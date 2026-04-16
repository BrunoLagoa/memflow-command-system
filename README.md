<p align="center">
  <img src="docs/assets/logo.webp" alt="Memflow logo" width="300" />
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

## Visão geral do sistema

O `memflow-command-system` é um conjunto de comandos operacionais que transforma uso ad-hoc de IA em um fluxo de engenharia previsível e auditável.

Em vez de "pedir código", você roda um sistema com etapas claras:

- **orquestração** para decidir estratégia e modelo
- **execução** para implementar com segurança
- **validação** para bloquear violações antes de concluir
- **memória** para preservar decisões e reduzir retrabalho

Na prática, ele funciona como uma camada de controle SDLC para times que querem velocidade com qualidade.

## Principais diferenciais

- Workflow stateful com reaproveitamento de decisões por score (`0-100`)
- Gate final estrito com saída binária (`OK` ou `BLOQUEADO`)
- Política de modelos orientada a custo/qualidade com escalada progressiva
- Modo degradado funcional quando `.agents` não existe
- Persistência inteligente de memória com versionamento de decisões (`(update)`)
- Estrutura modular por comando, com regras compartilhadas em `_shared`
- Integração com MCPs para código, memória contextual e documentação externa

## Como funciona (visão simplificada do fluxo)

```text
/context
   ↓
/workflow
   ↓
/execute (ou /plan, quando necessário)
   ↓
(/memory-save, se recomendado)
   ↓
/review
   ↓
/review-enforce-rules (Opcional)
```

## Arquitetura (orquestração vs capacidades)

### 1) Orquestração (decisão e controle)

- `/context`: carrega contexto, memória e modo de operação
- `/workflow`: classifica tarefa, decide estratégia e modelo
- `/execute`: aplica a decisão com fallback controlado
- `/review`: valida aderência técnica e arquitetural
- `/review-enforce-rules`: validação rígida final (recomendada/opcional)
- `model-policy.md`: estratégia de seleção e escalada de modelos

### 2) Capacidades (resolução especializada)

- Descoberta e definição: `/prd`, `/spec`, `/plan`, `/brainstorm`
- Implementação e qualidade: `/execute`, `/debug`, `/refactor`, `/test-plan`
- Memória: `/memory-init`, `/memory-save`

### 3) Regras compartilhadas

Arquivos em `src/_shared` centralizam normas transversais:

- `base-output.md`
- `base-preconditions.md`
- `base-degraded-mode.md`

## Como começar (quick start)

### Pré-requisitos

- Ambiente com suporte a slash commands
- `bash` e `curl` para macOS/Linux
- `PowerShell 7+` para Windows nativo

### Instalação

#### Opção A — one-liner (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

O wizard `MEMFLOW` guia as escolhas de:

1. Sistema operacional
2. Plataforma de instalação (`OpenCode`)
3. Escopo (`local` ou `global`)

#### Opção B — execução local do script (macOS/Linux)

```bash
git clone https://github.com/BrunoLagoa/memflow-command-system.git
cd memflow-command-system
chmod +x scripts/install.sh
./scripts/install.sh install
```

#### Opção C — Windows nativo (PowerShell)

```powershell
git clone https://github.com/BrunoLagoa/memflow-command-system.git
cd memflow-command-system
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install
```

### Instalação não interativa

#### Global

##### macOS/Linux

```bash
./scripts/install.sh install --non-interactive --scope global --target opencode
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope global -Target opencode
```

#### Local (projeto atual)

##### macOS/Linux

```bash
./scripts/install.sh install --non-interactive --scope local --project-dir . --target opencode
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope local -ProjectDir . -Target opencode
```

### Entrypoint recomendado (qualquer diretório)

Para operações de manutenção sem depender do clone local do repositório, priorize `memflowctl`:

#### Update (global)

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl | bash -s -- update --scope global --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl.ps1 -OutFile $env:TEMP\memflowctl.ps1; & $env:TEMP\memflowctl.ps1 update -Scope global -NonInteractive"
```

#### Update (local)

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl | bash -s -- update --scope local --project-dir . --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl.ps1 -OutFile $env:TEMP\memflowctl.ps1; & $env:TEMP\memflowctl.ps1 update -Scope local -ProjectDir . -NonInteractive"
```

#### Check de versão (global)

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl | bash -s -- check --scope global --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl.ps1 -OutFile $env:TEMP\memflowctl.ps1; & $env:TEMP\memflowctl.ps1 check -Scope global -NonInteractive"
```

#### Check de versão (local)

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl | bash -s -- check --scope local --project-dir . --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/memflowctl.ps1 -OutFile $env:TEMP\memflowctl.ps1; & $env:TEMP\memflowctl.ps1 check -Scope local -ProjectDir . -NonInteractive"
```

### Atualizar para nova versão

#### Recomendado (`memflowctl`)

##### Global

###### macOS/Linux

```bash
memflowctl update --scope global --non-interactive
```

###### PowerShell

```powershell
memflowctl.ps1 update -Scope global -NonInteractive
```

