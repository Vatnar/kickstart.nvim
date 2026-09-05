-- Ported IdeaVim keymaps that don't require LSP / IDE actions.
-- LSP-specific bindings (gh header/source, refactor) live in init.lua LspAttach.

local map = vim.keymap.set

-- =========================
-- Window / Editor Management
-- =========================
-- Split windows (IdeaVim: <leader>vs/<leader>vd)
map('n', '<leader>vs', '<C-w>s', { desc = '[V]ertical [S]plit horizontal / Split Horizontally' })
map('n', '<leader>vd', '<C-w>v', { desc = '[V]ertical split / Split Vertically' })
map('n', '<leader>vw', '<C-w>c', { desc = '[V]ertical [W]indow / Close Editor' })

-- Window navigation (IdeaVim: <leader>vh/vj/vk/vl)
map('n', '<leader>vh', '<C-w>h', { desc = 'Window [H] left' })
map('n', '<leader>vj', '<C-w>j', { desc = 'Window [J] down' })
map('n', '<leader>vk', '<C-w>k', { desc = 'Window [K] up' })
map('n', '<leader>vl', '<C-w>l', { desc = 'Window [L] right' })

-- =========================
-- Movement & Editing Enhancements
-- =========================
-- Move line/selection up/down (Alt+j / Alt+k), all modes
map('n', '<A-j>', ':m .+1<CR>', { desc = 'Move line down' })
map('n', '<A-k>', ':m .-2<CR>', { desc = 'Move line up' })
map('i', '<A-j>', '<Esc>:m .+1<CR>gi', { desc = 'Move line down' })
map('i', '<A-k>', '<Esc>:m .-2<CR>gi', { desc = 'Move line up' })
map('x', '<A-j>', ":m '>+1<CR>gv", { desc = 'Move selection down' })
map('x', '<A-k>', ":m '<-2<CR>gv", { desc = 'Move selection up' })

-- Join line but keep cursor position
map('n', 'J', 'mzJ`z', { desc = 'Join line, keep cursor' })

-- Keep cursor centered on search / scroll
map('n', 'n', 'nzzzv', { desc = 'Next match, centered' })
map('n', 'N', 'Nzzzv', { desc = 'Prev match, centered' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down, centered' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up, centered' })

-- Visual indent keeps selection
map('x', '<', '<gv', { desc = 'Indent left, keep selection' })
map('x', '>', '>gv', { desc = 'Indent right, keep selection' })

-- =========================
-- File Management (IdeaVim: <leader>f*)
-- =========================
map('n', '<leader>fn', ':enew<CR>', { desc = '[F]ile [N]ew' })
map('n', '<leader>fs', '<Cmd>wall<CR>', { desc = '[F]ile [S]ave All' })

-- =========================
-- Search / Navigation (IdeaVim: <leader>s*)
-- =========================
local telescope_builtin = require 'telescope.builtin'
-- Search Everywhere -> find files
map('n', '<leader>se', telescope_builtin.find_files, { desc = '[S]earch [E]verywhere' })
-- Go to Symbol (document symbols)
map('n', '<leader>so', telescope_builtin.lsp_document_symbols, { desc = '[S]earch sy[m]bol / Go to Symbol' })
-- Recent Files
map('n', '<leader>sr', telescope_builtin.oldfiles, { desc = '[S]earch [R]ecent Files' })
