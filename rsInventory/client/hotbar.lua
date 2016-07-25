hotbar = createSlotsRow(settings.hotbarY, true)
hotbar.visible = true
hotbar.selected = 1

-- все кнопки, которые могут изменить активный слот (в следующем цикле сюда добавляются остальные кнопки)
hotbar.keys = {
	"mouse_wheel_up",
	"mouse_wheel_down"
}

for index in ipairs(hotbar) do
	table.insert(hotbar.keys, index)
end


-- drawing hotbar
addEventHandler("onClientPreRender", root,
	function()
		if not settings.visible or not hotbar.visible then
			return
		end

		for index, slot in ipairs(hotbar) do
			if slot.isHotbar then
				local colorSelected = settings.colorSelected

				if hotbar.selected == index and not inventory.visible then
					slot.color = tocolor(colorSelected[1], colorSelected[2], colorSelected[3], inventory.alpha)
				else
					slot.color = nil
				end

				slot.alpha = inventory.alpha

				-- рисуем
				slot:draw()
			end
		end
	end
)

-- меняем активный слот
addEventHandler("onClientKey", root,
	function(keyPresssed, state)
		if not state then
			return
		end

		if inventory.visible then
			return
		end

		local isChange = false
		for _, key in ipairs(hotbar.keys) do
			if keyPresssed == tostring(key) then
				isChange = true
				break
			end
		end

		if not isChange then
			return
		end

		if keyPresssed == "mouse_wheel_up" then
			hotbar.selected = hotbar.selected + 1

			if hotbar.selected > #hotbar then
				hotbar.selected = 1
			end
		elseif keyPresssed == "mouse_wheel_down" then
			hotbar.selected = hotbar.selected - 1

			if hotbar.selected < 1 then
				hotbar.selected = #hotbar
			end
		else
			for index in ipairs(hotbar) do
				if index == tonumber(keyPresssed) then
					if hotbar.selected == tonumber(keyPresssed) then
						hotbar.selected = 0
					else
						hotbar.selected = tonumber(keyPresssed)
					end
					break
				end
			end
		end

		triggerEvent("onClientChangeHotbarSlot", root, hotbar[hotbar.selected])
	end
)

addEvent("onClientChangeHotbarSlot", true)
addEventHandler("onClientChangeHotbarSlot", root,
	function(slot)
		if not slot then -- happens when double click on same slot for hiding an item
			return
		end

		if not slot.item then
			return
		end

		outputChatBox(tostring(slot.item.name))
	end
)
