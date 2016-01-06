local function initializeResource()
	buildingManager = BuildingManager()

	-- Тестовая постройка
	local structure = buildingManager:CreateStructure(Vector3(1780, -2532, 13), 45)
	structure:AddWall("wall", structure:GetBaseFoundation(), "right")
	structure:AddWall("window", structure:GetBaseFoundation(), "left")

	structure:AddFloor(0, 0, 1)

	structure:AddWall("wall", structure:GetFloor(0, 0, 1), "right")
	structure:AddWall("wall", structure:GetFloor(0, 0, 1), "forward")
	structure:AddFloor(0, 0, 2)

	structure:AddWall("door", structure:GetFloor(0, 0, 2), "forward")

	structure:AddWall("wall", structure:GetFloor(0, 0, 0), "forward")
	structure:AddWall("wall", structure:GetFloor(0, 0, 0), "backward")

	local floor = structure:AddFloor(0, 1, 0)
	structure:AddFloor(0, 2, 0)
	structure:AddWall("wall", structure:GetFloor(0, 2, 0), "backward")
	structure:AddFloor(0, 1, 1)
end

addEventHandler("onResourceStart", resourceRoot, initializeResource)