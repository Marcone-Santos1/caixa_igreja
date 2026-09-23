---
name: Cantina Padroeira
description: Sistema de design caloroso, acolhedor e festivo inspirado na identidade visual da Cantina de Nossa Senhora Aparecida. Combina a solenidade e confiança do azul mariano com o aconchego do dourado e da terracota.
colors:
  primary: "#16437D"
  on-primary: "#FFFFFF"
  primary-container: "#DCE8FA"
  on-primary-container: "#0A264F"
  secondary: "#C98614"
  on-secondary: "#251700"
  secondary-container: "#FEE7BF"
  on-secondary-container: "#4A2E00"
  tertiary: "#8B4B27"
  on-tertiary: "#FFFFFF"
  tertiary-container: "#F8DFD2"
  on-tertiary-container: "#3E1805"
  background: "#FAF6EE"
  on-background: "#251F1A"
  surface: "#FFFFFF"
  surface-container: "#F2ECE0"
  surface-container-high: "#EAE3D4"
  on-surface: "#251F1A"
  outline: "#D8CEBD"
  outline-variant: "#E7DFD2"
  success: "#28753C"
  on-success: "#FFFFFF"
  success-container: "#DCF5E3"
  error: "#B3261E"
  on-error: "#FFFFFF"
  error-container: "#FCE8E6"
typography:
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.25
  headline-sm:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.45
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
  label-lg:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: 600
    lineHeight: 1.2
  label-md:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.04em
  label-caps:
    fontFamily: Outfit
    fontSize: 11px
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: 0.08em
rounded:
  none: 0px
  xs: 4px
  sm: 8px
  md: 14px
  lg: 20px
  xl: 28px
  full: 9999px
spacing:
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.md}"
    padding: 14px
  button-primary-hover:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
  button-secondary:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.on-secondary}"
    rounded: "{rounded.md}"
    padding: 14px
  card-surface:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: 16px
  chip-filter:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
    padding: 8px
  badge-success:
    backgroundColor: "{colors.success-container}"
    textColor: "{colors.success}"
    rounded: "{rounded.full}"
    padding: 6px
  badge-error:
    backgroundColor: "{colors.error-container}"
    textColor: "{colors.error}"
    rounded: "{rounded.full}"
    padding: 6px
  card-tertiary:
    backgroundColor: "{colors.tertiary-container}"
    textColor: "{colors.on-tertiary-container}"
    rounded: "{rounded.md}"
    padding: 12px
---

## Overview

O design system **Cantina Padroeira** foi concebido a partir da identidade artesanal e acolhedora da festa da comunidade (Nossa Senhora Aparecida — Pastel e Chá de Amendoim).

A filosofia visual equilibra:
1. **Confiança e Agilidade Operacional:** O Azul Mariano Profundo (`#16437D`) confere clareza, autoridade e contraste impecável para telas de Caixa e PDV.
2. **Afeto Comunitário e Festividade Gastronômica:** O Dourado Pastel Quente (`#C98614`) e a Terracota de Amendoim (`#8B4B27`) celebram o espírito da quermesse, destacando faturamento, métricas de sucesso e ações de venda.
3. **Legibilidade e Conforto:** Em vez de fundos brancos hospitalares e frios, as superfícies usam tons de marfim e linho suave (`#FAF6EE`), transmitindo o aconchego de uma recepção comunitária.

## Colors

As cores desempenham papéis semânticos estritos para guiar o operador voluntário sob alta demanda:

- **Primary (#16437D):** Azul Mariano central. Utilizado na AppBar, botões principais de confirmação, ícones institucionais e navegação ativa.
- **Secondary (#C98614):** Dourado Quente / Âmbar festivo. Representa a culinária da cantina (pastel frito dourado, insígnias). Utilizado em badges de destaque, botões de ação especial e cartões de faturamento.
- **Tertiary (#8B4B27):** Terracota / Chá de amendoim artesanal. Utilizado em métricas secundárias, divisores aconchegantes e categorias de produtos tradicionais.
- **Background (#FAF6EE):** Marfim suave que acolhe a vista dos voluntários durante longas horas de evento.
- **Surface (#FFFFFF):** Branco puro para cartões em primeiro plano, permitindo leitura limpa de itens de pedido, comandas e relatórios.
- **On-Surface (#251F1A):** Café profundo de altíssimo contraste, garantindo leitura sob sol ou ambientes iluminados de tenda/barraca.
- **Success (#28753C):** Verde esmeralda para confirmação de pagamento e status conectado.
- **Error (#B3261E):** Vermelho rubi para cancelamentos e estoques zerados.

## Typography

A tipografia combina o frescor moderno da família **Outfit** com a legibilidade robusta da **Inter**:

- **Headlines (Outfit):** Proporções geométricas e arredondadas com personalidade acolhedora e moderna. Usadas em títulos de tela, nomes de eventos e totais em moeda.
- **Body & Data (Inter):** Tipografia padrão da indústria para dados tabulares, listas de produtos, quantidades e descrições.
- **Labels & Tags (Outfit Bold/Caps):** Rótulos curtos em caixa alta e espaçamento expandido para crachás de pagamento (ex: `PIX`, `DINHEIRO`, `CARTÃO`).

## Layout

- **Escala de Espaçamento:** Baseada em múltiplos de 8px (com 4px para microespaçamento).
- **Cards com Respiro:** Nenhum elemento fica encostado nas bordas da tela. Padding horizontal padrão de 16px no mobile.
- **Densidade para Operação Rápida:** Botões de toque com altura mínima de 48px para facilitar o atendimento com luvas ou mãos ocupadas na cantina.

## Elevation & Depth

- **Elevação Tonal e Suave:** Evita sombras escuras artificiais. A hierarquia é obtida por contraste de fundo: telas no fundo Marfim (`#FAF6EE`), cartões no Branco (`#FFFFFF`) e modais/gavetas em recipientes com borda sutil (`#D8CEBD`).
- **Sombras Difusas:** Sombra sutil com opacidade inferior a 6% em tons castanhos, gerando efeito de papel artesanal assentado sobre o balcão.

## Shapes

- **Geometria Convidativa:** Cantos generosamente arredondados (`14px` para botões e inputs, `20px` para cards de produtos).
- **Pills e Chips:** Raios completos (`9999px`) em chips de categorias e status para toque ergonômico.

## Components

- **Botão Primário:** Fundo Azul Mariano com texto em Branco Puro. Transmite segurança e clareza no botão "Confirmar Venda".
- **Botão Dourado / Cantina:** Dourado Âmbar com texto branco/escuro para fechar pedidos ou imprimir via rápida.
- **Cards de Produto e Comanda:** Borda arredondada suave de 20px com contorno fino de linho (`#D8CEBD`), destacando foto, quantidade e valor formatado em reais com clareza.
- **Badges de Pagamento:** Pílulas coloridas para identificação visual relâmpago de `PIX` (ciano/dourado), `DINHEIRO` (verde) e `CARTÃO` (azul).

## Do's and Don'ts

- **DO:** Manter alto contraste entre texto café `#251F1A` e os cartões brancos e marfim.
- **DO:** Destacar valores em dinheiro (`R$`) com peso negrito e tipografia Outfit.
- **DO:** Usar o logotipo com carinho no cabeçalho ou tela inicial para reforçar a identidade da comunidade.
- **DON'T:** Usar cinza azulado hospitalar ou preto chapado `#000000` — prefira o tom café acolhedor `#251F1A`.
- **DON'T:** Utilizar cantos vivos ou pontiagudos de 0px que transmitam frieza industrial.
