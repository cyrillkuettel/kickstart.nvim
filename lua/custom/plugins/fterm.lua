return {
  'numToStr/FTerm.nvim',
  config = function()
    local fterm = require 'FTerm'

    -- Setup with minimal configuration
    fterm.setup {
      border = 'rounded',
      dimensions = {
        height = 0.8, -- Height of the terminal window
        width = 0.8, -- Width of the terminal window
        x = 0.5, -- X axis of the terminal window
        y = 0.5, -- Y axis of the terminal window
      },
    }

    -- F4 keybinding for toggling terminal in normal mode
    vim.keymap.set('n', '<F4>', '<CMD>lua require("FTerm").toggle()<CR>')

    -- double Esc for ability to treat the terminal like vim buffer
    vim.keymap.set('t', '<esc><esc>', [[<C-\><C-n>]], { silent = true, noremap = true })
  end,
}
