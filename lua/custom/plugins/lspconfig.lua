return {
    -- Main LSP plugin
    "neovim/nvim-lspconfig",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        { "j-hui/fidget.nvim",    opts = {} },
        "saghen/blink.cmp",
    },
    opts = {
        servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
                        diagnostics = { globals = { "vim" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            },
            clangd = {
                keys = {
                    { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                },
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                            "Makefile",
                            "configure.ac",
                            "configure.in",
                            "config.h.in",
                            "meson.build",
                            "meson_options.txt",
                            "build.ninja"
                        )(fname)
                        or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname)
                        or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
                end,
                capabilities = {
                    offsetEncoding = { "utf-16" },
                },
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                    "--clang-tidy-checks=" .. vim.fn.expand("~/cppconfig/.clang-tidy"),
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            },
            omnisharp = {
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(".sln", ".csproj", ".git")(fname)
                end,
                cmd = { "omnisharp" },
                on_attach = function(client, bufnr)
                    local bufopts = { noremap = true, silent = true, buffer = bufnr }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
                end,
                flags = { debounce_text_changes = 150 },
            },
        },
    },
    config = function(_, opts)
        local lspconfig = require("lspconfig")

        -- Diagnostics setup
        vim.diagnostic.config {
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN] = "󰀪 ",
                    [vim.diagnostic.severity.INFO] = "󰋽 ",
                    [vim.diagnostic.severity.HINT] = "󰌶 ",
                },
            } or {},
            virtual_text = {
                source = "if_many",
                spacing = 2,
                format = function(diagnostic)
                    return diagnostic.message
                end,
            },
        }

        -- LspAttach keymaps & inlay hints
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
                map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
                map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
                map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
                map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

                -- LSP diagnostic navigation
                vim.keymap.set("n", "<F3>", function()
                    vim.diagnostic.goto_next({ severity = nil }) -- nil = all severities
                end, { desc = "Go to next diagnostic" })

                vim.keymap.set("n", "<S-F3>", function()
                    vim.diagnostic.goto_prev({ severity = nil })
                end, { desc = "Go to previous diagnostic" })

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })

        -- Capabilities from blink.cmp
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- Install servers automatically
        local ensure_installed = vim.tbl_keys(opts.servers or {})
        vim.list_extend(ensure_installed, { "stylua" })
        require("mason-tool-installer").setup { ensure_installed = ensure_installed }
        require("mason-lspconfig").setup {
            ensure_installed = {},
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local server_opts = opts.servers[server_name] or {}
                    server_opts.capabilities =
                        vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
                    lspconfig[server_name].setup(server_opts)
                end,
            },
        }

        -- clangd extensions
        local ok, clangd_ext = pcall(require, "clangd_extensions")
        if ok then
            clangd_ext.setup({ server = opts.servers.clangd })
        end
    end,
}
