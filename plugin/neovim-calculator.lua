local build = require("nvim_calculator.build")

local main = function()
	local state_calc = {
		jobRpcId = 0,
		path = build.get_project_root_dir() .. "/target/release/nvim_calc_rs",
		is_debug = false,
	}
	local use_hot_reload = true
	local state_plugin = {
		is_reading = false,
		module_list = { "plugin.neovim-calculator", "nvim_calculator.build", "nvim_calculator.utl" },
	}

	build.build_rust(false, state_calc)
	if use_hot_reload then
		vim.api.nvim_clear_autocmds({
			event = "BufWritePost",
			pattern = build.get_files(build.get_project_root_dir(), { "%.lua", "%.rs", "Cargo.toml" }),
		})

		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = build.get_files(build.get_project_root_dir(), { "%.lua", "%.rs", "Cargo.toml" }),
			callback = function()
				build.reload_plugin_list(state_plugin)
			end,
		})
	end

	vim.api.nvim_create_user_command("AddL", function(ops)
		local args = ops.fargs
		if #args < 2 then
			return
		end
		local p = tonumber(args[1])
		local q = tonumber(args[2])

		vim.rpcnotify(state_calc.jobRpcId, "add", p, q)
	end, { nargs = "*" })

	vim.api.nvim_create_user_command("MulL", function(ops)
		local args = ops.fargs
		if #args < 2 then
			return
		end
		local p = tonumber(args[1])
		local q = tonumber(args[2])

		vim.rpcnotify(state_calc.jobRpcId, "multiply", p, q)
	end, { nargs = "*" })

	vim.api.nvim_create_user_command("SumAll", function(ops)
		local args = ops.fargs
		if #args < 1 then
			return
		end
		local args_num = {}
		for _, v in pairs(args) do
			table.insert(args_num, tonumber(v))
		end

		vim.rpcnotify(state_calc.jobRpcId, "sum_all", args_num)
	end, { nargs = "*" })

	vim.api.nvim_create_user_command("Average", function(ops)
		local args = ops.fargs
		if #args < 1 then
			return
		end
		local args_num = {}
		for _, v in pairs(args) do
			table.insert(args_num, tonumber(v))
		end

		vim.rpcnotify(state_calc.jobRpcId, "average", args_num)
	end, { nargs = "*" })

	vim.api.nvim_create_user_command("MulAll", function(ops)
		local args = ops.fargs
		if #args < 1 then
			return
		end
		local args_num = {}
		for _, v in pairs(args) do
			table.insert(args_num, tonumber(v))
		end

		vim.rpcnotify(state_calc.jobRpcId, "mul_all", args_num)
	end, { nargs = "*" })
end

main()
