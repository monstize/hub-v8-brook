--[[
	Brookhaven Hub v8 - Player ESP Module
	Mostra nome e distância de todos os players
]]

local PlayerESP = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Utils = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local ESPState = {
	Enabled = false,
	ESPLabels = {},
}

--[[
	Cria um label de ESP para um player
	@param player: Player
]]
local function CreateESPLabel(player)
	if not player.Character then return end
	
	local camera = Services.Camera()
	if not camera then return end
	
	local screenGui = Instance.new("BillboardGui")
	screenGui.Name = "ESPLABEL_" .. player.Name
	screenGui.ReplicatedStorage = false
	screenGui.MaxDistance = Config.PlayerESP.MaxDistance
	screenGui.Size = UDim2.new(4, 0, 2, 0)
	screenGui.StudsOffset = Vector3.new(0, 3, 0)
	
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundColor3 = Config.PlayerESP.BackgroundColor
	textLabel.BackgroundTransparency = 0.3
	textLabel.TextColor3 = Config.PlayerESP.TextColor
	textLabel.TextSize = Config.PlayerESP.TextSize
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Parent = screenGui
	
	screenGui.Adornee = player.Character:FindFirstChild("Head")
	screenGui.Parent = Services.CoreGui()
	
	ESPState.ESPLabels[player.Name] = screenGui
	State.AddObject("PlayerESP", screenGui)
	
	return screenGui
end

--[[
	Atualiza o conteúdo do label de ESP
	@param player: Player
	@param label: BillboardGui
]]
local function UpdateESPLabel(player, label)
	if not label or not label.Parent or not player.Character then
		if label and label.Parent then
			label:Destroy()
		end
		ESPState.ESPLabels[player.Name] = nil
		return
	end
	
	local distance = Utils.DistanceToPlayer(player)
	local color = Utils.GetDistanceColor(distance, Config.PlayerESP.MaxDistance)
	
	local text = string.format("%s\n%.1f m", player.Name, distance)
	label.TextLabel.Text = text
	label.TextLabel.TextColor3 = color
end

--[[
	Inicia o Player ESP
]]
function PlayerESP.Enable()
	if ESPState.Enabled then return end
	
	local Players = Services.Players()
	if not Players then
		warn("Players service not found")
		return false
	end
	
	ESPState.Enabled = true
	State.EnableModule("PlayerESP")
	
	-- Cria labels para players existentes
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Services.LocalPlayer() then
			CreateESPLabel(player)
		end
	end
	
	-- Detecta novos players
	local playerAdded = Players.PlayerAdded:Connect(function(player)
		if ESPState.Enabled then
			task.wait(0.1)
			CreateESPLabel(player)
		end
	end)
	
	State.AddConnection("PlayerESP", playerAdded)
	
	-- Loop de atualização
	local updateConnection = Services.RunService().Heartbeat:Connect(function()
		if not ESPState.Enabled then
			updateConnection:Disconnect()
			return
		end
		
		local now = tick()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= Services.LocalPlayer() then
				local label = ESPState.ESPLabels[player.Name]
				if not label then
					CreateESPLabel(player)
					label = ESPState.ESPLabels[player.Name]
				end
				
				if label then
					UpdateESPLabel(player, label)
				end
			end
		end
	end)
	
	State.AddConnection("PlayerESP", updateConnection)
	print("✅ Player ESP enabled")
	return true
end

--[[
	Desabilita o Player ESP
]]
function PlayerESP.Disable()
	if not ESPState.Enabled then return end
	
	for _, label in pairs(ESPState.ESPLabels) do
		if label and label.Parent then
			label:Destroy()
		end
	end
	
	ESPState.Enabled = false
	ESPState.ESPLabels = {}
	State.DisableModule("PlayerESP")
	print("🛑 Player ESP disabled")
end

--[[
	Retorna se PlayerESP está habilitado
	@return boolean
]]
function PlayerESP.IsEnabled()
	return ESPState.Enabled
end

return PlayerESP