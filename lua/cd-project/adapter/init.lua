-- The adapter that can search, or nil after telling the user why it cannot.
-- Resolved separately from the picker dispatch below because `vim-ui` is a valid
-- picker with no search backend at all -- that is a different failure from
-- "telescope is configured but not installed", and the two must not read alike.
---@return table|nil
local function search_adapter()
  local utils = require("cd-project.utils")
  local picker = vim.g.cd_project_config.projects_picker

  local module
  if picker == "snacks" then
    module = "cd-project.adapter.snacks"
  elseif picker == "telescope" then
    module = "cd-project.adapter.telescope"
  else
    return utils.log_error(
      "projects_picker is '"
        .. tostring(picker)
        .. "', which has no search backend. Set projects_picker to 'telescope' or 'snacks'."
    )
  end

  -- an adapter whose backend plugin is missing bails out at require time and so
  -- evaluates to `true` rather than the module table
  local adapter = require(module)
  if type(adapter) ~= "table" then
    return utils.log_error("projects_picker is '" .. picker .. "', but " .. picker .. " is not installed.")
  end
  return adapter
end

---@param project CdProject.Project
---@param kind CdProject.SearchKind
local function search(project, kind)
  local adapter = search_adapter()
  if adapter then
    adapter.search(project, kind)
  end
end

-- Ask which project first, then search in it. Same destination as `search`,
-- reached without the caller naming a project up front.
---@param kind CdProject.SearchKind
local function search_with_picker(kind)
  local adapter = search_adapter()
  if not adapter then
    return
  end
  adapter.project_picker(function(project)
    require("cd-project.api").search_in_project(project, kind)
  end, { prompt = kind == "grep" and "Grep in project" or "Find files in project" })
end

local function cd_project()
  local projects_picker = vim.g.cd_project_config.projects_picker
  if projects_picker == "telescope" then
    return require("cd-project.adapter.telescope").cd_project()
  end
  if projects_picker == "snacks" then
    return require("cd-project.adapter.snacks").cd_project()
  end

  require("cd-project.adapter.vim-ui").cd_project()
end

local function manual_cd_project()
  require("cd-project.adapter.vim-ui").manual_cd_project()
end

local function search_and_add()
  local projects_picker = vim.g.cd_project_config.projects_picker
  if projects_picker == "telescope" then
    return require("cd-project.adapter.telescope").search_and_add()
  end
  if projects_picker == "snacks" then
    return require("cd-project.adapter.snacks").search_and_add()
  end
end

local function delete_project()
  local projects_picker = vim.g.cd_project_config.projects_picker
  local adapter_module = "cd-project.adapter.telescope"
  if projects_picker == "snacks" then
    adapter_module = "cd-project.adapter.snacks"
  end
  require(adapter_module).project_picker(function(project)
    require("cd-project.api").delete_project(project)
  end, { prompt = "Delete project" })
end

return {
  cd_project = cd_project,
  manual_cd_project = manual_cd_project,
  search = search,
  search_with_picker = search_with_picker,
  search_and_add = search_and_add,
  -- kept for backward compatibility
  telescope_search_and_add = search_and_add,
  delete_project = delete_project,
}
