local config_file_path = "config/spawn_positions.json"
local spawn_positions = {
	{0, 0, 3} -- Точка спавна по умолчанию
}

local function get_player_sleeper(player)
	if not isElement(player) then return false end
	local sleeper_ped_id = exports["rust-accounts"]:get_data(player, "sleeper_ped_id")
	if not sleeper_ped_id then
		return false
	end
	return getElementByID(sleeper_ped_id)
end

local function despawn_player_sleeper(player)
	if not isElement(player) then return false end
	local ped = get_player_sleeper(player)
	if isElement(ped) then
		destroyElement(ped)
		exports["rust-accounts"]:set_data(player, "sleeper_ped_id", false)
		return true
	end
	return false
end

local function spawn_player_sleeper(player)
	if not isElement(player) then return false end
	local account = exports["rust-accounts"]:get_account(player)
	if not account then
		return false
	end

	-- Удалить существующего педа
	despawn_player_sleeper(player)

	-- Спавн нового педа
	local ped = createPed(player.model, player.position, player.rotation.z, false)
	ped:setID(tostring(account.name))
	exports["rust-accounts"]:set_data(player, "sleeper_ped_id", ped.id)
	-- TODO: Анимация
	-- TODO: Убийство спящего педа
	return ped
end

local function spawn_player(player, spawn_type)
	-- Проврека входных аргументов
	if not isElement(player) then return false end
	if not spawn_type then spawn_type = "random" end

	-- Если игрок уже заспавнен
	if player:getData("spawn_state") then return false end

	-- Спавн игрока
	local sleeper_ped = get_player_sleeper(player)
	if isElement(sleeper_ped) then
		-- Спавн рядом со спящим педом
		player:spawn(sleeper_ped.position, sleeper_ped.rotation)
		player.health = sleeper_ped.health
		-- Удалить педа
		despawn_player_sleeper(player)
	else
		-- TODO: Проверка наличия у игрока дома (кровать или спальный мешок)
		local player_has_home = false
		if spawn_type == "random" or not player_has_home then 
			-- Спавн в случайной точке
			local spawn_position = spawn_positions[math.random(1, #spawn_positions)]
			player:spawn(unpack(spawn_position))
		else
			-- TODO: Спавн в доме
		end
	end
	player:fadeCamera(true)
	player:setCameraTarget()
	player:setData("spawn_state", true)
	return true
end

local function despawn_player(player)
	-- Проврека входных аргументов
	if not isElement(player) then return false end
	-- Если игрок уже заспавнен
	if not player:getData("spawn_state") then return false end

	spawn_player_sleeper(player)

	player:setData("spawn_state", false)
	return true
end

local function spawn_all_players()
	local players_table = getElementsByType("player")
	for i, player in ipairs(players_table) do
		if exports["rust-accounts"]:is_logged_in(player) then
			player:setData("spawn_state", false)
			spawn_player(player)
		end
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

addEvent("rust_player_login", false)
addEventHandler("rust_player_login", root, function ()
	spawn_player(source)
end)

addEventHandler("onPlayerQuit", root, function ()
	despawn_player(source)
end)
