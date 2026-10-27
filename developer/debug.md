---
name: debug
description: Diagnóstico estruturado de bugs com feedback loop primeiro — constrói um comando que reproduz o bug (red), minimiza o cenário, gera 3 a 5 hipóteses falsificáveis ranqueadas e instrumenta com logs marcados. Classifica o erro (Simples/Estrutural/Crítico) e indica a causa mais provável com evidência. Não corrige. Integrado ao workflow e ao `model-policy.md` do target ativo (via `_shared/target-adapter.md`). Saída: Status, Análise, Problemas e Próximos passos. Próximo passo: /execute, /refactor ou /plan conforme classificação.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.2.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Analisar profundamente um erro, bug ou comportamento inesperado:

- construir um feedback loop que reproduza o bug
- identificar causa raiz
- priorizar hipóteses falsificáveis
- orientar investigação
- preparar base para correção segura

---

## Integração com sistema

Este comando:

- NÃO executa correções
- NÃO substitui `/execute`
- NÃO decide fluxo

Ele prepara para:

→ `/execute` (correção, com teste de regressão antes do fix — ver *Correção de bug* no `/execute`)
→ `/refactor` (melhoria estrutural)
→ `/plan` (quando necessário)

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou avançado
- priorizar qualidade de diagnóstico

---

## Regras

1. Basear análise em:
   - `.agents`
   - `docs`
   - comportamento esperado do sistema
   - vocabulário de `.agents/domain/GLOSSARY.md` e ADRs da área (quando existirem)

2. NÃO implementar correções
   - scripts, testes ou harness de **reprodução** e logs temporários de instrumentação NÃO são correção e são permitidos
   - toda alteração de código de produção para corrigir o bug fica para `/execute`

3. NÃO teorizar antes de existir feedback loop (Fase 1)

4. Após hipóteses:
   - ranquear e indicar **uma única causa mais provável** (a primeira do ranking)

---

## Mascarar segredos (OBRIGATÓRIO)

- Ao mostrar comandos, saídas e artefatos capturados, substituir todo segredo por `<REDACTED>`.
- Construir loops usando variáveis de ambiente, para que credenciais fiquem no ambiente e não na saída.
- Citar apenas as linhas de artefatos (logs, HAR, headers) que carregam o sinal.

---

## Fase 1 — Feedback loop (OBRIGATÓRIO)

**Esta é a fase principal.** Com um sinal pass/fail que fica vermelho **neste** bug, a causa será encontrada; sem ele, ler código não resolve.

Formas de construir, em ordem aproximada de preferência:

1. teste que falha no seam que alcança o bug (unitário, integração, e2e)
2. script curl/HTTP contra servidor de desenvolvimento
3. invocação de CLI com fixture, comparando a saída com snapshot conhecido
4. script de browser headless (Playwright/Puppeteer) com asserção em DOM/console/rede
5. replay de trace capturado (request, payload, log de eventos)
6. harness descartável com subconjunto mínimo do sistema
7. loop de propriedade/fuzz para "às vezes sai errado"
8. harness de bisseção (`git bisect run`) quando o bug surgiu entre dois estados conhecidos
9. loop diferencial: mesma entrada em versão antiga vs nova
10. script HITL estruturado (último recurso, quando só um humano pode acionar)

Apertar o loop: mais rápido, sinal mais preciso (assertar o sintoma exato), mais determinístico (fixar tempo, seed, rede). Para bugs não determinísticos, o objetivo é **aumentar a taxa de reprodução** até ser depurável.

### Critério de conclusão da Fase 1

Nomear **um comando** já executado pelo menos uma vez (mostrar invocação e saída, mascaradas) que seja:

- [ ] **capaz de ficar vermelho:** exercita o caminho real do bug e asserta o **sintoma exato** relatado
- [ ] **determinístico:** mesmo veredito a cada execução (ou taxa de reprodução fixada e alta)
- [ ] **rápido:** segundos, não minutos
- [ ] **executável pelo agente:** sem humano no loop (exceto HITL estruturado)

### Quando não for possível construir um loop

- PARAR e declarar explicitamente
- listar o que foi tentado
- pedir ao usuário: acesso ao ambiente que reproduz, artefato capturado (mascarado) ou permissão para instrumentação temporária
- status: `Aguardando dados`
- NÃO avançar para hipóteses sem loop

---

