
RVBMain = {}
local RVBMain_mt = Class(RVBMain)

RVBMain.alertmessage = true
RVBMain.difficulty = 2
RVBMain.basicrepairtrigger = true
RVBMain.repairshop = true

RVBMain.dailyServiceInterval = 6
RVBMain.periodicServiceInterval = 40
RVBMain.workshopOpen = 7
RVBMain.workshopClose = 16

RVBMain.cp_notice = false

RVBMain.thermostatLifetime = 150
RVBMain.lightingsLifetime = 220
RVBMain.glowplugLifetime = 2
RVBMain.wipersLifetime = 80
RVBMain.generatorLifetime = 180
RVBMain.engineLifetime = 210
RVBMain.selfstarterLifetime = 3
RVBMain.batteryLifetime = 140
RVBMain.tireLifetime = 340
	
RVBMain.DEFAULT_SETTINGS = {
	alertmessage = RVBMain.alertmessage,
	difficulty = RVBMain.difficulty,
	basicrepairtrigger = RVBMain.basicrepairtrigger,
	repairshop = RVBMain.repairshop,
	dailyServiceInterval = RVBMain.dailyServiceInterval,
	periodicServiceInterval = RVBMain.periodicServiceInterval,
	workshopOpen = RVBMain.workshopOpen,
	workshopClose = RVBMain.workshopClose,
	cp_notice = RVBMain.cp_notice,
	thermostatLifetime = RVBMain.thermostatLifetime,
	lightingsLifetime = RVBMain.lightingsLifetime,
	glowplugLifetime = RVBMain.glowplugLifetime,
	wipersLifetime = RVBMain.wipersLifetime,
	generatorLifetime = RVBMain.generatorLifetime,
	engineLifetime = RVBMain.engineLifetime,
	selfstarterLifetime = RVBMain.selfstarterLifetime,
	batteryLifetime = RVBMain.batteryLifetime,
	tireLifetime = RVBMain.tireLifetime
}
RVBMain.actions = {{
    name = InputAction.VEHICLE_BREAKDOWN_MENU,
    priority = GS_PRIO_HIGH
}}

local popupMessage

function RVBMain:new(modDirectory, modName)
    local self = {}

    setmetatable(self, RVBMain_mt)

    self.modDirectory = modDirectory
    self.modName = modName
    
	self.gameplaySettings = {}
	self.generalSettings = {}
	self.actionEvents = {}

    return self
end

