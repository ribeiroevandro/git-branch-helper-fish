# Configurações do Git Branch Helper para Fish Shell

# Hook de desinstalação (Fisher emite `<nome>_uninstall` para cada arquivo em conf.d)
# Este arquivo se chama `git-branch-helper.fish`, então o evento é `git-branch-helper_uninstall`.
function git-branch-helper_uninstall --on-event git-branch-helper_uninstall
    # Remover arquivo de configuração persistida (sem usar variáveis universais)
    set -l __gbh_root $__fish_config_dir
    if test -z "$__gbh_root"
        set __gbh_root ~/.config/fish
    end

    # Novo formato: arquivo em conf.d do usuário
    set -l __gbh_user_conf_file "$__gbh_root/conf.d/git-branch-helper.user.fish"
    command rm -f "$__gbh_user_conf_file" 2>/dev/null

    # Limpar legado (versões anteriores que criavam pasta)
    set -l __gbh_legacy_dir "$__gbh_root/git-branch-helper"
    command rm -rf "$__gbh_legacy_dir" 2>/dev/null

    # Limpar variáveis da sessão atual
    set -e -g GIT_BRANCH_ALLOWED_PREFIXES 2>/dev/null
    set -e -g GIT_BRANCH_USERNAME 2>/dev/null
    set -e -g __git_branch_helper_loaded 2>/dev/null
end

# Sem defaults: o usuário deve configurar via `git_branch_config`

# Mensagem de boas-vindas (uma vez por sessão interativa; sem persistência)
# Pode ser desativada definindo a variável `GIT_BRANCH_HELPER_NO_WELCOME` (por exemplo, em config.fish).
if status is-interactive; and not set -q __git_branch_helper_loaded; and not set -q GIT_BRANCH_HELPER_NO_WELCOME
    set -g __git_branch_helper_loaded 1
    echo "🐚 Git Branch Helper carregado! Use 'create_branch' para começar. Dica: 'git_branch_config help' para configurar."
end