local buildings = {}

local partTypes = {
	["wall"] = Wall
}

addEvent("rsBuilding.build", true)
addEventHandler("rsBuilding.build", resourceRoot, function (targetObject, partType, x, y, z, rotation, direction)
	if not targetObject and partType == "foundation" then
		local foundation = Foundation:new()
		local building = Building:new(Vector3(x, y, z), rotation, foundation)
	end

	if isElement(targetObject) then
		local position = targetObject:getData("rsBuilding.position")
		if not position then
			return
		end
		local partClass = partTypes[partType]
		if not partClass then
			outputChatBox("No such part: %s" % tostring(partType))
		end
		local part = partClass:new()
		building1:addPart(part, position.x, position.y, position.z, direction)
	end
end)