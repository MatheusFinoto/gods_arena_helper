# helper_frontend - Arquitetura, layout e guia visual

## Visao geral

O `helper_frontend` e um app Flutter desktop com foco em painel operacional. A arquitetura e enxuta, mas ja esta organizada por camadas: `core` concentra constantes e enums compartilhados, `domain` define entidades e casos de uso, `presentation` monta a interface e seus estados locais, e `service` faz a ponte com o backend Python.

O fluxo principal hoje e:

`UI/Page -> State (ChangeNotifier) -> Usecase -> PyCommandService / SharedPreferences`

---

## Mapa da arquitetura

```text
helper_frontend/
+-- assets/
|   +-- images/
|       +-- athens.png
|       `-- sparta.png
+-- lib/
|   +-- core/
|   |   +-- constants/
|   |   |   +-- assets_constants.dart
|   |   |   +-- dashboard_layout_constants.dart
|   |   |   +-- shared_preferences_constants.dart
|   |   |   +-- theme_colors_constants.dart
|   |   |   `-- theme_constants.dart
|   |   `-- enums/
|   |       +-- dashboard_pages_enum.dart
|   |       `-- faction_enum.dart
|   +-- domain/
|   |   +-- entities/
|   |   |   +-- account.dart
|   |   |   +-- app_settings.dart
|   |   |   +-- autoship_account_config.dart
|   |   |   +-- autoship_event.dart
|   |   |   `-- autoship_status.dart
|   |   `-- usecases/
|   |       +-- accounts_usecase.dart
|   |       +-- autoship_usecase.dart
|   |       `-- settings_usecase.dart
|   +-- presentation/
|   |   +-- auth/
|   |   |   `-- (reservado / ainda sem implementacao relevante)
|   |   `-- dashboard/
|   |       +-- components/
|   |       |   `-- dash_drawer.dart
|   |       +-- pages/
|   |       |   +-- home_page.dart
|   |       |   +-- autoship_page.dart
|   |       |   `-- settings_page.dart
|   |       +-- states/
|   |       |   +-- autoship_state.dart
|   |       |   +-- home_page_state.dart
|   |       |   `-- settings_state.dart
|   |       +-- dashboard_state.dart
|   |       `-- dashboard_view.dart
|   +-- service/
|   |   `-- py_command_service.dart
|   +-- main.dart
|   +-- main_services.dart
|   `-- main_state.dart
`-- windows/
    +-- runner/
    `-- flutter/
```

### Responsabilidade por pasta

- `lib/core/`: design tokens, cores, limites de layout, assets e enums globais.
- `lib/domain/entities/`: modelos de negocio usados pela UI e pelos usecases.
- `lib/domain/usecases/`: regras de orquestracao; hoje chamam Python e persistencia local.
- `lib/presentation/dashboard/`: shell principal do app, navegacao lateral, paginas e estados da interface.
- `lib/service/`: adaptador de infraestrutura que executa o `helper_service` em Python.
- `lib/main*.dart`: bootstrap da aplicacao, injecao simples via `Provider` e estado global.

---

## Fluxo arquitetural

### 1. Bootstrap

- `main.dart` sobe `MaterialApp`, registra providers e escolhe `lightTheme` / `darkTheme`.
- `main_services.dart` monta os usecases e injeta um unico `PyCommandService`.
- `main_state.dart` centraliza dados globais, hoje principalmente:
  - tema ativo
  - contas carregadas
  - refresh global de contas

### 2. Navegacao

- `DashboardView` cria um shell com `DashDrawer` fixo na lateral e `PageView` para trocar paginas.
- `DashboardState` controla pagina atual e sincroniza o `PageController`.

### 3. Paginas e estados locais

- `HomePage` mostra overview das contas e delega interacoes ao `MainState`.
- `AutoShipPage` usa `AutoShipState` para selecao, execucao e acompanhamento por PID.
- `SettingsPage` usa `SettingsState` para path do jogo, tema e acao de BetterSearch.
- Cada pagina mantem estado proprio em `ChangeNotifier`, evitando inflar o estado global.

### 4. Integracoes

- `AccountsUsecase` chama Python para listar contas e focar janela.
- `AutoShipUsecase` chama Python para iniciar o fluxo automatizado.
- `SettingsUsecase` mistura persistencia local via `SharedPreferences` com chamadas Python.
- `PyCommandService` executa `helper_service/src/main.py`, espera JSON em `stdout` e normaliza erros.

### Leitura rapida da arquitetura

- E uma arquitetura em camadas, mas pragmatica.
- Nao existe ainda uma camada `data/` separada.
- Os usecases falam direto com a infraestrutura.
- O frontend depende fortemente do backend Python para automacoes e leitura do jogo.
- Para o tamanho atual do projeto, a organizacao esta boa e facil de expandir.

---

## Layout, tema e caracteristicas visuais

### Estrutura do layout

- App desktop-first com navegacao lateral fixa e area de conteudo ampla.
- Sidebar com aproximadamente `280px`, visual premium e forte presenca de marca.
- Conteudo principal centralizado com `maxWidth = 1180`.
- Padding generoso (`24px`) e espacamento consistente entre secoes.
- Cada pagina segue o mesmo esqueleto:
  - fundo com acentos desfocados
  - hero section no topo
  - paineis/cards abaixo

### Linguagem visual

- Visual moderno de dashboard, com clima "control center".
- Uso forte de azul profundo + azul vibrante + azul claro/ciano.
- Superficies com cantos bem arredondados:
  - hero: `28px`
  - paineis: `28px`
  - cards internos: `20px` a `24px`
  - pills/badges: formato capsula
- Mistura de:
  - gradientes diagonais
  - sombras suaves
  - bordas discretas
  - transparencia leve
  - blur de fundo em blocos de resumo

### Paleta predominante

- Primaria: azul vivo `#1E6BFF`
- Primaria suave: azul claro `#73C8FF`
- Hero gradient: `#0F1D3D -> #163D78 -> #1E6BFF`
- Fundo claro: `#F3F7FB`
- Fundo escuro: `#07111F`
- Sucesso: verde petroleo `#14917F`
- Warning: ocre `#B7791F`

