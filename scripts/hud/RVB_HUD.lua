
RVB_HUD = {}
local RVB_HUD_mt = Class(RVB_HUD)

RVB_HUD.POSITION = {
	RPM			 = { -42, 0 },
	TEMP		 = { 42, 0 }
}

RVB_HUD.TEXT_SIZE = {
	RPM			  = 10,
	TEMP		  = 10,
	FUEL		  = 10
}


function RVB_HUD:new(speedMeterDisplay, gameInfoDisplay, modDirectory)

	local self = setmetatable({}, RVB_HUD_mt)

	self.speedMeterDisplay = speedMeterDisplay
	self.gameInfoDisplay   = gameInfoDisplay
	self.modDirectory      = modDirectory
	self.vehicle           = nil

	self.rpmText              = {}
	self.tempText             = {}
	self.fuelText             = {}
	self.RVB_generalSET = g_currentMission.vehicleBreakdowns.generalSettings

	return self

end

function RVB_HUD:load()
	self:createElements()
	self:setVehicle(nil)
end

function RVB_HUD:createElements()
	self:storeScaledValues()
end

function RVB_HUD:storeScaledValues()

	local baseX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX
	local baseY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY

	local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.RPM)
	self.rpmText.posX = baseX + textX
	self.rpmText.posY = baseY + textY
	self.rpmText.size = self.speedMeterDisplay:scalePixelToScreenHeight(RVB_HUD.TEXT_SIZE.RPM)

	local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.TEMP)
	self.tempText.posX = baseX + textX
	self.tempText.posY = baseY + textY
	self.tempText.size = self.speedMeterDisplay:scalePixelToScreenHeight(RVB_HUD.TEXT_SIZE.TEMP)

	local fuelbaseX, fuelbaseY = g_currentMission.inGameMenu.hud.speedMeter:getBasePosition()
	local textX, textY = getNormalizedScreenValues(unpack(SpeedMeterDisplay.POSITION.FUEL_LEVEL_ICON))
	self.fuelText.posX = fuelbaseX + textX
	self.fuelText.posY = fuelbaseY + textY

end

function RVB_HUD:setVehicle(vehicle)
	self.vehicle = vehicle
end

function RVB_HUD:drawHUD()

	local RVB_SETTINGS = g_currentMission.vehicleBreakdowns.generalSettings
	
	if self.vehicle.spec_motorized ~= nil then

		local rpm_txt = "--\nrpm"
		if self.vehicle.spec_motorized.isMotorStarted == true then
			rpm_txt = string.format("%i\nrpm", self.vehicle.spec_motorized:getMotorRpmReal())
		end

		setTextColor(1,1,1,1)
		setTextAlignment(RenderText.ALIGN_CENTER)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
		setTextBold(true)
		renderText(self.rpmText.posX, self.rpmText.posY, self.rpmText.size, rpm_txt)
	end

	if self.vehicle.spec_motorized ~= nil then

		local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
		local _s = "C"
		if _useF then _s = "F" end

		local temp_txt = "--\n°" .. _s
		if self.vehicle.spec_motorized.isMotorStarted == true then
		local _value = self.vehicle.spec_motorized.motorTemperature.value
		if _useF then _value = _value * 1.8 + 32 end
			temp_txt = string.format("%i\n°%s", _value, _s)
		end

		setTextColor(1,1,1,1)
		setTextAlignment(RenderText.ALIGN_CENTER)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
		setTextBold(true)
		renderText(self.tempText.posX, self.tempText.posY, self.tempText.size, temp_txt)

	end

	if self.vehicle.spec_motorized ~= nil then

		local baseX, baseY = g_currentMission.inGameMenu.hud.speedMeter:getBasePosition()
		local posX, posY = getNormalizedScreenValues(unpack(SpeedMeterDisplay.POSITION.FUEL_LEVEL_ICON))
		local size = 0.013 * g_gameSettings.uiScale
		local fuel_txt = string.format("%.1f l/h", 0.0)
		
		if self.vehicle.spec_motorized.isMotorStarted == true then
			local specf = self.vehicle.spec_faultData
			fuel_txt = specf.instantFuel.Consumption
		end

		setTextColor(1,1,1,1)
		setTextAlignment(RenderText.ALIGN_RIGHT)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
		setTextBold(true)
		renderText(baseX + posX + 0.02, baseY + posY, size, fuel_txt)

	end

	setTextColor(1,1,1,1)
	setTextAlignment(RenderText.ALIGN_LEFT)
	setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
	setTextBold(false)

end
