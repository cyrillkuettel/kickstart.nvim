local M = {}

---@param selected_entries table table of telescope entries
function M.add_files_to_aider(selected_entries)
  if not selected_entries or #selected_entries == 0 then
    vim.notify('No files selected to add to Aider.', vim.log.levels.WARN)
    return
  end

  local files_added = {}
  local files_failed = {}

  for _, entry in ipairs(selected_entries) do
    local file_path = entry.value -- 'value' usually holds the full path for oldfiles
    if file_path and vim.fn.filereadable(vim.fn.expand(file_path)) == 1 then
      local target_file_path_escaped = vim.fn.fnameescape(vim.fn.expand(file_path))
      -- To use AiderSilentAddCurrentFile, Aider expects the file to be the current buffer.
      -- We can briefly open it, add it, and then return to the previous buffer if needed,
      -- but since we want to add multiple files silently without complex window management,
      -- we'll make each file current one by one.
      local current_buf = vim.api.nvim_get_current_buf()
      vim.cmd('edit ' .. target_file_path_escaped) -- Make the file current buffer
      vim.cmd 'AiderSilentAddCurrentFile'
      vim.api.nvim_set_current_buf(current_buf) -- Restore previous buffer (optional, but good practice)
      table.insert(files_added, vim.fn.fnamemodify(file_path, ':t'))
    else
      table.insert(files_failed, vim.fn.fnamemodify(tostring(file_path), ':t'))
    end
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

  actions.select_default:replace(function() -- Default action: add selected file and close Telescope
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if entry then
      M.add_files_to_aider { entry }
    end
  end)

  local function add_current_entry_and_stay_open()
    local entry = action_state.get_selected_entry()
    if entry then
      M.add_files_to_aider { entry }
    else
      vim.notify('No entry currently under cursor to add.', vim.log.levels.WARN)
    end
  end

  map('i', '<C-p>', add_current_entry_and_stay_open)
  map('n', '<C-p>', add_current_entry_and_stay_open)
  return true
end

return M
