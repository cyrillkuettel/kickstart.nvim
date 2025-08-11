return {
  'rmagatti/auto-session',
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },

    cwd_change_handling = true,
    pre_cwd_changed_cmds = {
      'Neotree close',
    },
    use_git_branch = true,
    -- log_level = 'debug',
  },
}
