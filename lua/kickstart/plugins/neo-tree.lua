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
  lazy = false, -- don't lazy-load neo-tree so netrw hijacking on startup works (#1489))
  keys = {
    -- Keep the reveal keymap, it's still useful
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    -- Add a keymap to toggle the tree easily if needed
    { '<leader>e', ':Neotree toggle<CR>', desc = 'Toggle NeoTree', silent = true },
  },
  opts = {
    close_if_last_window = true, -- Close Neo-tree if it's the last window
    auto_clean_after_session_restore = true,
    auto_restore_session_experimental = true, -- https://github.com/nvim-neo-tree/neo-tree.nvim/pull/1366/files
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
    -- Removed open_on_startup = true
    -- Removed global follow_current_file
  },
  -- Removed config function, lazy.nvim handles setup via opts
}
