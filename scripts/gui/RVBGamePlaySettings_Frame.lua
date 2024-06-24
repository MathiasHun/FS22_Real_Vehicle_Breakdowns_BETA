
RVBGamePlaySettings_Frame = {}
local RVBGamePlaySettings_Frame_mt = Class(RVBGamePlaySettings_Frame, TabbedMenuFrameElement)

RVBGamePlaySettings_Frame.CONTROLS = {"dailyServiceIntervalSet", "periodicServiceIntervalSet", "repairOnlySetting", "workshopOpenSet", "workshopCloseSet", "settingsContainer", "boxLayout"}

function RVBGamePlaySettings_Frame.new(rvbMain, modName)
    local self = TabbedMenuFrameElement.new(nil, RVBGamePlaySettings_Frame_mt)
    self:registerControls(RVBGamePlaySettings_Frame.CONTROLS)

    self.rvbMain = rvbMain
    self.modName = modName
    self.selectedItem = nil
    self.i18n = g_i18n.modEnvironments[modName]
	
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

end

function RVBGamePlaySettings_Frame:assignStaticTexts()

	local textsNoYes = { self.i18n:getText("ui_off"), self.i18n:getText("ui_on") }

	local daily_values = stream(RVBMain.DAILY_ServiceInterval):map(function(daily_value)
        return tostring(daily_value)
    end)
    self.daily_values = daily_values:toList()
	self.dailyServiceIntervalSet:setTexts(self.daily_values)
	-- deactivate
	self.dailyServiceIntervalSet:setDisabled(true)
	
	local periodic_values = stream(RVBMain.PERIODIC_ServiceInterval):map(function(periodic_value)
        return tostring(periodic_value)
    end)
    self.periodic_values = periodic_values:toList()
	self.periodicServiceIntervalSet:setTexts(self.periodic_values)
	
	self.repairOnlySetting:setTexts(textsNoYes)
	
	local workshopO_values = stream(RVBMain.HOURS_workshopOpen):map(function(workshopO_value)
        return tostring(workshopO_value)
    end)
    self.workshopO_values = workshopO_values:toList()
	self.workshopOpenSet:setTexts(self.workshopO_values)
	
	local workshopC_values = stream(RVBMain.HOURS_workshopClose):map(function(workshopC_value)
        return tostring(workshopC_value)
    end)
    self.workshopC_values = workshopC_values:toList()
	self.workshopCloseSet:setTexts(self.workshopC_values)

end

function RVBGamePlaySettings_Frame:onFrameOpen()
	RVBGamePlaySettings_Frame:superClass().onFrameOpen(self)

	self:updateValues()
	
	self.dailyServiceIntervalSet:setDisabled(true)
	
	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.boxLayout)
		self:setSoundSuppressed(false)
	end

end

function RVBGamePlaySettings_Frame:updateValues()
    local gameplaySettings = self.rvbMain.gameplaySettings

	for index, value in pairs(RVBMain.DAILY_ServiceInterval) do
		if value == gameplaySettings.dailyServiceInterval then
			gameplaySettings.dailyServiceIntervalState = index
		end
	end		
	self.dailyServiceIntervalSet:setState(gameplaySettings.dailyServiceIntervalState)
	
	for index, value in pairs(RVBMain.PERIODIC_ServiceInterval) do
		if value == gameplaySettings.periodicServiceInterval then
			gameplaySettings.periodicServiceIntervalState = index
		end
	end
	self.periodicServiceIntervalSet:setState(gameplaySettings.periodicServiceIntervalState)
	self.repairOnlySetting:setIsChecked(gameplaySettings.repairshop)
	
	for index, value in pairs(RVBMain.HOURS_workshopOpen) do
		if value == gameplaySettings.workshopOpen then
			gameplaySettings.workshopOpenState = index
		end
	end
	self.workshopOpenSet:setState(gameplaySettings.workshopOpenState)
	
	for index, value in pairs(RVBMain.HOURS_workshopClose) do
		if value == gameplaySettings.workshopClose then
			gameplaySettings.workshopCloseState = index
		end
	end
	self.workshopCloseSet:setState(gameplaySettings.workshopCloseState)

end

function RVBGamePlaySettings_Frame:onFrameClose()
	self:onSave()
    RVBGamePlaySettings_Frame:superClass().onFrameClose(self)
end

function RVBGamePlaySettings_Frame:onSave()

	local dailyServiceInterval = self.dailyServiceIntervalSet:getState()
	local periodicServiceInterval = self.periodicServiceIntervalSet:getState()
	local repairshop = self.repairOnlySetting:getIsChecked()
	local workshopOpen = self.workshopOpenSet:getState()
	local workshopClose = self.workshopCloseSet:getState()

	if g_server ~= nil then
		g_server:broadcastEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose), nil, nil, self)
    else
		g_client:getServerConnection():sendEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose))
    end

end

function RVBGamePlaySettings_Frame:onReset()
    self.rvbMain:resetGamePlaySettings()
    self:updateValues()
end

function RVBGamePlaySettings_Frame:onClickPeriodic(state)
	self.rvbMain:setIsPeriodicServiceInterval(state)
	Logging.info("[RVB] Settings 'periodicServiceInterval': "..self.rvbMain.PERIODIC_ServiceInterval[state])
end

function RVBGamePlaySettings_Frame:onClickRepair(state)
	local _state = state == CheckedOptionElement.STATE_CHECKED
	self:onSave()
	self.rvbMain:setIsRepairShop(_state)
	Logging.info("[RVB] Settings 'repairshop': ".. tostring(_state)..state)
end

function RVBGamePlaySettings_Frame:onClickWorkshopOpen(state)
	self.rvbMain:setIsWorkshopOpen(state)
	Logging.info("[RVB] Settings 'workshopOpen': "..self.rvbMain.HOURS_workshopOpen[state])
end

function RVBGamePlaySettings_Frame:onClickWorkshopClose(state)
	self.rvbMain:setIsWorkshopClose(state)
	Logging.info("[RVB] Settings 'workshopClose': "..self.rvbMain.HOURS_workshopClose[state])
end
