---
name: workflow
description: Comando central do sistema — classifica a tarefa e decide execução, considerando decisões, score e possíveis conflitos na memória do projeto.
license: MIT
metadata:
  author: BrunoCastro
  version: "4.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Decidir automaticamente:

1. Fluxo de execução:
   - `/execute`
   - `/plan`

2. Modelo ideal

3. Estratégia de execução

4. Respeitar decisões já tomadas (memória)

5. Priorizar decisões com base em score

6. Detectar conflitos antes de decidir

---

## Base de decisão

Utilizar obrigatoriamente:

- `.agents`
- `docs`
- `.agents/memory/decisions.md`
- `model-policy.md` resolvido pelo target ativo (via `_shared/target-adapter.md`)

---

## Etapa 0 — Verificação de decisões existentes (CRÍTICO)

Antes de qualquer classificação:

- Verificar `.agents/memory/decisions.md` (se existir)

Pergunta obrigatória:

> Já existe decisão registrada sobre este assunto?

---

### Se SIM:

#### Regra de versionamento

Se houver múltiplas decisões sobre o mesmo tema:

- priorizar a versão mais recente (pela data)
- priorizar entradas com "(update)"
- ignorar versões antigas

---

#### Leitura de score

Identificar o score da decisão mais recente.

---

#### Regra de prioridade por score

- Score 81–100:
  - decisão crítica
  - NÃO permitir redefinição

- Score 51–80:
  - decisão relevante
  - evitar redefinição, salvo forte justificativa

- Score 21–50:
  - decisão fraca
  - pode ser ajustada

- Score 0–20:
  - decisão irrelevante
  - pode ser ignorada

---

#### Detecção de conflito

Verificar se existem decisões incompatíveis sobre o mesmo tema.

Exemplos:

- múltiplas tecnologias conflitantes
- definições divergentes de arquitetura
- escolhas exclusivas entre si

---

### Se conflito detectado:

- NÃO decidir automaticamente
- sinalizar inconsistência
- recomendar revisão

---

### Ação (sem conflito)

- reutilizar decisão mais recente conforme score
- NÃO redefinir sem necessidade

---

### Se NÃO existir decisão:

- seguir fluxo normal

---

## Priorização de skills

(sem alteração)

---

## Classificação da tarefa

(sem alteração)

---

## Decisão de fluxo

(sem alteração)

---

## Orquestração de modelo

(sem alteração)

---

## Controle de fluxo

(sem alteração)

---

## Integração com sistema

- `/execute` deve respeitar esta decisão
- `/plan` deve ser seguido quando necessário

---

## Regras de consistência

- NÃO redefinir decisões fortes (score alto)
- SEMPRE verificar memória antes de decidir
- SEMPRE utilizar a decisão mais recente
- NÃO ignorar conflitos detectados

---

## Regras

- NÃO implementar
- NÃO pular análise
- NÃO ignorar decisões existentes
- NÃO ignorar score
- NÃO ignorar conflitos

---

## Importante

- Este comando é stateful
- Deve respeitar memória do projeto
- Evita decisões duplicadas
- Usa score para priorização
- Detecta conflitos antes de decidir

---

## Formato obrigatório de saída

## Status

- Decisão tomada
- Bloqueado por conflito (se aplicável)

---

## Análise

### Classificação

- Complexidade:
- Impacto:
- Risco:
- Clareza:

---

### Memória

- Decisão existente detectada: SIM / NÃO
- Score da decisão: X/100
- Tipo de decisão:
  - Atual
  - Atualizada (update)
- Conflito detectado: SIM / NÃO
- Ação tomada:
  - Reutilizada
  - Ajustada
  - Nova decisão
  - Bloqueada

---

### Avaliação geral

- Interpretação da tarefa
- Justificativa da decisão
- Uso do score
- Consideração de conflitos
- Modo de operação

---

## Problemas

- Ambiguidades
- Riscos
- Conflitos detectados
- Falta de contexto

Se não houver:
→ Nenhum

---

## Modelo recomendado

- Nível:
- Modelo principal:
- Justificativa

### Modelos alternativos (mesmo nível)

- ...

### Regra de fallback

- Se o modelo principal não estiver disponível, usar a primeira alternativa disponível do mesmo nível.
- Se nenhuma alternativa do mesmo nível estiver disponível, escalar de nível apenas quando risco/complexidade justificarem.
- Ordem de tentativa recomendada: principal → alternativa 1 → alternativa 2.

---

## Estratégia de execução

- Direta / Planejada
- Necessidade de escalada
- Risco de falha

---

## Próximos passos

Se conflito:

- Revisar decisões no `.agents/memory/decisions.md`

Se EXECUTAR DIRETO:

- Executar `/execute`

Se PLANEJAR PRIMEIRO:

- Executar `/plan`