--[[
	Brookhaven Hub v8 - Utilities
	Funções úteis compartilhadas entre módulos
]]

local Utils = {}

local Services = require(script.Parent:FindFirstChild("Services"))

--[[
	Verifica se um objeto é válido
	@param obj: Objeto a verificar
	@return boolean
]]
function Utils.IsValid(obj)
	if not obj then return false end
	return pcall(function() return obj.Parent end)
end

--[[
	Retorna a distância entre dois pontos
	@param pos1: Vector3
	@param pos2: Vector3
	@return number
]]
function Utils.Distance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

--[[
	Retorna a distância entre o player e outro ponto
	@param pos: Vector3
	@return number
]]
function Utils.DistanceToLocal(pos)
	local Root = Services.LocalRoot()
	if not Root then return math.huge end
	return Utils.Distance(Root.Position, pos)
end

--[[
	Cria um Tween
	@param object: Objeto a animar
	@param duration: Duração em segundos
	@param properties: Propriedades a animar
	return Tween
]]
function Utils.CreateTween(object, duration, properties)
	local TweenService = Services.TweenService()
	local TweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	return TweenService:Create(object, TweenInfo, properties)
end

--[[
	Inicia uma tween
	@param object: Objeto a animar
	@param duration: Duração em segundos
	@param properties: Propriedades a animar
	return Tween
]]
function Utils.Tween(object, duration, properties)
	local tween = Utils.CreateTween(object, duration, properties)
	tween:Play()
	return tween
end

--[[
	Cria um TextLabel com estilo
	@param parent: Parent do label
	@param text: Texto inicial
	@param config: Tabela com configurações (Size, Position, etc)
	return TextLabel
]]
function Utils.CreateTextLabel(parent, text, config)
	local label = Instance.new("TextLabel")
	label.Parent = parent
	label.Text = text
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	
	if config then
		for prop, value in pairs(config) do
			if label:FindFirstChild(prop) or pcall(function() label[prop] = value end) then
				pcall(function() label[prop] = value end)
			end
		end
	end
	
	return label
end

--[[
	Cria um Frame com estilo
	@param parent: Parent do frame
	@param config: Tabela com configurações
	return Frame
]]
function Utils.CreateFrame(parent, config)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	
	if config then
		for prop, value in pairs(config) do
			pcall(function() frame[prop] = value end)
		end
	end
	
	return frame
end

--[[
	Cria um TextButton com estilo
	@param parent: Parent do botão
	@param text: Texto do botão
	@param config: Tabela com configurações
	return TextButton
]]
function Utils.CreateButton(parent, text, config)
	local button = Instance.new("TextButton")
	button.Parent = parent
	button.Text = text
	button.TextScaled = true
	button.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	if config then
		for prop, value in pairs(config) do
			pcall(function() button[prop] = value end)
		end
	end
	
	return button
end

--[[
	Adiciona corner radius a um GUI object
	@param object: Objeto GUI
	@param radius: Tamanho do radius
]]
function Utils.AddCornerRadius(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 8)
	corner.Parent = object
end

--[[
	Adiciona padding a um GUI object
	@param object: Objeto GUI
	@param padding: Tamanho do padding
]]
function Utils.AddPadding(object, padding)
	local pad = Instance.new("UIPadding")
	pad.Parent = object
	pad.PaddingBottom = padding or UDim.new(0, 8)
	pad.PaddingLeft = padding or UDim.new(0, 8)
	pad.PaddingRight = padding or UDim.new(0, 8)
	pad.PaddingTop = padding or UDim.new(0, 8)
end

--[[
	Formateia um número para distância legível
	@param distance: Número
	return string
]]
function Utils.FormatDistance(distance)
	if distance > 1000 then
		return string.format("%.1fk", distance / 1000)
	else
		return string.format("%.0f", distance)
	end
end

--[[
	Retorna uma cor baseada na distância
	@param distance: Número
	@param maxDistance: Distância máxima
	return Color3
]]
function Utils.ColorByDistance(distance, maxDistance)
	local ratio = math.min(distance / maxDistance, 1)
	
	if ratio < 0.5 then
		-- Verde para próximo
		return Color3.fromRGB(0, 255, 0)
	elseif ratio < 0.75 then
		-- Amarelo para médio
		return Color3.fromRGB(255, 255, 0)
	else
		-- Vermelho para longe
		return Color3.fromRGB(255, 0, 0)
	end
end

--[[
	Aguarda condição ser true
	@param condition: função que retorna boolean
	@param timeout: Timeout em segundos (opcional)
]]
function Utils.WaitFor(condition, timeout)
	timeout = timeout or 10
	local startTime = tick()
	
	while not condition() do
		task.wait(0.1)
		if tick() - startTime > timeout then
			return false
		end
	end
	
	return true
end

--[[
	Retorna FPS atual
	@return number
]]
function Utils.GetFPS()
	local RunService = Services.RunService()
	return math.round(1 / RunService.Heartbeat:Wait())
end

return Utils