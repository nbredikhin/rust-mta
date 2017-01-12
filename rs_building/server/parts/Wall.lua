Wall = class("Wall", Part)

function Wall:isPlacementAllowed(x, y, z, direction)
    local isAllowed = false
    local dx, dy = getDirectionOffset(direction)
    isAllowed = isAllowed or self.building:checkPart(x + dx, y + dy, z, nil, "Foundation")
    isAllowed = isAllowed or self.building:checkPart(x + dx, y + dy, z, nil, "Floor")

    dx, dy = getDirectionOffset(getOppositeDirection(direction))
    isAllowed = isAllowed or self.building:checkPart(x + dx, y + dy, z, nil, "Foundation")
    isAllowed = isAllowed or self.building:checkPart(x + dx, y + dy, z, nil, "Floor")

    return isAllowed    
end

function Wall:calculatePosition(x, y, z, direction)
    local position = Vector3()
    position.x = x * PartSizing.Floor.x / 2
    position.y = y * PartSizing.Floor.y / 2 
    position.z = z * PartSizing.Wall.z / 2

    return position, getDirectionAngle(direction) + 90
end