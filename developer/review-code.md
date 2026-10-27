---
name: review-code
description: Avalia qualidade técnica da implementação em dois eixos independentes sobre o diff desde um ponto fixo — Padrões (padrões documentados do repo + baseline de code smells) e Spec (aderência a PRD/SPEC/PLAN, escopo extra e implementação incorreta). Foco em bugs, arquitetura, testes e readiness para produção. Não implementa. Não corrige. Apenas analisa.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.5.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Validar a qualidade técnica da implementação:

- aderência ao `/spec` e `/plan`
- qualidade de código
- arquitetura
- testes
- readiness para produção

Este comando atua como **validação técnica final antes de produção**.

---

## Entrada esperada

- descrição do que foi implementado
- **ponto fixo** do diff (commit, branch, tag, `main`, `HEAD~N`)
- referência ao `/plan`
- referência ao `/spec` (ou PRD/brainstorm aprovado)

Se a descrição ou o ponto fixo estiverem ausentes:
→ BLOQUEAR e solicitar

Se não houver spec/plan:
→ executar apenas o eixo **Padrões** e registrar "sem spec disponível" no eixo **Spec**

---

## Ponto fixo (OBRIGATÓRIO)

Antes de avaliar:

- validar que o ponto fixo resolve (`git rev-parse <ponto-fixo>`)
- capturar o diff uma vez: `git diff <ponto-fixo>...HEAD` (três pontos, compara contra o merge-base)
- listar commits: `git log <ponto-fixo>..HEAD --oneline`
- ref inválida ou diff vazio → BLOQUEAR aqui, antes de qualquer análise

Quando não houver git, usar o diff/descrição fornecidos e registrar a limitação.

---

## Regras

1. NÃO implementar nada
2. NÃO corrigir automaticamente
3. NÃO assumir comportamento não definido no spec
4. Apenas analisar
5. BLOQUEAR se invariantes anti-compaction (pt-BR + Memflow) estiverem ausentes no contexto
6. Aplicar checklist de continuidade segura definido em `_shared/base-preconditions.md`
7. Avaliar os dois eixos **separadamente**; NÃO mesclar nem re-ranquear achados entre eixos

---

# Eixo 1 — Padrões

Pergunta: o código segue os padrões deste repositório?

## Fontes de padrões

