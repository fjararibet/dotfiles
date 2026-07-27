unalias compinit 2>/dev/null

export PATH=$HOME/.local/bin:$PATH

alias vim="nvim"
alias comp='g++ -Wall -Wextra -pedantic -std=c++17 -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC'

bindkey -e

# these were used to traverse the history but I use them for tmux
bindkey -r "^[."
bindkey -r "^[,"

export LEDGER_FILE=/home/fjara/finance/personal.journal
