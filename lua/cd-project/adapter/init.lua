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
  search_and_add = search_and_add,
  -- kept for backward compatibility
  telescope_search_and_add = search_and_add,
  delete_project = delete_project,
}
