--[[
	Brookhaven Hub v8 - State Management
	Gerencia toggle de módulos, conexões e cleanup
]]

local State = {}

-- Armazena estado de cada módulo
local ModuleStates = {}

-- Armazena conexões de cada módulo
local ModuleConnections = {}

-- Armazena objetos criados por cada módulo
local ModuleObjects = {}

--[[
	Habilita um módulo
	@param moduleName: Nome do módulo
]]
function State.EnableModule(moduleName)
	if not ModuleStates[moduleName] then
		ModuleStates[moduleName] = {}
	end
	ModuleStates[moduleName].Enabled = true
end

--[[
	Desabilita um módulo
	@param moduleName: Nome do módulo
]]
function State.DisableModule(moduleName)
	if ModuleStates[moduleName] then
		ModuleStates[moduleName].Enabled = false
	end
end

--[[
	Verifica se um módulo está habilitado
	@param moduleName: Nome do módulo
	@return boolean
]]
function State.IsModuleEnabled(moduleName)
	if not ModuleStates[moduleName] then
		return false
	end
	return ModuleStates[moduleName].Enabled == true
end

--[[
	Adiciona uma conexão a um módulo
	@param moduleName: Nome do módulo
	@param connection: RBXConnection ou função que será desconectada
]]
function State.AddConnection(moduleName, connection)
	if not ModuleConnections[moduleName] then
		ModuleConnections[moduleName] = {}
	end
	table.insert(ModuleConnections[moduleName], connection)
end

--[[
	Adiciona um objeto a um módulo (para cleanup depois)
	@param moduleName: Nome do módulo
	@param object: Objeto (Part, GUI, etc)
]]
function State.AddObject(moduleName, object)
	if not ModuleObjects[moduleName] then
		ModuleObjects[moduleName] = {}
	end
	table.insert(ModuleObjects[moduleName], object)
end

--[[
	Desconecta todas as conexões de um módulo
	@param moduleName: Nome do módulo
]]
function State.CleanupModule(moduleName)
	if ModuleConnections[moduleName] then
		for _, connection in ipairs(ModuleConnections[moduleName]) do
			if connection.Disconnect then
				pcall(function() connection:Disconnect() end)
			elseif typeof(connection) == "function" then
				pcall(connection)
			end
		end
		ModuleConnections[moduleName] = {}
	end
	
	if ModuleObjects[moduleName] then
		for _, object in ipairs(ModuleObjects[moduleName]) do
			if object and object.Parent then
				pcall(function() object:Destroy() end)
			end
		end
		ModuleObjects[moduleName] = {}
	end
	
	ModuleStates[moduleName] = nil
end

--[[
	Retorna todas as conexões de um módulo
	@param moduleName: Nome do módulo
	@return table
]]
function State.GetConnections(moduleName)
	return ModuleConnections[moduleName] or {}
end

--[[
	Retorna todos os objetos de um módulo
	@param moduleName: Nome do módulo
	@return table
]]
function State.GetObjects(moduleName)
	return ModuleObjects[moduleName] or {}
end

--[[
	Limpa tudo (ao desabilitar o hub)
]]
function State.CleanupAll()
	for moduleName, _ in pairs(ModuleStates) do
		State.CleanupModule(moduleName)
	end
end

return State