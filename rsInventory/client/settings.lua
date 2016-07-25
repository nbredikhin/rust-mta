scaleFactor = screenH / 900

settings = {
    width = 64 * scaleFactor,
    heigth = 64 * scaleFactor,
    alpha = 100,
    spacing = 6,
    colorSelected = {64, 128, 255},
    colorNormal = {128, 128, 128},
    colorHover = {64, 128, 255},
    row = 6,
    inventoryRows = 4,
    blockSpacing = 32,
    inventoryBGColor = tocolor(100, 100, 100, 240),
    visible = true
}
settings.hotbarY = screenH - settings.heigth - settings.blockSpacing * scaleFactor
settings.inventoryY = settings.hotbarY - settings.blockSpacing - (settings.heigth + settings.spacing) * (settings.inventoryRows + 1)