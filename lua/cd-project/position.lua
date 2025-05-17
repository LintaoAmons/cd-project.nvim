local M = {}
local repo = require("cd-project.project-repo")

-- Save current position for the current project
function M.save_current_position()
  if not vim.g.cd_project_config.remember_project_position then
    return
  end

  local current_project_path = vim.g.cd_project_current_project
  if not current_project_path then
    return
  end

  local current_file = vim.fn.expand("%:p")
  -- Only save if we're in a real file
  if current_file == "" or vim.bo.buftype ~= "" then
    return
  end

  -- Make path relative to project root
  local relative_path = vim.fn.fnamemodify(current_file, ":.")
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Update project data
  local projects = repo.get_projects()
  for i, project in ipairs(projects) do
    if project.path == current_project_path then
      projects[i].last_file = relative_path
      projects[i].last_position = cursor_pos
      break
    end
  end
  
  repo.write_projects(projects)
end

-- Restore position for the given project
function M.restore_position(project_path)
  if not vim.g.cd_project_config.remember_project_position then
    return
  end

  local projects = repo.get_projects()
  for _, project in ipairs(projects) do
    if project.path == project_path then
      if project.last_file then
        local file_path = project.path .. "/" .. project.last_file
        if vim.fn.filereadable(file_path) == 1 then
          -- Open the file
          vim.cmd("edit " .. vim.fn.fnameescape(file_path))
          -- Restore cursor position
          if project.last_position then
            vim.schedule(function()
              pcall(vim.api.nvim_win_set_cursor, 0, project.last_position)
            end)
          end
        end
      end
      break
    end
  end
end

-- Setup autocmds for position tracking
function M.setup()
  if not vim.g.cd_project_config.remember_project_position then
    return
  end

  local augroup = vim.api.nvim_create_augroup("CdProjectPosition", { clear = true })
  
  -- Save position when leaving a buffer
  vim.api.nvim_create_autocmd({"BufLeave", "VimLeave"}, {
    group = augroup,
    callback = function()
      M.save_current_position()
    end,
  })
  
  -- Add user commands
  vim.api.nvim_create_user_command("CdProjectSavePosition", function()
    M.save_current_position()
    vim.notify("Project position saved", vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_user_command("CdProjectRestorePosition", function()
    local current_project = vim.g.cd_project_current_project
    if current_project then
      M.restore_position(current_project)
      vim.notify("Project position restored", vim.log.levels.INFO)
    else
      vim.notify("No current project", vim.log.levels.WARN)
    end
  end, {})
end

return M
