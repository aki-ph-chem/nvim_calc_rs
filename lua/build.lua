get_project_root_dir = function()
	-- get path to project root
	local plugin = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	local plugin_root = plugin:gsub("/lua/?$", "")
	return plugin_root
end

build_rust = function(is_debug, state)
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

	connect_to_bin(state)
end

build_rust_async = function(config, state)
	local path_to_project = get_project_root_dir()
	local path_to_bin = path_to_project .. "/target/release/nvim_calc_rs"
	local job_id = 0

	if not vim.loop.fs_stat(path_to_bin) then
		local build_cmd = "cargo build --release --manifest-path=" .. path_to_project .. "/Cargo.toml"
		if config.is_debug then
			print("build_cmd: " .. build_cmd)
		end

		-- window size and position
		local width = 50
		local height = 15
		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		-- buffer for floating window
		local buf = vim.api.nvim_create_buf(false, true)

		-- options for floating window
		local opts = {
			style = "minimal",
			relative = "editor",
			width = width,
			height = height,
			col = col,
			row = row,
			border = "rounded",
		}

		-- generate floating window
		vim.api.nvim_open_win(buf, true, opts)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "   build rust binary ..." })

		job_id = vim.fn.jobstart(build_cmd, {
			on_stderr = function(_, data, _)
				if data then
					-- Get the current number of lines in the buffer
					local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

					-- Combine current lines with new data
					local new_lines = vim.list_extend(current_lines, data)

					-- Set the updated lines back to the buffer
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
				end
			end,

			on_exit = function(_, code, _)
				if code == 0 then
					connect_to_bin(state)
				else
					local error_message = string.format("   Build failed with exit code: %d", code)
					print(error_message)
				end
			end,
		})
	else
		if config.is_debug then
			print("rust binary: Ok")
		end
		connect_to_bin(state)
	end

	return job_id
end
