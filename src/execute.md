---
name: execute
description: Implementa código com base na decisão do /workflow respeitando `model-policy.md` do target ativo. Sem decisão explícita do /workflow, bloqueia e retorna para orquestração. Inclui integração com persistência inteligente e métricas de qualidade.
license: MIT
metadata:
  author: BrunoCastro
  version: "3.2.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Executar a implementação:

- respeitando a decisão do `/workflow`
- seguindo `model-policy.md`
- mantendo consistência com `.agents` e `docs`

Este comando NÃO decide estratégia, apenas executa.

---

## Uso de ferramentas MCP

### Serena MCP (PRIORIDADE)

- localizar pontos exatos de alteração
- editar código com precisão
- evitar duplicação
- entender dependências

Priorizar:

- find_symbol
- find_referencing_symbols
- replace_symbol_body
- insert_before_symbol / insert_after_symbol

Evitar:

- editar arquivos inteiros sem necessidade

---

## Validação de decisão (OBRIGATÓRIO)

### Existe decisão do `/workflow`?

- SIM → seguir decisão  
- NÃO → BLOQUEAR e retornar ao `/workflow`

---

## Sem decisão do `/workflow`

- Status: Parcial
- Motivo: decisão de estratégia ausente
- Ação obrigatória: executar `/workflow`
- NÃO classificar complexidade/impacto/risco dentro de `/execute`

E PARAR.

---

## Integração com `/workflow`

- EXECUTAR DIRETO → executar  
- PLANEJAR → bloquear  

---

## Uso de modelo

- seguir model-policy  
- execução → modelo econômico  
- escalar apenas se necessário  

---

## Escalada

1ª falha → corrigir  
2ª falha → revisar abordagem  
3ª falha → escalar modelo  

---

## Execução

- implementar código  
- ajustar arquivos  
- seguir padrões do projeto  

---

## Segurança

- respeitar `.agents`  
- evitar exposição de secrets  
- separar client/server corretamente  

Se `.agents` ausente:
- aplicar boas práticas  
- modo degradado  

---

## Testes

- detectar runtime  
- rodar testes relevantes  
- evitar regressão  

---

## Detecção de stack

Identificar:

- linguagem/runtime  
- gerenciador  
- comandos de lint/test  

---

## Qualidade obrigatória

Após implementar:

1. setup (se necessário)  
2. format  
3. lint/typecheck  
4. testes  

Se erro → corrigir automaticamente  

---

## Regras específicas

- NÃO sobrescrever sem análise  
- NÃO duplicar código  
- NÃO alterar múltiplos arquivos sem necessidade  

---

## Resiliência

- erro simples → corrigir  
- erro estrutural → revisar plano  
- erro recorrente → escalar  

---

# Persistência inteligente (AUTO MEMORY)

Após execução, avaliar relevância para memória.

---

## Avaliação de relevância

Verificar se houve:

- decisões técnicas  
- mudanças relevantes  
- padrões definidos  
- escolhas arquiteturais  
- contexto útil  

---

## Detecção de decisões

Detectar padrões:

- “vamos usar…”  
- “decidimos…”  
- “padronizar…”  
- “não usar mais…”  
- “a partir de agora…”  

---

## Score de relevância (0–100)

- Mudança de stack: +40  
- Decisão arquitetural: +30  
- Padrão global: +20  
- Impacto múltiplos arquivos: +10  
- Mudança local: +5  
- Ajuste trivial: 0  

---

## Interpretação

- 0–20 → Não salvar  
- 21–50 → Pode salvar  
- 51–80 → Recomendar  
- 81–100 → Recomendar fortemente  

---

## Resultado

Se score ≥ 51:

→ Executar `/memory-save`

Se score < 51:

→ Não necessário salvar  

---

# 🆕 Integração com métricas de qualidade (NOVO)

Se a execução for seguida de:

- `/review`
- `/review-code`

Então:

→ Priorizar execução do `/memory-save`

Objetivo:

- registrar qualidade da execução  
- alimentar histórico do sistema  
- permitir análise futura  

---

## Importante

- NÃO decidir estratégia  
- NÃO pular validações  
- NÃO finalizar com erro  
- NÃO executar sem entendimento  

---

# Formato obrigatório de saída

## Status

- Executado / Falhou / Parcial  

---

## Análise

- O que foi feito  
- Arquivos alterados  
- Uso de Serena  
- Uso de fallback  
- Aderência ao workflow  
- Modo: Normal / Degradado  

---

## Problemas

- Erros ou riscos  
- Impactos  

Se não houver:
→ Nenhum  

---

## Persistência sugerida

- Score de relevância: X/100  
- Conteúdo relevante: SIM / NÃO  
- Decisões detectadas: SIM / NÃO  
- Métricas de qualidade elegíveis: SIM / NÃO  
- Recomendação:
  - Executar `/memory-save`
  - Não necessário salvar  

---

## Bloqueios

- Plano necessário → PARAR  
- Conflito com `.agents` → PARAR  
- Falta de contexto → PARAR  

---

## Próximos passos

- `/review`  
- `/review-code` (se aplicável)  
- `/memory-save` (recomendado após validação)  
- `/review-enforce-rules` (opcional)  
- `/test-plan` (se aplicável)  