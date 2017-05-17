local inventories = {}

-- Айтем в инвентаре, структура:
-- id -- айди для получения инфы из коллекции айтемов
-- count -- количество предметов в ячейке
-- instance -- экземпляр того объекта, который представляет айтем

-- Создает предмет в инвентаре
function createInventoryItem(itemId, count, instance)
    if getItemById(itemId) == nil then
        return nil
    end

    if not count then
        count = 1
    end

    if not instance then
        iprint("Creating inventory item instance")
        -- TODO: create instance
    end

    local item = {
        id       = itemId,
        count    = count,
        instance = instance
    }

    return item
end

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

function transferItemCount(item1, item2)
    if type(item1) ~= "table" or type(item2) ~= "table" then
        return false, "bad_args"
    end

    if not itemsCouldBeStacked(item1.id, item2.id) then
        return false, "cannot_be_stacked"
    end

    local stackSize = getItemById(item1.id).stack
    local diff = math.min(stackSize - item2.count, item1.count)

    if not diff then
        return true
    end

    item1.count = item1.count - diff
    item2.count = stackSize

    return true
end

function getIndexInInventoryByItem(id, item)
    if type(id) ~= "number" or type(item) ~= "table" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "no_inventory"
    end

     for i = 1, inventory.size do
        if inventory.items[i] == item then
            return i
        end
    end

    return false, "not_found"
end

-- Добавляет вещь item в инвентарь
function addInventoryItem(id, item)
    if type(id) ~= "number" or type(item) ~= "table" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "no_inventory"
    end

    for i = 1, inventory.size do
        if not inventory.items[i] then
            inventory.items[i] = item
            return true
        else
            if transferItemCount(item, inventory.items[i]) and item.count == 0 then
              return true
            end
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
        return false, "no_inventory"
    end
    if inventory.items[index] then
        inventory.items[index] = nil
        return true
    else
        return false
    end
end

-- Перемещает item в инвентаре с позиции index в позицию newIndex
-- Если в позиции newIndex уже есть item, они поменяются местами, если они
-- разного типа или не стакаются, или перекладывает предметы из одного в другой
function moveInventoryItem(id, index, newIndex)
    if type(id) ~= "number" or type(index) ~= "number" or type(newIndex) ~= "number" then
        return false, "bad_args"
    end
    local inventory = getInventory(id)
    if not inventory then
        return false, "no_inventory"
    end
    if newIndex > inventory.size then
        return false, "invalid_index"
    end
    if not inventory.items[index] then
        return false, "no_item"
    end

    local item1 = inventory.items[index]
    local item2 = inventory.items[newIndex]

    if not transferItemCount(item1, item2) then
        inventory.items[index], inventory.items[newIndex] = item2, item1
    else
        if item1.count == 0 then
            removeInventoryItem(id, getIndexInInventoryByItem(id, item1))
        end
    end

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
        return false, "no_inventory"
    end
    local item1 = inventory1.items[index1]

    if not item1 then
        return false, "no_item"
    end
    local actualIndex2 = false
    if not index2 then
        index2 = 1
    end
    local item2 = inventory2.items[index2]
    -- Если место занято
    if item2 then
        -- Попробуем стакнуть или поменять местами
        if not transferItemCount(item1, item2) then
            inventory1.items[index1], inventory2.items[index2] = item2, item1
        else
            if item1.count == 0 then
                removeInventoryItem(id1, getIndexInInventoryByItem(id1, item1))
            end
        end
        return true
    else
        actualIndex2 = index2
    end


    inventory1.items[index1] = nil
    inventory2.items[actualIndex2] = item1
    return true
end