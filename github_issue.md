## Telescope preview window loses focus immediately after tabbing in Neovim 0.12.0-dev

**Describe the bug**
When using Telescope with a custom `focus_preview` function, pressing `Tab` to switch focus from the Telescope prompt to the preview window results in the focus immediately jumping back to the prompt window. This makes it impossible to interact with the preview window as intended.

**To Reproduce**
Steps to reproduce the behavior:
1. Use Neovim `0.12.0-dev-467+g5ebaf83256`.
2. Configure Telescope with the `focus_preview` function as shown in the "Relevant Configuration" section below. This function is mapped to `<Tab>` in both insert and normal modes within Telescope.
3. Open a Telescope picker that utilizes a preview window (e.g., `Telescope find_files` or `Telescope live_grep`).
4. While the Telescope picker is active, press `Tab`.

**Expected behavior**
After pressing `Tab`, the focus should switch to the Telescope preview window and remain there. This would allow for interaction with the preview buffer, such as scrolling or editing (if the `focus_preview` function is configured for editing, as in the example).

**Actual behavior**
After pressing `Tab`, the focus momentarily appears to switch to the preview window, but then immediately jumps back to the Telescope prompt window. The cursor remains in the prompt input area, and the preview window is not focused.

**Environment (please complete the following information):**
- Neovim Version (Working): `Nvim 0.11.2`
- Neovim Version (Not Working): `Nvim 0.12.0-dev-467+g5ebaf83256`

**Relevant Configuration**
The issue is observed with the following Telescope configuration, specifically the `focus_preview` function and its mapping:

```lua
-- Relevant part of init.lua or Telescope configuration

-- ... (other Telescope dependencies like plenary, nvim-web-devicons, etc.)

config = function()
  local focus_preview = function(prompt_bufnr)
    -- This allows to edit text inside the telescope preview window.
    -- Press TAB to cycle focus between search window and preview
    -- Changes will be saved automatically

    local action_state = require 'telescope.actions.state'
    local picker = action_state.get_current_picker(prompt_bufnr)
    local prompt_win = picker.prompt_win
    local previewer = picker.previewer
    local winid = previewer.state.winid
    local bufnr = previewer.state.bufnr

    -- Auto-save on text changes (example functionality within focus_preview)
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
      buffer = bufnr,
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local entry = action_state.get_selected_entry()
        if entry and entry.filename then
          local filename = require('plenary.path'):new(entry.filename):normalize(vim.loop.cwd())
          local real_buf = vim.fn.bufadd(filename)
          vim.fn.bufload(real_buf)
          vim.api.nvim_buf_call(real_buf, function()
            vim.api.nvim_buf_set_lines(real_buf, 0, -1, false, lines)
            vim.cmd.write()
          end)
        end
      end,
    })

    -- Keymap to return focus to the prompt window from the preview window
    vim.keymap.set('n', '<Tab>', function()
      vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
    end, { buffer = bufnr })

    -- Switch focus to the preview window
    vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
  end

  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ['<Tab>'] = focus_preview,
          -- other insert mode mappings
        },
        n = {
          ['<Tab>'] = focus_preview,
          -- other normal mode mappings
        },
      },
    },
    -- other Telescope pickers and extensions configuration
  }

  -- ... (loading Telescope extensions, other keymaps for Telescope builtins)
end,
```

**Additional context**
This behavior started after updating from Neovim 0.11.2 to the specified 0.12.0-dev version. The configuration worked as expected in 0.11.2, allowing focus to shift to and remain in the preview window upon pressing `Tab`. The core of the `focus_preview` function is `vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))` which is intended to set the current window to the previewer's window.
