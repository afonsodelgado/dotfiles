# Git aliases, shared by bash and zsh on every machine.
# Mostly the oh-my-zsh git plugin set I got used to on macOS, plus a few
# Omarchy ones. Omarchy defines `ga` and `gd` as worktree functions, so those
# two are intentionally not aliased here.

alias g='git'

# Status / log / diff
alias gst='git status'
alias gss='git status --short'
alias gdf='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --decorate --graph'
alias glol='git log --graph --pretty="%C(yellow)%h%Creset %C(cyan)%an%Creset %s %C(auto)%d%Creset"'
alias glo='git log --oneline --decorate'

# Stage
alias gaa='git add --all'
alias gapa='git add --patch'

# Commit
alias gcmsg='git commit -m'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gc!='git commit --amend'
alias gcn!='git commit --amend --no-edit'

# Branch / checkout / switch
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

# Remote
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias gp='git push'
alias gpush='git push'
alias gpf='git push --force-with-lease'
alias grv='git remote -v'

<<<<<<< Updated upstream
# Push / pull the current branch explicitly. oh-my-zsh defines these two as aliases;
# zsh expands aliases before parsing, so drop them first and use the `function`
# keyword, which is never alias-expanded.
unalias ggpush ggpull 2> /dev/null
function ggpush { git push origin "$(git branch --show-current)" "$@"; }
function ggpull { git pull origin "$(git branch --show-current)" "$@"; }
||||||| Stash base
# Push / pull the current branch explicitly
ggpush() { git push origin "$(git branch --show-current)" "$@"; }
ggpull() { git pull origin "$(git branch --show-current)" "$@"; }
=======
# Push / pull the current branch explicitly.
# oh-my-zsh's git plugin already aliases these; an alias shadows a function of
# the same name and breaks the definition at parse time.
unalias ggpush ggpull 2>/dev/null || true
ggpush() { git push origin "$(git branch --show-current)" "$@"; }
ggpull() { git pull origin "$(git branch --show-current)" "$@"; }
>>>>>>> Stashed changes

# Stash
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'

# Rebase / reset / cherry-pick
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grh='git reset'
alias grhh='git reset --hard'
alias gcp='git cherry-pick'

# WIP commits
alias gwip='git add -A && git commit --no-verify -m "--wip-- [skip ci]"'
alias gunwip='git log -n 1 | grep -q -- "--wip--" && git reset HEAD~1'
