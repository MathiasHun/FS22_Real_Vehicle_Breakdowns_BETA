
RVBMain = {}
local RVBMain_mt = Class(RVBMain)

RVBMain.ONOFF = { 1, 2 }

RVBMain.alertmessage = false
RVBMain.alertmessageState = 2

RVBMain.difficulty = ""
RVBMain.difficultyState = 2

RVBMain.repairshop = true
RVBMain.repairshopState = 1

RVBMain.DAILY_ServiceInterval = { 4, 6, 8, 10 }
RVBMain.dailyServiceInterval = 6
RVBMain.dailyServiceIntervalState = 2

RVBMain.PERIODIC_ServiceInterval = { 40, 60, 80, 100 }
RVBMain.periodicServiceInterval = 40
RVBMain.periodicServiceIntervalState = 1

RVBMain.HOURS_workshopOpen = { 5, 6, 7, 8, 9 }
RVBMain.workshopOpen = 7
RVBMain.workshopOpenState = 1

RVBMain.HOURS_workshopClose = { 16, 17, 18, 19, 20, 21, 22, 23 }
RVBMain.workshopClose = 16
RVBMain.workshopCloseState = 1

RVBMain.cp_notice = false

RVBMain.DEFAULT_SETTINGS = {
	alertmessage = RVBMain.alertmessage,
	alertmessageState = RVBMain.alertmessageState,
	rvbDifficulty = RVBMain.difficulty,
	rvbDifficultyState = RVBMain.difficultyState,
	repairshop = RVBMain.repairshop,
	repairshopState = RVBMain.repairshopState,
	dailyServiceInterval = RVBMain.dailyServiceInterval,
	dailyServiceIntervalState = RVBMain.dailyServiceIntervalState,
	periodicServiceInterval = RVBMain.periodicServiceInterval,
	periodicServiceIntervalState = RVBMain.periodicServiceIntervalState,
	workshopOpen = RVBMain.workshopOpen,
	workshopOpenState = RVBMain.workshopOpenState,
	workshopClose = RVBMain.workshopClose,
	workshopCloseState = RVBMain.workshopCloseState,
	cp_notice = RVBMain.cp_notice
}
RVBMain.actions = {{
    name = InputAction.VEHICLE_BREAKDOWN_MENU,
    priority = GS_PRIO_HIGH
}}

