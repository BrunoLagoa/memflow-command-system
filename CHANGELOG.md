# Changelog

Todas as mudanças relevantes deste projeto serão documentadas neste arquivo.

O formato segue o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.2.0] - 2026-06-09

### Adicionado
- Novo target `claude` nos instaladores Bash e PowerShell: instalação única por projeto em `<projeto>/.claude/commands/memflow`, com `install`, `update`, `check` e `uninstall` suportados e autodiscovery por manifest.
- `src/_shared/target-adapter.claude.md` e `developer/_shared/target-adapter.claude.md`: adaptador de target dedicado para resolução normativa no Claude Code (blocos `_shared/*` e `model-policy.md` injetados inline; instalação sempre local).
- `scripts/installers/bash/targets/claude.sh` e `scripts/installers/powershell/targets/claude.ps1`: adapters que mantêm o frontmatter dos comandos, já que o Claude Code lê `description` nativamente.
- `scripts/tests/test-install-regression.sh` e `scripts/tests/test-install-regression.ps1`: cenários de regressão para o target `claude` (install/update/check/uninstall e proteção contra instalação global indevida).

### Alterado
- `scripts/manifest.schema.json`: `target` passa a aceitar `claude` no enum.
- `README.md`, `README.pt-BR.md`, `docs/INSTALL.md`, `docs/INSTALL.pt-BR.md`, `docs/QUICKSTART.md` e `docs/QUICKSTART.pt-BR.md`: documentação atualizada para incluir o target `claude`.

## [1.1.48] - 2026-06-03

### Corrigido
- `developer/context.md` e `src/context.md` (v8.3.2): substituído placeholder `(mantido)` / `(maintained)` na seção de integração MCP por regras explícitas — MCP opcional, complementar e sem bloqueio do `/context` quando ausente.
- `developer/context.md` e `src/context.md` (v8.3.3): expandido `Modo fallback` para operar em modo degradado funcional quando a memória estiver ausente, sem bloquear `/context` nem depender de Serena/MCP específico.

### Adicionado
- `scripts/tests/test-command-contracts.sh`: contrato para impedir regressão do placeholder e exigir regras de MCP opcional no `/context`.
- `scripts/tests/test-command-contracts.sh`: contrato para impedir fallback genérico no `/context` quando a memória persistente estiver ausente.

## [1.1.47] - 2026-06-03

### Corrigido
- `developer/context.md` e `src/context.md`: reforçada a regra de ativação do `/context` para executar o carregamento de contexto, memória, métricas, skills e invariantes quando invocado, sem solicitar `/context` novamente em sessão nova.
- `developer/_shared/base-preconditions.md` e `src/_shared/base-preconditions.md`: movida a exceção do `/context` para uma regra antecipada antes dos bloqueios de pré-condição, evitando falso bloqueio quando o próprio `/context` é o comando ativo.
- `src/_shared/base-preconditions.md` e `src/context.md`: corrigidas quebras de Markdown que podiam degradar a interpretação do comando por modelos menores.
- `scripts/tests/test-command-contracts.sh`: adicionados contratos para impedir regressão no comportamento de inicialização do `/context`.

## [1.1.46] - 2026-05-30

### Alterado
- `src/workflow.md`: refinado texto em inglês para melhorar consistência terminológica, clareza de instruções e legibilidade geral sem alterar a lógica de decisão do comando.

## [1.1.45] - 2026-05-30

### Alterado
- `README.md` e `README.pt-BR.md`: adicionada seção de arquitetura operacional `developer/` (fonte pt-BR) -> `src/` (distribuição EN), mantendo instaladores consumindo `src/`.
- `scripts/tests/test-command-contracts.sh` e `scripts/tests/test-doc-flow-consistency.sh`: contratos atualizados para validar comportamento em specs EN (com compatibilidade pt-BR/EN), evitando acoplamento ao idioma.

### Adicionado
- `src/**/*.md`: árvore de distribuição em inglês gerada a partir de `developer/**/*.md`, preservando estrutura e referências normativas.

## [1.1.44] - 2026-05-30

### Alterado
- `src/workflow.md` (v9.8.0): adicionada etapa obrigatória de premissas e ambiguidades, com bloqueio para dúvidas críticas e proibição de interpretação silenciosa quando houver múltiplas leituras válidas.
- `src/plan.md` (v1.2.0): planejamento reforçado com premissas explícitas antes dos passos e exigência de critérios verificáveis por etapa no formato `Passo -> verificar`.
- `src/execute.md` (v3.4.0): execução endurecida com premissas explícitas, regra de simplicidade primeiro, mudanças cirúrgicas com rastreabilidade ao pedido e loop obrigatório de validação orientado a metas.
- `src/review.md` (v2.3.0): novo critério de validação de escopo cirúrgico para detectar alterações fora do pedido.
- `src/review-code.md` (v1.3.0): adicionada seção de simplicidade e overengineering para reduzir complexidade acidental e abstrações desnecessárias.
- `src/test-plan.md` (v1.1.0): plano de testes evoluído com critério de aprovação por cenário e loop explícito de validação.

### Adicionado
- `scripts/tests/test-command-contracts.sh`: novos contratos para premissas explícitas, simplicidade, execução orientada a metas, escopo cirúrgico e loop de validação em `/test-plan`.

## [1.1.43] - 2026-05-28

