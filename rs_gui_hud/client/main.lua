local isHUDVisible = false

function setVisible(visible)
    if not not visible == isHUDVisible then
        return
    end
    isHUDVisible = not not visible

    showPlayerHudComponent("all", false)
    showPlayerHudComponent("crosshair", true)
end

function isVisible()
    return isHUDVisible
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    setVisible(true)
end)
