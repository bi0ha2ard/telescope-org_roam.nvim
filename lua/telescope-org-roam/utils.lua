local M = {}

M.as_entry = function(title, node)
  return {
    title = title,
    file = node.file,
    level = node.level,
    tags = node.tags,
    line = node.range.start.row + 1
  }
end

local roam = nil
local org = nil

M.roam = function()
  if not roam then
    roam = require('org-roam')
  end
  return roam
end

M.org = function()
  if not org then
    org = require('orgmode.api')
  end
  return org
end

return M
