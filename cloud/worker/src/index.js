/**
 * Cantina Padroeira — Worker de sincronização POR EVENTO com
 * COMPARTILHAMENTO CONTROLADO (RFC v3).
 *
 * Modelo de acesso:
 * - Cada CELULAR tem credencial própria (token, guardado como hash). O QR de
 *   pareamento é um CONVITE de uso único que o Worker troca por um token.
 *   Revogar um celular corta o acesso na hora, no servidor.
 * - Cada EVENTO tem dono (`ownerDeviceId`) e lista de acesso (`sharedWith`).
 *   Por padrão um evento é PRIVADO (backup só do dono); compartilhar é
 *   ampliar a lista. Dono e admins gerenciam a lista.
 * - O primeiro celular da igreja é admin; admins convidam, revogam e podem
 *   promover outros admins (cobre o caso do celular do dono quebrar).
 *
 * Armazenamento (R2):
 *   {igreja}/church.json                      — marca a criação da igreja
 *   {igreja}/devices/{deviceId}.json          — nome, hash do token, papel
 *   {igreja}/invites/{inviteId}.json          — convites (uso único, 48h)
 *   {igreja}/events/{id}/manifest.json        — versão atual + acl
 *   {igreja}/events/{id}/snapshots/v*.json.gz
 *
 * Rotas:
 *   GET  /v1/health                               — sem auth
 *   POST /v1/register   {deviceName}              — cria a igreja (1º celular)
 *   POST /v1/join       {inviteId, inviteSecret, deviceName}
 *   GET  /v1/devices                              — lista celulares (auth)
 *   PUT  /v1/devices/:id {revoked?, role?}        — admin
 *   POST /v1/invites                              — admin; retorna convite
 *   GET  /v1/events                               — só eventos acessíveis
 *   GET  /v1/events/:id/manifest                  — dono/compartilhado/admin
 *   GET  /v1/events/:id/snapshot/:version         — idem
 *   PUT  /v1/events/:id/snapshot?expected=N       — idem; versão N -> N+1 (CAS)
 *   PUT  /v1/events/:id/acl {sharedWith: [...]}   — dono ou admin
 *
 * Headers de auth: x-church-code, x-device-id, x-device-token.
 */

