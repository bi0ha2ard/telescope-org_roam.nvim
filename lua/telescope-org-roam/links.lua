local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local roam = require('org-roam')
local org = require('orgmode.api')

local utils = require('telescope-org-roam.utils')

local TYPE_LINK = 0
local TYPE_BACKLINK = 1

local link_type_to_symbol = function(t)
  if t == TYPE_LINK then
    return "->"
  else
    return "<-"
  end
end

local get_links = function(opts)
  local file = opts.file or vim.api.nvim_buf_get_name(0)
  local nodes = {}
  local nodes_in_file = roam.database:find_nodes_by_file_sync(file)
  if opts.links then
    for id, _ in pairs(roam.database:get_file_links_sync(file)) do
      local node = roam.database:get_sync(id)
      local entry = utils.as_entry(node.title, node)
      entry.link_type = TYPE_LINK
      table.insert(nodes, entry)
    end
  end
  if opts.backlinks then
    for id, _ in pairs(roam.database:get_file_backlinks_sync(file)) do
      local node = roam.database:get_sync(id)
      for _, file_node in ipairs(nodes_in_file) do
        local locs = node.linked[file_node.id]
        for _, loc in ipairs(locs or {}) do
          local entry = utils.as_entry(node.title, node)
          local f = org.load(node.file)
          if f then
            local headline = f:get_closest_headline({ loc.row + 1, loc.column + 1 })
            if headline then
              entry.title = headline.title
              entry.level = headline.level
            end
          end
          entry.link_type = TYPE_BACKLINK
          entry.line = loc.row + 1
          table.insert(nodes, entry)
        end
      end
    end
  end

  return nodes
end

local make_entry = function(opts)
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 2 },
      { remaining = true },
      --{ width = vim.F.if_nil(opts.tag_width, 20) },
    },
  })

  local function make_display(entry)
    return displayer({ link_type_to_symbol(entry.value.link_type), entry.line })
  end

  return function(entry)
    local lnum = entry.line
    local location = vim.fn.fnamemodify(entry.file, ':t')
    local line = (entry.level > 0 and string.format('%s %s', string.rep('*', entry.level), entry.title) or entry.title)
    local tags = table.concat(entry.tags, ":")

    return {
      value = entry,
      ordinal = entry.title .. ' ' .. tags .. ' ' .. location,
      filename = entry.file,
      lnum = lnum,
      context = 1,
      display = make_display,
      location = location,
      line = line,
      tags = tags,
    }
  end
end

return function(opts)
  opts = opts or {}
  if not opts.links and not opts.backlinks then
    opts.links = true
  end

  pickers
      .new(opts, {
        prompt_title = 'Links and backlinks',
        finder = finders.new_table({
          results = get_links(opts),
          entry_maker = opts.entry_maker or make_entry(opts),
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
      })
      :find()
end