### Alterado
- `src/memory-save.md` (v11.2.0): `session-memory` ampliado para 500–1000 tokens com condensação antes do save; critérios objetivos de eviction para insights (10) e sugestões (5); expiração de sugestões após 3 ignoradas consecutivas; migração automática de `quality-metrics.md` legado; schema de sugestão com `Ignoradas consecutivas` e `Status`.
- `src/memory-init.md` (v4.3.0): bootstrap de `quality-metrics.md` alinhado à estrutura completa (Execuções, KPIs, Snapshot, Observações); `decision-suggestions.md` com seção `## Arquivadas`.
- `src/workflow.md`: ignorar sugestão incrementa contador e aciona arquivamento via `/memory-save` após 3 vezes.
- `AGENTS.md`: notas de eviction, expiração de sugestões e limite de tokens atualizado.

### Adicionado
- `scripts/tests/test-command-contracts.sh`: +6 contratos para eviction, expiração de sugestões, migração legado e bootstrap alinhado (140 contratos no total).

## [1.1.42] - 2026-05-28

### Alterado
- `src/memory-save.md` (v11.1.0): resgate seletivo do v7.0.0 — lista explícita anti-poluição, padrões extras de detecção, regras de cálculo de score, exemplos por categoria, híbrido `session-memory` (300–800 tokens durante sessão + limpeza pós-save), princípio "em dúvida não salve", fallback de criação de `decisions.md`, saída enriquecida e framing de dashboard.

## [1.1.41] - 2026-05-28

### Alterado
- `src/memory-save.md` (v11.0.0): spec completo — etapas 0–13 executáveis (validação de relevância, detecção de decisões, score alinhado ao `/execute`, schema de `decisions.md`, lifecycle de score com reforço/contradição/arquivamento, gate de confirmação obrigatório, limpeza de `session-memory.md`, registro de métricas pós-review, geração de insights e sugestões com controles de crescimento, formato de saída padronizado).
- `src/memory-init.md` (v4.2.0): bootstrap passa a criar `decision-suggestions.md` junto com os demais arquivos de memória.

### Adicionado
- `scripts/tests/test-command-contracts.sh`: 13 contratos específicos para `/memory-save` (confirmação, score, anti-duplicação, integração com review, limpeza de session-memory, bootstrap de decision-suggestions).
- `docs/examples/04-memoria-e-memory-save.md`: quatro cenários de memória (primeira sessão, decisão nova, reforço, trivial sem save) e ciclo review → métricas → próxima sessão.

## [1.1.40] - 2026-05-28

### Adicionado
- `scripts/tests/test-command-contracts.sh`: suíte comportamental com 116 contratos — frontmatter global (name, license, version, base-refs) para todos os 15 comandos executáveis; invariantes por comando: HARD-GATE do `/brainstorm`, bloqueio do `/execute` sem decisão do `/workflow`, saída binária do `/review-enforce-rules`, ausência de correção no `/debug`, gate de salvamento em `/prd`, `/spec`, `/plan` e `/brainstorm`, e invariantes anti-compaction em `/context` e `/workflow`.
- `.github/workflows/install-regression.yml`: execução do `test-command-contracts.sh` no pipeline de CI.
- `docs/examples/01-nova-feature.md`: exemplo ponta a ponta de nova feature (dark mode) com fluxo `/context` → `/workflow` → `/plan` → `/execute` → `/memory-save` → `/review` → `/review-code`.
- `docs/examples/02-correcao-bug.md`: exemplo ponta a ponta de correção de bug (login silencioso) com fluxo `/context` → `/workflow` → `/debug` → `/execute` → `/review-code` → `/memory-save`.
- `docs/examples/03-feature-complexa-com-brainstorm.md`: exemplo ponta a ponta de feature complexa (sistema de notificações) com fluxo `/context` → `/workflow` → `/brainstorm` → `/spec` → `/plan` → `/execute` → `/memory-save` → `/review` → `/review-enforce-rules`.
- `docs/QUICKSTART.md`: guia "First 10 minutes with Memflow" em inglês — install, memory-init, primeira sessão, modelo mental e tabela de fluxos por cenário.
- `docs/QUICKSTART.pt-BR.md`: versão pt-BR do quickstart — "Primeiros 10 minutos com Memflow".

### Alterado
- `README.md` e `README.pt-BR.md`: links para quickstart e exemplos adicionados no Quick start e na tabela de documentação; itens do Roadmap já entregues removidos.

## [1.1.39] - 2026-05-28

### Alterado
- `src/brainstorm.md` (v1.3.0): evolução completa do comando — HARD-GATE anti-bypass, processo em 4 fases conversacionais, diálogo estruturado com opções selecionáveis, auto-revisão (4 checks), gate de salvamento, subseção `Design proposto`, política de modelo, decomposição em sub-projetos, recursos visuais opcionais e handoff explícito para `/prd`, `/spec` ou `/plan`.
- `src/workflow.md` (v9.7.0): integração de `/brainstorm` na decisão de execução — critérios de `EXPLORAR COM /brainstorm`, ajustes por insights, campo `Exploração` na estratégia e encadeamento nos próximos passos.
- `src/model-policy.md`: inclusão de `/brainstorm` no fluxo ideal e regras de modelo por fase.
- `docs/SDLC.md` e `docs/SDLC.pt-BR.md`: nova etapa 0 (Exploração) com `/brainstorm` e fluxo SDLC atualizado.
- `README.md` e `README.pt-BR.md`: diagrama de fluxo, diferencial de exploração estruturada, exemplo com `/brainstorm`, tabela de workflow e link para spec do comando.
- `AGENTS.md`: notas de integração `/workflow` → `/brainstorm` e regra de sync de docs para mudanças de comportamento de comandos.

