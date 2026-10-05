/**
 * Cantina Padroeira — Worker de sincronização pela nuvem, POR EVENTO.
 * (RFC v2: docs/rfc_sincronizacao_nuvem_v2_por_evento.md)
 *
 * Cada evento tem a própria cadeia de versões `N -> N+1` (CAS por ETag no
 * manifest do evento). O app nunca fala com o R2 diretamente.
 *
 * REGISTRO AUTOMÁTICO: não existe lista de igrejas no servidor. O primeiro
 * request autenticado de um código novo grava `{code}/auth.json` com o hash
 * do segredo (escrita condicional "só se não existir") — a igreja reivindica
 * o próprio espaço. Dali em diante, só esse segredo acessa o prefixo.
 * Deploy é tarefa única do desenvolvedor; usuários nunca tocam na Cloudflare.
 *
 * Rotas (auth: headers x-church-code + x-church-secret):
 *   GET /v1/health                                — sem auth
 *   GET /v1/events                                — lista manifests dos eventos
 *   GET /v1/events/:eventId/manifest              — manifest de um evento
 *   GET /v1/events/:eventId/snapshot/:version     — gzip do snapshot
 *   PUT /v1/events/:eventId/snapshot?expected=N   — envia; vira versão N+1
 *       headers: x-snapshot-sha256, x-schema-version, x-format-version,
 *                x-device-id, x-device-name, x-event-title*, x-event-date-ms,
 *                x-summary (JSON pequeno)   (*latin-1; título vai no manifest)
 *
 * Retenção por evento: últimos KEEP_LAST snapshots + o mais novo de cada
 * semana nos últimos KEEP_WEEKS_DAYS dias.
 */

const MAX_SNAPSHOT_BYTES = 32 * 1024 * 1024; // agregado de evento: tipicamente KBs
const KEEP_LAST = 10;
const KEEP_WEEKS_DAYS = 180;
const MANIFEST_HISTORY = 15;
const MAX_EVENTS_LIST = 200;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, '');

    if (path === '/v1/health') {
      return json({ ok: true, now: new Date().toISOString() });
    }

    const auth = await authenticate(request, env);
    if (!auth.ok) {
      return json({ error: auth.error }, auth.status);
    }
    const prefix = auth.churchCode;

    try {
      if (request.method === 'GET' && path === '/v1/events') {
        return json({ events: await listEventManifests(env, prefix) });
      }

      const m = path.match(/^\/v1\/events\/([A-Za-z0-9-]{4,64})\/(manifest|snapshot)(?:\/(\d+))?$/);
      if (!m) return json({ error: 'Rota não encontrada' }, 404);
      const [, eventId, kind, versionStr] = m;

      if (request.method === 'GET' && kind === 'manifest') {
        const manifest = await readManifest(env, prefix, eventId);
        return json(stripEtag(manifest) ?? { eventId, version: 0 });
      }

      if (request.method === 'GET' && kind === 'snapshot' && versionStr) {
        const key = snapshotKey(prefix, eventId, parseInt(versionStr, 10));
        const obj = await env.BUCKET.get(key);
        if (!obj) return json({ error: 'Snapshot não encontrado' }, 404);
        return new Response(obj.body, {
          headers: { 'content-type': 'application/gzip' },
        });
      }

      if (request.method === 'PUT' && kind === 'snapshot' && !versionStr) {
        return await handleUpload(request, env, prefix, eventId, url);
      }

      return json({ error: 'Rota não encontrada' }, 404);
    } catch (e) {
      return json({ error: `Erro interno: ${e.message ?? e}` }, 500);
    }
  },
};

