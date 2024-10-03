initRpc = function(state)
	if state.jobRpcId == 0 then
		state.jobRpcId = vim.fn.jobstart(state.path, { rpc = true })
	end
end

connect_to_bin = function(state)
	initRpc(state)
	local id = state.jobRpcId

	if 0 == id or -1 == id then
		print("canot start rpc process")
		return
	end

	if state.is_debug then
		print("connection of RPC: OK")
	end
end
