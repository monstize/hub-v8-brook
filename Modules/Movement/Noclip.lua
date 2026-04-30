--[[
	Brookhaven Hub v8 - Noclip Module
	Sistema avançado de Noclip com detecção de colisão apropriada
]]

local Noclip = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local NoclipState = {
	Enabled = false,
	CharacterParts = {},
	OriginalCanCollide = {},
	CollisionGroup = nil,
}

--[[
	Cria o grupo de colisão
]]
local function CreateCollisionGroup()
	local PhysicsService = Services.GetService("PhysicsService")
	
	local groupName = Config.Noclip.CollisionGroupName
	local success = false
	
	pcall(function()
		PhysicsService:CreateCollisionGroup(groupName)
		success = true
	end)
	
	if success then
		pcall(function()
			PhysicsService:CollisionGroupSetCollidable(groupName, false)
		end)
	end
	
	return groupName
end

--[[
	Inicia o Noclip
]]
function Noclip.Enable()
	if NoclipState.Enabled then return end
	
	local Character = Services.LocalCharacter()
	if not Character then
		warn("Character not found")
		return false
	end
	
	local PhysicsService = Services.GetService("PhysicsService")
	local groupName = CreateCollisionGroup()
	
	-- Armazena partes e desabilita colisão
	for _, part in ipairs(Character:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(NoclipState.CharacterParts, part)
			NoclipState.OriginalCanCollide[part] = part.CanCollide
			
			-- Tenta adicionar ao grupo de colisão
			pcall(function()
				PhysicsService:AddToCollisionGroup(groupName, part)
			end)
		end
	end
	
	NoclipState.Enabled = true
	NoclipState.CollisionGroup = groupName
	State.EnableModule("Noclip")
	
	-- Loop de manutenção
	local connection = Services.RunService():BindToHeartbeat("NoclipUpdate", function()
		if not NoclipState.Enabled then
			Services.RunService():UnbindFromHeartbeat("NoclipUpdate")
			return
		end
		
		local character = Services.LocalCharacter()
		if not character then
			Noclip.Disable()
			return
		end
		
		-- Verifica se há novas partes
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and not table.find(NoclipState.CharacterParts, part) then
				table.insert(NoclipState.CharacterParts, part)
				NoclipState.OriginalCanCollide[part] = part.CanCollide
				
				pcall(function()
					PhysicsService:AddToCollisionGroup(NoclipState.CollisionGroup, part)
				end)
			end
		end
	end)
	
	State.AddConnection("Noclip", function()
		Services.RunService():UnbindFromHeartbeat("NoclipUpdate")
	end)
	
	print("✅ Noclip enabled")
	return true
end

--[[
	Desabilita o Noclip
]]
function Noclip.Disable()
	if not NoclipState.Enabled then return end
	
	local PhysicsService = Services.GetService("PhysicsService")
	
	-- Restaura colisão original
	for part, wasColliding in pairs(NoclipState.OriginalCanCollide) do
		if part and part.Parent then
			part.CanCollide = wasColliding
		end
	end
	
	NoclipState.Enabled = false
	NoclipState.CharacterParts = {}
	NoclipState.OriginalCanCollide = {}
	
	Services.RunService():UnbindFromHeartbeat("NoclipUpdate")
	State.DisableModule("Noclip")
	print("🛑 Noclip disabled")
end

--[[
	Retorna se Noclip está habilitado
	@return boolean
]]
function Noclip.IsEnabled()
	return NoclipState.Enabled
end

return Noclip