-- Привязка объектов при предпросмотре
SnapRules = {}

local rules = {}
-- rules[что ставится][на что ставится]
rules["Foundation"] = {}
rules["Foundation"]["world"] = {
    offset = {x = 0, y = 0, z = 0.5},
}
rules["Foundation"]["Foundation"] = {
    snap = {
        type = "direction",
        forceAngle = 0,
        distance = PartSizing.Foundation.x,
        gridOffset = function (x, y, z, direction)
            local dx, dy = getDirectionOffset(direction)
            return x + dx * 2, y + dy * 2, z
        end        
    }
}
--------------------------------------------------------------------------------
rules["Wall"] = {}
rules["Wall"]["Foundation"] = {
    snap = {
        type = "direction",
        distance = PartSizing.Foundation.x / 2,
        gridOffset = function (x, y, z, direction)
            local dx, dy = getDirectionOffset(direction)
            return x + dx, y + dy, z
        end
    }
}
rules["Wall"]["Floor"] = rules["Wall"]["Foundation"]
rules["Wall"]["Wall"] = {
    snap = {
        type = "offset",
        offset = {x = 0, y = 0, z = PartSizing.Wall.z / 2 - PartSizing.Floor.z},
        gridOffset = {0, 0, 1},
    }
}
--------------------------------------------------------------------------------
rules["WallWindow"] = rules["Wall"]
rules["WallDoor"] = rules["Wall"]
--------------------------------------------------------------------------------
rules["Floor"] = {}
rules["Floor"]["Foundation"] = {
    snap = {
        type = "offset",
        offset = {x = 0, y = 0, z = PartSizing.Wall.z / 2 - PartSizing.Floor.z},
        gridOffset = {0, 0, 1}
    }
}
rules["Floor"]["Floor"] = rules["Floor"]["Foundation"]
rules["Floor"]["Wall"] = {
    snap = {
        type = "side",
        side = 1,
        distance = PartSizing.Foundation.x / 2,
        offsetZ = PartSizing.Wall.z / 2 - PartSizing.Floor.z,
        gridOffset = function (x, y, z, direction, gridDirection)
            local dx, dy = getDirectionOffset(gridDirection)
            return x - dx, y - dy, z + 1
        end
    }
}
--------------------------------------------------------------------------------
rules["Stairway"] = {}
rules["Stairway"]["Foundation"] = { 
    snap = {
        type = "offset",
        offset = {x = 0, y = 0, z = PartSizing.Stairway.z / 2},
        directionFromRotation = true,
        rotation = 90,
    }   
}
rules["Stairway"]["Floor"] = rules["Stairway"]["Foundation"]


local function sideSnap(snap, object2, x, y, z, rotation)
    -- Позиция, куда смотрит игрок, относительно объекта
    local relativePosition = {
        x = x - object2.position.x,
        y = y - object2.position.y
    }

    -- Массив векторов направлений
    local directionVectors = {}
    if not snap.side then
        snap.side = 0
    end
    directionVectors[1] = getMatrixDirection(object2.matrix, snap.side)
    directionVectors[2] = getMatrixDirection(object2.matrix, getOppositeDirection(snap.side))

    -- Поиск ближайшего направления
    local minDistance, minPoint, minIndex = 9999, nil, -1
    for i, point in ipairs(directionVectors) do
        local distance = getDistanceBetweenPoints2D(point.x, point.y, relativePosition.x, relativePosition.y)
        if distance < minDistance then
            minDistance = distance
            minPoint = point
            minIndex = i
        end
    end
    if not snap.offsetZ then
        snap.offsetZ = 0
    end

    local direction = minIndex - 1
    x = object2.position.x + minPoint.x * snap.distance
    y = object2.position.y + minPoint.y * snap.distance
    z = object2.position.z + snap.offsetZ
    rotation = -90 * direction + 90 + object2.rotation.z
    if snap.forceAngle then
        rotation = object2.rotation.z + snap.forceAngle
    end    
    return x, y, z, rotation, direction - snap.side
end


local function directionSnap(snap, object2, x, y, z, rotation)
    -- Позиция, куда смотрит игрок, относительно объекта
    local relativePosition = {
        x = x - object2.position.x,
        y = y - object2.position.y
    }

    -- Массив векторов направлений
    local directionVectors = {}
    directionVectors[1] = getMatrixDirection(object2.matrix, 0)
    directionVectors[2] = getMatrixDirection(object2.matrix, 1)
    directionVectors[3] = getMatrixDirection(object2.matrix, 2)
    directionVectors[4] = getMatrixDirection(object2.matrix, 3)

    -- Поиск ближайшего направления
    local minDistance, minPoint, minIndex = 9999, nil, -1
    for i, point in ipairs(directionVectors) do
        local distance = getDistanceBetweenPoints2D(point.x, point.y, relativePosition.x, relativePosition.y)
        if distance < minDistance then
            minDistance = distance
            minPoint = point
            minIndex = i
        end
    end
    local direction = minIndex - 1
    x = object2.position.x + minPoint.x * snap.distance
    y = object2.position.y + minPoint.y * snap.distance
    z = object2.position.z
    rotation = -90 * direction + 90 + object2.rotation.z
    if snap.forceAngle then
        rotation = object2.rotation.z + snap.forceAngle
    end
    return x, y, z, rotation, direction
end

local function offsetSnap(snap, object2, x, y, z, rotation)
    x = object2.position.x
    y = object2.position.y 
    z = object2.position.z
    if snap.offset then
        x = x + snap.offset.x
        y = y + snap.offset.y
        z = z + snap.offset.z
    end 
    local direction = 0
    if snap.directionFromRotation then
        direction = getDirectionFromRotation(rotation)
        rotation = object2.rotation.z + 90 * direction
    else
        rotation = object2.rotation.z
    end
    if snap.rotaiton then
        rotation = rotation + snap.rotation
    end
    return x, y, z, rotation, direction
end

function SnapRules.getSnap(object1, partName1, object2, partName2, x, y, z, rotation)
    local rule = rules[partName1][partName2]
    if not rule then
        return false
    end
    local direction = 0
    if rule.offset then
        x = x + rule.offset.x
        y = y + rule.offset.y
        z = z + rule.offset.z
    end
    if rule.rotation then
        rotation = rotation + rule.rotation
    end
    local gx, gy, gz = BuildingClient.getPartGridPosition(object2)
    if rule.snap then
        local snap = rule.snap
        if snap.type == "direction" then
            x, y, z, rotation, direction = directionSnap(snap, object2, x, y, z, rotation)
        elseif snap.type == "offset" then
            x, y, z, rotation, direction = offsetSnap(snap, object2, x, y, z, rotation)
        elseif snap.type == "side" then
            x, y, z, rotation, direction = sideSnap(snap, object2, x, y, z, rotation)
        end

        if type(snap.gridOffset) == "function" then
            gx, gy, gz = snap.gridOffset(gx, gy, gz, direction, BuildingClient.getPartGridDirection(object2))
        elseif type(snap.gridOffset) == "table" then
            local ox, oy, oz = unpack(snap.gridOffset)
            gx = gx + ox
            gy = gy + oy
            gz = gz + oz    
        end        
    end
    return x, y, z, rotation, gx, gy, gz, direction
end

function SnapRules.hasRule(partName1, partName2)
    if not rules[partName1] then
        return false
    end
    return not not rules[partName1][partName2]
end