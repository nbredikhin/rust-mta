InventoryClient = {}
InventoryClient.items = {
    {name = "ak47", count = 1},
    nil,
    nil,
    {name = "foundation", count = 50},
    nil,
    nil,
    {name = "foundation", count = 50},
    {name = "foundation", count = 50},
    {name = "foundation", count = 50},
    {name = "foundation", count = 26},
}


function InventoryClient.getItem(slotId)
    if not slotId then
        return
    end
    return InventoryClient.items[slotId]
end
