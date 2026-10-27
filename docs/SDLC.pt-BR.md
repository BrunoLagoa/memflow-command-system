# 🧠 SDLC Completo — Ciclo de Vida do Desenvolvimento de Software

<!-- README-I18N:START -->

[English](./SDLC.md) | **Português (Brasil)**

<!-- README-I18N:END -->

Este documento explica o que é SDLC (Software Development Life Cycle) e como ele se aplica ao sistema de desenvolvimento com IA.

---

# 🚀 O que é SDLC

**SDLC (Software Development Life Cycle)** é o processo completo de criação de software.

👉 Em português: **Ciclo de Vida do Desenvolvimento de Software**

---

# 🔄 SDLC Completo

Um SDLC completo cobre todas as etapas, do início até a evolução contínua:

```text
ideia → definição → planejamento → desenvolvimento → testes → validação → entrega → evolução
```

---

# 🏗️ Etapas do SDLC

## 0. 💡 Exploração (opcional)

* Comparar abordagens antes de fechar direção
* Esforço grande demais para uma sessão: modo mapa (`.agents/docs/maps/`)
* Trade-offs técnicos e de produto
* Validação de premissas no código existente
* Perguntas em rodadas por fronteira de decisões, cada uma com resposta recomendada
* Linguagem do domínio: glossário e ADRs em `.agents/domain/` (com confirmação)

👉 No sistema:

```
/brainstorm
```

Quando usar: clareza insuficiente, múltiplas abordagens plausíveis ou trade-offs não resolvidos.

Handoff típico: `/brainstorm` → `/prd`, `/spec` ou `/plan` (conforme gate).

---

## 1. 📌 Descoberta / Ideia

* Definição do problema
* Entendimento do contexto

👉 No sistema:

```
/prd
```

---

## 2. 🧩 Especificação

* Definição do comportamento esperado
* Regras e fluxos
* Seams de teste, decisões de teste e fora de escopo
* Modo síntese: a partir de `/brainstorm` aprovado, sem nova entrevista

👉 No sistema:

```
/spec
```

---

## 3. 🧠 Planejamento

* Estratégia de implementação
* Tarefas em fatias verticais com dependências explícitas (`Bloqueado por`)

👉 No sistema:

```
/plan
```

---

## 4. ⚙️ Desenvolvimento

* Implementação do código
* Próxima tarefa escolhida pela fronteira do plano; TDD opcional (red → green) nos seams acordados
* Bugs: `/debug` constrói feedback loop primeiro; a correção começa pelo teste de regressão

👉 No sistema:

```
/execute
```

---

## 5. 🧪 Testes

* Validação funcional
* Cobertura de cenários

👉 No sistema:

```
/test-plan
```

---

## 6. 🔍 Validação

* Verificação de aderência
* Qualidade técnica e arquitetural
* Review técnico em dois eixos (Padrões e Spec) com `/review-code`

👉 No sistema:

```
/review
```

---

## 7. 🚫 Gate de Qualidade

* Validação rígida adicional recomendada antes de considerar pronto

👉 No sistema:

```
/review-enforce-rules
```

---

## 8. 🔁 Manutenção e Evolução

* Correção de bugs
* Refatoração
* Aprendizado contínuo

👉 No sistema:

```
/debug
/refactor
/memory-save
/memory-init
/retro
```

`/retro` melhora o ambiente do agente (checagens, padrões, instruções) a partir do que aconteceu na sessão.

Em qualquer etapa, o `/workflow` define se a tarefa segue **com ou sem subagents** (padrão: sem).

---

# 🧠 SDLC no sistema de IA

O sistema implementa um SDLC completo com comandos:

```text
/context
/workflow
/brainstorm
/prd
/spec
/plan
/execute
/test-plan
/review
/review-enforce-rules
/debug
/refactor
/memory-save
/memory-init
/retro
```

---

# 🔥 Diferença do modelo tradicional

## ❌ Uso comum de IA

* geração de código isolado
* sem validação
* sem controle de fluxo

---

## ✅ Sistema com SDLC completo

* fluxo estruturado
* decisões controladas
* validação consistente (com gate rígido opcional)
* qualidade consistente

---

# 💡 Benefícios

* Maior previsibilidade
* Redução de erros
* Melhor qualidade de código
* Menor retrabalho
* Evolução contínua

---

# 🧠 Essência

> SDLC completo é transformar uma ideia em software funcional, validado e evolutivo.

---

# 🚀 Conclusão

Este sistema não apenas utiliza IA para gerar código.

Ele implementa um:

# 👉 Sistema completo de engenharia baseado em SDLC com IA
