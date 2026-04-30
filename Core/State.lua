--[[
	Brookhaven Hub v8 - State Management
	Controla toggles, conexões e estados dos módulos
]]

local State = {}

-- Tabela de estados dos módulos
local ModuleStates = {}

-- Tabela de conexões ativas
local Connections = {}

--[[
	Alterna o estado de um módulo
	@param moduleName: Nome do módulo
	@param enabled: boolean (true para ativar, false para desativar)
]]
function State.SetModuleState(moduleName, enabled)
	if ModuleStates[moduleName] == enabled then
		return -- Já está neste estado
	end
	
	ModuleStates[moduleName] = enabled
	print("[State] " .. moduleName .. " -> " .. (enabled and "ON" or "OFF"))
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
	Registra uma conexão para controle
	@param moduleName: Nome do módulo
	@param connection: RBXScriptConnection
]]
function State.RegisterConnection(moduleName, connection)
	if not Connections[moduleName] then
		Connections[moduleName] = {}
	end
	
	table.insert(Connections[moduleName], connection)
end

--[[
	Desconecta todas as conexões de um módulo
	@param moduleName: Nome do módulo
]]
function State.CleanupModule(moduleName)
	if not Connections[moduleName] then
		return
	end
	
	for _, connection in ipairs(Connections[moduleName]) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	
	Connections[moduleName] = {}
	ModuleStates[moduleName] = false
	print("[State] Cleaned up: " .. moduleName)
end

--[[
	Retorna todas as conexões de um módulo
	@param moduleName: Nome do módulo
	@return table
]]
function State.GetConnections(moduleName)
	return Connections[moduleName] or {}
end

--[[
	Limpa todos os módulos
]]
function State.CleanupAll()
	for moduleName, _ in pairs(Connections) do
		State.CleanupModule(moduleName)
	end
	print("[State] All modules cleaned up")
end

return State