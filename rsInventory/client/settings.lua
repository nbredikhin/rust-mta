scaleFactor = screenH / 900

settings = {
    width = 64 * scaleFactor, -- размер слота
    heigth = 64 * scaleFactor, -- размер слота
    alpha = 100, -- альфа слотов
    spacing = 6, -- спейсинг между слотами
    colorSelected = {64, 128, 255}, -- цвет выделенного слота
    colorNormal = {128, 128, 128}, -- дефолтный цвет слота
    colorHover = {64, 128, 255}, -- цвет слота под курсором
    row = 6, -- количество слотов в одном ряду
    inventoryRows = 4, -- количество рядов в инвентаре
    blockSpacing = 48 * scaleFactor, -- расстояние между блоками 
    inventoryBGColor = tocolor(100, 100, 100, 240),
    selectedItemIMGSize = 128 * scaleFactor, 
    visible = true, -- глобальная переменная видимости всего (есть экспорт функция)
    titleSpacing = 32 * scaleFactor, -- расстояние от заголовка до блока
    key = "e", -- кнопка отображения/скрытия инвентаря
    slotAmountSpacing = 4, -- расстояние от нижнего правого угла до цифры количества предметов в стаке
    smallFont = dxCreateFont("files/tahomabd.ttf", (scaleFactor*10 + 1), false, "draft"), -- шрифт описания, количества предметов
    titleFont = dxCreateFont("files/tahomabd.ttf", (scaleFactor*10 + 7), false, "proof"), -- шрифт заголовков (названия блоков)
    worldItemNameOffset = 25, -- оффсет названия итема на экране
}
settings.hotbarY = screenH - settings.heigth - settings.blockSpacing -- положение хотбара
settings.inventoryY = settings.hotbarY - settings.blockSpacing - (settings.heigth + settings.spacing) * (settings.inventoryRows + 1) -- положение инвентаря