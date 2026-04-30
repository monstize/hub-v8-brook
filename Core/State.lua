--[[
	Brookhaven Hub v8 - State Manager
	Controla conexões, toggles e estado dos módulos
]]

local State = {}

-- Tabela de estado
local ModuleStates = {}
local ConnectionPool = {}
local TimerPool = {}

--[[
	Define o estado de um módulo
	@param moduleName: Nome do módulo
	@param enabled: boolean
]]
function State.SetModuleState(moduleName, enabled)
	ModuleStates[moduleName] = enabled
end

--[[
	Retorna o estado de um módulo
	@param moduleName: Nome do módulo
	@return boolean
]]
function State.GetModuleState(moduleName)
	return ModuleStates[moduleName] or false
end

--[[
	Toggla o estado de um módulo
	@param moduleName: Nome do módulo
	@return novo estado
]]
function State.ToggleModule(moduleName)
	local current = State.GetModuleState(moduleName)
	State.SetModuleState(moduleName, not current)
	return not current
end

--[[
	Adiciona uma conexão ao pool
	@param moduleName: Nome do módulo
	@param connection: RBXScriptConnection
]]
function State.AddConnection(moduleName, connection)
	if not ConnectionPool[moduleName] then
		ConnectionPool[moduleName] = {}
	end
	table.insert(ConnectionPool[moduleName], connection)
end

--[[
	Adiciona um timer ao pool
	@param moduleName: Nome do módulo
	@param thread: coroutine
]]
function State.AddTimer(moduleName, thread)
	if not TimerPool[moduleName] then
		TimerPool[moduleName] = {}
	end
	table.insert(TimerPool[moduleName], thread)
end

--[[
	Limpa todas as conexões e timers de um módulo
	@param moduleName: Nome do módulo
]]
function State.CleanupModule(moduleName)
	-- Desconectar conexões
	if ConnectionPool[moduleName] then
		for _, connection in ipairs(ConnectionPool[moduleName]) do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		ConnectionPool[moduleName] = nil
	end

	-- Parar timers
	if TimerPool[moduleName] then
		for _, thread in ipairs(TimerPool[moduleName]) do
			if thread then
				coroutine.close(thread)
			end
		end
		TimerPool[moduleName] = nil
	end

	-- Resetar estado
	ModuleStates[moduleName] = false
end

--[[
	Limpa todos os módulos
]]
function State.CleanupAll()
	for moduleName, _ in pairs(ModuleStates) do
		State.CleanupModule(moduleName)
	end
end

--[[
	Retorna informações de debug
	@return table
]]
function State.GetDebugInfo()
	local info = {}
	for moduleName, enabled in pairs(ModuleStates) do
		info[moduleName] = {
			Enabled = enabled,
			Connections = ConnectionPool[moduleName] and #ConnectionPool[moduleName] or 0,
			Timers = TimerPool[moduleName] and #TimerPool[moduleName] or 0,
		}
	end
	return info
end

return State