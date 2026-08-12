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

local api = require("cd-project.api")
local common = require("cd-project.adapter.common")

local M = {}

local get_entries = common.get_entries

-- Pick a directory inside the project and cd to it
---@param project CdProject.Project
function M.dir_picker(project)
  common.list_dirs(project.path, function(dirs)
    pickers
        .new({}, {
          prompt_title = "cd to dir in " .. project.name,
          finder = finders.new_table({ results = dirs }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              api.cd_project(project.path .. "/" .. selected.value)
            end)
            return true
          end,
        })
        :find()
  end)
end

---@param callback fun(project: CdProject.Project): nil
---@param opts? {prompt?: string}
function M.project_picker(callback, opts)
  opts = opts or {}

  local projects = get_entries()

  local function start_picker(project_list)
    local name_width, path_width = common.column_widths(project_list)
    pickers
        .new(opts, {
          prompt_title = opts.prompt or "cd to project",
          finder = finders.new_table({
            results = project_list,
            ---@param project CdProject.Project
            entry_maker = function(project)
              local name, path = common.format_columns(project, name_width, path_width)
              local display = string.format("%s │ %s", name, path)
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

            map({ "i", "n" }, "<c-f>", function()
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              actions.close(prompt_bufnr)
              require("telescope.builtin").find_files({ cwd = selected.value.path })
            end, { desc = "Find files in project" })

            map({ "i", "n" }, "<c-g>", function()
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              actions.close(prompt_bufnr)
              require("telescope.builtin").live_grep({ cwd = selected.value.path })
            end, { desc = "Grep in project" })

            map({ "i", "n" }, "<c-s>", function()
              local selected = action_state.get_selected_entry()
              if selected == nil then
                return
              end
              actions.close(prompt_bufnr)
              M.dir_picker(selected.value)
            end, { desc = "cd to dir in project" })

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
                local selected = action_state.get_selected_entry()
                if selected == nil then
                  return
                end
                common.prompt_name_and_add(selected.value)
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