### Adicionado
- `scripts/tests/test-doc-flow-consistency.sh`: asserts de consistência para `/brainstorm` em README, workflow e SDLC.

## [1.1.38] - 2026-05-27

### Alterado
- `README.md` e `README.pt-BR.md`: reestruturação completa com foco em onboarding — nova tagline, seção "Why/Por que Memflow?" narrativa, diagrama visual do fluxo, tabelas escaneáveis para comandos de orquestração e capacidades, e instalação simplificada apenas com o modo interativo (Quick start).
- `README.md` e `README.pt-BR.md`: redução de ~480 para ~190 linhas movendo detalhes técnicos avançados para `docs/INSTALL.*.md`.

### Adicionado
- `docs/INSTALL.md` e `docs/INSTALL.pt-BR.md`: guia avançado de instalação cobrindo instalação não-interativa por target, update, check, uninstall, escopo por target, destinos de instalação e bootstrap reproduzível (`MEMFLOW_REF`).

## [1.1.37] - 2026-05-09

### Alterado
- `src/workflow.md`: adicionada regra para tratar decisões pendentes em `Próximos passos` com diálogo estruturado de opções selecionáveis, incluindo repetição em caso de ambiguidade e opção `Outra` com detalhamento complementar.

## [1.1.36] - 2026-05-09

### Alterado
- `src/workflow.md`: removida a responsabilidade de conduzir confirmação de salvamento para `/prd`, `/spec` e `/plan`, mantendo o workflow focado na decisão de estratégia e validação.

## [1.1.35] - 2026-05-09

### Alterado
- `src/workflow.md`: confirmação de salvamento para `/prd`, `/spec` e `/plan` detalhada para exigir diálogo estruturado de opções selecionáveis (sem texto livre), incluindo repetição no mesmo formato em caso de ambiguidade.
- `src/prd.md` e `src/spec.md`: seção de confirmação de salvamento alinhada ao mesmo padrão de diálogo estruturado com opções selecionáveis e repetição consistente quando necessário.
- `README.md` e `README.pt-BR.md`: documentação sincronizada com o comportamento de confirmação via diálogo de seleção para geração de artefatos documentais.

## [1.1.34] - 2026-05-09

### Alterado
- `src/plan.md`: seção final de recomendação de modelos evoluída para exigir `nível recomendado`, `modelo principal`, `2-3 alternativas do mesmo nível` e critérios explícitos de fallback (indisponibilidade/cota/latência), reduzindo viés de opção única no plano.
- `src/model-policy.md`: política de fallback ampliada para cobrir indisponibilidade e degradação operacional (cota/latência), mantendo prioridade por alternativas no mesmo nível antes de escalada.
- `README.md` e `README.pt-BR.md`: adicionada seção explícita de convenção de commits com referência ao Conventional Commits 1.0.0 e tipos permitidos no projeto.

### Adicionado
- `.github/workflows/commit-convention.yml`: novo workflow de CI para validar mensagens de commit em PRs e pushes na `main`.
- `scripts/tests/test-conventional-commits.sh`: validação automatizada do padrão Conventional Commits para commits sem merge no range da execução.

## [1.1.33] - 2026-05-08

### Alterado
- `README.pt-BR.md`: documentação sincronizada com o comportamento de plano vivo para `/plan` salvo, incluindo sizing dinâmico, checkpoints e marcadores `[P]/[S]`.

## [1.1.32] - 2026-05-08

### Alterado
- `src/workflow.md`: limite de sugestões em modo assistido evoluído de fixo para dinâmico por complexidade/risco (`2`, `3` ou `4`) com priorização por impacto e confiança.
- `src/plan.md`: planejamento reforçado com sizing dinâmico obrigatório de tarefas, regra de não reutilizar quantidade fixa entre planos e checklist de granularidade executável.
- `src/plan.md` e `src/execute.md`: integração de **plano vivo** para planos salvos em `.md`, com atualização obrigatória de checklist/checkpoint durante execução e retomada segura após interrupção.
- `src/plan.md` e `src/execute.md`: padronização de status (`[ ]`, `[-]`, `[x]`, `[!]`), consistência pai/subtarefas, ordem de atualização top-down e protocolo de desbloqueio para itens bloqueados.
- `src/plan.md` e `src/execute.md`: adição de marcador de modo de execução por tarefa (`[P]` paralelizável, `[S]` sequencial) com critérios explícitos para paralelização.
- `README.md`: documentação sincronizada com o comportamento de plano vivo para `/plan` salvo, incluindo sizing dinâmico, checkpoints e marcadores `[P]/[S]`.

## [1.1.31] - 2026-05-08

### Alterado
- `src/_shared/base-preconditions.md`: adicionado checklist compartilhado de continuidade segura (decisão do `/workflow`, invariantes válidos e confirmação explícita do usuário).
- `src/review-code.md`: formato de saída normalizado para pt-BR e alinhado ao padrão base (`Status`, `Análise`, `Problemas`, `Próximos passos`).

## [1.1.30] - 2026-05-08

