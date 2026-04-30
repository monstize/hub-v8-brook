--[[
	Brookhaven Hub v8 - AntiSit Module
	Impede que o jogador sente em cadeiras
]]

local AntiSit = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local AntiSitState = {
	Enabled = false,
}

--[[
	Inicia o AntiSit
]]
function AntiSit.Enable()
	if AntiSitState.Enabled then return end
	
	local Humanoid = Services.LocalHumanoid()
	if not Humanoid then
		warn("Humanoid not found")
		return false
	end
	
	AntiSitState.Enabled = true
	State.EnableModule("AntiSit")
	
	-- Detecta tentativa de sentar
	local connection = Humanoid.Seated:Connect(function(isSeated)
		if isSeated and AntiSitState.Enabled then
			-- Força levantar
			Humanoid.Sit = false
			print("🚫 AntiSit: Prevented sit")
		end
	end)
	
	State.AddConnection("AntiSit", connection)
	
	-- Loop de verificação por outros métodos de sentar
	local checkConnection = Services.RunService().Heartbeat:Connect(function()
		if not AntiSitState.Enabled then
			checkConnection:Disconnect()
			return
		end
		
		local humanoid = Services.LocalHumanoid()
		local character = Services.LocalCharacter()
		
		if not humanoid or not character then
			AntiSit.Disable()
			return
		end
		
		-- Verifica se está sentado em algo
		local humanoidState = humanoid:GetState()
		if humanoidState == Enum.HumanoidStateType.Seated then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
	
	State.AddConnection("AntiSit", checkConnection)
	print("✅ AntiSit enabled")
	return true
end

--[[
	Desabilita o AntiSit
]]
function AntiSit.Disable()
	if not AntiSitState.Enabled then return end
	
	AntiSitState.Enabled = false
	State.DisableModule("AntiSit")
	print("🛑 AntiSit disabled")
end

--[[
	Retorna se AntiSit está habilitado
	@return boolean
]]
function AntiSit.IsEnabled()
	return AntiSitState.Enabled
end

return AntiSit