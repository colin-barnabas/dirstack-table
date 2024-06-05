d() {
    setopt local_options

    zparseopts -D -E -- -iso=iso x=trace
    if [[ "x$trace" != 'x' ]]; then
        setopt xtrace
        dbg "\n[\$1: $1]\n[\$2: $2]"
    fi

    local ret=$+dirstack[1]
    if [[ $ret -eq 0 ]]; then
        echo 'directory stack is empty'
        return $(( ret ^ 1 ))
    fi

    if [[ $ARGC -eq 0 ]]; then
        local TEMPLATE='
Ci5UUwpkb3VibGVib3ggYWxsYm94IG5vc3BhY2VzIG5vd2FybiBjZW50ZXIgdGFiKDopOwpOIHwg
QSxDQy4KJXMKLlRF
'
        local TBL="$( printf "$(base64 -d <<<$TEMPLATE)" \
            "$(for d in ${(u)dirstack}; print -aC2 ${dirstack[(ie)$d]} $d \
                | column --table --output-separator=':')" )"
        groff -t -Tutf8 -dpaper=com10 -me <<<$TBL | sed '/^$/d'
    elif [[ $1 == <-> ]]; then
        pushd -q -$1
        return $?
    elif [[ $1 == ?<-> ]]; then
        pushd -q $1
        return $?
    elif [[ $1 =~ '[[:alpha:]]' ]]; then
        local -a basenames=( ${(L)dirstack##*/} )
        local i
        : ${i:=$( test ${basenames[(i)$1]} -le ${#basenaes} && echo ${basenames[(i)$1]} )}
        : ${i:=$( test ${${(L)dirstack}[(i)*$1*]} -le ${#dirstack} && echo ${${(L)dirstack}[(i)*$1*]} )}
        test ${i:-0} -gt 0 && pushd -q -$i && return $? \
            || echo 'argument must reference an entry in $dirstack' && return 9
    else
        echo 'argument must reference an entry in $dirstack'
        return 9
    fi
}