##### Local (projeto atual)

###### macOS/Linux

```bash
memflowctl update --scope local --project-dir . --non-interactive
```

###### PowerShell

```powershell
memflowctl.ps1 update -Scope local -ProjectDir . -NonInteractive
```

#### Alternativa (scripts locais)

##### Global

###### macOS/Linux

```bash
./scripts/install.sh update --scope global
```

###### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 update -Scope global
```

##### Local (projeto atual)

###### macOS/Linux

```bash
./scripts/install.sh update --scope local --project-dir .
```

###### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 update -Scope local -ProjectDir .
```

Por padrão, o update usa a release tagueada mais recente.

### Remover instalação

#### Recomendado (`memflowctl`)

##### Global

###### macOS/Linux

```bash
memflowctl uninstall --scope global --non-interactive
```

###### PowerShell

```powershell
memflowctl.ps1 uninstall -Scope global -NonInteractive
```

##### Local (projeto atual)

###### macOS/Linux

```bash
memflowctl uninstall --scope local --project-dir . --non-interactive
```

###### PowerShell

```powershell
memflowctl.ps1 uninstall -Scope local -ProjectDir . -NonInteractive
```

#### Alternativa (scripts locais)

##### Global

###### macOS/Linux

```bash
./scripts/install.sh uninstall --scope global --non-interactive
```

###### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 uninstall -Scope global -NonInteractive
```

##### Local (projeto atual)

###### macOS/Linux

```bash
./scripts/install.sh uninstall --scope local --project-dir . --non-interactive
```

###### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 uninstall -Scope local -ProjectDir . -NonInteractive
```

### Destinos de instalação

- `global`: `~/.config/opencode/commands/memflow`
- `local`: `<projeto>/.opencode/commands/memflow`

### Primeiro uso

```bash
/context
/workflow
```

Se a tarefa for simples, o próximo passo normalmente é:

```bash
/execute
/review
/review-enforce-rules  # recomendado para validação rígida final
```

## Exemplo de fluxo real

Exemplo: implementar uma feature de média complexidade com memória ativa.

```text
1. /context
   - Carrega .agents e memória existente

2. /workflow
   - Detecta decisão prévia em decisions.md
   - Reaproveita decisão se score for alto

3. /plan
   - Necessário por complexidade/risco

4. /execute
   - Implementa com validações e testes
   - Calcula score de relevância da sessão

5. /memory-save
   - Registra decisão relevante com categoria, impacto e score

6. /review
   - Verifica qualidade, segurança e arquitetura

7. /review-enforce-rules (opcional/recomendado)
   - Aplica validação rígida adicional (OK ou BLOQUEADO)
```

## Suporte de ferramentas

Esta seção será atualizada continuamente conforme novos ambientes forem validados.

| Ferramenta | Suporte | Observações |
| ---------- | ------- | ----------- |
| `opencode` | ✅ | Plataforma principal do projeto, com suporte completo a comandos slash e fluxo SDLC. |

## Documentação (links para docs)

- Histórico de versões: [`CHANGELOG.md`](CHANGELOG.md)
- Guia conceitual de SDLC: [`docs/SDLC.md`](docs/SDLC.md)
- Política de modelos (operacional): [`src/model-policy.md`](src/model-policy.md)
- Comando de contexto: [`src/context.md`](src/context.md)
- Comando de decisão: [`src/workflow.md`](src/workflow.md)
- Comando de execução: [`src/execute.md`](src/execute.md)
- Validação rígida opcional: [`src/review-enforce-rules.md`](src/review-enforce-rules.md)

## Filosofia do sistema

> Workflow decide.  
> Modelo executa.  
> Regras protegem.

Princípios operacionais:

- Começar barato, escalar modelo apenas quando necessário
- Não executar sem contexto e sem decisão de fluxo
- Não perder aprendizado: decisão importante vira memória estruturada
- Não "aprovar no feeling": validação é explícita e rastreável

## Casos de uso

- Times que querem padronizar SDLC assistido por IA com governança
- Projetos que sofrem com decisões inconsistentes entre sessões
- Ambientes que precisam equilibrar custo de modelo e qualidade técnica
- Fluxos com alto requisito de conformidade arquitetural e segurança
- Adoção de IA em engenharia sem abrir mão de previsibilidade

## Roadmap

- Ampliar `docs/` com guias complementares além do SDLC e dos assets de marca
- Adicionar suíte de validação automatizada para comandos
- Disponibilizar templates por stack para onboarding mais rápido
- Incluir métricas de efetividade (lead time, retrabalho, custo por tarefa)

## Suporte

Para obter suporte, abra uma issue no GitHub. Relatos de bugs, solicitações de recursos e dúvidas de uso são bem-vindos.

## Licença

Este projeto está licenciado sob os termos da licença MIT. Consulte o arquivo [`LICENSE`](LICENSE) para os termos completos.

---

Se você quer IA atuando como copiloto de engenharia real, e não como gerador de snippets, este sistema foi feito para isso.