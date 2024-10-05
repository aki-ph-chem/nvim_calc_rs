require("utl")

local get_project_root_dir = function()
	-- get path to project root
	local plugin = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	local plugin_root = plugin:gsub("/plugin/?$", "")
	return plugin_root
end

local build_rust = function(is_debug)
	local project_root_dir = get_project_root_dir()
	local path_to_bin = project_root_dir .. "/target/release/nvim_calc_rs"

	if is_debug then
		print("projet_root_dir: " .. project_root_dir)
		print("path_to_bin: " .. path_to_bin)
	end

	if not vim.loop.fs_stat(path_to_bin) then
		print("build rust binary ...")

		local build_cmd = "cargo build --release --manifest-path=" .. project_root_dir .. "/Cargo.toml"
		if is_debug then
			print("build_cmd: " .. build_cmd)
		end

		local result_build = vim.fn.systemlist(build_cmd)
		for _, line in ipairs(result_build) do
			print(line)
		end

		print("build: Ok")
	end
end

local build_rust_async = function(config, state)
	local path_to_project = get_project_root_dir()
	local path_to_bin = path_to_project .. "/target/release/nvim_calc_rs"
	local job_id = 0

	if not vim.loop.fs_stat(path_to_bin) then
		if config.use_new_window then
			vim.api.nvim_command("vnew")
		end
		vim.api.nvim_buf_set_lines(0, -1, -1, false, { "   build rust binary..." })

		local build_cmd = "cargo build --release --manifest-path=" .. path_to_project .. "/Cargo.toml"
		if config.is_debug then
			print("build_cmd: " .. build_cmd)
		end

		job_id = vim.fn.jobstart(build_cmd, {
			on_stderr = function(_, data, _)
				if data then
					-- Add the ping output to the current buffer in real time
					vim.api.nvim_buf_set_lines(0, -1, -1, false, data)
				end
			end,
			on_exit = function(_, code, _)
				if code == 0 then
					vim.api.nvim_buf_set_lines(0, -1, -1, false, { "   Build: Ok" })
					connect_to_bin(state)
				else
					local error_message = string.format("   Build failed with exit code: %d", code)
					vim.api.nvim_buf_set_lines(0, -1, -1, false, { error_message })
				end
			end,
		})

		vim.cmd("setlocal buftype=nofile")
	else
		if config.is_debug then
			print("rust binary: Ok")
		end
		connect_to_bin(state)
	end

	return job_id
end

local main = function()
	local state_calc = {
		jobRpcId = 0,
		path = get_project_root_dir() .. "/target/release/nvim_calc_rs",
		is_debug = false,
	}
	local config_build = {
		is_debug = false,
		use_new_window = false,
	}
	build_rust_async(config_build, state_calc)

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
