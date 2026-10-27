---
name: test-plan
description: Gera plano de testes completo a partir dos seams de teste acordados, com cenários principais, casos de borda, segurança e regressão — detecta automaticamente o executor da stack (Vitest, Jest, Playwright, Pytest, RSpec) e inclui comandos concretos de execução. Saída: Status, Análise com executor detectado e comandos reais, Problemas e Próximos passos. Incompleto sem lista de execução concreta.
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
- `_shared/base-domain-model.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolver essas referências conforme `_shared/target-adapter.md` (sem fallback fora do target ativo).

---

## Objetivo

Criar um plano de testes completo e alinhado ao projeto.

---

## Base

- `.agents` → regras técnicas
- `docs` → regras de negócio
- seções **Pontos de teste (seams)** e **Decisões de teste** da `/spec` (quando existirem)
- termos de `.agents/domain/GLOSSARY.md` nos nomes dos testes

---

## Seams de teste (OBRIGATÓRIO)

- Partir dos seams confirmados na `/spec`; se não houver spec, propor seams e **confirmar com o usuário** antes do plano.
- Para cada seam proposto: uma linha sobre o que ele captura e o que ele não captura.
- Testar comportamento pela interface pública; nenhum teste em seam não confirmado.

## Anti-padrões (evitar)

- **Acoplado à implementação:** mocka colaboradores internos, testa métodos privados ou verifica por canal lateral (ex.: consultar o banco em vez de usar a interface). Sinal: quebra no refactor sem mudança de comportamento.
- **Tautológico:** a asserção recalcula o valor esperado do mesmo jeito que o código (`expect(soma(a, b)).toBe(a + b)`); valores esperados devem vir de fonte independente.
- **Fatiamento horizontal:** escrever todos os testes antes de qualquer implementação; preferir fatias verticais (um teste → uma implementação → repetir).

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
- **Critério de aprovação por cenário**: evidência objetiva de sucesso/falha esperada

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
- aplicar loop de validação: reproduzir cenário, executar teste, confirmar evidência e só então marcar como validado

---

## Formato obrigatório de saída

Responda SEMPRE com:

## Status

- Plano de testes criado / Bloqueado

---

## Análise

- Seams de teste (confirmados)
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