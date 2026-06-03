---
name: context
description: Primeiro comando do fluxo — carrega memória (decisões, estado e métricas), interpreta padrões e prepara contexto inteligente para o /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "8.3.1"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Regra de ativação do comando (CRÍTICO)

Quando o usuário invocar `/context`, este comando já está ativo.

- NÃO responder apenas que as referências normativas foram registradas
- NÃO solicitar que o usuário execute `/context` novamente
- NÃO bloquear por "pré-condições ainda não validadas"
- executar imediatamente o carregamento de contexto, memória, métricas, skills e invariantes anti-compaction descrito abaixo

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

# Re-hidratação de invariantes (ANTI-COMPACTION)

Antes de concluir o `/context`, revalidar explicitamente:

- idioma obrigatório do sistema: pt-BR
- identidade do projeto: Memflow Command System
- escopo ativo: comandos normativos em `src/` e bases em `_shared`

Se algum item estiver ausente no contexto ativo:

- recarregar referências normativas
- registrar que houve re-hidratação pós-compaction
- NÃO marcar contexto como completo sem revalidar os 3 itens

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
- skills do projeto (quando existirem)

---

# Skills do projeto (OBRIGATÓRIO quando disponíveis)

Verificar existência de skills no projeto (exemplos comuns):

- `.cursor/skills/**`
- `.cursor/skills-cursor/**`
- `.agents/skills/**`

Se existirem:

- carregar inventário de skills disponíveis
- registrar nomes e finalidade resumida de cada skill relevante
- sinalizar ao `/workflow` que existem skills potencialmente aplicáveis

Se não existirem:

- registrar ausência explicitamente (sem bloquear)

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
- NÃO ignorar skills disponíveis no projeto
- incluir status de skills no contexto entregue ao `/workflow`
- SEMPRE revalidar invariantes anti-compaction (pt-BR + Memflow) antes de finalizar

---

# Saída

---

## 🟢 Ultra-light

- Contexto: OK
- Memória: carregada
- Métricas: SIM/NÃO
- Qualidade: alta/media/baixa
- Sinais: nenhum / detectados
- Skills no projeto: SIM / NÃO
- Invariantes anti-compaction: OK / Reidratados

---

## Status

- Contexto: OK / Falhou
- Memória: SIM / NÃO
- Métricas: SIM / NÃO
- Skills: SIM / NÃO
- Invariantes anti-compaction: OK / Reidratados / Falhou
- Modo: Normal / Degradado / Otimizado

---

## Resumo

- uso da memória
- uso de métricas
- sinais detectados
- skills disponíveis (quando houver)
- status de invariantes anti-compaction (pt-BR + Memflow)

---

## Estado do fluxo

- Etapa: context

---

# Regras de consistência

- NÃO decidir execução
- NÃO aplicar métricas diretamente
- NÃO aplicar sinais diretamente
- NÃO decidir sozinho se skill deve ser usada
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