const MAX_SNAPSHOT_BYTES = 32 * 1024 * 1024;
const KEEP_LAST = 10;
const KEEP_WEEKS_DAYS = 180;
const MANIFEST_HISTORY = 15;
const MAX_EVENTS_LIST = 200;
const INVITE_TTL_MS = 48 * 3600 * 1000;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, '');

    try {
      if (path === '/v1/health') {
        return json({ ok: true, now: new Date().toISOString() });
      }
      if (request.method === 'POST' && path === '/v1/register') {
        return await handleRegister(request, env);
      }
      if (request.method === 'POST' && path === '/v1/join') {
        return await handleJoin(request, env);
      }

      const auth = await authenticate(request, env);
      if (!auth.ok) return json({ error: auth.error }, auth.status);
      const { code, device } = auth;

      // ─── Distribuição do app (atualizador embutido) ───────────────────
      // Os arquivos ficam em `_app/` (prefixo impossível como código de
      // igreja) e são publicados pelo desenvolvedor via cloud/publish_app.sh.
      if (request.method === 'GET' && path === '/v1/app/latest') {
        const manifest = await readJson(env, '_app/latest.json');
        return json(manifest ?? { versionCode: 0 });
      }
      const apkMatch = path.match(/^\/v1\/app\/apk\/(\d{1,10})$/);
      if (request.method === 'GET' && apkMatch) {
        const obj = await env.BUCKET.get(`_app/cantina-${apkMatch[1]}.apk`);
        if (!obj) return json({ error: 'APK não encontrado' }, 404);
        return new Response(obj.body, {
          headers: {
            'content-type': 'application/vnd.android.package-archive',
            'content-length': String(obj.size),
          },
        });
      }

      if (request.method === 'GET' && path === '/v1/events') {
        return json({ events: await listAccessibleEvents(env, code, device) });
      }
      if (request.method === 'GET' && path === '/v1/devices') {
        return json({ devices: await listDevices(env, code) });
      }
      if (request.method === 'POST' && path === '/v1/invites') {
        if (device.role !== 'admin') {
          return json({ error: 'Só o celular administrador convida outros' }, 403);
        }
        return await createInvite(env, code);
      }

      const devMatch = path.match(/^\/v1\/devices\/([A-Za-z0-9-]{4,64})$/);
      if (request.method === 'PUT' && devMatch) {
        if (device.role !== 'admin') {
          return json({ error: 'Só o celular administrador gerencia celulares' }, 403);
        }
        return await updateDevice(request, env, code, devMatch[1], device);
      }

      const evMatch = path.match(
        /^\/v1\/events\/([A-Za-z0-9-]{4,64})\/(manifest|snapshot|acl)(?:\/(\d+))?$/,
      );
      if (!evMatch) return json({ error: 'Rota não encontrada' }, 404);
      const [, eventId, kind, versionStr] = evMatch;

      const manifest = await readManifest(env, code, eventId);
      const access = canAccessEvent(manifest, device);

      if (request.method === 'GET' && kind === 'manifest') {
        if (manifest && !access) return json({ error: 'Sem acesso a este evento' }, 403);
        return json(publicManifest(manifest) ?? { eventId, version: 0 });
      }
      if (request.method === 'GET' && kind === 'snapshot' && versionStr) {
        if (!manifest || !access) return json({ error: 'Sem acesso a este evento' }, 403);
        const obj = await env.BUCKET.get(
          snapshotKey(code, eventId, parseInt(versionStr, 10)),
        );
        if (!obj) return json({ error: 'Snapshot não encontrado' }, 404);
        return new Response(obj.body, {
          headers: { 'content-type': 'application/gzip' },
        });
      }
      if (request.method === 'PUT' && kind === 'snapshot' && !versionStr) {
        // Evento novo: quem envia vira o dono. Existente: precisa de acesso.
        if (manifest && !access) return json({ error: 'Sem acesso a este evento' }, 403);
        return await handleUpload(request, env, code, eventId, url, manifest, device);
      }
      if (request.method === 'PUT' && kind === 'acl') {
        if (!manifest) return json({ error: 'Evento não encontrado' }, 404);
        const isOwner = manifest.ownerDeviceId === device.deviceId;
        if (!isOwner && device.role !== 'admin') {
          return json({ error: 'Só o dono do evento ou um administrador gerencia o compartilhamento' }, 403);
        }
        return await updateAcl(request, env, code, eventId, manifest);
      }

      return json({ error: 'Rota não encontrada' }, 404);
    } catch (e) {
      return json({ error: `Erro interno: ${e.message ?? e}` }, 500);
    }
  },
};

// ─── Identidade e acesso ─────────────────────────────────────────────────

function parseIdentity(request) {
  const code = (request.headers.get('x-church-code') ?? '').toLowerCase();
  const deviceId = request.headers.get('x-device-id') ?? '';
  if (!/^[a-z0-9][a-z0-9_-]{3,63}$/.test(code)) return null;
  if (!/^[A-Za-z0-9-]{4,64}$/.test(deviceId)) return null;
  return { code, deviceId };
}

async function authenticate(request, env) {
  const id = parseIdentity(request);
  const token = request.headers.get('x-device-token') ?? '';
  if (!id || !token) {
    return { ok: false, status: 401, error: 'Credenciais do celular ausentes' };
  }
  const record = await readJson(env, `${id.code}/devices/${id.deviceId}.json`);
  if (!record || record.revoked) {
    return { ok: false, status: 403, error: 'Este celular não tem mais acesso. Peça um novo convite.' };
  }
  const tokenHash = await sha256Hex(new TextEncoder().encode(token));
  if (!timingSafeEqual(tokenHash, record.tokenHash ?? '')) {
    return { ok: false, status: 403, error: 'Credencial do celular inválida' };
  }
  return { ok: true, code: id.code, device: record };
}

function canAccessEvent(manifest, device) {
  if (!manifest) return false;
  if (device.role === 'admin') return true;
  if (manifest.ownerDeviceId === device.deviceId) return true;
  return (manifest.sharedWith ?? []).includes(device.deviceId);
}