RVBMain.STARTMOTOR = false

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

	self.DIFFICULTY_A = {}
	self.DIFFICULTY_A[1] = g_i18n:getText("ui_RVB_difficulty1_subtitle")
	self.DIFFICULTY_A[2] = g_i18n:getText("ui_RVB_difficulty2_subtitle")
	self.DIFFICULTY_A[3] = g_i18n:getText("ui_RVB_difficulty3_subtitle")

	RVBMain.difficulty = self.DIFFICULTY_A[2]
	RVBMain.DEFAULT_SETTINGS.rvbDifficulty = self.DIFFICULTY_A[2]
	
	self:registerGamePlaySettingsSchema()
	self:registerGeneralSettingsSchema()

	self.mission = mission
	
    local VEHICLE_BREAKDOWN_FOLDER = getUserProfileAppPath() .. "modSettings/FS22_gameplay_Real_Vehicle_Breakdowns/"
    createFolder(VEHICLE_BREAKDOWN_FOLDER)

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
	
	local newvehicleListFrame = RVBVehicleList_Frame.new(self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBVehicleList_Frame.xml", "RVBVehicleList_Frame", newvehicleListFrame, true)

    self.menu = RVBTabbedMenu:new(g_messageCenter, g_i18n, g_inputBinding, self, self.modName)
    g_gui:loadGui(self.modDirectory .. "gui/RVBTabbedMenu.xml", "RVBTabbedMenu", self.menu)

	local conflictList = {}
	if g_modIsLoaded["FS22_Courseplay"] then
		if FS22_Courseplay ~= nil and FS22_Courseplay.WearableController.autoRepair ~= nil then
			table.insert(conflictList, "CoursePlay")
			FS22_Courseplay.WearableController.autoRepair = Utils.overwrittenFunction(FS22_Courseplay.WearableController.autoRepair, RVBMain.autoRepair)
		end
	end

	if g_modIsLoaded["FS22_AutoDrive"] then
		if FS22_AutoDrive ~= nil and FS22_AutoDrive.ADDrivePathModule.isTargetReached ~= nil then
			--table.insert(conflictList, "AutoDrive")
			--FS22_AutoDrive.ADDrivePathModule.isTargetReached = Utils.overwrittenFunction(FS22_AutoDrive.ADDrivePathModule.isTargetReached, RVBMain.isTargetReached)
		end
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
		if not self.gameplaySettings.cp_notice then
			addModEventListener(popupMessage)
			self.gameplaySettings.cp_notice = true
		end
	end

end

-- Original CP WearableController:autoRepair()
function RVBMain:autoRepair(superFunc)
	--if self:isBrokenGreaterThan(100-self.autoRepairSetting:getValue()) then 
	--	self.implement:repairVehicle()
	--end
end
-- Original AD ADDrivePathModule:isTargetReached()
function RVBMain:isTargetReached(superFunc)
    --if self.vehicle.spec_locomotive and self.vehicle.ad and self.vehicle.ad.trainModule then
        -- train
    --    return self.vehicle.ad.trainModule:isTargetReached()
    --end
    --return self.atTarget
	return false
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
			
			if typeEntry ~= nil and typeName ~= "locomotive" and typeName ~= "trainTrailer" and typeName ~= "trainTimberTrailer" then 
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
	self.gameplaySettingSchema:register(XMLValueType.BOOL, schemaKey .. ".cp_notice#value", "CP")

end

function RVBMain:registerGeneralSettingsSchema()
	
	self.generalSettingSchema = XMLSchema.new("rvbGeneralSettings")
	local schemaKey = "rvbGeneralSettings"
	
	self.generalSettingSchema:register(XMLValueType.BOOL, schemaKey .. ".alertmessage#value", "Alert Message")
	self.generalSettingSchema:register(XMLValueType.INT, schemaKey .. ".difficulty#value", "RVB difficulty")

end

function RVBMain:loadGamePlaySettingsFromXml(xmlPath)
    local xmlFile = XMLFile.load("configXml", xmlPath, self.gameplaySettingSchema)

    if xmlFile ~= 0 then

        local key = "rvbGamePlaySettings"
				
		self.gameplaySettings.repairshop = xmlFile:getValue(key .. ".repairshop#value", self.gameplaySettings.repairshop)

		local onoff_r = 2
		if self.gameplaySettings.repairshop then
			onoff_r = 2
		else
			onoff_r = 1
		end
		for index, value in pairs(RVBMain.ONOFF) do
			if value == onoff_r then
				self.gameplaySettings.repairshopState = index
			end
		end

		self.gameplaySettings.dailyServiceInterval = xmlFile:getValue(key .. ".dailyServiceInterval#value", self.gameplaySettings.dailyServiceInterval)
		for index, value in pairs(RVBMain.DAILY_ServiceInterval) do
			if value == self.gameplaySettings.dailyServiceInterval then
				self.gameplaySettings.dailyServiceIntervalState = index
			end
		end
		
		self.gameplaySettings.periodicServiceInterval = xmlFile:getValue(key .. ".periodicServiceInterval#value", self.gameplaySettings.periodicServiceInterval)
		for index, value in pairs(RVBMain.PERIODIC_ServiceInterval) do
			if value == self.gameplaySettings.periodicServiceInterval then
				self.gameplaySettings.periodicServiceIntervalState = index
			end
		end

		self.gameplaySettings.workshopOpen = xmlFile:getValue(key .. ".workshopOpen#value", self.gameplaySettings.workshopOpen)
		for index, value in pairs(RVBMain.HOURS_workshopOpen) do
			if value == self.gameplaySettings.workshopOpen then
				self.gameplaySettings.workshopOpenState = index
			end
		end
		
		self.gameplaySettings.workshopClose = xmlFile:getValue(key .. ".workshopClose#value", self.gameplaySettings.workshopClose)
		for index, value in pairs(RVBMain.HOURS_workshopClose) do
			if value == self.gameplaySettings.workshopClose then
				self.gameplaySettings.workshopCloseState = index
			end
		end
		
		self.gameplaySettings.cp_notice = xmlFile:getValue(key .. ".cp_notice#value", self.gameplaySettings.cp_notice)

        xmlFile:delete()
    end
end

function RVBMain:loadGeneralSettingsFromXml(xmlPath)
    local xmlFile = XMLFile.load("configXml", xmlPath, self.generalSettingSchema)

    if xmlFile ~= 0 then

        local key = "rvbGeneralSettings"
		
		self.generalSettings.alertmessage = xmlFile:getValue(key .. ".alertmessage#value", self.generalSettings.alertmessage)
		local onoff = 2
		if self.generalSettings.alertmessage then
			onoff = 2
		else
			onoff = 1
		end
		for index, value in pairs(RVBMain.ONOFF) do
			if value == onoff then
				self.generalSettings.alertmessageState = index
			end
		end

		
		self.generalSettings.rvbDifficultyState = xmlFile:getValue(key .. ".difficulty#value", self.generalSettings.rvbDifficultyState)
		for index, value in pairs(self.DIFFICULTY_A) do
			if index == self.generalSettings.rvbDifficultyState then
				self.generalSettings.rvbDifficulty = self.DIFFICULTY_A[index]
			end
		end

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

function RVBMain:updateStartMotorBinding()
    local actionEventId = self.actionEvents[InputAction.TOGGLE_MOTOR_STATE]
	local isActive = true
    g_inputBinding:setActionEventActive(actionEventId, isActive)
end

function RVBMain:resetGamePlaySettings()
    self.gameplaySettings = {
		repairshop = RVBMain.DEFAULT_SETTINGS.repairshop,
		repairshopState = RVBMain.DEFAULT_SETTINGS.repairshopState,
		dailyServiceInterval = RVBMain.DEFAULT_SETTINGS.dailyServiceInterval,
		dailyServiceIntervalState = RVBMain.DEFAULT_SETTINGS.dailyServiceIntervalState,
		periodicServiceInterval = RVBMain.DEFAULT_SETTINGS.periodicServiceInterval,
		periodicServiceIntervalState = RVBMain.DEFAULT_SETTINGS.periodicServiceIntervalState,
		workshopOpen = RVBMain.DEFAULT_SETTINGS.workshopOpen,
		workshopOpenState = RVBMain.DEFAULT_SETTINGS.workshopOpenState,
		workshopClose = RVBMain.DEFAULT_SETTINGS.workshopClose,
		workshopCloseState = RVBMain.DEFAULT_SETTINGS.workshopCloseState,
		cp_notice = RVBMain.DEFAULT_SETTINGS.cp_notice
    }
end

function RVBMain:resetGeneralSettings()
    self.generalSettings = {
		alertmessage = RVBMain.DEFAULT_SETTINGS.alertmessage,
		alertmessageState = RVBMain.DEFAULT_SETTINGS.alertmessageState,
		rvbDifficulty = RVBMain.DEFAULT_SETTINGS.rvbDifficulty,
		rvbDifficultyState = RVBMain.DEFAULT_SETTINGS.rvbDifficultyState
    }
end

function RVBMain:onActionCall(actionName, keyStatus, callbackStatus, isAnalog, arg6)

	if actionName == InputAction.VEHICLE_BREAKDOWN_MENU then
        g_gui:showDialog("RVBTabbedMenu")
    end

end

function RVBMain:setCustomGamePlaySet(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, cp_notice)

    if g_server then

        g_server:broadcastEvent(RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, cp_notice))

		self:setIsDailyServiceInterval(dailyServiceInterval)
		self:setIsPeriodicServiceInterval(periodicServiceInterval)
		self:setIsRepairShop(repairshop)
		self:setIsWorkshopOpen(workshopOpen)
		self:setIsWorkshopClose(workshopClose)
		self:setIsCPNotice(cp_notice)

    end

