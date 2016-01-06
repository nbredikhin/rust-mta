class "BuildingManager"

function BuildingManager:BuildingManager()
	-- Массив построек
	self.buildingStructures = {}
end

-- Создание постройки
-- Vector3 position, float rotation
function BuildingManager:CreateStructure(position, rotation)
	local newStructure = BuildingStructure(position, rotation)
	table.insert(self.buildingStructures, newStructure)

	return newStructure
end