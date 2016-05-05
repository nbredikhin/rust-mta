local TEST_BUILDING_POS = Vector3 { x = -1234.372, y = -163.901, z = 14.148 }
local TEST_BUILDING_ROT = 0

outputChatBox(" ")
local baseFoundation = Foundation:new()
building1 = Building:new(TEST_BUILDING_POS, TEST_BUILDING_ROT, baseFoundation)

local testFoundation = Foundation:new()
outputChatBox(tostring(building1:addPart(testFoundation, 1, 0, 0, 0)))

local testWall = WallDoor:new()
outputChatBox("Wall 1: %s" % tostring(building1:addPart(testWall, 1, 0, 0, getDirectionFromName("right"))))
local testWall2 = Wall:new()
outputChatBox("Wall 2: %s" % tostring(building1:addPart(testWall2, 1, 0, 0, 2)))
local testFloor = Floor:new()
outputChatBox("Floor 1: %s" % tostring(building1:addPart(testFloor, 1, 0, 1)))

local testStairway = Stairway:new()
outputChatBox("Stairway 1: %s" % tostring(building1:addPart(testStairway, 0, 0, 0, 2)))

local testWall3 = Wall:new()
outputChatBox("Wall 3: %s" % tostring(building1:addPart(testWall3, 0, 0, 0, 2)))
local testWall4 = WallWindow:new()
outputChatBox("Wall 4: %s" % tostring(building1:addPart(testWall4, 0, 0, 1, 6)))
local testWall5 = Wall:new()
outputChatBox("Wall 5: %s" % tostring(building1:addPart(testWall5, 0, 0, 1, 1)))

local testStairway2 = Stairway:new()
outputChatBox("Stairway 2: %s" % tostring(building1:addPart(testStairway2, 1, 0, 1, 4)))

local testFloor2 = Floor:new()
outputChatBox("Floor 2: %s" % tostring(building1:addPart(testFloor2, 0, 0, 2)))

local testStairway3 = Stairway:new()
outputChatBox("Stairway 3: %s" % tostring(building1:addPart(testStairway3, 0, 0, 2, 2)))
local testWall6 = Wall:new()
outputChatBox("Wall 6: %s" % tostring(building1:addPart(testWall6, 0, 0, 2, 2)))
local testWall7 = Wall:new()
outputChatBox("Wall 6: %s" % tostring(building1:addPart(testWall7, 0, 0, 2, 3)))