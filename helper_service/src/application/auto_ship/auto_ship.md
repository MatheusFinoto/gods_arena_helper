Fluxo simples do Auto ship

NOK: 1 - Verificar se esta em Athens ou Sparta:
OK: 1.1 - Sim? Clicar no search -> clicar no guild quest
NOK: 1.2 Não? Clicar no Portal para Athens/Sparta -> Iniciar processo novamente
NOK: 1.3 Verificar se esta nas coordenadas corretas(ainda não sei vou usar prints ou % match)[57, -94]

//! GUILD QUEST
NOK: 2 - Clicar no NPC Guild Quest
NOK: 2.1 - Verificar a Window na tela: All guild members...
NOK: 2.2 - Clicar em: Guild Quests
NOK: 2.3 - Verificar a Window na tela: Please choose a quest...
NOK: 2.4 - Clicar em: Delivery and Materials...
NOK: 2.5 - Clicar em: Ok
NOK: 2.6 - Verificar se pegou a quest no canto inferior direito
NOK: 2.7 - Clicar em: Search -> (new) Ship NPC 1
OLD: [
    NOK: 2.6 - Verificar a Window de Quest na tela
    NOK: 2.6.1 - Se nao tiver na tela: apertar Q
    NOK: 2.6.2 - Se tiver na tela: Fazer o scrool das quests até o final
    NOK: 2.7 - Clicar em: [50]News of war
    NOK: 2.8 - Clicar em: Retired Soldier
]

//! PRIMEIRO NPC
NOK: 3 - Verificar se esta na posiÇão correta do npc [82,14] podendo variar
NOK: 3.1 - Clicar no npc
NOK: 3.2 - Verificar Window: I have hunted..
NOK: 3.3 - Clicar em: [50]News of war (Done)
NOK: 3.4 - Clicar em: Finish
NOK: 3.5 - Clicar em: Accept
NOK: 3.6 - Verificar se pegou a quest no canto inferior direito
NOK: 3.7 - Clicar em: Search -> (new) Ship NPC 2

//! SEGUNDO NPC
NOK: 4 - Verificar se esta na posiÇão correta do npc [125,-70] podendo variar
NOK: 4.1 - Clicar no npc
NOK: 4.2 - Verificar Window:Hi warrior..
NOK: 4.3 - Clicar em: [50]Short on Supplies (Done)
NOK: 4.4 - Clicar em: Finish
NOK: 4.5 - Clicar em: Accept
NOK: 4.6 - Verificar se pegou a quest no canto inferior direito
NOK: 4.7 - Clicar em: NPC Transporter
NOK: 4.8 - Aguardar alguns segundos pra ele chegar, 0.2

//! TRANSPORTER NPC
NOK: 5 - Verificar window: I can send
NOK: 5.1 - Clicar em: Transmit
NOK: 5.2 - Clicar em: Marathon/Poloponeso
NOK: 5.3 - Clicar em: OK
NOK: 5.5 - Await 0.2
NOK: 5.6 - CLicar em: search -> (new) Ship NPC 3

//! TERCEIRO NPC 3
NOK: 6 - Esperar chegar nas coordenadas: 10 secs
NOK: 6.1 - Verificar se esta na posiÇão correta do npc [9,-26] podendo variar
NOK: 6.2 - Clicar no npc
NOK: 6.3 - Verificar window: I like charging..
NOK: 6.4 - Clicar em: [50]Running to Marathon (Done)
NOK: 6.5 - Clicar em: Finish
NOK: 6.6 - Clicar em: Accept

//! TRANSPORTER NPC
NOK: 7 - Verificar window: I can send
NOK: 7.1 - Clicar em: Transmit
NOK: 7.2 - Clicar em: Athens/Sparta
NOK: 7.3 - Clicar em: OK
NOK: 7.4 - Await 0.2
NOK: 7.5 - CLicar em: search -> (new) Ship NPC 1

//! PRIMEIRO NPC
NOK: 8 - Esperar chegar nas coordenadas: 10 secs
NOK: 8.1 - Verificar se esta na posiÇão correta do npc [81,14] podendo variar
NOK: 8.2 - Clicar no npc
NOK: 8.3 - Verificar Window: I have hunted..
NOK: 8.4 - Clicar em: [50]Supplies for the war (Done)
NOK: 8.5 - Verificar na bag qual precisa pegar
NOK: 8.6 - Clicar no item que precisa pegar


## Sugestao de estrutura de codigo

Ao inves de deixar toda a regra dentro de um unico arquivo grande com `step_1`, `step_2`, a ideia e separar:

- um arquivo para iniciar o AutoShip;
- um arquivo para orquestrar a ordem do fluxo;
- arquivos menores para cada passo principal;
- arquivos de apoio para validacoes e acoes visuais.

### Estrutura sugerida

```text
helper_service/src/application/
|- auto_ship_serivce.py
`- auto_ship/
   |- auto_ship.md
   |- runner.py
   |- context.py
   |- checks/
   |  |- city_check.py
   |  |- position_check.py
   |  |- quest_check.py
   |  `- dialog_check.py
   |- steps/
   |  |- ensure_home_city_step.py
   |  |- open_guild_quest_step.py
   |  |- first_npc_step.py
   |  |- second_npc_step.py
   |  |- travel_to_marathon_step.py
   |  |- third_npc_step.py
   |  |- return_home_step.py
   |  `- finish_first_npc_step.py
   `- actions/
      |- search_actions.py
      |- npc_actions.py
      |- transporter_actions.py
      |- dialog_actions.py
      `- bag_actions.py
