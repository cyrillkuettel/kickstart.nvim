return {
  'rmagatti/auto-session',
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    log_level = 'error',
    auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },

    auto_session_enable_last_session = false,

    pre_cwd_changed_cmds = {
      'Neotree close',
    },

    pre_save_cmds = {
      'Neotree close',
    },

    use_git_branch = true,
    auto_restore_enabled = true,
  },
}
