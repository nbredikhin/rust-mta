modelsSizes = {}

modelsSizes.foundationWidth = 5
modelsSizes.foundationHeight = modelsSizes.foundationWidth

modelsSizes.wallWidth = modelsSizes.foundationWidth
modelsSizes.wallHeight = 4
modelsSizes.wallDepth = 0.21

modelsSizes.floorWidth = modelsSizes.foundationWidth
modelsSizes.floorHeight = modelsSizes.wallDepth

modelsOffsets = {}
modelsOffsets.foundation = Vector3(0, 0, modelsSizes.foundationHeight * 0.05)
modelsOffsets.wall = Vector3(0, 0, 0)--modelsSizes.wallHeight)

modelsIDs = {
	["foundation"] = 3865,
	["wall"] = 1618,
	["wall_door"] = 1623,
	["wall_window"] = 1624,
	["floor"] = 3397
}

-- TXD с текстурами для всех строительных объектов
local txd = engineLoadTXD("models/structures.txd")
for fileName, id in pairs(modelsIDs) do
	engineImportTXD(txd, id)
	col = engineLoadCOL("models/" .. fileName ..".col")
	engineReplaceCOL(col, id)
	dff = engineLoadDFF("models/" .. fileName ..".dff")
	engineReplaceModel(dff, id)
end