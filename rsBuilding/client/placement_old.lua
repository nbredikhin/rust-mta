local screenWidth, screenHeight = guiGetScreenSize()
local screenPoint = Vector2(screenWidth / 2, screenHeight / 2)
local maxPlacementDistance = 15

local placingObjectType
local previewObject = createObject(3000, Vector3())
previewObject:setCollisionsEnabled(false)
previewObject.scale = 0.9

local function getPlacementPosition()
	if not placingObjectType or not snapRules[placingObjectType] then
		return false, Vector3(), 0
	end
	local info
	local lookingAtPosition = Vector3(getWorldFromScreenPosition(screenPoint.x, screenPoint.y, maxPlacementDistance))
	local cameraPosition = Vector3(getCameraMatrix())
	local isHit, wx, wy, wz, hitElement = processLineOfSight(cameraPosition.x, cameraPosition.y, cameraPosition.z, lookingAtPosition.x, lookingAtPosition.y, lookingAtPosition.z, true, false, false)
	local worldPosition = Vector3(wx, wy, wz)

	-- Если точка, куда пытаются поставить объект, находится слишком далеко
	if not wx or not wy then 
		return false, Vector3(0, 0, -100), 0
	end

	if placingObjectType == "foundation" then
		worldPosition = worldPosition + Vector3(0, 0, 0.3)
	end

	local angle = -math.atan2(cameraPosition.x - wx, cameraPosition.y - wy) / math.pi * 180
	local canPlace = true
	local isWorld = false
	if isElement(hitElement) then
		local hitObjectType = hitElement:getData("rust-object-type")
		if hitObjectType then
			if snapRules[placingObjectType][hitObjectType] then
				if type(snapRules[placingObjectType][hitObjectType] == "function") then
					local resultPosition, resultAngle, resultInfo = snapRules[placingObjectType][hitObjectType](hitElement, worldPosition, angle)
					if resultPosition then
						worldPosition = resultPosition
						angle = resultAngle
						info = resultInfo
					else
						canPlace = false
					end
				end
			else
				canPlace = false
			end
		else
			canPlace = false
		end
	else
		if snapRules[placingObjectType]["world"] then
			canPlace = snapRules[placingObjectType]["world"](worldPosition, angle)
			isWorld = true
		else
			canPlace = false
		end
	end
	return canPlace, worldPosition, angle, hitElement, info, isWorld
end

local function drawPlacingPreview(position, rotation, canPlace, world)
	local color = tocolor(255, 0, 0)
	if canPlace then
		color = tocolor(0, 255, 0)
		if world then
			color = tocolor(60, 120, 255)
		end
	end
	--previewObject.position = position
	previewObject.rotation = Vector3(0 ,0, rotation + 90)
	previews:drawObject(placingObjectType, position.x, position.y, position.z, rotation, color)
end

addEventHandler("onClientRender", root,
	function()
		local canPlace, worldPosition, rotation, _, _, isWorld = getPlacementPosition()
		drawPlacingPreview(worldPosition, rotation, canPlace, isWorld)
	end
)

local function getFoundationPos(object, base)
	local x1, y1, z1 = getElementPosition(base)
	local x2, y2, z2 = getElementPosition(object)

	local x = math.floor((x2 - x1) / ModelsSizes.foundation.width)
	local y = math.floor((y2 - y1) / ModelsSizes.foundation.width)

	return {x, y}
end

local function placeObject()
	local canPlace, worldPosition, rotation, targetObject, direction = getPlacementPosition()
	triggerServerEvent("rsBuilding.addPart", resourceRoot, placingObjectType, {worldPosition.x, worldPosition.y, worldPosition.z}, rotation, targetObject, covertDirection(direction))
end

addEventHandler("onClientKey", root,
	function(button, isDown)
		if button == "mouse2" and isDown then
			placeObject()
		end
	end
)

addCommandHandler("po",
	function(cmd, name)
		if not name then
			placingObjectType = ""
			outputChatBox("Введите название объекта")
			return
		end
		local model = exports.rsModels:getModelFromName(name)
		if model then
			previewObject.model = model
			placingObjectType = name
			outputChatBox("Выбран объект: " .. tostring(name))
		else
			outputChatBox("Невозможно выбрать объект: " .. tostring(name))
		end
	end
)