local TEST_BUILDING_POS = Vector3 { x = -1502.044, y = -218.703, z = 14.148 }

outputChatBox(" ")
local baseFoundation = Foundation:new()
local building1 = Building:new(TEST_BUILDING_POS, baseFoundation)

local testFoundation = Foundation:new()
outputChatBox(tostring(building1:addPart(testFoundation, 1, 0, 0, 1)))

local testWall = Wall:new()
outputChatBox("Wall 1: %s" % tostring(building1:addPart(testWall, 1, 0, 0, getDirectionFromName("right"))))
local testWall2 = Wall:new()
outputChatBox("Wall 2: %s" % tostring(building1:addPart(testWall2, 0, 0, 0, getDirectionFromName("left"))))

local testFloor = Floor:new()
outputChatBox("Floor 1: %s" % tostring(building1:addPart(testFloor, 0, 0, 1)))