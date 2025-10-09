return {
  'glacambre/firenvim',
  build = ':call firenvim#install(0)',
  config = function()
    -- FireVim configuration
    vim.g.firenvim_config = {
      globalSettings = {
        alt = 'all',
      },
      localSettings = {
        ['.*'] = {
          selector = 'textarea:not([readonly], [aria-readonly])',
          takeover = 'never', -- Prevents auto-takeover of textareas
        },
        ['https?://claude\\.ai/'] = {
          selector = 'div[contenteditable="true"][role="textbox"]',
          takeover = 'never',
          priority = 1,
        },
      },
    }
    -- Any additional FireVim-specific settings can go here
  end,
}
