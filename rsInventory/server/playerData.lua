playerItems = {}

for _, player in ipairs(getElementsByType("player")) do
	playerItems[player] = {}
end

--[[
function savePlayerDataIntoAccount(player, account)
	if not player or not account then
		return
	end

	if account.name == "guest" then
		return
	end

	-- items
	local items = playerItems[player]

	if not items then
		return
	end

	account:setData("inventory.items", toJSON(items))

	playerItems[player] = nil
end

function loadPlayerData(player, account)
	if not player or not account then
		return
	end

	if account.name == "guest" then
		return
	end

	-- items
	local itemsJSON = account:getData("inventory.items") 

	if itemsJSON then
		playerItems[player] = fromJSON(itemsJSON)
	else
		playerItems[player] = {}
	end
end


addEventHandler("onPlayerLogin", root,
	function()
		loadPlayerData(source, source.account)
	end
)

addEventHandler("onPlayerLogout", root,
	function(account)
		savePlayerDataIntoAccount(source, account)
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		savePlayerDataIntoAccount(source, source.account)
	end
)

addEventHandler("onResourceStart", resource.rootElement,
	function()
		for _, player in ipairs(getElementsByType("player")) do
			loadPlayerData(player, player.account)
		end
	end
)

addEventHandler("onResourceStop", resource.rootElement,
	function()
		for _, player in ipairs(getElementsByType("player")) do
			savePlayerDataIntoAccount(player, player.account)
		end
	end
)]]--