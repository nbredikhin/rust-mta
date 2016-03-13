local screenWidth, screenHeight = guiGetScreenSize()
webui = {}
webui.active = false
webui.currentScreen = ""

function webui:start()
	self.browser = createBrowser(screenWidth, screenHeight, true, true)
	self.browser:loadURL("about:blank")
	self.browser:setRenderingPaused(true)
	self.active = false

	addEventHandler("onClientRender", root, function() webui:draw() end)
	addEventHandler("onClientClick", root, function(button, state) webui:injectMouseState(button, state) end)
	addEvent("webui-buttonClick")
	addEventHandler("webui-buttonClick", resourceRoot, function(...) webui:buttonClick(...) end)

	setBrowserAjaxHandler(self.browser, "screens/login/ajax.html",
		function(get, post)
			for k, v in pairs(post) do 
				outputChatBox(k .. "=" .. tostring(v))
			end 
			return "<p>test</p>"
		end
	)	
end

function webui:injectMouseState(button, state)
	if state == "down" then
		injectBrowserMouseDown(self.browser, button)
	else
		injectBrowserMouseUp(self.browser, button)
	end 
end

function webui:draw()
	if self.active then
		local mx, my = getCursorPosition()
		if mx then
			mx, my = mx * screenWidth, my * screenHeight
			injectBrowserMouseMove(self.browser, mx, my)
		end
		dxDrawImage(0, 0, screenWidth, screenHeight, self.browser)
	end
end

function webui:showScreen(name)
	if not self.browser then
		return false
	end
	if not name then 
		return false
	end
	name = tostring(name)
	local screenPath = "screens/" .. name
	if not fileExists("screens/" .. name .. "/index.html") then
		return false
	end
	-- browser
	self.browser:setRenderingPaused(false)
	self.browser:loadURL(screenPath .. "/index.html")
	self.browser:focus()

	self.active = true
	self.currentScreen = name
	showCursor(true)
	guiSetInputEnabled(true)
	return true
end

function webui:hideScreen()
	if not self.browser then
		return false
	end
	self.browser:loadURL("screens/blank.html")
	self.browser:setRenderingPaused(true)
	self.currentScreen = ""
	self.active = false
	showCursor(false)
	guiSetInputEnabled(false)
	return true
end

function webui:buttonClick(button, ...)
	-- login-loginButton
	triggerEvent("tws-webuiButtonClick", resourceRoot, self.currentScreen .. "-" .. button, ...)
end


