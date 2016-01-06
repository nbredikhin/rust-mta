-- Размеры объектов
ModelsSizes = {}

ModelsSizes.foundation = {}
ModelsSizes.foundation.width = 5
ModelsSizes.foundation.height = ModelsSizes.foundation.width

ModelsSizes.wall = {}
ModelsSizes.wall.width = ModelsSizes.foundation.width
ModelsSizes.wall.height = 4
ModelsSizes.wall.depth = 0.21

ModelsSizes.floor = {}
ModelsSizes.floor.width = ModelsSizes.foundation.width
ModelsSizes.floor.height = ModelsSizes.foundation.height

-- ID'ы замененных моделей
ReplacedModelsIDs = {
	["foundation"] = 3865,
	["wall"] = 1618,
	["wall_door"] = 1623,
	["wall_window"] = 1624,
	["floor"] = 3397
}