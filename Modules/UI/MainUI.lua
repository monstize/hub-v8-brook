--[[
	Brookhaven Hub v8 - Main UI Module
	Interface principal do hub
]]

local MainUI = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local Utils = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Components = require(script.Parent:FindFirstChild("Components"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local UICreated = false
local MainWindow = nil
local FloatingButton = nil
local WindowOpen = false

--[[
	Cria a interface principal
]]
function MainUI.Create()
	if UICreated then return end
	
	local CoreGui = Services.CoreGui()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "BrookhavenHubUI"
	ScreenGui.ResetOnSpawn = false
	if pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.DevConsoleUI end) then end
	ScreenGui.Parent = CoreGui
	
	-- Botão Flutuante
	FloatingButton = Components.CreateFloatingButton(ScreenGui, function()
		MainUI.ToggleWindow()
	end)
	
	-- Janela Principal
	MainWindow = Components.CreateMainWindow(ScreenGui)
	MainWindow.Visible = false
	
	UICreated = true
	print("✅ Main UI created")
end

--[[
	Alterna a visibilidade da janela
]]
function MainUI.ToggleWindow()
	if not MainWindow then return end
	
	WindowOpen = not WindowOpen
	MainWindow.Visible = WindowOpen
end

--[[
	Abre a janela
]]
function MainUI.OpenWindow()
	if not MainWindow then return end
	WindowOpen = true
	MainWindow.Visible = true
end

--[[
	Fecha a janela
]]
function MainUI.CloseWindow()
	if not MainWindow then return end
	WindowOpen = false
	MainWindow.Visible = false
end

--[[
	Retorna se a UI foi criada
	@return boolean
]]
function MainUI.IsCreated()
	return UICreated
end

return MainUI