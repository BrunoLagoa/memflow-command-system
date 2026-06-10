<p align="center">
  <img src="docs/assets/logo.webp" alt="Memflow logo" width="240" />
</p>

<h1 align="center">Memflow Command System</h1>

<p align="center">
  Sistema avançado de engenharia com IA para SDLC (Software Development Life Cycle) completo, com orquestração inteligente, execução disciplinada, validação rígida e memória evolutiva de decisões.
</p>

<p align="center">
  Crie software de alta qualidade mais rapidamente. Um conjunto de ferramentas de código aberto para focar em cenários de produto e resultados previsíveis, em vez de desenvolver cada parte do zero com base em intuição.
</p>

<p align="center">
  <a href="https://github.com/BrunoLagoa/memflow-command-system/stargazers"><img src="https://img.shields.io/github/stars/BrunoLagoa/memflow-command-system?style=social" alt="GitHub stars" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system/releases/latest"><img src="https://img.shields.io/github/v/release/BrunoLagoa/memflow-command-system" alt="Latest Release" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system/blob/main/LICENSE"><img src="https://img.shields.io/github/license/BrunoLagoa/memflow-command-system" alt="License" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system"><img src="https://hits.sh/github.com/BrunoLagoa/memflow-command-system.svg?label=Project%20views&color=f1c40f" alt="Project views" /></a>
</p>

<!-- README-I18N:START -->

[English](./README.md) | **Português (Brasil)**

<!-- README-I18N:END -->

---

## Em uma frase

Memflow transforma o "abre o chat e torce" em um fluxo de engenharia que **decide com critério, executa com disciplina, valida com rigor e lembra das decisões** entre sessões.

---

## Por que Memflow?

A maioria dos fluxos com IA é assim: abre chat, cola contexto, pede código, torce, repete. Cada sessão começa do zero. Decisões se perdem. Os mesmos erros voltam na próxima semana.

O Memflow troca o improviso por um processo auditável e repetível:

| Sem Memflow                                   | Com Memflow                                                        |
| --------------------------------------------- | ----------------------------------------------------------------- |
| Cada sessão começa do zero                    | Memória reaproveitada entre sessões                               |
| Decisões se perdem no histórico do chat       | Decisões viram memória estruturada com categoria, impacto e score |
| Sempre o modelo mais caro (ou o mais barato)  | Modelo certo para a tarefa — barato por padrão, escala quando precisa |
| "Tá aprovado" no feeling                      | Gate final explícito: `OK` ou `BLOQUEADO`                         |
| A IA decide e executa de uma vez              | Cada etapa pede confirmação antes de seguir                       |

Por baixo, o Memflow funciona como um time de engenharia em estágios:

- **Workflow** — classifica a tarefa, encaminha exploração quando precisa (`/brainstorm`) e escolhe estratégia e modelo certos.
- **Execução** — implementa com fallbacks controlados e checkpoints explícitos.
- **Validação** — gate final estrito (`OK` ou `BLOQUEADO`), sem aprovação no feeling.
- **Memória** — captura decisões relevantes com categoria, impacto e score `0–100`, e reaproveita entre sessões.

O resultado é algo que você pode auditar, repetir e confiar.

---

## Início rápido

Um comando interativo. Ele detecta seu ambiente, faz 3 perguntas e instala.

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 install"
```

O wizard guia você por 3 escolhas:

1. **Sistema operacional**
2. **Plataforma** — `OpenCode`, `VSCode`, `Cursor` ou `Claude Code`
3. **Escopo** — `global` ou `local` (quando aplicável)

Depois, vá direto para seus primeiros comandos:

```text
/context
/workflow
```

> **Novo no Memflow?** Leia o [guia dos primeiros 10 minutos](docs/QUICKSTART.pt-BR.md) para um passo a passo com exemplos reais.

> **Precisa de instalação scriptada, update, check ou uninstall?** Veja o [guia de instalação avançada](docs/INSTALL.pt-BR.md).

---

## Como funciona — o fluxo

```text
   ┌──────────┐   ┌──────────────┐   ┌────────────────┐   ┌──────────┐
   │ /context │──▶│  /workflow   │──▶│    /execute    │──▶│ /review  │
   │  carrega │   │   decide     │   │   (ou /plan)   │   │  valida  │
   │  memória │   │   modelo     │   │   implementa   │   │          │
   └──────────┘   └──────┬───────┘   └────────────────┘   └────┬─────┘
                         │                                      │
                  ┌──────▼───────┐                    ┌─────────▼──────┐
                  │ /brainstorm  │                    │  /memory-save  │
                  │  (opcional)  │                    │   (opcional)   │
                  └──────────────┘                    └────────────────┘
