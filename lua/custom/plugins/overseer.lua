return {

    "stevearc/overseer.nvim",
    config = function()
        local overseer = require("overseer")

        -- setup
        overseer.setup()

        -- global build directory (default)
        vim.g.cmake_build_dir = "build"

        -- command to change build directory
        vim.api.nvim_create_user_command("SetBuildDir", function(opts)
            vim.g.cmake_build_dir = opts.args
            print("Build directory set to: " .. vim.g.cmake_build_dir)
        end, { nargs = 1 })

        -- CMake Build
        overseer.register_template({
            name = "CMakeBuild",
            builder = function()
                local build_type = vim.fn.input("Build type (Debug/Release/RelWithDebInfo/MinSizeRel): ", "Debug")
                return {
                    cmd = { "cmake" },
                    args = { "--build", vim.g.cmake_build_dir, "--config", build_type },
                    components = { "default" },
                }
            end,
        })

        -- CMake Run
        overseer.register_template({
            name = "CMakeRun",
            builder = function()
                local build_type = vim.fn.input("Run build type (Debug/Release/RelWithDebInfo/MinSizeRel): ", "Debug")
                local dir_to_search = vim.g.cmake_build_dir .. "/" .. build_type

                local handle = io.popen("find " .. dir_to_search .. " -maxdepth 1 -type f -executable 2>/dev/null")
                local result = handle:read("*a")
                handle:close()

                local targets = {}
                for t in result:gmatch("[^\r\n]+") do
                    table.insert(targets, t)
                end

                if #targets == 0 then
                    handle = io.popen("find " .. vim.g.cmake_build_dir .. " -maxdepth 1 -type f -executable 2>/dev/null")
                    result = handle:read("*a")
                    handle:close()
                    for t in result:gmatch("[^\r\n]+") do
                        table.insert(targets, t)
                    end
                end

                return {
                    cmd = { vim.fn.input("Run target: ", targets[1] or "./" .. vim.g.cmake_build_dir .. "/") },
                    components = { "default" },
                    on_complete = function(task, status)
                        overseer.quick_action("open float")
                    end,
                }
            end,
        })

        -- CMake Debug template
        overseer.register_template({
            name = "CMakeDebug",
            builder = function()
                local build_type = vim.fn.input("Debug build type (Debug/Release/RelWithDebInfo/MinSizeRel): ", "Debug")
                local dir_to_search = vim.g.cmake_build_dir .. "/" .. build_type

                -- find executable targets
                local handle = io.popen("find " .. dir_to_search .. " -maxdepth 1 -type f -executable 2>/dev/null")
                local result = handle:read("*a")
                handle:close()

                local targets = {}
                for t in result:gmatch("[^\r\n]+") do
                    table.insert(targets, t)
                end

                -- fallback: search directly in build dir
                if #targets == 0 then
                    handle = io.popen("find " .. vim.g.cmake_build_dir .. " -maxdepth 1 -type f -executable 2>/dev/null")
                    result = handle:read("*a")
                    handle:close()
                    for t in result:gmatch("[^\r\n]+") do
                        table.insert(targets, t)
                    end
                end

                -- no executable found
                if #targets == 0 then
                    vim.notify("No executables found in build directory", vim.log.levels.ERROR)
                    return {
                        cmd = { "echo", "No executable found" },
                        components = { "default" },
                    }
                end

                -- select target if multiple exist
                local target = targets[1]
                if #targets > 1 then
                    local choices = { "Select executable:" }
                    vim.list_extend(choices, targets)
                    local choice = vim.fn.inputlist(choices)
                    if choice < 1 or choice > #targets then
                        vim.notify("Debug cancelled", vim.log.levels.WARN)
                        return {
                            cmd = { "echo", "Debug cancelled" },
                            components = { "default" },
                        }
                    end
                    target = targets[choice]
                end

                -- return LLDB task
                return {
                    cmd = { "lldb", target },
                    components = { "default" },
                    on_complete = function(task, status)
                        overseer.quick_action("open float")
                    end,
                }
            end,
        })
        -- CMake Clean
        overseer.register_template({
            name = "CMakeClean",
            builder = function()
                return {
                    cmd = { "cmake" },
                    args = { "--build", vim.g.cmake_build_dir, "--target", "clean" },
                    components = { "default" },
                }
            end,
        })

        -- CMake Configure
        overseer.register_template({
            name = "CMakeConfigure",
            builder = function()
                local build_type = vim.fn.input("Build type (Debug/Release): ", "Debug")
                return {
                    cmd = { "cmake" },
                    args = { "-S", ".", "-B", vim.g.cmake_build_dir, "-DCMAKE_BUILD_TYPE=" .. build_type },
                    components = { "default" },
                }
            end,
        })

        -- CMake Test
        overseer.register_template({
            name = "CMakeTest",
            builder = function()
                return {
                    cmd = { "ctest" },
                    args = { "--test-dir", vim.g.cmake_build_dir },
                    components = { "default", "on_output_open" },
                }
            end,
        })

        -- key mappings
        vim.keymap.set("n", "<leader>ob", "<cmd>OverseerRun CMakeBuild<CR>", { desc = "Build project" })
        vim.keymap.set("n", "<leader>oc", "<cmd>OverseerRun CMakeConfigure<CR>", { desc = "Configure project" })
        vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun CMakeRun<CR>", { desc = "Run project" })
        vim.keymap.set("n", "<leader>od", "<cmd>OverseerRun CMakeDebug<CR>", { desc = "Debug project" })
        vim.keymap.set("n", "<leader>ot", "<cmd>OverseerRun CMakeTest<CR>", { desc = "Run tests" })
        vim.keymap.set("n", "<leader>ox", "<cmd>OverseerRun CMakeClean<CR>", { desc = "Clean build" })
        vim.keymap.set("n", "<leader>of", "<cmd>OverseerQuickAction open float<CR>", { desc = "Open Floating Terminal" })
        vim.keymap.set("n", "<leader>oo", "<cmd>OverseerQuickAction open vsplit<CR>", { desc = "Open vsplit Terminal" })
        vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "Open running list" })
    end,

}
