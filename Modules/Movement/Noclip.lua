--[[
	Brookhaven Hub v8 - Noclip Module
	Sistema de noclip corrigido com suporte consistente
]]

local Noclip = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local NoclipActive = false
local NoclipConnection = nil
local OriginalCollisions = {}
local PhysicsService = nil
local NoclipGroup = nil
local Character = nil

--[[
	Inicia o noclip
]]
function Noclip.Enable()
	if NoclipActive then return end
	
	Character = Services.LocalCharacter()
	if not Character then
		warn("[Noclip] No character found")
		return
	end
	
	NoclipActive = true
	
	-- Tentar usar PhysicsService
	local success, PhysicsServiceModule = pcall(function()
		return game:GetService("PhysicsService")
	end)
	
	if success then
		PhysicsService = PhysicsServiceModule
		pcall(function()
			PhysicsService:CreateCollisionGroup(Config.Noclip.CollisionGroupName)
		end)
	end
	
	-- Desativar colisão de todas as partes do personagem
	for _, part in ipairs(Character:GetDescendants()) do
		if part:IsA("BasePart") then
			OriginalCollisions[part] = part.CanCollide
			part.CanCollide = false
			
			if PhysicsService then
				pcall(function()
					PhysicsService:CollisionGroupSetCollidable(Config.Noclip.CollisionGroupName, "Default", false)
				end)
			end
		end
	end
	
	-- Conexão contínua para garantir colisão desativada
	NoclipConnection = Services.RunService():BindToHeartbeat("NoclipLoop", function()
		if not NoclipActive or not Character or not Character.Parent then
			Noclip.Disable()
			return
		end
		
		-- Garantir que nenhuma parte tenha colisão
		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)
	
	State.RegisterConnection("Noclip", NoclipConnection)
	State.SetModuleState("Noclip", true)
	print("✅ Noclip enabled")
end

--[[
	Desativa o noclip
]]
function Noclip.Disable()
	if not NoclipActive then return end
	
	NoclipActive = false
	
	if NoclipConnection then
		Services.RunService():UnbindFromHeartbeat("NoclipLoop")
		NoclipConnection = nil
	end
	
	if not Character or not Character.Parent then
		Character = Services.LocalCharacter()
	end
	
	-- Restaurar colisões originais
	if Character then
		for part, originalCollision in pairs(OriginalCollisions) do
			if part and part.Parent then
				part.CanCollide = originalCollision
			end
		end
	end
	
	OriginalCollisions = {}
	State.SetModuleState("Noclip", false)
	print("✅ Noclip disabled")
end

--[[
	Retorna se está em noclip
	@return boolean
]]
function Noclip.IsEnabled()
	return NoclipActive
end

return Noclip