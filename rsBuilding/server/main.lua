local TEST_BUILDING_POS = Vector3 { x = -1502.044, y = -218.703, z = 14.148 }

local baseFoundation = Foundation:new()
local building1 = Building:new(TEST_BUILDING_POS, baseFoundation)

local testFoundation = Foundation:new()
outputChatBox(tostring(building1:addPart(testFoundation, -1, 0, 0)))
local testFoundation2 = Foundation:new()
outputChatBox(tostring(building1:addPart(testFoundation2, 1, 0, 1)))