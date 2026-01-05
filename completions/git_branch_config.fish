# Completions para git_branch_config

# Não sugerir arquivos/diretórios por padrão (mantém apenas os subcomandos abaixo)
complete -c git_branch_config -f

# Comandos principais
complete -c git_branch_config -n "__fish_is_first_arg" -a "add" -d "Adicionar diretório"
complete -c git_branch_config -n "__fish_is_first_arg" -a "remove" -d "Remover diretório"
complete -c git_branch_config -n "__fish_is_first_arg" -a "list" -d "Listar diretórios"
complete -c git_branch_config -n "__fish_is_first_arg" -a "username" -d "Configurar username"
complete -c git_branch_config -n "__fish_is_first_arg" -a "show" -d "Mostrar configuração"
complete -c git_branch_config -n "__fish_is_first_arg" -a "reset" -d "Resetar configurações"
complete -c git_branch_config -n "__fish_is_first_arg" -a "help" -d "Mostrar ajuda"

# Aliases
complete -c git_branch_config -n "__fish_is_first_arg" -a "rm" -d "Remover diretório (alias)"
complete -c git_branch_config -n "__fish_is_first_arg" -a "ls" -d "Listar diretórios (alias)"
complete -c git_branch_config -n "__fish_is_first_arg" -a "user" -d "Configurar username (alias)"

# Autocompletar diretórios para 'add'
complete -c git_branch_config -n "__fish_seen_subcommand_from add" -a "(__fish_complete_directories)"

# Autocompletar índices para 'remove'
complete -c git_branch_config -n "__fish_seen_subcommand_from remove rm" -a "(seq (count $GIT_BRANCH_ALLOWED_PREFIXES))"