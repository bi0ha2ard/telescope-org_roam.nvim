local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local utils = require('telescope-org_roam.utils')

local include_node = function(node, tags)
  if vim.tbl_isempty(tags) then
    return true
  end
  for _, tag in ipairs(node.tags) do
    if vim.tbl_contains(tags, tag) then
      return true
    end
  end
  return false
end

local get_entries = function(opts)
  local roam = utils.roam()
  local tags = {}
  if opts.tags then
    tags = vim.split(opts.tags, ",")
  end
  local ids = roam.database:ids()
  local nodes = {}

  for _, id in ipairs(ids) do
    local node = roam.database:get_sync(id)
    if node and include_node(node, tags) then
      table.insert(nodes, utils.as_entry(node.title, node))
      for _, alias in ipairs(node.aliases) do
        if alias ~= node.title then
          table.insert(nodes, utils.as_entry(alias, node))
        end
      end
    end
  end
  if opts.sort_by_time then
    table.sort(nodes, function(a, b) return a.mtime > b.mtime end)
  else
    table.sort(nodes, function(a, b) return string.lower(a.title) > string.lower(b.title) end)
  end
  return nodes
end

local make_entry = function(opts)
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = vim.F.if_nil(opts.tag_width, 10) },
      { remaining = true },
      --{ width = vim.F.if_nil(opts.tag_width, 20) },
    },
  })

  local function make_display(entry)
    return displayer({ entry.tags, entry.line })
  end

  return function(entry)
    local lnum = entry.line
    -- if it's the file and not a headline
    if entry.level == 0 and entry.line == 1 then
      lnum = 0
    end
    local location = vim.fn.fnamemodify(entry.filename, ':t')
    if entry.level > 0 then
      location = string.format("%s:%i", location, lnum)
    end
    local line = (entry.level > 0 and string.format('%s %s', string.rep('*', entry.level), entry.title) or entry.title)
    local tags = table.concat(entry.tags, ":")

    return {
      value = entry,
      ordinal = tags .. ' ' .. line .. ' ' .. location,
      filename = entry.file,
      lnum = lnum,
      display = make_display,
      location = location,
      line = line,
      tags = tags,
    }
  end
end

return function(opts)
  opts = opts or {}

  pickers
      .new(opts, {
        prompt_title = 'Find Node',
        finder = finders.new_table({
          results = get_entries(opts),
          entry_maker = opts.entry_maker or make_entry(opts),
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
      })
      :find()
end
