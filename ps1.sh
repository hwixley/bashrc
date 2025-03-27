parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_git_changes() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if [[ `git status --porcelain` ]]; then
            # Changes
            echo -e " \033[0;31m+\033[0m"
        fi
    fi
}

parse_git_upstream_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git fetch
        branch=$(parse_git_branch)
        upstream_exists=$(git ls-remote --exit-code --heads origin "refs/heads/${branch}")
        if [ "$upstream_exists" != "" ]; then
            UPSTREAM=${1:-'@{u}'}
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse "$UPSTREAM")
            BASE=$(git merge-base @ "$UPSTREAM")

            if [ $LOCAL = $REMOTE ]; then
                echo -e " \033[0;32m✓\033[0m"
            elif [ $LOCAL = $BASE ]; then
                echo -e " \033[0;34m↓\033[0m"
            elif [ $REMOTE = $BASE ]; then
                echo -e " \033[0;34m↑\033[0m"
            else
                echo -e " \033[0;34m✵\033[0m"
            fi
        fi
    fi
}

if [ "$color_prompt" = yes ]; then
    PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$(parse_git_upstream_status)\$(parse_git_changes) \n$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
