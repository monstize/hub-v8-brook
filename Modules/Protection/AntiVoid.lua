--[[
	Brookhaven Hub v8 - AntiVoid Module
	Proteção contra queda no vazio
]]

local AntiVoid = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local AntiVoidActive = false
local AntiVoidConnection = nil
local LastSafePosition = nil
local CheckTimer = 0

--[[
	Inicia o AntiVoid
]]
function AntiVoid.Enable()
	if AntiVoidActive then return end
	
	local Root = Services.LocalRoot()
	if not Root then
		warn("[AntiVoid] No character found")
		return
	end
	
	AntiVoidActive = true
	LastSafePosition = Root.Position
	
	AntiVoidConnection = Services.RunService():BindToHeartbeat("AntiVoidLoop", function(deltaTime)
		if not AntiVoidActive then return end
		
		local Root = Services.LocalRoot()
		if not Root or not Root.Parent then
			AntiVoid.Disable()
			return
		end
		
		CheckTimer = CheckTimer + deltaTime
		
		if CheckTimer >= Config.AntiVoid.CheckInterval then
			CheckTimer = 0
			
			if Root.Position.Y < Config.AntiVoid.VoidLevel then
				-- Teleportar para última posição segura
				local humanoid = Services.LocalHumanoid()
				if humanoid and humanoid.Health > 0 then
					Root.CFrame = CFrame.new(LastSafePosition + Vector3.new(0, 5, 0))
					print("⚠️ AntiVoid: Teleported to safety")
				end
			else
				-- Atualizar última posição segura
				LastSafePosition = Root.Position
			end
		end
	end)
	
	State.RegisterConnection("AntiVoid", AntiVoidConnection)
	State.SetModuleState("AntiVoid", true)
	print("✅ AntiVoid enabled")
end

--[[
	Desativa o AntiVoid
]]
function AntiVoid.Disable()
	if not AntiVoidActive then return end
	
	AntiVoidActive = false
	CheckTimer = 0
	
	if AntiVoidConnection then
		Services.RunService():UnbindFromHeartbeat("AntiVoidLoop")
		AntiVoidConnection = nil
	end
	
	State.SetModuleState("AntiVoid", false)
	print("✅ AntiVoid disabled")
end

--[[
	Altera o nível do vazio
	@param newLevel: número
]]
function AntiVoid.SetVoidLevel(newLevel)
	Config.AntiVoid.VoidLevel = newLevel
end

--[[
	Retorna se está ativo
	@return boolean
]]
function AntiVoid.IsEnabled()
	return AntiVoidActive
end

return AntiVoid