function RVBMain:onMissionLoaded(mission)
	
	self:registerGamePlaySettingsSchema()
	self:registerGeneralSettingsSchema()

	self.mission = mission

	-- game play settings
	local DEFAUL_GAMEPLAY_SETTINGS_XML = Utils.getFilename("config/DefaultGamePlaySettings.xml", self.modDirectory)
	
	local savegameFolderPath = self.mission.missionInfo.savegameDirectory
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), math.floor(self.mission.missionInfo.savegameIndex))
	end
	
	local GAMEPLAY_SETTINGS_XML = Utils.getFilename("/RVBGamePlaySettings.xml", savegameFolderPath)

	if fileExists(GAMEPLAY_SETTINGS_XML) then
		self:loadGamePlaySettingsFromXml(GAMEPLAY_SETTINGS_XML)
	else
		copyFile(DEFAUL_GAMEPLAY_SETTINGS_XML, GAMEPLAY_SETTINGS_XML, false)
		self:resetGamePlaySettings()
	end
	
	-- general settings
	local VEHICLE_BREAKDOWN_FOLDER = getUserProfileAppPath() .. "modSettings/FS22_gameplay_Real_Vehicle_Breakdowns/"
	createFolder(VEHICLE_BREAKDOWN_FOLDER)
	
	local GENERAL_SETTINGS_XML = Utils.getFilename("RVBGeneralSettings.xml", VEHICLE_BREAKDOWN_FOLDER)
	local DEFAUL_GENERAL_SETTINGS_XML = Utils.getFilename("config/DefaultGeneralSettings.xml", self.modDirectory)

	if fileExists(GENERAL_SETTINGS_XML) then
		self:loadGeneralSettingsFromXml(GENERAL_SETTINGS_XML)
	else
		copyFile(DEFAUL_GENERAL_SETTINGS_XML, GENERAL_SETTINGS_XML, false)
		self:resetGeneralSettings()
	end
	
	-- hud
	self.ui_hud = RVB_HUD:new(self.mission.hud.speedMeter, self.mission.hud.gameInfoDisplay, self.modDirectory)
	self.ui_hud:load()


	g_gui:loadProfiles(self.modDirectory .. "gui/guiProfiles.xml")

    -- menu
    local gameplaySettingFrame = RVBGamePlaySettings_Frame.new(self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBGamePlaySettings_Frame.xml", "RVBGamePlaySettings_Frame", gameplaySettingFrame, true)
	
	local generalSettingFrame = RVBGeneralSettings_Frame.new(self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBGeneralSettings_Frame.xml", "RVBGeneralSettings_Frame", generalSettingFrame, true)
	
	local vehicleListFrame = RVBVehicleList_Frame.new(self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBVehicleList_Frame.xml", "RVBVehicleList_Frame", vehicleListFrame, true)

    self.menu = RVBTabbedMenu:new(g_messageCenter, g_i18n, g_inputBinding, self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBTabbedMenu.xml", "RVBTabbedMenu", self.menu)

	self.menu:setMissionInfo(self.mission.missionInfo, self.mission.missionDynamicInfo, self.modDirectory)
	self.menu:setServer(g_server)
	
	local conflictList = {}
	if g_modIsLoaded["FS22_Courseplay"] then
		if FS22_Courseplay ~= nil and FS22_Courseplay.WearableController.autoRepair ~= nil then
			table.insert(conflictList, "CoursePlay")
			FS22_Courseplay.WearableController.autoRepair = Utils.overwrittenFunction(FS22_Courseplay.WearableController.autoRepair, RVBMain.autoRepair)
		end
	end

	if g_modIsLoaded["FS22_AutoDrive"] then
		if FS22_AutoDrive ~= nil and FS22_AutoDrive.ADTaskModule.hasToRepair ~= nil then
			table.insert(conflictList, "AutoDrive")
			FS22_AutoDrive.ADTaskModule.hasToRepair = Utils.overwrittenFunction(FS22_AutoDrive.ADTaskModule.hasToRepair, RVBMain.hasToRepair)
		end
	end

	if table.maxn(conflictList) > 0 then
		popupMessage = {
			startUpdateTime = 4000,
			update = function(self, dt)
				self.startUpdateTime = self.startUpdateTime - dt
				if self.startUpdateTime < 0 and not g_gui:getIsGuiVisible() then
					if g_currentMission.hud ~= nil then
						local message = g_i18n:getText("Automatic_Repair_conflict_notice").."\n"..g_i18n:getText("Automatic_Repair_conflict_list")..table.concat(conflictList,", ").."\n"..g_i18n:getText("Automatic_Repair_conflict_signature")
						g_currentMission.hud:showInGameMessage("", message or "", -1, nil, nil, nil)
					end
					removeModEventListener(self)
					popupMessage = nil
				end
			end
		}
		if not self.generalSettings.cp_notice then
			addModEventListener(popupMessage)
			self.generalSettings.cp_notice = true
			
			self:saveGeneralettingsToXML()
			if g_server ~= nil then
				--g_server:broadcastEvent(RVBGeneralSet_Event.new(self.generalSettings.alertmessage, self.generalSettings.difficulty, self.generalSettings.basicrepairtrigger, self.generalSettings.cp_notice), nil, nil, self)
			else
				--g_client:getServerConnection():sendEvent(RVBGeneralSet_Event.new(self.generalSettings.alertmessage, self.generalSettings.difficulty, self.generalSettings.basicrepairtrigger, self.generalSettings.cp_notice))
			end
		end
	end
	
	if g_modIsLoaded["FS22_ToolBoxPack"] then
		if FS22_ToolBoxPack ~= nil and FS22_ToolBoxPack.ServiceVehicleWorkshop.openMenu ~= nil then
			FS22_ToolBoxPack.ServiceVehicleWorkshop.openMenu = Utils.overwrittenFunction(FS22_ToolBoxPack.ServiceVehicleWorkshop.openMenu, RVBMain.RVBopenMenu)
		end
	end
	
	if g_modIsLoaded["FS22_lsfmFarmEquipmentPack"] then
		if FS22_lsfmFarmEquipmentPack ~= nil and FS22_lsfmFarmEquipmentPack.ServiceVehicleWorkshop.openMenu ~= nil then
			FS22_lsfmFarmEquipmentPack.ServiceVehicleWorkshop.openMenu = Utils.overwrittenFunction(FS22_lsfmFarmEquipmentPack.ServiceVehicleWorkshop.openMenu, RVBMain.RVBopenMenu)
		end
	end
	
	if g_currentMission.missionInfo.automaticMotorStartEnabled then
		g_currentMission:setAutomaticMotorStartEnabled(false, true)
	end

end

-- Original CP WearableController:autoRepair()
function RVBMain:autoRepair(superFunc)
	--if self:isBrokenGreaterThan(100-self.autoRepairSetting:getValue()) then 
	--	self.implement:repairVehicle()
	--end
end

-- Original AD ADTaskModule hasToRepair()
function RVBMain:hasToRepair()
    local repairNeeded = false
--    if self.vehicle.ad.onRouteToRepair then
        -- repair is forced by user or CP, so send vehicle to workshop independent of damage level
--        return true
--    end
--    if AutoDrive.getSetting("autoRepair", self.vehicle) then
--        local attachedObjects = AutoDrive.getAllImplements(self.vehicle, true)
--        for _, attachedObject in pairs(attachedObjects) do
--            repairNeeded = repairNeeded or (attachedObject.spec_wearable ~= nil and attachedObject.spec_wearable.damage > 0.6)
--        end
--    end
    return repairNeeded
end
	
function RVBMain.installSpecializations(vehicleTypeManager, specializationManager, modDirectory, modName)
    specializationManager:addSpecialization("vehicleBreakdowns", "VehicleBreakdowns", Utils.getFilename("scripts/vehicles/specializations/VehicleBreakdowns.lua", modDirectory), nil)

    if specializationManager:getSpecializationByName("vehicleBreakdowns") == nil then
		Logging.error("[RVB] getSpecializationByName(\"vehicleBreakdowns\") == nil")
    else
        for typeName, typeEntry in pairs(vehicleTypeManager:getTypes()) do
			
			if typeEntry ~= nil and typeName ~= "locomotive" and typeName ~= "trainTrailer" and typeName ~= "trainTimberTrailer" and typeName ~= "conveyorBelt" and typeName ~= "pickupConveyorBelt" 
			and typeName ~= "FS22_lsfmFarmEquipmentPack.wheelBarrow" and typeName ~= "FS22_lsfmFarmEquipmentPack.wheelBarrowHay" 
			and typeName ~= "FS22_lsfmFarmEquipmentPack.bicycle" and typeName ~= "FS22_lsfmFarmEquipmentPack.transportBarrow" and typeName ~= "FS22_lsfmFarmEquipmentPack.milkShuttle"
			and typeName ~= "FS22_lsfmFarmEquipmentPack.transportBarrowBarrel" and typeName ~= "FS22_lsfmFarmEquipmentPack.transportBarrelModul" and typeName ~= "FS22_Wheelbarrow.handTool" then -- portableToolbox
				if SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) and
					SpecializationUtil.hasSpecialization(Enterable, typeEntry.specializations) and
					SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations) then
						vehicleTypeManager:addSpecialization(typeName, modName .. ".vehicleBreakdowns")
						Logging.info("[RVB] Add specialization "..typeName)
				end
			else
				Logging.info("[RVB] Failed to add specialization "..typeName)
            end
			
        end
    end
end

function RVBMain:registerGamePlaySettingsSchema()

    self.gameplaySettingSchema = XMLSchema.new("rvbGamePlaySettings")
    local schemaKey = "rvbGamePlaySettings"
	
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".dailyServiceInterval#value", "Daily Service Interval")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".periodicServiceInterval#value", "Periodic Service Interval")
	self.gameplaySettingSchema:register(XMLValueType.BOOL, schemaKey .. ".repairshop#value", "Repair only in vehicle workshop")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".workshopOpen#value", "Workshop opening")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".workshopClose#value", "Workshop closing")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".thermostatLifetime", "Thermostat Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".lightingsLifetime", "Lightings Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".glowplugLifetime", "Glowplug Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".wipersLifetime", "Wipers Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".generatorLifetime", "Generator Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".engineLifetime", "Engine Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".selfstarterLifetime", "Selfstarter Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".batteryLifetime", "Battery Lifetime")
	self.gameplaySettingSchema:register(XMLValueType.INT, schemaKey .. ".tireLifetime", "Tire Lifetime")

