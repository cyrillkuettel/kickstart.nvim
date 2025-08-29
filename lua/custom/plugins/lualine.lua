return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local harpoon_files = require 'harpoon_files'
    require('lualine').setup {
      options = {
        theme = 'auto',
      },
      sections = {
        lualine_c = {
          { harpoon_files.lualine_component },
        },
      },
    }
  end,
}
