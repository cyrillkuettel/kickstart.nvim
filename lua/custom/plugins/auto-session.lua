return {
  'rmagatti/auto-session',
  lazy = false,

  opts = {
    log_level = 'error',
    auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },

    pre_cwd_changed_cmds = {
      'Neotree close',
    },
    -- post_restore_cmds = { 'Neotree buffers' },
    pre_save_cmds = {
      'Neotree close',
    },

    use_git_branch = true,
  },
}
