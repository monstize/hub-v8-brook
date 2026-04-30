--[[
	Brookhaven Hub v8 - Utilities
	Funções auxiliares para todo o sistema
]]

local Utils = {}
local Services = require(script.Parent:FindFirstChild("Services"))

--[[
	Cria um delay com callback
	@param duration: Tempo em segundos
	@param callback: Função a executar
]]
function Utils.Delay(duration, callback)
	task.delay(duration, callback)
end

--[[
	Cria um spawn com segurança
	@param func: Função a executar
]]
function Utils.Spawn(func)
	task.spawn(func)
end

--[[
	Cria um tween
	@param object: Objeto a animar
	@param tweenInfo: TweenInfo
	@param goals: Tabela de objetivos
]]
function Utils.CreateTween(object, tweenInfo, goals)
	return Services.TweenService():Create(object, tweenInfo, goals)
end

--[[
	Calcula distância entre dois pontos
	@param pos1: Vector3
	@param pos2: Vector3
	@return number
]]
function Utils.Distance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

--[[
	Calcula distância até um player
	@param player: Player
	@return number
]]
function Utils.DistanceToPlayer(player)
	local localRoot = Services.LocalRoot()
	if not localRoot or not player.Character then
		return math.huge
	end
	local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then
		return math.huge
	end
	return Utils.Distance(localRoot.Position, playerRoot.Position)
end

--[[
	Retorna uma cor baseada em distância
	@param distance: Número
	@param maxDistance: Número
	@return Color3
]]
function Utils.GetDistanceColor(distance, maxDistance)
	if distance < maxDistance / 3 then
		return Color3.fromRGB(255, 0, 0) -- Vermelho (perto)
	elseif distance < maxDistance * 2 / 3 then
		return Color3.fromRGB(255, 255, 0) -- Amarelo (médio)
	else
		return Color3.fromRGB(0, 255, 0) -- Verde (longe)
	end
end

--[[
	Lerp entre dois valores
	@param a: Número inicial
	@param b: Número final
	@param t: Tempo (0-1)
	@return Número
]]
function Utils.Lerp(a, b, t)
	return a + (b - a) * t
end

--[[
	Clamp um valor entre min e max
	@param value: Valor
	@param min: Mínimo
	@param max: Máximo
	@return Número
]]
function Utils.Clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

--[[
	Cria um label de GUI
	@param parent: Parent container
	@param text: Texto inicial
	@param size: UDim2
	@param position: UDim2
	@return TextLabel
]]
function Utils.CreateLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.TextSize = 14
	label.Size = size
	label.Position = position
	label.Parent = parent
	return label
end

--[[
	Cria um botão de GUI
	@param parent: Parent container
	@param text: Texto do botão
	@param size: UDim2
	@param position: UDim2
	@param callback: Função ao clique
	@return TextButton
]]
function Utils.CreateButton(parent, text, size, position, callback)
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
	button.BorderSizePixel = 0
	button.Size = size
	button.Position = position
	button.Parent = parent
	
	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	
	return button
end

--[[
	Cria um frame container
	@param parent: Parent container
	@param size: UDim2
	@param position: UDim2
	@param bgColor: Color3
	@return Frame
]]
function Utils.CreateFrame(parent, size, position, bgColor)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	return frame
end

return Utils