```

- **`/context` → `/workflow` → `/execute` → `/review`** é o caminho principal.
- Quando `/workflow` detecta clareza insuficiente ou trade-offs não resolvidos, encaminha para **`/brainstorm`** primeiro. O handoff após aprovação vai para `/prd`, `/spec` ou `/plan`.
- Para trabalho de alto risco, finalize com **`/review-code`** (revisão técnica profunda) e **`/review-enforce-rules`** (gate final estrito).

---

## O que vem incluído

### Comandos de orquestração

A camada de controle que decide, executa e valida — o caminho principal.

| Comando                  | O que faz                                                                                     |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| `/context`               | Carrega contexto do projeto, memória, modo de operação e skills disponíveis                  |
| `/workflow`              | Classifica a tarefa; decide exploração (`/brainstorm`), estratégia de execução, nível, modelo principal e fallbacks |
| `/execute`               | Aplica a decisão com fallback controlado                                                      |
| `/review`                | Valida aderência técnica e arquitetural                                                       |
| `/review-code`           | Validação técnica profunda antes de produção                                                  |
| `/review-enforce-rules`  | Gate final estrito com saída binária: `OK` ou `BLOQUEADO`                                     |

### Comandos de capacidade

Resolução especializada para o dia a dia, chamada pelo workflow conforme a necessidade.

| Categoria                       | Comandos                                          |
| ------------------------------- | ------------------------------------------------- |
| Descoberta e definição          | `/brainstorm`, `/prd`, `/spec`, `/plan`           |
| Implementação e qualidade       | `/debug`, `/refactor`, `/test-plan`               |
| Memória                         | `/memory-init`, `/memory-save`                    |

### Principais diferenciais

- **Exploração estruturada** — `/brainstorm` compara 2–5 abordagens em diálogo por fases, com HARD-GATE, auto-revisão, salvamento opcional de artefato e handoff para `/prd`, `/spec` ou `/plan`.
- **Reaproveitamento de decisões por score** — decisões com score alto são reaproveitadas automaticamente entre sessões.
- **Política de modelo custo/qualidade** — modelo principal + fallbacks no mesmo nível; escala só quando justificado.
- **Modo degradado funcional** — continua operando mesmo sem `.agents`.
- **Persistência inteligente de memória** — versionamento de decisões com semântica `(update)`.
- **Re-hidratação anti-compaction** — invariantes pt-BR + identidade Memflow restauradas via `/context` e `/workflow`.
- **Integração MCP** — código, memória contextual e documentação externa.
- **Planos vivos** — quando `/plan` é salvo, as tarefas são dimensionadas por complexidade com marcadores de status (`[ ]`, `[-]`, `[x]`, `[!]`) e modos de execução (`[P]` paralelo, `[S]` sequencial).

---

## Glossário rápido

Termos que aparecem no projeto, em uma linha cada:

| Termo                        | O que significa                                                                                  |
| ---------------------------- | ------------------------------------------------------------------------------------------------ |
| `.agents`                    | Pasta de contexto do projeto que o `/context` carrega (memória, modos, skills).                  |
| Score `0–100`                | Nota de relevância de uma decisão; quanto maior, mais ela é reaproveitada entre sessões.         |
| Fallback                     | Modelo de reserva no mesmo nível, usado quando o principal falha — sem escalar custo à toa.      |
| HARD-GATE                    | Ponto de parada obrigatório que exige confirmação explícita antes de seguir.                     |
| Modo degradado               | Operação reduzida porém funcional quando falta `.agents` ou contexto.                            |
| Re-hidratação anti-compaction| Restauração de invariantes (idioma pt-BR e identidade Memflow) quando o histórico é compactado.  |
| MCP                          | Model Context Protocol — integração com código, memória contextual e docs externas.             |
| Planos vivos                 | Planos do `/plan` com tarefas marcadas por status e modo de execução, atualizados ao longo do trabalho. |

---

## Exemplo real

Implementar uma feature de média complexidade com memória ativa:

```text
1. /context              → Carrega .agents e memória existente
2. /workflow             → Detecta decisão prévia, reaproveita se score for alto
3. /plan                 → Necessário por complexidade/risco
4. /execute              → Implementa com validações e testes; calcula score da sessão
5. /memory-save          → Registra decisão com categoria, impacto e score
6. /review               → Verifica qualidade, segurança e arquitetura
7. /review-code          → Validação técnica profunda
8. /review-enforce-rules → Gate final estrito (OK ou BLOQUEADO) — opcional, recomendado
```

Quando escopo ou abordagem estiverem incertos, insira `/brainstorm` após `/workflow` (o passo 3 vira exploração e aprovação, depois `/prd`, `/spec` ou `/plan`).

---

## Ferramentas suportadas

| Ferramenta  | Status | Observações                                                                      |
| ----------- | :----: | -------------------------------------------------------------------------------- |
| OpenCode    |   ✅   | Plataforma principal. Suporte completo a slash commands e fluxo SDLC.            |
| VSCode      |   ✅   | Instalada via `--target vscode` como prompts em `.github/prompts`.               |
| Cursor      |   ✅   | Instalada via `--target cursor` como comandos em `.cursor/commands/memflow`.     |
| Claude Code |   ✅   | Instalada via `--target claude` como comandos em `.claude/commands/memflow`.     |
| Antigravity |   ⏳   | Suporte pendente de validação.                                                   |

---

## Filosofia

> **Workflow decide. Modelo executa. Regras protegem.**

Princípios operacionais:

- **Comece barato, escale quando precisar.** Não queime o modelo mais forte numa correção de uma linha.
- **Sem execução sem decisão.** Contexto e workflow vêm primeiro, sempre.
- **Sem progresso silencioso.** Cada passo aguarda confirmação explícita do usuário.
- **Não perca aprendizado.** Decisões importantes viram memória estruturada.
- **Sem "aprovar no feeling".** Validação é explícita e rastreável.

---

## Documentação

| Doc                                                            | O que tem dentro                              |
| -------------------------------------------------------------- | --------------------------------------------- |
| [Primeiros 10 minutos](docs/QUICKSTART.pt-BR.md)               | Passo a passo com exemplos reais             |
| [Instalação avançada](docs/INSTALL.pt-BR.md)                   | Instalação não-interativa, update, check, uninstall, detalhes de escopo, bootstrap pinning |
| [Guia SDLC (English)](docs/SDLC.md)                            | Guia conceitual do SDLC do Memflow            |
| [Guia SDLC (Português)](docs/SDLC.pt-BR.md)                    | Versão pt-BR                                  |
| [Exemplos ponta a ponta](docs/examples/)                       | Cenários reais com fluxos completos de comandos |
| [Changelog](CHANGELOG.md)                                      | Histórico de versões                          |
| [Política de modelos](src/model-policy.md)                     | Estratégia de seleção e escalada de modelos   |
| Specs de comandos                                              | [`/context`](src/context.md) · [`/workflow`](src/workflow.md) · [`/brainstorm`](src/brainstorm.md) · [`/execute`](src/execute.md) · [`/review-code`](src/review-code.md) · [`/review-enforce-rules`](src/review-enforce-rules.md) |

---

## Para quem é isso?

- Times padronizando SDLC assistido por IA com governança
- Projetos com decisões inconsistentes entre sessões
- Ambientes que precisam balancear custo de modelo e qualidade técnica
- Fluxos com alto requisito de conformidade arquitetural e segurança
- Orgs adotando IA na engenharia sem abrir mão de previsibilidade

---

## Roadmap

- Disponibilizar templates por stack para onboarding mais rápido
- Incluir métricas de efetividade (lead time, retrabalho, custo por tarefa)
- Expandir specs de comandos com hints adaptativos de memória

---

## Contribuindo

Este projeto segue [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). Mensagens de commit são validadas no CI para pull requests e pushes na `main`.

Tipos permitidos: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`.

