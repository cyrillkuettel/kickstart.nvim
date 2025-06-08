local M = {}

---@param selected_entries table table of telescope entries
function M.add_files_to_aider(selected_entries)
  if not selected_entries or #selected_entries == 0 then
    vim.notify('No files selected to add to Aider.', vim.log.levels.WARN)
    return
  end

  local files_added = {}
  local files_failed = {}

  -- Save the state of the window/buffer that was active after Telescope closed.
  local original_win_id = vim.fn.win_getid()
  local original_bufnr = vim.api.nvim_get_current_buf()

  for _, entry in ipairs(selected_entries) do
    local file_path = entry.value -- 'value' usually holds the full path for oldfiles
    if file_path and vim.fn.filereadable(vim.fn.expand(file_path)) == 1 then
      local target_file_path_escaped = vim.fn.fnameescape(vim.fn.expand(file_path))
      -- Make the file current buffer by opening it in the current window
      vim.cmd('edit ' .. target_file_path_escaped)
      vim.cmd 'AiderAddCurrentFile' -- This command should add the now-current file
      table.insert(files_added, vim.fn.fnamemodify(file_path, ':t'))
    else
      table.insert(files_failed, vim.fn.fnamemodify(tostring(file_path), ':t'))
    end
  end

  -- Attempt to restore the original buffer in the original window
  if vim.fn.win_id2win(original_win_id) ~= 0 then -- Check if original window still exists
    vim.api.nvim_set_current_win(original_win_id) -- Switch to the original window
    if vim.fn.bufexists(original_bufnr) == 1 then
      vim.api.nvim_set_current_buf(original_bufnr)
    else
      vim.cmd 'enew' -- Fallback to a new empty buffer
      vim.notify('Original buffer (' .. original_bufnr .. ') no longer exists. Opened a new buffer.', vim.log.levels.WARN)
    end
  else
    -- Original window is gone. This is less ideal.
    -- Try to set the original buffer in the current window, or open a new one.
    if vim.fn.bufexists(original_bufnr) == 1 then
      vim.api.nvim_set_current_buf(original_bufnr)
    else
      vim.cmd 'enew'
    end
    vim.notify('Original window (' .. original_win_id .. ') no longer exists. Restored buffer in current window.', vim.log.levels.WARN)
  end

  if #files_added > 0 then
    vim.notify('Added to Aider:\n' .. table.concat(files_added, '\n'), vim.log.levels.INFO)
  end
  if #files_failed > 0 then
    vim.notify('Failed to add to Aider (not found or unreadable):\n' .. table.concat(files_failed, '\n'), vim.log.levels.ERROR)
  end
end

M.aider_attach_mappings = function(prompt_bufnr, map)
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  actions.select_default:replace(function()
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if entry then
      M.add_files_to_aider { entry }
    end
  end)

  map('i', '<C-a>', function()
    local current_picker_selected_entries = action_state.get_selected_entries(prompt_bufnr)
    if #current_picker_selected_entries == 0 then
      local current_entry = action_state.get_current_entry()
      if current_entry then
        current_picker_selected_entries = { current_entry }
      end
    end
    actions.close(prompt_bufnr)
    if #current_picker_selected_entries > 0 then
      M.add_files_to_aider(current_picker_selected_entries)
    end
  end)
  return true
end

return M
