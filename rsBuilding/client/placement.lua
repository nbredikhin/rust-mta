local MAX_PLACEMENT_DISTANCE = 15

local screenSize = Vector2(guiGetScreenSize())
local placementScreenPoint = screenSize / 2

local placementParts = {
	Foundation = "foundation",
	Floor = "floor",
	Wall = "wall",
	WallWindow = "wall_window",
	WallDoor = "wall_door",
	Stairway = "stairs"
}
local activePartType
local previewObject = createObject(3000, Vector3())
local highlightShader
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
	else
		return false
	end

	local angle = -math.atan2(cameraPosition.x - lookingAt.x, cameraPosition.y - lookingAt.y) / math.pi * 180 - 90
	local targetPosition = lookingAt
	local targetAngle = angle
	local isPlacementAllowed = true
	if targetObject and targetObject:getData("rsBuilding.type") then
		local targetPartType = targetObject:getData("rsBuilding.type")
		local rulePosition, ruleAngle, ruleAllowed = getPlacementRule(activePartType, targetPartType, targetObject, targetPosition, targetAngle)
		if rulePosition then
			targetPosition = rulePosition
			targetAngle = ruleAngle
			if ruleAllowed == false then
				isPlacementAllowed = false
			end
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
	if highlightShader then
		local colorMul = math.sin(getTickCount() / 100)
		if not isPlacementAllowed then
			highlightShader:setValue("gColor", {0.8 + 0.2 * colorMul, 0, 0})
		else
			highlightShader:setValue("gColor", {0, 0.8 + 0.2 * colorMul, 0})
		end
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

addEventHandler("onClientResourceStart", resourceRoot, function ()
	highlightShader = DxShader("assets/shaders/highlight.fx")
	highlightShader:applyToWorldTexture("*", previewObject)
	highlightShader:setValue("gColor", {0, 255, 0, 150})
end)

addCommandHandler("part", function (command, partName)
	setActivePartType(partName)
end)

bindKey("mouse2", "down", function ()
	local isPlacementAllowed, position, angle = getPlacementPosition()
	if isPlacementAllowed then
		triggerServerEvent("rsBuilding.build", resourceRoot)
	end
end)

setActivePartType("Foundation")