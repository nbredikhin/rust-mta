local isHUDVisible = false

function setVisible(visible)
    if not not visible == isHUDVisible then
        return
    end
    isHUDVisible = not not visible

    showPlayerHudComponent("all", false)
end

function isVisible()
    return isHUDVisible
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    setVisible(true)
end)