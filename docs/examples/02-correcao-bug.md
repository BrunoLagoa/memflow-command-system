# Exemplo 02 — Correção de bug com diagnóstico estruturado

> Fluxo de investigação e correção de um bug real usando `/debug`
> antes de qualquer implementação.

**Cenário:** usuários reportam que o login falha silenciosamente quando o e-mail contém letras maiúsculas. O backend retorna 200 mas a sessão não é criada.

---

## Contexto inicial

Projeto com memória Memflow ativa. `.agents/memory/decisions.md` tem decisão registrada sobre autenticação: `"normalizar e-mails para lowercase antes de salvar"` (score: 90).

---

## Passo 1 — Carregar contexto

```text
/context
```

**Saída:**

```
Contexto: OK
Memória: carregada
  - Decisões: 7 (incluindo "normalizar e-mails para lowercase" com score 90)
Invariantes anti-compaction: OK
Modo: Normal
```

> Decisão relevante encontrada imediatamente — vai entrar na análise do `/workflow`.

---

## Passo 2 — Definir estratégia

```text
/workflow

Bug: login falha silenciosamente quando e-mail tem letras maiúsculas.
Backend retorna 200, sessão não é criada. Erro só aparece nos logs do servidor.
```

**Saída:**

```
## Status
Decisão tomada

## Análise

### Classificação
- Complexidade: Média
- Impacto: Alto (impede login de usuários)
- Risco: Médio
- Clareza: Média (causa exata incerta)

### Decisões existentes aplicadas
- "normalizar e-mails para lowercase antes de salvar" (score: 90)
  Suspeita imediata: normalização ausente em algum ponto do fluxo de login

### Exploração
Não necessária — causa hipotética clara, /debug define a causa raiz

### Estratégia
- Ação: DIAGNOSTICAR PRIMEIRO (/debug obrigatório)
- Execução: /execute após diagnóstico
- Validação: /review + /review-code

## Próximos passos
1. /debug — identificar causa raiz
2. /execute — após diagnóstico
3. /review + /review-code
```

---

## Passo 3 — Diagnosticar

```text
/debug
```

**Saída:**

```
## Status
Diagnóstico concluído

## Análise

### Classificação do erro
Simples (causa raiz localizada em ponto único)

### Evidências coletadas
- authController.login(): compara req.body.email diretamente com user.email do banco
- user.email no banco: sempre lowercase (normalizado no /register)
- req.body.email na requisição: case-sensitive, não normalizado
- Comparação falha quando o usuário digita "JOAO@EXEMPLO.COM" vs "joao@exemplo.com" no banco

### Hipóteses por probabilidade

1. (90%) Ausência de normalização do e-mail no endpoint de login
   - O endpoint /register normaliza (toLowerCase) mas /login não
   - Decisão existente "normalizar e-mails para lowercase" não foi aplicada
     em todos os endpoints de autenticação

2. (8%) Problema de colação no banco (case-sensitive por configuração)
   - Improvável — banco usa UTF8_UNICODE_CI (case-insensitive) por padrão

3. (2%) Middleware corrompendo a requisição
   - Descartado — retorno 200 confirma que a requisição chega ao controller

### Causa raiz eleita
authController.login() não normaliza o e-mail para lowercase antes
da query. Ponto exato: src/controllers/auth.controller.ts, linha 47.

## Problemas
- Violação da decisão registrada "normalizar e-mails para lowercase"
- Bug reproduzível em qualquer e-mail com maiúsculas

## Próximos passos
→ /execute — aplicar toLowerCase() no e-mail antes da query (1 linha)
→ /review-code — validar correção e ausência de outros endpoints afetados
```

---

## Passo 4 — Corrigir

```text
/execute
```

O `/execute` recebe a causa raiz diagnósticada e aplica a correção mínima:

**Antes:**

```typescript
// src/controllers/auth.controller.ts
const user = await User.findOne({ email: req.body.email });
```

**Depois:**

```typescript
const user = await User.findOne({ email: req.body.email.toLowerCase() });
```

**Saída do `/execute`:**

```
## Status
Parcial — aguardando revisão

## Implementação
- Arquivo: src/controllers/auth.controller.ts (1 linha alterada)
- Testes: adicionado caso de teste para login com e-mail maiúsculo
  (tests/auth.spec.ts — teste "login should normalize email case")

## Score da sessão: 68
→ Recomendado: /review-code
```

---

## Passo 5 — Validar

```text
/review-code
```

**Saída:**

```
## Status
Aprovado

## Análise
- Correção pontual e mínima
- Consistente com decisão "normalizar e-mails para lowercase" (score: 90)
- Teste adicionado cobre o caso reportado
- Verificado: /forgot-password e /resend-verification também normalizam
  (endpoints adjacentes — sem outros pontos vulneráveis)

## Problemas
Nenhum
```

---

## Opcional — Salvar decisão reforçada

```text
/memory-save
```

O `/memory-save` reforça a decisão existente:

```
Decisão "normalizar e-mails para lowercase" atualizada:
- Score anterior: 90 → Score atual: 95
- Nota adicionada: "ausência no /login causou bug P1 em produção"
```

---

## Resultado final

- Bug corrigido em 1 linha, com teste
- Causa raiz identificada antes de qualquer código
- Decisão existente reforçada com contexto de incidente

---

## Comandos usados neste fluxo

```text
/context → /workflow → /debug → /execute → /review-code → /memory-save
```