end
	
function RVBMain:registerGeneralSettingsSchema()
	
	self.generalSettingSchema = XMLSchema.new("rvbGeneralSettings")
	local schemaKey = "rvbGeneralSettings"
	
	self.generalSettingSchema:register(XMLValueType.BOOL, schemaKey .. ".alertmessage#value", "Alert Message")
	self.generalSettingSchema:register(XMLValueType.INT, schemaKey .. ".difficulty#value", "RVB difficulty")
	self.generalSettingSchema:register(XMLValueType.BOOL, schemaKey .. ".basicrepairtrigger#value", "")
	self.generalSettingSchema:register(XMLValueType.BOOL, schemaKey .. ".cp_notice#value", "CP")

end

function RVBMain:loadGamePlaySettingsFromXml(xmlPath)
    local xmlFile = XMLFile.load("configXml", xmlPath, self.gameplaySettingSchema)

    if xmlFile ~= 0 then

        local key = "rvbGamePlaySettings"
				
		self.gameplaySettings.repairshop              = xmlFile:getValue(key .. ".repairshop#value", self.gameplaySettings.repairshop)
		self.gameplaySettings.dailyServiceInterval    = xmlFile:getValue(key .. ".dailyServiceInterval#value", self.gameplaySettings.dailyServiceInterval)
		self.gameplaySettings.periodicServiceInterval = xmlFile:getValue(key .. ".periodicServiceInterval#value", self.gameplaySettings.periodicServiceInterval)
		self.gameplaySettings.workshopOpen            = xmlFile:getValue(key .. ".workshopOpen#value", self.gameplaySettings.workshopOpen)
		self.gameplaySettings.workshopClose           = xmlFile:getValue(key .. ".workshopClose#value", self.gameplaySettings.workshopClose)

		self.gameplaySettings.thermostatLifetime  = Utils.getNoNil(xmlFile:getInt(key .. ".thermostatLifetime"), self.gameplaySettings.thermostatLifetime)
		self.gameplaySettings.lightingsLifetime   = Utils.getNoNil(xmlFile:getInt(key .. ".lightingsLifetime"), self.gameplaySettings.lightingsLifetime)
		self.gameplaySettings.glowplugLifetime    = Utils.getNoNil(xmlFile:getInt(key .. ".glowplugLifetime"), self.gameplaySettings.glowplugLifetime)
		self.gameplaySettings.wipersLifetime      = Utils.getNoNil(xmlFile:getInt(key .. ".wipersLifetime"), self.gameplaySettings.wipersLifetime)
		self.gameplaySettings.generatorLifetime   = Utils.getNoNil(xmlFile:getInt(key .. ".generatorLifetime"), self.gameplaySettings.generatorLifetime)
		self.gameplaySettings.engineLifetime      = Utils.getNoNil(xmlFile:getInt(key .. ".engineLifetime"), self.gameplaySettings.engineLifetime)
		self.gameplaySettings.selfstarterLifetime = Utils.getNoNil(xmlFile:getInt(key .. ".selfstarterLifetime"), self.gameplaySettings.selfstarterLifetime)
		self.gameplaySettings.batteryLifetime     = Utils.getNoNil(xmlFile:getInt(key .. ".batteryLifetime"), self.gameplaySettings.batteryLifetime)
		self.gameplaySettings.tireLifetime        = Utils.getNoNil(xmlFile:getInt(key .. ".tireLifetime"), self.gameplaySettings.tireLifetime)

        xmlFile:delete()
    end
