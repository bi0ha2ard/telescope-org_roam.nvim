local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local utils = require('telescope-org-roam.utils')

local get_entries = function(opts)
  local roam = utils.roam()
  local ids = roam.database:ids()
  local nodes = {}

  for _, id in ipairs(ids) do
    local node = roam.database:get_sync(id)
    if node then
      table.insert(nodes, utils.as_entry(node.title, node))
      for _, alias in ipairs(node.aliases) do
        if alias ~= node.title then
          table.insert(nodes, utils.as_entry(alias, node))
        end
      end
    end
  end
  table.sort(nodes, function(a, b) return string.lower(a.title) > string.lower(b.title) end)
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
    local prefix = ""
    if entry.level > 0 then
      prefix = string.rep('*', entry.level) .. " "
    end
    local line = string.format('%s%s', prefix, entry.title)
    local tags = table.concat(entry.tags, ":")

    return {
      value = entry,
      ordinal = entry.title .. ' ' .. tags .. ' '.. location,
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
        prompt_title = 'Search Node',
        finder = finders.new_table({
          results = get_entries(opts),
          entry_maker = opts.entry_maker or make_entry(opts),
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
      })
      :find()
end
