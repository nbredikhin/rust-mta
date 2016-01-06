local function initializeResource()
	local buildingManager = BuildingManager()

	-- Тестовая постройка
	local structure = buildingManager:CreateStructure(Vector3(1780, -2532, 13), 40)
	structure:AddFoundation(1, 0)
	structure:AddWall("wall", structure:GetFoundation(0, 0), "forward")
	structure:AddWall("door", structure:GetFoundation(1, 0), "forward")

	structure:AddFoundation(1, 1)
	structure:AddWall("wall", structure:GetFoundation(1, 1), "right")
	structure:AddWall("wall", structure:GetFoundation(1, 1), "backward")
	structure:AddWall("door", structure:GetFoundation(0, 0), "right")
	structure:AddFoundation(1, 2)
end

addEventHandler("onResourceStart", resourceRoot, initializeResource)