local function initializeResource()
	buildingManager = BuildingManager()

	-- Тестовая постройка
	local structure = buildingManager:CreateStructure(Vector3(1780, -2532, 13), 45)

	structure:AddFloor(0, 0, 1)

end

local function handlePlayerPlacingObject(objectType, position, rotation, targetObject, direction)
	position = Vector3(unpack(position))
	if objectType == "foundation" and not targetObject then
		buildingManager:CreateStructure(position, rotation)
	elseif isElement(targetObject) then
		local structureID = targetObject:getData("rust-structure-id")
		if not structureID then
			return
		end
		local structure = buildingManager:GetStructureByID(structureID)
		if not structure then
			return
		end		

		if objectType == "foundation" then
			if targetObject:getData("rust-object-type") == "foundation" then
				structure:AddFoundation(targetObject, direction)
			end
		elseif string.find(objectType, "wall") then
			if targetObject:getData("rust-structure-type") == "floor" then
				structure:AddWall(objectType, targetObject, direction)
			end
		elseif objectType == "floor" then
			if targetObject:getData("rust-structure-type") == "floor" then
				structure:AddFloorAboveFloor(targetObject)
			elseif targetObject:getData("rust-structure-type") == "wall" then
				structure:AddFloorToWall(targetObject)
			end
		end
	end
end

addEventHandler("onResourceStart", resourceRoot, initializeResource)

addEvent("rust-onPlayerPlacingObject", true)
addEventHandler("rust-onPlayerPlacingObject", resourceRoot, handlePlayerPlacingObject)