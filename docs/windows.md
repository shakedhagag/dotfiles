# Windows and WSL

The same repo drives native Windows (PowerShell, WezTerm, AutoHotkey) and WSL
Ubuntu (the zsh setup, through Homebrew on Linux). `home/.chezmoiignore` keeps
each side to its own files.

## Native Windows

Prerequisites: [scoop](https://scoop.sh), and Developer Mode turned on
(Settings > System > For developers), so chezmoi can create the symlinks that
`mode = "symlink"` asks for.

In Windows PowerShell 5.1 (a fresh Windows has no PowerShell 7 yet):

```powershell
scoop install git chezmoi
git clone git@github.com:shakedhagag/dotfiles.git ~/Projects/dotfiles
chezmoi init --source ~/Projects/dotfiles --apply   # asks once: work or personal
git -C ~/Projects/dotfiles config core.hooksPath .githooks
```

The repo can live anywhere: the init config records the `--source` path, and
the profile's `dot:` drive follows it.

The first apply runs its `.ps1` scripts with `powershell` (5.1), because
`pwsh` isn't installed yet. That apply installs the scoop packages, PowerShell 7
and the PSFzf module. Then switch chezmoi to PowerShell 7:

```powershell
chezmoi init --source ~/Projects/dotfiles
```

`chezmoi init` renders `interpreters.ps1` as `pwsh` once `pwsh` is on the
PATH, and as `powershell` otherwise.

Both PowerShell 7 and 5.1 load `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`.

## WSL

Inside Ubuntu, follow the README's "New machine" steps. Install
[Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux) first;
`install-packages.sh` installs only the formulae on Linux.

On WSL only, chezmoi also creates `~/.config/zsh/chrome`, a symlink to Windows
Chrome that `.zshrc` exports as `$BROWSER`.
