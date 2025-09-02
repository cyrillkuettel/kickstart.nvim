return {
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      local blame = require 'blame'

      -- Set explicit colors to ensure they're visible
      local explicit_colors = {
        '#ff6188', -- red
        '#a9dc76', -- green
        '#78dce8', -- blue
        '#ffd866', -- yellow
        '#ab9df2', -- purple
        '#fc9867', -- orange
      }
      blame.setup {
        date_format = '%d.%m.%Y',
        virtual_style = 'float',
        focus_blame = false,
        
        merge_consecutive = false,
        max_summary_width = 20,
        colors = explicit_colors,
        blame_options = nil,
        commit_detail_view = 'vsplit',
        mappings = {
          commit_info = 'i',
          stack_push = '<TAB>', -- Like 'annotate with git' blame in Jetbrains
          stack_pop = '<BS>', -- Backspace to go back
          show_commit = '<CR>',
          close = { '<esc>', 'q' },
        },
      }
    end,
  },
}
