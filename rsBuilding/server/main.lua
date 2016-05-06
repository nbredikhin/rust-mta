local buildings = {}

local partTypes = {
	["wall"] = Wall
}

addEvent("rsBuilding.build", true)
addEventHandler("rsBuilding.build", resourceRoot, function (partType, position, rotation, element, direction)
	if not element and partType == "foundation" then
		-- New building
	end

	if isElement(element) then
		local position = element:getData("rsBuilding.position")
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