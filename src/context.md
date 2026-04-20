---
name: context
description: Primeiro comando do fluxo — carrega memória (decisões, estado e métricas), interpreta padrões e prepara contexto inteligente para o /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "8.1.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

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

# Uso da memória

## Fonte primária (CRÍTICO)

- memory.md → identidade
- decisions.md → decisões

---

## Fonte secundária

- quality-metrics.md → desempenho

---

## Regra de confiança

Se existirem:

- memory.md
- decisions.md

→ memória confiável

---

# 🧠 Interpretação de métricas

Se existir:

.agents/memory/quality-metrics.md

---

## Extrair:

- taxa_aprovacao
- taxa_reprovacao
- observações

---

## Classificação de qualidade

- qualidade_alta → erro < 10%
- qualidade_media → 10–30%
- qualidade_baixa → >30%

---

# 🆕 Interpretação de padrões (INSIGHTS 🔥)

Se existirem observações:

Exemplo:

- "tasks com baixa clareza falham mais"
- "integrações externas têm alto erro"

---

## Gerar sinais estratégicos

Converter observações em sinais:

### Tipos de sinal:

- risco_alto_por_clareza
- risco_alto_por_integracao
- necessidade_de_planejamento
- necessidade_de_validacao_reforcada

---

## Resultado interno

Preparar estrutura:

- qualidade: alta | media | baixa
- sinais:
  - lista de sinais detectados

---

## Regras

- NÃO decidir ação
- NÃO modificar fluxo
- NÃO bloquear execução
- apenas enriquecer contexto

---

# Modo otimizado

Se memória confiável:

---

## NÃO fazer:

- varrer projeto
- carregar docs
- ler código sem necessidade

---

## FAZER:

- carregar memória
- interpretar métricas
- interpretar sinais
- usar Serena otimizado

---

# Modo fallback

Se memória ausente:

- comportamento padrão

---

# Contexto principal

- .agents/**
- AGENTS.md

---

# Contexto sob demanda

- docs
- código
- configs

---

# Integração MCP

(mantido)

---

# Prioridade de fontes

1. memory.md  
2. decisions.md  
3. quality-metrics.md  
4. .agents  
5. Serena  
6. docs  
7. código  

---

# Regras obrigatórias

- memória é fonte primária
- métricas são suporte
- sinais NÃO substituem regras
- evitar leitura desnecessária

---

# Saída

---

## 🟢 Ultra-light

- Contexto: OK
- Memória: carregada
- Métricas: SIM/NÃO
- Qualidade: alta/media/baixa
- Sinais: nenhum / detectados

---

## Status

- Contexto: OK / Falhou
- Memória: SIM / NÃO
- Métricas: SIM / NÃO
- Modo: Normal / Degradado / Otimizado

---

## Resumo

- uso da memória
- uso de métricas
- sinais detectados

---

## Estado do fluxo

- Etapa: context

---

# Regras de consistência

- NÃO decidir execução
- NÃO aplicar métricas diretamente
- NÃO aplicar sinais diretamente
- SEMPRE delegar para /workflow

---

# Limitações

- observações podem ser incompletas
- sinais dependem da qualidade dos dados
- ausência de sinais não indica ausência de problema

---

# Importante

- NÃO implementar
- NÃO decidir fluxo
- sinais são apoio estratégico

---

## Próximos passos

- Executar /workflow