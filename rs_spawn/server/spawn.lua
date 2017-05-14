-- Возвращает случайную точку спавна в виде трёх переменных
local function getRandomSpawnPosition()
    if #SpawnPositions == 0 then
        return 0, 0, 0
    elseif #SpawnPositions == 1 then
        return unpack(SpawnPositions[1])
    else
        return unpack(SpawnPositions[math.random(1, #SpawnPositions)])
    end
end

-- Спавн игрока player в случайной точке
local function spawnPlayerAtRandomPosition(player)
    local x, y, z = getRandomSpawnPosition()
    local rotation = 0
    local skin = math.random(1, 288)
    player:spawn(x, y, z, rotation, skin)
end

-- Спавн игрока
function respawnPlayer(player)
    -- TODO: Спавн в зависимости от наличия кровати, спящего педа и т. д.
    spawnPlayerAtRandomPosition(player)

    -- TODO: Анимация спавна - перенести на клиент
    fadeCamera(player, true)
    setCameraTarget(player, player)
end

addCommandHandler("spawn", respawnPlayer)

addEventHandler("onResourceStart", resourceRoot, function ()
    -- Респавн всех игроков после запуска мода
    for i, player in ipairs(getElementsByType("player")) do
        respawnPlayer(player)
    end
end)

addEventHandler("onPlayerJoin", root, function ()
    respawnPlayer(source)
end)

addEventHandler("onPlayerWasted", root, function ()
    fadeCamera(source, false, 2)
    setTimer(respawnPlayer, 3000, 1, source)
end)
