function rotateVector(v, angle)
    local theta = math.rad(angle)
    local cs = math.cos(theta)
    local sn = math.sin(theta)
    return Vector3(v.x * cs - v.y * sn, v.x * sn + v.y * cs, v.z)
end

function getDistanceSquared2D(x1, y1, x2, y2)
    return (x1 - x2) * (x1 - x2) - (y1 - y2) * (y1 - y2)
end