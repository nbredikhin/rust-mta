addEventHandler("onClientResourceStart", resourceRoot, function ()
	local txd = engineLoadTXD("models/structures.txd")	
	for fileName, id in pairs(replacedModelsIds) do
		engineImportTXD(txd, id)
		col = engineLoadCOL("models/" .. fileName ..".col")
		if col then
			engineReplaceCOL(col, id)
		end
		dff = engineLoadDFF("models/" .. fileName ..".dff")
		engineReplaceModel(dff, id)
	end
end)