### Alterado
- `src/plan.md`, `src/spec.md` e `src/prd.md`: inclusão de etapa obrigatória de confirmação de salvamento antes de gerar o documento, com opções explícitas ao usuário (salvar ou apenas mostrar no chat), bloqueio por resposta ambígua e registro da decisão na saída.
- `src/workflow.md`: orquestração atualizada para exigir e sinalizar a confirmação de salvamento como pré-requisito quando o próximo passo envolver `/prd`, `/spec` ou `/plan`.
- `src/context.md` e `src/workflow.md`: fluxo reforçado para detectar skills disponíveis no projeto, sinalizar skills aplicáveis no contexto e exigir seu uso quando necessário antes da continuidade.
- `src/_shared/base-output.md`, `src/context.md` e `src/workflow.md`: adicionado gate anti-compaction com re-hidratação obrigatória de invariantes (idioma pt-BR + identidade Memflow) e bloqueio do workflow quando invariantes falharem.
- `src/_shared/base-preconditions.md`: pré-condições globais endurecidas para bloquear comandos críticos quando invariantes anti-compaction (pt-BR + Memflow) não estiverem válidos.
- `src/execute.md`, `src/review.md`, `src/review-code.md` e `src/review-enforce-rules.md`: validações anti-bypass reforçadas para impedir continuidade sem invariantes válidos e exigir confirmação explícita do usuário antes de qualquer próximo comando.
- `README.md` e `README.pt-BR.md`: documentação sincronizada com a nova política de confirmação prévia para geração de artefatos documentais.

## [1.1.29] - 2026-04-30

### Alterado
- `scripts/install.sh`: fallback interno de bootstrap alinhado para exibir título do banner com versão no wizard, mantendo consistência com o fluxo que carrega `lib/common.sh`.
- `scripts/installers/bash/targets/cursor.sh` e `scripts/installers/powershell/targets/cursor.ps1`: geração de comandos Cursor ajustada para remover frontmatter de topo e promover `description` como primeira linha visível, evitando `---` como descrição na lista de comandos do Cursor.
- `README.md` e `README.pt-BR.md`: documentação sincronizada com os comportamentos atuais do wizard (versão exibida) e da geração de comandos Cursor sem frontmatter no topo.

## [1.1.28] - 2026-04-30

### Alterado
- `scripts/lib/common.sh` e `scripts/lib/common.ps1`: banner do wizard atualizado para aceitar título customizado e exibir a versão do instalador no topo.
- `scripts/installers/bash/core.sh` e `scripts/installers/powershell/core.ps1`: detecção de versão para o wizard adicionada com fallback seguro (`MEMFLOW_REF` tag -> `CHANGELOG.md` local -> latest release -> `MEMFLOW`) e exibição em formato `MEMFLOW vX.Y.Z`.
- `scripts/install.ps1`: fallback interno de `Show-MemflowBanner` alinhado ao novo formato com título customizado.

## [1.1.27] - 2026-04-30

### Alterado
- `scripts/install.sh`, `scripts/install.ps1`, `scripts/installers/bash/*` e `scripts/installers/powershell/*`: novo target `cursor` adicionado ao instalador com suporte local-only em `.cursor/commands/memflow`, incluindo fluxo de `install`, `update`, `check` e `uninstall`.
- `scripts/installers/bash/targets/cursor.sh` e `scripts/installers/powershell/targets/cursor.ps1`: geração de comandos Cursor alinhada ao padrão OpenCode, com injeção de `_shared/*.md` e `model-policy.md` diretamente nos arquivos finais.
- `scripts/manifest.schema.json`: enum de `target` ampliado para aceitar `cursor`.
- `scripts/tests/test-install-regression.sh` e `scripts/tests/test-install-regression.ps1`: regressão expandida para cobrir cenários `cursor` (ausência de instalação, instalação local, update/check e remoção).
- `README.md` e `README.pt-BR.md`: documentação atualizada com `cursor` no escopo por target, exemplos de instalação e destinos, além de reordenação da seção de suporte deixando `Antigravity` por último.

## [1.1.26] - 2026-04-29

### Alterado
- `scripts/install.ps1`: carregamento de módulos PowerShell ajustado para dot-source no escopo do script, garantindo disponibilidade estável de funções como `Resolve-WizardValues` em execuções Windows CI.
- `scripts/installers/powershell/core.ps1`: resolução de SO em modo não interativo reforçada com fallback compatível entre PowerShell 5.1 e PowerShell 7+ (`Resolve-DefaultOsName`).
- `scripts/tests/test-install-regression.ps1`: runner de regressão atualizado para preferir `pwsh` (com fallback), reduzindo divergência de host no job Windows e melhorando diagnóstico em falhas.
- `scripts/installers/bash/targets/vscode.sh`, `scripts/installers/powershell/targets/vscode.ps1`, `scripts/tests/test-vscode-prompt-generation.sh`, `src/_shared/target-adapter.vscode.md` e comandos em `src/*.md`: geração VSCode atualizada para injetar `model-policy.md` no mesmo mecanismo das bases `_shared`, removendo a geração do arquivo dedicado `memflow.model-policy.prompt.md`.
- `scripts/installers/bash/targets/opencode.sh` e `scripts/installers/powershell/targets/opencode.ps1`: instalação OpenCode (`global` e `local`) passa a gerar apenas comandos executáveis com injeção de `_shared/*.md` e `model-policy.md`, sem copiar arquivos de referência standalone para o destino.
- `scripts/tests/test-install-regression.sh`: cobertura ampliada para validar no OpenCode a ausência de `_shared/` e `model-policy.md` no destino instalado e a presença dos blocos injetados nos comandos.
- `src/_shared/target-adapter.md`: contrato normativo atualizado para aceitar bases injetadas no próprio comando nos artefatos OpenCode gerados pelo instalador.
- `README.md` e `README.pt-BR.md`: documentação de `vscode` e `opencode` atualizada para refletir distribuição de comandos finais com conteúdo normativo injetado.

