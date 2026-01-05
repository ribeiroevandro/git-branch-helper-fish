function create_branch -d "Criar branches Git com padrão personalizado"
    # Uso: create_branch

    # Verificar se estamos em um repositório Git
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "❌ Erro: Este diretório não é um repositório Git!"
        return 1
    end

    # 1. Obter o tipo de branch (argumentos, flags ou prompt)
    set -l auto_confirm 0
    if not argparse h/help y/yes -- $argv
        return 1
    end

    if set -q _flag_h
        echo "🐚 Git Branch Helper (Fish)"
        echo ""
        echo "Uso:"
        echo "  create_branch [--yes|-y] [tipo|numero] [nome...]"
        echo ""
        echo "Exemplos:"
        echo "  create_branch"
        echo "  create_branch feat autenticacao oauth"
        echo "  create_branch 2 corrigir bug no checkout"
        echo "  create_branch --yes fix resolver conflito"
        echo ""
        echo "Tipos (ou números 1..7):"
        echo "  feat(1), fix(2), chore(3), docs(4), style(5), refactor(6), test(7)"
        echo ""
        echo "Configuração:"
        echo "  - Definir seu username (prefixo):"
        echo "      git_branch_config username <nome>"
        echo "  - Adicionar/remover diretórios onde o prefixo será aplicado:"
        echo "      git_branch_config add <dir>"
        echo "      git_branch_config remove <dir|n>"
        echo "      git_branch_config list"
        echo ""
        echo "Como funciona:"
        echo "  - Se o diretório atual (pwd) estiver dentro de algum diretório configurado (e existente),"
        echo "    a branch será criada como: <username>/<tipo>-<nome>"
        echo "  - Caso contrário, será criada como: <tipo>/<nome>"
        echo ""
        echo "Persistência:"
        echo "  - As configurações são persistidas no Fish via `git_branch_config`"
        return 0
    end

    if set -q _flag_y
        set auto_confirm 1
    end

    set -l positional $argv

    set -l branch_type ""
    set -l branch_name ""

    if test (count $positional) -ge 1
        set branch_type $positional[1]
    end

    if test (count $positional) -ge 2
        set branch_name (string join ' ' $positional[2..-1])
    end

    if test -z "$branch_type"
        echo "🔀 Tipos de branch disponíveis:"
        echo "  1) feat    - Nova funcionalidade"
        echo "  2) fix     - Correção de bug"
        echo "  3) chore   - Tarefas de manutenção"
        echo "  4) docs    - Documentação"
        echo "  5) style   - Formatação/estilo"
        echo "  6) refactor - Refatoração"
        echo "  7) test    - Testes"

        read -P "📝 Digite o número ou nome do tipo de branch: " branch_type
        set -l read_exit_code $status
        if test $read_exit_code -eq 130
            echo "❌ Operação cancelada."
            return 130
        else if test $read_exit_code -ne 0
            echo "❌ Operação cancelada."
            return 130
        end
    end

    # Mapear números para tipos
    switch $branch_type
        case 1
            set branch_type feat
        case 2
            set branch_type fix
        case 3
            set branch_type chore
        case 4
            set branch_type docs
        case 5
            set branch_type style
        case 6
            set branch_type refactor
        case 7
            set branch_type test
        case "*"
            # Manter o valor digitado se não for número
    end

    # Validar tipo de branch
    if test -z "$branch_type"
        echo "❌ Tipo de branch não pode estar vazio!"
        return 1
    end

    # 2. Obter o nome da branch (argumento ou prompt)
    if test -z "$branch_name"
        read -P "📝 Digite o nome da branch (ex: migracao de tela xpto): " branch_name
        set -l read_exit_code $status
        if test $read_exit_code -eq 130
            echo "❌ Operação cancelada."
            return 130
        else if test $read_exit_code -ne 0
            echo "❌ Operação cancelada."
            return 130
        end
    end

    if test -z "$branch_name"
        echo "❌ Nome da branch não pode estar vazio!"
        return 1
    end

    # 3. Limpar e formatar strings
    # Converter para minúsculas e remover acentos/caracteres especiais
    set clean_type (echo $branch_type | string lower | string replace -ra '[^a-z0-9]' '')

    # Limpar nome da branch: minúsculas, remover acentos, caracteres especiais, e converter espaços para hífens
    set clean_name (echo $branch_name | string lower | \
                    string replace -ra '[áàâãä]' 'a' | \
                    string replace -ra '[éèêë]' 'e' | \
                    string replace -ra '[íìîï]' 'i' | \
                    string replace -ra '[óòôõö]' 'o' | \
                    string replace -ra '[úùûü]' 'u' | \
                    string replace -ra '[ç]' 'c' | \
                    string replace -ra '[ñ]' 'n' | \
                    string replace -ra '[^a-z0-9\s]' '' | \
                    string replace -ra '\s+' '-' | \
                    string replace -ra '-+$' '')

    # 4. Criar nome da branch no padrão especificado
    set -l username $GIT_BRANCH_USERNAME
    set -l branch_suffix "$clean_type-$clean_name"
    set -l full_branch_name "$clean_type/$clean_name"

    # Incluir prefixo apenas em diretórios autorizados
    set -l current_dir (pwd)
    set -l allowed_prefixes $GIT_BRANCH_ALLOWED_PREFIXES

    # Filtrar apenas diretórios que existem (configs apontando para paths inexistentes não devem ativar username)
    set -l verified_prefixes
    for prefix in $allowed_prefixes
        if test -d "$prefix"
            set verified_prefixes $verified_prefixes "$prefix"
        end
    end

    # Aplicar username apenas quando há diretórios válidos E o diretório atual casa com algum prefixo válido
    if test -n "$username"
        for prefix in $verified_prefixes
            set -l escaped_prefix (string escape --style=regex $prefix)
            set -l prefix_regex (string join '' '^' $escaped_prefix '(/|$)')
            if string match -rq -- $prefix_regex $current_dir
                set full_branch_name "$username/$branch_suffix"
                break
            end
        end
    end

    # Mostrar preview da branch
    echo ""
    echo "🎯 Branch que será criada:"
    echo "   $full_branch_name"
    echo ""

    # Confirmar criação
    if test $auto_confirm -ne 1
        read -P "✅ Criar esta branch? [Y/n]: " confirm
        set -l read_exit_code $status
        if test $read_exit_code -eq 130
            echo "❌ Operação cancelada."
            return 130
        else if test $read_exit_code -ne 0
            echo "❌ Operação cancelada."
            return 130
        end

        if test "$confirm" = n; or test "$confirm" = N
            echo "❌ Operação cancelada."
            return 0
        end
    end

    # Verificar se a branch já existe
    if git show-ref --verify --quiet "refs/heads/$full_branch_name"
        echo "❌ A branch '$full_branch_name' já existe!"
        return 1
    end

    # Criar e fazer checkout para a nova branch
    # Obs: aqui não usamos `--` como separador, pois `-c` já consome o próximo argumento como nome da branch
    # e `$full_branch_name` já foi normalizado, sem caracteres especiais que exijam o uso de `--` para desambiguação
    if git switch -c $full_branch_name
        echo ""
        echo "🎉 Branch '$full_branch_name' criada e ativada com sucesso!"
        echo "📂 Você está agora na nova branch."

        # Mostrar status atual
        echo ""
        git status --short
    else
        echo "❌ Erro ao criar a branch!"
        return 1
    end
end