InventoryClient = {}

local HOTBAR_SLOTS_COUNT = 6
local currentHotbarSlot = nil

InventoryClient.items = {
}

function InventoryClient.getItem(slotId)
    if not slotId then
        return
    end
    return InventoryClient.items[slotId]
end

function InventoryClient.getActiveHotbarSlot()
    return currentHotbarSlot
end

function InventoryClient.showHotbarSlot(slotId)
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

function InventoryClient.moveItems(slotIdFrom, slotIdTo)
    if type(slotIdTo) ~= "number" or type(slotIdFrom) ~= "number" then
        return false, "bad_arguments"
    end

    triggerServerEvent("movePlayerItem", root, slotIdFrom, slotIdTo)

    return true
end

addEvent("onInventoryReceived", true)
addEventHandler("onInventoryReceived", root, function(inventory)
    InventoryClient.items = inventory.items
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    for i = 1, HOTBAR_SLOTS_COUNT do
        bindKey(tostring(i), "down", InventoryClient.showHotbarSlot, i)
    end

    triggerServerEvent("getPlayerInventory", root)
end)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function (previousSlot)
    if previousSlot ~= 0 then
        cancelEvent()
    end
end)
