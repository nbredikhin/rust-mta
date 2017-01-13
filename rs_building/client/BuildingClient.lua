BuildingClient = {}

function BuildingClient.addPart(building, name, x, y, z, direction)
    if not building then
        building = resourceRoot
    end
    triggerServerEvent("buildPart", building, name, x, y, z, direction)
end

function BuildingClient.isBuilding(building)
    if not isElement(building) then
        return false
    end
    return not not building:getData("isBuilding")
end

function BuildingClient.getPartBuilding(part)
    if not BuildingClient.isBuilding(part) then
        return false
    end
    if BuildingClient.isBuilding(part.parent) then
        return part.parent
    else
        return false
    end
end

function BuildingClient.getPartName(part)
    if not BuildingClient.isBuilding(part) then
        return false
    end
    return part:getData("name")
end

function BuildingClient.getPartGridPosition(part)
    if not BuildingClient.isBuilding(part) then
        return false
    end
    local position = part:getData("gridPosition")
    if not position then
        return false
    end
    return unpack(position)
end

function BuildingClient.getPartGridDirection(part)
    if not BuildingClient.isBuilding(part) then
        return false
    end
    return part:getData("direction")
end