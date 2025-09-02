return {
  --'ThePrimeagen/harpoon',
  'gin31259461/harpoon', -- Unmerged pull request, also restore cursor position
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup {}

    local function toggle_telescope(harpoon_files)
      local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require('telescope.finders').new_table {
          results = paths,
        }
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          -- NOTE: If at any time i switch to using git worktrees, i can get rid of this
          mark_branch = true, -- https://github.com/ThePrimeagen/harpoon/pull/98/files
          finder = finder(),
          previewer = false,
          sorter = require('telescope.config').values.generic_sorter {},
          layout_config = {
            height = 0.4,
            width = 0.5,
            prompt_position = 'top',
            preview_cutoff = 120,
          },
          attach_mappings = function(prompt_bufnr, map)
            map('i', '<C-d>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)

              table.remove(harpoon_files.items, selected_entry.index)
              current_picker:refresh(finder())
            end)
            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<A-s>', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })

    vim.keymap.set('n', '<leader>h', function()
      harpoon:list():add()
    end, { desc = 'Harpoon: Add file' })

    vim.keymap.set('n', '<A-1>', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon: Go to file 1' })
    vim.keymap.set('n', '<A-2>', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon: Go to file 2' })
    vim.keymap.set('n', '<A-3>', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon: Go to file 3' })
    vim.keymap.set('n', '<A-4>', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon: Go to file 4' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-S-P>', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon: Previous file' })
    vim.keymap.set('n', '<C-S-N>', function()
      harpoon:list():next()
    end, { desc = 'Harpoon: Next file' })
  end,
}
