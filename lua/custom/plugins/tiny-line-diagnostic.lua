return {
  -- Extensive configuration only found in :help tiny-inline-diagnostic.nvim-table-of-contents
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy', -- Or `LspAttach`
  priority = 1000, -- needs to be loaded in first
  config = function()
    require('tiny-inline-diagnostic').setup {
      options = {
        format = function(diagnostic)
          return diagnostic.message
        end,
        show_source = {
          -- Display the source of the diagnostic (e.g., basedpyright, vsserver, lua_ls etc.)
          enabled = true,
          -- Show source only when multiple sources exist for the same diagnostic
          if_many = true,
        },
      },
    }
    vim.diagnostic.config { virtual_text = false } -- Only if needed in your configuration, if you already have native LSP diagnostics
    vim.cmd 'highlight TinyInlineDiagnosticVirtualTextError gui=italic'
    vim.cmd 'highlight TinyInlineDiagnosticVirtualTextWarn gui=italic'
    vim.cmd 'highlight TinyInlineDiagnosticVirtualTextInfo gui=italic'
    vim.cmd 'highlight TinyInlineDiagnosticVirtualTextHint gui=italic'
  end,
}
