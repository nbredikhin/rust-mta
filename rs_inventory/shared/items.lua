Items = {}

-- Описывает функции работы с предметами инвентаря
-- Тип описания:
-- name -- имя предмета
-- description -- описание
-- type -- тип (оружие, здание и пр.)
-- stack -- кол-во предметов в одной ячейке (стак)

function getItemById(id)
    if not id then
        return
    end
    return Items[id]
end

function itemsCouldBeStacked(id1, id2)
    local item1 = getItemById(id1)
    local item2 = getItemById(id2)

    return (id1 == id2) and (item1.stack > 1)
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
    return items
end