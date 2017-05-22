function showPlayerHotbarItem(player, item)
    if not isElement(player) or type(item) ~= "table" then
        return false
    end
    hidePlayerHotbarItem(player)

    local itemDescription = getItemById(item.id)
    if itemDescription.create then
        itemDescription.create(player, item)
    end

    player:setData("hotbar_item_id", item.id)
end

function hidePlayerHotbarItem(player)
    if not isElement(player) then
        return false
    end
    local id = player:getData("hotbar_item_id")
    if not id then
        return false
    end

    local itemDescription = getItemById(id)
    if itemDescription.destroy then
        itemDescription.destroy(player)
    end

    player:removeData("hotbar_item_id")
end

addEvent("showPlayerHotbarSlot", true)
addEventHandler("showPlayerHotbarSlot", root, function (slot)
    if slot then
        local inventory = getPlayerInventory(client)
        if not inventory then
            return
        end
        local item = getInventoryItem(inventory, slot)

        showPlayerHotbarItem(client, item)
    else
        hidePlayerHotbarItem(client)
    end
end)
