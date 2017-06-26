local HOTBAR_SLOTS_COUNT = 6
local currentHotbarSlot = nil

local local_inventory = {}

function getInventory()
    return local_inventory
end

function getItem(slotId)
    if not slotId then
        return
    end
    if not local_inventory.items then
        local_inventory.items = {}
    end
    return local_inventory.items[slotId]
end

function getActiveHotbarSlot()
    return currentHotbarSlot
end

function showHotbarSlot(slotId)
    slotId = tonumber(slotId)
    if not slotId or slotId > HOTBAR_SLOTS_COUNT or slotId < 1 then
        return
    end
    if currentHotbarSlot and currentHotbarSlot == slotId then
        triggerServerEvent("showPlayerHotbarSlot", localPlayer)
        currentHotbarSlot = nil
    else
        triggerServerEvent("showPlayerHotbarSlot", localPlayer, slotId)
        currentHotbarSlot = slotId
    end
end

function moveItems(slotIdFrom, slotIdTo)
    if type(slotIdTo) ~= "number" or type(slotIdFrom) ~= "number" then
        return false, "bad_arguments"
    end

    local_inventory.items[slotIdTo], local_inventory.items[slotIdFrom] = local_inventory.items[slotIdFrom], local_inventory.items[slotIdTo]
    triggerServerEvent("movePlayerItem", resourceRoot, slotIdFrom, slotIdTo)
    return true
end

addEvent("onInventoryReceived", true)
addEventHandler("onInventoryReceived", resourceRoot, function(inventory)
    local_inventory = inventory
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    for i = 1, HOTBAR_SLOTS_COUNT do
        bindKey(tostring(i), "down", showHotbarSlot, i)
    end

    triggerServerEvent("getClientInventory", root)
end)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function (previousSlot)
    if previousSlot ~= 0 then
        cancelEvent()
    end
end)
