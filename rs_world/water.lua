local worldSize = 2998
local waterHeight = 70

addEventHandler("onResourceStart", resourceRoot, function ()
    local water = createWater(
        -worldSize, -worldSize, waterHeight,
         worldSize, -worldSize, waterHeight,
        -worldSize,  worldSize, waterHeight,
         worldSize,  worldSize, waterHeight
    )

    setWaterLevel(-100)
    water.level = waterHeight
end)
