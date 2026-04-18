---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática de decisões, validação de relevância, score, versionamento e gerenciamento de dashboard de decisões.
license: MIT
metadata:
  author: BrunoCastro
  version: "7.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Salvar o estado atual da sessão e preservar decisões importantes sem poluir a memória.

Gerenciar automaticamente o arquivo `.agents/memory/decisions.md` como dashboard estruturado com histórico de decisões.

---

## Etapa 1 — Validação de relevância (OBRIGATÓRIA)

Antes de salvar, analisar:

### NÃO salvar se for:

- Logs técnicos
- Execuções triviais
- Repetições de informações
- Conteúdo temporário
- Ações sem impacto futuro

---

### SALVAR apenas se houver:

- Decisões importantes
- Mudanças relevantes
- Definições técnicas
- Contexto útil para continuidade futura

---

## Regra de bloqueio

Se NÃO houver informação relevante:

- NÃO atualizar arquivos
- BLOQUEAR execução

---

## Etapa 2 — Auto-detecção de decisões

Analisar a sessão e identificar automaticamente decisões.

### Indicadores de decisão

Detectar padrões como:

- “decidimos que…”
- “vamos usar…”
- “não vamos mais usar…”
- “a partir de agora…”
- “padronizar…”
- “definido que…”

---

## Etapa 3 — Score de relevância (0–100)

Calcular o score com base nos critérios:

- Mudança de stack: +40
- Decisão arquitetural: +30
- Definição de padrão global: +20
- Impacto em múltiplos arquivos: +10
- Mudança local relevante: +5
- Ajuste trivial: 0

Regras:

- Somar apenas critérios aplicáveis
- Limite máximo: 100
- Não duplicar critérios equivalentes

---

## Etapa 4 — Determinação de impacto

Definir impacto com base no score:

- 0–20 → baixo
- 21–50 → médio
- 51–100 → alto

---

## Etapa 5 — Classificação de categoria

Classificar automaticamente a decisão:

### Críticas
- stack
- arquitetura
- mudanças estruturais

### Técnicas
- padrões
- regras técnicas
- decisões de implementação

### UI/UX
- interface
- experiência
- navegação

### Outras
- fallback

---

## Etapa 6 — Estrutura do decisions.md (CRIAÇÃO AUTOMÁTICA)

Se `.agents/memory/decisions.md` NÃO existir:

Criar com a estrutura base:

# Decisões do Projeto

## Críticas

## Técnicas

## UI/UX

## Outras

## Recentes

---

## Etapa 7 — Versionamento de decisões (CRÍTICO)

Antes de adicionar uma nova decisão:

Verificar se já existe decisão equivalente.

### Se NÃO existir:
- adicionar normalmente

### Se EXISTIR e houver mudança:

- NÃO sobrescrever
- criar nova entrada com sufixo "(update)"

---

## Etapa 8 — Escrita das decisões

Adicionar na categoria correta:

## [YYYY-MM-DD] Título da decisão

- Decisão: descrição objetiva
- Motivo: justificativa
- Impacto: baixo | médio | alto
- Score: X/100

---

## Etapa 9 — Atualização de "Recentes"

Sempre adicionar também em:

## Recentes

Formato:

- [YYYY-MM-DD] Título da decisão

---

## Regras obrigatórias

- NÃO duplicar decisões idênticas
- NÃO sobrescrever decisões antigas
- Atualizações devem gerar nova entrada
- Garantir que toda decisão possua Score
- Garantir que toda decisão possua Impacto
- NÃO salvar informação irrelevante
- NÃO transformar session-memory em log
- Manter `.agents/memory/session-memory.md` entre 300–800 tokens
- Manter `.agents/memory/decisions.md` organizado por categoria

---

## Etapa 10 — Escrita final

Se validado:

- Atualizar `.agents/memory/session-memory.md`
- Criar ou atualizar `.agents/memory/decisions.md`

---

## Boas práticas

- Usar ao final de cada tarefa relevante
- Evitar uso em tarefas triviais
- Priorizar qualidade sobre quantidade

---

## Importante

- Este comando mantém continuidade do sistema
- `.agents/memory/decisions.md` é a fonte de verdade das decisões
- Decisões nunca devem ser sobrescritas
- Histórico deve ser preservado
- Score deve refletir importância real
- Impacto deve ser coerente com o score
- Em caso de dúvida:
  → NÃO salvar

---

## Formato obrigatório de saída

## Status

- Atualizado / Bloqueado

---

## Análise

- Conteúdo relevante identificado: SIM / NÃO
- Decisões detectadas: SIM / NÃO
- Score calculado: X/100
- Impacto: baixo | médio | alto
- Categoria atribuída: Críticas | Técnicas | UI/UX | Outras
- Tipo de ação:
  - Nova decisão
  - Atualização de decisão
  - Sessão
- Justificativa

---

## Problemas

- Informação irrelevante (se bloqueado)
- Ambiguidades
- Possível conflito com decisões existentes
- Limitações de detecção

Se não houver:
→ Nenhum

---

## Próximos passos

Se BLOQUEADO:

- Nenhuma ação necessária

Se ATUALIZADO:

- Contexto salvo com sucesso
- Dashboard de decisões atualizado