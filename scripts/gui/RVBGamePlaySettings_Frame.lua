
RVBGamePlaySettings_Frame = {}
local RVBGamePlaySettings_Frame_mt = Class(RVBGamePlaySettings_Frame, TabbedMenuFrameElement)

RVBGamePlaySettings_Frame.CONTROLS = {"dailyServiceIntervalSet", "periodicServiceIntervalSet", "repairOnlySetting", "workshopOpenSet", "workshopCloseSet", "settingsContainer", "boxLayout",
 "thermostatLifetimeSet", "lightingsLifetimeSet", "glowplugLifetimeSet", "wipersLifetimeSet", "generatorLifetimeSet", "engineLifetimeSet", "selfstarterLifetimeSet", "batteryLifetimeSet", "tireLifetimeSet"}

function RVBGamePlaySettings_Frame.new(rvbMain, modName)
	local self = TabbedMenuFrameElement.new(nil, RVBGamePlaySettings_Frame_mt)

	self:registerControls(RVBGamePlaySettings_Frame.CONTROLS)

	self.rvbMain = rvbMain

	self.modName = modName
	self.selectedItem = nil
	self.i18n = g_i18n.modEnvironments[modName]

	self.hasMasterRights = false
	self.missionInfo = nil

	return self
end

function RVBGamePlaySettings_Frame:copyAttributes(src)
	RVBGamePlaySettings_Frame:superClass().copyAttributes(self, src)

	self.rvbMain = src.rvbMain
	self.modName = src.modName
	self.i18n = g_i18n.modEnvironments[self.modName]
end

function RVBGamePlaySettings_Frame:initialize()

	self:assignStaticTexts()
	
	self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	
	self.resetButtonInfo = {
		inputAction = InputAction.MENU_EXTRA_1,
		text = self.i18n:getText("button_reset"),
		callback = function ()
			self:onReset()
		end
	}
	
end
	
function RVBGamePlaySettings_Frame:updateMenuButtons()
	self.menuButtonInfo = {
		self.backButtonInfo,
		self.resetButtonInfo
	}

	self:setMenuButtonInfoDirty()
end

