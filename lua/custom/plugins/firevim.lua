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
          selector = 'textarea:not([readonly], [aria-readonly]),  div[role="textbox"],  div[contenteditable="true"].ProseMirror[max-w="[60ch]"]',
          takeover = 'never', -- Prevents auto-takeover of textareas
        },
      },
    }
    -- Any additional FireVim-specific settings can go here
  end,
}