end

function RVBMain:loadGeneralSettingsFromXml(xmlPath)
    local xmlFile = XMLFile.load("configXml", xmlPath, self.generalSettingSchema)

    if xmlFile ~= 0 then

        local key = "rvbGeneralSettings"
		
		self.generalSettings.alertmessage       = xmlFile:getValue(key .. ".alertmessage#value", self.generalSettings.alertmessage)
		self.generalSettings.difficulty         = xmlFile:getValue(key .. ".difficulty#value", self.generalSettings.difficulty)
		self.generalSettings.basicrepairtrigger = xmlFile:getValue(key .. ".basicrepairtrigger#value", self.generalSettings.basicrepairtrigger)
		self.generalSettings.cp_notice          = xmlFile:getValue(key .. ".cp_notice#value", self.generalSettings.cp_notice)
		
        xmlFile:delete()
    end
end

function RVBMain:registerActionEvents(inputManager)
    self:unregisterActionEvents()

	for _, action in pairs(RVBMain.actions) do

        local actionName = action.name
        local triggerUp = action.triggerUp ~= nil and action.triggerUp or false
        local triggerDown = action.triggerDown ~= nil and action.triggerDown or true
        local triggerAlways = action.triggerAlways ~= nil and action.triggerAlways or false
        local startActive = action.startActive ~= nil and action.startActive or true

        local _, eventId = g_inputBinding:registerActionEvent(actionName, self, RVBMain.onActionCall, triggerUp,
            triggerDown, triggerAlways, startActive, nil)

        self.actionEvents[actionName] = eventId

        if g_inputBinding ~= nil and g_inputBinding.events ~= nil and g_inputBinding.events[eventId] ~= nil then
            if action.priority ~= nil then
                g_inputBinding:setActionEventTextPriority(eventId, action.priority)
            end

            if action.text ~= nil then
                g_inputBinding:setActionEventText(eventId, action.text)
            end
        end
    end

    self:updateMenuInputBinding()
	
