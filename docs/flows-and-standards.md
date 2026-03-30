# Fluxos e Padroes do Projeto

Este documento registra, de forma simples, como o projeto esta organizado hoje e quais padroes devemos seguir nas proximas entregas.

## 1. Estrutura atual do projeto

O projeto esta dividido em duas partes principais:

- `helper_frontend`: aplicacao Flutter responsavel pela interface.
- `helper_service`: servico Python responsavel por leitura de janelas do jogo, OCR e interacoes locais com o sistema.

## 2. Fluxo atual da aplicacao

Fluxo principal ja existente:

1. O frontend abre o dashboard.
2. A tela inicial solicita a lista de contas.
3. O frontend executa o servico Python.
4. O backend localiza janelas do jogo.
5. O backend captura regioes da tela e tenta identificar nick e faccao.
6. O backend devolve os dados em JSON.
7. O frontend apresenta as contas encontradas e permite focar a janela correta.

## 3. Fluxo padrao para novas features

Toda nova feature deve seguir este fluxo:

1. documentacao inicial em `docs/features`;
2. definicao de regras de negocio;
3. definicao do impacto em frontend;
4. definicao do impacto em backend, se houver;
5. implementacao;
6. validacao manual e, quando fizer sentido, teste automatizado.

## 4. Padroes combinados

### Documentacao

- Toda feature nova deve ser documentada antes da implementacao.
- A documentacao deve ser simples, objetiva e facil de manter.
- Regras de negocio devem ficar explicitas.

### Frontend

- O frontend sera a camada de configuracao e interacao do usuario.
- Telas novas devem respeitar a navegacao existente do dashboard.
- Estados e acoes devem ficar organizados por pagina/feature.

### Backend

- O backend local deve concentrar qualquer leitura, automacao ou alteracao de arquivos do jogo.
- Sempre que houver alteracao em arquivo real do jogo, isso deve estar documentado antes da implementacao.
- Funcoes com risco de alterar o ambiente do usuario devem ter comportamento claro e reversivel quando possivel.

### Configuracoes do usuario

- Configuracoes devem ficar centralizadas na aba `Settings`.
- O projeto deve evoluir para armazenar preferencias persistentes do usuario.
- Caminhos locais, temas e toggles de comportamento devem ser tratados como configuracoes.

## 5. Direcao inicial do projeto

As proximas entregas devem priorizar:

1. consolidacao da aba `Settings`;
2. persistencia de configuracoes locais;
3. preparacao segura para futuras alteracoes em arquivos do jogo;
4. melhoria da portabilidade e organizacao do projeto.
