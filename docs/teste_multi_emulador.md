# Guia de Teste com Múltiplos Emuladores (Android Studio)

Este guia explica como simular e testar a sincronização local em tempo real utilizando **dois emuladores Android** rodando no mesmo computador através do Android Studio.

Como cada emulador roda por padrão atrás de uma rede virtual isolada (NAT), eles não conseguem se descobrir ou se comunicar diretamente usando IPs locais comuns. Precisamos usar o redirecionamento de portas do ADB para que a comunicação funcione.

---

## 📋 Pré-requisitos

1. Ter pelo menos **dois emuladores configurados e ativos** no Android Studio (ex: Emulador A e Emulador B).
2. O utilitário **`adb`** configurado e acessível no terminal da sua máquina de desenvolvimento.

---

## 🚀 Passo a Passo

### Passo 1: Identificar os IDs dos Emuladores
Com os dois emuladores abertos e rodando na sua tela, abra o terminal do seu computador (não o do emulador) e digite o seguinte comando:

```bash
adb devices
```

O comando retornará uma lista contendo os emuladores ativos. Exemplo:
```text
List of devices attached
emulator-5554   device
emulator-5556   device
```

Identifique qual emulador será o **Servidor (Caixa Central)** e qual será o **Cliente (Terminal)**. Neste exemplo:
- **`emulator-5554`**: Caixa Central (Servidor)
- **`emulator-5556`**: Terminal de Vendas (Cliente)

---

### Passo 2: Configurar o Redirecionamento de Portas (Port Forwarding)
O app Caixa Central escuta na porta **`8080`**. Precisamos fazer com que a porta `8080` do computador de desenvolvimento seja redirecionada para a porta `8080` interna do Emulador A (Servidor).

Execute o seguinte comando no terminal do seu computador:

```bash
adb -s emulator-5554 forward tcp:8080 tcp:8080
```
> **Nota:** Substitua `emulator-5554` pelo ID correspondente ao seu emulador Servidor caso seja diferente.

---

### Passo 3: Iniciar o Caixa Central no Emulador A
1. Abra o app no **Emulador A (`emulator-5554`)**.
2. Abra o evento desejado e navegue até a tela de **Sincronização Local**.
3. Ative a opção **Caixa Central (Servidor / Host)**.
4. O servidor iniciará e começará a escutar na porta `8080` interna dele (que agora está mapeada para a porta `8080` do seu computador).

---

### Passo 4: Conectar o Emulador B como Terminal
Como a rede dos emuladores é isolada, a busca automática não funcionará. Devemos conectar manualmente usando o IP especial de loopback da máquina host.

1. Abra o app no **Emulador B (`emulator-5556`)**.
2. Abra o mesmo evento (ou crie um de teste localmente).
3. Vá para a tela de **Sincronização Local** e selecione **Terminal de Vendas (Cliente / Terminal)**.
4. Toque para expandir a seção **Conexão Manual (Fallback)** no final da tela.
5. Preencha os campos da seguinte forma:
   - **IP do Servidor**: `10.0.2.2`
   - **Porta**: `8080`
6. Clique em **OK**.

> **Por que `10.0.2.2`?** No emulador Android, o IP `10.0.2.2` é um alias especial pré-configurado que aponta para o endereço de loopback (`127.0.0.1` / `localhost`) da sua máquina de desenvolvimento (computador host).

---

## 🎉 Testando o Funcionamento
Assim que você clicar em **OK**, o Emulador B se conectará ao Emulador A.
- Experimente criar um produto ou registrar uma venda no **Emulador B** e veja a alteração refletir instantaneamente no painel/listagens do **Emulador A**.
- Efetue qualquer modificação de preços ou estoque no **Emulador A** e veja a mudança ser replicada instantaneamente no **Emulador B**.
