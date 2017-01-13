setTimer(function()
    local building = Building:new(Vector3({ x = 1390.790, y = 1594.151, z = 10.813 }), 0)

    building:addPart("Foundation", 2, 0, 0, 1)
    -- building:addPart("Foundation", 2, 2, 0, 0)

    -- building:addPart("Wall", -1, 0, 0, 1)
    -- building:addPart("Wall", 0, 1, 0, 0)
    -- building:addPart("Wall", 0, -1, 0, 2)

    -- building:addPart("Wall", 2, -1, 0, 2)
    -- building:addPart("Wall", 3, 0, 0, 3)

    -- building:addPart("Floor", 0, 0, 1, 1)

    -- building:addPart("Wall", -1, 0, 1, 1)
    -- building:addPart("Wall", 0, 1, 1, 0)    
end, 100, 1)