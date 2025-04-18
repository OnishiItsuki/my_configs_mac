# ------ anyenv settings ------
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(anyenv init -)"
eval "$(nodenv init - --no-rehash)"

eval "$(direnv hook zsh)"

PROMPT='
%* %F{white}%n%b%f@%F{white}%m%u%f %F{green}[%~]%f
%# '


# ------- path settings ------- 
export PATH="/opt/homebrew/Cellar/mongodb-community@5.0/5.0.27/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
export PATH="~/.console-ninja/.bin":$PATH

# ------- python settings ------- 
# export PATH="${HOME}/.pyenv/shims:${PATH}"

# ------- not secure enviroment variables ------- 
export HOMEBREW_NO_AUTO_UPDATE=1

# ------- alias ------- 
# -- shell -- 
alias a="cd .."
alias aa="cd ../.."
alias aaa="cd ../../.."
alias aaaa="cd ../../../.."
alias aaaaa="cd ../../../../.."

alias restart="exec $SHELL -l"
alias restart-shell="exec $SHELL -l"

alias ql="qlmanage -p"

# -- ssh -- 
alias ssh-ac-infra-stg="ssh -i ~/.ssh/id_rsa ec2-user@${AC_INFRA_STG_IP}"
alias sshre="ssh -i ~/.ssh/id_rsa dhik@${AC_RELEAS_IP}"

# -- git -- 
alias gc="git checkout"
alias gb="git branch"
alias gs="git stash"
alias gm="git merge --ff"
alias gcm="git commit -m"

alias gsm="git submodule"
alias gsmu="git submodule update"

alias gpusho="git push origin"
alias gpullo="git pull origin"
alias gpush="CUURENT_BRANCH=\$(git branch --show-current); git push origin \$CUURENT_BRANCH"
alias gpull="CUURENT_BRANCH=\$(git branch --show-current); git pull origin \$CUURENT_BRANCH"

# Git便利コマンド
alias ggc="git branch --format=\"%(refname:short)\" | fzf | xargs git checkout"
alias ggbd="git branch --format=\"%(refname:short)\" | fzf | xargs git branch -d"
alias ggpush="TMPBRANCH=\$(git branch --format=\"%(refname:short)\" | fzf); git push origin \$TMPBRANCH"
alias ggpull="TMPBRANCH=\$(git branch --format=\"%(refname:short)\" | fzf); git pull origin \$TMPBRANCH"

# -- AWS -- 
alias ap="ansible-playbook"
alias awsp="source _awsp"

alias cdk-dep-sb="cdk deploy --profile sandbox"
alias cdk-dep-acprod="cdk deploy --profile aircloset"
alias cdk-dep-prod="cdk deploy --profile bridge"

alias cdk-dest-sb="cdk destroy --profile sandbox"
alias cdk-dest-acprod="cdk destroy --profile aircloset"
alias cdk-dest-prod="cdk destroy --profile bridge"


# -- others -- 
# -- shortcats -- 
alias v="nvim"
alias fu="fvm flutter"
alias flutter="fvm flutter"
alias diff="colordiff"
alias c="cursor"

# -- vim --
alias f="nvim \$(fzf --reverse)"

# -- utils --
# コピーしたもののフォーマットを変える
# 改行 <=> カンマ
alias n2c="pbpaste | tr '\n' ',' | pbcopy"
alias c2n="pbpaste | tr ',' '\n' | pbcopy"

# 改行 <=> タブ
alias n2t="pbpaste | tr '\n' '\t' | pbcopy"
alias t2n="pbpaste | tr '\t' '\n' | pbcopy"

# カンマ <=> タブ
alias c2t="pbpaste | tr ',' '\t' | pbcopy"
alias t2c="pbpaste | tr '\t' ',' | pbcopy"

# ;の末尾に改行を追加する
alias s="pbpaste | sed 's/;/;\n/g' | pbcopy"

#  綺麗なdiff
alias d='function _diffview(){ diff --side-by-side --color=always --width=$(tput cols) "$1" "$2" | colordiff | less -R }; _diffview'


# ヒストリー検索
alias h="TMPHISTCMD=\$(history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | tail -n 1); print -z \$TMPHISTCMD"
alias hex="TMPHISTCMD=\$(history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | tail -n 1); \$TMPHISTCMD"
# alias hex="history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | xargs -I {} zsh -c \"{}\""


