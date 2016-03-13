local function initializeResource()
	buildingManager = BuildingManager()

	local house = buildingManager:CreateStructure(Vector3(-2424, -614, 132), 45)
	house:AddWall("wall", house:GetBaseFoundation(), "forward")
	house:AddWall("wall", house:GetBaseFoundation(), "left")
	--house:AddStairs(house:GetBaseFoundation(), 90 * 0)

	local house = buildingManager:CreateStructure(Vector3(-2420, -610, 132), 45 + 180)
	house:AddWall("wall", house:GetBaseFoundation(), "backward")
	house:AddWall("wall", house:GetBaseFoundation(), "right")
	--house:AddStairs(house:GetBaseFoundation(), 90 * 0)
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

		local targetObjectType = targetObject:getData("rust-object-type")
		local targetObjectStructureType = targetObject:getData("rust-structure-type")
		if objectType == "foundation" then
			if targetObjectType == "foundation" then
				structure:AddFoundation(targetObject, direction)
			end
		elseif string.find(objectType, "wall") then
			if targetObjectStructureType == "floor" then
				structure:AddWall(objectType, targetObject, direction)
			elseif targetObjectStructureType == "wall" then
				structure:AddWallAboveWall(objectType, targetObject)
			end
		elseif objectType == "floor" then
			if targetObject:getData("rust-structure-type") == "floor" then
				structure:AddFloorAboveFloor(targetObject)
			elseif targetObject:getData("rust-structure-type") == "wall" then
				structure:AddFloorToWall(targetObject)
			end
		elseif objectType == "stairs" then
			if targetObject:getData("rust-structure-type") == "floor" then
				structure:AddStairs(targetObject, rotation)
			end
		elseif objectType == "door" then
			if targetObject:getData("rust-object-type") == "wall_door" then
				structure:AddDoor(targetObject)
			end
		end
	end
end

addEventHandler("onResourceStart", resourceRoot, initializeResource)

addEvent("rust-onPlayerPlacingObject", true)
addEventHandler("rust-onPlayerPlacingObject", resourceRoot, handlePlayerPlacingObject)