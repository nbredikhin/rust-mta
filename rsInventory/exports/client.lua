addEvent("onClientChangeHotbarSlot", true)
addEventHandler("onClientChangeHotbarSlot", root,
	function(slot)
		if not slot then -- happens when double click on same slot for hiding an item
			return
		end

		if not slot.item then
			return
		end

		--outputChatBox(tostring(slot.item.name))
	end
)


-- when hidden, you can't change your items
function setHotbarVisible(state)
	hotbar.visible = state
end

function isHotbarVisible()
	return hotbar.visible
end


-- completely disables visibility, so you have to press inventory.key to show it again
function setInventoryVisible(state)
	toggleInventory(state)
end

function isInventoryVisible()
	return inventory.visible
end


-- if this is true, but hotbar or inventory is false, they will be hidden
function setVisible(state)
	settings.visible = state
end

function getVisible()
	return settings.visible
end