local config_file_path = "config/spawn_positions.json"
local spawn_positions = {
	{0, 0, 3}
}

local function spawn_player(player)
	-- Проврека входных аргументов
	if not isElement(player) then return false end
	-- Если игрок уже заспавнен
	if player:getData("spawn_state") then return false end
	-- Спавн игрока
	local spawn_position = spawn_positions[math.random(1, #spawn_positions)]
	player:spawn(unpack(spawn_position))
	player:setData("spawn_state", true)
	return true
end

local function spawn_all_players()
	local players_table = getElementsByType("player")
	for i, player in ipairs(players_table) do
		player:setData("spawn_state", false)
		spawn_player(player)
	end
	return true
end

addEventHandler("onResourceStart", resourceRoot, function ()
	-- Прочитать конфиг
	local result = pcall(function ()
		local config_file = fileOpen(config_file_path)
		local config_json = fileRead(config_file, fileGetSize(config_file))
		fileClose(config_file)
		spawn_positions = fromJSON(config_json)
	end)
	if not result then
		outputDebugString("Не удалось прочитать список точек спавна")
	end
	-- Заспавнить всех игроков
	spawn_all_players()
end)
