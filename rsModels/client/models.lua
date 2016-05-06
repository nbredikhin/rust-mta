addEventHandler("onClientResourceStart", resourceRoot, function ()
	local txd = engineLoadTXD("models/structures.txd")	
	for fileName, id in pairs(replacedModelsIds) do
		engineImportTXD(txd, id)
		if fileExists("models/" .. fileName ..".col") then
			col = engineLoadCOL("models/" .. fileName ..".col")
			if col then
				engineReplaceCOL(col, id)
			end
		end
		if fileExists("models/" .. fileName ..".txd") then
			local txd = engineLoadTXD("models/" .. fileName ..".txd")	
			engineImportTXD(txd, id)
		end
		dff = engineLoadDFF("models/" .. fileName ..".dff")
		engineReplaceModel(dff, id)
	end
end)