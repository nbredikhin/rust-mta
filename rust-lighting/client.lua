local radius = 20

local light = Light(0, 0, 0, 0, 15, 255, 200, 100)
local isAttached = true
addEventHandler("onClientRender", root,
	function()
		if isAttached then
			light.position = localPlayer.position + Vector3(0, 0, 1)
		end
	end
)

addCommandHandler("dt", 
	function()
		isAttached = not isAttached
	end
)