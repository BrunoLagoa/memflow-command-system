---
name: context
description: Primeiro comando do fluxo — carrega e valida .agents, memória persistente (decisões e métricas) e MCPs. Utiliza memória como fonte primária e prepara contexto para decisões inteligentes no /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "7.0.0"
---

## Carregar contexto

---

# Memória persistente (ALTA PRIORIDADE)

Se existir:

- .agents/memory/memory.md
- .agents/memory/session-memory.md
- .agents/memory/decisions.md
- .agents/memory/quality-metrics.md

---

## Uso da memória

Se memória estiver disponível:

### Fonte primária (CRÍTICO)

- memory.md → identidade do projeto
- decisions.md → decisões estratégicas

---

### Fonte secundária (NOVO)

- quality-metrics.md → desempenho do sistema

Uso:

- NÃO definir contexto base
- NÃO substituir decisões
- NÃO alterar comportamento diretamente
- apenas enriquecer interpretação

---

## Regra de confiança da memória (CRÍTICO)

Se existirem:

- memory.md
- decisions.md

→ memória considerada confiável

---

### Observação importante

- quality-metrics.md NÃO define confiabilidade
- atua apenas como camada analítica

---

# 🆕 Interpretação de métricas (PREPARAÇÃO PARA WORKFLOW)

Se existir:

.agents/memory/quality-metrics.md

---

## Extrair informações:

- taxa_aprovacao
- taxa_reprovacao
- padrões em "Observações"

---

## Classificação de qualidade (derivada)

- qualidade_alta → baixa taxa de erro (<10%)
- qualidade_media → erro moderado (10–30%)
- qualidade_baixa → alta taxa de erro (>30%)

---

## Resultado gerado (interno)

Preparar sinal para o `/workflow`:

- qualidade_alta
- qualidade_media
- qualidade_baixa

---

## Regras

- NÃO decidir execução
- NÃO alterar fluxo
- NÃO bloquear ações
- apenas preparar contexto

---

# Modo otimizado

Se memória confiável:

---

## NÃO fazer:

- NÃO varrer projeto completo
- NÃO carregar docs automaticamente
- NÃO ler código sem necessidade
- NÃO reprocessar `/commands`

---

## FAZER:

- carregar `.agents`
- carregar memória
- considerar métricas como contexto adicional
- usar Serena de forma otimizada

---

# Modo fallback (SEM memória)

Se memória NÃO existir:

- carregar docs/**
- explorar código
- comportamento padrão

---

# Contexto principal (sempre carregar)

- .agents/**
- AGENTS.md (se existir)

---

# Contexto sob demanda

Carregar apenas se necessário:

- docs/**
- código
- configs grandes

---

# Referências normativas (LAZY LOAD)

Referências resolvidas via `_shared/target-adapter.md`

---

## Regras:

- NÃO carregar automaticamente
- assumir como conhecidas
- carregar apenas quando necessário

---

# Integração com MCP

### Serena MCP (OTIMIZADO)

Carregar:

- project_overview

---

### NÃO carregar automaticamente:

- code_style
- suggested_commands
- task_completion

---

### Carregamento sob demanda:

- code_style → ao gerar código
- suggested_commands → ao executar comandos
- task_completion → ao finalizar tarefas

---

## Regra de otimização

- evitar múltiplas memórias
- priorizar menor contexto possível

---

## Outros MCPs

- Context Mode → memória complementar
- Context7 → documentação externa sob demanda

---

# Prioridade de fontes

1. memory.md  
2. decisions.md  
3. quality-metrics.md  
4. .agents  
5. Serena MCP  
6. model-policy  
7. docs  
8. código  

---

# Regras obrigatórias

- memória é fonte primária
- métricas são suporte
- evitar leitura desnecessária
- não reprocessar comandos
- sem `.agents` → modo degradado

---

# Modo de saída

---

## 🟢 Modo ultra-light (PRIORITÁRIO)

Ativar quando:

- memória confiável
- nenhuma inconsistência detectada

---

### Saída (ultra-light)

- Contexto: OK
- Memória: carregada
- Métricas: disponíveis / não disponíveis

---

## Status

- Contexto: OK / Falhou
- Memória: SIM / NÃO
- Métricas: SIM / NÃO
- Modo: Normal / Degradado / Otimizado

---

## Resumo

- Estratégia de carregamento
- Uso da memória
- Uso de métricas

---

## Estado do fluxo

- Etapa atual: context

---

# Regras de consistência

- NÃO decidir execução
- NÃO escolher modelo
- NÃO aplicar métricas diretamente
- SEMPRE delegar para /workflow

---

# Validação mínima

(usar apenas fora do ultra-light)

- Memória encontrada: SIM/NÃO
- Métricas encontradas: SIM/NÃO
- Modo: Normal/Degradado/Otimizado

---

# Limitações

- métricas podem ser incompletas
- ausência de métricas não impacta execução
- dados históricos podem não refletir contexto atual

---

# Importante

- NÃO implementar
- NÃO decidir fluxo
- NÃO carregar contexto desnecessário
- métricas são suporte, não decisão

---

# Próximos passos

- Executar /workflow