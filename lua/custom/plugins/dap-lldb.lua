return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "julianolf/nvim-dap-lldb",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Setup DAP UI
        dapui.setup()
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- LLDB adapter
        dap.adapters.lldb = {
            type = 'executable',
            command = 'lldb', -- just the standard lldb
            name = 'lldb'
        }

        -- C/C++ configuration
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "lldb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/Debug/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = true,
                args = {},
                runInTerminal = false,
            },
        }

        dap.set_log_level('DEBUG')
        -- Use same configuration for C
        dap.configurations.c = dap.configurations.cpp

        -- Keymaps
        vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/Continue" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
        vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end, { desc = "Conditional breakpoint" })
        vim.keymap.set("n", "<leader>lp", function()
            dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end, { desc = "Log point" })
        vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
    end,
}
