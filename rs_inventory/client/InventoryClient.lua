InventoryClient = {}
InventoryClient.items = {
    {name = "AK47", count = 1},
    false,
    false,
    {name = "Foundation", count = 50},
    false,
    false,
    {name = "Foundation", count = 50},
    {name = "Foundation", count = 50},
    {name = "Foundation", count = 50},
    {name = "Foundation", count = 26},
}


function InventoryClient.getItem(slotId)
    if not slotId then
        return
    end
    return InventoryClient.items[slotId]
end