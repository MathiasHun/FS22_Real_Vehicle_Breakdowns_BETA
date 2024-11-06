
RVBTabbedMenu = {}

local RVBTabbedMenu_mt = Class(RVBTabbedMenu, TabbedMenu)

RVBTabbedMenu.CONTROLS = {"vehicleListFrame", "gameplaySettingFrame", "generalSettingFrame"}

RVBTabbedMenu.TAB_UV = {
	GAMEPLAY_SETTINGS = {64, 0, 64, 64},
	GENERAL_SETTINGS = {0, 0, 64, 64},
	VLIST_SETTINGS = {128, 0, 64, 64}
}

RVBTabbedMenu.L10N_SYMBOL = {
	BUTTON_ADMIN = "button_adminLogin"
}

function RVBTabbedMenu:new(messageCenter, i18n, inputManager, modDirectory)
	local self = TabbedMenu.new(nil, RVBTabbedMenu_mt, messageCenter, i18n, inputManager)

	self:registerControls(RVBTabbedMenu.CONTROLS)

	self.modDirectory = modDirectory
	self.selectedItem = nil
	self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]
	self.missionDynamicInfo = {}
	self.defaultMenuButtonInfo = {}
	self.server = nil
	self.isMasterUser = false
	self.isServer = false
	
	return self
end

function RVBTabbedMenu:onGuiSetupFinished()
	RVBTabbedMenu:superClass().onGuiSetupFinished(self)

	self.messageCenter:subscribe(MessageType.MASTERUSER_ADDED, self.onMasterUserAdded, self)

	self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)

	self.vehicleListFrame:initialize()

	if not GS_IS_MOBILE_VERSION then
		self.gameplaySettingFrame:initialize()
		self.generalSettingFrame:initialize()
	end

	self:setupMenuPages()
	--self:setupMenuButtonInfo()

end

function RVBTabbedMenu:setupMenuPages()

	local ICONS_PATH = Utils.getFilename("icons/rvbgui_icons.dds", g_vehicleBreakdownsDirectory)
	local orderedDefaultPages = {
								 {self.vehicleListFrame, self:makeIsVListVisiblePredicate(), RVBTabbedMenu.TAB_UV.VLIST_SETTINGS},
								 {self.gameplaySettingFrame, self:makeIsGeneralSettingsVisiblePredicate(), RVBTabbedMenu.TAB_UV.GAMEPLAY_SETTINGS},
								 {self.generalSettingFrame, self:makeIsServicesVisiblePredicate(), RVBTabbedMenu.TAB_UV.GENERAL_SETTINGS}
								}

	for i, pageDef in ipairs(orderedDefaultPages) do
		local page, predicate, iconUVs = unpack(pageDef)

		if page ~= nil then
			self:registerPage(page, i, predicate)
			local normalizedUVs = GuiUtils.getUVs(iconUVs)
			self:addPageTab(page, ICONS_PATH, normalizedUVs)
		end
	end

end

function RVBTabbedMenu:makeIsGeneralSettingsVisiblePredicate()
	return function ()
		local isMultiplayer = self.missionDynamicInfo.isMultiplayer
		local canChangeSettings = not isMultiplayer or isMultiplayer and self.isServer or self.isMasterUser

		return canChangeSettings
	end
end

function RVBTabbedMenu:makeIsServicesVisiblePredicate()
	return function()
		return true
	end
end

function RVBTabbedMenu:makeIsVListVisiblePredicate()
	return function()
		return true
	end
end

function RVBTabbedMenu:onClose()
	self.gameplaySettingFrame:onSave()
	self.generalSettingFrame:onSave()
	RVBTabbedMenu:superClass().onClose(self)
end

function RVBTabbedMenu:setupMenuButtonInfo()
	RVBTabbedMenu:superClass().setupMenuButtonInfo(self)

	local onButtonBackFunction = self.clickBackCallback

	self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK,
		text = self.i18n:getText("button_back"),
		callback = onButtonBackFunction
	}

	if GS_IS_MOBILE_VERSION then
		self.defaultMenuButtonInfo = {
			self.backButtonInfo
		}
	else
		self.defaultMenuButtonInfo = {
			self.backButtonInfo
		}
	end

	 self.defaultMenuButtonInfoByActions = {
		[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]
	}

	self.defaultButtonActionCallbacks = {
		[InputAction.MENU_BACK] = onButtonBackFunction
	}

end

function RVBTabbedMenu:setServer(server)
	self.server = server
	self.isServer = server ~= nil

	self:updateHasMasterRights()
end

function RVBTabbedMenu:setMissionInfo(missionInfo, missionDynamicInfo, missionBaseDirectory)
	self.missionInfo = missionInfo
	self.missionDynamicInfo = missionDynamicInfo

	if self.gameplaySettingFrame ~= nil then
		self.gameplaySettingFrame:setMissionInfo(missionInfo)
	end
end

function RVBTabbedMenu:updateHasMasterRights()
	local hasMasterRights = self.isMasterUser or self.isServer

	if self.gameplaySettingFrame ~= nil then
		self.gameplaySettingFrame:setHasMasterRights(hasMasterRights)
	end

	if self.currentPage ~= nil then
		self:updatePages()
	end
end

function RVBTabbedMenu:onMasterUserAdded(user)
	if user:getId() == g_currentMission.playerUserId then
		self.isMasterUser = true

		self:updateHasMasterRights()
	end
end