accounts = {}

-- bool success, bool is_bad_password
function accounts.login(player, username, password)
	if not isElement(player) then
		return false
	end
	if not username or not password then
		return false
	end
	if accounts.is_logged_in(player) then
		return false
	end
	local account = getAccount(username, password)
	if not account then
		return false, true
	end

	if not logIn(player, account) then
		return false, true
	else 
		return true
	end
end

function accounts.logout(player)
	if not isElement(player) then
		return false
	end
	if not accounts.is_logged_in(player) then
		return false
	end
	return logOut(player)
end

function accounts.is_logged_in(player)
	if not player.account then
		return false
	end
	if player.account.guest then
		return false
	else
		return true
	end
end

-- Отключить команду /logout
addEventHandler("onPlayerCommand", root, function (command)
	if command == "logout" then
		cancelEvent()
	end
end)

addEventHandler("onPlayerLogin", root, function (previous_account, account)
	local player = source

	-- TODO: Проверка аккаунта, заполнение стандартных полей

	triggerEvent("rust_player_login", player)
end)

addEventHandler("onResourceStart", resourceRoot, function ()
	local players_table = getElementsByType("player")
	for i, player in ipairs(players_table) do
		logOut(player)
	end
end)
