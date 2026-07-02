local repo = require("cd-project.project-repo")
local api = require("cd-project.api")
local utils = require("cd-project.utils")

local M = {}

-- Ask for a name (fall back to the directory tail) and add `dir` as a project.
---@param dir string
function M.prompt_name_and_add(dir)
  vim.ui.input({ prompt = "Add a project name: " }, function(name)
    if not name or name == "" then
      name = nil
      vim.notify('No name given, using "' .. utils.get_tail_of_path(dir) .. '" instead')
    end

    local project = api.build_project_obj(dir, name)
    if not project then
      return
    end
    api.add_project(project)
  end)
end

-- Projects sorted by the repo (last visited first), with the current
-- project moved to the end of the list.
---@return CdProject.Project[]
function M.get_entries()
  local projects = repo.get_projects()

  local current_project_path = vim.fn.getcwd()
  local current_project_index = nil
  for i, project in ipairs(projects) do
    if project.path == current_project_path then
      current_project_index = i
    end
  end

  if current_project_index then
    local current_project = table.remove(projects, current_project_index)
    table.insert(projects, current_project)
  end
  return projects
end

---@param projects CdProject.Project[]
---@return integer name_width, integer path_width
function M.column_widths(projects)
  local max_name = 15 -- minimum width
  local max_path = 20 -- minimum width

  for _, p in ipairs(projects) do
    max_name = math.max(max_name, #p.name)
    local path = vim.fn.pathshorten(p.path)
    max_path = math.max(max_path, #path)
  end

  return math.min(max_name, 30), math.min(max_path, 40)
end

---@param text string
---@param width integer
---@return string
local function pad_or_truncate(text, width)
  if #text > width then
    return text:sub(1, width - 2) .. ".."
  end
  return text .. string.rep(" ", width - #text)
end

-- Aligned `name`, `path` columns for a picker row.
---@param project CdProject.Project
---@param name_width integer
---@param path_width integer
---@return string name, string path
function M.format_columns(project, name_width, path_width)
  return pad_or_truncate(project.name, name_width), pad_or_truncate(vim.fn.pathshorten(project.path), path_width)
end

return M
