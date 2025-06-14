--
-- 1. really really need more options for full text search in telescope
-- Neotree show current file if neotree shown
-- switch ,, to alt + f4, reasonable to always use last files
-- todo: change only in files which were touched by git, in diff and in all commits which are local

--[[

What is Kickstart?

  Kickstart.nvim is *not* a distribution.


  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html


  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
--
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
  -- I used to have this, but I actuallly only care about 80 char limit in python files
  -- vim.opt.colorcolumn = '80'
  pattern = 'python',
  callback = function()
    vim.opt_local.colorcolumn = '80'
  end,
})

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.opt.undofile = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true
vim.opt.signcolumn = 'number'

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- for https://github.com/rmagatti/auto-session
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

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
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Format visual selection with black --line-ranges
local function format_visual_black()
  -- Todo: it would be more performant if this made a request to blackd server.
  -- Currently I assume this creates new process (!) every time you run format.
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  local file_path = vim.fn.expand '%:p' -- Get full path

  -- Basic check: Need a saved file
  if file_path == '' then
    print 'Error: Save the file first.'
    return
  end

  -- Simplified command construction and execution
  -- Note: vim.fn.shellescape is still crucial for filenames with spaces/symbols!
  local black_executable = vim.fn.executable 'black' == 1 and 'black' or 'python3.11 -m black'
  local cmd_parts = {
    black_executable,
    '-q',
    '--line-length',
    '79',
    '--skip-string-normalization',
    '--line-ranges',
    string.format('%d-%d', start_line, end_line),
    end_line,
    file_path, -- vim.fn.system handles shell escaping for individual arguments
  }

  -- Run the command and capture output
  local output = vim.fn.systemlist(cmd_parts)
  if vim.v.shell_error ~= 0 then
    vim.notify('Black formatting failed:\n' .. table.concat(output, '\n'), vim.log.levels.ERROR)
    return
  end

  -- Check if file changed on disk and prompt to reload if it did.
  -- If black failed, this will likely do nothing.
  vim.cmd 'checktime'
end

-- Deal with it 😎😎😎
vim.keymap.set('n', '<space>', '"_ciw', { desc = 'Change inner word' })

vim.keymap.set('n', '<leader>bt', ':BlameToggle Window<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gg', ':LazyGit<cr>', { noremap = true, silent = true })

vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Set the keymap in visual mode
vim.keymap.set('v', '<leader>b', format_visual_black, {
  noremap = true,
  silent = true, -- Keymap itself is silent; :! might still show errors
  desc = 'Format selection with Black (--line-ranges, simple)',
})

vim.keymap.set('n', '<leader>fml', '<cmd>CellularAutomaton make_it_rain<CR>', { desc = 'Make it rain animation' })

vim.keymap.set('n', '<S-Tab>', ':Neotree toggle reveal<CR>', { noremap = true, silent = true, desc = 'Toggle NeoTree reveal' })

-- Another escape key
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true, desc = 'Exit insert mode with jk' })
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and stay in visual mode' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and stay in visual mode' })

