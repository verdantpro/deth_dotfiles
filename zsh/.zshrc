# ~/.zshrc  (managed in ~/dotfiles, linked by stow)
# Works on Debian 13 and Ubuntu 26.04. Everything it sources comes from apt.

# ------------------------------------------------------------------ PATH / env

typeset -U path                       # no duplicate PATH entries
path=("$HOME/.local/bin" $path)       # zsh doesn't read ~/.profile, so add this ourselves

export EDITOR=vim
(( $+commands[vim] )) || export EDITOR=vi

# Colors for ls, completion menus, eza
eval "$(dircolors --sh)"

# man pages rendered through bat (Debian/Ubuntu name the binary batcat)
if (( $+commands[batcat] && $+commands[col] )); then
  export MANPAGER="sh -c 'col --no-backspaces --spaces | batcat --language=man --plain'"
  export MANROFFOPT="-c"
fi

# ------------------------------------------------------------------ history

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY        # save timestamp + duration of every command
setopt SHARE_HISTORY           # all sessions (tmux panes) share one history, live
setopt HIST_IGNORE_ALL_DUPS    # a repeated command replaces its older copy
setopt HIST_IGNORE_SPACE       # start a command with a space to keep it out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY             # !! and !$ expand into the line first, you press Enter again

# ------------------------------------------------------------------ navigation

setopt AUTO_CD                 # type a directory name to cd into it
setopt AUTO_PUSHD              # every cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS    # allow # comments on the command line
setopt NO_BEEP
# Directory stack: `dirs -v` lists it, `cd -<Tab>` picks from it, `cd -2` jumps

# ------------------------------------------------------------------ completion

zmodload zsh/complist
autoload -Uz compinit
mkdir --parents "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"

zstyle ':completion:*' menu select                                  # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'  # case-insensitive, then partial-word
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"             # same colors as ls
zstyle ':completion:*' group-name ''                                # group results by type
zstyle ':completion:*:descriptions' format '%F{#bb9af7}-- %d --%f'
zstyle ':completion:*:messages' format '%F{#7dcfff}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{#f7768e}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'

# Shift-Tab goes backwards in the menu
bindkey -M menuselect '^[[Z' reverse-menu-complete

# ------------------------------------------------------------------ key bindings

bindkey -e                                          # emacs keys, same as bash

# Up/Down search history for lines starting with what you've typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search          # Up
bindkey '^[OA' up-line-or-beginning-search          # Up (application mode)
bindkey '^[[B' down-line-or-beginning-search        # Down
bindkey '^[OB' down-line-or-beginning-search        # Down (application mode)

bindkey '^[[H'    beginning-of-line                 # Home
bindkey '^[[F'    end-of-line                       # End
bindkey '^[[3~'   delete-char                       # Delete
bindkey '^[[1;5C' forward-word                      # Ctrl-Right
bindkey '^[[1;5D' backward-word                     # Ctrl-Left
bindkey '^[[1;3C' forward-word                      # Option-Right (Mac)
bindkey '^[[1;3D' backward-word                     # Option-Left (Mac)

# Ctrl-X Ctrl-E: open the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ------------------------------------------------------------------ fzf
# Ctrl-R  fuzzy history search
# Ctrl-T  fuzzy file picker (pastes the path), previews with bat
# Alt-C   fuzzy cd into a subdirectory, previews with eza --tree
# **<Tab> fuzzy completion anywhere, e.g. `vim **<Tab>`, `kill -9 **<Tab>`, `ssh **<Tab>`

export FZF_DEFAULT_OPTS="
  --height=50% --layout=reverse --border=rounded --info=inline
  --color=fg:#c0caf5,bg:-1,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a,border:#565f89"
export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || eza --tree --level=2 --color=always --icons=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:wrap"

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
# Alt-C on the Mac needs `macos-option-as-alt = left` in the Ghostty config,
# otherwise Option-C just types ç.

# ------------------------------------------------------------------ prompt

eval "$(starship init zsh)"

# ------------------------------------------------------------------ plugins (keep last)

# Grey inline suggestion from history; Right arrow or End accepts it, Alt-F takes one word
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting, Tokyo Night colors. Must be sourced after everything else.
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[function]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#9ece6a,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#7dcfff'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#7dcfff'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'
