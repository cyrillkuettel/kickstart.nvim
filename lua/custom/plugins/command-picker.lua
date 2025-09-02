return {
  -- A custom plugin by me just to have some commonly used commmands easily available
  -- but don't want to set a keybinding.
  -- Cyrill:
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = function()
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'
    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local conf = require('telescope.config').values

    -- Define commonly used commands
    local commands = {
      {
        name = 'Get Current Working Directory',
        command = function()
          print(vim.fn.getcwd())
        end,
      },
      { name = 'Gitsigns reset_hunk', command = ':Gitsigns reset_hunk' },
      { name = 'LSP Restart', command = ':LspRestart' },
      { name = 'Telescope Builtin', command = ':Telescope builtin' },
      { name = 'Git Status', command = ':Telescope git_status' },
      { name = 'Checkhealth', command = ':checkhealth' },
      { name = 'LazyGitFilter', command = ':LazyGitFilter' }, -- Shows all commits
      { name = 'LazyGitFilterCurrentFile', command = ':LazyGitFilterCurrentFile' }, -- shows a floating window with commits current file
    }

    local command_picker = function(opts)
      opts = opts or {}
      pickers
        .new(opts, {
          prompt_title = "Cyrill's Common Commands",
          layout_strategy = 'vertical',
          layout_config = {
            height = 0.4,
            width = 0.6,
          },
          finder = finders.new_table {
            results = commands,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.name,
                ordinal = entry.name,
              }
            end,
          },
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection and selection.value then
                local cmd = selection.value.command
                if type(cmd) == 'function' then
                  cmd()
                else
                  vim.cmd(cmd)
                end
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Create the keymap
    vim.keymap.set('n', '<leader>mc', command_picker, { desc = 'My Common Commands Picker' })
  end,
}