```

## Como cada arquivo ficaria

### `auto_ship_serivce.py`

Ponto de entrada simples chamado pelo `main.py`.

Responsabilidade:
- receber `process_id`;
- chamar `run_auto_ship(process_id)`;
- devolver `True` ou `False`.

### `auto_ship/runner.py`

Arquivo principal do fluxo.

Exemplo de responsabilidade:

```python
def run_auto_ship(process_id: int) -> bool:
    if not ensure_home_city(process_id):
        return False
    if not open_guild_quest(process_id):
        return False
    if not complete_first_npc(process_id):
        return False
    return True
```

Esse arquivo deve ler como uma historia do fluxo.

### `auto_ship/context.py`

Opcional no inicio, mas bom para crescer depois.

Pode guardar:
- `process_id`;
- cidade atual;
- ultima posicao conhecida;
- ultima etapa executada;
- retries;
- dados temporarios da quest/item final.

### `auto_ship/checks/city_check.py`

Responsavel por verificacoes como:
- esta em Athens?;
- esta em Sparta?;
- precisa usar portal?;

### `auto_ship/checks/position_check.py`

Responsavel por:
- verificar se esta nas coordenadas esperadas;
- validar margem de erro;
- decidir entre print, OCR ou template match.

### `auto_ship/checks/quest_check.py`

Responsavel por:
- verificar se a quest foi aceita;
- verificar se a quest mudou;
- verificar se a quest de entrega apareceu no canto da tela.

### `auto_ship/checks/dialog_check.py`

Responsavel por:
- confirmar janelas como `All guild members...`;
- `Please choose a quest...`;
- `I have hunted...`;
- `Hi warrior...`;
- `I can send`;
- `I like charging...`.

### `auto_ship/steps/ensure_home_city_step.py`

Responsavel por:
- verificar Athens/Sparta;
- se nao estiver, usar portal;
- reiniciar o processo de validacao da cidade.

### `auto_ship/steps/open_guild_quest_step.py`

Responsavel por:
- clicar em `Search`;
- clicar em `Guild Quest`;
- abrir dialogos;
- escolher `Guild Quests`;
- escolher `Delivery and Materials`;
- confirmar `Ok`;
- validar se a quest foi recebida;
- buscar o NPC 1.

Esse deve ser o primeiro passo real a sair do fluxo simples atual.

### `auto_ship/steps/first_npc_step.py`

Responsavel por:
- validar posicao do NPC 1;
- clicar no NPC;
- validar janela;
- finalizar `[50]News of war (Done)`;
- clicar em `Finish`;
- clicar em `Accept`;
- validar nova quest;
- buscar NPC 2.

### `auto_ship/steps/second_npc_step.py`

Responsavel por:
- validar posicao do NPC 2;
- clicar no NPC;
- finalizar `[50]Short on Supplies (Done)`;
- clicar em `Finish`;
- clicar em `Accept`;
- validar nova quest;
- interagir com `NPC Transporter`.

### `auto_ship/steps/travel_to_marathon_step.py`

Responsavel por:
- validar janela `I can send`;
- clicar em `Transmit`;
- clicar em `Marathon/Poloponeso`;
- clicar em `OK`;
- aguardar;
- buscar NPC 3.

### `auto_ship/steps/third_npc_step.py`

Responsavel por:
- validar chegada;
- validar posicao do NPC 3;
- clicar no NPC;
- finalizar `[50]Running to Marathon (Done)`;
- clicar em `Finish`;
- clicar em `Accept`.

### `auto_ship/steps/return_home_step.py`

Responsavel por:
- usar transporter;
- clicar em `Athens/Sparta`;
- clicar em `OK`;
- aguardar;
- buscar NPC 1 novamente.

### `auto_ship/steps/finish_first_npc_step.py`

Responsavel por:
- validar chegada no NPC 1;
- clicar no NPC;
- finalizar `[50]Supplies for the war (Done)`;
- abrir/verificar bag;
- identificar item correto;
- clicar no item necessario.

### `auto_ship/actions/search_actions.py`

Responsavel por acoes pequenas ligadas ao search:
- clicar no label `Search`;
- clicar no alvo buscado;
- talvez limpar/confirmar buscas futuras.

### `auto_ship/actions/npc_actions.py`

Responsavel por:
- clicar em NPC;
- clicar em opcoes de dialogo de NPC;
- reaproveitar comportamento entre NPC 1, 2 e 3.

### `auto_ship/actions/transporter_actions.py`

Responsavel por:
- abrir dialogo do transporter;
- clicar em `Transmit`;
- escolher destino;
- confirmar `OK`.

### `auto_ship/actions/dialog_actions.py`

Responsavel por:
- clicar botoes como `Ok`, `Finish`, `Accept`;
- validar textos de janela;
- encapsular interacoes repetidas de dialogo.

### `auto_ship/actions/bag_actions.py`

Responsavel por:
- abrir bag;
- verificar qual item precisa pegar;
- clicar no item correto.

## Ordem recomendada de implementacao

Para crescer sem baguncar o codigo, eu seguiria nesta ordem:

1. mover o fluxo simples atual para `runner.py` e `steps/open_guild_quest_step.py`;
2. criar `actions/search_actions.py` e `actions/dialog_actions.py`;
3. criar `checks/dialog_check.py`;
4. implementar `first_npc_step.py`;
5. implementar `second_npc_step.py`;
6. implementar transporter e retorno;
7. implementar bag e item final.

## Regra importante

Evitar nomes como:

- `step_1.py`
- `step_2.py`
- `def step_3()`

Preferir nomes de dominio:

- `open_guild_quest`
- `complete_first_npc`
- `travel_to_marathon`
- `finish_first_npc`

Assim o codigo continua legivel mesmo se a ordem do fluxo mudar depois.
