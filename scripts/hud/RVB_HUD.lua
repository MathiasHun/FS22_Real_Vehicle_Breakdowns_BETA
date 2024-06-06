
RVB_HUD = {}
local RVB_HUD_mt = Class(RVB_HUD)

RVB_HUD.POSITION = {
	RPM			 = { -42, 0 },
	TEMP		 = { 42, 0 },
	FUEL		 = { 123, -117 },
	ICON_TEMP = { 165, 130 },
	ICON_BATTERY = { 70, 130 },
	ICON_ENGINE = { 75, 150 },
	ICON_LIGHTS = { 163, 150 },
	ICON_SERVICE = { 113, 165 }
}

RVB_HUD.TEXT_SIZE = {
	RPM			  = 10,
	TEMP		  = 10,
	FUEL		  = 12
}

RVB_HUD.SIZE = {
	RVBICON   = {  16, 14 },
	ICON_SERVICE = {35, 33}
}

RVB_HUD.UV = {
	ICON_TEMP   = { 0, 0,  25, 23 },
	ICON_BATTERY   = { 25, 0,  25, 23 },
	ICON_ENGINE   = { 50, 0,  25, 23 },
	ICON_LIGHTS   = { 75, 0,  25, 23 },
	ICON_SERVICE   = { 100, 0,  30, 27 }
}

function RVB_HUD:new(speedMeterDisplay, gameInfoDisplay, modDirectory)

	local self = setmetatable({}, RVB_HUD_mt)

	self.speedMeterDisplay = speedMeterDisplay
	self.gameInfoDisplay   = gameInfoDisplay
	self.modDirectory      = modDirectory
	self.vehicle           = nil
	
	self.uiFilename        = Utils.getFilename("icons/hud_icons.dds", modDirectory)

	self.icons = {}

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
	local baseX, baseY = self.speedMeterDisplay.gaugeBackgroundElement:getPosition()
	self:createParkBox(baseX, baseY)
end

function RVB_HUD:createParkBox(baseX, baseY)

	local iconWidth, iconHeight = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.SIZE.RVBICON)
	 
	
	-- TEMPERATURE HUD ICON
	local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.ICON_TEMP)
	self.icons.temperature = self:createIcon(baseX + iconPosX, baseY + iconPosY, iconWidth, iconHeight, RVB_HUD.UV.ICON_TEMP)
	self.icons.temperature:setVisible(false)
	self.speedMeterDisplay.gaugeBackgroundElement:addChild(self.icons.temperature)
		
	-- BATTERY HUD ICON
	local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.ICON_BATTERY)
	self.icons.battery = self:createIcon(baseX + iconPosX, baseY + iconPosY, iconWidth, iconHeight, RVB_HUD.UV.ICON_BATTERY)
	self.icons.battery:setVisible(false)
	self.speedMeterDisplay.gaugeBackgroundElement:addChild(self.icons.battery)
	
	-- ENGINE HUD ICON
	local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.ICON_ENGINE)
	self.icons.engine = self:createIcon(baseX + iconPosX, baseY + iconPosY, iconWidth, iconHeight, RVB_HUD.UV.ICON_ENGINE)
	self.icons.engine:setVisible(false)
	self.speedMeterDisplay.gaugeBackgroundElement:addChild(self.icons.engine)
	
	-- LIGHTS HUD ICON
	local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.ICON_LIGHTS)
	self.icons.lights = self:createIcon(baseX + iconPosX, baseY + iconPosY, iconWidth, iconHeight, RVB_HUD.UV.ICON_LIGHTS)
	self.icons.lights:setVisible(false)
	self.speedMeterDisplay.gaugeBackgroundElement:addChild(self.icons.lights)
	
	-- SERVICE HUD ICON
	local iconPosX, iconPosY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.ICON_SERVICE)
	local iconWidth, iconHeight = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.SIZE.ICON_SERVICE)
	self.icons.service = self:createIcon(baseX + iconPosX, baseY + iconPosY, iconWidth, iconHeight, RVB_HUD.UV.ICON_SERVICE)
	self.icons.service:setVisible(false)
	self.speedMeterDisplay.gaugeBackgroundElement:addChild(self.icons.service)
	
	self:storeScaledValuesHUD(baseX, baseY)
	
end

function RVB_HUD:createIcon(baseX, baseY, width, height, uvs)

	local iconOverlay = Overlay.new(self.uiFilename, baseX, baseY, width, height)
	iconOverlay:setUVs(GuiUtils.getUVs(uvs))
	local element = HUDElement.new(iconOverlay)

	element:setVisible(false)

	return element
end

function RVB_HUD:storeScaledValuesHUD(baseX, baseY)

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

	local textX, textY = self.speedMeterDisplay:scalePixelToScreenVector(RVB_HUD.POSITION.FUEL)
	self.fuelText.posX = baseX + textX
	self.fuelText.posY = baseY + textY
	self.fuelText.size = self.speedMeterDisplay:scalePixelToScreenHeight(RVB_HUD.TEXT_SIZE.FUEL)

