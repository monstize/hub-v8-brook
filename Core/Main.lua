--[[
	Brookhaven Hub v8 - Core/Main.lua
	Inicializador central do sistema
]]

local Config = require(script.Parent:WaitForChild("Config"))
local Services = require(script.Parent.Core:WaitForChild("Services"))
local State = require(script.Parent.Core:WaitForChild("State"))
local Utils = require(script.Parent.Core:WaitForChild("Utils"))

local Main = {}

-- Raiz do projeto
Main.RootFolder = script.Parent
Main.CoreFolder = Main.RootFolder:WaitForChild("Core")
Main.ModulesFolder = Main.RootFolder:WaitForChild("Modules")
Main.Config = Config
Main.Services = Services
Main.State = State
Main.Utils = Utils

--[[
	Inicializa o sistema
]]
function Main:Initialize()
	print("[Brookhaven Hub v8] Iniciando...")
	
	-- Aguardar o jogo carregar
	game:WaitForChild("Players")
	
	-- Inicializar State
	State:Initialize()
	
	-- Carregar módulos
	self:LoadModules()
	
	print("[Brookhaven Hub v8] Sistema inicializado com sucesso! ✅")
	return true
end

--[[
	Carrega todos os módulos
]]
function Main:LoadModules()
	local ModulesLoaded = 0
	
	-- Listar e carregar todos os módulos
	for _, category in pairs(self.ModulesFolder:GetChildren()) do
		if category:IsA("Folder") then
			for _, moduleScript in pairs(category:GetChildren()) do
				if moduleScript:IsA("ModuleScript") then
					local Module = require(moduleScript)
					if Module and type(Module) == "table" then
						ModulesLoaded = ModulesLoaded + 1
						print("[Brookhaven Hub v8] Módulo carregado: " .. category.Name .. "/" .. moduleScript.Name)
					end
				end
			end
		end
	end
	
	print("[Brookhaven Hub v8] Total de módulos carregados: " .. ModulesLoaded)
end

--[[
	Retorna um módulo pelo caminho
	@param path: "Movement/Fly", "Protection/AntiVoid", etc
	@return Module ou nil
]]
function Main:GetModule(path)
	local parts = Utils.SplitString(path, "/")
	if #parts ~= 2 then return nil end
	
	local category = parts[1]
	local moduleName = parts[2]
	
	local categoryFolder = self.ModulesFolder:FindChild(category)
	if not categoryFolder then return nil end
	
	local moduleScript = categoryFolder:FindChild(moduleName)
	if not moduleScript then return nil end
	
	return require(moduleScript)
end

--[[
	Limpa recursos ao desligar
]]
function Main:Cleanup()
	print("[Brookhaven Hub v8] Limpando recursos...")
	State:Cleanup()
	print("[Brookhaven Hub v8] Sistema desligado! ✅")
end

-- Conectar ao evento de fechamento
Services.RunService():BindToClose(function()
	Main:Cleanup()
end)

-- Iniciar sistema
if game:IsLoaded() then
	Main:Initialize()
else
	game.Loaded:Connect(function()
		Main:Initialize()
	end)
end

return Main
