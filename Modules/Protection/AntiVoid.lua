--[[
	Brookhaven Hub v8 - AntiVoid Module
	Protege o jogador de quedas no vazio
]]

local AntiVoid = {}

local Services = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Services"))
local State = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("State"))
local Utils = require(script.Parent.Parent.Parent:FindFirstChild("Core"):FindFirstChild("Utils"))
local Config = require(script.Parent.Parent.Parent:FindFirstChild("Config"))

-- Estado do módulo
local AntiVoidState = {
	Enabled = false,
	LastSafePosition = nil,
	LastSafeTime = 0,
}

--[[
	Inicia o AntiVoid
]]
function AntiVoid.Enable()
	if AntiVoidState.Enabled then return end
	
	local Root = Services.LocalRoot()
	if not Root then
		warn("Character not found")
		return false
	end
	
	-- Salva posição inicial
	AntiVoidState.LastSafePosition = Root.Position
	AntiVoidState.LastSafeTime = tick()
	AntiVoidState.Enabled = true
	State.EnableModule("AntiVoid")
	
	-- Loop de verificação
	local connection = Services.RunService().Heartbeat:Connect(function()
		if not AntiVoidState.Enabled then
			connection:Disconnect()
			return
		end
		
		local root = Services.LocalRoot()
		if not root then
			AntiVoid.Disable()
			return
		end
		
		-- Verifica se está no vazio
		if root.Position.Y < Config.AntiVoid.VoidLevel then
			-- Teleporta para posição segura
			local targetPos = AntiVoidState.LastSafePosition + Vector3.new(0, 5, 0)
			root.CFrame = CFrame.new(targetPos)
			print("🛡️ AntiVoid: Teleported to safe position")
		else
			-- Atualiza posição segura periodicamente
			if tick() - AntiVoidState.LastSafeTime > 1 then
				AntiVoidState.LastSafePosition = root.Position
				AntiVoidState.LastSafeTime = tick()
			end
		end
	end)
	
	State.AddConnection("AntiVoid", connection)
	print("✅ AntiVoid enabled")
	return true
end

--[[
	Desabilita o AntiVoid
]]
function AntiVoid.Disable()
	if not AntiVoidState.Enabled then return end
	
	AntiVoidState.Enabled = false
	AntiVoidState.LastSafePosition = nil
	State.DisableModule("AntiVoid")
	print("🛑 AntiVoid disabled")
end

--[[
	Muda o nível de vazio
	@param level: Novo nível Y
]]
function AntiVoid.SetVoidLevel(level)
	Config.AntiVoid.VoidLevel = level
end

--[[
	Retorna se AntiVoid está habilitado
	@return boolean
]]
function AntiVoid.IsEnabled()
	return AntiVoidState.Enabled
end

return AntiVoid