end

function RVB_HUD:setVehicle(vehicle)
	self.vehicle = vehicle
	
	 if self.speedMeterDisplay ~= nil then
		self.speedMeterDisplay.gaugeBackgroundElement:setVisible(vehicle ~= nil)
	end
end

function RVB_HUD:hideSomething(vehicle)

	if vehicle.isClient then
		self.speedMeterDisplay.gaugeBackgroundElement:setVisible(false)
	end
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

		local fuel_txt = string.format("%.1f l/h", 0.0)
		if self.vehicle.spec_motorized.isMotorStarted == true then
			local specf = self.vehicle.spec_faultData
			fuel_txt = specf.instantFuel.Consumption
		end

		setTextColor(1,1,1,1)
		setTextAlignment(RenderText.ALIGN_CENTER)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
		setTextBold(true)
		renderText(self.fuelText.posX, self.fuelText.posY, self.fuelText.size, fuel_txt)
		

	end

	setTextColor(1,1,1,1)
	setTextAlignment(RenderText.ALIGN_LEFT)
	setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
	setTextBold(false)
	

	if self.vehicle.spec_motorized.isMotorStarted then
		self.icons.temperature:setVisible(true)
		self.icons.battery:setVisible(true)
		self.icons.engine:setVisible(true)
		self.icons.lights:setVisible(true)
		self.icons.service:setVisible(true)
	else
		self.icons.temperature:setVisible(false)
		self.icons.battery:setVisible(false)
		self.icons.engine:setVisible(false)
		self.icons.lights:setVisible(false)
		self.icons.service:setVisible(false)
	end



	if self.speedMeterDisplay:getVisible() then

		if self.vehicle.spec_motorized.isMotorStarted and self.vehicle.spec_faultData.dashboard_check_ok then


			local RVB = {}
			RVB.COLOR = {}
			RVB.COLOR.DEFAULT = {1, 1, 1, 0.2}
			RVB.COLOR.YELLOWFAULT = {1.0000, 0.6592, 0.0000, 1}
			RVB.COLOR.REDFAULT = {0.8069, 0.0097, 0.0097, 0.5}

			local spec = self.vehicle.spec_faultData

			local temperature_percent = (spec.parts[1].operatingHours * 100) / spec.parts[1].tmp_lifetime
			if temperature_percent < 95 then
				self.icons.temperature:setColor(unpack(RVB.COLOR.DEFAULT))
			elseif temperature_percent >= 95 and temperature_percent < 99 then
				self.icons.temperature:setColor(unpack(RVB.COLOR.YELLOWFAULT))
			else
				self.icons.temperature:setColor(unpack(RVB.COLOR.REDFAULT))
			end

			local lights_percent = (spec.parts[2].operatingHours * 100) / spec.parts[2].tmp_lifetime
			if lights_percent < 95 then
				self.icons.lights:setColor(unpack(RVB.COLOR.DEFAULT))
			elseif lights_percent >= 95 and lights_percent < 99 then
				self.icons.lights:setColor(unpack(RVB.COLOR.YELLOWFAULT))
			else
				self.icons.lights:setColor(unpack(RVB.COLOR.REDFAULT))
			end

			local engine_percent = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
			if engine_percent < 95 then
				self.icons.engine:setColor(unpack(RVB.COLOR.DEFAULT))
			elseif engine_percent >= 95 and engine_percent < 99 then
				self.icons.engine:setColor(unpack(RVB.COLOR.YELLOWFAULT))
			else
				self.icons.engine:setColor(unpack(RVB.COLOR.REDFAULT))
			end

			local battery_percent = (spec.parts[8].operatingHours * 100) / spec.parts[8].tmp_lifetime
			if battery_percent < 95 then
				self.icons.battery:setColor(unpack(RVB.COLOR.DEFAULT))
			elseif battery_percent >= 95 and battery_percent < 99 then
				self.icons.battery:setColor(unpack(RVB.COLOR.YELLOWFAULT))
			else
				self.icons.battery:setColor(unpack(RVB.COLOR.REDFAULT))
			end

			local RVBSET = g_currentMission.vehicleBreakdowns
			local service_percent = (spec.rvb[4] * 100) / RVBSET:getIsIsPeriodicService()
			if service_percent < 95 then
				self.icons.service:setColor(unpack(RVB.COLOR.DEFAULT))
			elseif service_percent >= 95 and service_percent < 99 then
				self.icons.service:setColor(unpack(RVB.COLOR.YELLOWFAULT))
			else
				self.icons.service:setColor(unpack(RVB.COLOR.REDFAULT))
			end

		end

	end

end
