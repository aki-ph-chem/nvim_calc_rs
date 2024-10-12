local M = {}

local init_rpc = function(state)
	if state.jobRpcId == 0 then
		state.jobRpcId = vim.fn.jobstart(state.path, { rpc = true })
	end
end

M.connect_to_bin = function(state)
	init_rpc(state)
	local id = state.jobRpcId

	if 0 == id or -1 == id then
		print("canot start rpc process")
		return
	end

	if state.is_debug then
		print("connection of RPC: OK")
	end
end

return M
