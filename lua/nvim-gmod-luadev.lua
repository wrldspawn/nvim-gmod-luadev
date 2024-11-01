local uv = vim.uv
local api = vim.api

local M = {
	---@type {port: integer}
	config = {
		port = 27099,
	},
}

---@param cmd "self"|"sv"|"sh"|"cl"|"client"|"ent"|"wep"|"chatTextChanged"|"finishChat"|"requestPlayers"
---@param client? string
local function send(cmd, client)
	client = client or ""

	local filename = api.nvim_buf_get_name(0)
	if not filename or filename == "" then
		filename = "Untitled"
	else
		filename = vim.fs.basename(filename)
	end
	local content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")

	local sock = uv.new_tcp()
	if not sock then
		vim.notify("Failed to create socket for LuaDev", vim.log.levels.ERROR, { title = "LuaDev" })
		return
	end

	sock:connect("127.0.0.1", M.config.port, function(err)
		if err then
			vim.notify("Failed to send to LuaDev: " .. err, vim.log.levels.ERROR, { title = "LuaDev" })
			return
		end

		sock:write(table.concat({
			cmd,
			filename,
			client,
			content
		}, "\n"))

		sock:shutdown()
		sock:close()
	end)
end

local function create_send(cmd, client)
	return function()
		uv.new_async(vim.schedule_wrap(function()
			send(cmd, client)
		end)):send()
	end
end

local function player_select(data)
	local players = vim.split(data, "\n")

	vim.ui.select(players, {
		prompt = "Player to run on:"
	}, function(choice)
		if choice then create_send("client", choice)() end
	end)
end

local function request_players()
	local sock = uv.new_tcp()
	if not sock then
		vim.notify("Failed to create socket for LuaDev", vim.log.levels.ERROR, { title = "LuaDev" })
		return
	end

	sock:connect("127.0.0.1", M.config.port, function(err)
		if err then
			vim.notify("Failed to send to LuaDev: " .. err, vim.log.levels.ERROR, { title = "LuaDev" })
			return
		end

		sock:write("requestPlayers\n")

		sock:read_start(function(err, data)
			if err then
				vim.notify("Failed to request players: " .. err, vim.log.levels.ERROR, { title = "LuaDev" })
			elseif data then
				uv.new_async(vim.schedule_wrap(function()
					player_select(data)
				end)):send()
			else
				sock:shutdown()
				sock:close()
			end
		end)
	end)
end

function M.setup(opts)
	opts = opts or {}

	if opts.port ~= nil then
		M.config.port = opts.port
	end

	api.nvim_create_user_command("LuadevSelf", create_send("self"), { force = true, desc = "LuaDev: Run on self" })
	api.nvim_create_user_command("LuadevSv", create_send("sv"), { force = true, desc = "LuaDev: Run on server" })
	api.nvim_create_user_command("LuadevCl", create_send("cl"), { force = true, desc = "LuaDev: Run on clients" })
	api.nvim_create_user_command("LuadevSh", create_send("sh"), { force = true, desc = "LuaDev: Run on shared" })
	api.nvim_create_user_command(
		"LuadevClient",
		function()
			uv.new_async(vim.schedule_wrap(request_players)):send()
		end,
		{ force = true, desc = "LuaDev: Run on specific player" }
	)
end

return M
