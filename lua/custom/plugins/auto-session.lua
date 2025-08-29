return {
  'rmagatti/auto-session',
  lazy = false,
  cond = not vim.g.started_by_firenvim,
  opts = {
    log_level = 'error',
    auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },

    preserve_buffer_on_restore = function(bufnr)
      -- Function that returns true if a buffer should be preserved when restoring a session
      -- we don't want to restore the noneckpain buffers as it would erroneously set these to the middle window? which doesn't make any sense why it does that
      return not (vim.bo[bufnr].buftype == 'nofile' and vim.bo[bufnr].filetype == 'no-neck-pain')
    end,

    pre_cwd_changed_cmds = {
      'Neotree close',
    },

    -- post_restore_cmds = { 'Neotree buffers' },
    pre_save_cmds = {
      'Neotree close',
      -- Un-toggle NoNeckPain before closing nvim
      function()
        if require('no-neck-pain').state.enabled then
          vim.cmd 'NoNeckPain'
        end
      end,
    },
    -- Close buffers with the 'no-neck-pain' filetype before saving the session
    close_filetypes_on_save = { 'no-neck-pain' },
    use_git_branch = true,
    show_auto_restore_notif = true, -- Whether to show a notification when auto-restoring
  },
}
