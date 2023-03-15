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
alias agc="git checkout feature/AIRCLOSET-"
alias gb="git branch"
alias gs="git stash"
alias gm="git merge --ff"
alias gcm="git commit -m"
alias gsm="git submodule"
alias gsmu="git submodule update"

alias gpush="git push origin"
alias agpush="git push origin feature/AIRCLOSET-"
alias gpull="git pull origin"
alias agpull="git pull origin feature/AIRCLOSET-"

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
alias v="nvim"
alias f="fvm flutter"
alias flutter="fvm flutter"


