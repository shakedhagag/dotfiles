# PowerShell 7 profile: the Windows port of ~/.zshrc.
# Same aliases, chords and tool integrations where Windows has them. zsh-only
# parts (zinit, global aliases, directory hashes) have stand-ins noted inline.
# Tools come from packages.windows in .chezmoidata/packages.yaml (scoop).

# Also loaded by Windows PowerShell 5.1 (Documents\WindowsPowerShell profile
# dot-sources this file), so keep it 5.1-safe: ASCII only, no `e escapes.
# Features that need PowerShell 7 / PSReadLine 2.1+ are guarded below.

function Test-Cmd([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
$ESC = [char]27
$IsPwsh7 = $PSVersionTable.PSVersion.Major -ge 7

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                              ENVIRONMENT                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

$env:EDITOR = 'nvim'
$env:XDG_CONFIG_HOME = Join-Path $HOME '.config'
$env:FZF_DEFAULT_OPTS_FILE = Join-Path $env:XDG_CONFIG_HOME 'fzf\fzfrc'
$env:CARAPACE_BRIDGES = 'powershell,inshellisense'

# scoop first: older system installs (e.g. nvim 0.12.0 in Program Files) sit
# earlier in the machine PATH and would otherwise shadow the scoop versions.
foreach ($p in @("$HOME\.bun\bin", "$HOME\.local\bin", "$HOME\scoop\shims")) {
  if (Test-Path $p) {
    $rest = ($env:PATH -split ';' | Where-Object { $_ -and $_.TrimEnd('\') -ne $p }) -join ';'
    $env:PATH = "$p;$rest"
  }
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                     LINE EDITING (zsh-autosuggestions etc.)                ║
# ╚════════════════════════════════════════════════════════════════════════════╝

Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs `
  -MaximumHistoryCount 10000 `
  -HistoryNoDuplicates `
  -HistorySearchCursorMovesToEnd `
  -BellStyle None `
  -AddToHistoryHandler { param($line) -not $line.StartsWith(' ') }  # hist_ignore_space
# Grey inline suggestion from history, like zsh-autosuggestions (→ / End accepts)
if (-not [Console]::IsOutputRedirected -and (Get-Module PSReadLine).Version -ge [version]'2.1') {
  Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
  Set-PSReadLineOption -Colors @{ InlinePrediction = "$ESC[38;2;88;110;117m" }
}

# History navigation (zsh: history-search-backward/forward)
Set-PSReadLineKeyHandler -Chord 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'Ctrl+n' -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'UpArrow' -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'DownArrow' -Function HistorySearchForward

# Word navigation (Alt + arrows, as in Ghostty)
Set-PSReadLineKeyHandler -Chord 'Alt+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Alt+RightArrow' -Function ForwardWord

# Ctrl+X Ctrl+E: edit the command line in $EDITOR
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually

# Ctrl+X L: clear screen and scrollback
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,l' -Description 'Clear screen and scrollback' -ScriptBlock {
  [Console]::Write("$ESC[H$ESC[2J$ESC[3J")
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# Ctrl+X C: copy the command buffer to the clipboard
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,c' -Description 'Copy buffer to clipboard' -ScriptBlock {
  $line = $null; $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  Set-Clipboard -Value $line
}

# Git quick bindings. zsh uses Ctrl+X g <key>; PSReadLine chords are two keys,
# so these are Ctrl+X then Ctrl+<key>.
function Set-InsertChord([string]$Chord, [string]$Text, [int]$Back = 0, [switch]$Run) {
  Set-PSReadLineKeyHandler -Chord $Chord -Description "Insert: $Text" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Text)
    if ($Back) { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Text.Length - $Back) }
    if ($Run) { [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }
  }.GetNewClosure()
}
Set-InsertChord 'Ctrl+x,Ctrl+c' 'git commit -m ""' -Back 1
Set-InsertChord 'Ctrl+x,Ctrl+p' 'git push origin '
Set-InsertChord 'Ctrl+x,Ctrl+s' 'git status' -Run
Set-InsertChord 'Ctrl+x,Ctrl+l' 'git log --oneline -n 10' -Run

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                 ALIASES                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝
# PowerShell aliases cannot take arguments, so most of these are functions.
# Several names clash with built-in aliases (gc, gl, gp, gm, ls ...): drop those.
foreach ($a in 'ls', 'gc', 'gl', 'gp', 'gm', 'gcb', 'gst') {
  if (Test-Path "Alias:$a") { Remove-Item "Alias:$a" -Force }
}

Set-Alias vim nvim
Set-Alias oc opencode
Set-Alias pn pnpm
function reload-profile { . $PROFILE }

# File navigation with fzf
function zf { $f = fzf -m --preview 'bat --color=always {}'; if ($f) { nvim $f } }

# eza (better ls)
function ls { eza -G -a --icons=always --group-directories-first --git-ignore @args }
function ltree { eza --tree --level=2 --icons --git @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# ── Git ───────────────────────────────────────────────────────────────────────
function ga { git add @args }
function gaa { git add --all @args }
function gc { git commit -m @args }
function gca { git commit --amend @args }
function gst { git status @args }
function gl { git pull @args }
function gp { git push @args }
function gpf { git push --force-with-lease @args }
function gb { git branch @args }
function gco { git checkout @args }
function gsw { git switch @args }
function gd { git diff @args }
function gds { git diff --staged @args }
function glog { git log --oneline --graph --decorate @args }
function grb { git rebase @args }
function gm { git merge @args }
function gsta { git stash @args }
function gstp { git stash pop @args }

# zsh global aliases `J` / `C` have no PowerShell form; pipe to these instead:
#   cat x.json | J        ->  cat x.json | jq
#   echo hi | C           ->  echo hi | Set-Clipboard
# PowerShell names ignore case, so zsh's `c` (clear) and `C` share one
# function: piped input is copied, a bare `c` clears the screen.
function J { $input | jq @args }
function C { if ($MyInvocation.ExpectingInput) { $input | Set-Clipboard } else { Clear-Host } }

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                    DIRECTORY HASHES (zsh: cd ~dot)                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝
# PowerShell drives instead: `cd dot:`, `cd dl:`
# `dot` follows the repo: chezmoi's config records where `chezmoi init` put it.
$dotfiles = "$HOME\dotfiles"
$chezmoiToml = Join-Path $HOME '.config\chezmoi\chezmoi.toml'
if ((Test-Path $chezmoiToml) -and ((Get-Content -Raw $chezmoiToml) -match '(?m)^\s*sourceDir\s*=\s*"([^"]+)"')) {
  $dotfiles = $Matches[1] -replace '\\\\', '\'
}
foreach ($d in @{ dot = $dotfiles; dl = "$HOME\Downloads"; frm = "$HOME\frame" }.GetEnumerator()) {
  if ((Test-Path $d.Value) -and -not (Get-PSDrive $d.Key -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $d.Key -PSProvider FileSystem -Root $d.Value -Scope Global | Out-Null
  }
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                FUNCTIONS                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Yazi, cd into the directory it exits in
function y {
  $tmp = (New-TemporaryFile).FullName
  yazi @args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
  }
  Remove-Item -Path $tmp
}

# lazygit, cd into the repo/worktree it switched to
function lg {
  if (-not (Test-Cmd lazygit)) { Write-Error "'lazygit' is not installed."; return }
  $env:LAZYGIT_NEW_DIR_FILE = Join-Path $env:TEMP 'lazygit-chdir'
  lazygit @args
  if (Test-Path $env:LAZYGIT_NEW_DIR_FILE) {
    $target = Get-Content $env:LAZYGIT_NEW_DIR_FILE -Raw
    Remove-Item $env:LAZYGIT_NEW_DIR_FILE -Force
    if ($target -and (Test-Path $target) -and $target -ne $PWD.Path) {
      Set-Location $target
      Write-Host ":: Switched to: $target" -ForegroundColor Green
    }
  }
  Remove-Item Env:LAZYGIT_NEW_DIR_FILE -ErrorAction SilentlyContinue
}

# zsh `bup` (brew update/upgrade/cleanup/doctor), scoop edition
function bup {
  Write-Host ':: Updating scoop...'; scoop update
  Write-Host ':: Upgrading packages...'; scoop update *
  Write-Host ':: Cleaning up...'; scoop cleanup *
  Write-Host ':: Running checkup...'; scoop checkup
}

# Open WSL zsh in the current directory
function wz { wsl.exe --cd "$PWD" -- zsh -l }

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                           SHELL INTEGRATIONS                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Chocolatey tab completion
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) { Import-Module $ChocolateyProfile }

# Starship prompt. First of the prompt hooks: its `prompt` replaces the
# current one without calling it, so fnm, mise and zoxide wrap it afterwards.
if (Test-Cmd starship) { Invoke-Expression (&starship init powershell) }

# Node version manager
if (Test-Cmd fnm) { fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression }

# mise (per-project tool versions)
if (-not $IsPwsh7) { $env:MISE_PWSH_CHPWD_WARNING = '0' } # cd hooks need pwsh 7
if (Test-Cmd mise) { mise activate pwsh | Out-String | Invoke-Expression }

# Carapace argument completion (zsh: carapace + zsh-completions)
if (Test-Cmd carapace) { carapace _carapace powershell | Out-String | Invoke-Expression }

# fzf: Tab completion through fzf (zsh: fzf-tab), Ctrl+T file picker.
# Ctrl+R is left to atuin below, as in zsh.
if ((Test-Cmd fzf) -and (Get-Module -ListAvailable PSFzf)) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
}

# Zoxide (smart cd)
if (Test-Cmd zoxide) { Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) }) }

# Atuin (shell history, Ctrl+R)
# (PowerShell 7 only; on 5.1, Ctrl+R falls back to PSFzf's fzf history search)
if ($IsPwsh7 -and (Test-Cmd atuin)) {
  atuin init powershell | Out-String | Invoke-Expression
} elseif (Get-Module PSFzf) {
  Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Machine-local additions, kept out of this public repo (zsh: frame-functions.zsh)
$local = Join-Path $env:XDG_CONFIG_HOME 'powershell\local.ps1'
if (Test-Path $local) { . $local }
