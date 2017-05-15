local inventories = {}

-- Создание нового инвентаря. Возвращает id инвентаря
function createInventory(size, items)
    if type(size) ~= "number" then
        return false, "bad_size"
    end
    if size < 1 then
        return false, "invalid_size_value"
    end
    if type(items) ~= "table" then
        items = nil
    end

    local inventory = {
        size = size,
        items = items or {}
    }

    for i = 1, #inventories do
        if not inventories[i] then
            inventories[i] = inventory
            inventory.id = i
            return inventory.id
        end
    end

    table.insert(inventories, inventory)
    inventory.id = #inventories
    return inventory.id
end

-- Уничтожает инвентарь с заданным id
function destroyInventory(id)
    if inventories[id] then
        inventories[id] = nil
        return true
    else
        return false
    end
end

function getInventory(id)
    if not inventories[id] then
        return false
    end
    return inventories[id]
end

-- Добавляет вещь item в инвентарь
function addInventoryItem(id, item)
    if type(id) ~= "number" or type(item) ~= "table" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "bad_inventory"
    end

    for i = 1, inventory.size do
        if not inventory.items[i] then
            inventory.items[i] = item
            return true
        end
    end

    return false, "full"
end

-- Удаляет вещь с индексом index из инвентаря
function removeInventoryItem(id, index)
    if type(id) ~= "number" or type(index) ~= "number" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "bad_inventory"
    end
    if inventory.items[index] then
        inventory.items[index] = nil
        return true
    else
        return false
    end
end

-- Перемещает item в инвентаре с позиции index в позицию newIndex
-- Если в позиции newIndex уже есть item, они поменяются местами.
function moveInventoryItem(id, index, newIndex)
    if type(id) ~= "number" or type(index) ~= "number" or type(newIndex) ~= "number" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "bad_inventory"
    end
    if newIndex > inventory.size then
        return false, "invalid_index"
    end
    if not inventory.items[index] then
        return false, "no_item"
    end
    local item2 = inventory.items[newIndex]
    inventory.items[newIndex] = inventory.items[index]
    inventory.items[index] = item2
    return true
end

-- Перемещает вещь из инвентаря 1 в инвентарь 2
-- Если index2 не задан, то вещь будет добавлена в первый свободный слот
function transferInventoryItem(id1, id2, index1, index2)
    if type(id1) ~= "number" or type(id2) ~= "number" or type(index1) ~= "number" then
        return false, "bad_args"
    end
    local inventory1 = getInventory(id1)
    local inventory2 = getInventory(id2)
    if not inventory1 or not inventory2 then
        return false, "bad_inventory"
    end
    local item = inventory1.items[index1]
    if not item then
        return false, "no_item"
    end
    local actualIndex2 = false
    if not index2 then
        index2 = 1
    end
    -- Если место занято
    if inventory2.items[index2] then
        -- Ищем место после желаемого
        for i = math.min(inventory2.size, index2 + 1), inventory2.size do
            if not inventory2.items[i] then
                actualIndex2 = i
                break
            end
        end
        -- Ищем место в начале
        if not actualIndex2 then
            for i = 1, math.max(1, index2 - 1) do
                if not inventory2.items[i] then
                    actualIndex2 = i
                    break
                end
            end
        end
        -- Нет места
        if not actualIndex2 then
            return false, "target_inventory_full"
        end
    else
        actualIndex2 = index2
    end

    inventory1.items[index1] = nil
    inventory2.items[actualIndex2] = item
    return true
end
