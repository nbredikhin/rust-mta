lodsEnabled = true
local function renderLODs()
	if not lodsEnabled then
		return
	end
	for k, object in ipairs(getElementsByType("object")) do
		local objectType = object:getData("rust-object-type")
		if objectType then
			local x, y, z = getElementPosition(object)
			local rx, ry, rz = getElementRotation(object)
			lodsDrawing:drawObject(objectType, x, y, z, rz)
		end
	end
end

addEventHandler("onClientRender", root, renderLODs)
addCommandHandler("tl", 
	function()
		lodsEnabled = not lodsEnabled
	end
)