--  Alt + Shift + I  for my favorite navigation.
-- Remove all the Ctrl+I and Ctrl+O mappings first
-- This makes Alt+Shift+O jump forward (opposite of normal Ctrl+O)
vim.keymap.set('n', '<A-S-o>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-i>', true, true, true), 'n', false)
end, { noremap = true, silent = true, desc = 'Jump forward in jump list' })
-- This makes Alt+Shift+I jump backward (opposite of normal Ctrl+I)
vim.keymap.set('n', '<A-S-i>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>', true, true, true), 'n', false)
end, { noremap = true, silent = true, desc = 'Jump backward in jump list' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.api.nvim_create_user_command('MakeLint', function()
  -- Run linting and put things int quicklist
  -- Requires you to have a makefile with 'make lint'
  local old_makeprg = vim.o.makeprg
  vim.o.makeprg = 'make lint'
  local old_errorformat = vim.o.errorformat
  vim.o.errorformat = '%f:%l:%c:%m,%f:%l:%m'

  -- Run the command, put results in quickfix, and open the quickfix window
  vim.cmd 'silent make! | cwindow'
  vim.cmd 'redraw!' -- Refresh display
  vim.o.makeprg = old_makeprg
  vim.o.errorformat = old_errorformat
end, { desc = 'Run "make lint" and show results in quickfix' })

vim.keymap.set('n', '<leader>l', '<cmd>MakeLint<CR>', { desc = '[M]ake [L]int' })
-- Jump to next point in quickfix list, without leaving the window
vim.keymap.set('n', '<C-n>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-p>', '<cmd>cprev<CR>zz')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Function to toggle Aider window
_G.ToggleAiderWindow = function()
  if vim.g.aider_floatwin_id and vim.api.nvim_win_is_valid(vim.g.aider_floatwin_id) then
    vim.cmd 'AiderHide'
  else
    vim.cmd 'AiderRun'
  end
end
-- Global shortcut to toggle Aider window, works in normal, insert, and terminal modes
vim.keymap.set({ 'n', 'i', 't' }, '<F7>', function()
  _G.ToggleAiderWindow()
end, { noremap = true, silent = true, desc = 'Toggle Aider Window' })

-- colorscheme switching shortcut [cyrill]
vim.api.nvim_create_user_command('ColorSchemeSwitch', function()
  require('telescope.builtin').colorscheme()
end, { desc = 'Switch Colorscheme' })

vim.keymap.set('n', '<leader>cs', ':ColorSchemeSwitch<CR>', { desc = 'Switch Colorscheme' })

-- Command to yank current absolute path of current buffer to clipboard
vim.api.nvim_create_user_command('YankAbsolutePath', function()
  local path = vim.fn.expand '%:p'
  if path ~= '' then
    vim.fn.setreg('+', path)
    vim.notify('Copied to clipboard: ' .. path)
  else
    vim.notify('No file name to copy.', vim.log.levels.WARN)
  end
end, { desc = 'Yank absolute path of current buffer to clipboard' })
-- Keymap for YankAbsolutePath
vim.keymap.set('n', '<leader>yp', '<cmd>YankAbsolutePath<CR>', { desc = '[Y]ank current buffer [P]ath' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- I do never really use horizontal split really, so I'd rather use these bindings for harpoon.
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
vim.keymap.set('x', 'p', 'P', { desc = 'paste without replacing clipboard' })

-- Use vertical split for vim help
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.txt',
  callback = function()
    if vim.bo.buftype == 'help' and vim.fn.winnr '$' > 1 then
      -- Only attempt to move the window if there are multiple windows
      -- and we're not in the process of closing
      pcall(function()
        vim.cmd 'wincmd L'
      end)
    end
  end,
})

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Using Ruff alongside basdpyright, therefore we defer to that
-- language server for certain capabilities, like textDocument/hover:
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.
  change_detection = {
    -- Try to avoid this annoying red message appearing form lazy
    -- Happens every time I change a nvim config.
    enabled = false,
    notify = false,
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  {
    'michaeljsmith/vim-indent-object',
    lazy = false,
  },
  { -- Nice looking floating command line
    'VonHeikemen/fine-cmdline.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
  },
  {
    'eandrju/cellular-automaton.nvim',
    lazy = false,
  },

  { -- Buffer Line (Tabs) [cyrill]
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('bufferline').setup {
        options = {
          mode = 'tabs',
          separator_style = 'slant',
          always_show_bufferline = true,
          show_buffer_close_icons = vim.g.have_nerd_font,
          show_close_icon = vim.g.have_nerd_font,
        },
      }
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local focus_preview = function(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local picker = action_state.get_current_picker(prompt_bufnr)
        local prompt_win = picker.prompt_win
        local previewer = picker.previewer
        local winid = previewer.state.winid
        local bufnr = previewer.state.bufnr

        -- original focus mapping
        vim.keymap.set('n', '<Tab>', function()
          vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
        end, { buffer = bufnr })
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))

        -- use <leader>w to save to real file in preview
        vim.keymap.set('n', '<leader>w', function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local entry = require('telescope.actions.state').get_selected_entry()
          local filename = require('plenary.path'):new(entry.filename):normalize(vim.loop.cwd())
          local real_buf = vim.fn.bufadd(filename)
          vim.fn.bufload(real_buf)
          vim.api.nvim_buf_call(real_buf, function()
            vim.api.nvim_buf_set_lines(real_buf, 0, -1, false, lines)
            vim.cmd.write()
          end)
        end, { buffer = bufnr })

        -- api.nvim_set_current_win(winid)
      end

      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        defaults = {
          mappings = {
            i = {
              -- Bind Tab in insert mode
              -- disable because I suspect it might cause wird behavior if editign text in normal mode in telescope search
              -- ['<Tab>'] = focus_preview,
              ['<c-d>'] = actions.delete_buffer,

              ['<C-v>'] = actions.select_vertical,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-t>'] = actions.select_tab,
            },
            n = {
              -- Bind Tab in normal mode
              -- ['<Tab>'] = focus_preview,

              -- for opening in splits from normal mode
              ['<C-v>'] = actions.select_vertical,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-t>'] = actions.select_tab,
              ['<c-d>'] = actions.delete_buffer,
              ['p'] = function(prompt_bufnr)
                local clipboard = vim.fn.getreg '+' -- or use '"' for unnamed
                local picker = action_state.get_current_picker(prompt_bufnr)
                local current_line = picker:_get_prompt()
                picker:set_prompt(current_line .. clipboard)
              end,
            },
          },
        },
        pickers = {
          live_grep = {
            additional_args = function()
              -- I rarely use regex, I prefer literal match
              return { '--fixed-strings' }
            end,
          },
          oldfiles = {
            -- Limit the number of oldfiles shown
            cwd_only = true, -- Set to true if you only want files from current directory
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local previewers = require 'telescope.previewers'

      vim.keymap.set('n', ',sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', ',sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      -- I really like fyf to search and go to files.
      vim.keymap.set('n', 'fyf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', ',ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', ',sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

      -- Most used command by far
      vim.keymap.set('n', ',,', builtin.live_grep, { desc = '[S]earch by [G]rep' })

      local delta_commits = previewers.new_termopen_previewer {
        get_command = function(entry)
          if not entry or not entry.value then
            return { 'echo', 'Invalid commit entry' }
          end

          -- We need to make sure the current_file path is relative to the git root
          if not entry.current_file then
            return { 'echo', 'No file specified' }
          end

          -- Get absolute path of the current file directory
          local current_file_dir = vim.fn.expand '%:p:h' -- Changed quotes to double quotes

          -- Find the git root
          local git_root_command = 'git -C "' .. current_file_dir .. '" rev-parse --show-toplevel 2>/dev/null'
          local git_root = vim.fn.system(git_root_command):gsub('\n', '')

          if vim.v.shell_error ~= 0 then
            return { 'echo', 'Not in a git repository' }
          end

          -- Change to the git root directory and run the diff command there
          local cmd = {
            'sh',
            '-c',
            'cd "'
              .. git_root
              .. '" && '
              .. 'git -c core.pager=delta -c delta.side-by-side=false diff '
              .. entry.value
              .. '^! -- "'
              .. entry.current_file
              .. '"',
          }

          return cmd
        end,
      }

      local my_git_commits = function(opts)
        opts = opts or {}
        -- Get the directory of the currently open file
        local current_file_dir = vim.fn.expand '%:p:h' -- Changed quotes to double quotes
        -- Check if we're in a git repository *relative to the file*
        local git_root_command_string = 'git -C "' .. current_file_dir .. '" rev-parse --show-toplevel 2>/dev/null'
        local git_root = vim.fn.system(git_root_command_string):gsub('\n', '')
        if vim.v.shell_error ~= 0 then
          vim.notify('Not in a git repository (for the current file)', vim.log.levels.WARN)
          return
        end
        -- Set the cwd option to the git root directory
        opts.cwd = git_root
        opts.previewer = {
          delta_commits,
          previewers.git_commit_message.new(opts),
          previewers.git_commit_diff_as_was.new(opts),
        }
        builtin.git_commits(opts)
      end
      vim.keymap.set('n', ',gc', my_git_commits, { desc = '[G]it [C]ommits' })

      vim.keymap.set('n', ',gs', builtin.git_status, { desc = '[G]it [S]tatus' })

      vim.keymap.set('n', ',sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', ',rs', builtin.resume, { desc = '[S]earch [R]esume' })

      -- vim.keymap.set({ 'n', 'i' }, ',,', '<cmd>Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Recent files' })
      -- Using these two mainly for navigation
      vim.keymap.set('n', '..', builtin.buffers, { desc = '[ ] Find existing buffers' })
      --
      -- Use s for the fastes available search.
      vim.keymap.set('n', 's', '/', { desc = 'Search' })

      -- Slightly advanced example of overriding default behavior and theme
      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', ',sc', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', ',sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', ',gn', function()
        local config_dir = vim.fn.stdpath 'config'
        require('telescope.builtin').live_grep {
          prompt_title = 'Search Neovim Config',
          cwd = config_dir,
        }
      end, { desc = 'Grep in Neovim config files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', version = '^1.0.0', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', version = '^1.0.0' },

      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        --
        --
        -- For type checking we use mypy. So I only need basedpyright for
        -- auto resolving imports, go to definition and the like.
        -- This will overwrite the project specific settings
        basedpyright = {
          enabled = true,
          settings = {
            basedpyright = {
              exclude = { os.getenv 'HOME' }, -- to prevent lag, do not enable if file opened in home dir
              analysis = {
                -- typeshedPaths = { '/home/cyrill/onegov-cloud/stubs' },

                -- Enable a basic level of checking, else auto import won't work.
                -- basedpyright very intrusive with errors, this calms it down
                typeCheckingMode = 'standard',

                reportMissingSuperCall = 'none',

                inlayHints = { callArgumentNames = true },

                diagnosticSeverityOverrides = {

                  -- *** : Turn OFF reporting for specific type errors ***
                  -- See 'Type Check Rule Overrides': https://docs.basedpyright.com/latest/configuration/config-files/
                  reportAny = false,
                  reportMissingTypeArgument = false,
                  reportMissingTypeStubs = false,
                  reportUnknownArgumentType = false,
                  reportUnknownMemberType = false,
                  reportUnknownParameterType = false,
                  reportUnknownVariableType = false,
                  reportUnusedCallResult = false,
                  reportGeneralTypeIssues = 'none',
                  reportPropertyTypeMismatch = 'none',
                  reportFunctionMemberAccess = 'none',
                  reportMissingParameterType = 'none',
                  reportIncompatibleMethodOverride = 'none',
                  reportIncompatibleVariableOverride = 'none',
                  reportInconsistentConstructor = 'none',
                  reportAssignmentType = 'none',
                  reportAttributeAccessIssue = 'none',
                },

                useLibraryCodeForTypes = true,

                -- You might want to keep these 'warning'/'error' or remove the lines
                -- reportUndefinedVariable = 'warning',
                -- reportMissingImports = 'warning',
                -- reportUnusedImport = 'warning',
              },
              -- verboseOutput = true, -- Keep for debugging if needed
            },
          },
        },
        ruff = {
          enabled = true,
          settings = {
            logLevel = 'info',
            rules = {
              -- The 'line too long' and similar linting errors, these are automatically fixable, so 't report errors for that.
              ignore = { 'W293', 'E303' },
            },
          },
        },

        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {},
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        -- Python is also disabled to avoid creating huge diffs. I'd rather
        -- format specific file sections.
        local disable_filetypes = { c = true, cpp = true, python = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
            -- This undojoin is useful because of the autosave plugin + format on save. It will undo the last change AND the formatting, which is what you generaly want.
            undojoin = true,
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        -- python = { 'ruff_fix' },
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          -- : try this out
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-e>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  --[[
  {
    'ellisonleao/gruvbox.nvim',
    priority = 900,
    config = function()
      vim.notify('Gruvbox config function is being executed!', vim.log.levels.INFO)
      vim.o.background = 'dark' -- or "light" for light mode
      vim.cmd 'colorscheme gruvbox' -- Add this line here
    end,
    opts = ...,
  },
]]
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    --
    'crusoexia/vim-monokai',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'monokai'

      -- Overwrite background color to be darker
      vim.cmd.hi 'Normal guibg=#0a0a0a ctermbg=232'

      -- Set the color for plain text
      -- vim.cmd.hi 'Normal guifg=#FFFFFF' -- This line sets the text color to white

      -- Try to override imports
      --vim.cmd.hi 'Include guifg=#FFFFFF ctermfg=15'
      --vim.cmd.hi 'PreProc guifg=#FFFFFF ctermfg=15' -- This often controls import styling

      -- You can configure highlights by doing something like:
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup {
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',
          update_n_lines = '',

          -- Add this only if you don't want to use extended mappings
          suffix_last = '',
          suffix_next = '',
        },
        search_method = 'cover_or_next',
      }

      -- Remap adding surrounding to Visual mode selection
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

      -- Make special mapping for "add surrounding for line"
      vim.keymap.set('n', 'yss', 'ys_', { remap = true })

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'python', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  { -- Show code context
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end,
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  --
  require 'kickstart.plugins.neo-tree',

  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
  --
  -- My custom plugins
  { import = 'custom.plugins' },

  {
    'nekowasabi/aider.vim',
    dependencies = 'vim-denops/denops.vim',
    config = function()
      local cmd_file = vim.fn.expand '~/.local/bin/custom/aider_command'
      -- Somehow env vars in .bash_profile are not recognized if we run this we have to provide api keys through the cli
      -- This however necessitates putting the command in a external file
      local default_cmd = 'aider --vim --edit-format udiff-simple --no-attribute-author --no-attribute-committer --model gemini-2.5-pro-preview-03-25'
      if vim.fn.filereadable(cmd_file) == 1 then
        local cmd_content = vim.fn.readfile(cmd_file)
        vim.g.aider_command = table.concat(cmd_content, ' ')
      else
        vim.g.aider_command = default_cmd
      end

      vim.g.aider_buffer_open_type = 'floating'
      vim.g.aider_floatwin_width = 100
      vim.g.aider_floatwin_height = 20

      vim.api.nvim_create_autocmd('User', {
        pattern = 'AiderOpen',
        callback = function(args)
          vim.g.aider_terminal_bufnr = args.buf -- Store Aider's terminal buffer ID
          vim.g.aider_floatwin_id = args.winid -- Store Aider's floating window ID
          vim.g.aider_channel_id = args.channel -- Store Aider's channel ID
          vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = args.buf, noremap = true, silent = true, desc = 'Aider: Exit terminal mode' })
          vim.keymap.set('n', '<Esc>', '<cmd>AiderHide<CR>', { buffer = args.buf, noremap = true, silent = true, desc = 'Aider: Hide window (Normal mode)' })
          -- Ensure F7 hides the Aider window when pressed from within Aider's terminal/normal/insert mode
          vim.keymap.set({ 't', 'n', 'i' }, '<F7>', '<cmd>AiderHide<CR>', { buffer = args.buf, noremap = true, silent = true, desc = 'Aider: Hide window' })
        end,
      })
      -- https://github.com/nekowasabi/aider.vim
      vim.api.nvim_set_keymap('n', '<leader>at', ':AiderRun<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>aa', ':AiderAddCurrentFile<CR>', { noremap = true, silent = true, desc = 'Aider: Add current file (clear input)' })
      vim.api.nvim_set_keymap('n', '<leader>ar', ':AiderAddCurrentFileReadOnly<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ax', ':AiderExit<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ai', ':AiderAddIgnoreCurrentFile<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aI', ':AiderOpenIgnore<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aI', ':AiderPaste<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ah', ':AiderHide<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>afa', function()
        require('telescope.builtin').oldfiles {
          attach_mappings = require('custom.aider_telescope').aider_attach_mappings,
        }
      end, { desc = '[A]ider add [O]ldfiles' })
      vim.api.nvim_set_keymap('v', '<leader>av', ':AiderVisualTextWithPrompt<CR>', { noremap = true, silent = true })
    end,
  },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}) -- lazy setup

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
