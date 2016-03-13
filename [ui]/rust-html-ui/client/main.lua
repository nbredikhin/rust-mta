addEventHandler("onClientResourceStart", resourceRoot, 
	function()
		webui:start()
		webui:showScreen("login")
	end
)

addCommandHandler("br",
	function(cmd, fname, ...)

		if webui[fname]  then
			webui[fname](webui, ...)
		end
	end
)
