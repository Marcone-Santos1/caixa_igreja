# Distribuição e atualização do app

> Atualizador embutido via nossa nuvem (Worker/R2), ativo desde o 1.4.0.
> A Play Store fica documentada na seção 5 como evolução futura.

## 1. Como o usuário recebe atualização

Ao abrir o app (com o backup na nuvem configurado), ele compara a própria
versão com a publicada. Havendo versão nova:

- **Banner na lista de eventos**: "Atualização X disponível — Instalar";
- ou **Ajustes → Atualização do app → Verificar/Instalar**.

Tocar em Instalar baixa o APK (barra de progresso, sha256 conferido) e abre
o instalador do Android. Na **primeira vez**, o Android pede para permitir
"instalar apps desconhecidos" para o Cantina Padroeira — uma única vez por
celular.

A **primeira instalação** num celular novo continua manual (mandar o APK
uma vez); só as atualizações são automáticas.

## 2. Como o desenvolvedor publica

```bash
./cloud/publish_app.sh "notas curtas da versão"
```

O script lê a versão do `pubspec.yaml` (lembre de **incrementar o
`+versionCode`** a cada publicação!), builda o release assinado, sobe o APK
e o manifest para `_app/` no R2. Pronto: os celulares avisam na próxima
abertura.

## 3. Assinatura (keystore)

- Keystore em `~/keys/cantina_padroeira/upload-keystore.jks` (senha no
  `LEIA-ME.txt` ao lado e em `android/key.properties`, ambos fora do git).
- **Faça backup da pasta `~/keys/cantina_padroeira/`** (Drive/pendrive).
  Perder a chave = ninguém atualiza sem desinstalar.
- Sem o `key.properties` (outra máquina), o build cai na chave de debug —
  serve para testar, mas NÃO publique um build desses.

## 4. Migração do app antigo (`com.example`) para o 1.4.0

O 1.4.0 trocou o `applicationId` para
`io.github.marconesantos1.cantinapadroeira` e a assinatura para a chave
própria, então ele **instala ao lado** do antigo — nada se perde. Para
migrar um celular que era o administrador da igreja:

1. Instale o 1.4.0 (manual, última vez). Os dois apps coexistem.
2. No **antigo**: Ajustes → Backup na nuvem → **Convidar celular** →
   Copiar convite.
3. No **novo**: **Conectar com QR** → colar o convite → entra na mesma
   igreja (como membro).
4. No **antigo**: Avançado → Celulares da igreja → (o novo) → **Tornar
   administrador**.
5. No **novo** (agora admin, enxerga todos os eventos): baixe os eventos
   que quiser manter.
6. Desinstale o antigo.

Celulares que não eram admin: passos 1–3 com um convite de qualquer admin,
baixar os eventos compartilhados, desinstalar o antigo.

## 5. Caminho futuro: Play Store (testes internos)

Quando valer a pena (mais igrejas/celulares):

1. Conta Google Play Console (US$ 25, uma vez) — https://play.google.com/console
2. Criar o app com o id `io.github.marconesantos1.cantinapadroeira`
   (já é o definitivo) e optar por **Play App Signing**, enviando a chave
   atual como *upload key*.
3. Build em AAB: `flutter build appbundle --release --dart-define=...`
4. Trilha **Testes internos**: até 100 testadores por e-mail, sem revisão
   longa; atualizações chegam sozinhas pela loja (inclusive a 1ª
   instalação).
5. O atualizador embutido detecta que não há nada mais novo e fica quieto;
   pode ser removido ou mantido como canal paralelo.
