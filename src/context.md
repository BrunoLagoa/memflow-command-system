---
name: context
description: Primeiro comando do fluxo — carrega e valida .agents, memória persistente e MCPs. Utiliza memória como fonte primária, modo ultra-light automático, fallback inteligente, Serena otimizado e carregamento sob demanda. Próximo passo obrigatório: /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "6.0.0"
---

## Carregar contexto

---

## Memória persistente (ALTA PRIORIDADE)

Se existir:

- .agents/memory/memory.md
- .agents/memory/session-memory.md
- .agents/memory/decisions.md

---

## Uso da memória

Se memória estiver disponível:

- utilizar como fonte primária de contexto
- utilizar como histórico de decisões
- utilizar como estado atual do projeto

---

## Regra de confiança da memória (CRÍTICO)

Se existirem:

- .agents/memory/memory.md
- .agents/memory/decisions.md

→ considerar memória como confiável

---

## Modo otimizado

Se memória for confiável:

### NÃO fazer:

- NÃO varrer projeto completo
- NÃO carregar docs automaticamente
- NÃO ler código sem necessidade
- NÃO reprocessar diretório `/commands`

---

### FAZER:

- carregar apenas `.agents`
- carregar memória
- usar Serena de forma otimizada
- carregar arquivos apenas quando necessário

---

## Modo fallback (SEM memória)

Se memória NÃO existir:

- carregar docs/** (se existir)
- explorar código
- comportamento completo padrão

---

## Contexto principal (sempre carregar)

- .agents/**
- AGENTS.md (se existir)

---

## Contexto sob demanda

Carregar apenas se necessário:

- docs/**
- código
- configs grandes

---

## Referências normativas (LAZY LOAD)

Referências normativas resolvidas pelo target ativo (via `_shared/target-adapter.md`).

### Regras:

- NÃO carregar automaticamente
- Assumir como conhecidos
- NÃO reprocessar a cada execução
- Carregar apenas se necessário

Inclui:

- base-output
- base-preconditions
- base-degraded-mode
- model-policy

---

## Integração com MCP

### Serena MCP (OTIMIZADO)

Uso padrão:

- Carregar apenas:
  - project_overview

---

NÃO carregar automaticamente:

- code_style
- suggested_commands
- task_completion

---

### Carregamento sob demanda

Carregar somente quando necessário:

- code_style → ao gerar/modificar código
- suggested_commands → ao usar comandos
- task_completion → ao finalizar tarefas

---

### Regra de otimização

- evitar múltiplas memórias simultâneas
- priorizar menor contexto possível

---

### Context Mode MCP

- memória complementar

---

### Context7 MCP

- documentação externa sob demanda

---

## Prioridade de fontes

1. memory (fonte principal)
2. .agents
3. Serena MCP (project_overview)
4. model-policy (sob demanda)
5. docs (sob demanda)
6. código (sob demanda)

---

## Regras obrigatórias

- memória é fonte primária
- evitar leitura desnecessária
- não reprocessar comandos estáveis
- usar Serena apenas quando necessário
- sem `.agents` → modo degradado

---

## Modo de saída

### 🟢 Modo ultra-light (PRIORITÁRIO)

Ativar automaticamente quando:

- memória confiável
- nenhuma inconsistência detectada
- modo otimizado ativo

---

### Saída (ultra-light)

- Contexto: OK (carregamento mínimo suficiente)
- Próximo passo: executar `/workflow`

---

## Modo compacto (fallback padrão)

Usar quando ultra-light não for possível

---

## Status

- Contexto: OK / Falhou
- Memória: SIM / NÃO (confiável ou não)
- Modo: Normal / Degradado / Otimizado

---

## Resumo

- Estratégia de carregamento
- Uso da memória
- Próximo passo: /workflow

---

## Modo detalhado (fallback avançado)

Ativar quando:

- erro detectado
- conflito detectado
- memória inconsistente
- ausência de memória
- modo degradado
- solicitação explícita do usuário

---

## Estado do fluxo

- Etapa atual: context
- Próximo passo: /workflow

---

## Regras de consistência

- NÃO decidir execução
- NÃO escolher modelo
- SEMPRE delegar para /workflow

---

## Validação mínima

Informar (somente fora do ultra-light):

- Memória encontrada: SIM/NÃO
- Memória confiável: SIM/NÃO
- Docs carregados: SIM/NÃO
- Código carregado: SIM/NÃO
- Modo: Normal/Degradado/Otimizado

---

## Limitações

- sem Serena → avisar
- memória inconsistente → fallback

---

## Regras de bloqueio

- conflito crítico → fallback
- inconsistência grave → fallback

---

## Próximos passos

- Executar /workflow

---

## Importante

- NÃO implementar
- NÃO decidir fluxo
- NÃO carregar contexto desnecessário
- priorizar eficiência máxima