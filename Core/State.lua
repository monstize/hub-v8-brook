--[[
	Brookhaven Hub v8 - State Manager
	Gerencia todas as conexões, toggles e estados
]]

local State = {}
local Connections = {}
local Toggles = {}

--[[
	Cria um novo toggle com estado
	@param name: Nome único do toggle
	@param initialState: Estado inicial (default: false)
	@return table com métodos Get, Set, Toggle
]]
function State.CreateToggle(name, initialState)
	if Toggles[name] then
		return Toggles[name]
	end

	Toggles[name] = {
		_value = initialState or false,
		_callbacks = {},
	}

	local toggle = Toggles[name]

	--[[Retorna o valor atual]]
	function toggle:Get()
		return self._value
	end

	--[[Define o valor e dispara callbacks]]
	function toggle:Set(value)
		if self._value == value then return end
		self._value = value
		for _, callback in ipairs(self._callbacks) do
			pcall(callback, value)
		end
	end

	--[[Inverte o valor]]
	function toggle:Toggle()
		self:Set(not self._value)
	end

	--[[Registra callback quando estado muda]]
	function toggle:OnChanged(callback)
		table.insert(self._callbacks, callback)
	end

	return toggle
end

--[[
	Retorna um toggle existente
	@param name: Nome do toggle
	@return table ou nil
]]
function State.GetToggle(name)
	return Toggles[name]
end

--[[
	Conecta uma função a um evento com gerenciamento automático
	@param event: RBXSignal (ex: RunService.Heartbeat)
	@param callback: Função a executar
	@param id: ID único da conexão (para limpeza)
	@return Connection
]]
function State.Connect(event, callback, id)
	if not id then
		id = tostring(event) .. "_" .. math.random(1000, 9999)
	end

	local connection = event:Connect(callback)
	Connections[id] = connection

	return connection
end

--[[
	Desconecta uma conexão específica
	@param id: ID da conexão
]]
function State.Disconnect(id)
	if Connections[id] then
		Connections[id]:Disconnect()
		Connections[id] = nil
	end
end

--[[
	Desconecta todas as conexões
	Útil para cleanup ao desativar módulos
]]
function State.DisconnectAll()
	for id, connection in pairs(Connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	Connections = {}
end

--[[
	Desconecta conexões por padrão de ID
	@param pattern: Padrão de nome (ex: "fly_" desconecta todas que começam com fly_)
]]
function State.DisconnectByPattern(pattern)
	for id, connection in pairs(Connections) do
		if id:match(pattern) and connection and connection.Connected then
			connection:Disconnect()
			Connections[id] = nil
		end
	end
end

--[[
	Retorna todas as conexões ativas (para debug)
	@return table
]]
function State.GetConnections()
	return Connections
end

--[[
	Limpa todos os estados
]]
function State.Clear()
	State.DisconnectAll()
	Toggles = {}
	Connections = {}
end

return State
