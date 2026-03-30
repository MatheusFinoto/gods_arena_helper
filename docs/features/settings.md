# Feature: Settings

## Status

Nao iniciado

## Objetivo

Criar a aba `Settings` como ponto central de configuracoes do helper.

A primeira versao da aba deve permitir que o usuario configure informacoes basicas do ambiente local e controle funcionalidades que serao expandidas nas proximas iteracoes.

## Problema que a feature resolve

Hoje o projeto nao possui uma area dedicada para configuracoes do usuario. Isso dificulta:

- definir onde o jogo esta instalado;
- controlar preferencias visuais da aplicacao;
- habilitar ou desabilitar comportamentos futuros que alterarao arquivos do jogo.

## Escopo da primeira entrega documentada

Nesta primeira etapa, a aba `Settings` deve prever os seguintes itens:

### 1. Campo para path do jogo

Deve existir um `TextField` para o usuario informar o caminho onde o jogo esta instalado no computador.

Objetivo:

- permitir localizar a pasta do jogo;
- preparar o sistema para futuras alteracoes em arquivos reais do game;
- evitar caminhos fixos no codigo.

Comportamento esperado:

- o usuario digita ou cola o caminho da pasta do jogo;
- esse valor deve ser tratado como configuracao local;
- futuramente esse caminho sera usado por funcionalidades que leem ou alteram arquivos do jogo.

Exemplo de uso:

- `C:\Games\GodsArena`

### 2. Switch de tema

Deve existir um `Switch` para controle de tema da aplicacao.

Objetivo:

- permitir alternancia visual da interface;
- preparar a base para configuracao de preferencia do usuario.

Comportamento esperado:

- o usuario ativa ou desativa o modo de tema;
- o valor deve ser persistido localmente em iteracao futura;
- o comportamento exato do tema sera refinado depois.

Observacao:

- nesta fase estamos apenas definindo a existencia da configuracao.

### 3. Switch de BetterSearch

Deve existir um `Switch` chamado `BetterSearch`.

Objetivo:

- controlar uma funcionalidade futura que alterara arquivos reais do jogo;
- permitir que o usuario escolha explicitamente se quer usar esse comportamento.

Descricao funcional:

- `BetterSearch` sera uma funcionalidade que altera arquivos do jogo para modificar a forma como o personagem se desloca quando o usuario clica em uma regiao do mapa.
- posteriormente sera fornecido um arquivo de exemplo para detalhar a implementacao tecnica.

Comportamento esperado:

- o usuario ativa ou desativa a funcionalidade pela aba `Settings`;
- antes de qualquer alteracao real em arquivos do jogo, o sistema deve saber qual e o path configurado do game;
- essa funcionalidade deve ser tratada com cuidado por impactar arquivos reais do usuario.

## Regras de negocio iniciais

1. A aba `Settings` deve centralizar configuracoes do helper.
2. O path do jogo e obrigatorio para qualquer feature que precise ler ou alterar arquivos do game.
3. `BetterSearch` nao deve executar nenhuma alteracao sem o path do jogo definido.
4. `BetterSearch` deve ser tratado como funcionalidade opt-in.
5. Alteracoes futuras em arquivos do jogo devem ser documentadas antes da implementacao.

## Impacto esperado no frontend

- Criar a tela/aba `Settings`.
- Adicionar componentes visuais para:
  - campo de texto do path do jogo;
  - switch de tema;
  - switch de `BetterSearch`.
- Preparar estado da pagina para leitura e escrita dessas configuracoes.

## Impacto esperado no backend

Nesta fase, nenhum comportamento novo precisa ser implementado.

No futuro, o backend/local service podera precisar:

- validar existencia do diretorio do jogo;
- localizar arquivos especificos do game;
- aplicar alteracoes controladas em arquivos;
- possivelmente criar backup antes de modificar conteudo.

## Riscos e cuidados

- Alterar arquivos reais do jogo exige cuidado extra.
- O usuario pode informar um path invalido.
- Pode haver diferencas entre instalacoes do jogo em maquinas diferentes.
- Antes de habilitar alteracoes reais, sera importante definir estrategia de backup e reversao.

## Sugestao de proximos passos

1. Implementar somente a tela `Settings` com os campos visuais.
2. Definir como as configuracoes serao persistidas localmente.
3. Validar o path informado pelo usuario.
4. Documentar a estrutura dos arquivos afetados pela feature `BetterSearch`.
5. Implementar a logica de alteracao apenas depois de receber o arquivo de exemplo.
