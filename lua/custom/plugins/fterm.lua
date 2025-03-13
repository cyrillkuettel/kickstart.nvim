return {
  'numToStr/FTerm.nvim',
  config = function()
    local fterm = require 'FTerm'

    -- Setup with minimal configuration
    fterm.setup {
      border = 'rounded',
      dimensions = {
        height = 0.8,
        width = 0.8,
      },
    }

    -- F4 keybinding for toggling terminal in normal mode
    vim.keymap.set('n', '<F4>', '<CMD>lua require("FTerm").toggle()<CR>')
    -- F4 keybinding for toggling terminal in terminal mode
    vim.keymap.set('t', '<F4>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  end,
}
