# Exemplo 04 — Memória e `/memory-save`

> Três cenários que mostram quando salvar, quando reforçar e quando **não** salvar.

---

## Cenário A — Primeira sessão (nada para salvar ainda)

**Situação:** projeto recém-inicializado com `/memory-init`. `decisions.md` vazio.

```text
/context
```

```
Contexto: OK
Memória: carregada
  - Decisões: 0
Métricas: N/A
Modo: Normal
```

```text
/workflow

Quero entender a estrutura do projeto antes de implementar qualquer coisa.
```

```
## Status
Decisão tomada

## Análise
- Complexidade: Baixa
- Exploração: Não necessária
- Estratégia: apenas orientação — sem /execute

## Próximos passos
- Responder dúvidas do usuário
- Não invocar /memory-save (nenhuma decisão tomada)
```

**Resultado:** `/memory-save` **não é necessário**. Não há decisão, review ou score de relevância.

---

## Cenário B — Sessão que registra decisão nova

**Situação:** após `/execute` de feature média, score 74.

```text
/memory-save
```

**Gate de confirmação:**

```
Resumo do que será salvo:

Decisões:
- api-pagination-strategy (score: 74, nova)

Métricas: sim (review aprovado)
Session-memory: será limpo após salvar

Deseja persistir?

A) Sim, salvar tudo
B) Salvar apenas decisões (sem métricas)
C) Não salvar
```

*Escolha A*

**Escrita em `decisions.md`:**

```markdown
## Técnicas

### api-pagination-strategy (score: 74)
- Categoria: Técnica
- Impacto: Médio
- Decisão: Paginação cursor-based em endpoints de listagem;
  offset-based apenas para admin interno.
- Contexto: volume médio de dados, performance em mobile
- Data: 2026-05-28
- Versão: 1
```

**Atualização em `quality-metrics.md`:**

```markdown
## Snapshot atual
- Execuções: 1
- Taxa aprovação: 100%
- Taxa reprovação: 0%
- Retrabalho médio: 0
- Tendência: estável
```

**Saída do `/memory-save`:**

```
## Status
Salvo

## Análise
### Persistência
- Decisões salvas: 1 (api-pagination-strategy)
- Métricas atualizadas: SIM
- Session-memory limpo: SIM

## Próximos passos
- /context — recarregar memória atualizada
```

---

## Cenário C — Sessão que reforça decisão existente

**Situação:** bug P1 causado por violação de decisão anterior.

`decisions.md` já contém:

```markdown
### email-normalization (score: 90)
- Decisão: Normalizar e-mails para lowercase antes de salvar e comparar
- Versão: 2
```

Após `/debug` + `/execute` + `/review-code`:

```text
/memory-save
```

**Detecção:** mesma decisão, evidência adicional (incidente em produção).

**Gate:**

```
Decisões:
- email-normalization (score: 95, reforço)
  Nota: ausência no /login causou bug P1

Deseja persistir?
A) Sim, salvar tudo
```

*Escolha A*

**Atualização (não duplicata):**

```markdown
### email-normalization (score: 95)
- Decisão: Normalizar e-mails para lowercase em TODOS os endpoints de auth
- Contexto: bug P1 em /login — comparação case-sensitive em 2026-05-28
- Versão: 3
```

**Regra aplicada:** reforço +5 pontos (90 → 95), versão incrementada, contexto enriquecido.

---

## Cenário D — Sessão trivial (não salvar)

**Situação:** ajuste de typo em comentário, score 5.

```text
/execute
```

```
Score da sessão: 5
→ Não necessário salvar
```

Se o usuário invocar `/memory-save` mesmo assim:

```
## Status
Não necessário

## Análise
- Score de relevância: 5/100 (abaixo do limiar 21)
- Nenhuma decisão detectada
- Nenhuma métrica elegível

## Problemas
Nenhum

## Próximos passos
- Continuar fluxo sem persistência
```

**Regra:** score < 21 → não poluir memória.

---

## Ciclo completo: review → métricas → próxima sessão

```
Sessão N:
  /execute → /review (reprovado) → /memory-save
    → quality-metrics: taxa_reprovacao sobe

Sessão N+1:
  /context → qualidade_baixa detectada
  /workflow → exige /plan + /review-code reforçado
```

Esse loop é o que torna a memória **evolutiva**, não apenas um log.

---

## Comandos por cenário

| Cenário | Quando usar `/memory-save` |
|---------|---------------------------|
| A — Exploração inicial | Não |
| B — Decisão nova | Sim (após confirmação) |
| C — Reforço | Sim (atualiza existente) |
| D — Trivial | Não (bloqueado por score) |

---

## Arquivos envolvidos

| Arquivo | Papel no `/memory-save` |
|---------|-------------------------|
| `decisions.md` | Decisões persistentes com score e versão |
| `session-memory.md` | Limpo após save bem-sucedido |
| `quality-metrics.md` | KPIs e snapshot atualizados após review |
| `decision-suggestions.md` | Sugestões geradas a partir de padrões (≥ 5 execuções) |
