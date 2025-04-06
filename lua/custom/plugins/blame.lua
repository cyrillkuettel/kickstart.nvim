return {
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      local blame = require 'blame'

      -- Custom format function with first name only, no revision
      local function first_name_date_fn(line_porcelain, config, idx)
        -- Extract first name only
        local first_name = string.match(line_porcelain.author, '^(%S+)')
        local date = os.date(config.date_format, line_porcelain.author_time)

        -- Make sure we have a valid hash to create highlight group
        local hash = line_porcelain.hash or ''
        if hash == '' then
          hash = 'unknown'
        end

        -- Use the proper highlight group naming used by the plugin
        local hl_group = 'Blame' .. hash

        return {
          idx = idx,
          values = {
            { textValue = date, hl = hl_group },
            { textValue = ' (' .. first_name .. ')', hl = hl_group },
          },
          format = '%s%s', -- Format: date (first_name)
        }
      end

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
        virtual_style = 'right_align',
        focus_blame = true,
        merge_consecutive = false,
        max_summary_width = 30,
        colors = explicit_colors,
        blame_options = nil,
        commit_detail_view = 'vsplit',
        mappings = {
          commit_info = 'i',
          stack_push = '<TAB>',
          stack_pop = '<BS>',
          show_commit = '<CR>',
          close = { '<esc>', 'q' },
        },
      }
    end,
  },
}