end

function RVBMain:unregisterActionEvents()
    g_inputBinding:removeActionEventsByTarget(self)
end

function RVBMain:updateMenuInputBinding()
    local actionEventId = self.actionEvents[InputAction.VEHICLE_BREAKDOWN_MENU]
	local isActive = true
    g_inputBinding:setActionEventActive(actionEventId, isActive)
end

function RVBMain:resetGamePlaySettings()
    self.gameplaySettings = {
		repairshop = RVBMain.DEFAULT_SETTINGS.repairshop,
		dailyServiceInterval = RVBMain.DEFAULT_SETTINGS.dailyServiceInterval,
		periodicServiceInterval = RVBMain.DEFAULT_SETTINGS.periodicServiceInterval,
		workshopOpen = RVBMain.DEFAULT_SETTINGS.workshopOpen,
		workshopClose = RVBMain.DEFAULT_SETTINGS.workshopClose,
		thermostatLifetime = RVBMain.DEFAULT_SETTINGS.thermostatLifetime,
		lightingsLifetime = RVBMain.DEFAULT_SETTINGS.lightingsLifetime,
		glowplugLifetime = RVBMain.DEFAULT_SETTINGS.glowplugLifetime,
		wipersLifetime = RVBMain.DEFAULT_SETTINGS.wipersLifetime,
		generatorLifetime = RVBMain.DEFAULT_SETTINGS.generatorLifetime,
		engineLifetime = RVBMain.DEFAULT_SETTINGS.engineLifetime,
		selfstarterLifetime = RVBMain.DEFAULT_SETTINGS.selfstarterLifetime,
		batteryLifetime = RVBMain.DEFAULT_SETTINGS.batteryLifetime,
		tireLifetime = RVBMain.DEFAULT_SETTINGS.tireLifetime
	}
end

function RVBMain:resetGeneralSettings()
    self.generalSettings = {
		alertmessage = RVBMain.DEFAULT_SETTINGS.alertmessage,
		difficulty = RVBMain.DEFAULT_SETTINGS.difficulty,
		basicrepairtrigger = RVBMain.DEFAULT_SETTINGS.basicrepairtrigger,
		cp_notice = RVBMain.DEFAULT_SETTINGS.cp_notice
    }
end

function RVBMain:onActionCall(actionName, keyStatus, callbackStatus, isAnalog, arg6)

	if actionName == InputAction.VEHICLE_BREAKDOWN_MENU then
        g_gui:showDialog("RVBTabbedMenu")
    end

