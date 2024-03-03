
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
    --self.i18n = i18n
    self.i18n = g_i18n.modEnvironments[g_vehicleBreakdownsModName]

    self.defaultMenuButtonInfo = {}
	self.dedicatedMenuButtonInfo = {}
	self.connectedToDedicatedServer = false
	self.pageEnable = false

    return self
end

function RVBTabbedMenu:onGuiSetupFinished()
    RVBTabbedMenu:superClass().onGuiSetupFinished(self)
	
	if self.connectedToDedicatedServer then
        self.messageCenter:subscribe(MessageType.MASTERUSER_ADDED, self.onMasterUserAdded, self)
    end

	self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
		
	self.newvehicleListFrame:initialize()
	self.gameplaySettingFrame:initialize()
	self.generalSettingFrame:initialize()
	
	self:setupMenuPages()
	

	if g_currentMission ~= nil and g_currentMission.connectedToDedicatedServer or self.isClient then
		self:setPageEnabled(RVBGamePlaySettings_Frame, false)
    end	
	self:setupMenuButtonInfo()
	
end

function RVBTabbedMenu:setupMenuPages()

	local ICONS_PATH = Utils.getFilename("icons/rvbgui_icons.dds", g_vehicleBreakdownsDirectory)
    local orderedDefaultPages = {
								 {self.newvehicleListFrame, self:makeIsVListVisiblePredicate(), RVBTabbedMenu.TAB_UV.VLIST_SETTINGS},
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
    return function()
        return true
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

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
    self.clickResetCallback = self:makeSelfCallback(self.onButtonReset)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = self.i18n:getText("button_back"),
        callback = self.clickBackCallback
    }

    self.resetButtonInfo = {
        inputAction = InputAction.MENU_EXTRA_1,
        text = self.i18n:getText("button_reset"),
        callback = self.clickResetCallback
    }

	self.defaultMenuButtonInfo = {
		self.backButtonInfo,
		self.resetButtonInfo
	}
	
    self.defaultMenuButtonInfoByActions = {
        [InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1],
        [InputAction.MENU_EXTRA_1] = self.defaultMenuButtonInfo[2]
    }

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = self.clickBackCallback,
        [InputAction.MENU_EXTRA_1] = self.clickResetCallback
    }

	if g_currentMission ~= nil and g_currentMission.connectedToDedicatedServer or self.isClient then

		self.clickAdminLoginCallback = self:makeSelfCallback(self.onButtonAdminLogin)
		self.adminButtonInfo = {
			inputAction = InputAction.MENU_ACTIVATE,
			text = self.i18n:getText("button_adminLogin"),
			callback = self.clickAdminLoginCallback
		}
		self.dedicatedMenuButtonInfo = {
            self.backButtonInfo,
            self.resetButtonInfo,
			self.adminButtonInfo
        }

        self:setDedicatedMenuButtonInfo(self.dedicatedMenuButtonInfo)
        self.connectedToDedicatedServer = true

	end
		
end

function RVBTabbedMenu:onButtonReset()
    if self.currentPage == nil then
        return
    end

    local function dialogCallback(yes, _)
        if yes then
            self.currentPage:onReset()
        end
    end

    g_gui:showYesNoDialog({
        text = self.i18n:getText("ui_RVB_reset_msg"),
        callback = dialogCallback
    })
end

function RVBTabbedMenu:onButtonAdminLogin()
    if not self.connectedToDedicatedServer then
        return
    end

    g_gui:showPasswordDialog({
        defaultPassword = "",
        text = self.l10n:getText("ui_enterAdminPassword"),
        callback = function(password, yes)
            if yes then
                g_client:getServerConnection():sendEvent(GetAdminEvent.new(password))
            end
        end
    })
end

function RVBTabbedMenu:onMasterUserAdded(user)
    if user:getId() == g_currentMission.playerUserId then
		self.pageEnable = true
        self:setDedicatedMenuButtonInfo(nil)
		
    end
end

function RVBTabbedMenu:setDedicatedMenuButtonInfo(info)

    self.gameplaySettingFrame:setMenuButtonInfo(info)
    self.generalSettingFrame:setMenuButtonInfo(info)

	if self.pageEnable then
		self:setPageEnabled(RVBGamePlaySettings_Frame, true)
	else
		self:setPageEnabled(RVBGamePlaySettings_Frame, false)
    end	
	
    if self.currentPage ~= nil then

		self:updateButtonsPanel(self.currentPage)
        self:updatePages()

    end
end