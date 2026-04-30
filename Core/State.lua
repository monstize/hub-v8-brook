--[[
	Brookhaven Hub v8 - State Management
	Controla conexões e estado dos módulos
]]

local State = {}

local Services = require(script.Parent:FindFirstChild("Services"))
local Utils = require(script.Parent:FindFirstChild("Utils"))

-- Armazenar conexões ativas por módulo
local ModuleConnections = {}
local ModuleStates = {}
local ActiveTimers = {}

--[[
	Adiciona uma conexão controlada
	@param moduleName: Nome do módulo
	@param event: RBXScriptSignal
	@param callback: função callback
]]
function State.Connect(moduleName, event, callback)
	if not ModuleConnections[moduleName] then
		ModuleConnections[moduleName] = {}
	end
	
	local connection = event:Connect(callback)
	table.insert(ModuleConnections[moduleName], connection)
	
	return connection
end

--[[
	Cria um timer que pode ser cancelado
	@param moduleName: Nome do módulo
	@param interval: Intervalo em segundos
	@param callback: função callback
	@return function para cancelar
]]
function State.Timer(moduleName, interval, callback)
	if not ActiveTimers[moduleName] then
		ActiveTimers[moduleName] = {}
	end
	
	local timerActive = true
	local timerId = #ActiveTimers[moduleName] + 1
	
	task.spawn(function()
		while timerActive do
			task.wait(interval)
			if timerActive and callback then
				pcall(callback)
			end
		end
	end)
	
	ActiveTimers[moduleName][timerId] = true
	
	return function()
		timerActive = false
		ActiveTimers[moduleName][timerId] = nil
	end
end

--[[
	Define o estado de um módulo
	@param moduleName: Nome do módulo
	@param state: boolean ou table
]]
function State.SetModuleState(moduleName, state)
	ModuleStates[moduleName] = state
end

--[[
	Retorna o estado de um módulo
	@param moduleName: Nome do módulo
	@return state
]]
function State.GetModuleState(moduleName)
	return ModuleStates[moduleName]
end

--[[
	Limpa todas as conexões de um módulo
	@param moduleName: Nome do módulo
]]
function State.CleanupModule(moduleName)
	if ModuleConnections[moduleName] then
		for _, connection in ipairs(ModuleConnections[moduleName]) do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		ModuleConnections[moduleName] = nil
	end
	
	if ActiveTimers[moduleName] then
		ActiveTimers[moduleName] = nil
	end
	
	ModuleStates[moduleName] = nil
end

--[[
	Limpa tudo (desliga o hub)
]]
function State.CleanupAll()
	for moduleName, _ in pairs(ModuleConnections) do
		State.CleanupModule(moduleName)
	end
end

--[[
	Retorna todas as conexões ativas
	@return table
]]
function State.GetActiveConnections()
	return ModuleConnections
end

return State