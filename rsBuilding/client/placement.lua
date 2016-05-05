local MAX_PLACEMENT_DISTANCE = 15

local screenSize = Vector2(guiGetScreenSize())
local placementScreenPoint = screenSize / 2

local placementParts = {
	Foundation = "foundation",
	Floor = "floor",
	Wall = "wall",
	WallWindow = "wall_window",
	WallDoor = "wall_door"
}
local activePartType
local previewObject = createObject(3000, Vector3())
previewObject:setCollisionsEnabled(false)

local function getPlacementPosition()
	if not activePartType then
		return false
	end

	local lookingAt = Vector3(getWorldFromScreenPosition(placementScreenPoint.x, placementScreenPoint.y, MAX_PLACEMENT_DISTANCE))
	local cameraPosition = Vector3(getCameraMatrix())
	local isHit, wx, wy, wz, targetObject = processLineOfSight(cameraPosition, lookingAt, true, false, false)
	if wx and wy then
		lookingAt = Vector3(wx, wy, wz)
	end

	local angle = -math.atan2(cameraPosition.x - lookingAt.x, cameraPosition.y - lookingAt.y) / math.pi * 180
	local targetPosition = lookingAt
	local targetAngle = angle
	local isPlacementAllowed = true
	if targetObject and targetObject:getData("rsBuilding.type") then
		local targetPartType = targetObject:getData("rsBuilding.type")
		local rulePosition, ruleAngle = getPlacementRule(activePartType, targetPartType, targetObject, targetPosition, targetAngle)
		if rulePosition then
			targetPosition = rulePosition
			targetAngle = ruleAngle
		else
			isPlacementAllowed = false
		end
	else
		local rulePosition, ruleAngle = getPlacementRule(activePartType, "World", false, targetPosition, targetAngle)
		if rulePosition then
			targetPosition = rulePosition
			targetAngle = ruleAngle
		else
			isPlacementAllowed = false
		end
	end
	return isPlacementAllowed, targetPosition, targetAngle
end

addEventHandler("onClientRender", root, function ()
	if not activePartType then
		return
	end	

	local isPlacementAllowed, position, angle = getPlacementPosition()
	if not position then
		previewObject.position = Vector3(0, 0, -50)
		return
	end
	previewObject.position = position
	previewObject.rotation = Vector3(0, 0, angle)
	if not isPlacementAllowed then
		previewObject.alpha = 150
	else
		previewObject.alpha = 255
	end
end)

local function setActivePartType(partType)
	if not partType then
		return false
	end
	if not placementParts[partType] then
		return false
	end
	local model = exports.rsModels:getModelFromName(placementParts[partType])
	if not model then
		return false
	end
	previewObject.model = model
	activePartType = partType
	outputDebugString("Active part type: %q" % partType)
	return true
end

addCommandHandler("place", function (command, partName)
	setActivePartType(partName)
end)

setActivePartType("Foundation")