local utils = require("cd-project.utils")
local api = require("cd-project.api")
local repo = require("cd-project.project-repo")

---@param opts? table
local function cd_project(opts)
  opts = opts or {}
  local projects = repo.get_projects()

  local maxLength = 0
  for _, project in ipairs(projects) do
    if #project.name > maxLength then
      maxLength = #project.name
    end
  end

  vim.ui.select(projects, {
    prompt = "Select a directory",
    format_item = function(project)
      return utils.format_entry(project, maxLength)
    end,
  }, function(selected)
    if not selected then
      return utils.log_error("Must select a valid dir")
    end
    api.cd_project(selected.path)
  end)
end

---@param opts? table
local function cd_project_in_tab(opts)
  opts = opts or {}
  local projects = repo.get_projects()

  local maxLength = 0
  for _, project in ipairs(projects) do
    if #project.name > maxLength then
      maxLength = #project.name
    end
  end

  vim.ui.select(projects, {
    prompt = "Select a directory",
    format_item = function(project)
      return utils.format_entry(project, maxLength)
    end,
  }, function(selected)
    if not selected then
      return utils.log_error("Must select a valid dir")
    end
    api.cd_project_in_tab(selected.path)
  end)
end

local function manual_cd_project()
  vim.ui.input({ prompt = "Add a project path: ", completion = "dir" }, function(path)
    if not path or path == "" then
      return utils.log_error("No path given, quitting.")
    end

    vim.ui.input({ prompt = "Add a project name: " }, function(name)
      if not name or name == "" then
        name = utils.get_tail_of_path(path)
        vim.notify('No name given, using "' .. name .. '" instead')
      end

      local project = api.build_project_obj(path, name)
      if not project then
        return
      end

      return api.add_project(project)
    end)
  end)
end

return {
  cd_project = cd_project,
  cd_project_in_tab = cd_project_in_tab,
  manual_cd_project = manual_cd_project,
}
