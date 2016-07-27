function setResourcePlayerData(player)
	local itemsTable = fromJSON(player.account:getData("items") or "[[]]")
	local occupiedSlots = fromJSON(player.account:getData("occupiedSlots") or "[[]]")

	player:setData("items", itemsTable)
	player:setData("occupiedSlots", occupiedSlots)
end

addEventHandler("onPlayerLogin", root,
	function()
		setResourcePlayerData(source)
	end
)

addEventHandler("onResourceStart", resource.rootElement,
	function()
		for _, player in ipairs(getElementsByType("player")) do
			setResourcePlayerData(player)
		end		
	end
)

function saveResourceAccountData(account)
	local player = source

	if not player or player.type ~= "player" then
		player = account.player
	end

	if not player then
		outputDebugString("no player", 2)
		return
	end

	if eventName == "onPlayerQuit" then
		account = player.account
	end

	-- сохранение итемов
	local itemsTable = player:getData("items") or {}
	account:setData("items", toJSON(itemsTable))

	-- сохранение положения итемов
	local occupiedSlots = player:getData("occupiedSlots") or {}

	account:setData("occupiedSlots", toJSON(occupiedSlots))

	player:setData("items", {})
	player:setData("occupiedSlots", false)
end

addCommandHandler("s",
	function()
		local player = getRandomPlayer()
		local occupiedSlots = player:getData("occupiedSlots")

		local i = 0
		for _ in pairs(occupiedSlots) do
			i = i + 1
		end

		outputChatBox("#occupiedSlots = " .. i)
	end
)

addEventHandler("onPlayerLogout", root, saveResourceAccountData)
addEventHandler("onPlayerQuit", root, saveResourceAccountData)
addEventHandler("onResourceStop", resource.rootElement,
	function()
		for _, player in ipairs(getElementsByType("player")) do
			local account = player.account

			saveResourceAccountData(account)
		end
	end
)