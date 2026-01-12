local cd_hooks = require("cd-project.hooks")
local repo = require("cd-project.project-repo")
local utils = require("cd-project.utils")
local position = require("cd-project.position")

---@return string|nil
local function find_project_dir()
  local found = vim.fs.find(
    vim.g.cd_project_config.project_dir_pattern,
    { upward = true, stop = vim.loop.os_homedir(), path = vim.fs.dirname(vim.fn.expand("%:p")) }
  )

  if #found == 0 then
    return vim.loop.os_homedir()
  end

  local project_dir = vim.fs.dirname(found[1])

  if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
    project_dir = string.match(vim.fn.execute("pwd"), "^%s*(.-)%s*$")
  end

  if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
    return nil
  end

  return project_dir
end

---@return string[]
local function get_project_paths()
  local projects = repo.get_projects()
  local paths = {}
  for _, value in ipairs(projects) do
    table.insert(paths, value.path)
  end
  return paths
end

---@return string[]
local function get_project_names()
  local projects = repo.get_projects()
  local path_names = {}
  for _, value in ipairs(projects) do
    table.insert(path_names, value.name)
  end
  return path_names
end

---@param path string
---@return integer|nil tabpage number if found, nil otherwise
local function path_exists_in_tab(path)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local tab_cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
    local normalized_path = utils.remove_trailing_slash(path)
    local normalized_tab_cwd = utils.remove_trailing_slash(tab_cwd)
    if normalized_path == normalized_tab_cwd then
      return tabpage
    end
  end
  return nil
end

---@param tabpage integer
---@return boolean whether the operation was handled (true) or should continue with normal cd (false)
local function handle_existing_tab(tabpage)
  -- Remain in current tab if current tab holds target dir
  if vim.api.nvim_get_current_tabpage() == tabpage then
    vim.notify(
      "Dir already open in current tab (#" .. tabpage .. "). No action taken.",
      vim.log.levels.INFO,
      { title = "cd-project.nvim" }
    )
    return true
  end

  -- Switch to tab that holds target dir
  vim.api.nvim_set_current_tabpage(tabpage)
  vim.notify(
    "Dir already open in tab #" .. tabpage .. ". You have been redirected.",
    vim.log.levels.INFO,
    { title = "cd-project.nvim" }
  )
  return true
end


---@param dir string
---@param opts? {cd_cmd: "cd" | "tabe | tcd" | "lcd"}
local function cd_project(dir, opts)
  opts = opts or { cd_cmd = "cd" }
  
  -- Save position of current project before switching
  position.save_current_position()
  
  vim.g.cd_project_last_project = vim.g.cd_project_current_project
  vim.g.cd_project_current_project = dir

  -- Check if directory exists in another tab when using tab commands
  if opts.cd_cmd == "tabe | tcd" then
    local tabpage = path_exists_in_tab(dir)
    if tabpage ~= nil then
      handle_existing_tab(tabpage)
      return
    end
  end

  local hooks = cd_hooks.get_hooks(vim.g.cd_project_config.hooks, dir, "BEFORE_CD", opts.cd_cmd)
  for _, hook in ipairs(hooks) do
    hook.callback(dir)
  end

  local cd_cmd = opts.cd_cmd or "cd"
  local full_command = cd_cmd .. " " .. vim.fn.fnameescape(dir)
  vim.fn.execute(full_command)

  -- Update visited_at timestamp for the project
  local projects = repo.get_projects()
  for _, project in ipairs(projects) do
    if project.path == dir then
      project.visited_at = os.time()
      break
    end
  end
  repo.write_projects(projects)

  -- Restore position for the new project
  position.restore_position(dir)

  -- This will make the displayed names of the restored file appear relative to the root directory
  vim.fn.execute(full_command)

  local hooks = cd_hooks.get_hooks(vim.g.cd_project_config.hooks, dir, "AFTER_CD", opts.cd_cmd)
  for _, hook in ipairs(hooks) do
    hook.callback(dir)
  end
end

---@param path string
---@param name? string
---@param desc? string|nil
---@return CdProject.Project|nil
local function build_project_obj(path, name, desc)
  local normalized_path = vim.fn.expand(path)
  if vim.fn.isdirectory(normalized_path) == 0 then
    return utils.log_error(normalized_path .. " is not a directory")
  end

  return {
    id = vim.fn.strftime("%Y%m%d%H%M%S") .. "_" .. math.random(1000, 9999), -- Unique ID based on timestamp and random number
    path = normalized_path,
    name = name or utils.get_tail_of_path(normalized_path),
    desc = desc,
  }
end

---@param project CdProject.Project
---@param opts? {show_duplicate_hints: boolean}
local function add_project(project, opts)
  local projects = repo.get_projects()
  opts = opts or { show_duplicate_hints = true }

  for _, p in ipairs(projects) do
    if p.path == project.path then
      if opts.show_duplicate_hints then
        vim.notify("Project already exists: " .. project.path, vim.log.levels.INFO, { title = "cd-project.nvim" })
      end
      return
    end
  end

  table.insert(projects, project)
  repo.write_projects(projects)
  vim.notify("Project added: \n" .. project.path, vim.log.levels.INFO, { title = "cd-project.nvim" })
end

---@param project_id string
---@param updated_project CdProject.Project
local function update_project(project_id, updated_project)
  local projects = repo.get_projects()
  local found = false

  for i, p in ipairs(projects) do
    if p.id == project_id then
      projects[i] = updated_project
      found = true
      break
    end
  end

  if found then
    repo.write_projects(projects)
    vim.notify("Project updated: \n" .. updated_project.name, vim.log.levels.INFO, { title = "cd-project.nvim" })
  else
    vim.notify("Project not found with ID: " .. project_id, vim.log.levels.WARN, { title = "cd-project.nvim" })
  end
end

---@param project CdProject.Project
local function delete_project(project)
  local projects = repo.get_projects()

  local new_projects = vim.tbl_filter(function(p)
    return p.id ~= project.id
  end, projects)
  repo.write_projects(new_projects)
  vim.notify("Project deleted: \n" .. project.name, vim.log.levels.INFO, { title = "cd-project.nvim" })
end

---@param opts? {show_duplicate_hints: boolean}
local function add_current_project(opts)
  local project_dir = find_project_dir()
  opts = opts or { show_duplicate_hints = true }

  if not project_dir then
    return utils.log_err("Can't find project path of current file")
  end

  local project = build_project_obj(project_dir)

  if not project then
    return
  end

  add_project(project, opts)
end

local function back()
  local last_project = vim.g.cd_project_last_project
  if not last_project then
    vim.notify("Can't find last project. Haven't switch project yet.")
  end
  cd_project(last_project)
end

return {
  cd_project = cd_project,
  build_project_obj = build_project_obj,
  get_project_paths = get_project_paths,
  get_project_names = get_project_names,
  add_current_project = add_current_project,
  add_project = add_project,
  update_project = update_project,
  delete_project = delete_project,
  back = back,
  find_project_dir = find_project_dir,
}