async function handleRegister(request, env) {
  const id = parseIdentity(request);
  if (!id) return json({ error: 'Código da igreja ou id do celular inválidos' }, 400);
  const body = await request.json().catch(() => ({}));
  const deviceName = String(body.deviceName ?? 'Celular').slice(0, 60);

  // Reivindica a igreja: só se ainda não existir.
  const claimed = await env.BUCKET.put(
    `${id.code}/church.json`,
    JSON.stringify({ createdAt: new Date().toISOString() }),
    { onlyIf: { etagDoesNotMatch: '*' }, httpMetadata: { contentType: 'application/json' } },
  );
  if (claimed === null) {
    return json({ error: 'Este código já está em uso' }, 409);
  }

  const token = randomToken();
  const record = {
    deviceId: id.deviceId,
    name: deviceName,
    tokenHash: await sha256Hex(new TextEncoder().encode(token)),
    role: 'admin',
    joinedAt: new Date().toISOString(),
    revoked: false,
  };
  await writeJson(env, `${id.code}/devices/${id.deviceId}.json`, record);
  return json({ ok: true, deviceToken: token, role: 'admin' });
}

async function createInvite(env, code) {
  const inviteId = crypto.randomUUID();
  const secret = randomToken();
  await writeJson(env, `${code}/invites/${inviteId}.json`, {
    secretHash: await sha256Hex(new TextEncoder().encode(secret)),
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + INVITE_TTL_MS).toISOString(),
    usedByDeviceId: null,
  });
  return json({
    ok: true,
    inviteId,
    inviteSecret: secret,
    expiresAt: new Date(Date.now() + INVITE_TTL_MS).toISOString(),
  });
}

async function handleJoin(request, env) {
  const id = parseIdentity(request);
  if (!id) return json({ error: 'Código da igreja ou id do celular inválidos' }, 400);
  const body = await request.json().catch(() => ({}));
  const inviteId = String(body.inviteId ?? '');
  const inviteSecret = String(body.inviteSecret ?? '');
  const deviceName = String(body.deviceName ?? 'Celular').slice(0, 60);
  if (!/^[0-9a-f-]{10,40}$/.test(inviteId)) {
    return json({ error: 'Convite inválido' }, 400);
  }

  const key = `${id.code}/invites/${inviteId}.json`;
  const obj = await env.BUCKET.get(key);
  if (!obj) return json({ error: 'Convite não encontrado ou já usado' }, 403);
  const invite = await obj.json();
  const secretHash = await sha256Hex(new TextEncoder().encode(inviteSecret));
  if (!timingSafeEqual(secretHash, invite.secretHash ?? '')) {
    return json({ error: 'Convite inválido' }, 403);
  }
  if (invite.usedByDeviceId || Date.parse(invite.expiresAt ?? 0) < Date.now()) {
    return json({ error: 'Convite expirado ou já usado. Peça um novo.' }, 403);
  }

  // Marca como usado com CAS (dois celulares escaneando o mesmo QR: um ganha).
  invite.usedByDeviceId = id.deviceId;
  const marked = await env.BUCKET.put(key, JSON.stringify(invite), {
    onlyIf: { etagMatches: obj.etag },
    httpMetadata: { contentType: 'application/json' },
  });
  if (marked === null) {
    return json({ error: 'Convite expirado ou já usado. Peça um novo.' }, 403);
  }

  const existing = await readJson(env, `${id.code}/devices/${id.deviceId}.json`);
  const token = randomToken();
  const record = {
    deviceId: id.deviceId,
    name: deviceName,
    tokenHash: await sha256Hex(new TextEncoder().encode(token)),
    role: existing?.role === 'admin' ? 'admin' : 'member',
    joinedAt: existing?.joinedAt ?? new Date().toISOString(),
    revoked: false,
  };
  await writeJson(env, `${id.code}/devices/${id.deviceId}.json`, record);
  return json({ ok: true, deviceToken: token, role: record.role });
}

async function listDevices(env, code) {
  const list = await env.BUCKET.list({ prefix: `${code}/devices/`, limit: 200 });
  const devices = [];
  for (const obj of list.objects) {
    const record = await readJson(env, obj.key);
    if (record) {
      devices.push({
        deviceId: record.deviceId,
        name: record.name,
        role: record.role,
        joinedAt: record.joinedAt,
        revoked: record.revoked === true,
      });
    }
  }
  return devices;
}