## [1.1.25] - 2026-04-20

### Alterado
- `src/workflow.md`, `src/execute.md`, `src/review.md` e `src/review-enforce-rules.md`: fluxo unificado para exigir decisão explícita do `/workflow` antes de `/execute`, removendo fallback local de estratégia e reforçando validação anti-bypass.
- `src/context.md`, `src/memory-init.md` e `src/_shared/base-preconditions.md`: contrato de memória harmonizado com `quality-metrics.md`, ordem canônica de inicialização (`/memory-init` -> `/context` -> comandos operacionais) e continuidade de bootstrap via `/context`.
- `src/_shared/base-output.md`, `src/_shared/base-degraded-mode.md`, `src/_shared/target-adapter.md` e `src/_shared/target-adapter.vscode.md`: precedência refinada com invariantes não sobrescrevíveis para reduzir ambiguidade entre bases compartilhadas e comandos específicos.
- `README.md` e `README.pt-BR.md`: fluxo público atualizado com `/review-code`, documentação de bootstrap remoto (`main`) versus versão instalada (release tag) e exemplo de pin com `MEMFLOW_REF`.
- `scripts/installers/bash/core.sh`, `scripts/installers/powershell/core.ps1` e `scripts/installers/powershell/actions.ps1`: robustez e paridade cross-platform aprimoradas (detecção de SO em modo não interativo, fallback interativo de `update` sem instalação no PowerShell e mensagens de atualização alinhadas aos scripts remotos).
- `scripts/manifest.schema.json`: schema endurecido com `os` obrigatório, `installedAt` em `date-time` e bloqueio de propriedades adicionais não previstas.
- `scripts/tests/test-install-regression.sh`: cobertura ampliada para casos críticos (`check` silencioso e validação de `--project-dir` em update local), com isolamento de logs temporários por execução.
- `.github/workflows/install-regression.yml`: CI expandido com job Linux (regressões + consistência docs/fluxo + smoke VSCode) e job Windows para regressão PowerShell.

### Adicionado
- `.github/workflows/release.yml`: automação de release por tag (`v*`) com gate de consistência tag/changelog e publicação automática usando notas extraídas da seção correspondente do `CHANGELOG.md`.
- `scripts/tests/test-install-regression.ps1`: suíte de regressão dedicada ao instalador PowerShell.
- `scripts/tests/test-doc-flow-consistency.sh`: validação automática de consistência entre fluxo público documentado e comandos normativos.
- `scripts/tests/test-vscode-prompt-generation.sh`: smoke/regressão de geração de prompts `vscode` com verificação de injeção de bases compartilhadas.

## [1.1.24] - 2026-04-20

### Alterado
- `src/workflow.md`: terminologia atualizada na camada de métricas de aprovação para manter consistência entre recomendação, status e critérios de aceite no fluxo.
- `src/brainstorm.md`: reforço do gate de aprovação antes de `/plan`, inclusão de critérios de prontidão (DoD), novas subseções obrigatórias de análise (premissas/lacunas, critérios de sucesso e opções rejeitadas) e padronização fechada de valores para `Status`.

## [1.1.23] - 2026-04-18

### Alterado
- `src/_shared/base-preconditions.md`: regra de resolução normativa reforçada para impedir solicitação de confirmação manual de caminhos quando o comando ativo já está carregado no target.
- `src/brainstorm.md`: adicionada restrição explícita para não pedir confirmação de localização de arquivos normativos durante execução normal do comando.

## [1.1.22] - 2026-04-18

### Alterado
- `README.md` e `README.pt-BR.md`: documentação atualizada para explicitar que, no runtime de comandos `opencode`, a resolução normativa detecta automaticamente o escopo (`global` vs `local`) pela raiz do comando ativo antes da descoberta por caminhos oficiais.

## [1.1.21] - 2026-04-18

### Alterado
- `src/_shared/target-adapter.md`: adicionada regra obrigatória de detecção automática do escopo de instalação (`global` vs `local`) a partir do diretório do comando em execução, com resolução normativa relativa à raiz detectada e sem solicitar confirmação manual ao usuário quando essa detecção for possível.

## [1.1.20] - 2026-04-18

### Alterado
- `src/context.md`: fluxo de carregamento de contexto evoluído para interpretação de métricas e sinais estratégicos, com priorização de memória e refinamento do modo ultra-light.
- `src/execute.md`: integração reforçada com `/review-code` e persistência inteligente pós-execução, com foco em fechamento de ciclo de qualidade.
- `src/review.md`: validação de governança consolidada com classificação de problemas por severidade e direcionamento explícito para `/review-code`.
- `src/review-code.md`: novo comando de validação técnica profunda da implementação (aderência ao SPEC/PLAN, arquitetura, testes, segurança e readiness de produção).
- `src/memory-save.md`: expansão do pipeline de persistência com métricas, insights, sugestões de decisão e controles de crescimento/deduplicação.
- `src/workflow.md`: orquestração ampliada para decisões baseadas em métricas, insights e sugestões assistidas, com regras de prioridade, limites de ativação e loop de aplicação rastreável.

## [1.1.19] - 2026-04-18

