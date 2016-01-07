class "BuildingManager"

function BuildingManager:BuildingManager()
	-- Массив построек
	self.buildingStructures = {}
end

function BuildingManager:GetStructureByID(id)
	return self.buildingStructures[id]
end

-- Создание постройки
-- Vector3 position, float rotation
function BuildingManager:CreateStructure(position, rotation)
	local newStructure = BuildingStructure(position, rotation)
	table.insert(self.buildingStructures, newStructure)
	newStructure.id = #self.buildingStructures
	newStructure:Setup()
	return newStructure
end