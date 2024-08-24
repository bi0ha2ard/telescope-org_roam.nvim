return require('telescope').register_extension({
  exports = {
    find_nodes = require('telescope-org_roam.init').find_nodes,
    links = require('telescope-org_roam.init').links,
  }
})
