local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x')
--
-- -- Increment/decrement
-- keymap.set("n", "+", "<C-a>")
-- keymap.set("n", "-", "<C-x>")
--
-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

keymap.set("n", "<C-Space>", "<Cmd>NvimTmuxNavigateNavigateNext<CR>", { silent = true })

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)
keymap.set("n", "<Leader>q", ":quit<Return>", opts)
keymap.set("n", "<Leader>Q", ":qa<Return>", opts)

-- File explorer with NvimTree
keymap.set("n", "<Leader>f", ":NvimTreeFindFile<Return>", opts)
keymap.set("n", "<Leader>t", ":NvimTreeToggle<Return>", opts)

-- Tabs
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
keymap.set("n", "tw", ":tabclose<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")
--
-- Diagnostics
keymap.set("n", "<C-q>", function()
  vim.diagnostic.goto_next()
end, opts)

--Move entire line up and down
keymap.set("n", "<C-k>", ":m .-2<CR>==") -- move line down(n)
keymap.set("n", "<C-j>", ":m .+1<CR>==") -- move line up(n)

keymap.set("n", "<Leader>;f", ":Telescope find_files<cr> . ' . expand('<cword>')", opts)

-- Map MaximizerToggle (szw/vim-maximizer) yo leader-m
keymap.set("n", "<leader>m", ":MaximizerToggle<cr>")

-- Make split windows equal in size
keymap.set("n", "<leader>=", "<C-w>=")

--Jump to the start/end of line:
keymap.set("n", "L", "$")
keymap.set("n", "H", "^")
