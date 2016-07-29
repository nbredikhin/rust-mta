local gui = {
	x = inventory.x1,
	y = settings.blockSpacing,
	w = inventory.x2 - inventory.x1,
	h = inventory.y1 - settings.blockSpacing * 2,
	color = function()
		return tocolor(settings.colorNormal[1], settings.colorNormal[2], settings.colorNormal[3], inventory.alpha)
	end,
	imgSize = settings.selectedItemIMGSize,
	spacing = 16 * scaleFactor
}

gui.imgX = gui.x + gui.w - gui.spacing - gui.imgSize
gui.imgY = gui.y + gui.spacing

gui.textX = gui.x
gui.textY = gui.y - settings.titleSpacing

gui.descriptionFont = dxCreateFont("files/tahoma.ttf", math.round(scaleFactor*10), false, "proof")
gui.description_x1 = gui.x + gui.spacing
gui.description_y1 = gui.y + gui.spacing
gui.description_x2 = gui.imgX - gui.spacing
gui.description_y2 = gui.imgY + gui.imgSize
gui.descriptionColor = tocolor(200, 200, 200)

addEventHandler("onClientRender", root,
	function()
		if true then
			return
		end
		
		if not inventory.visible then
			selectedItemID = nil
			return
		end

		local itemID = selectedItemID
		local item = localPlayer:getData("items")[itemID]

		if not itemID or not item then
			return
		end

		-- bg
		dxDrawRectangle(gui.x, gui.y, gui.w, gui.h, gui.color())

		-- item img
		dxDrawImage(gui.imgX, gui.imgY, gui.imgSize, gui.imgSize, getImgForItemByID(itemID))

		-- name
		dxDrawText(tostring(item.name), gui.textX, gui.textY, gui.textX, gui.textY, 0xFFFFFFFF, 2 * scaleFactor, "default-bold")

		-- description
		dxDrawText(item.description or "", gui.description_x1, gui.description_y1, gui.description_x2, gui.description_y2, gui.descriptionColor, 1, gui.descriptionFont, "left", "top", true, true)
	end
)