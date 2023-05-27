# ------ anyenv settings ------
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(anyenv init -)"
eval "$(nodenv init - --no-rehash)"

eval "$(direnv hook zsh)"

PROMPT='
%* %F{white}%n%b%f@%F{white}%m%u%f %F{green}[%~]%f 
%# '


# ------- python settings ------- 
export PATH="${HOME}/.pyenv/shims:${PATH}"

# ------- alias ------- 
# -- shell -- 
alias a="cd .."
alias aa="cd ../.."
alias aaa="cd ../../.."
alias aaaa="cd ../../../.."
alias aaaaa="cd ../../../../.."

alias sr="exec $SHELL -l"
alias restart-shell="exec $SHELL -l"

alias ql="qlmanage -p"

# -- ssh -- 
alias ssh-ac-infra-stg="ssh -i ~/.ssh/id_rsa ec2-user@172.31.5.196"

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
alias gpush="TMPBRANCH=\$(git branch --show-current); git push origin \$TMPBRANCH"
alias gpull="TMPBRANCH=\$(git branch --show-current); git pull origin \$TMPBRANCH"

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

# -- vim --
alias f="nvim \$(fzf --reverse)"

# -- utils --
# コピーしたもののフォーマットを変える
# カンマ区切り
alias n2c="pbpaste | tr '\n' ',' | sed 's/,$//' | pbcopy"
# カンマ区切りにしつつダブルクウォーテーションをつける
alias n2dc="pbpaste | tr '\n' ',' | sed 's/,$//' | pbcopy"

# ヒストリー検索
alias h="TMPHISTCMD=\$(history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | tail -n 1); print -z \$TMPHISTCMD"
alias hex="TMPHISTCMD=\$(history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | tail -n 1); \$TMPHISTCMD"
# alias hex="history 1 | fzf --reverse --tac | sed 's/^ *[0-9]* *//' | xargs -I {} zsh -c \"{}\""

# Git便利コマンド
alias ggc="git branch --format=\"%(refname:short)\" | fzf | xargs git checkout"
alias ggbd="git branch --format=\"%(refname:short)\" | fzf | xargs git branch -d"
alias ggpush="TMPBRANCH=\$(git branch --format=\"%(refname:short)\" | fzf); git push origin \$TMPBRANCH"
alias ggpull="TMPBRANCH=\$(git branch --format=\"%(refname:short)\" | fzf); git pull origin \$TMPBRANCH"

