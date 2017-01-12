local directionNames = {
    "forward", "right", "backward", "left"
}

local directions = {
    ["forward"]     = 0,
    ["right"]       = 1,
    ["backward"]    = 2,
    ["left"]        = 3,
}

function getOppositeDirection(direction)
    if type(direction) ~= "number" then
        return false
    end
    return (direction + 2) % 4
end

function rotateDirectionRight(direction)
    if type(direction) ~= "number" then
        return false
    end
    return (direction + 1) % 4
end

function rotateDirectionLeft(direction)
    if type(direction) ~= "number" then
        return false
    end
    return (direction - 1) % 4
end

function getDirectionName(direction)
    if type(direction) ~= "number" then
        return false
    end
    return directionNames[direction]
end

function getDirectionFromName(name)
    return directions[name]
end

-- В градусах
function getDirectionFromAngle(angle)
    local direction = math.floor(angle / 90)
    return direction % 4
end

function getDirectionAngle(direction)
    if type(direction) ~= "number" then
        return false
    end    
    return direction * 90
end

function getDirectionOffset(direction)
    if type(direction) ~= "number" then
        return false
    end
    direction = direction % 4
    if direction == 0 then
        return 0, 1
    elseif direction == 1 then
        return 1, 0
    elseif direction == 2 then
        return 0, -1
    elseif direction == 3 then
        return -1, 0
    end
    return false
end

function getMatrixDirection(matrix, direction)
    if not matrix or type(direction) ~= "number" then
        return false
    end
    direction = direction % 4
    if direction == 0 then
        return matrix.forward
    elseif direction == 1 then
        return matrix.right
    elseif direction == 2 then
        return -matrix.forward
    elseif direction == 3 then
        return -matrix.right
    end
end