/** Autentica e, se for o primeiro uso do código, registra a igreja. */
async function authenticate(request, env) {
  const code = (request.headers.get('x-church-code') ?? '').toLowerCase();
  const secret = request.headers.get('x-church-secret') ?? '';
  if (!code || !secret) {
    return { ok: false, status: 401, error: 'Código da igreja e segredo são obrigatórios' };
  }
  if (!/^[a-z0-9][a-z0-9_-]{3,63}$/.test(code)) {
    return { ok: false, status: 400, error: 'Código da igreja inválido' };
  }
  const secretHash = await sha256Hex(new TextEncoder().encode(secret));
  const authKey = `${code}/auth.json`;

  let authObj = await env.BUCKET.get(authKey);
  if (!authObj) {
    // Primeiro uso: reivindica o espaço desta igreja (CAS: só se não existir).
    const record = JSON.stringify({
      secretHash,
      createdAt: new Date().toISOString(),
      createdBy: request.headers.get('x-device-name') ?? '',
    });
    const put = await env.BUCKET.put(authKey, record, {
      onlyIf: { etagDoesNotMatch: '*' },
      httpMetadata: { contentType: 'application/json' },
    });
    if (put !== null) {
      return { ok: true, churchCode: code };
    }
    // Perdeu a corrida com outro aparelho: relê e valida normalmente.
    authObj = await env.BUCKET.get(authKey);
    if (!authObj) {
      return { ok: false, status: 500, error: 'Falha ao registrar a igreja' };
    }
  }
  const stored = await authObj.json();
  if (!timingSafeEqual(secretHash, stored.secretHash ?? '')) {
    return { ok: false, status: 403, error: 'Segredo incorreto para esta igreja' };
  }
  return { ok: true, churchCode: code };
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

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

const manifestKey = (prefix, eventId) => `${prefix}/events/${eventId}/manifest.json`;
const snapshotKey = (prefix, eventId, version) =>
  `${prefix}/events/${eventId}/snapshots/v${String(version).padStart(6, '0')}.json.gz`;

async function readManifest(env, prefix, eventId) {
  const obj = await env.BUCKET.get(manifestKey(prefix, eventId));
  if (!obj) return null;
  const manifest = await obj.json();
  // R2Conditional exige o etag SEM aspas (obj.etag); httpEtag vem entre aspas
  // e faz o put condicional falhar ("Conditional ETag should not be wrapped
  // in quotes").
  manifest._etag = obj.etag;
  return manifest;
}

async function listEventManifests(env, prefix) {
  const list = await env.BUCKET.list({
    prefix: `${prefix}/events/`,
    delimiter: '/',
    limit: MAX_EVENTS_LIST,
  });
  const ids = (list.delimitedPrefixes ?? [])
    .map((p) => p.slice(`${prefix}/events/`.length).replace(/\/$/, ''))
    .filter(Boolean);
  const manifests = await Promise.all(
    ids.map(async (id) => stripEtag(await readManifest(env, prefix, id))),
  );
  return manifests.filter(Boolean);
}

async function handleUpload(request, env, prefix, eventId, url) {
  const expected = parseInt(url.searchParams.get('expected') ?? '', 10);
  if (!Number.isInteger(expected) || expected < 0) {
    return json({ error: 'Parâmetro expected inválido' }, 400);
  }
  const length = parseInt(request.headers.get('content-length') ?? '0', 10);
  if (length > MAX_SNAPSHOT_BYTES) {
    return json({ error: 'Snapshot grande demais' }, 413);
  }

  const current = await readManifest(env, prefix, eventId);
  const currentVersion = current?.version ?? 0;
  if (currentVersion !== expected) {
    return json(
      { error: 'conflict', manifest: stripEtag(current) ?? { eventId, version: 0 } },
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
  await env.BUCKET.put(snapshotKey(prefix, eventId, newVersion), body);

  const entry = {
    eventId,
    version: newVersion,
    sha256: actualSha,
    sizeBytes: body.byteLength,
    schemaVersion: parseInt(request.headers.get('x-schema-version') ?? '0', 10),
    formatVersion: parseInt(request.headers.get('x-format-version') ?? '0', 10),
    uploadedAt: new Date().toISOString(),
    deviceId: request.headers.get('x-device-id') ?? '',
    deviceName: request.headers.get('x-device-name') ?? '',
    eventTitle: request.headers.get('x-event-title') ?? '',
    eventDateMs: parseInt(request.headers.get('x-event-date-ms') ?? '0', 10),
    baseVersion: currentVersion,
    summary,
  };
  const manifest = {
    ...entry,
    history: [entry, ...(current?.history ?? [])]
      .slice(0, MANIFEST_HISTORY)
      .map(({ history, _etag, ...rest }) => rest),
  };

  const onlyIf = current?._etag
    ? { etagMatches: current._etag }
    : { etagDoesNotMatch: '*' };
  const put = await env.BUCKET.put(
    manifestKey(prefix, eventId),
    JSON.stringify(manifest),
    { onlyIf, httpMetadata: { contentType: 'application/json' } },
  );
  if (put === null) {
    await env.BUCKET.delete(snapshotKey(prefix, eventId, newVersion));
    const fresh = await readManifest(env, prefix, eventId);
    return json(
      { error: 'conflict', manifest: stripEtag(fresh) ?? { eventId, version: 0 } },
      409,
    );
  }

  await pruneSnapshots(env, prefix, eventId, newVersion);
  return json({ ok: true, manifest: stripEtag(manifest) });
}

function stripEtag(manifest) {
  if (!manifest) return null;
  const { _etag, ...rest } = manifest;
  return rest;
}

async function pruneSnapshots(env, prefix, eventId, currentVersion) {
  const list = await env.BUCKET.list({
    prefix: `${prefix}/events/${eventId}/snapshots/`,
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
    const isRecent = v > currentVersion - KEEP_LAST;
    if (!isRecent && !weeklyKeep.has(obj.key)) {
      deletions.push(env.BUCKET.delete(obj.key));
    }
  }
  await Promise.all(deletions);
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}
