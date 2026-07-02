local utils = require("cd-project.utils")

---@param tbl table
---@param path string
local write_json_file = function(tbl, path)
  local content = vim.fn.json_encode(tbl)

  if vim.g.cd_project_config.format_json ~= false and vim.fn.executable("jq") == 1 then
    local result = vim.system({ "jq", "--sort-keys", "--monochrome-output" }, { stdin = content }):wait()
    if result.code == 0 then
      content = result.stdout
    else
      utils.log_error("Failed to format JSON with jq, writing unformatted: " .. (result.stderr or ""))
    end
  end

  local file, err = io.open(path, "w")
  if not file then
    return utils.log_error("Could not open file: " .. (err or path))
  end

  file:write(content)
  file:close()
end

---@param path string
---@return table
local read_or_init_json_file = function(path)
  local file = io.open(path, "r")
  if not file then
    write_json_file({}, path)
    return {}
  end

  local content = file:read("*a")
  file:close()

  local ok, decoded = pcall(vim.fn.json_decode, content)
  if not ok or type(decoded) ~= "table" then
    utils.log_error("Invalid JSON in " .. path .. ", starting with an empty project list (file left untouched)")
    return {}
  end
  return decoded
end

return {
  write_json_file = write_json_file,
  read_or_init_json_file = read_or_init_json_file,
}
