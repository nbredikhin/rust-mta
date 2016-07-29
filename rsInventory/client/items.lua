addEvent("inventory.refresh", true)
addEventHandler("inventory.refresh", resourceRoot,
	function(items)
		outputChatBox("new item! (" .. #items .. " items in inventory)")

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