### Alterado
- `src/prd.md`: critérios de aceite por história (seção 4) vs critérios de nível PRD/release (seção 11); fase de ambiguidade com opções e bloqueio até decisão do usuário; metadados v2.1.0.
- `src/spec.md`: especificação técnica ampliada (contratos entrada/saída, estados/erros, fluxos, modelo de dados, integração com `/plan`, ambiguidade técnica com opções); metadados v2.1.1; seções 8 e 9 com escopos explícitos (modelo de dados vs garantias operacionais) e distinção entre invariantes estruturais e de comportamento.

## [1.1.18] - 2026-04-18

### Alterado
- `src/_shared/base-output.md`: regra explícita de que `## Próximos passos` é o último `##` da resposta e que a continuidade do fluxo não usa linhas `Próximo passo:` fora dessa seção.
- `src/review-enforce-rules.md`: `## Formato obrigatório de saída` passa ao fim do arquivo (após base de validação, verificações e critérios), para o template normativo encerrar com **Próximos passos** como última seção descrita.
- `src/brainstorm.md`: `## Produza` antecede `## Formato obrigatório de saída`, evitando qualquer `##` adicional após a definição do bloco de saída.
- `src/context.md`: norma de continuidade apenas em `## Próximos passos`; remoção de bullets redundantes em ultra-light, Resumo e Estado do fluxo.
- `src/execute.md`: bloqueio por ausência de plano descreve a continuidade via seção **Próximos passos** em vez de bullet `Próximo passo:`.

## [1.1.17] - 2026-04-17

### Alterado
- `src/_shared/base-output.md`: `## Regras de uso` antecede o bloco Status → Análise → Problemas → Próximos passos, deixando `## Próximos passos` como última seção do template normativo.
- Comandos em `src/*.md`: alinhamento do formato de saída para que `## Próximos passos` seja sempre a última seção `##` da resposta — metas (`## Importante`, `## Boas práticas`, `## Regras` onde aplicável) e critérios passam a preceder `## Formato obrigatório de saída`; onde havia conteúdo de saída após Próximos passos (ex.: modelo no plano, persistência/bloqueios no execute), esse conteúdo foi reordenado para antes de `## Próximos passos`.
- `src/review-enforce-rules.md`: removida duplicação de modelo de `## Problemas` / `## Próximos passos` no fim do arquivo; detalhe incorporado ao bloco de formato obrigatório.
- `src/brainstorm.md`: `## Regras específicas` e `## Importante` antes do formato; `## Final` removido com orientação fundida em **Próximos passos**.

## [1.1.16] - 2026-04-17

### Alterado
- `src/workflow.md`: no formato obrigatório de saída, a seção `## Próximos passos` passa a aparecer após `## Estratégia de execução` (depois de modelo e estratégia, antes de `## Regras`).

## [1.1.15] - 2026-04-17

### Alterado
- `src/context.md` e `src/memory-init.md`: referências normativas em lazy load passaram a usar resolução pelo target ativo via `_shared/target-adapter.md`, removendo caminho hardcoded de OpenCode.
- `src/memory-init.md`: seção "Sistema de comandos" atualizada para descrever diretório normativo de forma agnóstica ao target.

## [1.1.14] - 2026-04-17

### Alterado
- `src/_shared/base-preconditions.md` e `src/_shared/base-degraded-mode.md`: regras comportamentais tornadas agnósticas de target, com resolução delegada ao adaptador.
- `src/_shared/target-adapter.md` e `src/_shared/target-adapter.vscode.md`: novos adaptadores de resolução normativa por target (`opencode` e `vscode`).
- `src/*.md`: referências normativas comuns atualizadas para usar `_shared/base-*` + `_shared/target-adapter.md`, removendo paths OpenCode hardcoded dos comandos.
- `src/execute.md`, `src/plan.md`, `src/review.md`, `src/review-enforce-rules.md`, `src/refactor.md`, `src/debug.md` e `src/workflow.md`: referências de `model-policy.md` migradas para resolução por target via adaptador compartilhado.
- `scripts/installers/bash/targets/vscode.sh` e `scripts/installers/powershell/targets/vscode.ps1`: renderização de prompts VSCode atualizada para injetar `target-adapter.vscode.md` quando houver referência a `target-adapter.md`.
- `README.md` e `README.pt-BR.md`: documentação de `_shared` e do fluxo de geração VSCode atualizada para refletir a arquitetura núcleo + adaptador de target.

## [1.1.13] - 2026-04-17

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: target `vscode` agora usa instalação única por projeto gerando apenas prompt files em `.github/prompts` (sem geração de `.github/agents`), sem divisão entre escopos `global` e `local`.
- `scripts/install.sh` e `scripts/install.ps1`: para `vscode`, referências de caminhos `.../_shared/...` nos comandos agora são substituídas pelo conteúdo real das bases compartilhadas durante a geração dos `.prompt.md`.
- `scripts/install.sh` e `scripts/install.ps1`: descoberta sem escopo agora permite filtrar por target explícito (`--target` / `-Target`) e mantém comportamento padrão quando não informado.
- `scripts/install.sh` e `scripts/install.ps1`: arquitetura interna refatorada para módulos por domínio/target/ação (`scripts/installers/bash/*` e `scripts/installers/powershell/*`), mantendo a interface de CLI.
- `scripts/installers/bash/actions.sh` e `scripts/installers/powershell/actions.ps1`: ações passaram a atuar como dispatcher fino, delegando a implementação para módulos dedicados por target.
- `scripts/installers/bash/targets/*` e `scripts/installers/powershell/targets/*`: separação forte de `opencode` e `vscode` com arquivos independentes por target.
- `scripts/memflowctl` e `scripts/memflowctl.ps1`: download remoto atualizado para buscar também os módulos do instalador, preservando execução via bootstrap remoto.
- `scripts/manifest.schema.json`: `target.enum` ampliado para aceitar `vscode`.
- `scripts/tests/test-install-regression.sh`: cobertura atualizada para fluxo único de `vscode` (install/update/check/uninstall e ausência de instalação), garantindo que não exista instalação global para esse target.
- `README.md` e `README.pt-BR.md`: documentação atualizada para refletir o modelo único de instalação no `vscode`.

