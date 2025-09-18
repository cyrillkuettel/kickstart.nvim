-- Python import management utilities
local M = {}

-- Python import ordering fix function
--  1. Identifies existing import blocks after the __future__ import
-- 2. Places moved imports at the beginning of existing import blocks instead of creating a separate block
-- 3. Only adds a blank line if no existing import block is found after __future__
function M.fix_python_imports(bufnr)
  if vim.bo[bufnr].filetype ~= 'python' then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Find __future__ import line
  local future_line_idx = nil
  for i, line in ipairs(lines) do
    if line:match '^from%s+__future__%s+import' then
      future_line_idx = i
      break
    end
  end

  if not future_line_idx then
    return -- No __future__ import, nothing to fix
  end

  -- Find imports above the __future__ import
  local imports_to_move = {}
  local other_lines = {}

  for i, line in ipairs(lines) do
    if i < future_line_idx then
      if line:match '^%s*import%s+' or (line:match '^%s*from%s+' and not line:match '^%s*from%s+__future__') then
        table.insert(imports_to_move, line)
      else
        table.insert(other_lines, line)
      end
    else
      table.insert(other_lines, line)
    end
  end

  -- If we found imports to move, reconstruct the file
  if #imports_to_move > 0 then
    local new_lines = {}
    local future_inserted = false

    for i, line in ipairs(other_lines) do
      table.insert(new_lines, line)
      -- After inserting the __future__ import, find existing import block and insert there
      if line:match '^from%s+__future__%s+import' and not future_inserted then
        -- Look ahead to find where to insert the moved imports
        local next_line_idx = i + 1
        local found_import_block = false

        -- Skip blank lines after __future__ import
        while next_line_idx <= #other_lines and other_lines[next_line_idx]:match '^%s*$' do
          table.insert(new_lines, other_lines[next_line_idx])
          next_line_idx = next_line_idx + 1
        end

        -- Check if the next non-blank line is an import
        if next_line_idx <= #other_lines then
          local next_line = other_lines[next_line_idx]
          if next_line:match '^%s*import%s+' or next_line:match '^%s*from%s+' then
            -- Insert moved imports at the beginning of the existing import block
            for _, import_line in ipairs(imports_to_move) do
              table.insert(new_lines, import_line)
            end
            found_import_block = true
          end
        end

        -- If no import block found, add blank line and then imports
        if not found_import_block then
          table.insert(new_lines, '') -- Add blank line after __future__ import
          for _, import_line in ipairs(imports_to_move) do
            table.insert(new_lines, import_line)
          end
        end

        future_inserted = true
      end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  end
end

-- Auto-import function that queries LSP and auto-applies if only one option
function M.auto_import_single()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= 'python' then
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, params.range.start.line),
    only = { 'quickfix' },
  }

  vim.lsp.buf_request(bufnr, 'textDocument/codeAction', params, function(err, result, ctx)
    if err or not result then
      vim.notify('No code actions available', vim.log.levels.INFO)
      return
    end

    -- Filter for pyrefly import actions
    local import_actions = {}
    for _, action in ipairs(result) do
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client and client.name == 'pyrefly' then
        -- Look for import-related actions
        if action.title:match '[Ii]mport' or action.title:match '[Aa]dd' then
          table.insert(import_actions, action)
        end
      end
    end

    if #import_actions == 0 then
      vim.notify('No import suggestions found', vim.log.levels.INFO)
      return
    elseif #import_actions == 1 then
      -- Auto-apply the single import action
      local action = import_actions[1]
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
      vim.notify('Auto-imported: ' .. action.title, vim.log.levels.INFO)

      -- Fix import ordering after applying
      vim.defer_fn(function()
        M.fix_python_imports(bufnr)
      end, 100)
    else
      -- Multiple options, show them in telescope
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      pickers
        .new({}, {
          prompt_title = 'Select Import',
          finder = finders.new_table {
            results = import_actions,
            entry_maker = function(action)
              return {
                value = action,
                display = action.title,
                ordinal = action.title,
              }
            end,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              local action = selection.value

              if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
              elseif action.command then
                vim.lsp.buf.execute_command(action.command)
              end

              -- Fix import ordering after applying
              vim.defer_fn(function()
                M.fix_python_imports(bufnr)
              end, 100)
            end)
            return true
          end,
        })
        :find()
    end
  end)
end

-- Auto-import all undefined symbols in buffer (only if single option each)
function M.auto_import_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= 'python' then
    vim.notify('Auto-import buffer only works for Python files', vim.log.levels.WARN)
    return
  end

  -- Get all diagnostics for the buffer
  local diagnostics = vim.diagnostic.get(bufnr)
  local undefined_symbols = {}
  local processed_positions = {}

  -- Find all "undefined name" diagnostics
  for _, diagnostic in ipairs(diagnostics) do
    if
      diagnostic.source == 'pyrefly'
      and (diagnostic.message:match 'Undefined variable' or diagnostic.message:match 'undefined name' or diagnostic.message:match 'is not defined')
    then
      local line = diagnostic.lnum
      local col = diagnostic.col
      local pos_key = line .. ':' .. col

      if not processed_positions[pos_key] then
        processed_positions[pos_key] = true
        table.insert(undefined_symbols, {
          line = line,
          col = col,
          message = diagnostic.message,
        })
      end
    end
  end

  if #undefined_symbols == 0 then
    vim.notify('No undefined symbols found in buffer', vim.log.levels.INFO)
    return
  end

  vim.notify(string.format('Found %d undefined symbols, checking import options...', #undefined_symbols), vim.log.levels.INFO)

  local imports_applied = 0
  local imports_skipped = 0
  local total_symbols = #undefined_symbols

  -- Process each undefined symbol
  for i, symbol in ipairs(undefined_symbols) do
    vim.defer_fn(function()
      -- Set cursor to the undefined symbol position
      vim.api.nvim_win_set_cursor(0, { symbol.line + 1, symbol.col })

      local params = vim.lsp.util.make_range_params()
      params.context = {
        diagnostics = { symbol },
        only = { 'quickfix' },
      }

      vim.lsp.buf_request(bufnr, 'textDocument/codeAction', params, function(err, result, ctx)
        if err or not result then
          imports_skipped = imports_skipped + 1
          return
        end

        -- Filter for pyrefly import actions
        local import_actions = {}
        for _, action in ipairs(result) do
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          if client and client.name == 'pyrefly' then
            if action.title:match '[Ii]mport' or action.title:match '[Aa]dd' then
              table.insert(import_actions, action)
            end
          end
        end

        if #import_actions == 1 then
          -- Auto-apply the single import action
          local action = import_actions[1]
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
          elseif action.command then
            vim.lsp.buf.execute_command(action.command)
          end
          imports_applied = imports_applied + 1
        else
          imports_skipped = imports_skipped + 1
        end

        -- After processing the last symbol, show summary and fix imports
        if i == total_symbols then
          vim.defer_fn(function()
            M.fix_python_imports(bufnr)
            vim.notify(
              string.format('Auto-import complete: %d applied, %d skipped (multiple/no options)', imports_applied, imports_skipped),
              vim.log.levels.INFO
            )
          end, 200)
        end
      end)
    end, i * 50) -- Stagger requests by 50ms each
  end
end

return M