require("utl")
require("build")

local main = function()
	local state_calc = {
		jobRpcId = 0,
		path = get_project_root_dir() .. "/target/release/nvim_calc_rs",
		is_debug = false,
	}
	local use_hot_reload = true

	build_rust(false, state_calc)
	if use_hot_reload then
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = get_files(get_project_root_dir(), { "%.lua", "%.rs", "Cargo.toml" }),
			callback = function(args)
				if args.file:match("%.lua") then
					print("*.lua is updated")
					-- ToDo: reload thid plugin
				end
				build_rust(false, state_calc)
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
