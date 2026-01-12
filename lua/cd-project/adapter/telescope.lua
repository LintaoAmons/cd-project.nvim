local utils = require("cd-project.utils")
local success, _ = pcall(require, "telescope.pickers")
if not success then
  utils.log_error("telescope not installed")
  return
end
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local repo = require("cd-project.project-repo")
local api = require("cd-project.api")

local M = {}

local function format_entry(project, projects)
  local max_name = 15 -- minimum width
  local max_path = 20 -- minimum width

  for _, p in ipairs(projects) do
    max_name = math.max(max_name, #p.name)
    local path = vim.fn.pathshorten(p.path)
    max_path = math.max(max_path, #path)
  end

  -- Apply maximum constraints
  max_name = math.min(max_name, 30)
  max_path = math.min(max_path, 40)

  local name = project.name
  local path = vim.fn.pathshorten(project.path)

  -- Pad or truncate name
  if #name > max_name then
    name = name:sub(1, max_name - 2) .. ".."
  else
    name = name .. string.rep(" ", max_name - #name)
  end

  -- Pad or truncate path
  if #path > max_path then
    path = path:sub(1, max_path - 2) .. ".."
  else
    path = path .. string.rep(" ", max_path - #path)
  end

  return string.format("%s │ %s", name, path)
end

---@return CdProject.Project[]
local function get_entries()
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

---@param callback fun(project: CdProject.Project): nil
---@param opts? {prompt?: string}
function M.project_picker(callback, opts)
  opts = opts or {}

  local projects = get_entries()

  local function start_picker(project_list)
    pickers
        .new(opts, {
          prompt_title = opts.prompt or "cd to project",
          finder = finders.new_table({
            results = project_list,
            ---@param project CdProject.Project
            entry_maker = function(project)
              local display = format_entry(project, project_list)
              return {
                value = project,
                display = display,
                ordinal = display,
                filename = project.path,
              }
            end,
          }),
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              callback(selected.value)
            end)

            -- tcd: open in new tab
            map({ "i", "n" }, "<c-t>", function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              api.cd_project(selected.value.path, { cd_cmd = "tabe | tcd" })
            end, { desc = "Open in new tab" })

            actions.select_horizontal:replace(function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              vim.cmd [[ split ]]
              api.cd_project(selected.value.path, { cd_cmd = "lcd" })
            end)

            actions.select_vertical:replace(function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              vim.cmd [[ vsplit ]]
              api.cd_project(selected.value.path, { cd_cmd = "lcd" })
            end)

            map({ "i", "n" }, "<c-e>", function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              api.cd_project(selected.value.path, { cd_cmd = "lcd" })
            end, { desc = "Open in current window" })

            map({ "i", "n" }, "<c-d>", function()
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              api.delete_project(selected.value)
              actions.close(prompt_bufnr)
              -- Refresh the picker with updated project list
              start_picker(get_entries())
            end, { desc = "Remove project" })

            map({ "i", "n" }, "<c-r>", function()
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              vim.ui.input({ prompt = "Rename project to: ", default = selected.value.name }, function(new_name)
                if new_name and new_name ~= "" then
                  local project = selected.value
                  project.name = new_name
                  project.visited_at = os.time() -- Update the timestamp to reflect the rename action
                  api.update_project(project.id, project)
                  actions.close(prompt_bufnr)
                  -- Refresh the picker with updated project list
                  start_picker(get_entries())
                end
              end)
            end, { desc = "Rename project" })

            return true
          end,
        })
        :find()
  end

  start_picker(projects)
end

---@param opts? table
function M.cd_project(opts)
  opts = opts or {}
  M.project_picker(function(project)
    api.cd_project(project.path)
  end, opts)
end

function M.search_and_add(opts)
  opts = opts or {}

  local find_command = utils.check_for_find_cmd()
  if not find_command then
    utils.log_error("You need to install fd or find.")
    return
  end

  vim.fn.jobstart(find_command, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      pickers
          .new(opts, {
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selected_dir = action_state.get_selected_entry().value

                vim.ui.input({ prompt = "Add a project name: " }, function(name)
                  if not name or name == "" then
                    vim.notify('No name given, using "' .. utils.get_tail_of_path(selected_dir) .. '" instead')
                    local project = api.build_project_obj(selected_dir)
                    if not project then
                      return
                    end
                    return api.add_project(project)
                  end

                  local project = api.build_project_obj(selected_dir, name)
                  if not project then
                    return
                  end
                  return api.add_project(project)
                end)
              end)
              return true
            end,
            prompt_title = "Select dir to add",
            finder = finders.new_table({
              results = data,
            }),
            sorter = conf.file_sorter(opts),
          })
          :find()
    end,
  })
end

return M
