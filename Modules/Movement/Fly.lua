--[[
	Brookhaven Hub v8 - Fly Module
	Sistema de voo com suporte completo para mobile
]]

local Fly = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Utils = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local FlyState = {
	Enabled = false,
	Velocity = nil,
	BodyVelocity = nil,
	Gyro = nil,
	CurrentSpeed = 0,
	TargetSpeed = Config.Fly.Speed,
}

--[[
	Inicia o sistema de voo
]]
function Fly.Enable()
	if FlyState.Enabled then return end
	
	local Root = Services.LocalRoot()
	local Character = Services.LocalCharacter()
	local Camera = Services.Camera()
	
	if not Root or not Character or not Camera then
		warn("Cannot enable Fly: Character or Camera not found")
		return false
	end
	
	-- Remove antigos se existirem
	if Root:FindFirstChild("FlyVelocity") then
		Root:FindFirstChild("FlyVelocity"):Destroy()
	end
	if Root:FindFirstChild("FlyGyro") then
		Root:FindFirstChild("FlyGyro"):Destroy()
	end
	
	-- Cria BodyVelocity
	local BodyVel = Instance.new("BodyVelocity")
	BodyVel.Name = "FlyVelocity"
	BodyVel.Velocity = Vector3.new(0, 0, 0)
	BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVel.Parent = Root
	FlyState.BodyVelocity = BodyVel
	
	-- Cria BodyGyro
	local Gyro = Instance.new("BodyGyro")
	Gyro.Name = "FlyGyro"
	Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	Gyro.D = 500
	Gyro.CFrame = Root.CFrame
	Gyro.Parent = Root
	FlyState.Gyro = Gyro
	
	FlyState.Enabled = true
	State.EnableModule("Fly")
	
	-- Loop de atualização
	local connection = Services.RunService():BindToHeartbeat("FlyUpdate", function()
		if not FlyState.Enabled then
			Services.RunService():UnbindFromHeartbeat("FlyUpdate")
			return
		end
		
		local root = Services.LocalRoot()
		if not root or not FlyState.BodyVelocity or not FlyState.Gyro then
			Fly.Disable()
			return
		end
		
		local camera = Services.Camera()
		local moveInput = Vector3.new(0, 0, 0)
		
		-- Pega input (simulado para mobile)
		local UserInput = Services.UserInputService()
		if UserInput:IsKeyDown(Enum.KeyCode.W) then moveInput = moveInput + camera.CFrame.LookVector end
		if UserInput:IsKeyDown(Enum.KeyCode.S) then moveInput = moveInput - camera.CFrame.LookVector end
		if UserInput:IsKeyDown(Enum.KeyCode.A) then moveInput = moveInput - camera.CFrame.RightVector end
		if UserInput:IsKeyDown(Enum.KeyCode.D) then moveInput = moveInput + camera.CFrame.RightVector end
		if UserInput:IsKeyDown(Enum.KeyCode.Space) then moveInput = moveInput + Vector3.new(0, 1, 0) end
		if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveInput = moveInput + Vector3.new(0, -1, 0) end
		
		-- Normaliza movimento
		if moveInput.Magnitude > 0 then
			moveInput = moveInput.Unit
			FlyState.CurrentSpeed = Utils.Lerp(FlyState.CurrentSpeed, FlyState.TargetSpeed, 0.1)
		else
			FlyState.CurrentSpeed = Utils.Lerp(FlyState.CurrentSpeed, 0, 0.1)
		end
		
		-- Aplica velocidade
		FlyState.BodyVelocity.Velocity = moveInput * FlyState.CurrentSpeed
		
		-- Rotaciona para câmera
		FlyState.Gyro.CFrame = camera.CFrame
	end)
	
	State.AddConnection("Fly", function()
		Services.RunService():UnbindFromHeartbeat("FlyUpdate")
	end)
	
	print("✅ Fly enabled")
	return true
end

--[[
	Desabilita o sistema de voo
]]
function Fly.Disable()
	if not FlyState.Enabled then return end
	
	local Root = Services.LocalRoot()
	
	if FlyState.BodyVelocity then
		FlyState.BodyVelocity:Destroy()
		FlyState.BodyVelocity = nil
	end
	
	if FlyState.Gyro then
		FlyState.Gyro:Destroy()
		FlyState.Gyro = nil
	end
	
	FlyState.Enabled = false
	FlyState.CurrentSpeed = 0
	
	Services.RunService():UnbindFromHeartbeat("FlyUpdate")
	State.DisableModule("Fly")
	print("🛑 Fly disabled")
end

--[[
	Muda a velocidade de voo
	@param speed: Nova velocidade
]]
function Fly.SetSpeed(speed)
	FlyState.TargetSpeed = Utils.Clamp(speed, 10, 200)
end

--[[
	Retorna se o voo está habilitado
	@return boolean
]]
function Fly.IsEnabled()
	return FlyState.Enabled
end

return Fly