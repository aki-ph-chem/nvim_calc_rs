require("utl")

local get_project_root_dir = function()
	-- get path to project root
	local plugin_root = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	return plugin_root
end

local build_rust = function(is_debug)
	--local project_root_dir = get_project_root_dir()
	local project_root_dir = "/home/aki/nvim_calc_rs"
	local path_to_bin = project_root_dir .. "/target/release/nvim_calc_rs"

	if is_debug then
		print("projet_root_dir: " .. project_root_dir)
		print("path_to_bin: " .. path_to_bin)
	end

	if not vim.loop.fs_stat(path_to_bin) then
		print("build rust binary ...")

		local build_cmd = "cargo build --release --manifest-path=" .. project_root_dir .. "Cargo.toml"
		print("build_cmd: " .. build_cmd)

		local result_build = vim.fn.systemlist(build_cmd)
		for _, line in ipairs(result_build) do
			print(line)
		end

		print("build: Ok")
	end
end

local build_rust_async = function(is_debug)
	local path_to_project = "/home/aki/nvim_calc_rs"
	local path_to_bin = "/home/aki/nvim_calc_rs/target/release/nvim_calc_rs"

	if not vim.loop.fs_stat(path_to_bin) then
		print("build rust binary ...")

		local build_cmd = { "cargo", "build", "--release", "--manifest-path=" .. path_to_project .. "/Cargo.toml" }
		if is_debug then
			for _, c in ipairs(build_cmd) do
				print(c)
			end
		end
		vim.fn.jobstart(build_cmd, {
			on_stdout = function(_, data)
				for _, line in ipairs(data) do
					if line ~= "" then
						print(line)
					end
				end
			end,
			on_stderr = function(_, data)
				for _, line in ipairs(data) do
					if line ~= "" then
						print("Error: " .. line)
					end
				end
			end,
			on_exit = function(_, code, _)
				if code == 0 then
					print("Build: Ok")
				else
					print("Build failed with exit code " .. code)
				end
			end,
			stderr_buffered = true,
			stdout_buffered = true,
		})
	end
end

local main = function()
	build_rust(true)
	--build_rust_async(false)
	local state_calc = {}
	state_calc.jobRpcId = 0
	state_calc.path = "/home/aki/nvim_calc_rs/target/release/nvim_calc_rs"
	state_calc.is_debug = false

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

	connect_to_bin(state_calc)
end

main()
