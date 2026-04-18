---
name: brainstorm
description: Brainstorming estruturado antes de qualquer implementação — explora o problema, gera 2 a 5 abordagens alternativas com prós/contras, riscos e recomendação. Saída: seções Status, Análise, Problemas e Próximos passos. Pré-requisito: /context. Próximo passo: /plan. Não implementa nada.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Uso de ferramentas MCP

Se disponível:

### Serena MCP

- Utilize para:
  - entender a estrutura real do código
  - identificar padrões existentes
  - localizar implementações similares
  - validar suposições sobre arquitetura
- Priorizar:
  - find_symbol
  - find_referencing_symbols
  - search_for_pattern
- Evitar:
  - assumir estrutura sem validação
  - basear decisões apenas em nomes de arquivos

---

## Objetivo

Explorar múltiplas abordagens possíveis antes de definir uma solução.

---

## Regras

1. Baseie-se em:
  - `.agents` (restrições técnicas)
  - `docs` (objetivos do produto)
  - Serena MCP (quando disponível, para validar o código real)
2. NÃO escolha uma única solução ainda.
3. NÃO implemente nada.
4. Sempre que necessário:
  - validar suposições com Serena
  - evitar decisões baseadas apenas em contexto estático

---

## Regras específicas

- NÃO assumir arquitetura sem validar no código
- NÃO propor soluções que contradizem padrões existentes
- Se Serena estiver disponível:
  - validar pelo menos uma hipótese no código real
- Se Serena NÃO estiver disponível:
  - avisar limitação na análise

---

## Importante

- Se alguma abordagem violar `.agents` → DESCARTAR
- Se houver dúvida → PERGUNTAR
- NÃO implementar nada
- NÃO inferir comportamento sem evidência

---

## Produza (conteúdo de **Análise**)

Em **Análise**, inclua obrigatoriamente estas subseções `###`:

### Problema

- O que precisa ser resolvido

### Possíveis abordagens

- Liste 2 a 5 opções diferentes
- Sempre que possível:
  - basear em padrões reais do código (via Serena)

### Prós e contras

- Para cada abordagem

### Complexidade

- Baixa / Média / Alta (por abordagem ou síntese)

### Riscos

- Técnicos ou de negócio
- Considerar impacto no código existente

### Aderência ao projeto

- Compatível com `.agents`?
- Alinhado com `docs`?
- Coerente com o código atual (via Serena)?

### Recomendação

- Melhor opção (com justificativa)

### Confiança na recomendação

- Baixa / Média / Alta

---

## Formato obrigatório de saída

Responda **sempre** com estes quatro títulos `##`, **nesta ordem** e **com estes nomes exatos**:

1. **Status** — ex.: `Em exploração`, `Bloqueado (dúvida)`, `Pronto para /plan` (um valor claro).
2. **Análise** — conteúdo principal; use apenas `###` para subdividir (ver lista abaixo).
3. **Problemas** — violações a `.agents`, lacunas de contexto, riscos inaceitáveis; se não houver: **Nenhum**.
4. **Próximos passos** — ex.: perguntas ao usuário, rodar `/plan`, descartar opção X (ações concretas); quando couber, aguardar confirmação do usuário para seguir para `/plan` (**sempre** a última seção `##` da resposta).

Não omita seções. Não renomeie os títulos.