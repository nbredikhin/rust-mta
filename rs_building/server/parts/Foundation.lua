Foundation = class("Foundation", Part)

function Foundation:isPlacementAllowed(x, y, z, direction)
    -- Foundation можно создать только если с хотя бы одной стороны находится Foundation
    local isAllowed = false
    isAllowed = isAllowed or self.building:checkPart(x - 2, y, z, nil, "Foundation")
    isAllowed = isAllowed or self.building:checkPart(x + 2, y, z, nil, "Foundation")
    isAllowed = isAllowed or self.building:checkPart(x, y - 2, z, nil, "Foundation")
    isAllowed = isAllowed or self.building:checkPart(x, y + 2, z, nil, "Foundation")
    return isAllowed
end

function Foundation:calculatePosition(x, y, z, direction)
    local position = Vector3()
    position.x = x * PartSizing.Foundation.x / 2
    position.y = y * PartSizing.Foundation.y / 2
    position.z = z * PartSizing.Foundation.z / 2

    return position, 0
end