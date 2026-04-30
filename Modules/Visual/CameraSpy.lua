--[[
	Brookhaven Hub v8 - Camera Spy Module
	Trava a câmera em outro player com controle de rotação
]]

local CameraSpy = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Utils = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local CameraSpyState = {
	Enabled = false,
	TargetPlayer = nil,
	OriginalCamera = nil,
	CameraOffset = CFrame.new(0, 2, 5),
	CameraRotation = Vector2.new(0, 0),
	Zoom = 10,
}

--[[
	Define o player alvo
	@param player: Player alvo
]]
function CameraSpy.SetTarget(player)
	if not player or not player.Character then
		warn("Invalid player")
		return false
	end
	
	CameraSpyState.TargetPlayer = player
	return true
end

--[[
	Inicia o Camera Spy
]]
function CameraSpy.Enable()
	if CameraSpyState.Enabled then return end
	
	if not CameraSpyState.TargetPlayer or not CameraSpyState.TargetPlayer.Character then
		warn("Target player not set or not found")
		return false
	end
	
	local Camera = Services.Camera()
	if not Camera then
		warn("Camera not found")
		return false
	end
	
	-- Salva câmera original
	CameraSpyState.OriginalCamera = Camera.CFrame
	CameraSpyState.Enabled = true
	State.EnableModule("CameraSpy")
	
	-- Input para rotação
	local UserInput = Services.UserInputService()
	local mouse = Services.Players().LocalPlayer:GetMouse()
	
	local inputConnection = UserInput.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed or not CameraSpyState.Enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouseDelta = Vector2.new(
				mouse.X - (mouse.X or 0),
				mouse.Y - (mouse.Y or 0)
			)
			
			CameraSpyState.CameraRotation = CameraSpyState.CameraRotation + mouseDelta * Config.CameraSpy.Speed
		end
		
		-- Zoom com scroll
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			CameraSpyState.Zoom = Utils.Clamp(
				CameraSpyState.Zoom - input.Position.Z * Config.CameraSpy.ZoomSensitivity,
				Config.CameraSpy.MinZoom,
				Config.CameraSpy.MaxZoom
			)
		end
	end)
	
	State.AddConnection("CameraSpy", inputConnection)
	
	-- Loop de atualização de câmera
	local updateConnection = Services.RunService().RenderStepped:Connect(function()
		if not CameraSpyState.Enabled then
			updateConnection:Disconnect()
			return
		end
		
		local target = CameraSpyState.TargetPlayer
		if not target or not target.Character then
			CameraSpy.Disable()
			return
		end
		
		local targetHead = target.Character:FindFirstChild("Head")
		if not targetHead then
			CameraSpy.Disable()
			return
		end
		
		-- Calcula posição da câmera com rotação
		local xRotation = CFrame.fromAxisAngle(Vector3.new(1, 0, 0), CameraSpyState.CameraRotation.Y)
		local yRotation = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), CameraSpyState.CameraRotation.X)
		local rotation = yRotation * xRotation
		
		local offset = rotation * Vector3.new(0, 0, -CameraSpyState.Zoom)
		Services.Camera().CFrame = CFrame.new(targetHead.Position + offset, targetHead.Position)
	end)
	
	State.AddConnection("CameraSpy", updateConnection)
	print("✅ Camera Spy enabled")
	return true
end

--[[
	Desabilita o Camera Spy
]]
function CameraSpy.Disable()
	if not CameraSpyState.Enabled then return end
	
	local Camera = Services.Camera()
	local LocalPlayer = Services.LocalPlayer()
	
	-- Restaura câmera
	if CameraSpyState.OriginalCamera and LocalPlayer and LocalPlayer.Character then
		local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if Root then
			Camera.CFrame = CFrame.new(Root.Position + Vector3.new(0, 5, 10), Root.Position)
		end
	end
	
	CameraSpyState.Enabled = false
	CameraSpyState.TargetPlayer = nil
	State.DisableModule("CameraSpy")
	print("🛑 Camera Spy disabled")
end

--[[
	Retorna se Camera Spy está habilitado
	@return boolean
]]
function CameraSpy.IsEnabled()
	return CameraSpyState.Enabled
end

return CameraSpy