- buscar todo arquivo que documente como escrever código (ex.: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.agents/rules/**`, configs de lint)
- `CODING_STANDARDS.md` e `CONTRIBUTING.md`, quando existirem, são obrigatórios na lista
- vocabulário de `.agents/domain/GLOSSARY.md` e ADRs da área (nomes e decisões vigentes)
- ignorar o que o tooling já garante (formatter, linter, typecheck)

## Baseline de code smells (sempre aplicado)

Regras:

- **o repo prevalece:** padrão documentado no repo sempre vence; se ele endossar algo que o baseline sinalizaria, suprimir o smell
- **sempre julgamento:** cada smell é heurística rotulada ("possível Feature Envy"), nunca violação dura

Smells (o que é → como corrigir):

- **Nome misterioso:** nome não revela o que faz/contém → renomear
- **Código duplicado:** mesma lógica em mais de um trecho do diff → extrair forma comum
- **Feature Envy:** método acessa mais dados de outro objeto que os próprios → mover para perto dos dados
- **Data Clumps:** os mesmos campos/params viajam juntos → agrupar em um tipo
- **Obsessão por primitivos:** primitivo representando conceito de domínio → tipo próprio
- **Switches repetidos:** mesmo `switch`/`if` sobre o mesmo tipo em vários pontos → polimorfismo ou mapa compartilhado
- **Shotgun Surgery:** uma mudança lógica exige edições espalhadas → reunir o que muda junto
- **Divergent Change:** um módulo editado por razões não relacionadas → separar por razão de mudança
- **Generalidade especulativa:** abstração/params/hooks sem necessidade na spec → remover
- **Message Chains:** navegação longa `a.b().c().d()` → esconder atrás de um método
- **Middle Man:** classe/função que só delega → chamar o alvo direto
- **Refused Bequest:** subclasse ignora a maior parte do que herda → composição

## Critérios do eixo Padrões

### Qualidade de código

- código claro e legível?
- separação de responsabilidades?
- duplicação evitada (DRY)?
- tipagem correta (se aplicável)?
- tratamento de erros adequado?

### Arquitetura

- estrutura consistente com o projeto?
- componentes bem definidos?
- escalável?
- performance considerada?

### Testes

- existem testes?
- cobrem lógica real nos seams acordados?
- cobrem edge cases?
- são confiáveis (não apenas mocks, não tautológicos, não acoplados à implementação)?

### Segurança

- exposição de secrets?
- validação de input adequada?
- falhas de segurança evidentes?

### Produção (Readiness)

- backward compatibility considerada?
- erros tratados corretamente?
- logs adequados (sem instrumentação `[DEBUG-...]` remanescente)?
- comportamento previsível?

### Simplicidade e overengineering

- a solução usa o mínimo de complexidade necessário?
- existe abstração de uso único sem necessidade real?
- há configurabilidade/flexibilidade adicionada sem requisito explícito?
- o volume de código é proporcional ao problema resolvido?

---

# Eixo 2 — Spec

Pergunta: o código implementa fielmente o que a spec/plan pediu?

Reportar, **citando a linha da spec** em cada achado:

- (a) requisitos pedidos que estão **ausentes ou parciais**
- (b) comportamento no diff que **não foi pedido** (escopo extra)
- (c) requisitos que parecem implementados, mas com **implementação incorreta**

Também verificar:

- segue contratos de input/output?
- regras e estados foram respeitados?
- seams e decisões de teste da spec foram seguidos?

---

## Por que dois eixos

- código que segue todos os padrões mas implementa a coisa errada → **Padrões aprovado, Spec reprovado**
- código que faz exatamente o pedido mas quebra convenções → **Spec aprovado, Padrões reprovado**

Reportar separadamente impede que um eixo mascare o outro.

---

## Classificação de problemas (dentro de cada eixo)

### Critical (MUST FIX)

- bugs
- falhas de segurança
- quebra de funcionalidade
- violação do spec

---

### Important (SHOULD FIX)

- problemas de arquitetura
- ausência de testes relevantes
- tratamento de erro insuficiente
- overengineering (abstrações/configurações sem necessidade)
- escopo extra não solicitado

---

### Minor (NICE TO HAVE)

- melhorias de código
- legibilidade
- otimizações
- smells do baseline (julgamento)

---

## Importante

- Este comando NÃO valida fluxo do memflow (isso é papel do `/review`)
- Este comando NÃO substitui `/review`
- Este comando valida a implementação real
- Refatorações sugeridas aqui são a etapa de refactor do ciclo TDD (não fazem parte do red → green do `/execute`)
- NÃO autoexecutar qualquer próximo passo sem confirmação explícita do usuário

---

# Orquestração com subagents

Aplicar `_shared/base-subagents.md`. Somente quando a decisão do `/workflow` for `Orquestração: Com subagents`:

- enviar **dois subagents na mesma mensagem**, um por eixo, para que nenhum contamine o contexto do outro:
  - **Padrões:** comando de diff, lista de commits, fontes de padrões encontradas **e o baseline de smells colado por completo** (o subagent não tem outro acesso a ele); brief: reportar por arquivo/trecho (a) violações de padrão documentado citando arquivo e regra e (b) smells do baseline citando o trecho, distinguindo violação dura de julgamento; até 400 palavras
  - **Spec:** comando de diff, lista de commits e path (ou conteúdo) da spec; brief: (a) requisitos ausentes/parciais, (b) escopo extra, (c) implementação incorreta, citando a linha da spec; até 400 palavras
- sem spec → enviar apenas o subagent de Padrões
- apresentar os relatórios sob os eixos, verbatim ou levemente limpos, **sem mesclar nem re-ranquear**
- verificar cada achado Critical no código antes de usá-lo no Status

Sem subagents → avaliar os dois eixos em sequência no contexto principal, mantendo-os separados.

---

# Formato obrigatório de saída

## Status

- Aprovado / Aprovado com ressalvas / Reprovado
- Regra: qualquer Critical em qualquer eixo → Reprovado; qualquer Important → no máximo Aprovado com ressalvas

---

## Análise

### Ponto fixo

- ref, commits avaliados e comando de diff usado

### Eixo Padrões

- fontes de padrões encontradas
- avaliação de qualidade, arquitetura, testes, segurança, readiness e simplicidade
- smells identificados (rotulados como julgamento)

### Eixo Spec

- fonte de spec usada (ou "sem spec disponível")
- requisitos ausentes/parciais, escopo extra e implementação incorreta (com citação)

### Resumo

- total de achados por eixo e o pior problema **dentro de cada eixo** (sem eleger um vencedor entre eixos)

---

## Problemas

### Padrões

#### Critical
- ...

#### Important
- ...

#### Minor
- ...

### Spec

#### Critical
- ...

#### Important
- ...

#### Minor
- ...

Se não houver:
→ Nenhum

---

## Próximos passos

Se APROVADO:

- pronto para produção
- Aguardar confirmação explícita do usuário antes de qualquer novo comando

Se COM RESSALVAS:

- corrigir itens importantes antes de merge
- Aguardar confirmação explícita do usuário antes de qualquer novo comando

Se REPROVADO:

- corrigir críticos
- reexecutar `/review-code`
- Aguardar confirmação explícita do usuário antes de qualquer novo comando
