# Telescope pickers for [org-roam](https://github.com/chipsenkbeil/org-roam.nvim)

An alternative to the built-in node finder UI.

## Installation and setup

Install the plugin with your favorite plugin manager, then add the following in your telescope configuration:

```lua
require('telescope').load_extension('org_roam')
```

## Find Nodes

Find a node and jump to it:

```
:Telescope org_roam find_files
```

## Links and backlinks

Outgoing links (indicated with `->`):

```
:Telescope org_roam links
```

Backlinks (indicated with `<-`):

```
:Telescope org_roam links backlinks=true
```

Both:

```
:Telescope org_roam links links=true backlinks=true
```

## Missing features

- Insert node
- Creating now nodes
- Use the async APIs?

## See also

- [telescope-orgmode](https://github.com/nvim-orgmode/telescope-orgmode.nvim)