function RVBGamePlaySettings_Frame:assignStaticTexts()

	local textsNoYes = { self.i18n:getText("ui_off"), self.i18n:getText("ui_on") }
	
	local dailyServiceTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.DailyService) do
		table.insert(dailyServiceTable, rvb_Utils.getDailyServiceString(i))
	end
	self.dailyServiceIntervalSet:setTexts(dailyServiceTable)
	-- deactivate
	self.dailyServiceIntervalSet:setDisabled(true)
	
	local periodicServiceTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.PeriodicService) do
		table.insert(periodicServiceTable, rvb_Utils.getPeriodicServiceString(i))
	end
	self.periodicServiceIntervalSet:setTexts(periodicServiceTable)
	
	self.repairOnlySetting:setTexts(textsNoYes)

	local workshopOpenTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.WorkshopOpen) do
		table.insert(workshopOpenTable, rvb_Utils.getWorkshopOpenString(i))
	end
	self.workshopOpenSet:setTexts(workshopOpenTable)

	local workshopCloseTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.WorkshopClose) do
		table.insert(workshopCloseTable, rvb_Utils.getWorkshopCloseString(i))
	end
	self.workshopCloseSet:setTexts(workshopCloseTable)

	local thermostatLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(thermostatLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.thermostatLifetimeSet:setTexts(thermostatLifetimeTable)

	local lightingsLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(lightingsLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.lightingsLifetimeSet:setTexts(lightingsLifetimeTable)

	local glowplugLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.SmallArray) do
		table.insert(glowplugLifetimeTable, rvb_Utils.getSmallLifetimeString(i))
	end
	self.glowplugLifetimeSet:setTexts(glowplugLifetimeTable)

	local wipersLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(wipersLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.wipersLifetimeSet:setTexts(wipersLifetimeTable)

	local generatorLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(generatorLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.generatorLifetimeSet:setTexts(generatorLifetimeTable)

	local engineLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(engineLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.engineLifetimeSet:setTexts(engineLifetimeTable)

	local selfstarterLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.SmallArray) do
		table.insert(selfstarterLifetimeTable, rvb_Utils.getSmallLifetimeString(i))
	end
	self.selfstarterLifetimeSet:setTexts(selfstarterLifetimeTable)

	local batteryLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(batteryLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.batteryLifetimeSet:setTexts(batteryLifetimeTable)

	local tireLifetimeTable = {}
	for i = 1, rvb_Utils.table_count(rvb_Utils.LargeArray) do
		table.insert(tireLifetimeTable, rvb_Utils.getLargeLifetimeString(i))
	end
	self.tireLifetimeSet:setTexts(tireLifetimeTable)
	self.tireLifetimeSet:setDisabled(true)
	--self.tireLifetimeSet:setDisabled(not self.hasMasterRights)
	
end

function RVBGamePlaySettings_Frame:onFrameOpen()
	RVBGamePlaySettings_Frame:superClass().onFrameOpen(self)

	self:updateValues()
	
	self:updateMenuButtons()

	self.dailyServiceIntervalSet:setDisabled(true)
	
	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.periodicServiceIntervalSet)--boxLayout
		self:setSoundSuppressed(false)
	end

end

function RVBGamePlaySettings_Frame:updateValues()

	local gameplaySettings = self.rvbMain.gameplaySettings

	self.dailyServiceIntervalSet:setState(rvb_Utils.getDailyServiceIndex(gameplaySettings.dailyServiceInterval, 2))
	self.periodicServiceIntervalSet:setState(rvb_Utils.getPeriodicServiceIndex(gameplaySettings.periodicServiceInterval, 1))
	self.repairOnlySetting:setIsChecked(gameplaySettings.repairshop)
	self.workshopOpenSet:setState(rvb_Utils.getWorkshopOpenIndex(gameplaySettings.workshopOpen, 1))
	self.workshopCloseSet:setState(rvb_Utils.getWorkshopCloseIndex(gameplaySettings.workshopClose, 1))
	self.thermostatLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.thermostatLifetime, 30))
	self.lightingsLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.lightingsLifetime, 44))
	self.glowplugLifetimeSet:setState(rvb_Utils.getSmallLifetimeIndex(gameplaySettings.glowplugLifetime, 2))
	self.wipersLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.wipersLifetime, 16))
	self.generatorLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.generatorLifetime, 36))
	self.engineLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.engineLifetime, 42))
	self.selfstarterLifetimeSet:setState(rvb_Utils.getSmallLifetimeIndex(gameplaySettings.selfstarterLifetime, 3))
	self.batteryLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.batteryLifetime, 28))
	self.tireLifetimeSet:setState(rvb_Utils.getLargeLifetimeIndex(gameplaySettings.tireLifetime, 68))

end

function RVBGamePlaySettings_Frame:onFrameClose()
	--self:onSave()
	RVBGamePlaySettings_Frame:superClass().onFrameClose(self)
end

function RVBGamePlaySettings_Frame:onSave()

	local dailyServiceInterval    = rvb_Utils.getDailyServiceFromIndex(self.dailyServiceIntervalSet:getState())
	local periodicServiceInterval = rvb_Utils.getPeriodicServiceFromIndex(self.periodicServiceIntervalSet:getState())
	local repairshop              = self.repairOnlySetting:getIsChecked()
	local workshopOpen            = rvb_Utils.getWorkshopOpenFromIndex(self.workshopOpenSet:getState())
	local workshopClose           = rvb_Utils.getWorkshopCloseFromIndex(self.workshopCloseSet:getState())
	local thermostatLifetime      = rvb_Utils.getLargeLifetimeFromIndex(self.thermostatLifetimeSet:getState())
	local lightingsLifetime       = rvb_Utils.getLargeLifetimeFromIndex(self.lightingsLifetimeSet:getState())
	local glowplugLifetime        = rvb_Utils.getSmallLifetimeFromIndex(self.glowplugLifetimeSet:getState())
	local wipersLifetime          = rvb_Utils.getLargeLifetimeFromIndex(self.wipersLifetimeSet:getState())
	local generatorLifetime       = rvb_Utils.getLargeLifetimeFromIndex(self.generatorLifetimeSet:getState())
	local engineLifetime          = rvb_Utils.getLargeLifetimeFromIndex(self.engineLifetimeSet:getState())
	local selfstarterLifetime     = rvb_Utils.getSmallLifetimeFromIndex(self.selfstarterLifetimeSet:getState())
	local batteryLifetime         = rvb_Utils.getLargeLifetimeFromIndex(self.batteryLifetimeSet:getState())
	local tireLifetime            = rvb_Utils.getLargeLifetimeFromIndex(self.tireLifetimeSet:getState())

	if g_server ~= nil then
		g_server:broadcastEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, thermostatLifetime, lightingsLifetime,
		glowplugLifetime, wipersLifetime, generatorLifetime, engineLifetime, selfstarterLifetime, batteryLifetime, tireLifetime), nil, nil, self)
	else
		g_client:getServerConnection():sendEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, thermostatLifetime, lightingsLifetime,
		glowplugLifetime, wipersLifetime, generatorLifetime, engineLifetime, selfstarterLifetime, batteryLifetime, tireLifetime))
	end

