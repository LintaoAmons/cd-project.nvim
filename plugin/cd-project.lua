if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("cd-project.nvim requires at least nvim-0.7")
  return
end

-- make sure this file is loaded only once
if vim.g.loaded_cd_project == 1 then
  return
end
vim.g.loaded_cd_project = 1

require("cd-project").setup()
local adapter = require("cd-project.adapter")
local api = require("cd-project.api")
vim.g.cd_project_current_project = api.find_project_dir()

---@param fargs string[]
---@return string|nil
local function joined_name(fargs)
  local name = vim.trim(table.concat(fargs, " "))
  if name == "" then
    return nil
  end
  return name
end

vim.api.nvim_create_user_command("CdProject", function(args)
  local name = joined_name(args.fargs)
  if name then
    return api.cd_project_by_name(name)
  end
  adapter.cd_project()
end, {
  nargs = "*",
  complete = function(arg_lead)
    return vim.tbl_filter(function(name)
      return name:lower():find(arg_lead:lower(), 1, true) ~= nil
    end, api.get_project_names())
  end,
  desc = "cd to a project by name, or pick one when no name is given",
})
vim.api.nvim_create_user_command("CdProjectAdd", function(args)
  api.add_current_project({ show_duplicate_hints = true, name = joined_name(args.fargs) })
end, { nargs = "*", desc = "Add current project, optionally with a name" })
vim.api.nvim_create_user_command("CdProjectManualAdd", adapter.manual_cd_project, {})
vim.api.nvim_create_user_command("CdProjectSearchAndAdd", adapter.search_and_add, {})
vim.api.nvim_create_user_command("CdProjectDelete", adapter.delete_project, {})
vim.api.nvim_create_user_command("CdProjectPrune", function(args)
  api.prune_projects({ force = args.bang })
end, { bang = true, desc = "Remove projects whose directory no longer exists (! skips confirmation)" })
vim.api.nvim_create_user_command("CdProjectScan", function(args)
  api.scan_projects({ dir = joined_name(args.fargs) })
end, { nargs = "*", complete = "dir", desc = "Add all git repos under the given dir (default: cwd) as projects" })
vim.api.nvim_create_user_command("CdProjectBack", api.back, {})
