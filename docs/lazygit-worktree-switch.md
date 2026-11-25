# Switching worktrees from LazyGit in Neovim

Research note (2026-11-19). Versions checked: lazygit 0.66.3 (Homebrew), snacks.nvim `882c996`, worktrunk 0.82.0, Rex 0.1.0-preview.19 (API rev 14). No config was changed.

## Answer

Yes. The clean way is to override `<space>` in LazyGit's Worktrees panel, only in the nvim door's overlay config. The override calls back into Neovim, and Neovim runs the existing `rex do worktree_open` through `config/host.lua`. That action already returns to the tab where the worktree is open, or creates a worktree session, and then queues `session.select` so the app switches to it. LazyGit has no "on worktree switch" hook. What it does have is `LAZYGIT_NEW_DIR_FILE`, which it rewrites the moment it switches repo, so it can serve as a fallback signal. Worktrunk hooks never fire for a LazyGit switch because LazyGit doesn't run `wt`.

## Findings

### LazyGit

- **Built-in switch is in-process.** In the Worktrees panel, `<space>` (`universal.select`) and `<enter>` (`universal.goInto`) both call `WorktreeHelper.Switch` ([worktrees_controller.go#L46-L58](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/worktrees_controller.go#L46-L58)). That calls `DispatchSwitchTo` → `switchToLocation`, which does `os.Chdir`, verifies the repo, loads direnv and re-inits the GUI with `onNewRepo` ([repos_helper.go#L334-L414](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/helpers/repos_helper.go#L334-L414)). Nothing external is spawned.
- **Other ways in:** checking out a branch that another worktree holds prompts and then switches ([branches_controller.go#L438-L450](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/branches_controller.go#L438-L450)). Creating a worktree also switches to it ([worktree_helper.go#L428-L452](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/helpers/worktree_helper.go#L428-L452)). A `<space>` override doesn't catch either one.
- **No switch hook or event.** The one side effect visible from outside is `LAZYGIT_NEW_DIR_FILE`. `switchToLocation` writes the new cwd to it on every switch, not only on quit ([repos_helper.go#L408](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/helpers/repos_helper.go#L408), [record_directory_helper.go#L21-L36](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/controllers/helpers/record_directory_helper.go#L21-L36)). On quit it writes it again: the current dir for `q`, the starting dir for `Q` ([gui.go#L1050-L1058](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/gui.go#L1050-L1058)). It writes with `os.WriteFile`, which truncates the file in place ([os.go#L157-L172](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/commands/oscommands/os.go#L157-L172)).
- **Custom commands can replace `<space>`.** `worktrees` is a valid context. A custom key that collides with a built-in one in the same context runs *instead of* the built-in ([Custom_Command_Keybindings.md "Keybinding collisions"](https://github.com/jesseduffield/lazygit/blob/v0.66.3/docs/Custom_Command_Keybindings.md#keybinding-collisions)). `{{.SelectedWorktree.Path}}`, `.Branch`, `.IsCurrent`, `.IsMain` and `.Name` are available ([models.go#L99-L107](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/gui/services/custom_commands/models.go#L99-L107)). Overriding only `<space>` leaves `<enter>` as the built-in switch, which is a free escape hatch.
- **A custom command can't quit LazyGit.** `after` only has `checkForConflicts` ([user_config.go#L740-L742](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/config/user_config.go#L740-L742)). `output` can be `none`, `terminal`, `log`, `logWithPty` or `popup` (same doc, field table). For a float inside nvim that doesn't matter: nvim can hide the float itself, as `Config.lazygit_edit` already does.
- **Overlay configs append custom commands.** When `LG_CONFIG_FILE` lists several files, each file's `customCommands` are added to the earlier ones instead of replacing them ([app_config.go#L214-L220](https://github.com/jesseduffield/lazygit/blob/v0.66.3/pkg/config/app_config.go#L214-L220)). So the nvim overlay (`home/dot_config/nvim/plugin/42_lazygit.lua:46`) can add one command without losing `<c-g>`, `<c-c>` and the rest from `home/dot_config/lazygit/config.yml:92`.

### Snacks.lazygit

- It doesn't handle `LAZYGIT_NEW_DIR_FILE` and has no exit callback. `M.open` builds `{ "lazygit", ...args }` and returns `Snacks.terminal(cmd, opts)`, which toggles ([lazygit.lua#L192-L207](https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/lazygit.lua#L192-L207)). A grep for `LAZYGIT_NEW_DIR_FILE` in snacks finds nothing.
- The terminal options include `cwd`, `env`, `win`, `auto_close` and `interactive` ([terminal.lua#L16-L30](https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/terminal.lua#L16-L30)). `env` goes to `jobstart` ([L162-L166](https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/terminal.lua#L162-L166)). On a clean exit, `auto_close` closes the window on `TermClose` ([L138-L147](https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/terminal.lua#L138-L147)). Your own `TermClose` autocmd on the buffer would be the "on exit" hook.
- **Gotcha:** a terminal's id is `{cmd, cwd = getcwd(0), env, count}` ([L176-L184](https://github.com/folke/snacks.nvim/blob/882c996cf28183f4d63640de0b4c02ec886d01f2/lua/snacks/terminal.lua#L176-L184)). If nvim `:cd`s, the next `<Leader>gg` starts a *new* LazyGit, and the old one stays hidden in the old directory.

### Worktrunk

- Hooks run only when `wt` runs. `wt switch` runs `pre-switch`, creates the worktree if needed, runs `pre-start` (blocking), then spawns `post-start` and `post-switch` in the background. `post-switch` fires on every switch result: created, existing, or staying on current (`wt switch --help`, `wt hook --help`; [worktrunk.dev/hook](https://worktrunk.dev/hook/)). LazyGit's switch never calls `wt`, so none of this runs.
- `--no-cd` only stops the shell from following. Hooks and `-x` still run in the worktree (`wt switch --help`). The shell `cd` works through a temp file passed as `WORKTRUNK_DIRECTIVE_CD_FILE` (`wt config shell init zsh`).
- worktrunk documents a "workspace per worktree" pattern for cmux. It uses `[switch] cd = false`, `pre-start` to create the workspace and `pre-switch` to select it. It uses `pre-*` because `post-*` hooks are detached ([tips-patterns, cmux](https://worktrunk.dev/tips-patterns/)). In `pre-switch`, `worktree_path` is the *source* when the switch creates a worktree (`wt hook --help`).
- `wt list --format=json` and `wt switch --format=json` exist. I didn't check the JSON field names.

### Rex

- `worktree_open` (`home/dot_config/rex/init.lua:677-713`) already does the whole job. It finds where the worktree is open by scanning every tiled pane's *foreground process cwd* across sessions, preferring a tab with nvim (`init.lua:608-656`, `fg_cwd` at `:50`). If none is found, it calls `session.create` with the nvim | claude layout. Unless `select=false`, it then calls `rex.client.queue("session.select", { session_id, window_id })` (`:709`).
- **Client actions from the CLI need Remote Control.** `rex.client.queue` raises when no client can be found from the CLI, and "the app also only accepts actions from the CLI when Remote Control is turned on" ([actions.md, Calling Other Actions](https://www.superlogical.com/rex/docs/customize/actions.md)). The setting is at *Settings > Server > Client Info > Remote Control* ([mac-settings](https://www.superlogical.com/rex/docs/reference/mac-settings.md)). The comment at `init.lua:566-567` calls it "Settings > Rex Server", which may be outdated. Without a `-C`, `rex do` uses the app client when exactly one is connected (`rex do --help`). `rex client ls` currently shows one app client (`hagagsh`). I couldn't check read-only whether Remote Control is on, but `<Leader>gw` working would prove it.
- `session.select` takes `session_id` and an optional `window_id` (`rex client inspect <app-client> --json`). It's listed as "Go to Session" in [mac-actions](https://www.superlogical.com/rex/docs/reference/mac-actions.md).
- Rex events include `terminal.pwd_changed` (OSC 7) and `terminal.process_changed` ([events](https://www.superlogical.com/rex/docs/reference/events.md)). Neither sees LazyGit inside nvim: LazyGit runs on nvim's own pty, and the Rex pane's foreground process stays `nvim`.

### Neovim side

- The env is already in place. LazyGit in the Snacks float inherits nvim's env: `$NVIM` (used by the edit script, `42_lazygit.lua:46-63`), plus `$REX_SESSION` and `$REX_BLOCK` of nvim's pane, which `host.lua:81` passes as `-b`. Herdr nesting is handled by `host.kind()` (`host.lua:218`).
- **Option (a): `:cd` nvim to the new worktree.** It's easy. But it changes what Rex calls "open": session A's nvim process cwd now sits inside worktree B, so `worktree_open B` would return to session A (CONTEXT.md "open worktree"; `init.lua:553-557`). The agent pane in A stays in the old worktree. It goes against "one worktree session per worktree". It only fits when there's no host.
- **Option (b): jump to or create the worktree's Rex session.** This matches the model and reuses `rex.open_worktree` (`host.lua:136`) or `herdr.open_worktree` (`host.lua:205`). `host.lua` doesn't export a single "open this path" function yet. Only `pick_worktree` (`host.lua:292`) is public.

## Candidate designs

### A. `<space>` override in the nvim overlay → nvim → `host.open_worktree` (recommended)

Files: `home/dot_config/nvim/plugin/42_lazygit.lua`, `home/dot_config/nvim/lua/config/host.lua`, `scripts/test-host.lua`, and the nvim row in `docs/lazygit-contract.md`.

In `ensure_lazygit_remote_config`, write the override only when a host exists. Outside Rex or Herdr, `<space>` keeps its built-in in-process switch:

```lua
-- callback script, same pattern as lazygit-nvim-edit.sh
local wt_script = vim.fs.joinpath(cache, 'lazygit-nvim-worktree.sh')
vim.fn.writefile({
  "dir=$(printf '%s' \"$1\" | sed \"s/'/''/g\")",
  [[exec nvim --server "$NVIM" --remote-expr "v:lua.Config.lazygit_worktree('$dir')" >/dev/null]],
}, wt_script)

local lines = { --[[ existing os:/promptToReturnFromSubprocess lines ]] }
if require('config.host').kind() then
  vim.list_extend(lines, {
    'customCommands:',
    "  - key: '<space>'",
    "    context: 'worktrees'",
    "    description: 'Open worktree session'",
    ("    command: 'sh %s {{.SelectedWorktree.Path | quote}}'"):format(wt_script),
    '    output: none',
  })
end
```

```lua
Config.lazygit_worktree = function(path)
  -- hide the float like Config.lazygit_edit does, so coming back shows the editor
  for _, t in ipairs(Snacks.terminal.list()) do
    if type(t.cmd) == 'table' and t.cmd[1] == 'lazygit' then t:hide() end
  end
  -- return at once: the rex action scans every session and must not block the RPC
  vim.schedule(function() require('config.host').open_worktree(path) end)
  return ''
end
```

```lua
-- host.lua: export the open half of pick_worktree
M.open_worktree = function(path)
  local host = current()
  if not host then return end
  local list, err = host.worktrees()   -- Herdr needs w.workspace to focus, not duplicate
  if not list then return echo_error(err) end
  local w = vim.iter(list):find(function(x) return x.path == path end) or { path = path }
  local open_err = host.open_worktree(w)
  if open_err then echo_error(open_err) end
end
```

Trade-offs and gotchas:
- LazyGit in session A doesn't switch. The app moves to session B, which has its own nvim and LazyGit. Coming back works the same way.
- It only catches `<space>`. `<enter>`, the branch-checkout prompt and `n` (new worktree) still switch LazyGit in-process. Keeping `<enter>` as the built-in is useful. Design B covers the rest if you want them.
- Choosing the current worktree selects A's own tab, which does nothing harmful. Guarding with `{{if .SelectedWorktree.IsCurrent}}` is optional.
- For Rex, `host.worktrees()` scans every session, and so does `worktree_open`, so the work happens twice. You could skip the lookup for Rex, since `rex.open_worktree` only needs `path`.
- If Remote Control is off, the session gets created but the app doesn't switch to it. The error shows in `:messages` via `echo_error`.
- `worktree_open` needs an exact worktree-root path (`init.lua:692-694`). LazyGit's `Path` comes from git's worktree list, so it should match. I didn't test symlinked paths.
- Run `sh scripts/test.sh` (host changes). The overlay is only for the nvim door, which keeps to the per-door rule in `docs/lazygit-contract.md`.

### B. `LAZYGIT_NEW_DIR_FILE` watcher in nvim (catches every LazyGit switch)

Files: `home/dot_config/nvim/plugin/42_lazygit.lua`.

```lua
local dir_file = vim.fs.joinpath(vim.fn.stdpath('state'), 'lazygit-newdir-' .. vim.fn.getpid())
Snacks.lazygit[open]({ configure = false, env = { LAZYGIT_NEW_DIR_FILE = dir_file } })
-- once per nvim: watch the directory, since LazyGit rewrites the file in place
local ev = vim.uv.new_fs_event()
ev:start(vim.fs.dirname(dir_file), {}, vim.schedule_wrap(function(_, name)
  if name ~= vim.fs.basename(dir_file) then return end
  local path = (vim.fn.readfile(dir_file)[1] or '')
  if path == '' or path == vim.fn.getcwd() then return end   -- quit with `q`/`Q` lands here too
  -- host: close (kill) this LazyGit (now in B) and host.open_worktree(path)
  -- no host: vim.cmd.cd(path)
end))
```

Trade-offs and gotchas:
- It fires for every switch path, worktree creation included. But LazyGit has already moved itself to B, so in a host you have to kill that float, or session A's LazyGit stays on B.
- A switch inside a subdirectory reports the worktree root, and nvim's cwd may be a subdirectory of the same worktree. Compare git roots, not raw cwd.
- `env` becomes part of the Snacks terminal id. Keep the value stable per nvim.
- macOS FSEvents can coalesce events or fire twice, so make the handler idempotent. Reading the file on the float's `TermLeave` or hide is a simpler alternative.
- For the no-host case, this is the natural "nvim follows LazyGit" behaviour (option a). Note the Snacks tid gotcha above.

### C. worktrunk `post-switch` hook → `rex do worktree_open` (not recommended)

Files: `home/dot_config/worktrunk/config.toml`, plus a LazyGit custom command that runs `wt switch {{.SelectedWorktree.Branch | quote}} --no-cd` so the hook fires at all.

```toml
[post-switch]
rex = '[ -n "$REX_BLOCK" ] && rex do worktree_open path={{ worktree_path }} || true'
```

Why not:
- It fires on every `wt switch` from any shell or agent, `wt switch -c` per `docs/worktree-flow.md` included, and drags the app to another session.
- It fires with `--no-cd` too, so `worktree-pick.sh:31` followed by its own `worktree_open` (`:37`) would open twice. Both could race to `session.create` and make duplicate sessions.
- `post-*` hooks are detached. I didn't verify whether `REX_*` and a usable client survive that. cmux needed `pre-*` for this reason.
- `pre-switch` can't take over, because on create its `worktree_path` is the source.
- Creating through `wt` is still worth having. A LazyGit `worktrees` command with an `input` prompt and `output: terminal` (needed for hook approval prompts) could run `wt switch --create {{.Form.Branch | quote}} --no-cd` and then the design A callback. That fixes the fact that LazyGit's own `n` uses `git worktree add` under `worktree.defaultPath: ~/worktrees` (`lazygit/config.yml:83`). That location doesn't match `worktree-path` (`worktrunk/config.toml:7`), and it skips the `pre-start` bootstrap.

## Recommendation

Build A. It keeps `host.lua` as the only caller of `rex`/`herdr`, reuses `worktree_open` unchanged, and lives in the nvim door. Add the `wt switch --create` custom command from C as the "create" half. Add B only if you also want `<enter>` or branch checkout to follow, or want nvim to `:cd` when there's no host.

## Open questions

- Is Remote Control on (*Settings > Server > Client Info*)? Does the `init.lua:566` comment need updating?
- Should `<enter>` keep the in-process switch, or should both keys open the session?
- Should the Rex `Hyper+g` LazyGit float (`init.lua:348-356`) get the same override? It would need its own overlay (for example `LG_CONFIG_FILE` set in `toggle_float`'s command) calling `rex do worktree_open` directly, because there's no `$NVIM` there.
- Not verified: `wt switch --format=json` field names, symlinked worktree paths, and how `rex do` behaves when more than one app client is connected.
