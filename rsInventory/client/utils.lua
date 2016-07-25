screenW, screenH = guiGetScreenSize()
--screenW, screenH = 1024, 768

_getCursorPosition = getCursorPosition

function getCursorPosition()
	if not isCursorShowing() then
		return false, false
	end

	local x, y = _getCursorPosition()

	return x * screenW, y * screenH
end

unknownImg = dxCreateTexture("client/unknown.png", "argb", true, "clamp")