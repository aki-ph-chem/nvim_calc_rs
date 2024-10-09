require("utl")

get_project_root_dir = function()
	-- get path to project root
	local plugin = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	local plugin_root = plugin:gsub("/lua/?$", "")
	return plugin_root
end

local is_diff_git_rust = function()
	local diff = vim.fn.systemlist("git diff --name-only", get_project_root_dir())

	for _, file_name in ipairs(diff) do
		if file_name:match("Cargo.toml") or file_name:match(".*rs$") then
			return true
		end
	end
	return false
end

local get_timestamp = function(path_to_file)
	local stat = vim.loop.fs_stat(path_to_file)
	return os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
end

local function dfs(path, postfix_list, file_list)
	local scandir = vim.loop.fs_scandir(path)

	if scandir then
		while true do
			local name, typ = vim.loop.fs_scandir_next(scandir)
			if not name then
				break
			end

			local fullpath = path .. "/" .. name
			for _, p in pairs(postfix_list) do
				if fullpath:match(p) then
					table.insert(file_list, fullpath)
				end
			end

			if typ == "directory" then
				dfs(fullpath, postfix_list, file_list)
			end
		end
	else
		print("Failed to open directory: " .. path)
	end
end

get_files = function(path, postfix_list)
	local file_list = {}
	dfs(path, postfix_list, file_list)

	return file_list
end

local is_update_src = function(path, postfix_list, path_to_bin)
	local files = get_files(path, postfix_list)
	local timestamp_binnary = get_timestamp(path_to_bin)

	for _, f in pairs(files) do
		if get_timestamp(f) > timestamp_binnary then
			return true
		end
	end

	return false
end

-- state_plugin = {
--      is_reading = false,
--      module_name = "module_name"
--}
reload_plugin = function(state_plugin)
	if state_plugin.is_reading then
		return
	end

	print("reloading is passed")
	state_plugin.is_reading = true
	package.loaded[state_plugin.module_name] = nil
	require(state_plugin.module_name)
end

build_rust = function(is_debug, state)
	local project_root_dir = get_project_root_dir()
	local path_to_bin = project_root_dir .. "/target/release/nvim_calc_rs"

	if is_debug then
		print("projet_root_dir: " .. project_root_dir)
		print("path_to_bin: " .. path_to_bin)
	end

	local postfix_list = { "%.rs", "Cargo.toml" }
	if not vim.loop.fs_stat(path_to_bin) or is_update_src(project_root_dir, postfix_list, path_to_bin) then
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
