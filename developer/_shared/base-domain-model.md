---
description: Não é um comando executável. Base compartilhada de modelo de domínio (glossário e ADRs).
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Base comum de modelo de domínio (referência normativa)

Aplicar este bloco nos comandos que leem ou refinam a linguagem do projeto (`/context`, `/brainstorm`, `/spec`, `/plan`, `/execute`, `/test-plan`, `/debug`, `/review-code`).

Objetivo: manter uma **linguagem ubíqua** curta e precisa entre usuário, agente e código, e registrar decisões difíceis de reverter sem duplicar a memória do Memflow.

---

## Layout (OBRIGATÓRIO)

- Glossário: `.agents/domain/GLOSSARY.md`
- ADRs: `.agents/domain/adr/NNNN-slug.md` (numeração sequencial: `0001-...`, `0002-...`)
- Criar arquivos **sob demanda**: o glossário só quando o primeiro termo for resolvido; `adr/` só quando o primeiro ADR for aprovado.
- Para descobrir o próximo número de ADR, ler `.agents/domain/adr/` e incrementar o maior número existente.

---

## Leitura (todos os comandos que aplicam este bloco)

- Se `.agents/domain/GLOSSARY.md` existir:
  - usar seus termos em perguntas, nomes, títulos de tarefa, specs, testes e relatórios
  - NÃO usar termos listados em `_Evitar_`
- Se `.agents/domain/adr/` existir:
  - ler os títulos dos ADRs e abrir o conteúdo apenas dos ADRs da área tocada
  - NÃO reabrir uma decisão registrada em ADR sem sinalizar explicitamente o conflito (ex.: "isso contradiz ADR-0003; vale reabrir porque…")
- Ausência de glossário ou ADRs **não bloqueia** execução.

---

## Refinamento ativo (`/brainstorm`, `/spec`, `/plan`, `/debug`)

Durante a sessão:

- **Desafiar contra o glossário:** quando o usuário usar um termo que conflita com o glossário, apontar imediatamente ("o glossário define X como A, mas você parece usar B — qual é o correto?").
- **Afiar linguagem vaga:** quando um termo for vago ou sobrecarregado, propor um termo canônico ("'conta' aqui é Cliente ou Usuário?").
- **Testar com cenários concretos:** inventar cenários de borda que forcem precisão nas fronteiras entre conceitos.
- **Cruzar com o código:** quando o usuário afirmar como algo funciona, verificar se o código concorda e expor contradições.

---

## Formato do glossário

```md
# {Nome do contexto}

{Uma ou duas frases sobre o que é este contexto.}

## Linguagem

**Pedido**:
{Definição em uma ou duas frases — o que É, não o que faz.}
_Evitar_: compra, transação
```

Regras:

- Ser opinativo: escolher um termo e listar sinônimos em `_Evitar_`.
- Definições curtas (1–2 frases).
- Incluir apenas termos específicos do domínio do projeto (não conceitos genéricos de programação).
- Agrupar por subtítulos quando surgirem clusters naturais.
- O glossário NÃO contém detalhes de implementação, specs ou rascunhos.

---

## ADRs (oferecer com parcimônia)

Oferecer ADR **somente** quando os três critérios forem verdadeiros:

1. **Difícil de reverter** — mudar de ideia depois tem custo relevante
2. **Surpreendente sem contexto** — um leitor futuro perguntaria "por que fizeram assim?"
3. **Resultado de trade-off real** — havia alternativas genuínas e uma foi escolhida por motivos específicos

Se faltar qualquer um → NÃO oferecer ADR.

Template:

```md
# {Título curto da decisão}

{1–3 frases: contexto, o que foi decidido e por quê.}
```

Seções opcionais (apenas quando agregam valor): `Status` (`proposto | aceito | obsoleto | substituído por ADR-NNNN`), `Opções consideradas`, `Consequências`.

---

## Escrita com confirmação (CRÍTICO)

- NUNCA escrever em `.agents/domain/` silenciosamente.
- Agrupar termos resolvidos e ADRs candidatos ao final de cada rodada/fase e perguntar em diálogo estruturado:
  - Sim, registrar no glossário/ADR
  - Não registrar agora
  - Ajustar antes de registrar
- Registrar na `## Análise` os termos e ADRs efetivamente gravados.

---

## Relação com a memória do Memflow

- `.agents/memory/decisions.md` continua sendo a memória de decisões com score (fonte de reuso entre sessões).
- ADR é o registro **durável e legível por humanos** de decisões que passam nos três critérios.
- Quando um ADR for criado para uma decisão existente em `decisions.md`, a decisão deve referenciar o ADR (ex.: `ADR: .agents/domain/adr/0002-slug.md`) — sem duplicar o conteúdo.
- Glossário e ADRs não substituem `/memory-save`.

---

## Regra de precedência

- Este arquivo define o padrão comum de modelo de domínio.
- Comandos podem estender estas regras.
- Invariantes não sobrescrevíveis:
  - escrita em `.agents/domain/` somente com confirmação explícita
  - ADR somente quando os três critérios forem verdadeiros
  - glossário sem detalhes de implementação
  - ausência de glossário/ADRs não bloqueia execução
