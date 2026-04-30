--[[
	Brookhaven Hub v8 - Core Services
	Centraliza GetService e funcionalidades principais
]]

local Services = {}

-- Cache de serviços
local ServiceCache = {}

--[[
	Retorna um serviço do jogo
	@param serviceName: Nome do serviço (ex: "Players", "RunService")
	@return Service
]]
function Services.GetService(serviceName)
	if not ServiceCache[serviceName] then
		ServiceCache[serviceName] = game:GetService(serviceName)
	end
	return ServiceCache[serviceName]
end

-- Alias rápidos para serviços comuns
Services.Players = function() return Services.GetService("Players") end
Services.RunService = function() return Services.GetService("RunService") end
Services.UserInputService = function() return Services.GetService("UserInputService") end
Services.Workspace = function() return Services.GetService("Workspace") end
Services.TweenService = function() return Services.GetService("TweenService") end
Services.CoreGui = function() return Services.GetService("CoreGui") end
Services.SoundService = function() return Services.GetService("SoundService") end
Services.Debris = function() return Services.GetService("Debris") end

--[[
	Retorna o player local
	@return Player
]]
function Services.LocalPlayer()
	return Services.Players():WaitForChild("Player", 5) or Services.Players().LocalPlayer
end

--[[
	Retorna o character do player local
	@return Model
]]
function Services.LocalCharacter()
	local Player = Services.LocalPlayer()
	if not Player then return nil end
	return Player.Character or Player:WaitForChild("Character", 5)
end

--[[
	Retorna o humanoid do player local
	@return Humanoid
]]
function Services.LocalHumanoid()
	local Character = Services.LocalCharacter()
	if not Character then return nil end
	return Character:FindFirstChild("Humanoid")
end

--[[
	Retorna a câmera do jogo
	@return Camera
]]
function Services.Camera()
	return Services.Workspace():FindFirstChild("Camera")
end

--[[
	Retorna a raiz do personagem (HumanoidRootPart)
	@return BasePart
]]
function Services.LocalRoot()
	local Character = Services.LocalCharacter()
	if not Character then return nil end
	return Character:FindFirstChild("HumanoidRootPart")
end

return Services