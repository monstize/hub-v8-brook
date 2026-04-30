--[[
	Brookhaven Hub v8 - Camera Spy Module
	Trava câmera em outro player com liberdade de rotação
]]

local CameraSpy = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local SpyActive = false
local SpyConnection = nil
local TargetPlayer = nil
local OriginalCamera = nil
local CameraRotation = Vector2.new(0, 0)
local CurrentZoom = 20

--[[
	Inicia o CameraSpy em um player específico
	@param targetPlayer: Player a espiar
]]
function CameraSpy.Enable(targetPlayer)
	if SpyActive then
		CameraSpy.Disable()
	end
	
	if not targetPlayer or not targetPlayer.Character then
		warn("[CameraSpy] Invalid target player")
		return
	end
	
	TargetPlayer = targetPlayer
	SpyActive = true
	CurrentZoom = 20
	
	SpyConnection = Services.RunService().RenderStepped:Connect(function()
		if not SpyActive or not TargetPlayer or not TargetPlayer.Character then
			CameraSpy.Disable()
			return
		end
		
		local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then
			CameraSpy.Disable()
			return
		end
		
		local Camera = Services.Camera()
		local UserInput = Services.UserInputService()
		
		-- Controles de rotação com mouse
		if UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local delta = UserInput:GetMouseDelta()
			CameraRotation = CameraRotation + delta * Config.CameraSpy.Speed
		end
		
		-- Zoom com scroll
		local Mouse = Services.Players():GetLocalPlayer():GetMouse()
		if Mouse.WheelBackward then
			CurrentZoom = math.min(CurrentZoom + Config.CameraSpy.ZoomSensitivity, Config.CameraSpy.MaxZoom)
		elseif Mouse.WheelForward then
			CurrentZoom = math.max(CurrentZoom - Config.CameraSpy.ZoomSensitivity, Config.CameraSpy.MinZoom)
		end
		
		-- Aplicar rotação
		local rotationX = math.rad(CameraRotation.Y)
		local rotationY = math.rad(CameraRotation.X)
		
		local newCFrame = targetRoot.CFrame
			* CFrame.Angles(rotationX, rotationY, 0)
			* CFrame.new(0, 0, CurrentZoom)
		
		Camera.CFrame = newCFrame
	end)
	
	State.RegisterConnection("CameraSpy", SpyConnection)
	State.SetModuleState("CameraSpy", true)
	print("✅ CameraSpy enabled on " .. TargetPlayer.Name)
end

--[[
	Desativa o CameraSpy
]]
function CameraSpy.Disable()
	if not SpyActive then return end
	
	SpyActive = false
	
	if SpyConnection then
		SpyConnection:Disconnect()
		SpyConnection = nil
	end
	
	TargetPlayer = nil
	State.SetModuleState("CameraSpy", false)
	print("✅ CameraSpy disabled")
end

--[[
	Muda o target
	@param newTarget: Novo player
]]
function CameraSpy.SetTarget(newTarget)
	if newTarget and newTarget.Character then
		TargetPlayer = newTarget
		print("📹 Camera target changed to " .. newTarget.Name)
	end
end

--[[
	Retorna se está ativo
	@return boolean
]]
function CameraSpy.IsEnabled()
	return SpyActive
end

return CameraSpy