async function updateDevice(request, env, code, targetId, requester) {
  const record = await readJson(env, `${code}/devices/${targetId}.json`);
  if (!record) return json({ error: 'Celular não encontrado' }, 404);
  const body = await request.json().catch(() => ({}));
  if (typeof body.revoked === 'boolean') {
    if (targetId === requester.deviceId && body.revoked) {
      return json({ error: 'Um administrador não pode revogar o próprio celular' }, 400);
    }
    record.revoked = body.revoked;
  }
  if (body.role === 'admin' || body.role === 'member') {
    if (targetId === requester.deviceId && body.role !== 'admin') {
      return json({ error: 'Um administrador não pode rebaixar o próprio celular' }, 400);
    }
    record.role = body.role;
  }
  await writeJson(env, `${code}/devices/${targetId}.json`, record);
  return json({ ok: true });
}

// ─── Eventos ─────────────────────────────────────────────────────────────

const manifestKey = (code, eventId) => `${code}/events/${eventId}/manifest.json`;
const snapshotKey = (code, eventId, version) =>
  `${code}/events/${eventId}/snapshots/v${String(version).padStart(6, '0')}.json.gz`;

async function readManifest(env, code, eventId) {
  const obj = await env.BUCKET.get(manifestKey(code, eventId));
  if (!obj) return null;
  const manifest = await obj.json();
  manifest._etag = obj.etag; // sem aspas: R2Conditional exige o etag cru
  return manifest;
}

function publicManifest(manifest) {
  if (!manifest) return null;
  const { _etag, ...rest } = manifest;
  return rest;
}

async function listAccessibleEvents(env, code, device) {
  const list = await env.BUCKET.list({
    prefix: `${code}/events/`,
    delimiter: '/',
    limit: MAX_EVENTS_LIST,
  });
  const ids = (list.delimitedPrefixes ?? [])
    .map((p) => p.slice(`${code}/events/`.length).replace(/\/$/, ''))
    .filter(Boolean);
  const manifests = await Promise.all(ids.map((id) => readManifest(env, code, id)));
  return manifests
    .filter((m) => m && canAccessEvent(m, device))
    .map(publicManifest);
}

async function handleUpload(request, env, code, eventId, url, current, device) {
  const expected = parseInt(url.searchParams.get('expected') ?? '', 10);
  if (!Number.isInteger(expected) || expected < 0) {
    return json({ error: 'Parâmetro expected inválido' }, 400);
  }
  const length = parseInt(request.headers.get('content-length') ?? '0', 10);
  if (length > MAX_SNAPSHOT_BYTES) return json({ error: 'Snapshot grande demais' }, 413);

  const currentVersion = current?.version ?? 0;
  if (currentVersion !== expected) {
    return json(
      { error: 'conflict', manifest: publicManifest(current) ?? { eventId, version: 0 } },
      409,
    );
  }

  const body = await request.arrayBuffer();
  if (body.byteLength === 0) return json({ error: 'Corpo vazio' }, 400);
  if (body.byteLength > MAX_SNAPSHOT_BYTES) {
    return json({ error: 'Snapshot grande demais' }, 413);
  }
  const declaredSha = (request.headers.get('x-snapshot-sha256') ?? '').toLowerCase();
  const actualSha = await sha256Hex(body);
  if (declaredSha && declaredSha !== actualSha) {
    return json({ error: 'sha256 não confere (upload corrompido?)' }, 400);
  }

  let summary = null;
  try {
    summary = JSON.parse(request.headers.get('x-summary') ?? 'null');
  } catch {
    summary = null;
  }

  const newVersion = currentVersion + 1;
  await env.BUCKET.put(snapshotKey(code, eventId, newVersion), body);

  const entry = {
    eventId,
    version: newVersion,
    sha256: actualSha,
    sizeBytes: body.byteLength,
    schemaVersion: parseInt(request.headers.get('x-schema-version') ?? '0', 10),
    formatVersion: parseInt(request.headers.get('x-format-version') ?? '0', 10),
    uploadedAt: new Date().toISOString(),
    deviceId: device.deviceId,
    deviceName: device.name,
    eventTitle: request.headers.get('x-event-title') ?? '',
    eventDateMs: parseInt(request.headers.get('x-event-date-ms') ?? '0', 10),
    eventDeleted: request.headers.get('x-event-deleted') === 'true',
    baseVersion: currentVersion,
    summary,
  };
  const manifest = {
    ...entry,
    // A lista de acesso pertence ao evento, não ao upload: preservada.
    // Evento novo nasce PRIVADO (backup só do dono).
    ownerDeviceId: current?.ownerDeviceId ?? device.deviceId,
    sharedWith: current?.sharedWith ?? [],
    history: [entry, ...(current?.history ?? [])]
      .slice(0, MANIFEST_HISTORY)
      .map(({ history, _etag, ...rest }) => rest),
  };

  const onlyIf = current?._etag
    ? { etagMatches: current._etag }
    : { etagDoesNotMatch: '*' };
  const put = await env.BUCKET.put(manifestKey(code, eventId), JSON.stringify(manifest), {
    onlyIf,
    httpMetadata: { contentType: 'application/json' },
  });
  if (put === null) {
    await env.BUCKET.delete(snapshotKey(code, eventId, newVersion));
    const fresh = await readManifest(env, code, eventId);
    return json(
      { error: 'conflict', manifest: publicManifest(fresh) ?? { eventId, version: 0 } },
      409,
    );
  }

  await pruneSnapshots(env, code, eventId, newVersion);
  return json({ ok: true, manifest: publicManifest(manifest) });
}

