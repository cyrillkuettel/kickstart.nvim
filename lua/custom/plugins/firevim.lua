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
          takeover = 'never', -- Prevents auto-takeover of textareas
        },
      },
    }

    -- Any additional FireVim-specific settings can go here
  end,
}
