# Completions para create_branch

# Não sugerir arquivos/diretórios por padrão (mantém apenas as opções abaixo)
complete -c create_branch -f

# Ajuda
complete -c create_branch -s h -l help -d "Mostrar ajuda"

# Flag de auto-confirmação
complete -c create_branch -s y -l yes -d "Auto-confirmar criação da branch"

# Tipos de branch
complete -c create_branch -n "__fish_is_first_arg" -a "feat" -d "Nova funcionalidade"
complete -c create_branch -n "__fish_is_first_arg" -a "fix" -d "Correção de bug"
complete -c create_branch -n "__fish_is_first_arg" -a "chore" -d "Tarefas de manutenção"
complete -c create_branch -n "__fish_is_first_arg" -a "docs" -d "Documentação"
complete -c create_branch -n "__fish_is_first_arg" -a "style" -d "Formatação/estilo"
complete -c create_branch -n "__fish_is_first_arg" -a "refactor" -d "Refatoração"
complete -c create_branch -n "__fish_is_first_arg" -a "test" -d "Testes"

# Números como atalhos
complete -c create_branch -n "__fish_is_first_arg" -a "1" -d "feat - Nova funcionalidade"
complete -c create_branch -n "__fish_is_first_arg" -a "2" -d "fix - Correção de bug"
complete -c create_branch -n "__fish_is_first_arg" -a "3" -d "chore - Tarefas de manutenção"
complete -c create_branch -n "__fish_is_first_arg" -a "4" -d "docs - Documentação"
complete -c create_branch -n "__fish_is_first_arg" -a "5" -d "style - Formatação/estilo"
complete -c create_branch -n "__fish_is_first_arg" -a "6" -d "refactor - Refatoração"
complete -c create_branch -n "__fish_is_first_arg" -a "7" -d "test - Testes"