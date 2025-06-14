return {
  'rmagatti/auto-session',
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    use_git_branch = true,
    git_auto_restore_on_branch_change = true,
    -- log_level = 'debug',
  },
}
