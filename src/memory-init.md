---
name: memory-init
description: Cria ou atualiza o memory.md com o contexto base do projeto — inclui bootstrap da estrutura .agents/memory, confirmação antes de executar e configuração de cache de comandos.
license: MIT
metadata:
  author: BrunoCastro
  version: "4.1.0"
---

## Referências normativas (LAZY LOAD)

Referências normativas resolvidas pelo target ativo (via `_shared/target-adapter.md`).

### Regras:

- NÃO carregar automaticamente
- Assumir como conhecidos
- Carregar apenas se necessário

Inclui:

- base-output
- base-preconditions
- base-degraded-mode
- model-policy

---

## Objetivo

Criar ou atualizar o arquivo `memory.md` apenas quando houver mudança estrutural no projeto.

Também é responsável por inicializar a estrutura `.agents/memory/` quando inexistente.

---

## Etapa 0 — Bootstrap de memória (CRÍTICO)

Verificar se o diretório `.agents/memory/` existe.

---

### Se NÃO existir:

Solicitar confirmação:

> O diretório `.agents/memory/` não existe. Deseja criar a estrutura base de memória do projeto?

---

### Se confirmado:

Criar:

- `.agents/memory/memory.md`
- `.agents/memory/session-memory.md`
- `.agents/memory/decisions.md`
- `.agents/memory/quality-metrics.md`

---

### Conteúdo inicial:

#### memory.md

Deve conter:

- Nome do projeto
- Descrição
- Stack principal
- Estrutura básica

---

### Adicionar obrigatoriamente:

## Sistema de comandos

- Diretório: resolvido pelo target ativo (via `_shared/target-adapter.md`)
- Status: Estável
- Frequência de mudança: Baixa

Regras:

- NÃO recarregar automaticamente
- NÃO reprocessar a cada execução
- Recarregar apenas se houver mudança explícita

---

#### session-memory.md

- Arquivo vazio ou com placeholder leve

---

#### decisions.md

# Decisões do Projeto

## Críticas
## Técnicas
## UI/UX
## Outras
## Recentes

---

#### quality-metrics.md

Conteúdo inicial mínimo:

# Métricas de Qualidade

- taxa_aprovacao:
- taxa_reprovacao:
- retrabalho_medio:
- observacoes:

---

### Após criação:

- Tipo de ação: Bootstrap de memória

---

### Se NÃO confirmado:

- BLOQUEAR execução

---

## Etapa 1 — Classificação da mudança

### Mudança estrutural (PERMITIDO)

- Alteração de stack
- Mudança de arquitetura
- Mudança de domínio
- Reorganização estrutural

---

### Mudança incremental (BLOQUEADO)

- Componentes
- Features
- Bugfix
- Refatoração
- Ajustes visuais

---

## Regra de bloqueio

Se mudança incremental:

- NÃO atualizar memory.md
- BLOQUEAR execução

---

## Etapa 2 — Validação de necessidade

Comparar estado atual com `memory.md`

Pergunta:

> memory.md ainda representa o projeto?

---

### Se SIM:

- NÃO atualizar
- BLOQUEAR

---

### Se NÃO:

- Prosseguir

---

## Etapa 3 — Geração do memory.md

Deve conter:

- Nome do projeto
- Descrição clara
- Stack
- Estrutura de pastas (alto nível)
- Diretrizes principais

---

## Regras obrigatórias

- NÃO incluir decisões
- NÃO incluir logs
- NÃO duplicar decisions.md
- 500–1500 tokens
- foco em identidade

---

## Boas práticas

- Executar apenas na inicialização
- NÃO usar para mudanças incrementais
- Manter memory.md estável

---

## Importante

- Define a base da memória
- Bootstrap ocorre uma única vez
- NÃO reprocessar comandos
- Priorizar eficiência do sistema
- Em caso de dúvida:
  → NÃO executar

---

## Formato obrigatório de saída

## Status

- Atualizado / Bloqueado

---

## Análise

- Tipo de ação:
  - Bootstrap
  - Atualização estrutural
  - Bloqueado
- Tipo de mudança: Estrutural / Incremental
- Justificativa

---

## Problemas

- Uso indevido
- Ambiguidades

Se não houver:
→ Nenhum

---

## Próximos passos

Se BOOTSTRAP:
- Executar /context

Se BLOQUEADO:
- Usar /memory-save

Se ATUALIZADO:
- Executar /context