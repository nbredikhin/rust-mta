local player_inventories = {}

-- Возвращает id инвентаря
function getPlayerInventory(player)
    if not player then
        return false
    end
    return player_inventories[player]
end

-- Создаёт пустой инвентарь и заполняет его стартовыми вещами
function createPlayerInventory(player)
    if not player then
        return false, "OMG U DICK WHAT HAVE U DONE???"
    end
    local size = getDefaultPlayerInventorySize()
    local inventory = createInventory(size)
    player_inventories[player] = inventory

    -- Fill with dummy items
    local ak = createInventoryItem("ak47")
    local foundation = createInventoryItem("foundation", 40)
    addInventoryItem(inventory, ak)
    addInventoryItem(inventory, foundation)    
    return true
end

-- Отправляет игроку его инвентарь
function sendInventoryToPlayer(player)
    local inventory = getPlayerInventory(client)
    if not inventory then
        return false
    end
    local items = getInventoryItems(inventory)
    return triggerClientEvent(client, "onInventoryReceived", root, items)
end

-- Перемещение предметов внутри инвентаря
addEvent("movePlayerItem", true)
addEventHandler("movePlayerItem", root, function (index1, index2)
    if player_inventories[client] == nil then
        return false, "does_not_exist"
    end
    if type(index1) ~= "number" or type(index2) ~= "number" then
        iprint("bad arguments")
        return false, "bad_arguments"
    end

    if not moveInventoryItem(player_inventories[client], index1, index2) then
        return false, "internal_error"
    end
    sendInventoryToPlayer(client)
    return true
end)

-- Возвращает инвентарь игрока
addEvent("getClientInventory", true)
addEventHandler("getClientInventory", root, function ()
    if not getPlayerInventory(client) then
        createPlayerInventory(client)
    end
    sendInventoryToPlayer(client)
end)