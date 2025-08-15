return {
  'kdheepak/lazygit.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>ag', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
  },
}
