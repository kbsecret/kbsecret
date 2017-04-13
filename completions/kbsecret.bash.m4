# kbsecret.bash: bash completion functions for kbsecret
# XXX: this file is run through m4 via a makefile, which
# populates a few variables that aren't (currently) easy to
# determine during normal user activity:
# __KBSECRET_INTROSPECTABLE_COMMANDS:
#   commands that accept the --introspect-flags flag, which dumps
#   a list of valid flags to stdout. this would ideally be all kbsecret
#   commands, but in the interest of flexibility and simplicity we don't
#   want to require users to add it to their utilities.

_kbsecret_complete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "${prev}" = "kbsecret" ]] || [[ "${prev}" = "help" ]]; then
        opts=$(kbsecret commands)
    elif _kbsecret_completable_subcommand "${prev}"; then
        opts=$(_kbsecret_complete_subcommand "${prev}")
    else # assume it's an argument
        opts=$(_kbsecret_complete_argument "${prev}")
    fi

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _kbsecret_complete kbsecret

# these are commands that obey the --introspect-flags contract
_kbsecret_completable_subcommand() {
    cmd="${1}"
    cmds="__KBSECRET_INTROSPECTABLE_COMMANDS" # gen
    [[ " $cmds " =~ " $cmd " ]]
    return "${?}"
}

_kbsecret_complete_subcommand() {
    cmd="${1}"

    opts=$(kbsecret ${cmd} --introspect-flags)

    echo "${opts}"
}

_kbsecret_complete_argument() {
    arg="${1}"

    case "${arg}" in
        -s|--session) opts=$(kbsecret sessions);;
        -t|--type) opts=$(kbsecret types);;
        # XXX: is this a reasonable fallback?
        # a lot of commands take a record label at the end, but
        # many don't/won't or require a specifically typed record
        *) opts=$(kbsecret list);;
    esac

    echo "${opts}"
}

