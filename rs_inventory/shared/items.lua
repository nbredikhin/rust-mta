Items = {}

function getItemFromName(name)
    if not name then
        return
    end
    return Items[name]
end

function getAllItems()
    local items = {}
    for name, item in pairs(Items) do
        table.insert(items, item)
    end
    return items
end

function getItemsByType(typeName)
    if not typeName then
        return {}
    end
    local items = {}
    for name, item in pairs(Items) do
        if item.type == typeName then
            table.insert(items, item)
        end
    end
    return itemms
end