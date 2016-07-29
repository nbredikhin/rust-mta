function moveItem(item, slot)
	if not item or not slot then
		return
	end

	triggerServerEvent("inventory.onClientMoveItem", resourceRoot, item.id, slot.index)
end

function dropItem(item)
	if not item then
		return
	end

	triggerServerEvent("inventory.onClientDropItem", resourceRoot, item.id)
end

addEvent("inventory.refresh", true)
addEventHandler("inventory.refresh", resourceRoot,
	function(items)
		for _, slot in ipairs(inventory) do
			slot.item = nil
		end

		for _, item in ipairs(items) do
			if not item.slot then
				outputDebugString("no item.slot", 1)
				return
			end

			if inventory[item.slot] then
				inventory[item.slot].item = item
			else
				outputDebugString("no slot with index " .. tostring(item.slot), 2)
			end
		end

		inventory.items = items
	end
)


-- tracking to decide whether its selecting item or moving item case
function cursorMove()
	if slotUnderCursor and slotUnderCursor.item then
		movingItem = slotUnderCursor.item
	end	

	removeEventHandler("onClientCursorMove", root, cursorMove)
end

-- moving/selecting item
addEventHandler("onClientKey", root,
	function(keyPressed, keyDown)
		if keyPressed ~= "mouse1" then
			return
		end

		if keyDown then
			if not slotUnderCursor or not slotUnderCursor.item then
				return
			end

			addEventHandler("onClientCursorMove", root, cursorMove)
		else
			removeEventHandler("onClientCursorMove", root, cursorMove)

			if not movingItem then
				if slotUnderCursor then
					selectedItem = slotUnderCursor.item
				end
			else
				if slotUnderCursor then
					if slotUnderCursor.index ~= movingItem.slot then
						moveItem(movingItem, slotUnderCursor)
					end
				else
					dropItem(movingItem)
				end

				movingItem = nil
			end
		end
	end
)

-- drawing moving item
addEventHandler("onClientRender", root,
	function()
		if not movingItem then
			return
		end

		local x, y = getCursorPosition()
		local w, h = settings.width, settings.heigth

		drawItem(movingItem, x - w/2, y - h/2, w, h)
	end
)

