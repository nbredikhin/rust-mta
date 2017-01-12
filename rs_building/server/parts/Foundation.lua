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

    return position, getDirectionAngle(direction)
end

function Foundation:getAnchors()
    return {
        {name = "Foundation", x = self.x - 2, y = self.y, z = self.z},
        {name = "Foundation", x = self.x + 2, y = self.y, z = self.z},
        {name = "Foundation", x = self.x, y = self.y - 2, z = self.z},
        {name = "Foundation", x = self.x, y = self.y + 2, z = self.z},

        {name = "Wall", x = self.x - 1, y = self.y, z = self.z, oz = PartSizing.Wall.z / 4, direction = 1},
        {name = "Wall", x = self.x + 1, y = self.y, z = self.z, oz = PartSizing.Wall.z / 4, direction = 3},
        {name = "Wall", x = self.x, y = self.y - 1, z = self.z, oz = PartSizing.Wall.z / 4, direction = 0},
        {name = "Wall", x = self.x, y = self.y + 1, z = self.z, oz = PartSizing.Wall.z / 4, direction = 2},

        {name = "Floor", x = self.x, y = self.y, z = self.z + 1},
    }
end