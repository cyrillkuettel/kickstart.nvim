return {
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      local blame = require 'blame'

      -- Define highlight groups with different intensities (you'd put this somewhere in your colorscheme setup)
      vim.api.nvim_command 'highlight BlameRecent guifg=#50fa7b gui=bold' -- Bright green for very recent
      vim.api.nvim_command 'highlight BlameDaysOld guifg=#8be9fd' -- Cyan for days old
      vim.api.nvim_command 'highlight BlameWeeksOld guifg=#bd93f9' -- Purple for weeks old
      vim.api.nvim_command 'highlight BlameMonthsOld guifg=#ff79c6' -- Pink for months old
      vim.api.nvim_command 'highlight BlameOld guifg=#6272a4' -- Dim blue for old commits

      -- Define custom format function with age-based coloring
      local function age_colored_format_fn(line_porcelain, config, idx)
        local hash = string.sub(line_porcelain.hash, 0, 7)
        local line_with_hl = {}
        local is_commited = hash ~= '0000000'

        if is_commited then
          -- Extract only the first name from the author
          local first_name = string.match(line_porcelain.author, '^(%S+)')

          -- Determine age of commit for coloring
          local commit_time = line_porcelain.committer_time
          local current_time = os.time()
          local age_in_days = (current_time - commit_time) / (60 * 60 * 24)

          -- Choose highlight group based on age
          local highlight
          if age_in_days < 2 then
            highlight = 'BlameRecent' -- Less than 2 days old
          elseif age_in_days < 7 then
            highlight = 'BlameDaysOld' -- Less than a week old
          elseif age_in_days < 30 then
            highlight = 'BlameWeeksOld' -- Less than a month old
          elseif age_in_days < 90 then
            highlight = 'BlameMonthsOld' -- Less than 3 months old
          else
            highlight = 'BlameOld' -- Older than 3 months
          end

          line_with_hl = {
            idx = idx,
            values = {
              {
                textValue = hash,
                hl = 'Comment',
              },
              {
                textValue = os.date(config.date_format, commit_time),
                hl = highlight, -- Use age-based highlight
              },
              {
                textValue = first_name or line_porcelain.author,
                hl = highlight, -- Use age-based highlight
              },
            },
            format = '%s  %s  %s',
          }
        else
          line_with_hl = {
            idx = idx,
            values = {
              {
                textValue = 'Not commited',
                hl = 'Comment',
              },
            },
            format = '%s',
          }
        end
        return line_with_hl
      end

      blame.setup {
        date_format = '%d.%m.%Y',
        virtual_style = 'left_align',
        focus_blame = true,
        merge_consecutive = false,
        max_summary_width = 30,
        colors = nil,
        blame_options = nil,
        commit_detail_view = 'vsplit',
        format_fn = age_colored_format_fn,
      }
    end,
  },
  vim.keymap.set('n', '<leader>g', ':BlameToggle virtual<CR>', { noremap = true, silent = true }),
}
