--[[
	Brookhaven Hub v8 - Fly Module
	Sistema de voo com controle mobile otimizado
]]

local Fly = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local FlySpeed = Config.Fly.Speed
local FlyVelocity = nil
local FlyConnection = nil
local FlyingActive = false
local FlyDirection = Vector3.new(0, 0, 0)
local FlyAcceleration = Config.Fly.Acceleration

--[[
	Inicia o sistema de voo
]]
function Fly.Enable()
	if FlyingActive then return end
	
	local Root = Services.LocalRoot()
	if not Root then
		warn("[Fly] No character found")
		return
	end
	
	FlyingActive = true
	FlyDirection = Vector3.new(0, 0, 0)
	
	-- Criar BodyVelocity
	if Root:FindFirstChild("FlyVelocity") then
		Root:FindFirstChild("FlyVelocity"):Destroy()
	end
	
	FlyVelocity = Instance.new("BodyVelocity")
	FlyVelocity.Name = "FlyVelocity"
	FlyVelocity.Velocity = Vector3.new(0, 0, 0)
	FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	FlyVelocity.Parent = Root
	
	-- Conexão principal de voo
	FlyConnection = Services.RunService():BindToHeartbeat("FlyLoop", function(deltaTime)
		if not FlyingActive or not Root or not Root.Parent then
			Fly.Disable()
			return
		end
		
		local Camera = Services.Camera()
		if not Camera then return end
		
		-- Atualizar direção baseado na câmera
		local cameraDirection = Camera.CFrame.LookVector
		local cameraRight = Camera.CFrame.RightVector
		local cameraUp = Vector3.new(0, 1, 0)
		
		local inputDirection = Vector3.new(0, 0, 0)
		local UserInput = Services.UserInputService()
		
		-- Controles de teclado
		if UserInput:IsKeyDown(Enum.KeyCode.W) then
			inputDirection = inputDirection + cameraDirection
		end
		if UserInput:IsKeyDown(Enum.KeyCode.S) then
			inputDirection = inputDirection - cameraDirection
		end
		if UserInput:IsKeyDown(Enum.KeyCode.A) then
			inputDirection = inputDirection - cameraRight
		end
		if UserInput:IsKeyDown(Enum.KeyCode.D) then
			inputDirection = inputDirection + cameraRight
		end
		if UserInput:IsKeyDown(Enum.KeyCode.Space) then
			inputDirection = inputDirection + cameraUp
		end
		if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then
			inputDirection = inputDirection - cameraUp
		end
		
		-- Normalizar e aplicar velocidade
		if inputDirection.Magnitude > 0 then
			inputDirection = inputDirection.Unit
		end
		
		FlyVelocity.Velocity = inputDirection * FlySpeed
	end)
	
	State.RegisterConnection("Fly", FlyConnection)
	State.SetModuleState("Fly", true)
	print("✅ Fly enabled")
end

--[[
	Desativa o sistema de voo
]]
function Fly.Disable()
	if not FlyingActive then return end
	
	FlyingActive = false
	
	if FlyConnection then
		Services.RunService():UnbindFromHeartbeat("FlyLoop")
		FlyConnection = nil
	end
	
	local Root = Services.LocalRoot()
	if Root and Root:FindFirstChild("FlyVelocity") then
		Root:FindFirstChild("FlyVelocity"):Destroy()
	end
	
	FlyVelocity = nil
	State.SetModuleState("Fly", false)
	print("✅ Fly disabled")
end

--[[
	Altera a velocidade de voo
	@param newSpeed: número
]]
function Fly.SetSpeed(newSpeed)
	FlySpeed = newSpeed
end

--[[
	Retorna se está voando
	@return boolean
]]
function Fly.IsEnabled()
	return FlyingActive
end

return Fly