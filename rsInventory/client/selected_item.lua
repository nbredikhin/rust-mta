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

gui.titleX = gui.x
gui.titleY = gui.y - settings.titleSpacing
gui.titleFont = settings.titleFont

gui.descriptionFont = settings.smallFont
gui.description_x1 = gui.x + gui.spacing
gui.description_y1 = gui.y + gui.spacing
gui.description_x2 = gui.imgX - gui.spacing
gui.description_y2 = gui.imgY + gui.imgSize
gui.descriptionColor = tocolor(200, 200, 200)

addEventHandler("onClientRender", root,
	function()
		if not inventory.visible then
			return
		end

		local item = selectedItem

		if not item then
			return
		end

		-- bg
		dxDrawRectangle(gui.x, gui.y, gui.w, gui.h, gui.color())

		-- item img
		dxDrawImage(gui.imgX, gui.imgY, gui.imgSize, gui.imgSize, getImgForItem(item))

		-- title
		dxDrawText(tostring(item.name), gui.titleX, gui.titleY, gui.titleX, gui.titleY, 0xFFFFFFFF, 1, gui.titleFont)

		-- description
		dxDrawText(item.description or "", gui.description_x1, gui.description_y1, gui.description_x2, gui.description_y2, gui.descriptionColor, 1, gui.descriptionFont, "left", "top", true, true)
	end
)