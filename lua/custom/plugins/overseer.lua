


return {

    "stevearc/overseer.nvim",
    config = function()
        require("overseer").setup()

        local overseer = require("overseer")

        -- Create CMake build and run tasks
        overseer.register_template({
            name = "CMakeBuild",
            builder = function()
                local build_type = vim.fn.input("Build type (Debug/Release/RelWithDebInfo/MinSizeRel): ", "Debug")
                return {
                    cmd = { "cmake" },
                    args = { "--build", "build", "--config", build_type },
                    components = { "default" },
                }
            end,
        })




        overseer.register_template({
            name = "CMakeRun",
            builder = function()
                -- Ask which build type to use
                local build_type = vim.fn.input("Run build type (Debug/Release/RelWithDebInfo/MinSizeRel): ", "Debug")

                -- Find executables in build/<build_type> if multi-config, or build/ otherwise
                local build_dir = "build/" .. build_type
                local handle = io.popen("find " .. build_dir .. " -maxdepth 1 -type f -executable 2>/dev/null")
                local result = handle:read("*a")
                handle:close()

                local targets = {}
                for t in result:gmatch("[^\r\n]+") do
                    table.insert(targets, t)
                end

                if #targets == 0 then
                    -- fallback to just build/
                    handle = io.popen("find build -maxdepth 1 -type f -executable")
                    result = handle:read("*a")
                    handle:close()
                    for t in result:gmatch("[^\r\n]+") do
                        table.insert(targets, t)
                    end
                end

                return {
                    cmd = { vim.fn.input("Run target: ", targets[1] or "./build/") },
                    components = { "default" },
                    on_complete = function(task, status)
                        require("overseer").quick_action("open float")
                    end,
                }
            end,
        })


        overseer.register_template({

            name = "CMakeClean",
            builder = function()
                return {
                    cmd = { "cmake" },
                    args = { "--build", "build", "--target", "clean" },
                    components = { "default" },
                }
            end,
        })

        overseer.register_template({
            name = "CMakeConfigure",
            builder = function()
                local build_type = vim.fn.input("Build type (Debug/Release): ", "Debug")
                return {
                    cmd = { "cmake" },
                    args = { "-S", ".", "-B", "build", "-DCMAKE_BUILD_TYPE=" .. build_type },
                    components = { "default" },
                }
            end,
        })

        overseer.register_template({
            name = "CMakeTest",
            builder = function()
                return {
                    cmd = { "ctest" },
                    args = { "--test-dir", "build" },
                    components = { "default", "on_output_open" },
                }
            end,
        })

        -- mappings

        vim.keymap.set("n", "<leader>ob", "<cmd>OverseerRun CMakeBuild<CR>", { desc = "Build project" })
        vim.keymap.set("n", "<leader>oc", "<cmd>OverseerRun CMakeConfigure<CR>", { desc = "Configure project" })
        vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun CMakeRun<CR>", { desc = "Run project" })
        vim.keymap.set("n", "<leader>ot", "<cmd>OverseerRun CMakeTest<CR>", { desc = "Run tests" })
        vim.keymap.set("n", "<leader>ox", "<cmd>OverseerRun CMakeClean<CR>", { desc = "Clean build" })
        vim.keymap.set("n", "<leader>of", "<cmd>OverseerQuickAction open float<CR>", { desc = "Open Floating Terminal" })

    end,

}