end

function RVBMain:setCustomGeneralSet(alertmessage, difficulty)

    if g_server then

        g_server:broadcastEvent(RVBGeneralSet_Event.new(alertmessage, difficulty))

		self.generalSettings.alertmessage = alertmessage
		local onoff_r = 2
		if self.generalSettings.alertmessage then
			onoff_r = 2
		else
			onoff_r = 1
		end
		for index, value in pairs(RVBMain.ONOFF) do
			if value == onoff_r then
				self.generalSettings.alertmessageState = index
			end
		end
		
		self:setIsRVBDifficulty(difficulty)

    end

end

function RVBMain:rvbsaveToXMLFile(RVBXMLFile)

    local schemaKey = "rvbGamePlaySettings"

    local xmlFile = XMLFile.create("RBVGamePlaySettingsXML", RVBXMLFile, "rvbGamePlaySettings",
        self.gameplaySettingSchema)

    if xmlFile ~= 0 then

		xmlFile:setValue(schemaKey .. ".dailyServiceInterval#value", self.gameplaySettings.dailyServiceInterval)
		xmlFile:setValue(schemaKey .. ".periodicServiceInterval#value", self.gameplaySettings.periodicServiceInterval)
		xmlFile:setValue(schemaKey .. ".repairshop#value", self.gameplaySettings.repairshop)
		xmlFile:setValue(schemaKey .. ".workshopOpen#value", self.gameplaySettings.workshopOpen)
		xmlFile:setValue(schemaKey .. ".workshopClose#value", self.gameplaySettings.workshopClose)
		xmlFile:setValue(schemaKey .. ".cp_notice#value", self.gameplaySettings.cp_notice)

        xmlFile:save()
        xmlFile:delete()
    end
	
	local VEHICLE_BREAKDOWN_FOLDER = getUserProfileAppPath() .. "modSettings/FS22_gameplay_Real_Vehicle_Breakdowns/"
    local GENERAL_SETTINGS_XML = Utils.getFilename("RVBGeneralSettings.xml", VEHICLE_BREAKDOWN_FOLDER)
    local schemaKey_general = "rvbGeneralSettings"
    local xmlFile_general = XMLFile.create("RBVGeneralSettingsXML", GENERAL_SETTINGS_XML, "rvbGeneralSettings", self.generalSettingSchema)

    if xmlFile_general ~= 0 then
		xmlFile_general:setValue(schemaKey_general .. ".alertmessage#value", self.generalSettings.alertmessage)
		xmlFile_general:setValue(schemaKey_general .. ".difficulty#value", self.generalSettings.rvbDifficultyState)
		
        xmlFile_general:save()
        xmlFile_general:delete()
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
	if alertmessage then
		self.generalSettings.alertmessageState = 2
	else
		self.generalSettings.alertmessageState = 1
	end
