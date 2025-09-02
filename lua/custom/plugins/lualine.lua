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
    -- 1. When the window width is narrow (less than or equal to 100 pixels), lualine will display the filename where the branch name would normally be.
    -- 2. When the window is wider, it will show the truncated branch name, and the filename will be in its usual position.
    local function get_branch()
      local head = vim.b.gitsigns_head or vim.g.gitsigns_head
      if not head then
        return ''
      end
      -- Truncate branch name to 15 characters
      if #head > 15 then
        return head:sub(1, 15) .. '...'
      end
      return head
    end

    local width = 100
    opts.sections.lualine_b = {
      {
        get_branch,
        cond = function()
          return vim.fn.winwidth(0) > width
        end,
      },
      {
        'filename',
        path = 1,
        cond = function()
          return vim.fn.winwidth(0) <= width
        end,
      },
    }
    opts.sections.lualine_c = {
      {
        'filename',
        path = 1,
        cond = function()
          return vim.fn.winwidth(0) > width
        end,
      },
    }

    require('lualine').setup(opts)
  end,
}

