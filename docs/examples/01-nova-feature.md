# Exemplo 01 — Nova feature com memória ativa

> Fluxo completo para implementar uma feature de complexidade média
> usando decisões persistentes e validação formal.

**Cenário:** adicionar modo escuro (dark mode) a um app web existente que já usa Tailwind CSS e tem memória Memflow ativa.

---

## Contexto inicial

O projeto já rodou `/memory-init` anteriormente. Existem arquivos em `.agents/memory/` com decisões sobre o design system (tokens, paleta de cores) e métricas registradas de sessões anteriores.

---

## Passo 1 — Carregar contexto

```text
/context
```

**Saída esperada (ultra-light):**

```
Contexto: OK
Memória: carregada
  - Decisões: 3 (incluindo "usar variáveis CSS para temas" com score 82)
Métricas: SIM — qualidade_alta (taxa_reprovação: 4%)
Skills: NÃO
Invariantes anti-compaction: OK
Modo: Normal
```

> O `/context` identificou decisão anterior com score alto: **"usar variáveis CSS para temas"**. Isso vai influenciar o `/workflow` no passo seguinte.

---

## Passo 2 — Definir estratégia

```text
/workflow

Quero implementar dark mode no app. Já temos Tailwind configurado
e a paleta de cores está definida no design system.
```

**Saída esperada:**

```
## Status
Decisão tomada

## Análise

### Classificação
- Complexidade: Média
- Impacto: Médio
- Risco: Baixo
- Clareza: Alta

### Decisões existentes aplicadas
- "usar variáveis CSS para temas" (score: 82) → REAPROVEITADO
  Implicação: implementar via CSS custom properties, não hardcode de classes

### Exploração
Não necessária — abordagem clara, decisão existente com score alto

### Estratégia
- Execução: Planejada (/plan obrigatório)
- Validação: /review + /review-code (mudança em múltiplos componentes)

### Skills
Não disponíveis no projeto

## Próximos passos
1. /plan — criar plano de implementação
2. /execute — após aprovação do plano
3. /memory-save — registrar decisões da sessão
4. /review
5. /review-code
```

---

## Passo 3 — Planejar implementação

```text
/plan
```

> O `/plan` perguntará se deseja salvar o plano antes de gerá-lo.

**Diálogo de salvamento:**

```
Deseja salvar o plano que será criado?

A) Sim, salvar o plano
B) Não, apenas mostrar no chat
```

Escolha **A**. O plano será salvo em `.agents/docs/plans/dark-mode.md`.

**Plano gerado (resumido):**

```
## Status
Plano criado

## Análise

### Escopo
Adicionar suporte a dark mode usando CSS custom properties
e a classe `dark` do Tailwind (strategy: class).

### Arquivos afetados
- tailwind.config.js — habilitar darkMode: 'class'
- src/styles/tokens.css — adicionar variáveis CSS para tema dark
- src/components/ThemeToggle.tsx — novo componente (botão)
- src/app/layout.tsx — integrar ThemeToggle no layout

### Sequência
[ ] 1. Configurar Tailwind para modo class
[ ] 2. Definir variáveis CSS do tema dark em tokens.css
[ ] 3. Criar componente ThemeToggle com persistência via localStorage
[ ] 4. Integrar no layout raiz
[ ] 5. Ajustar componentes críticos (navbar, cards) para respeitar dark:

### Riscos
- Flash of unstyled content (FOUC) no primeiro render
  Mitigação: script inline no <head> antes do React hidratar

### Modelo recomendado
- Nível: econômico
- Principal: GPT-4.1
- Alternativas: claude-haiku, gemini-flash

## Próximos passos
→ /execute (seguir plano salvo em .agents/docs/plans/dark-mode.md)
```

---

## Passo 4 — Implementar

```text
/execute
```

O `/execute` lê o plano, segue a sequência e atualiza os checkboxes conforme avança:

```
[x] 1. Configurar Tailwind para modo class
[x] 2. Definir variáveis CSS do tema dark em tokens.css
[-] 3. Criar componente ThemeToggle com persistência via localStorage
[ ] 4. Integrar no layout raiz
[ ] 5. Ajustar componentes críticos
```

Ao final, o `/execute` calcula o **score de relevância** da sessão:

```
Score da sessão: 74
→ Recomendado: /memory-save
```

---

## Passo 5 — Salvar decisões

```text
/memory-save
```

**Decisão registrada em `decisions.md`:**

```markdown
## Técnicas

### dark-mode-strategy (score: 78)
- Categoria: Técnica
- Impacto: Médio
- Decisão: Dark mode implementado via CSS custom properties +
  Tailwind darkMode: 'class'. Script inline no <head> previne FOUC.
- Contexto: app com Tailwind, design system com tokens existentes
- Data: 2026-05-28
```

**Métricas atualizadas em `quality-metrics.md`:**

```markdown
## Snapshot atual
- Execuções: 4
- Taxa aprovação: 100%
- Taxa reprovação: 0%
- Retrabalho médio: 0
- Tendência: melhorando
```

---

## Passo 6 — Validar

```text
/review
```

```
## Status
Aprovado

## Análise
- Aderência ao .agents: OK
- Arquitetura: OK — segue decisão "usar variáveis CSS para temas"
- Segurança: OK — sem exposição de dados sensíveis
- Fluxo do sistema: OK — /workflow → /plan → /execute seguidos

## Problemas
Nenhum

## Próximos passos
→ /review-code (mudança afeta múltiplos componentes, risco ≥ médio)
```

```text
/review-code
```

```
## Status
Aprovado

## Análise
- FOUC tratado corretamente com script inline
- localStorage com fallback para preferência do sistema (prefers-color-scheme)
- Sem side effects em outros componentes
- Cobertura de testes: ThemeToggle com RTL

## Problemas
Nenhum
```

---

## Resultado final

- Dark mode implementado e validado
- Decisão registrada para reaproveitamento futuro
- Próxima sessão que envolver temas encontrará score 78 em `decisions.md`

---

## Comandos usados neste fluxo

```text
/context → /workflow → /plan → /execute → /memory-save → /review → /review-code
```
