# RFC v3 — Compartilhamento por evento com controle de aparelhos

> **Status:** Aprovada e implementada em 06/10/2026. Decisões da seção 5:
> (1) revogação REAL por credencial de aparelho; (2) **backup privado
> automático** — todo evento sobe com acesso só do dono, compartilhar =
> ampliar a lista (une o "nasce pausado" ao backup garantido); (3) gestão
> por dono + administradores; (4) quem recebe opera igual ("só acompanhar"
> fica para depois).
> **Motivação:** feedback do Marcone (06/10/2026): evento deve nascer SEM
> sincronizar; quem compartilha escolhe o evento e **gerencia quais celulares
> conectados seguem recebendo**.
> **Base:** RFC v2 (nuvem por evento) implementada — esta RFC muda o modelo
> de acesso, não o transporte.

---

## 1. Mudança de modelo mental

| Hoje (v2) | Proposta (v3) |
|---|---|
| Ativou a nuvem → **todo evento local sobe sozinho** | Evento **nasce local** (não compartilhado); nada sobe sem ação explícita |
| Pausa é opção *por aparelho* (opt-out) | **Compartilhar** é ação do dono (opt-in), evento a evento |
| Qualquer celular pareado vê e baixa **todos** os eventos da igreja | Cada evento tem **sua lista de celulares**; só quem está na lista vê/recebe |
| Remover acesso: não existe | O dono liga/desliga cada celular na lista — o celular para de receber novas versões |

O paralelo é compartilhar um álbum: o evento é seu até você compartilhá-lo,
e você escolhe com quem.

## 2. Experiência proposta

1. **Criar evento** → fica só no aparelho. O ☁️ do hub mostra
   "Não compartilhado — sem backup na nuvem" (com aviso sutil: se o celular
   quebrar, esse evento se perde — hoje o backup automático cobre isso).
2. **Compartilhar** → ☁️ → "Compartilhar na nuvem" → lista dos celulares
   conectados da igreja (padrão: todos marcados) → confirma → sobe v1 com a
   lista de acesso.
3. **No celular convidado** → o evento aparece no banner "disponível na
   nuvem" (só para quem está na lista) → Baixar → passa a receber e enviar
   normalmente (revezamento de caixa igual à v2).
4. **Gerenciar** → ☁️ → "Quem recebe" → interruptor por celular.
   Desligado: aquele celular para de receber novas versões e perde o acesso
   ao download. **O que ele já baixou permanece no aparelho dele** — não há
   apagamento remoto (impossível tecnicamente; melhor dizer com clareza).
5. **Novo celular na igreja** → pareamento por QR como hoje; entra na lista
   de "conectados" e pode ser incluído evento a evento.

A pausa por aparelho (v2) continua existindo do lado de quem recebe
("parar de seguir este evento neste celular"), com menos destaque.

## 3. O que muda por camada

**App**
- Estado novo do evento: `não compartilhado` / `compartilhado (dono)` /
  `recebido`. O fingerprint/dirty da v2 continua igual para os
  compartilhados.
- Fluxo "Compartilhar na nuvem" + tela "Quem recebe" no painel do evento.
- O refresh só considera eventos compartilhados; `GET /v1/events` já volta
  filtrado por aparelho.

**Worker**
- Registro de aparelhos: `{igreja}/devices/{deviceId}.json` (nome, entrada).
- Lista de acesso por evento (`acl` no manifest ou sidecar):
  `{ ownerDeviceId, sharedWith: [deviceId…] }`.
- `GET /v1/events` filtra pela lista; `GET snapshot`/`PUT` conferem acesso.
- Endpoints novos: `GET /v1/devices`, `PUT /v1/events/:id/acl`.

**Migração:** nada em produção de verdade (fase de testes) — eventos já na
nuvem viram "compartilhados com todos" ou a igreja de teste é recriada.

## 4. A decisão que define o tamanho da obra: a revogação é real?

Hoje **todos os celulares têm o mesmo segredo** (é o que o QR carrega).
Com segredo único, qualquer controle "por aparelho" no servidor é
*organizacional*: o Worker filtra pelo `deviceId` declarado, e um app
honesto obedece — mas quem tem o segredo da igreja poderia, tecnicamente,
continuar lendo. Para um time de cantina que se conhece, isso pode bastar.

Para a revogação ser **de verdade**, cada celular precisa de credencial
própria:
- O QR de pareamento vira um **convite** (código de uso único/limitado);
  o Worker troca o convite por um token do aparelho (hash guardado no
  `devices/{id}.json`). A experiência continua "mostrar QR / escanear".
- Revogar = apagar o token no servidor: o celular perde acesso na hora,
  inclusive ao que não baixou.
- Bônus que o segredo único nunca teve: dá para **remover um celular da
  igreja inteira** (hoje, quem viu o QR uma vez tem acesso para sempre).
- Custo: ~1 dia a mais (endpoints de convite/revogação no Worker, gestão de
  token no app, história de recuperação se o celular "dono" sumir).

**Recomendação:** credencial por aparelho (opção B). "Revogação por
confiança" não é revogação, e o delta é administrável. Mas é defensável
ficar na organizacional (A) se o objetivo é organização, não controle.

## 5. Decisões abertas (para o autor)

1. **Revogação:** real (credencial por aparelho, bloqueio no servidor) ou
   organizacional (segredo único; a lista controla o que o app mostra)?
2. **Quem gerencia o compartilhamento de um evento:** só o dono (quem
   compartilhou), dono + "primeiro celular da igreja" (admin), ou qualquer
   celular que tenha o evento? (Pensar no caso: o celular do dono quebrou.)
3. **Quem recebe pode tudo?** v1 proposto: quem recebe opera igual ao dono
   (vende, edita, envia de volta — é o revezamento de caixa). Um nível
   "só acompanhar" (leitura, ex.: tesoureiro de casa) fica anotado para
   depois — e casaria com a ideia futura de acompanhar vendas de casa.
4. **Evento não compartilhado perde o backup automático.** Aceitável com um
   aviso no hub, ou vale um "backup sem compartilhar" (sobe para a nuvem
   visível só para o próprio aparelho)?