## [1.1.12] - 2026-04-17

### Alterado
- `src/execute.md` e `src/review.md`: check silencioso de atualização passou a orientar somente comandos remotos (`install.sh`/`install.ps1`) para eliminar dependência de `memflowctl` no ambiente.

## [1.1.11] - 2026-04-17

### Alterado
- `src/workflow.md`: saída obrigatória de recomendação de modelo passou a incluir nível, modelo principal, alternativas do mesmo nível e regra explícita de fallback por disponibilidade.
- `src/model-policy.md`: política de seleção operacional atualizada para formalizar o padrão "1 modelo principal + alternativas do mesmo nível", com fallback intra-nível antes de escalada.
- `README.md` e `README.pt-BR.md`: documentação de diferenciais e arquitetura ajustada para refletir seleção de modelo com principal e alternativas.

## [1.1.10] - 2026-04-16

### Corrigido
- `src/*.md`: atualização das referências normativas para o novo namespace `commands/memflow`, incluindo `_shared` e `model-policy.md`.
- `src/*.md`: instruções de resolução de caminhos ajustadas para considerar explicitamente os dois escopos oficiais (`global` e `local`) sem fallback fora dos caminhos definidos.

## [1.1.9] - 2026-04-16

### Adicionado
- `README.pt-BR.md`: variante em português com seletor de idioma e paridade estrutural com a versão padrão.
- `docs/SDLC.pt-BR.md`: variante em português do guia SDLC com seletor de idioma e links cruzados.
- `AGENTS.md`: instruções compactas para sessões OpenCode, com comandos de verificação, layout de alto valor e quirks do instalador.

### Alterado
- `README.md`: passou a ser a versão padrão em inglês, com seletor de idioma e seção de documentação apontando para SDLC em inglês e português.
- `docs/SDLC.md`: passou a ser a versão padrão em inglês, mantendo estrutura e comandos do conteúdo original.

### Adicionado
- `README.md`: seção **Check de versão** documentada com comando geral (macOS/Linux e PowerShell) logo após **Atualizar para nova versão**.
- `scripts/tests/test-install-regression.sh`: cobertura para `check` sem escopo nos cenários com instalações em `global`+`local` e `global-only`.

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: `update` sem `--scope` / `-Scope` agora processa automaticamente os dois escopos (`global` e `local`) quando ambos tiverem instalação detectada por manifest.
- `scripts/install.sh` e `scripts/install.ps1`: `uninstall` sem `--scope` / `-Scope` agora remove automaticamente os dois escopos (`global` e `local`) quando ambos estiverem instalados.
- `scripts/install.sh` e `scripts/install.ps1`: `check` sem `--scope` / `-Scope` agora avalia automaticamente os dois escopos (`global` e `local`) quando ambos tiverem instalação detectada por manifest.
- `README.md`: documentação de descoberta automática em `update`/`check`/`uninstall` atualizada para refletir execução em múltiplos escopos com comando geral único.

## [1.1.7] - 2026-04-16

### Corrigido
- `src/model-policy.md`: frontmatter corrigido para o contexto correto de política de modelos (`description`, `hidden` e metadados), alinhando o arquivo ao padrão das bases compartilhadas não executáveis.

## [1.1.6] - 2026-04-16

### Alterado
- `README.md`: seção **Instalação não interativa** em macOS/Linux atualizada para one-liners remotos com `curl -fsSL ... | bash -s -- install`, tanto no escopo `global` quanto `local`, mantendo `--target opencode`.

## [1.1.5] - 2026-04-16

### Alterado
- `README.md`: seção **Remover instalação** refatorada para adotar o mesmo padrão operacional de instalação/update, com exemplos remotos (`curl -fsSL ...` e `powershell -ExecutionPolicy Bypass -Command ...`) para escopos global e local em macOS/Linux e PowerShell.

### Removido
- Exemplos locais legados de `uninstall` via `memflowctl` e execução direta de scripts no repositório, em favor de one-liners remotos padronizados.

## [1.1.4] - 2026-04-16

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: mensagens de atualização passaram a exibir versão instalada e versão disponível no mesmo texto (`Atual: ... | Disponível: ...`) para melhorar clareza operacional.
- `scripts/install.sh` e `scripts/install.ps1`: mensagem de estado atualizado simplificada para `MEMFLOW já está atualizado (...)`.

### Removido
- Linha de saída `Próximos passos: /context e /workflow` após instalação concluída, reduzindo ruído no output dos instaladores.

## [1.1.3] - 2026-04-16

### Adicionado
- Teste de regressão do instalador em `scripts/tests/test-install-regression.sh`, cobrindo cenários de `update`/`uninstall` sem instalação e validação de código de saída `2`.
- Workflow de CI `.github/workflows/install-regression.yml` para executar automaticamente a regressão do instalador em `push`, `pull_request` e execução manual.