### Fonte e distribuição

Se você vai mexer no código dos comandos, atenção a como o projeto é organizado (isso reduz custo de token nos prompts e mantém a autoria em pt-BR):

- `developer/` é a **fonte de autoria** em Português (pt-BR).
- `src/` é o **payload de distribuição** em inglês consumido pelos instaladores.
- Os targets do instalador (`opencode`, `cursor`, `vscode`, `claude`) continuam consumindo `src/`.

Quando houver mudança de comportamento dos comandos, mantenha `developer/` e `src/` sincronizados com a mesma estrutura de arquivos.

## Pessoas

Este projeto evolui com contribuições de pessoas que acreditam em engenharia de software com IA de forma disciplinada, prática e auditável.

<p align="left">
  <a href="https://github.com/BrunoLagoa/memflow-command-system/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=BrunoLagoa/memflow-command-system&max=100" alt="Contribuidores do projeto" width="45" />
  </a>
</p>

Quer aparecer aqui também? Abra uma issue, sugira melhorias ou envie um PR.

## Suporte

Abra uma issue no GitHub. Relatos de bugs, solicitações de recursos e dúvidas de uso são bem-vindos.

## Licença

MIT. Veja [`LICENSE`](LICENSE) para os termos completos.

---

<p align="center">
  Se você quer IA atuando como copiloto de engenharia real — e não como gerador de snippets — este sistema foi feito pra isso.
</p>