end

function RVBGamePlaySettings_Frame:onReset()
	local function dialogCallback(yes, _)
		if yes then
			self.rvbMain:resetGamePlaySettings()
			self:updateValues()
		end
	end
	g_gui:showYesNoDialog({
		text = self.i18n:getText("ui_RVB_reset_msg"),
		callback = dialogCallback
	})
end

function RVBGamePlaySettings_Frame:onClickPeriodic(state)
	local periodicServiceInterval = rvb_Utils.getPeriodicServiceFromIndex(state)
	if periodicServiceInterval ~= self.rvbMain.gameplaySettings.periodicServiceInterval then
		self.rvbMain:setIsPeriodicServiceInterval(periodicServiceInterval)
		self:onSave()
		Logging.info("[RVB] Settings 'periodicServiceInterval': %s", periodicServiceInterval)
	end
end

function RVBGamePlaySettings_Frame:onClickRepair(state)
	local isEnabled = state == CheckedOptionElement.STATE_CHECKED
	if isEnabled ~= self.rvbMain.gameplaySettings.repairshop then
		self.rvbMain:setIsRepairShop(isEnabled)
		self:onSave()
		Logging.info("[RVB] Settings 'repairshop': ".. tostring(isEnabled))
	end
end

function RVBGamePlaySettings_Frame:onClickWorkshopOpen(state)
	local workshopOpen = rvb_Utils.getWorkshopOpenFromIndex(state)
	if workshopOpen ~= self.rvbMain.gameplaySettings.workshopOpen then
		self.rvbMain:setIsWorkshopOpen(workshopOpen)
		self:onSave()
		Logging.info("[RVB] Settings 'workshopOpen': %s", workshopOpen)
	end
end

function RVBGamePlaySettings_Frame:onClickWorkshopClose(state)
	local workshopClose = rvb_Utils.getWorkshopCloseFromIndex(state)
	if workshopClose ~= self.rvbMain.gameplaySettings.workshopClose then
		self.rvbMain:setIsWorkshopClose(workshopClose)
		self:onSave()
		Logging.info("[RVB] Settings 'workshopClose': %s", workshopClose)
	end
end

