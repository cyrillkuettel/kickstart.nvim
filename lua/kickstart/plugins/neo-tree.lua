-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false, -- Load at startup instead of lazy loading
  keys = {
    -- Keep the reveal keymap, it's still useful
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    close_if_last_window = false, -- Don't close Neo-tree if it's the last window
    filesystem = {
      window = {
        -- Keep the default mapping to close with \
        mappings = {
          ['\\'] = 'close_window',
          -- You could add other mappings here if needed
        },
        position = 'left', -- Or 'right'
        width = 30, -- Adjust width as needed
      },
      -- Keep Neo-tree open even when opening specific file types
      open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
      follow_current_file = {
        enabled = true, -- Enable following current file in filesystem view
        leave_dirs_open = true, -- Keep directories open when switching files
      },
    },
    buffers = {
      follow_current_file = { enabled = true }, -- Also follow in buffers source
    },
    git_status = {
      follow_current_file = { enabled = true }, -- Also follow in git status source
    },
    -- Set this to true to automatically open Neo-tree at startup
    open_on_startup = true,
    -- Enable global follow current file
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
  },
  config = function(_, opts)
    -- Ensure Neo-tree is setup with the options
    require('neo-tree').setup(opts)
    
    -- Auto-open Neo-tree at startup
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.defer_fn(function()
          vim.cmd("Neotree show")
        end, 10)
      end
    })
  end,
}
