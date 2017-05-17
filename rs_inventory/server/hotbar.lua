function showPlayerHotbarItem(player, item)
    if not isElement(player) or type(item) ~= "table" then
        return false
    end
    hidePlayerHotbarItem(player)
    giveWeapon(player, 30, 30, true)
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
    takeAllWeapons(player)
    player:removeData("hotbar_item_id")
end

addCommandHandler("hotbar", function (player)
    if player:getData("hotbar_item_id") then
        hidePlayerHotbarItem(player)
    else
        showPlayerHotbarItem(player, { id = "ak47", count = 1 })
    end
end)

addEvent("showPlayerHotbarSlot", true)
addEventHandler("showPlayerHotbarSlot", root, function (slot)
    if slot then
        -- TODO: Получить item в слоте
        local item = { id = "ak47", count = 1 }

        showPlayerHotbarItem(client, item)
    else
        hidePlayerHotbarItem(client)
    end
end)
