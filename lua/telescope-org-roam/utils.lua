local M = {}

M.as_entry = function(title, node)
  return {
    title = title,
    file = node.file,
    level = node.level,
    tags = node.tags,
    line = node.range.start.row
  }
end

return M
