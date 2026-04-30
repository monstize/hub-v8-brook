--[[
	Brookhaven Hub v8 - Favorites Module
	Gerenciamento de músicas favoritas
]]

local Favorites = {}

-- Tabela de favoritas
local FavoritesList = {}

-- Carregar favoritas salvas (se existirem)
local function LoadFavorites()
	-- Aqui você pode adicionar lógica para carregar de SaveGame ou similar
	-- Por enquanto, usaremos uma tabela em memória
	end

--[[
	Adiciona uma música às favoritas
	@param musicName: Nome da música
	@param musicID: ID da música
]]
function Favorites.AddFavorite(musicName, musicID)
	if not FavoritesList[musicName] then
		FavoritesList[musicName] = musicID
		print("⭐ Favorite added: " .. musicName .. " (" .. musicID .. ")")
	else
		print("⚠️  Already in favorites: " .. musicName)
	end
end

--[[
	Remove uma música das favoritas
	@param musicName: Nome da música
]]
function Favorites.RemoveFavorite(musicName)
	if FavoritesList[musicName] then
		FavoritesList[musicName] = nil
		print("❌ Favorite removed: " .. musicName)
	else
		print("⚠️  Not found in favorites: " .. musicName)
	end
end

--[[
	Retorna todas as favoritas
	@return table
]]
function Favorites.GetFavorites()
	return FavoritesList
end

--[[
	Retorna uma favorita específica
	@param musicName: Nome da música
	@return ID da música ou nil
]]
function Favorites.GetFavorite(musicName)
	return FavoritesList[musicName]
end

--[[
	Limpa todas as favoritas
]]
function Favorites.ClearAll()
	FavoritesList = {}
	print("🗑️  All favorites cleared")
end

--[[
	Retorna a quantidade de favoritas
	@return number
]]
function Favorites.GetCount()
	local count = 0
	for _ in pairs(FavoritesList) do
		count = count + 1
	end
	return count
end

-- Inicializar
LoadFavorites()

return Favorites