end

function RVBMain:RVBopenMenu(superFunc)

	if g_currentMission.vehicleBreakdowns.generalSettings.basicrepairtrigger then
		g_gui:showDialog("RVBTabbedMenu")
	else
		superFunc(self)
	end
	
end
VehicleSellingPoint.openMenu = Utils.overwrittenFunction(VehicleSellingPoint.openMenu, RVBMain.RVBopenMenu)

function RVBMain:setCustomGamePlaySet(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, thermostatLifetime, lightingsLifetime,
	glowplugLifetime, wipersLifetime, generatorLifetime, engineLifetime, selfstarterLifetime, batteryLifetime, tireLifetime)

    if g_server then

		g_server:broadcastEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, thermostatLifetime, lightingsLifetime,
		glowplugLifetime, wipersLifetime, generatorLifetime, engineLifetime, selfstarterLifetime, batteryLifetime, tireLifetime))

		self:setIsDailyServiceInterval(dailyServiceInterval)
		self:setIsPeriodicServiceInterval(periodicServiceInterval)
		self:setIsRepairShop(repairshop)
		self:setIsWorkshopOpen(workshopOpen)
		self:setIsWorkshopClose(workshopClose)
		self:setIsThermostatLifetime(thermostatLifetime)
		self:setIsLightingsLifetime(lightingsLifetime)
		self:setIsGlowplugLifetime(glowplugLifetime)
		self:setIsWipersLifetime(wipersLifetime)
		self:setIsGeneratorLifetime(generatorLifetime)
		self:setIsEngineLifetime(engineLifetime)
		self:setIsSelfstarterLifetime(selfstarterLifetime)
		self:setIsBatteryLifetime(batteryLifetime)
		self:setIsTireLifetime(tireLifetime)

    end

end

function RVBMain:setCustomGeneralSet(alertmessage, difficulty, basicrepairtrigger, cp_notice)

    if g_server then

        g_server:broadcastEvent(RVBGeneralSet_Event.new(alertmessage, difficulty, basicrepairtrigger, cp_notice), nil, nil, self)

		self:setIsAlertMessage(alertmessage)
		self:setIsRVBDifficulty(difficulty)
		self:setIsBasicRepairTrigger(basicrepairtrigger)
		self:setIsCPNotice(cp_notice)

    end

end

function RVBMain:rvbsaveToXMLFile(RVBXMLFile)

    local schemaKey = "rvbGamePlaySettings"
    local xmlFile = XMLFile.create("RBVGamePlaySettingsXML", RVBXMLFile, "rvbGamePlaySettings", self.gameplaySettingSchema)
    if xmlFile ~= 0 then
		xmlFile:setValue(schemaKey .. ".dailyServiceInterval#value", self.gameplaySettings.dailyServiceInterval)
		xmlFile:setValue(schemaKey .. ".periodicServiceInterval#value", self.gameplaySettings.periodicServiceInterval)
		xmlFile:setValue(schemaKey .. ".repairshop#value", self.gameplaySettings.repairshop)
		xmlFile:setValue(schemaKey .. ".workshopOpen#value", self.gameplaySettings.workshopOpen)
		xmlFile:setValue(schemaKey .. ".workshopClose#value", self.gameplaySettings.workshopClose)

		xmlFile:setValue(schemaKey .. ".thermostatLifetime", self.gameplaySettings.thermostatLifetime)
		xmlFile:setValue(schemaKey .. ".lightingsLifetime", self.gameplaySettings.lightingsLifetime)
		xmlFile:setValue(schemaKey .. ".glowplugLifetime", self.gameplaySettings.glowplugLifetime)
		xmlFile:setValue(schemaKey .. ".wipersLifetime", self.gameplaySettings.wipersLifetime)
		xmlFile:setValue(schemaKey .. ".generatorLifetime", self.gameplaySettings.generatorLifetime)
		xmlFile:setValue(schemaKey .. ".engineLifetime", self.gameplaySettings.engineLifetime)
		xmlFile:setValue(schemaKey .. ".selfstarterLifetime", self.gameplaySettings.selfstarterLifetime)
		xmlFile:setValue(schemaKey .. ".batteryLifetime", self.gameplaySettings.batteryLifetime)
		xmlFile:setValue(schemaKey .. ".tireLifetime", self.gameplaySettings.tireLifetime)
        xmlFile:save()
        xmlFile:delete()
    end
		
