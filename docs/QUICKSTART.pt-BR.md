# Primeiros 10 minutos com Memflow

> Do install à primeira sessão real — sem rodeios.

---

## 1. Instalar (2 min)

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 install"
```

O instalador faz 3 perguntas: sistema operacional, plataforma (OpenCode / VSCode / Cursor) e escopo (global ou local). Responda e pronto.

**Verificar:**

```bash
bash scripts/install.sh check
```

---

## 2. Inicializar memória no projeto (1 min)

Abra o projeto na ferramenta de IA (OpenCode, Cursor ou VSCode) e execute:

```text
/memory-init
```

Isso cria `.agents/memory/` com quatro arquivos:

| Arquivo | Para quê |
|---------|---------|
| `memory.md` | Identidade do projeto — stack, estrutura, regras de negócio |
| `decisions.md` | Decisões persistentes com scores — reutilizadas entre sessões |
| `session-memory.md` | Estado temporário da sessão atual |
| `quality-metrics.md` | Histórico de sessões, taxas de aprovação, tendências de retrabalho |

A IA vai pedir confirmação antes de escrever. Confirme.

---

## 3. Primeira sessão (5 min)

Toda sessão começa com `/context` e `/workflow`. Esse é o hábito central.

### Passo 1 — Carregar contexto

```text
/context
```

A saída mostra o que foi carregado da memória, quais decisões existem e se o sistema está pronto. Na primeira vez, a memória será mínima — é esperado.

### Passo 2 — Declarar o objetivo e obter uma decisão

```text
/workflow

Quero adicionar uma tela de login com e-mail e senha ao app.
```

O `/workflow` vai:
- Classificar complexidade, impacto e risco
- Verificar se existem decisões anteriores aplicáveis
- Decidir se exploração (`/brainstorm`) é necessária
- Escolher o caminho: execução direta → `/execute`, planejado → `/plan` primeiro, ou exploração → `/brainstorm`

Siga o que ele recomendar.

### Passo 3 — Executar

Se `/workflow` rotear para **execução direta**:

```text
/execute
```

Se rotear para **planejar primeiro**:

```text
/plan
/execute
```

Se rotear para **exploração**:

```text
/brainstorm
```

Então siga o brainstorm até `/spec` ou `/plan`, depois `/execute`.

### Passo 4 — Validar

```text
/review
```

Para mudanças com muito código:

```text
/review-code
```

Para mudanças críticas (autenticação, pagamentos, segurança):

```text
/review-enforce-rules
```

### Passo 5 — Salvar decisões

Ao final de qualquer sessão que valha a pena preservar:

```text
/memory-save
```

Isso registra decisões e atualiza as métricas de qualidade. A próxima sessão vai encontrar essas decisões em `decisions.md` e aplicá-las automaticamente.

---

## 4. O modelo mental (30 seg)

Memflow não é um assistente de código. É um processo estruturado:

```
Entender  → Decidir   → Planejar → Implementar → Validar  → Lembrar
/context    /workflow   /plan      /execute       /review    /memory-save
```

`/workflow` é o cérebro. Ele decide o que fazer a seguir. Nunca pule.

`decisions.md` é a memória. Fica mais inteligente quanto mais você usa.

---

## 5. Fluxos comuns por cenário

| Cenário | Comandos |
|---------|----------|
| Feature simples nova | `/context` → `/workflow` → `/execute` → `/review` |
| Feature média nova | `/context` → `/workflow` → `/plan` → `/execute` → `/review` → `/memory-save` |
| Feature complexa (incerta) | `/context` → `/workflow` → `/brainstorm` → `/spec` → `/plan` → `/execute` → `/review` |
| Correção de bug | `/context` → `/workflow` → `/debug` → `/execute` → `/review-code` |
| Refatoração | `/context` → `/workflow` → `/plan` → `/refactor` → `/review` |

---

## 6. Exemplos ponta a ponta

Cenários reais com fluxo completo de comandos e saídas esperadas:

- [Exemplo 01 — Nova feature](examples/01-nova-feature.md) — dark mode com memória ativa
- [Exemplo 02 — Correção de bug](examples/02-correcao-bug.md) — falha silenciosa no login
- [Exemplo 03 — Feature complexa](examples/03-feature-complexa-com-brainstorm.md) — sistema de notificações com brainstorm

---

## Comandos úteis

```bash
# Verificar status da instalação
bash scripts/install.sh check

# Atualizar para versão mais recente
bash scripts/install.sh update

# Ver todos os specs de comandos
ls src/*.md
```

---

## Próximos passos

- [`SDLC.pt-BR.md`](SDLC.pt-BR.md) — a metodologia completa
- [`src/model-policy.md`](../src/model-policy.md) — como modelos são selecionados por tarefa
- [`INSTALL.pt-BR.md`](INSTALL.pt-BR.md) — opções avançadas de instalação (escopo local, multi-projeto)
