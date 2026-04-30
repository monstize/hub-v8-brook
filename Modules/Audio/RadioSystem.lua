--[[
	Brookhaven Hub v8 - Radio System Module
	Sistema completo de reprodução de música
]]

local RadioSystem = {}

local Services = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Favorites = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Modules"):FindFirstChild("Audio"):FindFirstChild("Favorites"))
local Config = require(game:GetService("RunService").Parent.Parent.Parent:FindFirstChild("Config"))

-- Variáveis do módulo
local RadioActive = false
local CurrentMusic = nil
local CurrentMusicID = nil
local MusicContainer = nil

--[[
	Inicia o sistema de rádio
]]
function RadioSystem.Initialize()
	if RadioActive then return end
	
	RadioActive = true
	
	-- Criar container para músicas
	local Workspace = Services.Workspace()
	if Workspace:FindFirstChild("RadioContainer") then
		Workspace:FindFirstChild("RadioContainer"):Destroy()
	end
	
	MusicContainer = Instance.new("Folder")
	MusicContainer.Name = "RadioContainer"
	MusicContainer.Parent = Workspace
	
	State.SetModuleState("RadioSystem", true)
	print("✅ RadioSystem initialized")
end

--[[
	Toca uma música por ID
	@param musicID: ID da música (número)
	@param volume: Volume (0-1)
]]
function RadioSystem.PlayMusic(musicID, volume)
	if not RadioActive then
		RadioSystem.Initialize()
	end
	
	volume = volume or Config.Radio.Volume
	
	-- Parar música anterior
	if CurrentMusic then
		CurrentMusic:Destroy()
	end
	
	-- Criar som
	local sound = Instance.new("Sound")
	sound.Name = "Music_" .. musicID
	sound.SoundId = "rbxassetid://" .. musicID
	sound.Volume = volume
	sound.Parent = MusicContainer
	
	-- Reproduzir
	pcall(function()
		sound:Play()
	end)
	
	CurrentMusic = sound
	CurrentMusicID = musicID
	
	print("🎵 Playing music: " .. musicID)
end

--[[
	Para a música
]]
function RadioSystem.StopMusic()
	if CurrentMusic then
		CurrentMusic:Stop()
		CurrentMusic:Destroy()
		CurrentMusic = nil
		CurrentMusicID = nil
		print("⏹️  Music stopped")
	end
end

--[[
	Altera o volume
	@param newVolume: Novo volume (0-1)
]]
function RadioSystem.SetVolume(newVolume)

if CurrentMusic then
		CurrentMusic.Volume = math.clamp(newVolume, 0, 1)
		Config.Radio.Volume = newVolume
	end
end

--[[
	Retorna a música atual
	@return ID da música
]]
function RadioSystem.GetCurrentMusic()
	return CurrentMusicID
end

--[[
	Favorita uma música
	@param musicName: Nome da música
	@param musicID: ID da música
]]
function RadioSystem.AddFavorite(musicName, musicID)
	Favorites.AddFavorite(musicName, musicID)
	print("⭐ Added to favorites: " .. musicName)
end

--[[
	Retorna todas as favoritas
	@return table com favoritas
]]
function RadioSystem.GetFavorites()
	return Favorites.GetFavorites()
end

--[[

Desativa o sistema de rádio
]]
function RadioSystem.Disable()
	RadioSystem.StopMusic()
	
	if MusicContainer then
		MusicContainer:Destroy()
		MusicContainer = nil
	end
	
	RadioActive = false
	State.SetModuleState("RadioSystem", false)
	print("✅ RadioSystem disabled")
end

--[[
	Retorna se está ativo
	@return boolean
]]
function RadioSystem.IsEnabled()
	return RadioActive
end

return RadioSystem