
O auto race tem como objetivo fazer com oque a(s) contas selecionadas façam a missão diaria chada RACE, em resumo é o seguinte,
A conta deve
 1 - Pegar o manual na cidade suburb
 2 - Ir até o proximo npc, responder uma questão matematica de soma, e ir para o proximo npc
 3 - o passo 2 se repete 17 vezes até que seja finalizado

Toda a parte de automação vai ser feita no python

Agora mais resumido o processo que eu quero implementar
1 - Ir para cidade de suburb (Apertar M + Clicar no ponto especifico)

1.1 Pegar o Manual
 1.1.1 Clicar NPC (implementar alguma forma de clicar corretamente no npc, talvez quando o mouse mudar ao fazer o hover)
 1.1.2 Clicar Na opção: Round-the-city Race (Verificar imagem, move + click do mouse)
 1.1.3 Clicar Na opção: I want to join the race. (Verificar imagem, move + click do mouse)
 1.1.4 Click Botão OK
 1.1.5 Clicar Na opção: Start (Verificar imagem, move + click do mouse)
 1.1.6 Click Botão OK
 1.1.7 Verificar Imagem se pegou o Health Manual (Verificar imagem)

1.2 Ir para o NPC do Manual 1 (Apertar M + Clicar no ponto especifico, NPC 3)
 1.2.0 Aguardar o time até iniciar a ação
 1.2.1 Clicar NPC (implementar alguma forma de clicar corretamente no npc, talvez quando o mouse mudar ao fazer o hover)
 1.2.2 Clicar Na opção: Round-the-city Race (Verificar imagem, move + click do mouse)
 1.2.3 Clicar Na opção: Turn in a Health Manual. (Verificar imagem, move + click do mouse + Click Botão OK)
 1.2.4 Resolver calculo: (Verificar imagem, extrair primeiro numero, extrair segundo numero, input do resultado, Click Botão OK)
 1.2.5 Verificar Imagem se respondeu com sucesso (validar imagem, caso sucesso: proximo NPC, caso falha: Click botão ok, iniciar a partir da 1.2.1)

1.3 Quando o manual esta indo do 9 para o 10 ele precisa ir no npc 1 novamente, mas selecionar outras opções, como na 1.2
1.4 Os manuais vao do 1(quando o item é pego) e vai até o 17(quando termina em Sparta), ao final ele responde uma ultima vez, em suburb no npc 1, usando o step 1.2



## Especificação para implementação

Essa seção documenta a versão inicial do Auto Race para guiar a implementação futura.
O texto acima deve continuar sendo a base da regra de negócio, e os pontos abaixo detalham como vamos transformar o fluxo em código.

## Escopo da v1

A v1 do Auto Race vai ser uma automação feita no Python, usando somente validação de imagem.
Isso significa que o bot deve comparar prints da tela com imagens salvas em assets e tomar decisões com base nessas comparações.

Não vamos usar leitura textual por OCR para decidir opções de diálogo ou resultado da missão.
Mesmo o cálculo matemático deve ser resolvido por imagem, comparando os dígitos da pergunta com templates salvos.

O frontend vai ter uma página própria chamada AutoRace.
Nessa página o usuário poderá selecionar uma ou mais contas e iniciar a execução.
A execução inicial será em lote sequencial: o bot roda uma conta por vez, focando a janela daquela conta, concluindo ou falhando o fluxo, e depois passando para a próxima conta selecionada.

Cada conta selecionada deve permitir configurar qual é o manual atual antes de iniciar.
Isso serve para casos onde a conta tomou disconnect, fechou o jogo ou a automação foi interrompida.
Assim o usuário não precisa começar tudo do zero: ele seleciona o manual que a conta tem no momento e o Auto Race continua a partir daquele ponto.

## Fluxo principal esperado

1 - Focar a janela da conta selecionada.
2 - Ler o manual inicial configurado no frontend para essa conta.
3 - Ir para a cidade Suburb usando o mapa, apertando M e clicando no ponto configurado quando o fluxo precisar começar ou retomar por Suburb.
4 - Se o manual inicial for 0 ou "sem manual", pegar o Health Manual no NPC inicial:
 4.1 - Clicar no NPC.
 4.2 - Validar e clicar na opção Round-the-city Race.
 4.3 - Validar e clicar na opção I want to join the race.
 4.4 - Clicar no botão OK.
 4.5 - Validar e clicar na opção Start.
 4.6 - Clicar no botão OK.
 4.7 - Validar por imagem se o Health Manual foi recebido.

5 - Se o manual inicial for de 1 até 17, pular a etapa de pegar o manual e retomar diretamente a entrega daquele manual.

6 - Percorrer os manuais do manual atual até o 17:
 6.1 - Ir até o NPC correspondente ao manual atual usando o mapa.
 6.2 - Aguardar o tempo necessário até a conta chegar no NPC.
 6.3 - Clicar no NPC.
 6.4 - Validar e clicar na opção Round-the-city Race.
 6.5 - Validar e clicar na opção Turn in a Health Manual.
 6.6 - Clicar no botão OK quando necessário.
 6.7 - Resolver a pergunta matemática por comparação de imagem.
 6.8 - Digitar o resultado da soma.
 6.9 - Clicar no botão OK.
 6.10 - Validar por imagem se a resposta foi aceita.

7 - Caso a resposta matemática falhe:
 7.1 - Clicar no botão OK da mensagem de falha.
 7.2 - Repetir o fluxo do NPC atual a partir do clique no NPC.
 7.3 - Usar limite de tentativas para evitar loop infinito.

8 - Tratar o caso especial do manual 9 para o 10:
 8.1 - Voltar ao NPC 1.
 8.2 - Usar o mesmo padrão de validação por imagem.
 8.3 - Selecionar as opções específicas desse ponto do fluxo.

