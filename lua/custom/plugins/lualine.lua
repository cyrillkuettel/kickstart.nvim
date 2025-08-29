return {
  'nvim-lualine/lualine.nvim',
  name = 'lualine',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      -- theme = 'auto',
      theme = 'codedark',
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = {
        { require('harpoon_files').lualine_component },
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    extensions = { 'trouble', 'neo-tree' },
  },
  config = function(_, opts)
    require('lualine').setup(opts)
  end,
}