end

function RVBMain:saveGeneralettingsToXML()

    local VEHICLE_BREAKDOWN_FOLDER = getUserProfileAppPath() .. "modSettings/FS22_gameplay_Real_Vehicle_Breakdowns/"
    local GENERAL_SETTINGS_XML = Utils.getFilename("RVBGeneralSettings.xml", VEHICLE_BREAKDOWN_FOLDER)
    local schemaKey = "rvbGeneralSettings"
    local xmlFile = XMLFile.create("RBVGeneralSettingsXML", GENERAL_SETTINGS_XML, "rvbGeneralSettings", self.generalSettingSchema)
    if xmlFile ~= 0 then
		xmlFile:setValue(schemaKey .. ".alertmessage#value", self.generalSettings.alertmessage)
		xmlFile:setValue(schemaKey .. ".difficulty#value", self.generalSettings.difficulty)
		xmlFile:setValue(schemaKey .. ".basicrepairtrigger#value", self.generalSettings.basicrepairtrigger)
		xmlFile:setValue(schemaKey .. ".cp_notice#value", self.generalSettings.cp_notice)
        xmlFile:save()
        xmlFile:delete()
    end
	
end

function RVBMain:update()
end

function RVBMain:draw()
end

function RVBMain:delete()
end

function RVBMain:getIsAlertMessage()
    return self.generalSettings.alertmessage
end

function RVBMain:setIsAlertMessage(alertmessage)
	self.generalSettings.alertmessage = alertmessage
end

function RVBMain:getIsRVBDifficulty()
    return self.generalSettings.difficulty
end

function RVBMain:setIsRVBDifficulty(difficulty)
	self.generalSettings.difficulty = difficulty
end

function RVBMain:getIsBasicRepairTrigger()
    return self.generalSettings.basicrepairtrigger
end

function RVBMain:setIsBasicRepairTrigger(basicrepairtrigger)
	self.generalSettings.basicrepairtrigger = basicrepairtrigger
end

function RVBMain:setIsCPNotice(cpnotice)
	self.generalSettings.cp_notice = cpnotice
end

--[[**************************************************]]

function RVBMain:getIsDailyService()
    return self.gameplaySettings.dailyServiceInterval
end

function RVBMain:setIsDailyServiceInterval(dailyServiceInterval)
	self.gameplaySettings.dailyServiceInterval = dailyServiceInterval
end

function RVBMain:getIsIsPeriodicService()
    return self.gameplaySettings.periodicServiceInterval
end

function RVBMain:setIsPeriodicServiceInterval(periodicServiceInterval)
	self.gameplaySettings.periodicServiceInterval = periodicServiceInterval
end

function RVBMain:getIsRepairShop()
    return self.gameplaySettings.repairshop
end

function RVBMain:setIsRepairShop(repairshop)
	self.gameplaySettings.repairshop = repairshop
end

function RVBMain:getIsWorkshopOpen()
    return self.gameplaySettings.workshopOpen
end

function RVBMain:setIsWorkshopOpen(workshopOpen)
	self.gameplaySettings.workshopOpen = workshopOpen
end

function RVBMain:getIsWorkshopClose()
    return self.gameplaySettings.workshopClose
end

function RVBMain:setIsWorkshopClose(workshopClose)
	self.gameplaySettings.workshopClose = workshopClose
end

function RVBMain:getIsThermostatLifetime()
    return self.gameplaySettings.thermostatLifetime
end

function RVBMain:setIsThermostatLifetime(thermostatLifetime)
	self.gameplaySettings.thermostatLifetime = thermostatLifetime
end

function RVBMain:getIsLightingsLifetime()
    return self.gameplaySettings.lightingsLifetime
end

function RVBMain:setIsLightingsLifetime(lightingsLifetime)
	self.gameplaySettings.lightingsLifetime = lightingsLifetime
end

function RVBMain:getIsGlowplugLifetime()
    return self.gameplaySettings.glowplugLifetime
end

