# Model Policy — Orquestração de Modelos

Este arquivo define as regras de uso, seleção e escalada de modelos de IA no projeto.

Ele garante:

- redução de custo
- consistência de decisões
- qualidade técnica
- previsibilidade do sistema

---

## Objetivo

Padronizar como os modelos são utilizados em cada etapa do workflow:

- `/workflow`
- `/plan`
- `/execute`
- `/review`
- `/review-enforce-rules`

---

## Princípio fundamental

👉 Começar com o modelo mais econômico
👉 Escalar apenas quando necessário

---

## Papéis dos modelos

### Modelo econômico (ex: Codex)

Usar para:

- execução de código
- CRUD
- componentes UI
- ajustes simples
- correções pontuais

Características:

- rápido
- barato
- menor capacidade de raciocínio complexo

---

### Modelo intermediário (ex: GPT-5.4)

Usar para:

- planejamento (`/plan`)
- arquitetura
- integração de sistemas
- regras de negócio
- decisões técnicas

Características:

- melhor equilíbrio custo/qualidade
- principal modelo de raciocínio

---

### Modelo avançado (ex: Opus)

Usar apenas para:

- refatoração complexa
- debugging difícil
- análise de código grande
- problemas persistentes

Características:

- alto custo
- alta capacidade de raciocínio

---

## Estratégia padrão

### Separação obrigatória

- Planejamento → modelo mais inteligente
- Execução → modelo mais econômico

---

### Fluxo ideal

```
/workflow → decide
   ↓
/plan (modelo inteligente)
   ↓
/execute (modelo econômico)
```

---

## Regras de seleção

### Por complexidade

| Complexidade | Modelo                    |
| ------------ | ------------------------- |
| Baixa        | Econômico                 |
| Média        | Intermediário             |
| Alta         | Intermediário ou Avançado |

---

### Por tipo de tarefa

#### Econômico

- "crie função"
- "ajuste componente"
- "corrija bug simples"

#### Intermediário

- "crie sistema"
- "arquitetura"
- "integração backend"

#### Avançado

- "refatore projeto"
- "analise código inteiro"
- "debug complexo"

---

## Escalada automática

### Regra principal

Se houver falha:

1ª falha → tentar corrigir localmente
2ª falha → revisar abordagem (possível erro de plano)
3ª falha → escalar modelo

---

### Exemplo de escalada

```
Codex → GPT-5.4 → Opus
```

---

## Regras críticas

- NÃO usar modelo avançado por padrão
- NÃO usar modelo econômico para decisões complexas
- NÃO pular planejamento em tarefas médias/altas
- NÃO insistir em modelo que falhou repetidamente

---

## Integração com comandos

### `/workflow`

- decide modelo inicial

---

### `/plan`

- usar modelo intermediário ou superior

---

### `/execute`

- usar modelo econômico
- escalar se necessário

---

### `/review`

- validar se modelo foi adequado

---

### `/review-enforce-rules`

- bloquear uso incorreto de modelo

---

## Regras de consistência

- modelo deve ser coerente com complexidade
- decisões devem ser justificadas
- escalada deve ser progressiva

---

## Objetivo de performance

- reduzir custo em 50%–80%
- manter qualidade alta
- evitar retrabalho

---

## Anti-patterns (evitar)

- usar modelo avançado para tarefas simples
- executar sem planejamento em tarefas complexas
- ignorar falhas repetidas
- misturar responsabilidades (planejar + executar no mesmo nível)

---

## Resumo final

👉 Modelo NÃO é o cérebro
👉 Workflow é o cérebro
👉 Modelo é ferramenta

---

## Resultado esperado

- execução mais barata
- decisões mais inteligentes
- sistema previsível
- menor taxa de erro
