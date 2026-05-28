# Exemplo 03 — Feature complexa com exploração prévia

> Fluxo completo para features com trade-offs não resolvidos:
> `/workflow` rota para `/brainstorm` antes de qualquer decisão técnica.

**Cenário:** adicionar sistema de notificações (email + push + in-app) a um SaaS. Sem decisão prévia sobre canais, frequência ou persistência. Equipe tem dúvidas sobre a abordagem.

---

## Contexto inicial

Projeto novo no Memflow. Memória foi inicializada com `/memory-init` mas `decisions.md` ainda está vazia para esta área. Sem precedente interno sobre mensageria.

---

## Passo 1 — Carregar contexto

```text
/context
```

**Saída:**

```
Contexto: OK
Memória: carregada
  - Decisões: 2 (sobre autenticação e banco — não aplicáveis aqui)
Invariantes anti-compaction: OK
Modo: Normal
```

---

## Passo 2 — Definir estratégia

```text
/workflow

Quero implementar um sistema de notificações. Precisa suportar e-mail,
push web e notificações in-app. Ainda não sei a melhor abordagem.
```

**Saída:**

```
## Status
Decisão tomada

## Análise

### Classificação
- Complexidade: Alta
- Impacto: Alto
- Risco: Alto
- Clareza: Baixa (múltiplas abordagens viáveis sem trade-offs resolvidos)

### Exploração
Necessária (/brainstorm obrigatório)
- Motivo: complexidade alta + sem decisão prévia + múltiplas abordagens

## Próximos passos
1. /brainstorm — explorar abordagens, resolver trade-offs
2. /spec ou /plan — após brainstorm definir escopo final
3. /execute
```

---

## Passo 3 — Explorar com brainstorm

```text
/brainstorm
```

> HARD-GATE ativo — o `/brainstorm` não vai implementar nada. Somente explorar e recomendar.

**Fase 1/4 — Contexto:**

```
Antes de começar, preciso entender melhor o cenário.

A) Qual é o volume esperado de notificações?
   1. Pequeno (< 10k/dia)
   2. Médio (10k–100k/dia)
   3. Grande (> 100k/dia)
```

*Resposta: 2 (médio)*

```
B) Vocês já têm algum serviço de e-mail contratado?

   1. Sim — SendGrid / Resend / SES
   2. Não — precisaríamos contratar
   3. Não — preferimos self-hosted
```

*Resposta: 1 (Resend já contratado)*

```
C) O push web é obrigatório para o MVP ou pode ser incremental?

   1. Obrigatório — entra no MVP
   2. Incremental — pode vir depois
   3. Opcional — só se facilitar
```

*Resposta: 2 (push pode ser incremental)*

---

**Fase 2/4 — Abordagens:**

```
## Abordagens identificadas

### A. Fila interna com workers (Bull/BullMQ + Redis)
Vantagens: controle total, retry configurável, zero dependência externa extra
Desvantagens: complexidade operacional (Redis, workers), mais código para manter
Custo: baixo (infraestrutura já existe se Redis estiver no stack)

### B. Serviço dedicado (Novu, Knock, Courier)
Vantagens: multi-canal nativo, preferências de usuário, analytics prontos
Desvantagens: custo por notificação, vendor lock-in
Custo: ~$0.001/notificação em volumes médios

### C. Funções assíncronas + webhook (Inngest, Trigger.dev)
Vantagens: developer experience excelente, retry gerenciado, observabilidade
Desvantagens: mais um serviço externo
Custo: free tier generoso para volumes médios

### D. Implementação direta sem fila
Vantagens: mais simples inicialmente
Desvantagens: sem retry, falhas silenciosas, bloqueante
Custo: baixo, mas risco alto em produção

Qual abordagem prefere explorar mais?

1. A — controle total (Bull/BullMQ)
2. B — serviço dedicado (Novu/Knock)
3. C — funções assíncronas (Inngest)
4. D — direto sem fila
5. Explorar A e C para comparar
```

*Resposta: 5 (A e C para comparar)*

---

**Fase 3/4 — Design e Recomendação:**

```
## Design proposto

### Recomendação: Opção A (Bull/BullMQ) com abstração de canal

Baseada em:
- Volume médio → Redis já justifica o custo operacional
- Resend já contratado → adaptar sem introduzir novo vendor
- Push web incremental → arquitetura permite adicionar canal depois
- Controle sobre retry e DLQ (dead letter queue)

### Estrutura proposta

src/
  notifications/
    notification.service.ts     — orquestrador, único ponto de entrada
    channels/
      email.channel.ts          — usa Resend SDK
      in-app.channel.ts         — salva no banco, usa SSE ou polling
      push.channel.ts           — Web Push API (incremental)
    queues/
      notification.queue.ts     — define filas Bull com retry
      notification.processor.ts — worker que consome a fila
    templates/
      welcome.template.ts
      password-reset.template.ts

### Fluxo
chamador → notification.service.send(userId, type, data)
  → enfileira em Bull
    → processor consome → channel.send()
      → OK: marca como entregue
      → FALHA: retry automático (max 3x, exponential backoff)
        → DLQ após 3 falhas → alerta para monitoramento

### Trade-offs resolvidos
- Push web: canal criado mas desabilitado por feature flag
- Preferências de usuário: tabela user_notification_preferences
- Rate limiting por usuário: Redis sorted sets no processor

## Auto-revisão
- Escopo claro? SIM
- Abordagem justificada? SIM
- Trade-offs explícitos? SIM
- Pronto para /spec? SIM

## Status
Pronto para /spec
```

---

**Fase 4/4 — Confirmação de salvamento:**

```
Deseja salvar este brainstorm para referência futura?

A) Sim, salvar em .agents/docs/brainstorm/notifications.md
B) Não, apenas continuar
```

*Escolha A* → salvo com ID `bs-notifications-2026-05-28`.

---

## Passo 4 — Especificar

```text
/spec
```

O `/spec` usa o brainstorm salvo como base e gera a spec técnica formal, incluindo interfaces TypeScript, contratos de API e critérios de aceite.

---

## Passo 5 — Planejar

```text
/plan
```

Com a spec aprovada, o `/plan` cria a sequência de implementação com arquivos, dependências e checkboxes.

---

## Passo 6 — Implementar

```text
/execute
```

Segue o plano. Ao final, score da sessão 81 → `decisions.md` atualizado com:

```markdown
### notification-architecture (score: 81)
- Decisão: Bull/BullMQ + Redis para fila de notificações
  com abstração de canal e feature flag para push web
- Contexto: SaaS médio porte, Resend já contratado, push incremental
- Data: 2026-05-28
```

---

## Passo 7 — Validar

```text
/review → /review-enforce-rules
```

O `/review-enforce-rules` (gate binário) é acionado por ser feature de alta criticidade:

```
## Status
OK

Fluxo completo respeitado:
/workflow → /brainstorm → /spec → /plan → /execute
Decisão salva. Invariantes pt-BR e Memflow confirmados.
```

---

## Resultado final

- Feature complexa entregue com trade-offs documentados
- Arquitetura extensível (push web por feature flag)
- Brainstorm salvo para rastreabilidade de decisão
- Decisão com score 81 disponível para próximas sessões

---

## Comandos usados neste fluxo

```text
/context → /workflow → /brainstorm → /spec → /plan → /execute → /memory-save → /review → /review-enforce-rules
```
