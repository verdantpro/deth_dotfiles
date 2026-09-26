# dotfiles

zsh + Starship + tmux for the lab boxes (Debian 13, Ubuntu 26.04). Tokyo Night colors.

## New box

From the Mac (Ghostty's terminfo, once per host):

```
infocmp -x xterm-ghostty | ssh jdw_ops@<host> -- tic -x -
```

On the box:

```
sudo apt update && sudo apt install --yes zsh zsh-autosuggestions zsh-syntax-highlighting starship fzf tmux eza bat stow git ncurses-term
git clone https://github.com/verdantpro/dotfiles.git "$HOME/dotfiles"
stow --dir="$HOME/dotfiles" --target="$HOME" --no-folding --verbose zsh starship tmux
mkdir --parents "$HOME/.local/bin" && ln --symbolic /usr/bin/batcat "$HOME/.local/bin/bat"
chsh --shell /usr/bin/zsh
```

Log out and back in. The first `tmux` launch clones TPM and installs the plugins.

## Mac side (Ghostty config)

```
theme = <Tokyo Night name from `ghostty +list-themes`>
macos-option-as-alt = left
```

## Keys worth knowing

| Where | Keys | Does |
|---|---|---|
| zsh | Ctrl-R | fuzzy history search |
| zsh | Ctrl-T | fuzzy file picker with bat preview |
| zsh | Option-C | fuzzy cd with eza tree preview |
| zsh | `cmd **<Tab>` | fuzzy completion (`vim **`, `kill -9 **`, `ssh **`) |
| zsh | Up / Down | history search on what you've typed so far |
| zsh | Right arrow | accept the grey suggestion |
| zsh | Ctrl-X Ctrl-E | edit the command line in $EDITOR |
| zsh | `cd -<Tab>` | jump back through the directory stack |
| tmux | prefix `\|` / `-` | split side by side / top-bottom |
| tmux | prefix h j k l | move between panes |
| tmux | prefix H J K L | resize (hold to repeat) |
| tmux | prefix Tab | last window |
| tmux | prefix r | reload config |
| tmux | prefix [ then v, y | copy mode, select, copy to Mac clipboard |
| tmux | prefix Ctrl-s / Ctrl-r | save / restore sessions (auto every 15 min) |

Prefix is the default Ctrl-b. Stock bindings (`"`, `%`) still work.

## Notes

- Starship's `sudo` module is off on purpose: it runs `sudo -n true` before every prompt, and sudo logs every run (including "a password is required") to the auth log. On a detection lab box that is noise in your data.
- `ls`, `cat`, `grep` are not aliased. Call `eza` and `bat` by name.
- Commands starting with a space stay out of history.
