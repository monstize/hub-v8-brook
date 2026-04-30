--[[
	Brookhaven Hub v8 - ID Tag Module
	Mostra tag com ID do player local
]]

local IDTag = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local TagActive = false
local TagConnection = nil
local BillboardGui = nil
local BobOffset = 0

--[[
	Inicia o IDTag
]]
function IDTag.Enable()
	if TagActive then return end
	
	local Character = Services.LocalCharacter()
	if not Character then
		warn("[IDTag] No character found")
		return
	end
	
	local Head = Character:FindFirstChild("Head")
	if not Head then
		warn("[IDTag] No head found")
		return
	end
	
	TagActive = true
	
	-- Criar BillboardGui
	BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Size = UDim2.new(6, 0, 2, 0)
	BillboardGui.MaxDistance = 200
	BillboardGui.Adornee = Head
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
	textLabel.BackgroundTransparency = 0.2
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = Config.IDTag.TextSize
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "ID: " .. Services.LocalPlayer().UserId
	textLabel.Parent = BillboardGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = textLabel
	
	BillboardGui.Parent = Head
	
	-- Animação de bob
	TagConnection = Services.RunService().RenderStepped:Connect(function(deltaTime)
		if not TagActive or not BillboardGui or not BillboardGui.Parent then
			IDTag.Disable()
			return
		end
		
		BobOffset = BobOffset + (Config.IDTag.BobSpeed * deltaTime)
		if BobOffset > math.pi * 2 then
			BobOffset = BobOffset - (math.pi * 2)
		end
		
		local bobY = math.sin(BobOffset) * Config.IDTag.BobHeight
		BillboardGui.StudsOffset = Vector3.new(0, bobY, 0)
	end)
	
	State.RegisterConnection("IDTag", TagConnection)
	State.SetModuleState("IDTag", true)
	print("✅ IDTag enabled")
end

--[[
	Desativa o IDTag
]]
function IDTag.Disable()
	if not TagActive then return end
	
	TagActive = false
	BobOffset = 0
	
	if TagConnection then
		TagConnection:Disconnect()
		TagConnection = nil
	end
	
	if BillboardGui and BillboardGui.Parent then
		BillboardGui:Destroy()
	end
	
	BillboardGui = nil
	State.SetModuleState("IDTag", false)
	print("✅ IDTag disabled")
end

--[[
	Retorna se está ativo
	@return boolean
]]
function IDTag.IsEnabled()
	return TagActive
end

return IDTag