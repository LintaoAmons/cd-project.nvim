local utils = require("cd-project.utils")
local success, Snacks = pcall(require, "snacks")
if not success or not Snacks.picker then
  utils.log_error("snacks.nvim (with picker enabled) not installed")
  return
end

local api = require("cd-project.api")
local common = require("cd-project.adapter.common")

local M = {}

-- Pick a directory inside the project and cd to it
---@param project CdProject.Project
function M.dir_picker(project)
  common.list_dirs(project.path, function(dirs)
    local items = {}
    for i, dir in ipairs(dirs) do
      table.insert(items, {
        idx = i,
        text = dir,
        file = project.path .. "/" .. dir,
        dir = true,
      })
    end
    Snacks.picker.pick({
      source = "cd_project_dirs",
      title = "cd to dir in " .. project.name,
      finder = function()
        return items
      end,
      format = "text",
      confirm = function(picker, item)
        picker:close()
        if item == nil then
          return
        end
        api.cd_project(item.file)
      end,
    })
  end)
end

---@param callback fun(project: CdProject.Project): nil
---@param opts? {prompt?: string}
function M.project_picker(callback, opts)
  opts = opts or {}

  local function finder()
    local projects = common.get_entries()
    local name_width, path_width = common.column_widths(projects)
    local items = {}
    for i, project in ipairs(projects) do
      table.insert(items, {
        idx = i,
        text = project.name .. " " .. project.path,
        file = project.path,
        dir = true,
        project = project,
        name_width = name_width,
        path_width = path_width,
      })
    end
    return items
  end

  Snacks.picker.pick({
    source = "cd_project",
    title = opts.prompt or "cd to project",
    finder = finder,
    format = function(item)
      local name, path = common.format_columns(item.project, item.name_width, item.path_width)
      return {
        { name, "SnacksPickerLabel" },
        { " │ ", "SnacksPickerDelim" },
        { path, "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item == nil then
        return
      end
      callback(item.project)
    end,
    actions = {
      cd_project_tab = function(picker, item)
        if item == nil then
          return
        end
        picker:close()
        api.cd_project(item.project.path, { cd_cmd = "tabe | tcd" })
      end,
      cd_project_window = function(picker, item)
        if item == nil then
          return
        end
        picker:close()
        api.cd_project(item.project.path, { cd_cmd = "lcd" })
      end,
      delete_project = function(picker, item)
        if item == nil then
          return
        end
        api.delete_project(item.project)
        picker:find({ refresh = true })
      end,
      search_files = function(picker, item)
        if item == nil then
          return
        end
        picker:close()
        Snacks.picker.files({ cwd = item.project.path })
      end,
      grep_content = function(picker, item)
        if item == nil then
          return
        end
        picker:close()
        Snacks.picker.grep({ cwd = item.project.path })
      end,
      search_dirs = function(picker, item)
        if item == nil then
          return
        end
        picker:close()
        M.dir_picker(item.project)
      end,
      rename_project = function(picker, item)
        if item == nil then
          return
        end
        vim.ui.input({ prompt = "Rename project to: ", default = item.project.name }, function(new_name)
          if new_name and new_name ~= "" then
            local project = item.project
            project.name = new_name
            project.visited_at = os.time() -- Update the timestamp to reflect the rename action
            api.update_project(project.id, project)
            picker:find({ refresh = true })
          end
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-t>"] = { "cd_project_tab", mode = { "i", "n" }, desc = "Open in new tab" },
          ["<c-e>"] = { "cd_project_window", mode = { "i", "n" }, desc = "Open in current window" },
          ["<c-d>"] = { "delete_project", mode = { "i", "n" }, desc = "Delete project" },
          ["<c-r>"] = { "rename_project", mode = { "i", "n" }, desc = "Rename project" },
          ["<c-f>"] = { "search_files", mode = { "i", "n" }, desc = "Find files in project" },
          ["<c-g>"] = { "grep_content", mode = { "i", "n" }, desc = "Grep in project" },
          ["<c-s>"] = { "search_dirs", mode = { "i", "n" }, desc = "cd to dir in project" },
        },
      },
      list = {
        keys = {
          ["<c-t>"] = "cd_project_tab",
          ["<c-e>"] = "cd_project_window",
          ["<c-d>"] = "delete_project",
          ["<c-r>"] = "rename_project",
          ["<c-f>"] = "search_files",
          ["<c-g>"] = "grep_content",
          ["<c-s>"] = "search_dirs",
        },
      },
    },
  })
end

---@param opts? table
function M.cd_project(opts)
  opts = opts or {}
  M.project_picker(function(project)
    api.cd_project(project.path)
  end, opts)
end

---@param opts? table
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
      local items = {}
      for i, dir in ipairs(data) do
        if dir ~= "" then
          table.insert(items, {
            idx = i,
            text = dir,
            file = dir,
            dir = true,
          })
        end
      end

      Snacks.picker.pick({
        source = "cd_project_add",
        title = "Select dir to add",
        finder = function()
          return items
        end,
        format = "text",
        confirm = function(picker, item)
          picker:close()
          if item == nil then
            return
          end
          common.prompt_name_and_add(item.text)
        end,
      })
    end,
  })
end

return M
