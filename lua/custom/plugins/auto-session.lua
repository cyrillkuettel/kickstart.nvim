return {
  'rmagatti/auto-session',
  lazy = false,
  dependencies = { 'shortcuts/no-neck-pain.nvim' },
  priority = 9999, -- <-- FIX: Load it before almost everything else

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    use_git_branch = true,
    git_auto_restore_on_branch_change = true,
    post_restore_cmds = { 'silent! NoNeckPain' },
    pre_save_cmds = { 'silent! NoNeckPainDisable' },
    -- log_level = 'debug',
  },
}
