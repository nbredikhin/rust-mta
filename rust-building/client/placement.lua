local screenWidth, screenHeight = guiGetScreenSize()
local screenPoint = Vector2(screenWidth / 2, screenHeight / 2)
local maxPlacementDistance = 15

local placingObjectType = "foundation"

local function getPlacementPosition()
	if not placingObjectType or not snapRules[placingObjectType] then
		return false, Vector3(), 0
	end
	local lookingAtPosition = Vector3(getWorldFromScreenPosition(screenPoint.x, screenPoint.y, maxPlacementDistance))
	local cameraPosition = Vector3(getCameraMatrix())
	local isHit, wx, wy, wz, hitElement = processLineOfSight(cameraPosition.x, cameraPosition.y, cameraPosition.z, lookingAtPosition.x, lookingAtPosition.y, lookingAtPosition.z, true, false, false)
	local worldPosition = Vector3(wx, wy, wz)

	-- Если точка, куда пытаются поставить объект, находится слишком далеко
	if not wx or not wy then 
		return false, Vector3(0, 0, -100), 0
	end

	local angle = -math.atan2(cameraPosition.x - wx, cameraPosition.y - wy) / math.pi * 180
	local canPlace = true
	if isElement(hitElement) then
		local hitObjectType = hitElement:getData("rust-object-type")
		if hitObjectType then
			if snapRules[placingObjectType][hitObjectType] then
				if type(snapRules[placingObjectType][hitObjectType] == "function") then
					local resultPosition, resultAngle = snapRules[placingObjectType][hitObjectType](hitElement, worldPosition, angle)
					if resultPosition then
						worldPosition = resultPosition
						angle = resultAngle
					else
						canPlace = false
					end
				end
			else
				canPlace = false
			end
		elseif not snapRules[placingObjectType]["world"] then
			canPlace = false
		end
	elseif not snapRules[placingObjectType]["world"] then
		canPlace = false
	end
	return canPlace, worldPosition, angle, hitElement
end

local function drawPlacingPreview(position, rotation, canPlace)
	local color = tocolor(0, 255, 0)
	if not canPlace then
		color = tocolor(255, 0, 0)
	end
	previews:drawObject(placingObjectType, position.x, position.y, position.z, rotation, color)
end

addEventHandler("onClientRender", root,
	function()
		local canPlace, worldPosition, rotation = getPlacementPosition()
		drawPlacingPreview(worldPosition, rotation, canPlace)
	end
)

local function placeObject()
	local canPlace, worldPosition, rotation, hitElement = getPlacementPosition()
	if not canPlace then
		return
	end
	if modelsOffsets[placingObjectType] then
		worldPosition = worldPosition + modelsOffsets[placingObjectType]
	end


	local object = createObject(modelsIDs[placingObjectType], worldPosition)
	object:setData("rust-object-type", placingObjectType)
	object.rotation = Vector3(0, 0, rotation + 90)

	if isElement(hitElement) then
		local hitObjectType = hitElement:getData("rust-object-type")
		if placingObjectType == "wall" and hitObjectType == "foundation" then
			local foundationWallsCount = hitElement:getData("rust-walls-count") or 0
			hitElement:setData("rust-walls-count", foundationWallsCount + 1)
		end
	end
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
		if modelsIDs[name] then
			placingObjectType = name
			outputChatBox("Выбран объект: " .. tostring(name))
		else
			outputChatBox("Невозможно выбрать объект: " .. tostring(name))
		end
	end
)