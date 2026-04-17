---
name: review
description: Validação inteligente de qualidade antes da validação rígida opcional — avalia aderência a .agents, segurança (client/server), arquitetura, produto (docs), fluxo do sistema e `model-policy.md` do target ativo (via `_shared/target-adapter.md`). Saída: Aprovado ou Reprovado, com problemas por categoria (Regras, Segurança, Arquitetura, Fluxo, Modelo). Não corrige. Pode ser complementado por /review-enforce-rules.
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

## Objetivo

Avaliar se a solução:

- segue `.agents` (regras técnicas e segurança)
- está alinhada com `docs` (produto)
- respeita a arquitetura do projeto
- segue corretamente o fluxo do sistema
- está de acordo com `model-policy.md` resolvido pelo target ativo (via `_shared/target-adapter.md`)

Este comando atua como **validação inteligente principal**, podendo ser complementado pela validação rígida (`/review-enforce-rules`) quando necessário.

---

## Base de análise

Utilizar obrigatoriamente:

- `.agents/**/*` → regras técnicas (quando disponível)
- `docs/**/*` → produto
- `model-policy.md` do target ativo (via `_shared/target-adapter.md`) → uso de modelos
- decisões do `/workflow`
- plano (`/plan`) quando aplicável

---

## Regras

1. NÃO implementar nada
2. NÃO sugerir execução direta
3. NÃO corrigir automaticamente
4. Apenas analisar e validar

---

## Critérios de avaliação

### Aderência às regras

- Segue `.agents`?
- Viola alguma regra técnica? (se `.agents` existir)

---

### Segurança

- Há exposição de secrets?
- Client/server está correto?
- Respeita `.agents/rules/client-server-security.md`?

---

### Arquitetura

- Está consistente com o padrão do projeto?
- Segue os padrões de stack definidos em `.agents`?
- Reutiliza código e componentes existentes?
- Evita duplicação?

---

### Produto

- Está alinhado com `docs`?
- Comportamento esperado foi respeitado?

---

### Fluxo do sistema

- `/workflow` foi utilizado corretamente?
- A decisão foi respeitada?
- `/plan` foi usado quando necessário?
- `/execute` seguiu corretamente o fluxo?
- Houve bypass do sistema?

---

### Estratégia de execução

- Planejamento foi feito quando necessário?
- Complexidade foi tratada corretamente?
- Houve execução indevida sem plano?

---

### Uso de modelo (ALINHADO AO MODEL-POLICY)

- Modelo foi coerente com a complexidade?
- Planejamento usou modelo adequado?
- Execução usou modelo econômico?
- Escalada foi necessária e ignorada?
- Houve uso excessivo de modelo avançado?

---

## Formato obrigatório de saída

Responda SEMPRE com:

## Status

- Aprovado / Reprovado

---

## Análise

- Avaliação geral
- Qualidade da implementação
- Pontos positivos
- Alinhamento com:
  - regras
  - arquitetura
  - fluxo
  - `model-policy.md` do target ativo (via `_shared/target-adapter.md`)

---

## Problemas

Listar problemas separados por tipo:

### Regras

- ...

### Segurança

- ...

### Arquitetura

- ...

### Fluxo

- ...

### Modelo

- ...

Se não houver:
→ Nenhum

Se `.agents` estiver ausente:

- marcar explicitamente como limitação em vez de violação automática

---

## Próximos passos

Se APROVADO:

- Opcionalmente executar `/review-enforce-rules` para validação rígida adicional
- Executar check silencioso de versão do MEMFLOW via comandos remotos (cross-OS, sem depender de binário local no PATH)
  - macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- check --non-interactive`
  - Windows/PowerShell: `powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 check -NonInteractive"`
- Se houver atualização: exibir aviso com versão atual, última versão e comando recomendado de update não interativo

Se REPROVADO:

- Corrigir problemas listados
- Executar novamente `/review`
- Ainda assim executar check silencioso de versão do MEMFLOW ao final (somente exibir mensagem se houver update)

---

## Critérios de reprovação automática

Reprovar se houver:

- violação de `.agents`
- falha de segurança
- execução fora do fluxo correto
- ausência de planejamento quando necessário
- inconsistência com `docs`
- uso inadequado de modelo (contra `model-policy.md` do target ativo via `_shared/target-adapter.md`)

Observação:

- ausência de `.agents`, isoladamente, NÃO reprova automaticamente; usar modo degradado com alerta

---

## Importante

- Este comando NÃO implementa nada
- Atua como QA do sistema
- Dúvidas leves podem ser registradas sem bloqueio automático
- Deve garantir qualidade antes da validação final
