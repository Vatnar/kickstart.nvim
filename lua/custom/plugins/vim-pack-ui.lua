-- vim.pack wrapper exposed through Telescope (lazy-like management UI)
-- <leader>sp lists plugins. Inside the picker:
--   <C-r>  update the selected plugin
--   <C-a>  update all plugins
--   <C-d>  remove the selected plugin

local function collect_plugins()
  local entries = {}
  for _, info in ipairs(vim.pack.get()) do
    local spec = info.spec or {}
    table.insert(entries, {
      name = spec.name or 'unknown',
      src = spec.src or '',
      rev = info.rev or '?',
      active = info.active,
      path = info.path or '',
    })
  end
  table.sort(entries, function(a, b) return a.name < b.name end)
  return entries
end

local function open_picker()
  local actions = require 'telescope.actions'
  local state = require 'telescope.actions.state'
  local finders = require 'telescope.finders'
  local pickers = require 'telescope.pickers'

  pickers
    .new({}, {
      prompt_title = 'vim.pack plugins',
      finder = finders.new_table {
        results = collect_plugins(),
        entry_maker = function(entry)
          local status = entry.active and 'active' or 'installed'
          return {
            value = entry.name,
            display = string.format('%s  (%s)', entry.name, status),
            ordinal = entry.name .. ' ' .. entry.src,
            name = entry.name,
          }
        end,
      },
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local function selected_name()
          local entry = state.get_selected_entry()
          return entry and entry.name
        end

        map('i', '<C-r>', function()
          local name = selected_name()
          actions.close(prompt_bufnr)
          if name then
            vim.pack.update({ name })
          end
        end)

        map('i', '<C-a>', function()
          actions.close(prompt_bufnr)
          vim.pack.update()
        end)

        map('i', '<C-d>', function()
          local name = selected_name()
          actions.close(prompt_bufnr)
          if name then
            vim.pack.del({ name })
          end
        end)

        return true
      end,
    })
    :find()
end

vim.keymap.set('n', '<leader>sp', open_picker, { desc = '[S]earch [P]lugins (vim.pack)' })