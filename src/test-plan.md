---
name: test-plan
description: Gera plano de testes completo com cenários principais, casos de borda, segurança e regressão — detecta automaticamente o executor da stack (Vitest, Jest, Playwright, Pytest, RSpec) e inclui comandos concretos de execução. Saída: Status, Análise com executor detectado e comandos reais, Problemas e Próximos passos. Incompleto sem lista de execução concreta.
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
- Resolver essas referências conforme `_shared/target-adapter.md` (sem fallback fora do target ativo).

---

## Objetivo

Criar um plano de testes completo e alinhado ao projeto.

---

## Base

- `.agents` → regras técnicas
- `docs` → regras de negócio

---

## Produza:

## Cenários principais
- Fluxos principais do sistema

## Casos de teste
- Lista detalhada

## Casos de borda
- Edge cases

## Segurança
- Testes de segurança (se aplicável)

## Regressão
- O que precisa ser garantido

## Estratégia
- Como testar (manual, unitário, e2e)

## Detecção de stack e executor (OBRIGATÓRIO)

Antes de definir comandos, identificar:

- Runtime principal e linguagem do projeto
- Executor(es) de teste configurados (Vitest, Jest, Playwright, Pytest, RSpec, etc.)
- Comandos reais disponíveis no repositório (scripts/config/documentação)

## Execução dos testes (após o plano)

Sempre incluir:

- **Quais testes executar**: caminhos de arquivos, pastas, suítes ou filtros relevantes
- **Comandos concretos** para rodar só o necessário, conforme stack detectada
- **Mapeamento** de cada cenário crítico para ao menos um teste/filtro (ou marcar “criar teste”)

### Se usar Vitest

- Exemplos:
  - `npx vitest run <caminho/do/arquivo.test.ts>`
  - script do projeto (ex.: `npm run test -- <args>`)

### Se NÃO usar Vitest

- Avisar explicitamente
- Informar executor real e comandos equivalentes com o mesmo nível de detalhe
- Exemplos possíveis:
  - Jest: `npx jest <caminho/ou/filtro>`
  - Playwright: `npx playwright test <caminho/ou/grep>`
  - Pytest: `pytest <caminho/ou-k>`
  - RSpec: `bundle exec rspec <caminho/ou-tag>`

---

## Importante

- Priorize cenários críticos
- Se faltar contexto → AVISAR
- Não assumir Node/npm quando não for a stack do projeto
- Plano sem **lista de execução concreta do executor detectado** → **incompleto**; não tratar o passo como encerrado até isso constar na resposta

---

## Formato obrigatório de saída

Responda SEMPRE com:

## Status

- Plano de testes criado / Bloqueado

---

## Análise

- Cenários cobertos
- Estratégia de teste
- Executor(es) detectados
- Comandos concretos de execução

---

## Problemas

- Lacunas de cobertura
- Falta de contexto
- Se não houver: Nenhum

---

## Próximos passos

- Executar testes listados
- Ajustar plano (se necessário)