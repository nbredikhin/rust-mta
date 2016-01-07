-- TXD с текстурами для всех строительных объектов
local txd = engineLoadTXD("models/structures.txd")

-- Замена моделей
for fileName, id in pairs(ReplacedModelsIDs) do
	engineImportTXD(txd, id)
	col = engineLoadCOL("models/" .. fileName ..".col")
	engineReplaceCOL(col, id)
	dff = engineLoadDFF("models/" .. fileName ..".dff")
	engineReplaceModel(dff, id)
end