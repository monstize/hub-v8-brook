--[[
	Brookhaven Hub v8 - UI Components
	Componentes reutilizáveis da UI
]]

local Components = {}

local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

--[[
	Cria um botão flutuante
	@param parent: Container pai
	@param callback: Função ao clicar
	@return TextButton
]]
function Components.CreateFloatingButton(parent, callback)
	local button = Instance.new("TextButton")
	button.Name = "FloatingButton"
	button.Size = Config.UI.FloatingButtonSize
	button.Position = UDim2.new(0, 10, 0, 10)
	button.BackgroundColor3 = Config.UI.PrimaryColor
	button.TextColor3 = Config.UI.TextColor
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.Text = "≡"
	button.BorderSizePixel = 0
	button.Draggable = true
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = Config.UI.CornerRadius
	corner.Parent = button
	
	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	
	return button
end

--[[
	Cria a janela principal
	@param parent: Container pai
	@return Frame
]]
function Components.CreateMainWindow(parent)
	local frame = Instance.new("Frame")
	frame.Name = "MainWindow"
	frame.Size = Config.UI.MainWindowSize
	frame.Position = UDim2.new(0.5, -175, 0.5, -200)
	frame.BackgroundColor3 = Config.UI.SecondaryColor
	frame.BorderSizePixel = 0
	frame.Draggable = true
	frame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = Config.UI.CornerRadius
	corner.Parent = frame
	
	-- Título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.BackgroundColor3 = Config.UI.PrimaryColor
	titleLabel.TextColor3 = Config.UI.TextColor
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "🚀 Brookhaven Hub v8"
	titleLabel.BorderSizePixel = 0
	titleLabel.Parent = frame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = Config.UI.CornerRadius
	titleCorner.Parent = titleLabel
	
	-- ScrollingFrame para conteúdo
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "Content"
	scrollFrame.Size = UDim2.new(1, -10, 1, -50)
	scrollFrame.Position = UDim2.new(0, 5, 0, 45)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.TopImage = ""
	scrollFrame.BottomImage = ""
	scrollFrame.MidImage = ""
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
	scrollFrame.Parent = frame
	
	return frame
end

--[[
	Cria um toggle (botão on/off)
	@param parent: Container pai
	@param text: Texto do toggle
	@param callback: Função ao alternar
	@return Frame com toggle
]]
function Components.CreateToggle(parent, text, callback)
	local container = Instance.new("Frame")
	container.Name = "Toggle"
	container.Size = UDim2.new(1, -10, 0, 40)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Config.UI.TextColor
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Button"
	toggleButton.Size = UDim2.new(0, 50, 0, 25)
	toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
	toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	toggleButton.TextColor3 = Config.UI.TextColor
	toggleButton.TextSize = 12
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Text = "OFF"
	toggleButton.BorderSizePixel = 0
	toggleButton.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = toggleButton
	
	local state = false
	
	toggleButton.MouseButton1Click:Connect(function()
		state = not state
		toggleButton.BackgroundColor3 = state and Config.UI.PrimaryColor or Color3.fromRGB(100, 100, 100)
		toggleButton.Text = state and "ON" or "OFF"
		if callback then
			callback(state)
		end
	end)
	
	return container
end

--[[
	Cria uma seção com título
	@param parent: Container pai
	@param title: Título da seção
	@return Frame
]]
function Components.CreateSection(parent, title)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. title
	section.Size = UDim2.new(1, -10, 0, 50)
	section.BackgroundTransparency = 1
	section.Parent = parent
	
	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Size = UDim2.new(1, 0, 0, 25)
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.TextColor3 = Config.UI.AccentColor
	sectionTitle.TextSize = 14
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.Text = title
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = section
	
	return section
end

return Components