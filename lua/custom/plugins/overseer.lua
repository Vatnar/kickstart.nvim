return {
	"stevearc/overseer.nvim",
	config = function()
		local overseer = require("overseer")

		-- setup
		overseer.setup()

		-- global settings
		vim.g.build_dir = "build" -- default build directory

		-- command to change build directory
		vim.api.nvim_create_user_command("SetBuildDir", function(opts)
			vim.g.build_dir = opts.args
			print("Build directory set to: " .. vim.g.build_dir)
		end, { nargs = 1 })

		----------------------------------------------------------------------
		-- HELPERS
		----------------------------------------------------------------------

		-- Detect build system automatically
		local function detect_build_system()
			if vim.fn.filereadable("CMakeLists.txt") == 1 then
				return "cmake"
			elseif vim.fn.filereadable("meson.build") == 1 then
				return "meson"
			else
				return nil
			end
		end

		local function get_build_cmd(build_type, threads)
			threads = threads or 12
			local sys = detect_build_system()
			if sys == "cmake" then
				return {
					cmd = { "cmake" },
					args = { "--build", vim.g.build_dir, "--config", build_type },
				}
			elseif sys == "meson" then
				return {
					cmd = { "meson" },
					args = { "compile", "-C", vim.g.build_dir, "-j", tostring(threads) },
				}
			else
				error("No build system detected!")
			end
		end

		local function get_configure_cmd(build_type)
			local sys = detect_build_system()
			if sys == "cmake" then
				return {
					cmd = { "cmake" },
					args = { "-S", ".", "-B", vim.g.build_dir, "-DCMAKE_BUILD_TYPE=" .. build_type },
				}
			elseif sys == "meson" then
				return {
					cmd = { "meson" },
					args = { vim.g.build_dir, "-Dbuildtype=" .. build_type:lower() },
				}
			else
				error("No build system detected!")
			end
		end

		local function get_clean_cmd()
			local sys = detect_build_system()
			if sys == "cmake" then
				return {
					cmd = { "cmake" },
					args = { "--build", vim.g.build_dir, "--target", "clean" },
				}
			elseif sys == "meson" then
				return {
					cmd = { "meson" },
					args = { "clean", "-C", vim.g.build_dir },
				}
			else
				error("No build system detected!")
			end
		end

		local function get_test_cmd()
			local sys = detect_build_system()
			if sys == "cmake" then
				return {
					cmd = { "ctest" },
					args = { "--test-dir", vim.g.build_dir },
				}
			elseif sys == "meson" then
				return {
					cmd = { "meson" },
					args = { "test", "-C", vim.g.build_dir },
				}
			else
				error("No build system detected!")
			end
		end

		----------------------------------------------------------------------
		-- Templates
		----------------------------------------------------------------------

		overseer.register_template({
			name = "Build",
			builder = function()
				local build_type = vim.fn.input("Build type (Debug/Release/...): ", "Debug")
				local threads = vim.fn.input("Threads (default 12): ", "12")
				local task = get_build_cmd(build_type, tonumber(threads))
				task.components = { "default" }
				return task
			end,
		})

		overseer.register_template({
			name = "Configure",
			builder = function()
				local build_type = vim.fn.input("Build type (Debug/Release): ", "Debug")
				local task = get_configure_cmd(build_type)
				task.components = { "default" }
				return task
			end,
		})

		overseer.register_template({
			name = "Clean",
			builder = function()
				local task = get_clean_cmd()
				task.components = { "default" }
				return task
			end,
		})

		overseer.register_template({
			name = "Test",
			builder = function()
				local task = get_test_cmd()
				task.components = { "default", "on_output_open" }
				return task
			end,
		})

		overseer.register_template({
			name = "Run",
			builder = function()
				local handle = io.popen("find " ..
					vim.g.build_dir .. " -maxdepth 1 -type f -executable 2>/dev/null")
				local result = handle:read("*a")
				handle:close()

				local targets = {}
				for t in result:gmatch("[^\r\n]+") do
					table.insert(targets, t)
				end

				local target = vim.fn.input("Run target: ", targets[1] or "")
				return {
					cmd = { target },
					components = { "default" },
				}
			end,
		})


		----------------------------------------------------------------------
		-- Key mappings
		----------------------------------------------------------------------
		vim.keymap.set("n", "<leader>ob", "<cmd>OverseerRun Build<CR>", { desc = "Build project" })
		vim.keymap.set("n", "<leader>oc", "<cmd>OverseerRun Configure<CR>", { desc = "Configure project" })
		vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun Run<CR>", { desc = "Run project" })
		vim.keymap.set("n", "<leader>ot", "<cmd>OverseerRun Test<CR>", { desc = "Run tests" })
		vim.keymap.set("n", "<leader>ox", "<cmd>OverseerRun Clean<CR>", { desc = "Clean build" })
		vim.keymap.set("n", "<leader>of", "<cmd>OverseerQuickAction open float<CR>",
			{ desc = "Open Floating Terminal" })

		-- Open vsplit terminal or fallback to normal split in cwd
		vim.keymap.set("n", "<leader>oo", function()
			local tasks = overseer.list_tasks()
			if #tasks > 0 then
				-- open Overseer vsplit for running tasks
				vim.cmd("OverseerQuickAction open vsplit")
			else
				vim.opt.shell = "/usr/bin/fish" -- adjust path if fish is elsewhere
				vim.opt.shellcmdflag = "-c"

				-- fallback: open normal split terminal in current cwd
				local cwd = vim.fn.getcwd()
				vim.cmd("vsplit | terminal ")
				vim.cmd("lcd " .. cwd)
			end
		end, { desc = "Open vsplit Terminal or fallback split in cwd" })

		vim.keymap.set("n", "<leader>ol", "<cmd>OverseerToggle<CR>", { desc = "Open running list" })
	end,
}
