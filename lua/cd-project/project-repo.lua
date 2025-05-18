local json = require("cd-project.json")
---@class CdProject.Project
---@field id string Unique identifier for the project
---@field path string
---@field name string
---@field desc string|nil
---@field last_file string|nil Path to last opened file (relative to project root)
---@field last_position number[]|nil Cursor position as [line, col]
---@field visited_at number|nil Timestamp of last visit

---@return CdProject.Project[]
local get_projects = function()
  local json = json.read_or_init_json_file(vim.g.cd_project_config.projects_config_filepath)

  -- Filter out projects whose directory does not exist
  local existing_projects = vim.tbl_filter(function(p)
    return vim.fn.isdirectory(p.path) == 1
  end, json)

  -- Sort projects by visited_at in descending order (most recent first)
  table.sort(existing_projects, function(a, b)
    local a_time = a.visited_at or 0
    local b_time = b.visited_at or 0
    return a_time > b_time
  end)

  return existing_projects
end

---@param projects CdProject.Project[]
local write_projects = function(projects)
  json.write_json_file(projects, vim.g.cd_project_config.projects_config_filepath)
end

return {
  get_projects = get_projects,
  write_projects = write_projects,
}
