# Guia de Sincronização Local Multi-dispositivos (PT-BR)

Este guia ensina como conectar vários celulares na mesma rede Wi-Fi local para trabalharem em conjunto no mesmo evento, registrando vendas de forma simultânea e atualizando o estoque e o painel financeiro em tempo real.

---

## 📋 Requisitos Básicos

1. **Rede Wi-Fi Comum**: Todos os celulares (o **Caixa Central** e os **Terminais**) precisam estar conectados à **mesma rede Wi-Fi**.
   > [!IMPORTANT]
   > Não é necessário ter acesso à Internet. O aplicativo se comunica usando a infraestrutura local do roteador Wi-Fi.
2. **Permissão de Rede Local**: Ao abrir a tela de sincronização local pela primeira vez, conceda as permissões de rede solicitadas pelo celular (Android ou iOS).

---

## 1. Configurando o Caixa Central (Servidor / Host)

O **Caixa Central** funciona como o "servidor" ou banco de dados principal. Todas as vendas feitas pelos outros caixas serão enviadas e consolidadas nele.

1. No celular principal, entre no evento que deseja gerenciar.
2. Acesse a aba/tela de **Sincronização Local**.
3. Selecione a opção **Caixa Central (Servidor / Host)**.
4. O servidor iniciará automaticamente:
   - Se estiver conectado a um Wi-Fi válido, ele mostrará o **IP do Servidor** (ex: `192.168.1.50`) e a **Porta** (padrão `8080`).
   - Um **QR Code** de conexão e um **Token de Conexão** serão gerados na tela.
5. Deixe essa tela aberta ou minimize o app (o servidor continuará ativo em segundo plano enquanto o evento estiver aberto).

---

## 2. Conectando os Caixas Adicionais (Terminais / Clientes)

Os **Terminais de Vendas** são os aparelhos que os caixas adicionais usarão para registrar as vendas. Eles recebem os produtos e denominadores em tempo real do Caixa Central.

### Método A: Descoberta Automática (Recomendado para uso real)
1. Conecte o terminal no mesmo Wi-Fi.
2. Acesse a tela de **Sincronização Local** e escolha **Terminal de Vendas (Cliente / Terminal)**.
3. Sob a seção **Servidores Disponíveis na Rede (Busca Automática)**, a lista detectará o nome do evento iniciado no Caixa Central.
4. Clique em **Conectar**. O app importará o evento automaticamente e entrará na tela do PDV sincronizado.

### Método B: Escaneando o QR Code (Caso a busca automática falhe)
1. No terminal, acesse a lista de eventos (tela inicial).
2. Clique no botão **Conectar a Caixa Central** localizado na barra superior do app.
3. Se estiver usando o celular fisicamente, você pode escanear o **QR Code** exibido na tela do Caixa Central.
4. O aplicativo lerá o token, criará o evento localmente e fará o pareamento de rede de forma instantânea.

### Método C: Colando o Token de Conexão (Fallback definitivo)
Ideal para computadores, emuladores (onde a rede é isolada pelo roteador virtual) ou quando a câmera não puder ser usada.
1. No **Caixa Central**, clique no botão **Copiar token de conexão** (isso copia o token em base64 com o protocolo `caixa://connect/...`).
2. Envie esse token para o operador do outro celular (via WhatsApp, chat local, etc.) ou copie-o no emulador.
3. No terminal, na tela inicial de eventos, clique em **Conectar a Caixa Central**.
4. Cole o token no campo de texto e clique em **Conectar**.

---

## 🛡️ Segurança de Dados e Restrições dos Terminais

Para evitar divergências financeiras e conflitos nos bancos de dados locais dos dispositivos, os **Terminais de Vendas** têm certas restrições:
- **Sem Modificações**: Botões de **Editar Venda**, **Excluir Venda** e **Baixar Troco Pendente** são ocultados e bloqueados nos terminais.
- **Autoridade Central**: Apenas o **Caixa Central** tem a autoridade para editar dados financeiros e autorizar ou cancelar vendas já finalizadas.

---

## 🔍 Resolução de Problemas (Troubleshooting)

### O botão "Caixa Central" não ativa ou mostra erro de porta
- **Causa**: Outro aplicativo pode estar usando a porta `8080` no dispositivo.
- **Solução**: Reinicie o aplicativo. Se persistir, verifique se há outras instâncias do app rodando em segundo plano.

### Terminais não encontram o Caixa Central na busca automática
- **Causa**: Alguns roteadores Wi-Fi modernos bloqueiam mensagens de difusão de rede (UDP Broadcast/Multicast) por segurança. Isso impede a descoberta automática.
- **Solução**: Use a conexão manual. Copie o Token de Conexão no host e cole no terminal no diálogo **Conectar a Caixa Central**. O pareamento direto via IP funcionará normalmente.

### Conexão cai no meio do evento
- **Causa**: O celular do Caixa Central entrou em modo de suspensão profunda (Deep Sleep) ou o sinal do Wi-Fi ficou muito fraco.
- **Solução**:
  - Evite que a tela do Caixa Central bloqueie totalmente ou configure o celular para não desligar o Wi-Fi em modo de suspensão.
  - Aproxime os celulares do roteador Wi-Fi para melhor estabilidade.
