# RFC — Venda fiada

> **Status:** Aprovada e implementada em 06/10/2026 (app 1.3.0, schema v10,
> agregado formato v2). Decisões da seção 6: (1) pagamento parcial SIM;
> (2) tela geral por pessoa SIM (aba Exportar → Fiados); (3) cliente por
> texto livre + sugestões; (4) aviso de saldo no checkout, sem bloquear.
> **Pedido:** Marcone (06/10/2026): "venda fiada".
> **Contexto:** cantina de igreja; cliente conhecido leva o produto e paga
> depois (no fim do evento, na semana seguinte…).

---

## 1. O que é, no modelo do app

Uma venda fiada é uma venda **completa** (itens entregues, estoque baixado)
cujo pagamento fica **em aberto, em nome de alguém**, até ser recebido —
possivelmente em outra sessão de caixa. É o espelho invertido do "troco
pendente" que já existe (lá, o caixa deve ao cliente; aqui, o cliente deve
ao caixa) — e reaproveita o mesmo desenho de ponta a ponta: marcação na
venda, selo no registro, resolução depois e linha no fechamento impresso.

## 2. Modelagem (migração v10)

- **Novo método de pagamento `fiado`** no checkout. Venda fiada exige o
  **nome do cliente** (campo `customerName` que já existe).
- **Nova tabela `fiado_payments`** (com as colunas de sincronização v9 e
  trigger de carimbo):
  `id, saleId, amountCents, method, paidAtMs, sessionId?, notes?, deviceId`.
  Cada recebimento é uma linha **append-only** (como as movimentações de
  estoque): permite pagamento parcial, auditoria de quem recebeu quando, e
  sincroniza sem conflito (união de linhas). Desfazer um lançamento errado =
  tombstone.
- **Saldo devedor é derivado, nunca flag:** `devido = totalCents −
  soma(pagamentos vivos)`. Venda aberta = saldo > 0. Mesma filosofia do
  estoque E1 e do fingerprint (nada de estado mantido à mão).
- `completeSale`: com método `fiado`, aceita `amountReceivedCents <
  totalCents` (hoje isso é erro). Entrada na hora (ex.: paga metade) vira o
  primeiro lançamento em `fiado_payments`.
- Troco não se aplica a fiado (nada foi recebido além da entrada exata).

## 3. Dinheiro certo no caixa (a parte delicada)

Hoje o fechamento espera na gaveta: `fundo + vendas em dinheiro − troco
dado`. Com fiado:

- A venda fiada **não** entra em "vendas em dinheiro" (não há dinheiro).
- Um **recebimento** de fiado em dinheiro entra na gaveta **da sessão em que
  foi recebido** (`fiado_payments.sessionId`), mesmo que a venda seja de
  outra sessão.
- O fechamento impresso ganha duas linhas: "(+) Fiados recebidos em
  dinheiro" e a lista de **fiados em aberto** (nome · valor), igual à lista
  de trocos pendentes que já sai no comprovante.
- Resumo financeiro/dashboard: "Fiado" aparece como método, separado em
  **recebido** × **em aberto** (em aberto não é dinheiro em caixa).

## 4. Onde o usuário vê e usa

1. **Checkout:** opção "Fiado" junto dos métodos de pagamento; ao escolher,
   o nome do cliente vira obrigatório (com sugestões dos nomes já usados) e
   aparece campo opcional "entrada".
2. **Registro do evento:** selo "Fiado · deve R$ X" na venda (como o selo de
   troco pendente), com ação **"Receber"** → valor (pré-preenchido com o
   saldo), método, pronto. Parcial deixa o restante em aberto.
3. **Tela "Fiados" do evento** (pelo hub): lista por pessoa com saldo,
   histórico de lançamentos e botão receber.
4. **Fechamento de caixa:** fiados em aberto listados no comprovante; fiados
   recebidos em dinheiro somados à gaveta esperada.

## 5. Sincronização

- `fiado_payments` entra no **agregado do evento da venda** (nuvem e Wi-Fi):
  quem tem o evento vê e recebe os fiados dele. União de linhas append-only
  — zero conflito entre celulares.
- Receber um fiado exige ter o evento no aparelho (compartilhado via RFC
  v3), como qualquer outra operação do evento.

## 6. Decisões abertas (para o autor)

1. **Pagamento parcial:** liberar desde já (a tabela de lançamentos dá isso
   de graça) ou v1 só quitação total? *Rec.: parcial.*
2. **Receber fora do evento de origem:** uma tela geral "Fiados" (todas as
   dívidas de todos os eventos, agrupadas por pessoa) além da tela por
   evento? O lançamento sempre cai no evento da venda; se não houver sessão
   ativa lá, fica como "recebido fora de caixa" (não entra em gaveta
   nenhuma). *Rec.: sim, tela geral no menu Exportar/Relatórios ou Ajustes.*
3. **Cliente:** texto livre com autocomplete dos nomes já usados, ou
   cadastro de clientes de verdade (tabela própria)? *Rec.: texto livre +
   autocomplete no v1; cadastro só se a lista geral mostrar que precisa.*
4. **Limite/trava:** algum aviso tipo "esta pessoa já deve R$ X" na hora de
   fiar de novo? *Rec.: mostrar o saldo atual da pessoa no checkout, sem
   bloquear.*