### Componentes recorrentes

- Hero cards com gradiente forte e resumo em glassmorphism.
- Stat cards com icone em bloco colorido e tipografia de numero grande.
- Painel principal com fundo quase opaco, borda fina e sombra elegante.
- Chips informativos para PID, faccao, status e contagem.
- Botoes `FilledButton` para a acao principal e `OutlinedButton` para acoes auxiliares.
- Drawer com itens em formato de card, nao apenas lista simples.

### Comportamento responsivo

- O projeto quebra layout em pontos como `780`, `800`, `900` e `980px`.
- Em telas mais estreitas:
  - blocos que eram `Row` viram `Column`
  - cards se empilham
  - areas de resumo descem para baixo do hero
- Ou seja: ele continua desktop-first, mas ja tem uma adaptacao boa para larguras menores.

### Tema

- O app usa `Material 3`, mas com personalidade visual propria.
- Light mode:
  - fundo claro azulado
  - cards brancos
  - bordas frias e leves
- Dark mode:
  - fundo navy quase preto
  - cards azulados escuros
  - textos secundarios azul-acinzentados
- O tema nao depende so do `ThemeData`; muita identidade visual esta nos widgets e containers customizados.

### Sensacao de produto

- Painel operacional moderno.
- Visual limpo, mas nao generico.
- Mistura produtividade com um toque gamer/futurista.
- Boa hierarquia visual: hero -> resumo -> cards metricos -> painel funcional.

---

## DNA visual reutilizavel para futuros projetos

Se quiser reaproveitar este estilo em outros apps, a identidade-base e:

- dashboard desktop com sidebar premium fixa
- hero section grande com gradiente azul profundo
- cards brancos ou azul-escuros com bordas sutis
- cantos arredondados grandes e espacamento respirado
- chips de status e metricas com aparencia de produto SaaS moderno
- fundo com blobs desfocados e atmosfera tecnologica
- visual sofisticado, limpo, moderno e levemente gamer
- interface com alto senso de organizacao e foco em operacao

### Prompt base para UI

```text
Crie uma interface de dashboard moderna, bonita e premium, com foco desktop-first. 
Use uma sidebar fixa e elegante, hero section no topo com gradiente azul profundo, 
cards amplos com bordas suaves, sombras delicadas e cantos bem arredondados. 
O visual deve combinar clima de painel operacional com linguagem SaaS moderna e um 
leve toque gamer/futurista. Use fundo com acentos desfocados, chips de status, 
metricas bem destacadas, hierarquia visual clara e responsividade cuidadosa. 
Evite visual generico de admin template; prefira algo polido, atmosferico e autoral.
```

### Prompt base mais direcionado

```text
Quero um layout no estilo control center premium: sidebar escura em gradiente, 
conteudo principal claro ou navy conforme o tema, hero card com resumo rapido em 
glassmorphism, cards internos com radius entre 20px e 28px, azul vibrante como cor 
principal, ciano como apoio, verde-petroleo para sucesso e badges em formato capsula. 
A interface deve parecer moderna, elegante, funcional, tecnologica e pronta para 
automacoes/monitoramento.
```

---

## Observacoes finais

- A arquitetura esta boa para crescer por features.
- Se o projeto aumentar bastante, o proximo passo natural seria separar melhor infraestrutura e fontes de dados.
- Para reuso visual, o maior valor esta em replicar a combinacao de:
  - sidebar premium
  - hero gradient
  - painel com profundidade sutil
  - chips/status cards
  - atmosfera azul tecnologica com blur
