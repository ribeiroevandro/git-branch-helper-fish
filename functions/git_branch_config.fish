function git_branch_config -d "Configurar Git Branch Helper"
    set -l command $argv[1]

    # Arquivo de configuração persistida (sem variáveis universais):
    # guardamos um arquivo em `~/.config/fish/conf.d/` (padrão similar ao autopair)
    set -l __gbh_root $__fish_config_dir
    if test -z "$__gbh_root"
        set __gbh_root ~/.config/fish
    end
    set -l __gbh_user_conf_file "$__gbh_root/conf.d/git-branch-helper.user.fish"

    function __gbh_save_config --argument-names username prefixes config_file
        set -l tmp (command mktemp)
        echo "# Git Branch Helper - configuração do usuário (auto-gerado)" >"$tmp"
        echo "# Este arquivo é atualizado via: git_branch_config" >>"$tmp"
        echo "" >>"$tmp"
        echo "status is-interactive || exit" >>"$tmp"
        echo "" >>"$tmp"

        if test -n "$username"
            echo "set -gx GIT_BRANCH_USERNAME "(string escape -- "$username") >>"$tmp"
        end

        echo -n "set -gx GIT_BRANCH_ALLOWED_PREFIXES" >>"$tmp"
        for p in $prefixes
            echo -n " "(string escape -- "$p") >>"$tmp"
        end
        echo "" >>"$tmp"

        command mv "$tmp" "$config_file"
        command chmod 600 "$config_file" 2>/dev/null
    end

    function __gbh_ensure_username --argument-names user_conf_file
        if test -n "$GIT_BRANCH_USERNAME"
            return 0
        end

        echo "⚠️  Username não configurado."
        echo ""
        echo "Como deseja configurar o username?"
        echo "  1) Usar usuário do sistema ("(whoami)")"
        echo "  2) Informar manualmente"
        echo ""

        read -P "Escolha [1/2] (Enter = 1): " choice
        set -l read_exit_code $status
        if test $read_exit_code -eq 130
            echo "❌ Operação cancelada."
            return 130
        else if test $read_exit_code -ne 0
            echo "❌ Operação cancelada."
            return 130
        end

        set -l selected ""
        if test -z "$choice"; or test "$choice" = 1
            set selected (whoami)
        else if test "$choice" = 2
            read -P "Digite o username: " selected
            set -l read_exit_code $status
            if test $read_exit_code -eq 130
                echo "❌ Operação cancelada."
                return 130
            else if test $read_exit_code -ne 0
                echo "❌ Operação cancelada."
                return 130
            end
        else
            echo "❌ Opção inválida: $choice"
            return 1
        end

        if test -z "$selected"
            echo "❌ Username não pode estar vazio."
            return 1
        end

        set -gx GIT_BRANCH_USERNAME $selected
        __gbh_save_config "$GIT_BRANCH_USERNAME" "$GIT_BRANCH_ALLOWED_PREFIXES" "$user_conf_file"
        echo "✅ Username configurado: $selected"
        return 0
    end
    
    switch $command
        case add
            # Adicionar diretório aos prefixos permitidos
            if test (count $argv) -lt 2
                echo "❌ Uso: git_branch_config add <diretório>"
                return 1
            end
            
            set -l new_dir $argv[2]
            
            # Expandir ~ para $HOME
            set new_dir (string replace -r '^~' $HOME $new_dir)
            
            # Verificar se diretório existe
            if not test -d "$new_dir"
                echo "⚠️  Aviso: O diretório '$new_dir' não existe."
                read -P "Deseja adicionar mesmo assim? [Y/n]: " confirm
                if test "$confirm" = n; or test "$confirm" = N
                    echo "❌ Operação cancelada."
                    return 0
                end
            end
            
            # Verificar se já existe
            # (contains precisa de pelo menos 1 VALUE; quando a lista está vazia ele gera erro)
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -gt 0; and contains -- "$new_dir" $GIT_BRANCH_ALLOWED_PREFIXES
                echo "⚠️  O diretório '$new_dir' já está na lista."
                return 0
            end

            # Garantir username antes de adicionar (para já ficar disponível na criação de branch)
            __gbh_ensure_username "$__gbh_user_conf_file"
            or return $status
            
            # Adicionar à lista (persistir em arquivo) e manter disponível nesta sessão
            # Obs: dentro de função, `set -x` seria local; precisamos de `-g` para surtir efeito imediatamente.
            set -gx GIT_BRANCH_ALLOWED_PREFIXES $GIT_BRANCH_ALLOWED_PREFIXES $new_dir
            __gbh_save_config "$GIT_BRANCH_USERNAME" "$GIT_BRANCH_ALLOWED_PREFIXES" "$__gbh_user_conf_file"
            echo "✅ Diretório adicionado: $new_dir"
            echo "💡 Agora branches criadas neste diretório terão o prefixo '$GIT_BRANCH_USERNAME/'"
            
        case remove rm
            # Remover diretório dos prefixos
            if test (count $argv) -lt 2
                echo "❌ Uso: git_branch_config remove <diretório|índice>"
                return 1
            end
            
            set -l target $argv[2]
            
            # Expandir ~ para $HOME
            set target (string replace -r '^~' $HOME $target)
            
            # Verificar se é um número (índice)
            if string match -qr '^\d+$' $target
                set -l index $target
                if test $index -lt 1; or test $index -gt (count $GIT_BRANCH_ALLOWED_PREFIXES)
                    echo "❌ Índice inválido. Use 'git_branch_config list' para ver os índices."
                    return 1
                end
                set target $GIT_BRANCH_ALLOWED_PREFIXES[$index]
            end
            
            # Verificar se existe na lista
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -eq 0; or not contains -- "$target" $GIT_BRANCH_ALLOWED_PREFIXES
                echo "❌ O diretório '$target' não está na lista."
                return 1
            end
            
            # Remover da lista
            set -l new_list
            for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                if test "$dir" != "$target"
                    set new_list $new_list $dir
                end
            end
            
            set -gx GIT_BRANCH_ALLOWED_PREFIXES $new_list
            __gbh_save_config "$GIT_BRANCH_USERNAME" "$GIT_BRANCH_ALLOWED_PREFIXES" "$__gbh_user_conf_file"
            echo "✅ Diretório removido: $target"
            
        case list ls
            # Listar diretórios configurados
            echo "📁 Diretórios com prefixo '$GIT_BRANCH_USERNAME/':"
            echo ""
            
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -eq 0
                echo "  (nenhum diretório configurado)"
                echo ""
                echo "💡 Use 'git_branch_config add <diretório>' para adicionar"
            else
                set -l index 1
                for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                    set -l display_dir (string replace $HOME '~' $dir)
                    if test -d $dir
                        echo "  $index) $display_dir ✓"
                    else
                        echo "  $index) $display_dir ⚠️  (não existe)"
                    end
                    set index (math $index + 1)
                end
            end
            echo ""
            
        case username user
            # Configurar username
            set -l new_username ""

            if test (count $argv) -ge 2
                # Modo direto (manual via argumento)
                set new_username $argv[2]
            else
                echo "📝 Username atual: $GIT_BRANCH_USERNAME"
                echo ""
                echo "Como deseja configurar o username?"
                echo "  1) Usar usuário do sistema ("(whoami)")"
                echo "  2) Informar manualmente"
                echo ""

                read -P "Escolha [1/2] (Enter = 1): " choice
                set -l read_exit_code $status
                if test $read_exit_code -eq 130
                    echo "❌ Operação cancelada."
                    return 130
                else if test $read_exit_code -ne 0
                    echo "❌ Operação cancelada."
                    return 130
                end

                if test -z "$choice"; or test "$choice" = 1
                    set new_username (whoami)
                else if test "$choice" = 2
                    read -P "Digite o username: " new_username
                    set -l read_exit_code $status
                    if test $read_exit_code -eq 130
                        echo "❌ Operação cancelada."
                        return 130
                    else if test $read_exit_code -ne 0
                        echo "❌ Operação cancelada."
                        return 130
                    end
                else
                    echo "❌ Opção inválida: $choice"
                    return 1
                end
            end

            if test -z "$new_username"
                echo "❌ Username não pode estar vazio."
                return 1
            end

            set -gx GIT_BRANCH_USERNAME $new_username
            __gbh_save_config "$GIT_BRANCH_USERNAME" "$GIT_BRANCH_ALLOWED_PREFIXES" "$__gbh_user_conf_file"
            echo "✅ Username atualizado: $new_username"
            echo "💡 Agora suas branches terão o prefixo '$new_username/' nos diretórios configurados"
            
        case reset
            # Resetar (limpar) configurações
            read -P "⚠️  Isso irá resetar todas as configurações. Continuar? [y/N]: " confirm
            if test "$confirm" != y; and test "$confirm" != Y
                echo "❌ Operação cancelada."
                return 0
            end
            
            # Apagar config persistida
            command rm -f "$__gbh_user_conf_file" 2>/dev/null

            # Resetar vars na sessão atual
            set -e -g GIT_BRANCH_USERNAME 2>/dev/null
            set -e -g GIT_BRANCH_ALLOWED_PREFIXES 2>/dev/null

            echo "✅ Configurações removidas."
            echo "💡 Dica: use 'git_branch_config username <nome>' e 'git_branch_config add <dir>' para configurar novamente."
            
        case show
            # Mostrar configuração atual
            echo "⚙️  Configuração atual do Git Branch Helper:"
            echo ""
            echo "👤 Username: $GIT_BRANCH_USERNAME"
            echo ""
            echo "📁 Diretórios com prefixo:"
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -eq 0
                echo "   (nenhum)"
            else
                for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                    set -l display_dir (string replace $HOME '~' $dir)
                    if test -d $dir
                        echo "   ✓ $display_dir"
                    else
                        echo "   ⚠️  $display_dir (não existe)"
                    end
                end
            end
            echo ""
            
        case help ''
            # Mostrar ajuda
            echo "🐚 Git Branch Helper - Configuração"
            echo ""
            echo "Uso: git_branch_config <comando> [argumentos]"
            echo ""
            echo "Comandos:"
            echo "  add <dir>          Adicionar diretório aos prefixos"
            echo "  remove <dir|n>     Remover diretório (por caminho ou índice)"
            echo "  list               Listar diretórios configurados"
            echo "  username [nome]    Ver ou alterar username"
            echo "  show               Mostrar configuração atual"
            echo "  reset              Resetar para valores padrão"
            echo "  help               Mostrar esta ajuda"
            echo ""
            echo "Exemplos:"
            echo "  git_branch_config add ~/projetos/empresa"
            echo "  git_branch_config add /workspace/clientes"
            echo "  git_branch_config remove 1"
            echo "  git_branch_config username joaosilva"
            echo "  git_branch_config list"
            echo ""
            echo "💡 Dica: Use tab para autocompletar comandos"
            
        case '*'
            echo "❌ Comando desconhecido: $command"
            echo "Use 'git_branch_config help' para ver os comandos disponíveis"
            return 1
    end
end