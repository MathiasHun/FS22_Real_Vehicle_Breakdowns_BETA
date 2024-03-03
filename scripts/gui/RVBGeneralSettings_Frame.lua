
RVBGeneralSettings_Frame = {}
local RVBGeneralSettings_Frame_mt = Class(RVBGeneralSettings_Frame, TabbedMenuFrameElement)

RVBGeneralSettings_Frame.CONTROLS = {"alertMessageSetting", "settingsContainer", "boxLayout"}

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

end

function RVBGeneralSettings_Frame:onFrameClose()
	self:onSave()
    RVBGeneralSettings_Frame:superClass().onFrameClose(self)
end
	
function RVBGeneralSettings_Frame:onSave()
	
	local alertmessage = self.alertMessageSetting:getIsChecked()
	if g_server ~= nil then
		g_server:broadcastEvent(RVBGeneralSet_Event.new(alertmessage))
    else
		g_client:getServerConnection():sendEvent(RVBGeneralSet_Event.new(alertmessage))
    end
	
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