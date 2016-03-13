local config_file_path = "config/spawn_positions.json"
local spawn_positions = {
	{0, 0, 3} -- Точка спавна по умолчанию
}

local function spawn_player(player, spawn_type)
	-- Проврека входных аргументов
	if not isElement(player) then return false end
	if not spawn_type then spawn_type = "random" end

	-- Если игрок уже заспавнен
	if player:getData("spawn_state") then return false end

	-- Спавн игрока
	-- TODO: Проверка на наличие спящего педа
	local sleeper_ped = player:getData("sleeper_ped")
	if isElement(sleeper_ped) then
		-- TODO: Спавн около спящего педа, удаление спящего педа
	else
		-- TODO: Проверка наличия у игрока дома (кровать или спальный мешок)
		local player_has_home = false
		if spawn_type == "random" or not player_has_home then 
			-- Спавн в случайной точке
			local spawn_position = spawn_positions[math.random(1, #spawn_positions)]
			player:spawn(unpack(spawn_position))
		else
			-- TODO: Спавн дома
		end
	end
	player:setData("spawn_state", true)	
	return true
end

local function despawn_player(player)
	-- Проврека входных аргументов
	if not isElement(player) then return false end
	-- Если игрок уже заспавнен
	if not player:getData("spawn_state") then return false end

	-- TODO: Создать спящего педа
	local ped = false
	player:setData("sleeper_ped", ped)

	player:setData("spawn_state", false)
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

addEventHandler("rust_player_login", root, function ()
	spawn_player(source)
end)

addEventHandler("onPlayerQuit", root, function ()
	despawn_player(source)
end)
