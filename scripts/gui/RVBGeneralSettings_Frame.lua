
RVBGeneralSettings_Frame = {}
local RVBGeneralSettings_Frame_mt = Class(RVBGeneralSettings_Frame, TabbedMenuFrameElement)

RVBGeneralSettings_Frame.CONTROLS = {"alertMessageSetting", "difficultySet", "basicrepairtriggerSetting", "settingsContainer", "debugDisplaySetting", "boxLayout"}

function RVBGeneralSettings_Frame.new(rvbMain, modName)
	local self = TabbedMenuFrameElement.new(nil, RVBGeneralSettings_Frame_mt)

	self:registerControls(RVBGeneralSettings_Frame.CONTROLS)

	self.rvbMain = rvbMain
	self.modName = modName
	self.selectedItem = nil
	self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]

	self.adminButtonInfo = {}
	self.currentUser = User.new()
	self.messageCenter = g_messageCenter

	return self
end

function RVBGeneralSettings_Frame:copyAttributes(src)
	RVBGeneralSettings_Frame:superClass().copyAttributes(self, src)

	self.rvbMain = src.rvbMain
	self.modName = src.modName
	self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]
	self.messageCenter = src.messageCenter

end

function RVBGeneralSettings_Frame:initialize()

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

	self.adminButtonInfo = {
		inputAction = InputAction.MENU_ACTIVATE,
		text = self.i18n:getText("button_adminLogin"),
		callback = function ()
			self:onButtonAdminLogin()
		end
	}

end

function RVBGeneralSettings_Frame:assignStaticTexts()

	local textsNoYes = { self.i18n:getText("ui_off"), self.i18n:getText("ui_on") }

	self.alertMessageSetting:setTexts(textsNoYes)

	local difficultyTable = {}
	table.insert(difficultyTable, self.i18n:getText("ui_RVB_difficulty1_subtitle"))
	table.insert(difficultyTable, self.i18n:getText("ui_RVB_difficulty2_subtitle"))
	table.insert(difficultyTable, self.i18n:getText("ui_RVB_difficulty3_subtitle"))
	self.difficultySet:setTexts(difficultyTable)

	self.basicrepairtriggerSetting:setTexts(textsNoYes)
	
	self.debugDisplaySetting:setTexts(textsNoYes)

end

function RVBGeneralSettings_Frame:onFrameOpen()
	RVBGeneralSettings_Frame:superClass().onFrameOpen(self)

	self.messageCenter:subscribe(MessageType.MASTERUSER_ADDED, self.onMasterUserAdded, self)

	self:setCurrentUserId(g_currentMission.playerUserId)
	self:updateValues()
	self:updateMenuButtons()

	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.boxLayout)
		self:setSoundSuppressed(false)
	end

end

function RVBGeneralSettings_Frame:setCurrentUserId(userId)
	self.currentUserId = userId
	self.currentUser = g_currentMission.userManager:getUserByUserId(userId) or self.currentUser

	self:updateMenuButtons()
end

function RVBGeneralSettings_Frame:onMasterUserAdded()
	self:updateMenuButtons()
end

function RVBGeneralSettings_Frame:onButtonAdminLogin()
	g_gui:showPasswordDialog({
		defaultPassword = "",
		text = self.i18n:getText("ui_enterAdminPassword"),
		callback = self.onAdminPassword,
		target = self
	})
end

function RVBGeneralSettings_Frame:onAdminPassword(password, yes)
	if yes then
		g_client:getServerConnection():sendEvent(GetAdminEvent.new(password))
	end
end

function RVBGeneralSettings_Frame:updateMenuButtons()
	self.menuButtonInfo = {
		self.backButtonInfo,
		self.resetButtonInfo
	}

	if g_currentMission ~= nil then
		if g_currentMission ~= nil and g_currentMission.connectedToDedicatedServer and not self.currentUser:getIsMasterUser() then
			table.insert(self.menuButtonInfo, self.adminButtonInfo)
		end
	end

	self:setMenuButtonInfoDirty()