end

function RVBMain:getIsRVBDifficulty()
    return self.generalSettings.rvbDifficulty
end

function RVBMain:setIsRVBDifficulty(difficulty)
	self.generalSettings.rvbDifficultyState = difficulty
	self.generalSettings.rvbDifficulty = self.DIFFICULTY_A[difficulty]

end

--[[**************************************************]]

function RVBMain:getIsDailyService()
    return self.gameplaySettings.dailyServiceInterval
end

function RVBMain:setIsDailyServiceInterval(dailyServiceInterval)
	self.gameplaySettings.dailyServiceIntervalState = dailyServiceInterval
	self.gameplaySettings.dailyServiceInterval = RVBMain.DAILY_ServiceInterval[dailyServiceInterval]
end

function RVBMain:getIsIsPeriodicService()
    return self.gameplaySettings.periodicServiceInterval
end

function RVBMain:setIsPeriodicServiceInterval(periodicServiceInterval)
	self.gameplaySettings.periodicServiceIntervalState = periodicServiceInterval
	self.gameplaySettings.periodicServiceInterval = RVBMain.PERIODIC_ServiceInterval[periodicServiceInterval]
end

function RVBMain:getIsRepairShop()
    return self.gameplaySettings.repairshop
end

function RVBMain:setIsRepairShop(repairshop)
	self.gameplaySettings.repairshop = repairshop
	if repairshop then
		self.gameplaySettings.repairshopState = 2
	else
		self.gameplaySettings.repairshopState = 1
	end
end

function RVBMain:getIsWorkshopOpen()
    return self.gameplaySettings.workshopOpen
end

function RVBMain:setIsWorkshopOpen(workshopOpen)
	self.gameplaySettings.workshopOpenState = workshopOpen
	self.gameplaySettings.workshopOpen = RVBMain.HOURS_workshopOpen[workshopOpen]
end

function RVBMain:getIsWorkshopClose()
    return self.gameplaySettings.workshopClose
end

function RVBMain:setIsWorkshopClose(workshopClose)
	self.gameplaySettings.workshopCloseState = workshopClose
	self.gameplaySettings.workshopClose = RVBMain.HOURS_workshopClose[workshopClose]
end

function RVBMain:setIsCPNotice(cpnotice)
	self.gameplaySettings.cp_notice = cpnotice
end

function RVBMain:onReadStream(streamId, connection)
    if connection:getIsServer() then
        self.gameplaySettings.dailyServiceInterval = streamReadInt32(streamId)
		self.gameplaySettings.periodicServiceInterval = streamReadInt32(streamId)
		self.gameplaySettings.repairshop = streamReadBool(streamId)
		self.gameplaySettings.workshopOpen = streamReadInt32(streamId)
		self.gameplaySettings.workshopClose = streamReadInt32(streamId)
		self.gameplaySettings.cp_notice = streamReadBool(streamId)
		
		self.generalSettings.alertmessage = streamReadBool(streamId)
		self.generalSettings.rvbDifficultyState = streamReadInt32(streamId)
    end
end

function RVBMain:onWriteStream(streamId, connection)
    if not connection:getIsServer() then
        streamWriteInt32(streamId, self.gameplaySettings.dailyServiceInterval)
		streamWriteInt32(streamId, self.gameplaySettings.periodicServiceInterval)
		streamWriteBool(streamId, self.gameplaySettings.repairshop)
		streamWriteInt32(streamId, self.gameplaySettings.workshopOpen)
		streamWriteInt32(streamId, self.gameplaySettings.workshopClose)
		streamWriteBool(streamId, self.gameplaySettings.cp_notice)
		
		streamWriteBool(streamId, self.generalSettings.alertmessage)
		streamWriteInt32(streamId, self.generalSettings.rvbDifficultyState)
    end
end