function RVBMain:setIsGlowplugLifetime(glowplugLifetime)
	self.gameplaySettings.glowplugLifetime = glowplugLifetime
end

function RVBMain:getIsWipersLifetime()
    return self.gameplaySettings.wipersLifetime
end

function RVBMain:setIsWipersLifetime(wipersLifetime)
	self.gameplaySettings.wipersLifetime = wipersLifetime
end

function RVBMain:getIsGeneratorLifetime()
    return self.gameplaySettings.generatorLifetime
end

function RVBMain:setIsGeneratorLifetime(generatorLifetime)
	self.gameplaySettings.generatorLifetime = generatorLifetime
end

function RVBMain:getIsEngineLifetime()
    return self.gameplaySettings.engineLifetime
end

function RVBMain:setIsEngineLifetime(engineLifetime)
	self.gameplaySettings.engineLifetime = engineLifetime
end

function RVBMain:getIsSelfstarterLifetime()
    return self.gameplaySettings.selfstarterLifetime
end

function RVBMain:setIsSelfstarterLifetime(selfstarterLifetime)
	self.gameplaySettings.selfstarterLifetime = selfstarterLifetime
end

function RVBMain:getIsBatteryLifetime()
    return self.gameplaySettings.batteryLifetime
end

function RVBMain:setIsBatteryLifetime(batteryLifetime)
	self.gameplaySettings.batteryLifetime = batteryLifetime
end

function RVBMain:getIsTireLifetime()
    return self.gameplaySettings.tireLifetime
end

function RVBMain:setIsTireLifetime(tireLifetime)
	self.gameplaySettings.tireLifetime = tireLifetime
end

function RVBMain:onReadStream(streamId, connection)
    if connection:getIsServer() then
        self.gameplaySettings.dailyServiceInterval = streamReadInt32(streamId)
		self.gameplaySettings.periodicServiceInterval = streamReadInt32(streamId)
		self.gameplaySettings.repairshop = streamReadBool(streamId)
		self.gameplaySettings.workshopOpen = streamReadInt32(streamId)
		self.gameplaySettings.workshopClose = streamReadInt32(streamId)
		self.gameplaySettings.thermostatLifetime = streamReadInt32(streamId)
		self.gameplaySettings.lightingsLifetime = streamReadInt32(streamId)
		self.gameplaySettings.glowplugLifetime = streamReadInt32(streamId)
		self.gameplaySettings.wipersLifetime = streamReadInt32(streamId)
		self.gameplaySettings.generatorLifetime = streamReadInt32(streamId)
		self.gameplaySettings.engineLifetime = streamReadInt32(streamId)
		self.gameplaySettings.selfstarterLifetime = streamReadInt32(streamId)
		self.gameplaySettings.batteryLifetime = streamReadInt32(streamId)
		self.gameplaySettings.tireLifetime = streamReadInt32(streamId)
		
		--self.generalSettings.alertmessage = streamReadBool(streamId)
		--self.generalSettings.difficulty = streamReadInt32(streamId)
		--self.generalSettings.basicrepairtrigger = streamReadBool(streamId)
		--self.generalSettings.cp_notice = streamReadBool(streamId)
    end
end

function RVBMain:onWriteStream(streamId, connection)
    if not connection:getIsServer() then
        streamWriteInt32(streamId, self.gameplaySettings.dailyServiceInterval)
		streamWriteInt32(streamId, self.gameplaySettings.periodicServiceInterval)
		streamWriteBool(streamId, self.gameplaySettings.repairshop)
		streamWriteInt32(streamId, self.gameplaySettings.workshopOpen)
		streamWriteInt32(streamId, self.gameplaySettings.workshopClose)
		streamWriteInt32(streamId, self.gameplaySettings.thermostatLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.lightingsLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.glowplugLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.wipersLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.generatorLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.engineLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.selfstarterLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.batteryLifetime)
		streamWriteInt32(streamId, self.gameplaySettings.tireLifetime)
		
		--streamWriteBool(streamId, self.generalSettings.alertmessage)
		--streamWriteInt32(streamId, self.generalSettings.difficulty)
		--streamWriteBool(streamId, self.generalSettings.basicrepairtrigger)
		--streamWriteBool(streamId, self.generalSettings.cp_notice)
    end
end
