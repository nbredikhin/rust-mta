local buildings = {}

local partTypes = {
	["wall_door"] = WallDoor,
	["wall_window"] = WallWindow,
}

local building1

addEvent("rsBuilding.build", true)
addEventHandler("rsBuilding.build", resourceRoot, function (targetObject, partType, x, y, z, rotation, direction)
	if not targetObject and partType == "foundation" then
		local foundation = Foundation:new()
		building1 = Building:new(Vector3(x, y, z), rotation, foundation)
	elseif isElement(targetObject) then
		local position = targetObject:getData("rsBuilding.position")
		if not position then
			return
		end
		local partClass = partTypes[partType]
		if not partClass then
			local capitalized = string.gsub(partType, "^%l", string.upper)
			partClass = _G[capitalized]
			if not partClass then
				outputChatBox("No such part: %s" % tostring(partType))
				return
			end
		end
		local part = partClass:new()
		if partClass == Foundation then
			local dx, dy = getDirectionOffset(direction)
			position.x = position.x + dx
			position.y = position.y + dy
			direction = 0
		elseif partClass == Floor then
			position.z = position.z + 1
		end
		building1:addPart(part, position.x, position.y, position.z, direction)
	end
end)