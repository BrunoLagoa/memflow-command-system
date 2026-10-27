---
name: refactor
description: Analisa e propõe refatoração de código com vocabulário de módulos profundos (módulo, interface, profundidade, seam, adaptador, alavancagem, localidade) — identifica módulos rasos, duplicação, baixa legibilidade e violações de padrões, aplica o teste de deleção e apresenta oportunidades de aprofundamento priorizadas. Classifica risco (Baixo/Médio/Alto). Não aplica mudanças automaticamente; aguarda confirmação explícita. Saída: Status (Análise concluída/Bloqueado), diagnóstico e proposta de mudanças. Bloqueia execução se risco Alto sem confirmação.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.1.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Refatorar código:

- mantendo comportamento funcional
- melhorando qualidade, legibilidade e estrutura
- aprofundando módulos rasos para ganhar testabilidade e navegabilidade por agentes
- respeitando `.agents` e `docs`

---

## Regras obrigatórias

1. Seguir obrigatoriamente:
   - `.agents` (padrões técnicos e segurança)
   - `docs` (comportamento esperado)
   - `.agents/domain/GLOSSARY.md` para nomear módulos e ADRs da área (decisões que não devem ser reabertas sem motivo)

2. NÃO alterar comportamento funcional sem aviso explícito

3. NÃO introduzir nova arquitetura sem validação

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou avançado
- priorizar qualidade de análise e segurança da refatoração
- seguir `model-policy.md` resolvido pelo target ativo (via `_shared/target-adapter.md`)

---

## Vocabulário de design (usar exatamente)

- **Módulo:** qualquer coisa com interface e implementação (função, classe, pacote, fatia vertical). _Evitar_: componente, serviço, unidade.
- **Interface:** tudo que quem chama precisa saber para usar o módulo corretamente — assinatura, invariantes, ordem de chamadas, modos de erro, configuração, características de performance. _Evitar_: API, assinatura.
- **Implementação:** o corpo de código dentro do módulo.
- **Profundidade:** alavancagem na interface — quanto comportamento quem chama (ou o teste) exercita por unidade de interface aprendida. **Profundo** = muito comportamento atrás de interface pequena; **raso** = interface quase tão complexa quanto a implementação.
- **Seam:** lugar onde o comportamento pode ser alterado sem editar ali; onde a interface do módulo vive. _Evitar_: limite, boundary.
- **Adaptador:** algo concreto que satisfaz uma interface em um seam (papel, não conteúdo).
- **Alavancagem:** o que quem chama ganha com a profundidade.
- **Localidade:** o que quem mantém ganha com a profundidade — mudança, bugs e verificação concentrados em um lugar.

---

## Princípios

- **Profundidade é propriedade da interface**, não da implementação; um módulo profundo pode ter partes internas pequenas e substituíveis (seams internos).
- **Teste de deleção:** imagine apagar o módulo. Se a complexidade some, era repasse; se reaparece espalhada por N chamadores, ele se pagava.
- **A interface é a superfície de teste:** chamadores e testes cruzam o mesmo seam; querer testar "por trás" da interface indica módulo no formato errado.
- **Um adaptador = seam hipotético; dois adaptadores = seam real.** Não criar seam sem algo que realmente varie através dele.
- Preferir: aceitar dependências em vez de criá-las; retornar resultados em vez de produzir efeitos colaterais; interface pequena.

---

## Exploração (oportunidades de aprofundamento)

Escopo antes de varrer (YAGNI):

- se o usuário indicou direção (módulo, subsistema, dor) → seguir
- senão → percorrer o histórico (`git log --oneline`) para achar **pontos quentes** (arquivos/áreas que mudam com frequência) e começar por eles

Perguntas de atrito:

- entender um conceito exige pular entre muitos módulos pequenos?
- há módulos rasos (interface quase tão complexa quanto a implementação)?
- funções puras foram extraídas só para teste, mas os bugs estão em como são chamadas (sem localidade)?
- módulos acoplados vazam através dos seams?
- quais partes não têm teste, ou são difíceis de testar pela interface atual?

