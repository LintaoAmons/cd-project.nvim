local M = {}

---@class CdProject.Hook
---@field callback fun(param: string)
---@field name? string
---@field order? number
---@field cd_cmd? "cd" | "tabe | tcd" | "lcd"
---@field trigger_point? string
---@field pattern? string
---@field match_rule? fun(dir: string): boolean
---
---@param hooks CdProject.Hook[]
---@param dir string
---@param point string
---@param cd_cmd? "cd" | "tabe | tcd" | "lcd"
---@return CdProject.Hook[]
M.get_hooks = function(hooks, dir, point, cd_cmd)
  -- print("[DEBUG hooks.lua] Getting hooks for point: " .. point .. ", dir: " .. dir)
  local matching_hooks = {}
  for _, hook in ipairs(hooks) do
    local trigger_point = hook.trigger_point or "AFTER_CD"
    -- print("[DEBUG hooks.lua] Checking hook: " .. (hook.name or "unnamed") .. ", trigger_point: " .. trigger_point)

    -- Check if the hook's trigger_point matches the given point
    if trigger_point ~= point then
      -- print("[DEBUG hooks.lua] Hook skipped - trigger point mismatch")
      goto continue
    end

    if hook.cd_cmd and hook.cd_cmd ~= cd_cmd then
      -- print("[DEBUG hooks.lua] Hook skipped - cd_cmd mismatch, expected: " .. (cd_cmd or "nil") .. ", got: " .. (hook.cd_cmd or "nil"))
      goto continue
    end

    local matches = false
    if hook.match_rule and hook.match_rule(dir) then
      -- print("[DEBUG hooks.lua] Hook matched - match_rule returned true")
      matches = true
      -- If no match_rule, check if pattern exists in dir
    elseif hook.pattern and dir:find(hook.pattern) then
      -- print("[DEBUG hooks.lua] Hook matched - pattern found in dir: " .. hook.pattern)
      matches = true
      -- If neither match_rule nor pattern is specified, consider it a match
    elseif hook.match_rule == nil and hook.pattern == nil then
      -- print("[DEBUG hooks.lua] Hook matched - no specific match criteria")
      matches = true
    end

    -- Add hook to matching_hooks if it matches
    if matches then
      -- print("[DEBUG hooks.lua] Adding hook to matching list: " .. (hook.name or "unnamed"))
      table.insert(matching_hooks, hook)
    end
    ::continue::
  end

  -- print("[DEBUG hooks.lua] Found " .. #matching_hooks .. " matching hooks")
  -- Sort hooks by order if order is defined
  table.sort(matching_hooks, function(a, b)
    return (a.order or 0) < (b.order or 0)
  end)
  -- print("[DEBUG hooks.lua] Hooks sorted by order")

  return matching_hooks
end

return M
