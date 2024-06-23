-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.g.mapleader = " "

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true --display line numbers
vim.opt.title = true --set the title of the window to the file name
vim.opt.autoindent = true -- auto indent new lines based on previous line

vim.opt.smartindent = true --auto indent new lines
vim.opt.shiftwidth = 2
vim.opt.breakindent = true
vim.opt.hlsearch = true --highlight search results
vim.opt.backup = false --disables vim automatic backups

vim.opt.showcmd = true --show command in status line

vim.opt.cmdheight = 1 --height of the command line
vim.opt.laststatus = 0 --always show status line
vim.opt.scrolloff = 10 --lines of context when scroll_padding

vim.opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"

vim.opt.inccommand = "split" --show the effects of a command incrementally
vim.opt.ignorecase = true --ignore case in search
vim.opt.smarttab = true --use shiftwidth for tabstop

vim.opt.shiftwidth = 2 --number of spaces to use for auto indent
vim.opt.tabstop = 2 --number of spaces that a tab counts for
vim.opt.wrap = false --do not wrap lines
vim.opt.backspace = { "indent", "eol", "start" } --backspace through everything in insert mode
vim.opt.path:append({ "**" }) --search for files in the current directory and subdirectories

vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true --split windows below
vim.opt.splitright = true --split windows to the right
vim.opt.splitkeep = "cursor" --keep the window open when splitting

vim.opt.mouse = "" -- disable mouse support
vim.opt.formatoptions:append({ "r" }) --specify the behavior of formatting text adds the option to continue comments with the comment leader

-- Enable ignorecase + smartcase for better searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