## Fase 2 — Reproduzir e minimizar

- Confirmar que o loop produz o modo de falha **descrito pelo usuário** (bug errado = correção errada)
- Confirmar reprodutibilidade em múltiplas execuções
- Capturar o sintoma exato (mensagem, saída errada, tempo)
- Minimizar: cortar entradas, chamadores, config, dados e passos **um por vez**, reexecutando o loop a cada corte
- Concluído quando **todo elemento restante é necessário** (remover qualquer um deixa o loop verde)

---

## Fase 3 — Hipóteses

- Gerar **3 a 5 hipóteses ranqueadas** antes de testar qualquer uma
- Cada hipótese deve ser **falsificável**:
  - formato: "Se <X> for a causa, então <mudar Y> fará o bug sumir / <mudar Z> o fará piorar"
  - hipótese sem predição é palpite: descartar ou afiar
- **Mostrar o ranking ao usuário antes de testar** (ele pode reordenar com conhecimento de domínio); não bloquear se o usuário estiver ausente

---

## Fase 4 — Instrumentar

- Cada sonda mapeia para uma predição da Fase 3; **mudar uma variável por vez**
- Preferência: debugger/REPL → logs pontuais nas fronteiras que distinguem hipóteses → nunca "logar tudo e filtrar"
- **Marcar todo log de debug** com prefixo único (ex.: `[DEBUG-a4f2]`) para limpeza por busca
- Regressão de performance: medir baseline (timing, profiler, query plan) e bissectar; medir antes de corrigir

---

## Classificação do erro

Classificar o erro como:

- **Simples**
  - erro isolado
  - baixo impacto

- **Estrutural**
  - envolve arquitetura
  - múltiplos pontos
  - inclui ausência de seam correto para teste de regressão

- **Crítico**
  - segurança
  - dados
  - fluxo do sistema

---

## Importante

- NÃO corrigir ainda
- NÃO pular investigação
- NÃO pular o feedback loop
- NÃO listar múltiplas causas sem ranquear
- Sempre indicar causa mais provável
- Remover instrumentação `[DEBUG-...]` antes de encerrar, ou registrar em **Próximos passos** que ela deve ser removida no `/execute`

---

## Orquestração com subagents

Aplicar `_shared/base-subagents.md`. Somente quando a decisão do `/workflow` for `Orquestração: Com subagents`:

- **Levantamento de fatos:** subagents somente leitura podem localizar o caminho de código do sintoma, histórico de commits da área (`git log`) e reproduções semelhantes, em paralelo
- a construção do feedback loop, as hipóteses e as sondas continuam no contexto principal
- sondas **não** rodam em paralelo: mudar uma variável por vez continua obrigatório

Sem subagents → executar tudo no contexto principal.

---

## Formato obrigatório de saída

## Status

- Diagnóstico preliminar / Aguardando dados / Pronto para correção

---

## Análise

### Problema

- Descrição clara do erro

---

### Comportamento esperado

- Baseado em docs ou regras

---

### Feedback loop

- Comando de reprodução (mascarado)
- Saída observada (vermelho) e checklist da Fase 1
- Cenário minimizado

---

### Classificação do erro

- Simples / Estrutural / Crítico

---

### Hipóteses ranqueadas

- 3 a 5 hipóteses, cada uma com a predição que a confirma ou refuta
- Resultado de cada sonda executada

---

### Causa mais provável

- Apenas UMA (primeira do ranking após as sondas)
- Justificar com evidências
- Grau de confiança: baixa / média / alta
- O que confirmaria ou refutaria

---

### Análise técnica

- Onde está o problema:
  - módulos
  - fluxo
  - lógica

---

### Impacto

- O que pode quebrar

---

### Seam para teste de regressão

- Seam correto disponível: SIM / NÃO
- Se NÃO: registrar como achado de arquitetura

---

### Plano de investigação

- Passos restantes para validar
- Começar pela causa mais provável

---

## Problemas

- Dados insuficientes
- Incertezas
- Riscos de correção errada

Se não houver:
→ Nenhum

---

## Próximos passos

- Solicitar logs / acesso / artefato (se não houver loop)
- Validar hipótese principal
- Após confirmação:
  → `/execute` (erro simples) — teste de regressão antes do fix e checklist de limpeza
  → `/refactor` (erro estrutural)
  → `/plan` (erro complexo)
