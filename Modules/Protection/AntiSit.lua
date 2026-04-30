--[[
	Brookhaven Hub v8 - AntiSit Module
	Previne sentar automaticamente
]]

local AntiSit = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local AntiSitActive = false
local AntiSitConnections = {}

--[[
	Inicia o AntiSit
]]
function AntiSit.Enable()
	if AntiSitActive then return end
	
	local Character = Services.LocalCharacter()
	if not Character then
		warn("[AntiSit] No character found")
		return
	end
	
	AntiSitActive = true
	
	-- Monitorar Seat e VehicleSeat
	local humanoid = Services.LocalHumanoid()
	if humanoid then
		local connection = humanoid.Seated:Connect(function(isSeated, seat)
			if isSeated and AntiSitActive then
				if seat and (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
					humanoid:MoveTo(Services.LocalRoot().Position)
					print("⚠️ AntiSit: Prevented sitting")
				end
		end
	end)
	
	table.insert(AntiSitConnections, connection)
	end
	
	-- Loop contínuo para garantir
	local heartbeatConnection = Services.RunService():BindToHeartbeat("AntiSitLoop", function()
		if not AntiSitActive then return end
		
		local Character = Services.LocalCharacter()
		local humanoid = Services.LocalHumanoid()
		
		if not Character or not humanoid then
			AntiSit.Disable()
			return
		end
		
		if humanoid.Sit then
			humanoid.Sit = false
			print("⚠️ AntiSit: Force stand")
		end
	end)
	
	table.insert(AntiSitConnections, heartbeatConnection)
	
	State.SetModuleState("AntiSit", true)
	print("✅ AntiSit enabled")
end

--[[
	Desativa o AntiSit
]]
function AntiSit.Disable()
	if not AntiSitActive then return end
	
	AntiSitActive = false
	
	for _, connection in ipairs(AntiSitConnections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	
	AntiSitConnections = {}
	Services.RunService():UnbindFromHeartbeat("AntiSitLoop")
	
	State.SetModuleState("AntiSit", false)
	print("✅ AntiSit disabled")
end

--[[
	Retorna se está ativo
	@return boolean
]]
function AntiSit.IsEnabled()
	return AntiSitActive
end

return AntiSit