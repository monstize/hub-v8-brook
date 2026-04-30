--[[
	Brookhaven Hub v8 - Main Initializer
	Inicializa o hub e carrega todos os módulos
]]

local Main = {}

local Services = require(script.Parent:FindFirstChild("Services"))
local State = require(script.Parent:FindFirstChild("State"))
local Utils = require(script.Parent:FindFirstChild("Utils"))
local Config = require(script.Parent.Parent:FindFirstChild("Config"))

-- Variáveis locais
local HubEnabled = true
local LoadedModules = {}

--[[
	Carrega um módulo do hub
	@param modulePath: Caminho do módulo (ex: "Movement/Fly")
	@return Module table ou nil
]]
function Main.LoadModule(modulePath)
	if LoadedModules[modulePath] then
		return LoadedModules[modulePath]
	end
	
	local pathParts = string.split(modulePath, "/")
	local modulesFolder = script.Parent.Parent:FindFirstChild("Modules")
	
	if not modulesFolder then
		warn("Modules folder not found!")
		return nil
	end
	
	local current = modulesFolder
	for i, part in ipairs(pathParts) do
		if i < #pathParts then
			current = current:FindFirstChild(part)
			if not current then
				warn("Module path not found: " .. modulePath)
				return nil
			end
		else
			local moduleScript = current:FindFirstChild(part .. ".lua")
			if moduleScript then
				local success, module = pcall(function()
					return require(moduleScript)
				end)
				if success then
					LoadedModules[modulePath] = module
					return module
				else
					warn("Failed to load module " .. modulePath .. ": " .. tostring(module))
					return nil
				end
			end
		end
	end
	
	return nil
end

--[[
	Inicializa o Hub
]]
function Main.Initialize()
	print("🚀 Brookhaven Hub v8 Initializing...")
	
	if not Services.LocalPlayer() then
		warn("LocalPlayer not found!")
		return false
	end
	
	print("✅ Services initialized")
	print("✅ State system ready")
	print("✅ Hub initialized successfully!")
	
	HubEnabled = true
	return true
end

--[[
	Desabilita o Hub
]]
function Main.Disable()
	print("🛑 Disabling Brookhaven Hub v8...")
	State.CleanupModule("Fly")
	State.CleanupModule("Noclip")
	State.CleanupModule("AntiVoid")
	State.CleanupModule("AntiSit")
	State.CleanupModule("CameraSpy")
	State.CleanupModule("PlayerESP")
	State.CleanupModule("IDTag")
	State.CleanupModule("RadioSystem")
	HubEnabled = false
	print("✅ Hub disabled")
end

--[[
	Retorna se o Hub está habilitado
	@return boolean
]]
function Main.IsEnabled()
	return HubEnabled
end

--[[
	Retorna todos os módulos carregados
	@return table
]]
function Main.GetLoadedModules()
	return LoadedModules
end

-- Auto-initialize
if not game:IsLoaded() then
	game.Loaded:Wait()
end

Main.Initialize()

return Main