Aplicar o teste de deleção a todo suspeito de ser raso.

Para cada candidato, apresentar:

- **Arquivos/módulos** envolvidos
- **Problema:** por que a forma atual causa atrito
- **Solução:** o que mudaria, em linguagem simples
- **Benefícios:** em termos de localidade e alavancagem, e como os testes melhorariam
- **Força da recomendação:** `Forte` / `Vale explorar` / `Especulativa`
- **Conflito com ADR** (quando houver): sinalizar explicitamente e só propor se o atrito justificar reabrir a decisão

Encerrar com a **recomendação principal** (qual candidato atacar primeiro e por quê) e perguntar ao usuário qual explorar. NÃO propor interfaces antes da escolha.

Após a escolha:

- conduzir rodadas de perguntas sobre restrições, dependências, forma do módulo aprofundado, o que fica atrás do seam e quais testes sobrevivem
- nomear o módulo aprofundado com termos do glossário; termo novo → registrar com confirmação (`_shared/base-domain-model.md`)
- se o usuário rejeitar o candidato com motivo estrutural → oferecer ADR para que revisões futuras não o sugiram de novo

---

## Orquestração com subagents

Aplicar `_shared/base-subagents.md`. Somente quando a decisão do `/workflow` for `Orquestração: Com subagents`:

- **Levantamento de fatos:** subagent somente leitura percorre o código (pontos quentes e perguntas de atrito) e reporta candidatos com evidência
- **Design em paralelo:** para o candidato escolhido, 2 a 3 subagents desenham a interface de formas radicalmente diferentes (ex.: mínima, orientada a casos de uso, orientada a extensibilidade); comparar por profundidade, localidade e posição do seam
- a escolha final, os riscos e a proposta continuam no contexto principal

Sem subagents → explorar e comparar no contexto principal.

---

## Análise obrigatória

Antes de qualquer refatoração, identificar:

### Problema atual

- Código duplicado
- Baixa legibilidade
- Violação de padrões
- Complexidade desnecessária
- Módulos rasos (teste de deleção)

---

### Regras aplicáveis

- Quais regras de `.agents` estão sendo violadas ou não seguidas
- Padrões que deveriam ser aplicados
- ADRs da área que limitam a proposta

---

### Estratégia de refatoração

- Como o código será melhorado
- Qual abordagem será usada (ex: aprofundar módulo, extrair/inlinar função, mover seam, separar responsabilidade)
- Refactor amplo → sequenciar como expand → migrate → contract (ver `/plan`)

---

### Mudanças propostas

- Lista clara e objetiva do que será alterado

---

### Riscos

Classificar:

- Baixo
- Médio
- Alto

E explicar:

- o que pode quebrar
- impacto possível

---

## Validação de risco

- Se risco = ALTO:
  - AVISAR
  - NÃO executar automaticamente
  - Aguardar confirmação

- Se houver violação de `.agents`:
  - PARAR
  - Explicar o problema

---

## Bloqueio de execução

Este comando NÃO deve aplicar mudanças automaticamente.

Sempre:

- apresentar análise completa
- aguardar confirmação explícita do usuário

---

## Importante

- NÃO executar refatoração automaticamente
- NÃO alterar comportamento sem autorização
- Este comando é apenas de análise + proposta

---

## Formato obrigatório de saída

Responda SEMPRE com:

## Status

- Análise concluída / Bloqueado

---

## Análise

- Diagnóstico do código atual
- Candidatos a aprofundamento (com força da recomendação) e recomendação principal
- Problemas encontrados
- Qualidade atual
- Orquestração: Com subagents / Sem subagents / Sem subagents (fallback)

---

## Problemas

- Lista clara dos pontos que precisam refatoração
- Se não houver: Nenhum

---

## Próximos passos

- Escolher o candidato a explorar
- Confirmar se deve aplicar refatoração
- Ou ajustar estratégia
