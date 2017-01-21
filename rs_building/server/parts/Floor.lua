Floor = class("Floor", Part)

function Floor:isPlacementAllowed(x, y, z, direction)
    local isAllowed = false
    isAllowed = isAllowed or self.building:checkPart(x - 2, y, z, nil, "Floor")
    isAllowed = isAllowed or self.building:checkPart(x + 2, y, z, nil, "Floor")
    isAllowed = isAllowed or self.building:checkPart(x, y - 2, z, nil, "Floor")
    isAllowed = isAllowed or self.building:checkPart(x, y + 2, z, nil, "Floor")

    local wallsCount = 0
    for i = 1, 4 do 
        local dx, dy = getDirectionOffset(i - 1)
        if self.building:checkPart(x + dx, y + dy, z - 1, nil, nil, Wall) then
            wallsCount = wallsCount + 1
        end
    end
    isAllowed = isAllowed or wallsCount >= 2
    return isAllowed
end

function Floor:calculatePosition(x, y, z, direction)
    local position = Vector3()
    position.x = x * PartSizing.Floor.x / 2
    position.y = y * PartSizing.Floor.y / 2
    position.z = z * (PartSizing.Wall.z) / 2 - PartSizing.Floor.z

    return position, 0
end