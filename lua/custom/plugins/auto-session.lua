return {
  'rmagatti/auto-session',
  lazy = false,
  cond = not vim.g.started_by_firenvim,
  opts = {
    log_level = 'error',
    enabled = true, -- Enables/disables auto creating, saving and restoring
    auto_save = true, -- Enables/disables auto saving session on exit
    auto_restore = true, -- Enables/disables auto restoring session on start
    -- auto_create = true, -- Enables/disables auto creating new session files. Can be a function that returns true if a new session file should be allowed
    auto_restore_last_session = false, -- On startup, loads the last saved session if session for cwd does not exist
    cwd_change_handling = false, -- Automatically save/restore sessions when changing directories

    pre_cwd_changed_cmds = {
      'Neotree close',
    },

    -- post_restore_cmds = { 'Neotree buffers' },
    pre_save_cmds = {
      'Neotree close',
      -- Manually find and delete no-neck-pain buffers before saving the session.
      -- This is a robust, synchronous way to prevent them from being saved,
      -- avoiding race conditions with the plugin's own commands on exit.
      function()
        local bufs_to_delete = {}
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[bufnr].filetype == 'no-neck-pain' then
            table.insert(bufs_to_delete, bufnr)
          end
        end

        if #bufs_to_delete > 0 then
          vim.notify(
            'AutoSession: Removing ' .. #bufs_to_delete .. ' no-neck-pain buffer(s) before saving.',
            vim.log.levels.INFO
          )
          for _, bufnr in ipairs(bufs_to_delete) do
            -- Force delete the buffer without saving
            vim.api.nvim_buf_delete(bufnr, { force = true })
          end
        end
      end,
    },
    use_git_branch = true,
    show_auto_restore_notif = false, -- Whether to show a notification when auto-restoring
  },
}
