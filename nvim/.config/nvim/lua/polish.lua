-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Auto command to set the background of Telescope
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.cmd "hi TelescopeNormal guibg=NONE cterm=NONE" end,
})

-- Auto command to set the border of Telescope
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.cmd "hi TelescopeBorder guibg=NONE cterm=NONE" end,
})
