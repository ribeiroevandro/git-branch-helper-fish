# 🐚 Git Branch Helper (Fish)

Plugin para **Fish Shell** que cria branches Git com padrão consistente, com modo interativo e suporte a configuração simples.

[![Fish Shell](https://img.shields.io/badge/fish-v3.0+-blue.svg)](https://fishshell.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## ✨ Features

- **Fish-only**: feito para Fish Shell (com autocompletar)
- **Modo interativo ou por argumentos**: use prompts ou CLI
- **Tipos padronizados**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test` (ou números `1..7`)
- **Normalização automática**: remove acentos e caracteres especiais
- **Auto-confirmação**: flag `-y/--yes` para uso em scripts
- **Prefixo opcional por diretório**: em paths configurados, cria `username/feat-nome` (útil para GitLab/monorepos)

---

## ✅ Requisitos

- **Fish**: v3.0+
- **Git**: com suporte a `git switch` (Git 2.23+)

---

## 🚀 Instalação (Fisher)

```fish
fisher install ribeiroevandro/git-branch-helper-fish
```

---

## 📖 Uso

> Execute o comando dentro de um repositório Git (senão ele aborta com erro).

### Ajuda

```fish
create_branch --help
```

### Modo interativo

```fish
create_branch
```

### Com argumentos

```fish
create_branch feat nova funcionalidade de login
create_branch fix corrigir bug no checkout
create_branch 1 implementar api de pagamento  # usando números
```

### Auto-confirmação

```fish
create_branch -y feat implementar oauth
create_branch --yes fix resolver conflito
```

---

## 📋 Tipos de Branch

| Tipo     | Número | Descrição             |
|----------|--------|-----------------------|
| feat     | 1      | Nova funcionalidade   |
| fix      | 2      | Correção de bug       |
| chore    | 3      | Manutenção            |
| docs     | 4      | Documentação          |
| style    | 5      | Formatação/estilo     |
| refactor | 6      | Refatoração           |
| test     | 7      | Testes                |

---

## ⚙️ Configuração

### Configuração rápida (recomendado)

Use `git_branch_config` (**persiste em arquivo** no Fish):

```fish
# Definir seu username (prefixo)
git_branch_config username seu-username

# Adicionar diretórios onde branches terão o prefixo username/
git_branch_config add ~/workspace/gitlab
git_branch_config add ~/projetos/empresa

# Listar diretórios configurados
git_branch_config list

# Ver configuração completa
git_branch_config show

# Ajuda
git_branch_config help
```

Por padrão, a criação fica assim:

- **Fora dos diretórios configurados**: `tipo/nome` (ex: `feat/minha-feature`)
- **Dentro de um diretório configurado**: `username/tipo-nome` (ex: `seu-username/feat-minha-feature`)

> A config é salva em `~/.config/fish/conf.d/git-branch-helper.user.fish` e é carregada apenas em sessões **interativas**.
> Para scripts/CI, prefira exportar as variáveis `GIT_BRANCH_USERNAME` e `GIT_BRANCH_ALLOWED_PREFIXES` no próprio ambiente/script.

### Configuração manual (alternativa)

Você pode definir variáveis no seu `~/.config/fish/config.fish`:

```fish
set -gx GIT_BRANCH_USERNAME "seu-username"
set -gx GIT_BRANCH_ALLOWED_PREFIXES "$HOME/workspace" "$HOME/workspace/gitlab"
```

---

## 💡 Exemplos

### Criação básica

```text
$ create_branch feat autenticação oauth
🎯 Branch que será criada:
   feat/autenticacao-oauth
✅ Criar esta branch? [Y/n]:
```

### Em diretório autorizado (adiciona username)

```text
$ cd ~/workspace/gitlab/meu-projeto
$ create_branch feat nova api
🎯 Branch que será criada:
   seu-username/feat-nova-api
```

### Usando números

```text
$ create_branch 2 resolver bug crítico
🎯 Branch que será criada:
   fix/resolver-bug-critico
```

---

## 📂 Estrutura do projeto (Fish)

```text
git-branch-helper-fish/
├── conf.d/
│   └── git-branch-helper.fish
├── functions/
│   ├── create_branch.fish
│   └── git_branch_config.fish
├── completions/
│   ├── create_branch.fish
│   └── git_branch_config.fish
├── fisher_file
└── README.md
```

---

## 🔧 Desenvolvimento

### Testar localmente

```fish
set -p fish_function_path $PWD/functions
create_branch
```

---

## 📄 Licença

MIT — veja [LICENSE](LICENSE).
