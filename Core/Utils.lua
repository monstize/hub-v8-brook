--[[
	Brookhaven Hub v8 - Utility Functions
	Funções auxiliares para todo o hub
]]

local Utils = {}

local Services = require(script.Parent:FindFirstChild("Services"))

--[[
	Interpolação linear entre dois valores
	@param a: valor inicial
	@param b: valor final
	@param t: progresso (0-1)
	@return valor interpolado
]]
function Utils.Lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

--[[
	Calcula distância entre dois pontos 3D
	@param pos1: Vector3
	@param pos2: Vector3
	@return number
]]
function Utils.Distance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

--[[
	Cria uma cor baseada em distância (verde -> amarelo -> vermelho)
	@param distance: número da distância
	@param maxDistance: distância máxima
	@return Color3
]]
function Utils.GetColorByDistance(distance, maxDistance)
	local ratio = math.min(distance / maxDistance, 1)
	if ratio < 0.5 then
		-- Verde para Amarelo
		local r = ratio * 2
		return Color3.fromRGB(r * 255, 255, 0)
	else
		-- Amarelo para Vermelho
		local b = (1 - ratio) * 2
		return Color3.fromRGB(255, b * 255, 0)
	end
end

--[[
	Verifica se um ponto está dentro de um raio
	@param point: Vector3
	@param center: Vector3
	@param radius: number
	@return boolean
]]
function Utils.IsInRadius(point, center, radius)
	return Utils.Distance(point, center) <= radius
end

--[[
	Gera um UUID simples
	@return string
]]
function Utils.UUID()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

--[[
	Delay com suporte a cancelamento
	@param duration: tempo em segundos
	@param callback: função a executar
	@return função para cancelar
]]
function Utils.DelayWithCancel(duration, callback)
	local cancelled = false
	local thread = task.spawn(function()
		local elapsed = 0
		while elapsed < duration and not cancelled do
			elapsed = elapsed + task.wait(0.01)
		end
		if not cancelled and callback then
			callback()
		end
	end)
	
	return function()
		cancelled = true
	end
end

--[[
	Retorna informações do player
	@param player: Player ou nil para player local
	@return table
]]
function Utils.GetPlayerInfo(player)
	player = player or Services.LocalPlayer()
	if not player then return nil end
	
	return {
		Name = player.Name,
		Id = player.UserId,
		Character = player.Character,
		Humanoid = player.Character and player.Character:FindFirstChild("Humanoid"),
		Root = player.Character and player.Character:FindFirstChild("HumanoidRootPart"),
	}
end

--[[
	Retorna todos os players exceto o local
	@return table
]]
function Utils.GetOtherPlayers()
	local players = {}
	local localPlayer = Services.LocalPlayer()
	
	for _, player in ipairs(Services.Players():GetPlayers()) do
		if player ~= localPlayer and player.Character then
			table.insert(players, player)
		end
	end
	
	return players
end

--[[
	Cria um objeto Billboard GUI
	@param parent: Instance
	@param text: string
	@param size: UDim2
	@param color: Color3
	@return BillboardGui
]]
function Utils.CreateBillboard(parent, text, size, color)
	local billboard = Instance.new("BillboardGui")
	billboard.Parent = parent
	billboard.Size = size or UDim2.new(5, 0, 2, 0)
	billboard.MaxDistance = 500
	billboard.Adornee = parent
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = billboard
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.3
	textLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Text = text
	
	return billboard
end

--[[
	Anima um valor usando Tween
	@param object: objeto com propriedade
	@param property: nome da propriedade
	@param targetValue: valor alvo
	@param duration: duração em segundos
	@return TweenObject
]]
function Utils.TweenValue(object, property, targetValue, duration)
	local tweenInfo = TweenInfo.new(
		number(duration),
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	
	local goals = {}
	goals[property] = targetValue
	
	local tween = Services.TweenService():Create(object, tweenInfo, goals)
	tween:Play()
	
	return tween
end

--[[
	Calcula FPS atual
	@return number
]]
local lastTime = tick()
local frameCount = 0
local fps = 0

function Utils.GetFPS()
	frameCount = frameCount + 1
	local currentTime = tick()
	if currentTime - lastTime >= 1 then
		fps = frameCount
		frameCount = 0
		lastTime = currentTime
	end
	return fps
end

return Utils