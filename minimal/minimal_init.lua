-- Set <space> as the leader key
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ Setting options ]]
-- Set tab width to 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- Use spaces instead of tabs
vim.opt.expandtab = true
-- Smart indenting
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.incsearch = true

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.colorcolumn = '80'
  end,
})

vim.opt.swapfile = false
vim.opt.backup = false
-- Consider changing undodir if HOME might not be writable or ideal
-- For a truly minimal setup, you might disable undofile if persistence isn't critical
-- or ensure the path is always valid in the constrained environment.
local undodir_path = os.getenv 'HOME'
if undodir_path then
  vim.opt.undodir = undodir_path .. '/.vim/undodir'
  vim.opt.undofile = true
else
  -- Fallback or disable if HOME is not set
  vim.opt.undofile = false
end

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'number'

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
-- Deal with it 😎😎😎
vim.keymap.set('n', '<space>', '"_ciw', { desc = 'Change inner word' })

vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Another escape key
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true, desc = 'Exit insert mode with jk' })
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and stay in visual mode' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and stay in visual mode' })

--  Alt + Shift + I / O for jump list navigation.
vim.keymap.set('n', '<A-S-o>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-i>', true, true, true), 'n', false)
end, { noremap = true, silent = true, desc = 'Jump forward in jump list' })
vim.keymap.set('n', '<A-S-i>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>', true, true, true), 'n', false)
end, { noremap = true, silent = true, desc = 'Jump backward in jump list' })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps (basic, without plugin dependency)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('x', 'p', 'P', { desc = 'paste without replacing clipboard' })

-- Use vertical split for vim help
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.txt',
  callback = function()
    if vim.bo.buftype == 'help' and vim.fn.winnr '$' > 1 then
      pcall(function()
        vim.cmd 'wincmd L'
      end)
    end
  end,
})

-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('minimal-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Load Monokai colorscheme
-- output may be messing with terminal
vim.opt.termguicolors = false
vim.cmd 'colorscheme monokai'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
