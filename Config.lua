--[[
	Brookhaven Hub v8 - Configuration File
	Arquivo centralizado de configurações
]]

local Config = {}

-- ANTI-VOID CONFIG
Config.AntiVoid = {
	Enabled = false,
	VoidLevel = -100,
	TeleportSpeed = 50,
	CheckInterval = 0.5,
}

-- ANTI-SIT CONFIG
Config.AntiSit = {
	Enabled = false,
	CheckInterval = 0.1,
}

-- NOCLIP CONFIG
Config.Noclip = {
	Enabled = false,
	CollisionGroupName = "NoclipGroup",
	UpdateRate = 0.05,
}

-- FLY CONFIG
Config.Fly = {
	Enabled = false,
	Speed = 50,
	Acceleration = 10,
	MobileJoystickSize = 60,
	UpDownButtonSize = 50,
}

-- CAMERA SPY CONFIG
Config.CameraSpy = {
	Enabled = false,
	Speed = 0.1,
	ZoomSensitivity = 2,
	MinZoom = 5,
	MaxZoom = 100,
}

-- PLAYER ESP CONFIG
Config.PlayerESP = {
	Enabled = false,
	UpdateRate = 0.2,
	MaxDistance = 500,
	TextSize = 14,
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
}

-- ID TAG CONFIG
Config.IDTag = {
	Enabled = false,
	TextSize = 18,
	UpdateRate = 0.1,
	BobSpeed = 2,
	BobHeight = 0.5,
}

-- RADIO CONFIG
Config.Radio = {
	Enabled = false,
	Volume = 0.5,
	MaxFavorites = 50,
}

-- UI CONFIG
Config.UI = {
	MainWindowSize = UDim2.new(0, 350, 0, 400),
	FloatingButtonSize = UDim2.new(0, 60, 0, 60),
	CornerRadius = UDim.new(0, 12),
	PrimaryColor = Color3.fromRGB(50, 150, 250),
	SecondaryColor = Color3.fromRGB(30, 30, 30),
	TextColor = Color3.fromRGB(255, 255, 255),
	AccentColor = Color3.fromRGB(100, 200, 255),
}

-- GENERAL CONFIG
Config.General = {
	Enabled = true,
	ShowFPS = true,
	MobileOptimized = true,
}

return Config