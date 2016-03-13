outputChatBox("asd")

local function createWater2(x, y, z, w, h)
	createWater(x, y, z, x + w, y, z, x, y + w, z, x + w, y + w, z)
end
createWater2(-2990, -2990, 60, 5700, 5700)
setWaterLevel(475)