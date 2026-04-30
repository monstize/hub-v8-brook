--[[
	Brookhaven Hub v8 - Utility Functions
	Funções auxiliares para o hub
]]

local Utils = {}
local Services = require(script.Parent:FindFirstChild("Services"))

--[[
	Cria um tween suave
	@param object: Objeto a ser animado
	@param properties: Propriedades a animar (ex: {Position = Vector3.new(0,0,0)})
	@param duration: Duração em segundos
	@param style: TweenStyle (default: Quad)
	@param direction: EasingDirection (default: InOut)
]]
function Utils.CreateTween(object, properties, duration, style, direction)
	local TweenService = Services.TweenService()
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.InOut
	
	local tweenInfo = TweenInfo.new(duration, style, direction)
	local tween = TweenService:Create(object, tweenInfo, properties)
	return tween
end

--[[
	Retorna a distância entre dois pontos
	@param pos1: Vector3
	@param pos2: Vector3
	@return number
]]
function Utils.GetDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

--[[
	Retorna a cor baseada na distância
	@param distance: número
	@param maxDistance: número máximo
	@return Color3
]]
function Utils.GetColorByDistance(distance, maxDistance)
	local ratio = math.min(distance / maxDistance, 1)
	if ratio < 0.5 then
		return Color3.fromRGB(255, 0, 0) -- Vermelho (perto)
	elseif ratio < 0.75 then
		return Color3.fromRGB(255, 255, 0) -- Amarelo (médio)
	else
		return Color3.fromRGB(0, 255, 0) -- Verde (longe)
	end
end

--[[
	Limpa todas as conexões de um objeto
	@param connections: table com as conexões
]]
function Utils.CleanupConnections(connections)
	if not connections then return end
	for _, connection in ipairs(connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
end

--[[
	Cria um TextLabel customizado
	@param parent: Container pai
	@param text: Texto inicial
	@param size: UDim2
	@param position: UDim2
	@return TextLabel
]]
function Utils.CreateTextLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.Parent = parent
	return label
end

--[[
	Cria um botão customizado
	@param parent: Container pai
	@param text: Texto do botão
	@param size: UDim2
	@param position: UDim2
	@param callback: Função ao clicar
	@return TextButton
]]
function Utils.CreateButton(parent, text, size, position, callback)
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	
	return button
end

--[[
	Retorna se o player está em um dispositivo mobile
	@return boolean
]]
function Utils.IsMobile()
	local UserInputService = Services.UserInputService()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

--[[
	Cria uma caixa de entrada (TextBox)
	@param parent: Container pai
	@param placeholder: Texto placeholder
	@param size: UDim2
	@param position: UDim2
	@return TextBox
]]
function Utils.CreateTextBox(parent, placeholder, size, position)
	local textbox = Instance.new("TextBox")
	textbox.Name = "TextBox"
	textbox.PlaceholderText = placeholder
	textbox.Size = size
	textbox.Position = position
	textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textbox.TextSize = 14
	textbox.Font = Enum.Font.Gotham
	textbox.BorderSizePixel = 0
	textbox.ClearTextOnFocus = false
	textbox.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = textbox
	
	return textbox
end

return Utils