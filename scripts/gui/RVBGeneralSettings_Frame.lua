
RVBGeneralSettings_Frame = {}
local RVBGeneralSettings_Frame_mt = Class(RVBGeneralSettings_Frame, TabbedMenuFrameElement)

RVBGeneralSettings_Frame.CONTROLS = {"alertMessageSetting", "rvbDifficulty", "basicrepairtriggerSetting", "settingsContainer", "boxLayout"}

function RVBGeneralSettings_Frame.new(rvbMain, modName)
    local self = TabbedMenuFrameElement.new(nil, RVBGeneralSettings_Frame_mt)
	
    self:registerControls(RVBGeneralSettings_Frame.CONTROLS)

    self.rvbMain = rvbMain
    self.modName = modName
    self.selectedItem = nil
    self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]
	
    return self
end

function RVBGeneralSettings_Frame:copyAttributes(src)
    RVBGeneralSettings_Frame:superClass().copyAttributes(self, src)

    self.rvbMain = src.rvbMain
    self.modName = src.modName
    self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]
	
end

function RVBGeneralSettings_Frame:initialize()
	
    self:assignStaticTexts()

end

function RVBGeneralSettings_Frame:assignStaticTexts()

	local textsNoYes = { self.i18n:getText("ui_off"), self.i18n:getText("ui_on") }

    self.alertMessageSetting:setTexts(textsNoYes)

	local difficulty_values = stream(self.rvbMain.DIFFICULTY_A):map(function(difficulty_value)
		return tostring(difficulty_value)
    end)
    self.difficulty_values = difficulty_values:toList()
	self.rvbDifficulty:setTexts(self.difficulty_values)
	
	self.basicrepairtriggerSetting:setTexts(textsNoYes)

end

function RVBGeneralSettings_Frame:onFrameOpen()
	RVBGeneralSettings_Frame:superClass().onFrameOpen(self)

    self:updateValues()

	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.boxLayout)
		self:setSoundSuppressed(false)
	end
	
end

function RVBGeneralSettings_Frame:updateValues()
    local generalSettings = self.rvbMain.generalSettings

	self.alertMessageSetting:setIsChecked(self.rvbMain:getIsAlertMessage())

	for index, value in pairs(self.rvbMain.DIFFICULTY_A) do
		if index == generalSettings.rvbDifficultyState then
			generalSettings.rvbDifficulty = self.rvbMain.DIFFICULTY_A[index]
		end
	end
	self.rvbDifficulty:setState(generalSettings.rvbDifficultyState)
	
	self.basicrepairtriggerSetting:setIsChecked(self.rvbMain:getIsBasicRepairTrigger())
	
end

function RVBGeneralSettings_Frame:onFrameClose()
	self:onSave()
    RVBGeneralSettings_Frame:superClass().onFrameClose(self)
end
	
function RVBGeneralSettings_Frame:onSave()
	
	local alertmessage = self.alertMessageSetting:getIsChecked()
	local rvbDifficulty = self.rvbDifficulty:getState()
	local basicrepairtrigger = self.basicrepairtriggerSetting:getIsChecked()

	if g_server ~= nil then
		g_server:broadcastEvent(RVBGeneralSet_Event.new(alertmessage, rvbDifficulty, basicrepairtrigger, self.rvbMain.generalSettings.cp_notice))
    else
		--g_client:getServerConnection():sendEvent(RVBGeneralSet_Event.new(alertmessage, rvbDifficulty, self.rvbMain.generalSettings.cp_notice))
    end
	
	self.rvbMain:saveGeneralettingsToXML()
	
end

function RVBGeneralSettings_Frame:onReset()
    self.rvbMain:resetGeneralSettings()
    self:updateValues()
end

function RVBGeneralSettings_Frame:onClickAlert(state)
	local _state = state == CheckedOptionElement.STATE_CHECKED
	self.rvbMain:setIsAlertMessage(_state)
	Logging.info("[RVB] Settings 'alertmessage': ".. tostring(_state))
end

function RVBGeneralSettings_Frame:onClickrvbDifficulty(state)
	self.rvbMain:setIsRVBDifficulty(state)
	Logging.info("[RVB] Settings 'rvbDifficulty': "..self.rvbMain.DIFFICULTY_A[state])
end

function RVBGeneralSettings_Frame:onClickBasicRepairTrigger(state)
	local _state = state == CheckedOptionElement.STATE_CHECKED
	self.rvbMain:setIsBasicRepairTrigger(_state)
	Logging.info("[RVB] Settings 'basicrepairtrigger': ".. tostring(_state))
end