### Alterado
- Organização de testes em `scripts/tests/`, removendo o caminho legado `scripts/test/`.
- `README.md`: documentação de comportamento para `update` sem instalação prévia (modo interativo vs não interativo) e semântica de erro no `uninstall`.

### Corrigido
- `scripts/install.sh`: `update` agora informa ausência de instalação e, em modo interativo, pergunta se deve iniciar uma nova instalação; em modo não interativo, retorna erro explícito com código `2`.
- `scripts/install.sh`: `uninstall` agora retorna erro explícito com código `2` quando não houver instalação no escopo solicitado.
- `scripts/install.ps1`: alinhamento de `update`/`uninstall` com comportamento consistente de ausência de instalação, incluindo erro explícito com código `2` e fallback interativo para nova instalação no `update`.

## [1.1.2] - 2026-04-16

### Adicionado
- `README.md`: subseção **Escopo global vs local** (`--scope` / `--project-dir`), remissões em instalação não interativa, `memflowctl`, desinstalação e destinos; exemplos de `update` remoto com descoberta automática de escopo (sem `--scope` / `-Scope`).

### Corrigido
- `update` em `scripts/install.sh`: quando o usuário não passa `--scope`, o escopo passa a ser inferido do manifest (`.memflow-install.json`) em vez de ficar preso ao padrão `global`.
- `update` em `scripts/install.ps1`: busca do manifest quando `-Scope` não é informado; escopo e SO efetivos derivados do manifest; mensagem clara quando não existe instalação MEMFLOW.

## [1.1.1] - 2026-04-16

### Adicionado
- Arquivo `CHANGELOG.md` com histórico consolidado das versões publicadas.
- Registro retroativo das mudanças de `v1.0.0` e `v1.1.0` para manter rastreabilidade de releases.

### Alterado
- Processo de release passa a incluir atualização obrigatória do changelog.

## [1.1.0] - 2026-04-16

### Adicionado
- Ação `check` nos instaladores `scripts/install.sh` e `scripts/install.ps1` para consultar atualização sem alterar a instalação.
- Cache de 24h para consulta de versão mais recente, com saída silenciosa quando não houver update.
- Entrypoints `scripts/memflowctl` e `scripts/memflowctl.ps1` para executar `install`, `update`, `uninstall` e `check` fora do diretório do repositório.
- Orientação de fluxo em `src/review.md` e fallback em `src/execute.md` para check silencioso de versão ao final.

### Alterado
- Mensagens de update passam a sugerir comando desacoplado (`memflowctl`) com `--non-interactive` e `scope` correto.
- `README.md` atualizado com exemplos completos de operação `global` e `local` para instalação, update, check e uninstall.

### Corrigido
- `update`/`uninstall` no escopo local agora exigem `--project-dir` (`-ProjectDir` no PowerShell) quando necessário, reduzindo risco operacional.
- Fluxo de update evita tentativa de atualização quando a versão instalada já é a mais recente.

### Removido
- `logo.png` na raiz do repositório (asset obsoleto).

## [1.0.0] - 2026-04-16

### Adicionado
- Estrutura inicial do `memflow-command-system`.
- Workflow base por comandos em `src/` para contexto, decisão, execução e validação (`/context`, `/workflow`, `/execute`, `/review`, `/review-enforce-rules`).
- Instalador cross-platform com fluxo interativo para Bash e PowerShell.

### Alterado
- Wizard do instalador com prompts e onboarding refinados.
- Seção de roadmap da documentação ampliada.

[1.2.0]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.48...v1.2.0
[1.1.48]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.47...v1.1.48
[1.1.47]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.46...v1.1.47
[1.1.46]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.45...v1.1.46
[1.1.45]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.44...v1.1.45
[1.1.44]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.43...v1.1.44
[1.1.43]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.42...v1.1.43
[1.1.42]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.41...v1.1.42
[1.1.41]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.40...v1.1.41
[1.1.40]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.39...v1.1.40
[1.1.39]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.38...v1.1.39
[1.1.38]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.37...v1.1.38
[1.1.37]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.36...v1.1.37
[1.1.36]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.35...v1.1.36
[1.1.35]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.34...v1.1.35
[1.1.34]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.33...v1.1.34
[1.1.33]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.32...v1.1.33
[1.1.32]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.31...v1.1.32
[1.1.31]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.30...v1.1.31
[1.1.30]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.29...v1.1.30
[1.1.29]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.28...v1.1.29
[1.1.28]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.27...v1.1.28
[1.1.27]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.26...v1.1.27
[1.1.26]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.25...v1.1.26
[1.1.25]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.24...v1.1.25
[1.1.24]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.23...v1.1.24
[1.1.23]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.22...v1.1.23
[1.1.22]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.21...v1.1.22
[1.1.21]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.20...v1.1.21
[1.1.20]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.19...v1.1.20
[1.1.19]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.18...v1.1.19
[1.1.18]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.17...v1.1.18
[1.1.17]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.16...v1.1.17
[1.1.16]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.15...v1.1.16
[1.1.15]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.14...v1.1.15
[1.1.14]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.13...v1.1.14
[1.1.13]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.12...v1.1.13
[1.1.12]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.11...v1.1.12
[1.1.11]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.10...v1.1.11
[1.1.10]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.9...v1.1.10
[1.1.9]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.7...v1.1.9
[1.1.7]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.6...v1.1.7
[1.1.6]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/BrunoLagoa/memflow-command-system/releases/tag/v1.0.0
