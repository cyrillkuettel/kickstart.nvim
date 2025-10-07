-- Custom Telescope search keymaps
-- Extracted for easier navigation and maintenance

return function(builtin, previewers)
  -- Basic search commands
  vim.keymap.set('n', ',sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', ',sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', ',ts', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', ',ss', '<cmd>AutoSession search<CR>', { desc = '[S]earch [S]essions' })
  vim.keymap.set('n', ',sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

  -- Most used command - K for full text search
  -- Default K looks up word under cursor in man pages (rarely useful so we're overriding here)
  vim.keymap.set('n', 'K', builtin.live_grep, { desc = '' })

  -- Git-related searches
  local delta_commits = previewers.new_termopen_previewer {
    get_command = function(entry)
      if not entry or not entry.value then
        return { 'echo', 'Invalid commit entry' }
      end

      if not entry.current_file then
        return { 'echo', 'No file specified' }
      end

      local current_file_dir = vim.fn.expand '%:p:h'
      local git_root_command = 'git -C "' .. current_file_dir .. '" rev-parse --show-toplevel 2>/dev/null'
      local git_root = vim.fn.system(git_root_command):gsub('\n', '')

      if vim.v.shell_error ~= 0 then
        return { 'echo', 'Not in a git repository' }
      end

      local cmd = {
        'sh',
        '-c',
        'cd "'
          .. git_root
          .. '" && '
          .. 'git -c core.pager=delta -c delta.side-by-side=false diff '
          .. entry.value
          .. '^! -- "'
          .. entry.current_file
          .. '"',
      }

      return cmd
    end,
  }

  local my_git_commits = function(opts)
    opts = opts or {}
    local current_file_dir = vim.fn.expand '%:p:h'
    local git_root_command_string = 'git -C "' .. current_file_dir .. '" rev-parse --show-toplevel 2>/dev/null'
    local git_root = vim.fn.system(git_root_command_string):gsub('\n', '')
    if vim.v.shell_error ~= 0 then
      vim.notify('Not in a git repository (for the current file)', vim.log.levels.WARN)
      return
    end
    opts.cwd = git_root
    opts.previewer = {
      delta_commits,
      previewers.git_commit_message.new(opts),
      previewers.git_commit_diff_as_was.new(opts),
    }
    builtin.git_commits(opts)
  end
  vim.keymap.set('n', ',gc', my_git_commits, { desc = '[G]it [C]ommits' })
  vim.keymap.set('n', ',gs', builtin.git_status, { desc = '[G]it [S]tatus' })

  -- Diagnostics and buffers
  vim.keymap.set('n', ',sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', ',rs', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set({ 'n', 'i' }, ',of', '<cmd>Telescope oldfiles<CR>', { noremap = true, silent = true, desc = 'Recent files' })
  vim.keymap.set('n', '..', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', 's', '/', { desc = 'Search' })

  -- Current buffer fuzzy find
  vim.keymap.set('n', ',sf', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- Neovim config searches
  vim.keymap.set('n', ',sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })

  vim.keymap.set('n', ',gn', function()
    local config_dir = vim.fn.stdpath 'config'
    require('telescope.builtin').live_grep {
      prompt_title = 'Search Neovim Config',
      cwd = config_dir,
    }
  end, { desc = 'Grep in Neovim config files' })

  -- Plugin searches
  vim.keymap.set('n', ',gp', function()
    local plugins_dir = vim.fn.stdpath 'data' .. '/lazy'
    require('telescope.builtin').live_grep {
      prompt_title = 'Search Plugins',
      search_dirs = { plugins_dir },
    }
  end, { desc = '[G]rep in [P]lugins' })

  -- Python/Pyramid-specific searches
  vim.keymap.set('n', '<leader>sov', function()
    local args
    local config = require('telescope.config').values
    if config and config.pickers and config.pickers.live_grep and config.pickers.live_grep.additional_args then
      args = config.pickers.live_grep.additional_args()
    else
      args = {}
    end

    table.insert(args, '--glob')
    table.insert(args, '**/views/**')
    builtin.live_grep {
      additional_args = args,
      default_text = 'def ',
      prompt_title = 'pyramid views',
    }
  end, { desc = '[S]earch [O]negov [V]iews' })

  vim.keymap.set('n', 'öö', function()
    local args
    local config = require('telescope.config').values
    if config and config.pickers and config.pickers.live_grep and config.pickers.live_grep.additional_args then
      args = config.pickers.live_grep.additional_args()
    else
      args = {}
    end
    builtin.live_grep {
      search_dirs = { 'src/onegov/translator_directory' },
      additional_args = args,
      prompt_title = 'Grep in PAS',
    }
  end, { desc = '[Grep] [P]AS' })

  -- File type specific searches
  local is_server = os.getenv 'SSH_TTY' ~= nil
  local is_mac = vim.loop.os_uname().sysname == 'Darwin'

  if not is_server and not is_mac then
    vim.keymap.set('n', 'ff', function()
      require('fff').find_files()
    end, { desc = 'Open file picker' })
  elseif is_server then
    vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Find files' })
  end

  vim.keymap.set('n', '<leader>sch', function()
    builtin.find_files {
      prompt_title = 'PT Templates',
      find_command = { 'fd', '--type', 'f', '--extension', 'pt' },
    }
  end, { desc = '[S]earch [chameleon] [T]emplates' })

  vim.keymap.set('n', '<leader>spy', function()
    builtin.find_files {
      prompt_title = 'python files',
      find_command = { 'fd', '--type', 'f', '--extension', 'py' },
    }
  end, { desc = 'search python files only' })

  vim.keymap.set('n', '<leader>gch', function()
    builtin.live_grep { glob_pattern = '*.pt' }
  end, { desc = 'Grep in chameleon templates' })

  -- Virtual environment search
  local function search_in_venv()
    local lsp_util_ok, lsp_util = pcall(require, 'lspconfig.util')
    local project_root
    if lsp_util_ok then
      project_root = lsp_util.root_pattern('.git', 'pyproject.toml', 'setup.py', '.hg')(vim.fn.getcwd())
    end
    if not project_root then
      project_root = vim.fn.getcwd()
    end

    local venv_path = os.getenv 'VIRTUAL_ENV'
    if not venv_path or venv_path == '' then
      local common_venv_names = { '.venv', 'venv' }
      for _, name in ipairs(common_venv_names) do
        local potential_path = project_root .. '/' .. name
        if vim.fn.isdirectory(potential_path) == 1 then
          venv_path = potential_path
          break
        end
      end
    end

    if not venv_path or venv_path == '' then
      vim.notify('Could not find a virtual environment. Please activate it before starting Neovim.', vim.log.levels.WARN)
      return
    end

    require('telescope.builtin').live_grep {
      prompt_title = 'Grep in ' .. vim.fn.fnamemodify(venv_path, ':t'),
      search_dirs = { venv_path },
      additional_args = { '--fixed-strings' },
    }
  end

  vim.keymap.set('n', '<leader>sv', search_in_venv, { desc = '[S]earch in [V]env only' })
end
