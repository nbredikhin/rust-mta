local copyControlsFromPlayer = {
	"fire",
	"aim_weapon"
}

local cameraOffset = Vector3(0, 0, 0)

local rotationX = 0
local rotationY = 0

local MOUSE_SENSITIVITY = 0.05

local ped
local pedOffset = Vector3(0, 0.4, -0.4)
local pedRotationOffset = 0
local targetRotationOffset = 0
local targetFOV = 70
local fov = 70

addEventHandler("onClientRender", root, function ()
	pedRotationOffset = pedRotationOffset + (targetRotationOffset - pedRotationOffset) * 0.05
	fov = fov + (targetFOV - fov) * 0.05
	local cameraPosition = Vector3(localPlayer:getBonePosition(7)) + cameraOffset
	local cameraLook = Vector3(
		math.cos(rotationY) * math.sin(rotationX),
		math.cos(rotationY) * math.cos(rotationX),
		math.sin(rotationY)
	)

	setCameraMatrix(cameraPosition, cameraPosition + cameraLook, 0, fov)
	ped.rotation = Vector3(-math.deg(rotationY) - pedRotationOffset, 0, -math.deg(rotationX))
	setElementPosition(ped, cameraPosition, false)
	local pedStateOffset = Vector3(0, 0, 0)
	if getKeyState("mouse2") then
		pedStateOffset = Vector3(0.1, 0, 0.02)
		targetFOV = 60
	else
		targetFOV = 70
	end
	setElementPosition(ped, ped.matrix:transformPosition(pedOffset + pedStateOffset), false)

	if getKeyState("mouse2") then	
		local pedAimTarget = ped.position + cameraLook * 20
		pedAimTarget.z = math.sin(rotationY + pedRotationOffset) + ped.position.z
		setPedAimTarget(ped, pedAimTarget)
	end	
end)

addEventHandler("onClientCursorMove", root, function(cX, cY, aX, aY)
	if isMTAWindowActive() or isCursorShowing() then
		return
	end

	local width, height = guiGetScreenSize()

	-- Center offsets
	aX = aX - width / 2
	aY = aY - height / 2

	local sensitivity = MOUSE_SENSITIVITY * 0.01745
	rotationX = rotationX + aX * sensitivity
	rotationY = rotationY - aY * sensitivity
	-- Wrap angle
	local PI = math.pi
	if rotationX > PI then
		rotationX = rotationX - 2 * PI
	elseif rotationX < -PI then
		rotationX = rotationX + 2 * PI
	end
	if rotationY > PI then
		rotationY = rotationY - 2 * PI
	elseif rotationY < -PI then
		rotationY = rotationY + 2 * PI
	end

	-- Angle must be less than abs(PI / 2)
	if rotationY < - PI / 2.05 then
		rotationY = -PI / 2.05
	elseif rotationY > PI / 2.05 then
		rotationY = PI / 2.05
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	localPlayer.alpha = 0
	ped = createPed(160, localPlayer.position)
	bindKey("1", "down", function()
		givePedWeapon(ped, 31, 50, true)
		pedRotationOffset = -40
	end)
	local camera = getCamera()
	setElementCollisionsEnabled(ped, false)

	local arms = engineLoadTXD("assets/models/arms.txd")
	engineImportTXD(arms, 160)
end)

addEventHandler("onClientKey", root, function(key, state)
	-- Прицеливание
	ped:setControlState("aim_weapon", getKeyState("mouse2"))
end)