end

function RVBGeneralSettings_Frame:updateValues()
	local generalSettings = self.rvbMain.generalSettings

	self.alertMessageSetting:setIsChecked(self.rvbMain:getIsAlertMessage())

	self.difficultySet:setState(generalSettings.difficulty)

	self.basicrepairtriggerSetting:setIsChecked(self.rvbMain:getIsBasicRepairTrigger())
	
	self.debugDisplaySetting:setIsChecked(self.rvbMain:getIsDebugDisplay())

end

function RVBGeneralSettings_Frame:onFrameClose()
	self:onSave()
	RVBGeneralSettings_Frame:superClass().onFrameClose(self)
	self.messageCenter:unsubscribeAll(self)
end

function RVBGeneralSettings_Frame:onSave()

	local alertmessage = self.alertMessageSetting:getIsChecked()
	local difficulty = self.difficultySet:getState()
	local basicrepairtrigger = self.basicrepairtriggerSetting:getIsChecked()
	local debugdisplay = self.debugDisplaySetting:getIsChecked()

	if g_server ~= nil then
		g_server:broadcastEvent(RVBGeneralSet_Event.new(alertmessage, difficulty, basicrepairtrigger, debugdisplay, self.rvbMain.generalSettings.cp_notice), nil, nil, self)
	else
		g_client:getServerConnection():sendEvent(RVBGeneralSet_Event.new(alertmessage, difficulty, basicrepairtrigger, debugdisplay, self.rvbMain.generalSettings.cp_notice))
	end

	--self.rvbMain:setIsAlertMessage(alertmessage)
	--self.rvbMain:setIsRVBDifficulty(difficulty)
	--self.rvbMain:setIsBasicRepairTrigger(basicrepairtrigger)
	self.rvbMain:saveGeneralettingsToXML()

end

function RVBGeneralSettings_Frame:onReset()
	local function dialogCallback(yes, _)
		if yes then
			self.rvbMain:resetGeneralSettings()
			self:updateValues()
		end
	end
	g_gui:showYesNoDialog({
		text = self.i18n:getText("ui_RVB_reset_msg"),
		callback = dialogCallback
	})
end

function RVBGeneralSettings_Frame:onClickAlert(state)
	local isEnabled = state == CheckedOptionElement.STATE_CHECKED
	if isEnabled ~= self.rvbMain.generalSettings.alertmessage then
		self.rvbMain:setIsAlertMessage(isEnabled)
		self:onSave()
		Logging.info("[RVB] Settings 'alertmessage': ".. tostring(isEnabled))
	end
end

function RVBGeneralSettings_Frame:onClickrvbDifficulty(state)
	local difficulty = state
	if difficulty ~= self.rvbMain.generalSettings.difficulty then
		self.rvbMain:setIsRVBDifficulty(difficulty)
		self:onSave()
		Logging.info("[RVB] Setting 'difficulty': %s", difficulty)
	end
end

function RVBGeneralSettings_Frame:onClickBasicRepairTrigger(state)
	local isEnabled = state == CheckedOptionElement.STATE_CHECKED
	if isEnabled ~= self.rvbMain.generalSettings.basicrepairtrigger then
		self.rvbMain:setIsBasicRepairTrigger(isEnabled)
		self:onSave()
		Logging.info("[RVB] Settings 'basicrepairtrigger': ".. tostring(isEnabled))
	end
end

function RVBGeneralSettings_Frame:onClickDebug(state)
	local isEnabled = state == CheckedOptionElement.STATE_CHECKED
	if isEnabled ~= self.rvbMain.generalSettings.debugdisplay then
		self.rvbMain:setIsDebugDisplay(isEnabled)
		self:onSave()
		Logging.info("[RVB] Settings 'debugdisplay': ".. tostring(isEnabled))
	end
end