async function updateAcl(request, env, code, eventId, current) {
  const body = await request.json().catch(() => ({}));
  const sharedWith = Array.isArray(body.sharedWith)
    ? body.sharedWith
        .map(String)
        .filter((id) => /^[A-Za-z0-9-]{4,64}$/.test(id))
        .slice(0, 50)
    : null;
  if (sharedWith === null) return json({ error: 'sharedWith inválido' }, 400);

  const manifest = { ...publicManifest(current), sharedWith };
  const put = await env.BUCKET.put(manifestKey(code, eventId), JSON.stringify(manifest), {
    onlyIf: { etagMatches: current._etag },
    httpMetadata: { contentType: 'application/json' },
  });
  if (put === null) {
    // Upload concorrente mudou o manifest: o app refaz a leitura e tenta de novo.
    return json({ error: 'conflict', manifest: publicManifest(await readManifest(env, code, eventId)) }, 409);
  }
  return json({ ok: true, manifest });
}

async function pruneSnapshots(env, code, eventId, currentVersion) {
  const list = await env.BUCKET.list({
    prefix: `${code}/events/${eventId}/snapshots/`,
    limit: 1000,
  });
  const parse = (key) => {
    const m = key.match(/v(\d+)\.json\.gz$/);
    return m ? parseInt(m[1], 10) : null;
  };
  const cutoff = Date.now() - KEEP_WEEKS_DAYS * 24 * 3600 * 1000;
  const weeklyKeep = new Set();
  const byWeek = new Map();
  for (const obj of list.objects) {
    const v = parse(obj.key);
    if (v === null) continue;
    const t = obj.uploaded?.getTime?.() ?? 0;
    if (t < cutoff) continue;
    const week = Math.floor(t / (7 * 24 * 3600 * 1000));
    const prev = byWeek.get(week);
    if (!prev || v > prev.v) byWeek.set(week, { v, key: obj.key });
  }
  for (const { key } of byWeek.values()) weeklyKeep.add(key);

  const deletions = [];
  for (const obj of list.objects) {
    const v = parse(obj.key);
    if (v === null) continue;
    if (v > currentVersion - KEEP_LAST) continue;
    if (!weeklyKeep.has(obj.key)) deletions.push(env.BUCKET.delete(obj.key));
  }
  await Promise.all(deletions);
}

// ─── Utilitários ─────────────────────────────────────────────────────────

async function readJson(env, key) {
  const obj = await env.BUCKET.get(key);
  return obj ? obj.json() : null;
}

function writeJson(env, key, data) {
  return env.BUCKET.put(key, JSON.stringify(data), {
    httpMetadata: { contentType: 'application/json' },
  });
}

function randomToken() {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('');
}

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function timingSafeEqual(a, b) {
  const enc = new TextEncoder();
  const ab = enc.encode(a);
  const bb = enc.encode(b);
  if (ab.length !== bb.length) return false;
  let diff = 0;
  for (let i = 0; i < ab.length; i++) diff |= ab[i] ^ bb[i];
  return diff === 0;
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}
