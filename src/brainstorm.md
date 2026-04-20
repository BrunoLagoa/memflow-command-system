---
name: brainstorm
description: Brainstorming estruturado antes de qualquer implementação — explora o problema, gera 2 a 5 abordagens alternativas com prós/contras, riscos e recomendação. Inclui gate de aprovação antes do /plan e critérios de prontidão (DoD). Saída: seções Status, Análise, Problemas e Próximos passos. Pré-requisito: /context. Próximo passo: /plan. Não implementa nada.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.2.0"
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
5. Se o escopo envolver múltiplos subsistemas independentes:
  - decompor em partes menores antes de fechar recomendação
6. Se houver lacunas de contexto:
  - fazer uma pergunta por vez para reduzir ambiguidade
7. NÃO avançar para `/plan` sem aprovação explícita do usuário sobre a recomendação.

---

## Regras específicas

- NÃO assumir arquitetura sem validar no código
- NÃO propor soluções que contradizem padrões existentes
- NÃO pedir confirmação de caminho de arquivos normativos quando o comando já estiver em execução no target ativo
- Se Serena estiver disponível:
  - validar pelo menos uma hipótese no código real
- Se Serena NÃO estiver disponível:
  - avisar limitação na análise
- Aplicar YAGNI:
  - evitar overengineering e escopo não solicitado
- Toda recomendação deve indicar a fonte principal:
  - código real (Serena), docs, ou validação explícita do usuário

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

### Premissas e lacunas

- O que é fato validado
- O que é premissa ainda não validada
- Quais lacunas exigem pergunta ao usuário

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

### Critérios de sucesso

- Como medir se a solução atende o objetivo
- Critérios objetivos (funcionais, técnicos e de negócio, quando aplicável)

### Aderência ao projeto

- Compatível com `.agents`?
- Alinhado com `docs`?
- Coerente com o código atual (via Serena)?

### Recomendação

- Melhor opção (com justificativa)

### Decisão e rejeitadas

- Opção escolhida e motivo
- Opções descartadas e motivo do descarte

### Confiança na recomendação

- Baixa / Média / Alta

---

## Critério de prontidão para `/plan` (DoD)

Só use status `Pronto para /plan` se TODOS os itens abaixo estiverem atendidos:

- problema definido com escopo claro
- premissas e lacunas explicitadas
- 2 a 5 abordagens comparadas com prós e contras
- riscos principais identificados
- critérios de sucesso definidos
- recomendação justificada
- opções rejeitadas registradas com motivo
- aprovação explícita do usuário para seguir ao `/plan`

---

## Formato obrigatório de saída

Responda **sempre** com estes quatro títulos `##`, **nesta ordem** e **com estes nomes exatos**:

1. **Status** — usar apenas um valor entre: `Em exploração`, `Aguardando resposta`, `Bloqueado`, `Pronto para /plan`.
2. **Análise** — conteúdo principal; use apenas `###` para subdividir (ver lista abaixo).
3. **Problemas** — violações a `.agents`, lacunas de contexto, riscos inaceitáveis; se não houver: **Nenhum**.
4. **Próximos passos** — ex.: perguntas ao usuário, rodar `/plan`, descartar opção X (ações concretas); quando couber, aguardar confirmação do usuário para seguir para `/plan` (**sempre** a última seção `##` da resposta).

Não omita seções. Não renomeie os títulos.