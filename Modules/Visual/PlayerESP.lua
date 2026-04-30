--[[
	Brookhaven Hub v8 - Player ESP Module
	Mostra informações dos players na tela
]]

local PlayerESP = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Utils = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local ESPActive = false
local ESPConnection = nil
local ESPLabels = {}
local UpdateTimer = 0

--[[
	Inicia o PlayerESP
]]
function PlayerESP.Enable()
	if ESPActive then return end
	
	local Camera = Services.Camera()
	if not Camera then
		warn("[PlayerESP] No camera found")
		return
	end
	
	ESPActive = true
	
	ESPConnection = Services.RunService().RenderStepped:Connect(function()
		if not ESPActive then return end
		
		UpdateTimer = UpdateTimer + (1/60)
		
		if UpdateTimer < Config.PlayerESP.UpdateRate then
			return
		end
		
		UpdateTimer = 0
		
		local Players = Services.Players()
		local LocalPlayer = Services.LocalPlayer()
		local LocalRoot = Services.LocalRoot()
		local Camera = Services.Camera()
		
		if not LocalRoot or not Camera then return end
		
		-- Limpar labels mortos
		for player, label in pairs(ESPLabels) do
			if not player or not player.Parent or not label or not label.Parent then
				ESPLabels[player] = nil
			end
		end
		
		-- Atualizar labels
		for _, player in ipairs(Players:GetPlayers()) do
			if player == LocalPlayer or not player.Character then
				continue
			end
			
			local character = player.Character
			local humanoid = character:FindFirstChild("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")
			
			if not humanoid or not root or humanoid.Health <= 0 then
				continue
			end
			
			local distance = Utils.GetDistance(LocalRoot.Position, root.Position)
			
			if distance > Config.PlayerESP.MaxDistance then
				continue
			end
			
			-- Criar ou atualizar label
			if not ESPLabels[player] then
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Size = UDim2.new(4, 0, 2, 0)
				billboardGui.MaxDistance = Config.PlayerESP.MaxDistance
				billboardGui.Adornee = root
				
				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundColor3 = Config.PlayerESP.BackgroundColor
				textLabel.BackgroundTransparency = 0.3
				textLabel.TextColor3 = Config.PlayerESP.TextColor
				textLabel.TextSize = Config.PlayerESP.TextSize
				textLabel.Font = Enum.Font.GothamBold
				textLabel.Parent = billboardGui
				
				billboardGui.Parent = root
				ESPLabels[player] = billboardGui
			end
			
			local label = ESPLabels[player]
			if label and label.Parent then
				local textLabel = label:FindFirstChildOfClass("TextLabel")
				if textLabel then
					textLabel.Text = player.Name .. "\n" .. math.floor(distance) .. "m"
					textLabel.TextColor3 = Utils.GetColorByDistance(distance, Config.PlayerESP.MaxDistance)
				end
			end
		end
	end)
	
	State.RegisterConnection("PlayerESP", ESPConnection)
	State.SetModuleState("PlayerESP", true)
	print("✅ PlayerESP enabled")
end

--[[
	Desativa o PlayerESP
]]
function PlayerESP.Disable()
	if not ESPActive then return end
	
	ESPActive = false
	
	if ESPConnection then
		ESPConnection:Disconnect()
		ESPConnection = nil
	end
	
	-- Limpar labels
	 for player, label in pairs(ESPLabels) do
		if label and label.Parent then
			label:Destroy()
		end
	end
	
	ESPLabels = {}
	State.SetModuleState("PlayerESP", false)
	print("✅ PlayerESP disabled")
end

--[[
	Retorna se está ativo
	@return boolean
]]
function PlayerESP.IsEnabled()
	return ESPActive
end

return PlayerESP