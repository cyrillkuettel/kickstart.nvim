return {
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      local blame = require('blame')
      
      -- Custom format function with first name only, no revision
      local function first_name_date_fn(line_porcelain, config, idx)
        -- Extract first name only
        local first_name = string.match(line_porcelain.author, '^(%S+)')
        local date = os.date(config.date_format, line_porcelain.author_time)
        
        return {
          idx = idx,
          values = {
            { textValue = date, hl = 'Blame' .. line_porcelain.hash },
            { textValue = first_name, hl = 'Blame' .. line_porcelain.hash }
          },
          format = '%s (%s)'  -- Format: date (first_name)
        }
      end
      
      -- Define highlight groups with different intensities
      vim.api.nvim_command('highlight BlameRecent guifg=#50fa7b gui=bold')
      vim.api.nvim_command('highlight BlameDaysOld guifg=#8be9fd')
      vim.api.nvim_command('highlight BlameWeeksOld guifg=#bd93f9')
      vim.api.nvim_command('highlight BlameMonthsOld guifg=#ff79c6')
      vim.api.nvim_command('highlight BlameOld guifg=#6272a4')
      
      blame.setup({
        date_format = '%d.%m.%Y',
        virtual_style = 'float',
        focus_blame = true,
        merge_consecutive = false,
        max_summary_width = 30,
        colors = nil,
        blame_options = nil,
        commit_detail_view = 'vsplit',
        format_fn = first_name_date_fn
      })
    end,
  },
  vim.keymap.set('n', '<leader>g', ':BlameToggle virtual<CR>', 
                 { noremap = true, silent = true }),
}
