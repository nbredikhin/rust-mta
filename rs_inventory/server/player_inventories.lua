local player_inventories = {}

function createPlayerInventory(player)
    if not player then
        return false, "OMG U DICK WHAT HAVE U DONE???"
    end
    local size = getDefaultPlayerInventorySize()
    player_inventories[player] = createInventory(size)
    return true
end

function sendInventoryToPlayer(player)
    if player_inventories[player] == nil then
        return false, "does_not_exist"
    end
    local inventory = getInventory(player_inventories[player])
    triggerClientEvent(client, "onInventoryReceived", root, inventory)
end

function movePlayerItem(index1, index2)
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
end
addEvent("movePlayerItem", true)
addEventHandler("movePlayerItem", root, movePlayerItem)

function getPlayerInventory()
    if player_inventories[client] == nil then
        createPlayerInventory(client)
    end
    local inventory_id = player_inventories[client]

    -- Fill with dummy items
    local ak = createInventoryItem("ak47")
    local foundation = createInventoryItem("foundation", 40)
    addInventoryItem(inventory_id, ak)
    addInventoryItem(inventory_id, foundation)

    sendInventoryToPlayer(client)
end
addEvent("getPlayerInventory", true)
addEventHandler("getPlayerInventory", root, getPlayerInventory)