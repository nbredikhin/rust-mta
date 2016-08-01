screenW1, screenH1 = guiGetScreenSize()
screenW, screenH = screenW1, screenH1

_getCursorPosition = getCursorPosition

function getCursorPosition()
	if not isCursorShowing() then
		return false, false
	end

	local x, y = _getCursorPosition()

	return x * screenW1, y * screenH1
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

unknownImg = dxCreateTexture("files/unknown.png", "argb", true, "clamp")

addEvent("inventory.setPedAnimation", true)
addEventHandler("inventory.setPedAnimation", resourceRoot,
	function(arg)
		setPedAnimation(unpack(arg))
	end
)

addCommandHandler("cursor",
	function()
		outputDebugString("rsInventiry/utils.lua changed cursor state")

		showCursor(not isCursorShowing())
	end
)