function RVBGamePlaySettings_Frame:onClickThermostatLifetime(state)
	local thermostat = rvb_Utils.getLargeLifetimeFromIndex(state)
	thermostat = MathUtil.clamp(thermostat, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if thermostat ~= self.rvbMain.gameplaySettings.thermostatLifetime then
		self.rvbMain:setIsThermostatLifetime(thermostat)
		self:onSave()
		Logging.info("[RVB] Settings 'thermostatLifetime': %s", thermostat)
	end
end

function RVBGamePlaySettings_Frame:onClickLightingsLifetime(state)
	local lightings = rvb_Utils.getLargeLifetimeFromIndex(state)
	lightings = MathUtil.clamp(lightings, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if lightings ~= self.rvbMain.gameplaySettings.lightingsLifetime then
		self.rvbMain:setIsLightingsLifetime(lightings)
		self:onSave()
		Logging.info("[RVB] Settings 'lightingsLifetime': %s", lightings)

		--self.rvbMain:rvbVehicleSetLifetime(2, lightings)
		for _, vehicle in ipairs(g_currentMission.vehicles) do
			if vehicle.spec_faultData ~= nil then
				--vehicle:rvbVehicleSetLifetime(2, lightings)
			end
		end
		
	end
end

function RVBGamePlaySettings_Frame:onClickGlowplugLifetime(state)
	local glowplug = rvb_Utils.getSmallLifetimeFromIndex(state)
	glowplug = MathUtil.clamp(glowplug, rvb_Utils.SmallArrayMin, rvb_Utils.SmallArrayMax)
	if glowplug ~= self.rvbMain.gameplaySettings.glowplugLifetime then
		self.rvbMain:setIsGlowplugLifetime(glowplug)
		self:onSave()
		Logging.info("[RVB] Settings 'glowplugLifetime': %s", glowplug)
	end
end

function RVBGamePlaySettings_Frame:onClickWipersLifetime(state)
	local wipers = rvb_Utils.getLargeLifetimeFromIndex(state)
	wipers = MathUtil.clamp(wipers, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if wipers ~= self.rvbMain.gameplaySettings.wipersLifetime then
		self.rvbMain:setIsWipersLifetime(wipers)
		self:onSave()
		Logging.info("[RVB] Settings 'wipersLifetime': %s", wipers)
	end
end

function RVBGamePlaySettings_Frame:onClickGeneratorLifetime(state)
	local generator = rvb_Utils.getLargeLifetimeFromIndex(state)
	generator = MathUtil.clamp(generator, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if generator ~= self.rvbMain.gameplaySettings.generatorLifetime then
		self.rvbMain:setIsGeneratorLifetime(generator)
		self:onSave()
		Logging.info("[RVB] Settings 'generatorLifetime': %s", generator)
	end
end

function RVBGamePlaySettings_Frame:onClickEngineLifetime(state)
	local engine = rvb_Utils.getLargeLifetimeFromIndex(state)
	engine = MathUtil.clamp(engine, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if engine ~= self.rvbMain.gameplaySettings.engineLifetime then
		self.rvbMain:setIsEngineLifetime(engine)
		self:onSave()
		Logging.info("[RVB] Settings 'engineLifetime': %s", engine)
	end
end

function RVBGamePlaySettings_Frame:onClickSelfstarterLifetime(state)
	local selfstarter = rvb_Utils.getSmallLifetimeFromIndex(state)
	selfstarter = MathUtil.clamp(selfstarter, rvb_Utils.SmallArrayMin, rvb_Utils.SmallArrayMax)
	if selfstarter ~= self.rvbMain.gameplaySettings.selfstarterLifetime then
		self.rvbMain:setIsSelfstarterLifetime(selfstarter)
		self:onSave()
		Logging.info("[RVB] Settings 'selfstarterLifetime': %s", selfstarter)
	end
end

function RVBGamePlaySettings_Frame:onClickBatteryLifetime(state)
	local battery = rvb_Utils.getLargeLifetimeFromIndex(state)
	battery = MathUtil.clamp(battery, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if battery ~= self.rvbMain.gameplaySettings.batteryLifetime then
		self.rvbMain:setIsBatteryLifetime(battery)
		self:onSave()
		Logging.info("[RVB] Settings 'batteryLifetime': %s", battery)
	end
end

function RVBGamePlaySettings_Frame:onClickTierLifetime(state)
	local tire = rvb_Utils.getLargeLifetimeFromIndex(state)
	tire = MathUtil.clamp(tire, rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax)
	if tire ~= self.rvbMain.gameplaySettings.tireLifetime then
		self.rvbMain:setIsTireLifetime(tire)
		self:onSave()
		Logging.info("[RVB] Settings 'tireLifetime': %s", tire)
	end
end

function RVBGamePlaySettings_Frame:setHasMasterRights(hasMasterRights)
	self.hasMasterRights = hasMasterRights

	if g_currentMission ~= nil then
		self:updateMenuButtons()
	end
end

function RVBGamePlaySettings_Frame:setMissionInfo(missionInfo)
	self.missionInfo = missionInfo
end