9 - Finalizar a corrida:
 9.1 - Após o manual 17, voltar para Suburb.
 9.2 - Interagir novamente com o NPC 1.
 9.3 - Entregar a última etapa usando o mesmo padrão do step 1.2.
 9.4 - Validar por imagem que a missão foi concluída.

## Retomada por manual atual

O AutoRace deve aceitar um valor de manual inicial por conta.
Esse valor representa o manual que a conta tem na bag ou a próxima entrega que ela precisa fazer.

Valores esperados:

- 0 ou "sem manual": iniciar do começo, ir para Suburb e pegar o Health Manual.
- 1 até 17: retomar a corrida a partir da entrega desse manual.

Exemplos:

- Se a conta ainda não começou a race, usar manual 0.
- Se a conta desconectou com o manual 6 na bag, selecionar manual 6 e iniciar.
- Se a conta falhou depois de entregar o manual 9 e precisa buscar o fluxo do 10, selecionar manual 10.

O runner Python deve receber esse valor junto com o process_id.
Com isso ele decide qual step executar primeiro.

Regra importante:

- O bot não deve tentar adivinhar automaticamente o manual atual na v1.
- A fonte da verdade será o valor escolhido pelo usuário no frontend.
- A automação ainda deve validar por imagem se a tela esperada apareceu em cada etapa.
- Se o usuário selecionar um manual errado, a etapa provavelmente vai falhar por ausência do template esperado, salvar debug e marcar erro na conta atual.

## Estrutura futura sugerida

A implementação deve ficar separada do AutoShip, em uma pasta própria:

```text
helper_service/src/application/
|- auto_race_service.py
`- auto_race/
   |- runner.py
   |- context.py
   |- steps/
   |  |- go_to_suburb_step.py
   |  |- pickup_manual_step.py
   |  |- go_to_manual_npc_step.py
   |  |- turn_in_manual_step.py
   |  |- solve_math_question_step.py
   |  `- finish_race_step.py
   |- actions/
   |  |- map_actions.py
   |  |- npc_actions.py
   |  |- dialog_actions.py
   |  |- input_actions.py
   |  `- debug_capture_actions.py
   `- vision/
      |- template_matcher.py
      |- race_checks.py
      |- math_question_reader.py
      `- capture_regions.py
```

O arquivo `auto_race_service.py` deve ser o ponto de entrada chamado pelo `main.py`.
O `runner.py` deve coordenar a história do fluxo do começo ao fim.
O `context.py` deve guardar informações da execução, como process_id, manual inicial escolhido, manual atual, tentativa atual, última etapa e configurações de timeout.

## Assets necessários

Os assets da feature devem ficar em:

```text
helper_service/src/assets/auto_race/
```

Tipos de imagens que vamos precisar:

- opções de diálogo:
  - Round-the-city Race;
  - I want to join the race;
  - Turn in a Health Manual;
  - Start.
- botões e ações:
  - OK;
  - mensagens de confirmação;
  - mensagens de falha.
- estados da missão:
  - Health Manual recebido;
  - entrega aceita;
  - resposta errada;
  - corrida concluída.
- matemática:
  - dígitos de 0 até 9;
  - sinal de soma;
  - região da pergunta matemática;
  - campo de input do resultado.
- navegação:
  - pontos do mapa para Suburb;
  - pontos do mapa para cada NPC;
  - imagens ou regiões de validação de chegada ao NPC.

## Captura assistida

Antes de implementar o fluxo completo, vamos criar ou usar um modo de captura assistida.
Esse modo deve ajudar a salvar recortes da tela do jogo para montar os templates.

O objetivo é evitar depender de imagens feitas manualmente sem padrão.
Cada captura deve registrar, quando possível:

- nome da etapa;
- process_id;
- região capturada;
- timestamp;
- imagem salva em PNG.

Exemplos de nomes úteis:

```text
round_the_city_race_option.png
i_want_to_join_race_option.png
turn_in_health_manual_option.png
ok_button.png
health_manual_received.png
math_digit_0.png
math_digit_1.png
math_plus_sign.png
math_question_region_sample.png
```

## Regras de validação e retry

Toda ação importante precisa ter uma validação por imagem antes ou depois do clique.

Regras recomendadas:

- se uma opção de diálogo não aparecer, tentar reabrir o NPC ou salvar debug e falhar a etapa;
- se o Health Manual não for detectado depois de pegar a missão, falhar a conta atual;
- se a resposta matemática for recusada, clicar OK e repetir o NPC atual;
- se uma mesma etapa falhar muitas vezes, parar a conta atual e marcar erro no frontend;
- sempre salvar screenshot ou recorte de debug quando um template esperado não for encontrado.

## Integração com frontend

A página AutoRace deve seguir o padrão atual do dashboard.
Ela deve permitir selecionar várias contas, iniciar a execução e acompanhar o status por conta.

Estados mínimos por conta:

- aguardando;
- executando;
- concluída;
- falhou;
- interrompida.

Informações úteis para mostrar:

- PID;
- nick da conta;
- manual atual detectado pela execução;
- manual inicial escolhido pelo usuário;
- etapa atual;
- mensagem de status;
- erro, quando houver.

Controles necessários por conta selecionada:

- seletor de manual inicial com opções "Sem manual / Começar do zero" e manuais 1 até 17;
- valor padrão em "Sem manual / Começar do zero";
- possibilidade de alterar o manual inicial antes de iniciar;
- bloqueio da alteração enquanto a execução estiver rodando para aquela conta;
- exibição do manual atual conforme o backend avança.

Na v1, mesmo com várias contas selecionadas, a execução deve ser sequencial para evitar conflito de foco da janela, mouse e captura de tela.
