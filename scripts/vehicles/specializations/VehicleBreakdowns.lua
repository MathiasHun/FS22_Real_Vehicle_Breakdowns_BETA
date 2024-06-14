
VehicleBreakdowns = {}

VehicleBreakdowns.Debug = {}
VehicleBreakdowns.Debug.Info = true

VehicleBreakdowns.repairTriggers = {}
VehicleBreakdowns.searchedForTriggers = false

VehicleBreakdowns.repairCosts = { 0.0015, 0.0025, 0.001, 0.0007, 0.005, 0.02, 0.006, 0.0005, 0.005, 0.003 }
VehicleBreakdowns.IRSBTimes = { 10800, 5400, 7200, 1800, 5400, 21600, 5400, 60, 600, 900 }
VehicleBreakdowns.faultText = { "THERMOSTAT", "LIGHTINGS", "GLOWPLUG", "WIPERS", "GENERATOR", "ENGINE", "SELFSTARTER", "BATTERY" }

VehicleBreakdowns.INGAME_NOTIFICATION = {
	1, 0.27058823529412, 0,	1.0
}

VehicleBreakdowns.ECONOMIZER = {
    REFRESH_PERIOD = 250.0,
	TIME = 0,
	DISPLAY = false
}

VehicleBreakdowns.GSET_Change = 1


function VehicleBreakdowns.prerequisitesPresent(specializations)
    return true
end

function VehicleBreakdowns.registerOverwrittenFunctions(vehicleType)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "updateMotorTemperature", VehicleBreakdowns.updateMotorTemperature)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanMotorRun", VehicleBreakdowns.getCanMotorRun)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getMotorNotAllowedWarning", VehicleBreakdowns.getMotorNotAllowedWarning)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "startMotor", VehicleBreakdowns.startMotor)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "stopMotor", VehicleBreakdowns.stopMotor)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "updateConsumers", VehicleBreakdowns.updateConsumers)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getIsActiveForWipers", VehicleBreakdowns.getIsActiveForWipers)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "repairVehicle", VehicleBreakdowns.repairVehicle)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "showInfo", VehicleBreakdowns.showInfo)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getSpeedLimit", VehicleBreakdowns.getSpeedLimit)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "updateDamageAmount", VehicleBreakdowns.updateDamageAmount)
end

function VehicleBreakdowns.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onEnterVehicle", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onLeaveVehicle", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onDelete", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", VehicleBreakdowns)
	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", VehicleBreakdowns)

end

function VehicleBreakdowns.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "addDamage", VehicleBreakdowns.addDamage)
	SpecializationUtil.registerFunction(vehicleType, "getSpeed", VehicleBreakdowns.getSpeed)
	SpecializationUtil.registerFunction(vehicleType, "lightingsFault", VehicleBreakdowns.lightingsFault)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrain", VehicleBreakdowns.setBatteryDrain)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrainIfGeneratorFailure", VehicleBreakdowns.setBatteryDrainIfGeneratorFailure)
	SpecializationUtil.registerFunction(vehicleType, "StopAI", VehicleBreakdowns.StopAI)
	SpecializationUtil.registerFunction(vehicleType, "DebugFaultPrint", VehicleBreakdowns.DebugFaultPrint)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultThermostat", VehicleBreakdowns.getIsFaultThermostat)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultThermostatoverHeating", VehicleBreakdowns.getIsFaultThermostatoverHeating)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultThermostatoverCooling", VehicleBreakdowns.getIsFaultThermostatoverCooling)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultLightings", VehicleBreakdowns.getIsFaultLightings)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultGlowPlug", VehicleBreakdowns.getIsFaultGlowPlug)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultWipers", VehicleBreakdowns.getIsFaultWipers)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultGenerator", VehicleBreakdowns.getIsFaultGenerator)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultEngine", VehicleBreakdowns.getIsFaultEngine)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultSelfStarter", VehicleBreakdowns.getIsFaultSelfStarter)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultBattery", VehicleBreakdowns.getIsFaultBattery)
	SpecializationUtil.registerFunction(vehicleType, "setIsFaultBattery", VehicleBreakdowns.setIsFaultBattery)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultOperatingHours", VehicleBreakdowns.getIsFaultOperatingHours)
	SpecializationUtil.registerFunction(vehicleType, "getIsOperatingHoursTemp", VehicleBreakdowns.getIsOperatingHoursTemp)
	SpecializationUtil.registerFunction(vehicleType, "getIsService", VehicleBreakdowns.getIsService)
	--SpecializationUtil.registerFunction(vehicleType, "setIsService", VehicleBreakdowns.setIsService)
	SpecializationUtil.registerFunction(vehicleType, "getIsDailyService", VehicleBreakdowns.getIsDailyService)
	--SpecializationUtil.registerFunction(vehicleType, "setIsDailyService", VehicleBreakdowns.setIsDailyService)
	SpecializationUtil.registerFunction(vehicleType, "getIsPeriodicServiceTime", VehicleBreakdowns.getIsPeriodicServiceTime)
	SpecializationUtil.registerFunction(vehicleType, "setIsPeriodicServiceTime", VehicleBreakdowns.setIsPeriodicServiceTime)
	SpecializationUtil.registerFunction(vehicleType, "getIsRepairStartService", VehicleBreakdowns.getIsRepairStartService)
	SpecializationUtil.registerFunction(vehicleType, "getIsRepairClockService", VehicleBreakdowns.getIsRepairClockService)
	SpecializationUtil.registerFunction(vehicleType, "getIsRepairTimeService", VehicleBreakdowns.getIsRepairTimeService)
	SpecializationUtil.registerFunction(vehicleType, "getIsRepairTimePassedService", VehicleBreakdowns.getIsRepairTimePassedService)
	SpecializationUtil.registerFunction(vehicleType, "getIsRepairScaleService", VehicleBreakdowns.getIsRepairScaleService)
	SpecializationUtil.registerFunction(vehicleType, "workshopTriggers", VehicleBreakdowns.workshopTriggers)
	SpecializationUtil.registerFunction(vehicleType, "getRepairTriggers", VehicleBreakdowns.getRepairTriggers)
	SpecializationUtil.registerFunction(vehicleType, "getShapesInRange", VehicleBreakdowns.getShapesInRange)
	SpecializationUtil.registerFunction(vehicleType, "addWorkshop", VehicleBreakdowns.addWorkshop)
	SpecializationUtil.registerFunction(vehicleType, "CalculateFinishTime", VehicleBreakdowns.CalculateFinishTime)
	SpecializationUtil.registerFunction(vehicleType, "calculateBatteryChPrice", VehicleBreakdowns.calculateBatteryChPrice)
	SpecializationUtil.registerFunction(vehicleType, "getRepairPrice_RVBClone", VehicleBreakdowns.getRepairPrice_RVBClone)
	SpecializationUtil.registerFunction(vehicleType, "getServicePrice", VehicleBreakdowns.getServicePrice)
	SpecializationUtil.registerFunction(vehicleType, "getInspectionPrice", VehicleBreakdowns.getInspectionPrice)
	SpecializationUtil.registerFunction(vehicleType, "getSellPrice_RVBClone", VehicleBreakdowns.getSellPrice_RVBClone)
	SpecializationUtil.registerFunction(vehicleType, "onStartOperatingHours", VehicleBreakdowns.onStartOperatingHours)
	SpecializationUtil.registerFunction(vehicleType, "onStopOperatingHours", VehicleBreakdowns.onStopOperatingHours)
	SpecializationUtil.registerFunction(vehicleType, "minuteChanged", VehicleBreakdowns.minuteChanged)
	SpecializationUtil.registerFunction(vehicleType, "RVBhourChanged", VehicleBreakdowns.RVBhourChanged)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryCharging", VehicleBreakdowns.setBatteryCharging)
	SpecializationUtil.registerFunction(vehicleType, "setGeneratorBatteryCharging", VehicleBreakdowns.setGeneratorBatteryCharging)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleInspection", VehicleBreakdowns.setVehicleInspection)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleRepair", VehicleBreakdowns.setVehicleRepair)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleService", VehicleBreakdowns.setVehicleService)
	SpecializationUtil.registerFunction(vehicleType, "setDamageService", VehicleBreakdowns.setDamageService)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleDamageThermostatoverHeatingFailure", VehicleBreakdowns.setVehicleDamageThermostatoverHeatingFailure)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleDamageGlowplugFailure", VehicleBreakdowns.setVehicleDamageGlowplugFailure)
	SpecializationUtil.registerFunction(vehicleType, "displayMessage", VehicleBreakdowns.displayMessage)
	SpecializationUtil.registerFunction(vehicleType, "getIsRVBMotorStarted", VehicleBreakdowns.getIsRVBMotorStarted)
	SpecializationUtil.registerFunction(vehicleType, "RVBaddRemoveMoney", VehicleBreakdowns.RVBaddRemoveMoney)
	
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVB", VehicleBreakdowns.SyncClientServer_RVB)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBFaultStorage", VehicleBreakdowns.SyncClientServer_RVBFaultStorage)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBService", VehicleBreakdowns.SyncClientServer_RVBService)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBRepair", VehicleBreakdowns.SyncClientServer_RVBRepair)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBBattery", VehicleBreakdowns.SyncClientServer_RVBBattery)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBParts", VehicleBreakdowns.SyncClientServer_RVBParts)

end

function VehicleBreakdowns.initSpecialization()
    -- vehicle schema
    local schema = Vehicle.xmlSchema

    schema:setXMLSpecializationType("VehicleBreakdowns")

    -- savegame schema
    local schemaSavegame = Vehicle.xmlSchemaSavegame
		
	local rvbSavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.INT, rvbSavegameKey .. "#timeScale", "Idő skála")
	schemaSavegame:register(XMLValueType.FLOAT, rvbSavegameKey .. "#operatingHoursTemp", "Ideiglenes üzemóra")
	schemaSavegame:register(XMLValueType.FLOAT, rvbSavegameKey .. "#TotaloperatingHours", "Összes üzemóra")
	
	schemaSavegame:register(XMLValueType.FLOAT, rvbSavegameKey .. "#operatingHours", "futott üzemóra")
	schemaSavegame:register(XMLValueType.FLOAT, rvbSavegameKey .. "#chargelevel", "Akkumulátor tölttötségi szint")
	
    local savegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.faultStorage", g_vehicleBreakdownsModName)
    schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#thermostatoverHeating", "Overheating is the most common symptom of a failing thermostat. The engine will overheat, causing severe damage.")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#thermostatoverCooling", "Overcooling is the most common symptom of a failing thermostat. The engine will overcool, causing severe damage and the engine will run rich and consume more fuel.")
		
	local parts = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.parts.part(?)", g_vehicleBreakdownsModName)
    schemaSavegame:register(XMLValueType.STRING, parts .. "#name", "")
	schemaSavegame:register(XMLValueType.INT, parts .. "#lifetime", "")
	schemaSavegame:register(XMLValueType.FLOAT, parts .. "#operatingHours", "Kár")
	schemaSavegame:register(XMLValueType.BOOL, parts .. "#repairreq", "Repair is required")
	schemaSavegame:register(XMLValueType.FLOAT, parts .. "#amount", "Megadott időközönként ennyivel nőveli a javítási értéket v mi")
	schemaSavegame:register(XMLValueType.FLOAT, parts .. "#cost", "Javítási költség")

	local serviceSavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.vehicleService", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.BOOL, serviceSavegameKey .. "#state", "Service in progress")
	schemaSavegame:register(XMLValueType.BOOL, serviceSavegameKey .. "#suspension", "Munka szüneteltetés")
	schemaSavegame:register(XMLValueType.INT, serviceSavegameKey .. "#finishday", "")
    schemaSavegame:register(XMLValueType.INT, serviceSavegameKey .. "#finishhour", "")
    schemaSavegame:register(XMLValueType.INT, serviceSavegameKey .. "#finishminute", "")
	schemaSavegame:register(XMLValueType.FLOAT, serviceSavegameKey .. "#amount", "Megadott időközönként ennyivel nőveli a javítási értéket v mi")
	schemaSavegame:register(XMLValueType.FLOAT, serviceSavegameKey .. "#cost", "Javítási költség")
	schemaSavegame:register(XMLValueType.FLOAT, serviceSavegameKey .. "#damage", "Kár")
		
	local repairSavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.vehicleRepair", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.BOOL, repairSavegameKey .. "#state", "Repair in progress")
	schemaSavegame:register(XMLValueType.BOOL, repairSavegameKey .. "#suspension", "Munka szüneteltetés")
	schemaSavegame:register(XMLValueType.INT, repairSavegameKey .. "#finishday", "")
    schemaSavegame:register(XMLValueType.INT, repairSavegameKey .. "#finishhour", "")
    schemaSavegame:register(XMLValueType.INT, repairSavegameKey .. "#finishminute", "")
	schemaSavegame:register(XMLValueType.FLOAT, repairSavegameKey .. "#amount", "Megadott időközönként ennyivel nőveli a javítási értéket v mi")
	schemaSavegame:register(XMLValueType.FLOAT, repairSavegameKey .. "#cost", "Javítási költség")
	schemaSavegame:register(XMLValueType.FLOAT, repairSavegameKey .. "#damage", "Kár")
	schemaSavegame:register(XMLValueType.FLOAT, repairSavegameKey .. "#factor", "")
	schemaSavegame:register(XMLValueType.BOOL, repairSavegameKey .. "#inspection", "")
	
	local batterySavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.vehicleBattery", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.BOOL, batterySavegameKey .. "#state", "Töltés elkezdve")
	schemaSavegame:register(XMLValueType.BOOL, batterySavegameKey .. "#suspension", "Munka szüneteltetés")
	schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishday", "")
    schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishhour", "")
    schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishminute", "")
	schemaSavegame:register(XMLValueType.FLOAT, batterySavegameKey .. "#amount", "Mennyit tölt")
	schemaSavegame:register(XMLValueType.FLOAT, batterySavegameKey .. "#cost", "Töltési költség")

end

function VehicleBreakdowns:onLoad(savegame)

	if self.spec_faultData == nil then
        self.spec_faultData = {}
    end
	
    local spec = self.spec_faultData

	spec.messageCenter = g_messageCenter	
	spec.dirtyFlag = self:getNextDirtyFlag()
	
	spec.rvb = { 5, 0, 0, 0, 0 }
	spec.faultStorage = { false, false }
	spec.service = { false, false, 0, 0, 0, 0, 0, 0, 0 }
	spec.battery = { false, false, 0, 0, 0, 0, 0 }
	spec.repair = { false, false, 0, 0, 0, 0, 0, 0, 0, false }
	spec.parts = {}

	local xmlFilePath = Utils.getFilename('config/PartsSettingsSetup.xml', g_vehicleBreakdownsDirectory)
	local xmlFile = XMLFile.load("settingSetupXml", xmlFilePath)

	if xmlFile == nil then
		return
	end

	xmlFile:iterate("Parts.Part", function (i, key)
		local name = xmlFile:getString( key.."#name")
		local lifetime = xmlFile:getInt( key.."#lifetime")
		local operatingHours = xmlFile:getFloat( key.."#operatingHours")
		local repairreq = xmlFile:getBool( key.."#repairreq")
		local amount = xmlFile:getFloat( key.."#amount")
		local cost = xmlFile:getFloat( key.."#cost")
		spec.parts[i] = {}
		spec.parts[i].name = name
		spec.parts[i].lifetime = lifetime
		spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * g_currentMission.environment.plannedDaysPerPeriod
		spec.parts[i].operatingHours = operatingHours
		spec.parts[i].repairreq = repairreq
		spec.parts[i].amount = amount
		spec.parts[i].cost = cost
	end)

	-- onUpdateTick()
	spec.instantFuel = {}
	spec.instantFuel.Consumption = string.format("%.1f l/h", 0.0)
	spec.instantFuel.time = 0

	-- repairVehicle()
	spec.repair_canfixed = true
	
	spec.isRVBMotorStarted = false
	spec.rvbmotorStartTime = 0
	spec.rvbMotorStart = false

	-- load sound effects
	if g_dedicatedServerInfo == nil then
		local file, id
		VehicleBreakdowns.sounds = {}
		for _, id in ipairs({"self_starter"}) do
			VehicleBreakdowns.sounds[id] = createSample(id)
			file = g_currentMission.vehicleBreakdowns.modDirectory.."sounds/"..id..".ogg"
			loadSample(VehicleBreakdowns.sounds[id], file, false)
		end
	end
 
    local currentTemperaturInC = g_currentMission.environment.weather:getCurrentTemperature()
    local currentTemperaturExpanded = g_i18n:getTemperature(currentTemperaturInC)
 	self.temperatureDayText = string.format("%.0f", currentTemperaturExpanded)
	if tonumber(self.temperatureDayText) < 0 then
		self.temperatureDayText = 0
	else
		self.temperatureDayText = self.temperatureDayText - 15
		if tonumber(self.temperatureDayText) < 0 then
			self.temperatureDayText = 0
		end
	end
	


	self.spec_motorized.motorTemperature.value = self.temperatureDayText
    self.spec_motorized.motorTemperature.valueMin = self.temperatureDayText
	--self.spec_motorized.motorFan.disableTemperature = 85
	self.spec_motorized.motorTemperature.valueMax = 122
	
	-- engine data
	spec.motorTemperature = self.temperatureDayText
	spec.fanEnabled = false
	spec.fanEnabledLast = false
	
	spec.fanEnableTemperature = 95
    spec.fanDisableTemperature = 85
	
	spec.lastFuelUsage = 0
	spec.lastDefUsage = 0
	spec.lastAirUsage = 0


	spec.DontStopMotor =	{}
	spec.DontStopMotor.glowPlug	= false
	spec.DontStopMotor.self_starter	= false
	spec.RandomNumber = {}
	spec.RandomNumber.glowPlug = 0
	spec.TimesSoundPlayed = {}
	spec.TimesSoundPlayed.glowPlug = 2
	spec.TimesSoundPlayed.self_starter = 2
	spec.MotorTimer = {}
	spec.MotorTimer.glowPlug = -1
	spec.MotorTimer.self_starter = -1
	spec.NumberMotorTimer = {}
	spec.NumberMotorTimer.glowPlug = 0
	spec.NumberMotorTimer.self_starter = 0
	
	spec.updateTimer = 0

	spec.addDamage = {}
	spec.addDamage.alert = false

	spec.messageCenter:subscribe(MessageType.MINUTE_CHANGED, self.minuteChanged, self)
	spec.messageCenter:subscribe(MessageType.HOUR_CHANGED, self.RVBhourChanged, self)
	
	spec.daysperiod = g_currentMission.environment.plannedDaysPerPeriod

	VehicleBreakdowns.GSET_Change = g_currentMission.vehicleBreakdowns.generalSettings.rvbDifficultyState
	
	self.speedLimit = 10
	
	spec.dashboard_check = false
	spec.dashboard_check_ok = false
	spec.dashboard_check_updateDelta = 0
	spec.dashboard_check_updateRate = 2000
	
	spec.lights_request = false
	
end
	
function VehicleBreakdowns:minuteChanged()

	local spec = self.spec_faultData
	
	if g_currentMission.environment.currentMinute ~= 0 then
		self:setVehicleService()
		self:setBatteryCharging()
		self:setVehicleInspection()
		self:setVehicleRepair()
	end
	
	local spec_M = self.spec_motorized
    if spec_M.isMotorStarted then

		self:onStopOperatingHours()
		--self:onStartOperatingHours()
		self:setDamageService()
		self:setGeneratorBatteryCharging()
		self:setVehicleDamageThermostatoverHeatingFailure()
		--self:addDamage()
		--ha a generator meghibasodik lemerul az akkumulator
		self:setBatteryDrainIfGeneratorFailure()

		local rvbfactor = {1,1,1,1,1,1,1,1}

		local alllifetime = 0
		local alloperatingHours = 0
		for i=1, 8 do
			if i ~= 2 and i ~= 4 and i ~= 8 then
				alllifetime = alllifetime + spec.parts[i].tmp_lifetime
				alloperatingHours = alloperatingHours + spec.parts[i].operatingHours
			end
		end

		local rvbDamage = 1 / (alllifetime * 60)
		self:addDamageAmount(rvbDamage, 1)
	
	else
	
		self:setBatteryDrain()
	
		--[[
			Motor hűtőfolyadék hőmérséklet csökkentése
			Ha a motor nem jár
			Ha még nem érte el az időjárásnak megfelelő hőmérsékletet
			minden percben 0.35 fokkal csökken
		]]
		if self.spec_motorized.motorTemperature.value > self.temperatureDayText then
			self.spec_motorized.motorTemperature.value = self.spec_motorized.motorTemperature.value - 0.35
		end
		
	end
	
	--[[
		Növelje a világítás üzemidejét
		Amikor ég a lámpa
		A világítás működik
		Az akkumulátor működik és a töltési szint megfelelő
		Increase the operating hours of the lighting
		When the light is on
		Lighting is working
		The battery is working and the charge level is adequate
	]]
	if self.spec_lights.currentLightState > 0 and not spec.parts[2].repairreq and not spec.parts[8].repairreq and self:getIsFaultBattery() <= 0.75 then
		local oneGameMinute = 60 * 1000 / 3600000
		spec.parts[2].operatingHours = spec.parts[2].operatingHours + oneGameMinute
		RVBParts_Event.sendEvent(self, unpack(spec.parts))
		self:raiseDirtyFlags(spec.dirtyFlag)
	end
	--[[ END ]]
	
	--[[
		Növelje az ablaktörlő üzemidejét
		Amikor a motor jár
		Ha az ablaktörlő működik és esik az eső
		Increase wiper operating hours
		When the engine is running
		If the wiper is working and it is raining
	]]
	if spec.isMotorStarted then
		local lastRainScale = g_currentMission.environment.weather:getRainFallScale()
		if self:getIsActiveForWipers() and lastRainScale > 0.01 then
			local oneGameMinute = 60 * 1000 / 3600000
			specf.parts[4].operatingHours = specf.parts[4].operatingHours + oneGameMinute
			RVBParts_Event.sendEvent(self, unpack(specf.parts))
			self:raiseDirtyFlags(specf.dirtyFlag)
		end
	end
	--[[ END ]]
	
end

function VehicleBreakdowns:RVBhourChanged()
	
	local spec = self.spec_faultData
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings
	
	if g_currentMission.environment.currentHour == GPSET.workshopClose and g_currentMission.environment.currentMinute == 0 then

		if spec.service[1] then
			spec.service[8] = spec.service[8] - spec.service[6]
			spec.service[2] = true
		end
		
		if spec.repair[1] then
			spec.repair[8] = spec.repair[8] - spec.repair[6]
			local damage = self:getDamageAmount()
			self:setDamageAmount(damage - ((spec.repair[9] / (1 / spec.repair[6])) / 100), true)
			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			spec.repair[2] = true
		end
		
		if spec.battery[1] then
			self:setIsFaultBattery(self:getIsFaultBattery() - spec.battery[6])
			spec.battery[2] = true
		end
		
		--if self.isServer then
		--elseif self.isClient then
			if spec.service[1] then
				RVBService_Event.sendEvent(self, unpack(spec.service))
			end
			if spec.repair[1] then
				RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			end
			if spec.battery[1] then
				RVBBattery_Event.sendEvent(self, unpack(spec.battery))
				RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			end
			self:raiseDirtyFlags(spec.dirtyFlag)
			
		--end
	end
	
	if g_currentMission.environment.currentHour == GPSET.workshopOpen and g_currentMission.environment.currentMinute == 0 then
	
		if spec.service[1] then
			spec.service[2] = false
		end
		if spec.repair[1] then
			spec.repair[2] = false
		end
		if spec.battery[1] then
			spec.battery[2] = false
		end
		
		--if self.isServer then
		--elseif self.isClient then
			if spec.service[1] then
				RVBService_Event.sendEvent(self, unpack(spec.service))
			end
			if spec.repair[1] then
				RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			end
			if spec.battery[1] then
				RVBBattery_Event.sendEvent(self, unpack(spec.battery))
			end
			self:raiseDirtyFlags(spec.dirtyFlag)
		--end
		
	end

	if (g_currentMission.environment.currentHour > GPSET.workshopOpen and g_currentMission.environment.currentMinute == tonumber(0)) and (g_currentMission.environment.currentHour < GPSET.workshopClose and g_currentMission.environment.currentMinute == tonumber(0)) then
		self:setBatteryCharging()
		self:setVehicleInspection()
		self:setVehicleRepair()
		self:setVehicleService()
	end
	
end

function VehicleBreakdowns:setDamageService()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns
	local servicePeriodic = math.floor(spec.rvb[4])

	if servicePeriodic > RVBSET:getIsIsPeriodicService() and self.spec_motorized.isMotorStarted then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
		spec.parts[3].operatingHours = spec.parts[3].operatingHours + oneGameMinute
		spec.parts[5].operatingHours = spec.parts[5].operatingHours + oneGameMinute
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute
		spec.parts[7].operatingHours = spec.parts[7].operatingHours + oneGameMinute

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			self:raiseDirtyFlags(spec.dirtyFlag)
		--end

		if RVBSET:getIsAlertMessage() then
			if self.getIsEntered ~= nil and self:getIsEntered() then
			--	g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_operatinghours"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_operatinghours_hud"), self:getFullName()), 5000)
			end
		end
		
	end
	
end

function VehicleBreakdowns:setVehicleDamageThermostatoverHeatingFailure()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local _value = self.spec_motorized.motorTemperature.value
	--local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
	--if _useF then _value = _value * 1.8 + 32 end
	local currentTemp = _value

	if spec.faultStorage[1] and tonumber(currentTemp) > 95 and self.spec_motorized.isMotorStarted then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			self:raiseDirtyFlags(spec.dirtyFlag)
		--end
		
		if RVBSET:getIsAlertMessage() then
			if self.getIsEntered ~= nil and self:getIsEntered() then
			--	g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_thermostat"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_thermostat_hud"), self:getFullName()), 5000)
			end
		end
		
	end
	
end

function VehicleBreakdowns:setVehicleDamageGlowplugFailure()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if self:getIsFaultGlowPlug() then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
		spec.parts[3].operatingHours = spec.parts[3].operatingHours + oneGameMinute
		spec.parts[5].operatingHours = spec.parts[5].operatingHours + oneGameMinute
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute
		spec.parts[7].operatingHours = spec.parts[7].operatingHours + oneGameMinute

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			self:raiseDirtyFlags(spec.dirtyFlag)
		--end

		if RVBSET:getIsAlertMessage() then
			if self.getIsEntered ~= nil and self:getIsEntered() then
			--	g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_glowplug"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_glowplug_hud"), self:getFullName()), 5000)
			end
		end
		
	end
	
end
		
function VehicleBreakdowns:setBatteryDrain()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if not self.spec_motorized.isMotorStarted and self.spec_lights.currentLightState > 0 and not spec.parts[2].repairreq and self:getIsFaultBattery() <= 0.75 then
		if self:getIsFaultBattery() <= 0.75 and not self.spec_motorized.isMotorStarted then

			local drainValue = 0.01
			local spec = self.spec_faultData
			local drainValue = 0.005
			if self.spec_lights.currentLightState == 1 then
				drainValue = 0.005
			elseif self.spec_lights.currentLightState == 2 then
				drainValue = 0.01
			elseif self.spec_lights.currentLightState == 3 then
				drainValue = 0.015
			elseif self.spec_lights.currentLightState == 4 then
				drainValue = 0.018
			end

			self:setIsFaultBattery(self:getIsFaultBattery() + drainValue)
			if self.isServer then
			elseif self.isClient then
				--RVB_Event.sendEvent(self, unpack(spec.faultStorage))
			end
			
			RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			self:raiseDirtyFlags(spec.dirtyFlag)
			
			if g_server ~= nil then
				--g_server:broadcastEvent(RVB_Event.new(self, unpack(spec.faultStorage)), nil, nil, self)
			else
				--g_client:getServerConnection():sendEvent(RVB_Event.new(self, unpack(spec.faultStorage)))
			end

			if RVBSET:getIsAlertMessage() then
				if self.getIsEntered ~= nil and self:getIsEntered() then
				--	g_currentMission:showBlinkingWarning(g_i18n:getText("fault_operatinghours"), 2500)
				else
				--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("fault_operatinghours_hud"), self:getFullName()), 5000)
				end
				if VehicleBreakdowns.Debug.Info then
					--Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_batteryCh_hud"), self:getFullName()))
				end
			end
		else
			local spec = self.spec_lights
			spec:deactivateLights(true)
		end
	end
	
end

function VehicleBreakdowns:setBatteryDrainIfGeneratorFailure()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if self.spec_motorized.isMotorStarted and self.spec_lights.currentLightState > 0 and not spec.parts[2].repairreq and self:getIsFaultBattery() <= 0.75 then
		if spec.parts[5].repairreq and self:getIsFaultBattery() <= 0.75 then
			local drainValue = 0.01
			local spec = self.spec_faultData
			local drainValue = 0.005
			if self.spec_lights.currentLightState == 1 then
				drainValue = 0.005
			elseif self.spec_lights.currentLightState == 2 then
				drainValue = 0.01
			elseif self.spec_lights.currentLightState == 3 then
				drainValue = 0.015
			elseif self.spec_lights.currentLightState == 4 then
				drainValue = 0.018
			end

			self:setIsFaultBattery(self:getIsFaultBattery() + drainValue)
			
			RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			self:raiseDirtyFlags(spec.dirtyFlag)
		end
	end
	
end

function VehicleBreakdowns:setBatteryCharging()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute
	
	if spec.battery[1] then
		
		if not spec.battery[2] then

			self:setIsFaultBattery(self:getIsFaultBattery() - spec.battery[6])
			--if self.isServer then
			--elseif self.isClient then
				RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			if RVBSET:getIsAlertMessage() then
				if self:displayMessage(currentMinute) == "0" or self:displayMessage(currentMinute) == "5" then
					if self.getIsEntered ~= nil and self:getIsEntered() then
						g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_alertmessage_batteryCh"), 2500)
					else
					--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_alertmessage_batteryCh_hud"), self:getFullName()), 2500)
					end
					if VehicleBreakdowns.Debug.Info then
						Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_batteryCh_hud"), self:getFullName()))
					end
				end
			end

		end

		if currentDay == spec.battery[3] and currentHour >= spec.battery[4] and currentMinute >= spec.battery[5] then

			self:setIsFaultBattery(0)

			spec.battery[1] = false
			spec.battery[2] = false
			spec.battery[3] = 0
			spec.battery[4] = 0
			spec.battery[5] = 0
			spec.battery[6] = 0

			local specm = self.spec_motorized
			specm.motorTemperature.value = 15

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end
			
			local batterycosts = spec.battery[7]
			self:RVBaddRemoveMoney(-batterycosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.battery[7] = 0
			RVBBattery_Event.sendEvent(self, unpack(spec.battery))
			RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			self:raiseDirtyFlags(spec.dirtyFlag)

		end

	end

end

function VehicleBreakdowns:setGeneratorBatteryCharging()

	local spec = self.spec_faultData

	if not spec.parts[5].repairreq and self.spec_motorized.isMotorStarted then
		if self:getIsFaultBattery() > 0 then

			self:setIsFaultBattery(self:getIsFaultBattery() - 0.005)
			if self:getIsFaultBattery() < 0 then

				self:setIsFaultBattery(0)
			end
			--if self.isServer then
			--elseif self.isClient then
				RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end
		end
	end

end

function VehicleBreakdowns:setVehicleInspection()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute

	if spec.repair[1] and not spec.repair[10] then

		if not spec.repair[2] then
	
			if RVBSET:getIsAlertMessage() then
				if self:displayMessage(currentMinute) == "0" then
					if self.getIsEntered ~= nil and self:getIsEntered() then
					--	g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_alertmessage_inspection"), 2500)
					else
					--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_alertmessage_inspection_hud"), self:getFullName()), 2500)
					end
					if VehicleBreakdowns.Debug.Info then
						Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_inspection_hud"), self:getFullName()))
					end
				end
			end

		end

		if currentDay == spec.repair[3] and currentHour >= spec.repair[4] and currentMinute >= spec.repair[5] then

			spec.repair[1] = false
			spec.repair[2] = false
			spec.repair[3] = 0
			spec.repair[4] = 0
			spec.repair[5] = 0
			spec.repair[6] = 0
			spec.repair[8] = 0
			spec.repair[9] = 0

			local specm = self.spec_motorized
			specm.motorTemperature.value = 15
			--specm.motorFan.enableTemperature = 95
			--specm.motorFan.disableTemperature = 85

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end
			
			local faultListText = {}

			local thermostatRandom = false
			for i=1, #spec.parts do

				local Partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
				
				if Partfoot >= 95 then
						if i == 1 then
						thermostatRandom = true
					end
					spec.parts[i].repairreq = true
					VehicleBreakdowns:DebugFaultPrint(i)
				end
				if spec.parts[i].repairreq then
					table.insert(faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
				end

			end

			if thermostatRandom and not spec.faultStorage[1] and not spec.faultStorage[2] then
				local faultNum = {1,2}
				if faultNum[math.random(#faultNum)] == 1 then
					spec.faultStorage[1] = true
				else
					spec.faultStorage[2] = true
				end
			
				--if self.isServer then
				--elseif self.isClient then
					RVB_Event.sendEvent(self, unpack(spec.faultStorage))
					self:raiseDirtyFlags(spec.dirtyFlag)
				--end
				thermostatRandom = false
			end
		
			if table.maxn(faultListText) > 0 then
				spec.repair[10] = true
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText("RVB_inspectionDialogFault"), self:getFullName(), g_i18n:formatMoney(self:getRepairPrice_RVBClone(true))).."\n"..g_i18n:getText("RVB_ErrorList").."\n"..table.concat(faultListText,", "),
					dialogType=DialogElement.TYPE_INFO
				})
			else
				
				local damage = self:getDamageAmount()
				local end_text = ""

				if damage >= 0.90 then

					--if self.isServer then

						g_currentMission:addMoney(-self:getRepairPrice(), self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR, true, true)
		
						self:setDamageAmount(0, true)
					
					--end
					end_text = "RVB_inspectionDialogEnd_other"
					
				else
					end_text = "RVB_inspectionDialogEnd"
				end
				
				spec.repair[10] = false
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText(end_text), self:getFullName()),
					dialogType=DialogElement.TYPE_INFO,
					yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
				})
				
			end
			
			local inspectioncosts = spec.repair[7]
			self:RVBaddRemoveMoney(-inspectioncosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.repair[7] = 0
			RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			self:raiseDirtyFlags(spec.dirtyFlag)
						
		end

	end

end

function VehicleBreakdowns:RVBaddRemoveMoney(amount, farmId, moneyType)
	if g_currentMission:getIsServer() then
		g_currentMission:addMoneyChange(amount, farmId, moneyType, true)
		local farm = g_farmManager:getFarmById(farmId)
		if farm ~= nil then
			farm:changeBalance(amount, moneyType)
		end
	end
end

function VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings
	local FinishHour = 0
	local FinishMinute = 0
	local PlusHourForMinutes = math.floor((g_currentMission.environment.currentMinute + AddMinute) / 60)
	local FinishDay = g_currentMission.environment.currentDay + math.floor((g_currentMission.environment.currentHour + PlusHourForMinutes + AddHour) / GPSET.workshopClose)

	if g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes >= GPSET.workshopClose then
		FinishHour = g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes  - (GPSET.workshopClose - GPSET.workshopOpen) - (math.max(g_currentMission.environment.currentHour - GPSET.workshopClose, 0))
		if PlusHourForMinutes >= 1 then
			FinishMinute = g_currentMission.environment.currentMinute + AddMinute - 60
		else
			FinishMinute = g_currentMission.environment.currentMinute + AddMinute
		end
	elseif g_currentMission.environment.currentHour < GPSET.workshopOpen then
		FinishHour = g_currentMission.environment.currentHour + AddHour + (GPSET.workshopOpen - g_currentMission.environment.currentHour)
		FinishMinute = 0 + AddMinute
	else
		FinishHour = g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes
		if PlusHourForMinutes >= 1 then
			FinishMinute = g_currentMission.environment.currentMinute + AddMinute - 60
		else
			FinishMinute = g_currentMission.environment.currentMinute + AddMinute
		end
	end

	if FinishHour >= GPSET.workshopClose then
		FinishDay = FinishDay + 1
		FinishHour = FinishHour - (GPSET.workshopClose - GPSET.workshopOpen)
	end

	return FinishDay, FinishHour, FinishMinute
end


function VehicleBreakdowns:setVehicleRepair()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute

	if spec.repair[1] and spec.repair[10] then

		if not spec.repair[2] then

			spec.repair[8] = spec.repair[8] - spec.repair[6]
			local damage = self:getDamageAmount()
			self:setDamageAmount(damage - ((spec.repair[9] / (1 / spec.repair[6])) / 100), true)
			if self.isServer then
				self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			end

			--if self.isServer then
			--elseif self.isClient then
				RVBRepair_Event.sendEvent(self, unpack(spec.repair))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			if RVBSET:getIsAlertMessage() then
				if self:displayMessage(currentMinute) == "0" then
					if self.getIsEntered ~= nil and self:getIsEntered() then
						g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_alertmessage_repair"), 2500)
					else
					--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_alertmessage_repair_hud"), self:getFullName()), 2500)
					end
					if VehicleBreakdowns.Debug.Info then
						Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_repair_hud"), self:getFullName()))
					end
				end
			end

		end

		if currentDay == spec.repair[3] and currentHour >= spec.repair[4] and currentMinute >= spec.repair[5] then

			spec.repair[1] = false
			spec.repair[2] = false
			spec.repair[3] = 0
			spec.repair[4] = 0
			spec.repair[5] = 0
			spec.repair[6] = 0
			spec.repair[8] = 0
			spec.repair[9] = 0
			spec.repair[10] = false
			local specm = self.spec_motorized
			specm.motorTemperature.value = 15
			specm.motorFan.enableTemperature = 95
			specm.motorFan.disableTemperature = 85

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end

			for index, value in pairs(spec.faultStorage) do
				if type(value) == "boolean" and value then
					spec.faultStorage[index] = false
				end
			end
			
			for i=1, #spec.parts do
				if spec.parts[i].repairreq then
					spec.parts[i].operatingHours = 0.000000
					spec.parts[i].repairreq = false
				end
			end

			local repaircosts = spec.repair[7]
			self:RVBaddRemoveMoney(-repaircosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.repair[7] = 0
			RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			self:raiseDirtyFlags(spec.dirtyFlag)

		end

	end

end

function VehicleBreakdowns:setVehicleService()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute

	if self:getIsService() then

		if not spec.service[2] then

			spec.service[8] = spec.service[8] - spec.service[6]
			--if self.isServer then
			--elseif self.isClient then
				RVBService_Event.sendEvent(self, unpack(spec.service))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			if RVBSET:getIsAlertMessage() then
				if self:displayMessage(currentMinute) == "0" then
					if self.getIsEntered ~= nil and self:getIsEntered() then
						g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_alertmessage_service"), 2500)
					else
					--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_alertmessage_service_hud"), self:getFullName()), 2500)
					end
					if VehicleBreakdowns.Debug.Info then
						Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_service_hud"), self:getFullName()))
					end
				end
			end

		end

		if currentDay == spec.service[3] and currentHour >= spec.service[4] and currentMinute >= spec.service[5] then

			spec.service[1] = false
			spec.service[2] = false
			spec.service[3] = 0
			spec.service[4] = 0
			spec.service[5] = 0
			spec.service[6] = 0
			spec.service[8] = 0
			spec.rvb[4] = 0

			local specm = self.spec_motorized
			specm.motorTemperature.value = 15

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end

			local servicecosts = spec.service[7]
			self:RVBaddRemoveMoney(-servicecosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.service[7] = 0
			RVBService_Event.sendEvent(self, unpack(spec.service))
			RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			self:raiseDirtyFlags(spec.dirtyFlag)

		end

	end

end

function VehicleBreakdowns:displayMessage(currentMinute)
	local count = 0
	local string_num = tostring(currentMinute)
	for i in string_num:gmatch("") do
		count = count + 1
	end
	count = count - 1
	return string.sub(string_num, count, count)
end

function VehicleBreakdowns:onPostLoad(savegame)

	if savegame == nil or savegame.resetVehicles then
        return
    end

    local spec = self.spec_faultData

	local rvbkey = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns")
	spec.rvb[1] = savegame.xmlFile:getValue(rvbkey .. "#timeScale", 5)
	local starthours = savegame.xmlFile:getValue(rvbkey .. "#operatingHoursTemp", spec.rvb[2]) * 1000
	spec.rvb[2] = math.max(Utils.getNoNil(starthours, 0), 0)
	local totaloperatinghours = savegame.xmlFile:getValue(rvbkey .. "#TotaloperatingHours", spec.rvb[3]) * 1000
	spec.rvb[3] = math.max(Utils.getNoNil(totaloperatinghours, 0), 0)
	
	local periodic = savegame.xmlFile:getValue(rvbkey .. "#operatingHours", 0) * 1000
	spec.rvb[4] = math.max(Utils.getNoNil(periodic, 0), 0)
	self:setIsFaultBattery(savegame.xmlFile:getValue(rvbkey .. "#chargelevel", 0))
	
    local key = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.faultStorage")
	spec.faultStorage[1] = savegame.xmlFile:getValue(key .. "#thermostatoverHeating", false)
	spec.faultStorage[2] = savegame.xmlFile:getValue(key .. "#thermostatoverCooling", false)
	
	local keyservice = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.vehicleService")
	spec.service[1] = savegame.xmlFile:getValue(keyservice .. "#state", false)
	spec.service[2] = savegame.xmlFile:getValue(keyservice .. "#suspension", false)
	spec.service[3] = savegame.xmlFile:getValue(keyservice .. "#finishday", 0)
	spec.service[4] = savegame.xmlFile:getValue(keyservice .. "#finishhour", 0)
	spec.service[5] = savegame.xmlFile:getValue(keyservice .. "#finishminute", 0)
	spec.service[6] = savegame.xmlFile:getValue(keyservice .. "#amount", 0)
	spec.service[7] = savegame.xmlFile:getValue(keyservice .. "#cost", 0)
	spec.service[8] = savegame.xmlFile:getValue(keyservice .. "#damage", 0)

	local keyrepair = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.vehicleRepair")
	spec.repair[1] = savegame.xmlFile:getValue(keyrepair .. "#state", false)
	spec.repair[2] = savegame.xmlFile:getValue(keyrepair .. "#suspension", false)
	spec.repair[3] = savegame.xmlFile:getValue(keyrepair .. "#finishday", 0)
	spec.repair[4] = savegame.xmlFile:getValue(keyrepair .. "#finishhour", 0)
	spec.repair[5] = savegame.xmlFile:getValue(keyrepair .. "#finishminute", 0)
	spec.repair[6] = savegame.xmlFile:getValue(keyrepair .. "#amount", 0)
	spec.repair[7] = savegame.xmlFile:getValue(keyrepair .. "#cost", 0)
	spec.repair[8] = savegame.xmlFile:getValue(keyrepair .. "#damage", 0)
	spec.repair[9] = savegame.xmlFile:getValue(keyrepair .. "#factor", 0)
	spec.repair[10] = savegame.xmlFile:getValue(keyrepair .. "#inspection", false)

	local keybattery = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.vehicleBattery")
	spec.battery[1] = savegame.xmlFile:getValue(keybattery .. "#state", false)
	spec.battery[2] = savegame.xmlFile:getValue(keybattery .. "#suspension", false)
	spec.battery[3] = savegame.xmlFile:getValue(keybattery .. "#finishday", 0)
	spec.battery[4] = savegame.xmlFile:getValue(keybattery .. "#finishhour", 0)
	spec.battery[5] = savegame.xmlFile:getValue(keybattery .. "#finishminute", 0)
	spec.battery[6] = savegame.xmlFile:getValue(keybattery .. "#amount", 0)
	spec.battery[7] = savegame.xmlFile:getValue(keybattery .. "#cost", 0)


	local keyparts = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns")	
	for i=1, #spec.parts do
		local keyss = string.format("%s.parts.part(%d)", keyparts, i)
		spec.parts[i].name = savegame.xmlFile:getValue(keyss .. "#name", spec.parts[i].name)
		spec.parts[i].lifetime = savegame.xmlFile:getValue(keyss .. "#lifetime", spec.parts[i].lifetime)
		spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * g_currentMission.environment.plannedDaysPerPeriod
		spec.parts[i].operatingHours = savegame.xmlFile:getValue(keyss .. "#operatingHours", spec.parts[i].operatingHours) * 1000
		spec.parts[i].repairreq = savegame.xmlFile:getValue(keyss .. "#repairreq", spec.parts[i].repairreq)
		spec.parts[i].amount = savegame.xmlFile:getValue(keyss .. "#amount", spec.parts[i].amount)
		spec.parts[i].cost = savegame.xmlFile:getValue(keyss .. "#cost", spec.parts[i].cost)
	end

	if self.isServer then
	elseif self.isClient then

		spec.rvb = { unpack(spec.rvb) }
		spec.faultStorage = { unpack(spec.faultStorage) }
		spec.parts = { unpack(spec.parts) }
		spec.service = { unpack(spec.service) }
		spec.repair = { unpack(spec.repair) }
		spec.battery = { unpack(spec.battery) }

	end

end

function VehicleBreakdowns.SyncClientServer_RVB(vehicle, rvb)
	local spec = vehicle.spec_faultData
	spec.rvb = { unpack(spec.rvb) }
end

function VehicleBreakdowns.SyncClientServer_RVBFaultStorage(vehicle, faultStorage)
	local spec = vehicle.spec_faultData
	spec.faultStorage = { unpack(spec.faultStorage) }
end

function VehicleBreakdowns.SyncClientServer_RVBService(vehicle, service)
	local spec = vehicle.spec_faultData
	spec.service = { unpack(spec.service) }
end

function VehicleBreakdowns.SyncClientServer_RVBRepair(vehicle, repair)
	local spec = vehicle.spec_faultData
	spec.repair = { unpack(spec.repair) }
end

function VehicleBreakdowns.SyncClientServer_RVBBattery(vehicle, battery)
	local spec = vehicle.spec_faultData
	spec.battery = { unpack(spec.battery) }
end

function VehicleBreakdowns.SyncClientServer_RVBParts(vehicle, parts)
	local spec = vehicle.spec_faultData
	spec.parts = { unpack(spec.parts) }
end

function VehicleBreakdowns:onReadStream(streamId, connection)
	
	if self.spec_faultData == nil then
        return
    end

	local spec = self.spec_faultData
	
	spec.rvb[1] = streamReadInt16(streamId)
	spec.rvb[2] = streamReadFloat32(streamId)
	spec.rvb[3] = streamReadFloat32(streamId)
	
	spec.rvb[4] = streamReadFloat32(streamId)
	spec.rvb[5] = streamReadFloat32(streamId)
		
	for index=1, 2 do
		spec.faultStorage[index] = streamReadBool(streamId)
	end
	
	spec.service[1] = streamReadBool(streamId)
	spec.service[2] = streamReadBool(streamId)
	spec.service[3] = streamReadInt16(streamId)
	spec.service[4] = streamReadInt16(streamId)
	spec.service[5] = streamReadInt16(streamId)
	spec.service[6] = streamReadFloat32(streamId)
	spec.service[7] = streamReadFloat32(streamId)
	spec.service[8] = streamReadFloat32(streamId)
	
	spec.repair[1] = streamReadBool(streamId)
	spec.repair[2] = streamReadBool(streamId)
	spec.repair[3] = streamReadInt16(streamId)
	spec.repair[4] = streamReadInt16(streamId)
	spec.repair[5] = streamReadInt16(streamId)
	spec.repair[6] = streamReadFloat32(streamId)
	spec.repair[7] = streamReadFloat32(streamId)
	spec.repair[8] = streamReadFloat32(streamId)
	spec.repair[9] = streamReadFloat32(streamId)
	spec.repair[10] = streamReadBool(streamId)
	
	spec.battery[1] = streamReadBool(streamId)
	spec.battery[2] = streamReadBool(streamId)
	spec.battery[3] = streamReadInt16(streamId)
	spec.battery[4] = streamReadInt16(streamId)
	spec.battery[5] = streamReadInt16(streamId)
	spec.battery[6] = streamReadFloat32(streamId)
	spec.battery[7] = streamReadFloat32(streamId)

	for i=1, #spec.parts do
		spec.parts[i].name = streamReadString(streamId)
		spec.parts[i].lifetime = streamReadInt16(streamId)
		spec.parts[i].tmp_lifetime = streamReadInt16(streamId)
		spec.parts[i].operatingHours = streamReadFloat32(streamId)
		spec.parts[i].repairreq = streamReadBool(streamId)
		spec.parts[i].amount = streamReadFloat32(streamId)
		spec.parts[i].cost = streamReadFloat32(streamId)
	end
	
	if self.isClient then
		spec.rvb = { unpack(spec.rvb) }
		spec.faultStorage = { unpack(spec.faultStorage) }
		spec.parts = { unpack(spec.parts) }
		spec.service = { unpack(spec.service) }
		spec.repair = { unpack(spec.repair) }
		spec.battery = { unpack(spec.battery) }
	end
	
	spec.motorTemperature = streamReadFloat32(streamId)
	spec.fanEnabled = streamReadBool(streamId)
	
	spec.fanEnableTemperature = streamReadFloat32(streamId)
	spec.fanDisableTemperature = streamReadFloat32(streamId)
	spec.lastFuelUsage = streamReadFloat32(streamId)
	spec.lastDefUsage = streamReadFloat32(streamId)
	spec.lastAirUsage = streamReadFloat32(streamId)

end


function VehicleBreakdowns:onWriteStream(streamId, connection)
	
	if self.spec_faultData == nil then
		return
	end
	
	local spec = self.spec_faultData
	
	streamWriteInt16(streamId, spec.rvb[1])
	streamWriteFloat32(streamId, spec.rvb[2])
	streamWriteFloat32(streamId, spec.rvb[3])
	
	streamWriteFloat32(streamId, spec.rvb[4])
	streamWriteFloat32(streamId, self:getIsFaultBattery())
	
	for index=1, 2 do
		streamWriteBool(streamId, spec.faultStorage[index])
	end
	
	streamWriteBool(streamId, spec.service[1])
	streamWriteBool(streamId, spec.service[2])
	streamWriteInt16(streamId, spec.service[3])
	streamWriteInt16(streamId, spec.service[4])
	streamWriteInt16(streamId, spec.service[5])
	streamWriteFloat32(streamId, spec.service[6])
	streamWriteFloat32(streamId, spec.service[7])
	streamWriteFloat32(streamId, spec.service[8])

	streamWriteBool(streamId, spec.repair[1])
	streamWriteBool(streamId, spec.repair[2])
	streamWriteInt16(streamId, spec.repair[3])
	streamWriteInt16(streamId, spec.repair[4])
	streamWriteInt16(streamId, spec.repair[5])
	streamWriteFloat32(streamId, spec.repair[6])
	streamWriteFloat32(streamId, spec.repair[7])
	streamWriteFloat32(streamId, spec.repair[8])
	streamWriteFloat32(streamId, spec.repair[9])
	streamWriteBool(streamId, spec.repair[10])

	streamWriteBool(streamId, spec.battery[1])
	streamWriteBool(streamId, spec.battery[2])
	streamWriteInt16(streamId, spec.battery[3])
	streamWriteInt16(streamId, spec.battery[4])
	streamWriteInt16(streamId, spec.battery[5])
	streamWriteFloat32(streamId, spec.battery[6])
	streamWriteFloat32(streamId, spec.battery[7])
	
	for i=1, #spec.parts do
		streamWriteString(streamId, spec.parts[i].name)
		streamWriteInt16(streamId, spec.parts[i].lifetime)
		streamWriteInt16(streamId, spec.parts[i].tmp_lifetime)
		streamWriteFloat32(streamId, spec.parts[i].operatingHours)
		streamWriteBool(streamId, spec.parts[i].repairreq)
		streamWriteFloat32(streamId, spec.parts[i].amount)
		streamWriteFloat32(streamId, spec.parts[i].cost)
	end
	
	streamWriteFloat32(streamId, spec.motorTemperature)
	streamWriteBool(streamId, spec.fanEnabled)
	streamWriteFloat32(streamId, spec.fanEnableTemperature)
	streamWriteFloat32(streamId, spec.fanDisableTemperature)
	streamWriteFloat32(streamId, spec.lastFuelUsage)
	streamWriteFloat32(streamId, spec.lastDefUsage)
	streamWriteFloat32(streamId, spec.lastAirUsage)

end
	
function VehicleBreakdowns:onReadUpdateStream(streamId, timestamp, connection)
	if connection:getIsServer() then
		local spec = self.spec_faultData
		if streamReadBool(streamId) then			
			spec.rvb[1] = streamReadInt16(streamId)
			spec.rvb[2] = streamReadFloat32(streamId)
			spec.rvb[3] = streamReadFloat32(streamId)
			
			spec.rvb[4] = streamReadFloat32(streamId)
			spec.rvb[5] = streamReadFloat32(streamId)
			
			for index=1, 2 do
				spec.faultStorage[index] = streamReadBool(streamId)
			end
	
			spec.service[1] = streamReadBool(streamId)
			spec.service[2] = streamReadBool(streamId)
			spec.service[3] = streamReadInt16(streamId)
			spec.service[4] = streamReadInt16(streamId)
			spec.service[5] = streamReadInt16(streamId)
			spec.service[6] = streamReadFloat32(streamId)
			spec.service[7] = streamReadFloat32(streamId)
			spec.service[8] = streamReadFloat32(streamId)
	
			spec.repair[1] = streamReadBool(streamId)
			spec.repair[2] = streamReadBool(streamId)
			spec.repair[3] = streamReadInt16(streamId)
			spec.repair[4] = streamReadInt16(streamId)
			spec.repair[5] = streamReadInt16(streamId)
			spec.repair[6] = streamReadFloat32(streamId)
			spec.repair[7] = streamReadFloat32(streamId)
			spec.repair[8] = streamReadFloat32(streamId)
			spec.repair[9] = streamReadFloat32(streamId)
			spec.repair[10] = streamReadBool(streamId)
	
			spec.battery[1] = streamReadBool(streamId)
			spec.battery[2] = streamReadBool(streamId)
			spec.battery[3] = streamReadInt16(streamId)
			spec.battery[4] = streamReadInt16(streamId)
			spec.battery[5] = streamReadInt16(streamId)
			spec.battery[6] = streamReadFloat32(streamId)
			spec.battery[7] = streamReadFloat32(streamId)
			
			for i=1, #spec.parts do
				spec.parts[i].name = streamReadString(streamId)
				spec.parts[i].lifetime = streamReadInt16(streamId)
				spec.parts[i].tmp_lifetime = streamReadInt16(streamId)
				spec.parts[i].operatingHours = streamReadFloat32(streamId)
				spec.parts[i].repairreq = streamReadBool(streamId)
				spec.parts[i].amount = streamReadFloat32(streamId)
				spec.parts[i].cost = streamReadFloat32(streamId)
			end
			
			spec.motorTemperature = streamReadFloat32(streamId)
			spec.fanEnabled = streamReadBool(streamId)
			spec.fanEnableTemperature = streamReadFloat32(streamId)
			spec.fanDisableTemperature = streamReadFloat32(streamId)
			spec.lastFuelUsage = streamReadFloat32(streamId)
			spec.lastDefUsage = streamReadFloat32(streamId)
			spec.lastAirUsage = streamReadFloat32(streamId)
			
		end
	end
end

function VehicleBreakdowns:onWriteUpdateStream(streamId, connection, dirtyMask)

	if not connection:getIsServer() then
		local spec = self.spec_faultData
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
		
			streamWriteInt16(streamId, spec.rvb[1])
			streamWriteFloat32(streamId, spec.rvb[2])
			streamWriteFloat32(streamId, spec.rvb[3])
			
			streamWriteFloat32(streamId, spec.rvb[4])
			streamWriteFloat32(streamId, self:getIsFaultBattery())
	
			for index=1, 2 do
				streamWriteBool(streamId, spec.faultStorage[index])
			end
	
			streamWriteBool(streamId, spec.service[1])
			streamWriteBool(streamId, spec.service[2])
			streamWriteInt16(streamId, spec.service[3])
			streamWriteInt16(streamId, spec.service[4])
			streamWriteInt16(streamId, spec.service[5])
			streamWriteFloat32(streamId, spec.service[6])
			streamWriteFloat32(streamId, spec.service[7])
			streamWriteFloat32(streamId, spec.service[8])

			streamWriteBool(streamId, spec.repair[1])
			streamWriteBool(streamId, spec.repair[2])
			streamWriteInt16(streamId, spec.repair[3])
			streamWriteInt16(streamId, spec.repair[4])
			streamWriteInt16(streamId, spec.repair[5])
			streamWriteFloat32(streamId, spec.repair[6])
			streamWriteFloat32(streamId, spec.repair[7])
			streamWriteFloat32(streamId, spec.repair[8])
			streamWriteFloat32(streamId, spec.repair[9])
			streamWriteBool(streamId, spec.repair[10])

			streamWriteBool(streamId, spec.battery[1])
			streamWriteBool(streamId, spec.battery[2])
			streamWriteInt16(streamId, spec.battery[3])
			streamWriteInt16(streamId, spec.battery[4])
			streamWriteInt16(streamId, spec.battery[5])
			streamWriteFloat32(streamId, spec.battery[6])
			streamWriteFloat32(streamId, spec.battery[7])
			
			for i=1, #spec.parts do
				streamWriteString(streamId, spec.parts[i].name)
				streamWriteInt16(streamId, spec.parts[i].lifetime)
				streamWriteInt16(streamId, spec.parts[i].tmp_lifetime)
				streamWriteFloat32(streamId, spec.parts[i].operatingHours)
				streamWriteBool(streamId, spec.parts[i].repairreq)
				streamWriteFloat32(streamId, spec.parts[i].amount)
				streamWriteFloat32(streamId, spec.parts[i].cost)
			end

			streamWriteFloat32(streamId, spec.motorTemperature)
			streamWriteBool(streamId, spec.fanEnabled)
			streamWriteFloat32(streamId, spec.fanEnableTemperature)
			streamWriteFloat32(streamId, spec.fanDisableTemperature)
			streamWriteFloat32(streamId, spec.lastFuelUsage)
			streamWriteFloat32(streamId, spec.lastDefUsage)
			streamWriteFloat32(streamId, spec.lastAirUsage)
			self.spec_motorized.motorTemperature.valueSend = spec.motorTemperature
			
			self.spec_motorized.motorFan.enabled = spec.fanEnabled
			self.spec_motorized.motorFan.enableTemperature = spec.fanEnableTemperature
			self.spec_motorized.motorFan.disableTemperature = spec.fanDisableTemperature

		end
	end
end


function VehicleBreakdowns:saveToXMLFile(xmlFile, key, usedModNames)
	local spec = self.spec_faultData
	
	xmlFile:setValue(key .. "#timeScale", spec.rvb[1])
	xmlFile:setValue(key .. "#operatingHoursTemp", self:getIsOperatingHoursTemp() / 1000)
	xmlFile:setValue(key .. "#TotaloperatingHours", spec.rvb[3] / 1000)
	
	xmlFile:setValue(key .. "#operatingHours", spec.rvb[4] / 1000)
	xmlFile:setValue(key .. "#chargelevel", self:getIsFaultBattery())
	
    xmlFile:setValue(key .. ".faultStorage#thermostatoverHeating", self:getIsFaultThermostatoverHeating())
	xmlFile:setValue(key .. ".faultStorage#thermostatoverCooling", self:getIsFaultThermostatoverCooling())
	
	xmlFile:setValue(key .. ".vehicleService#state", spec.service[1])
	xmlFile:setValue(key .. ".vehicleService#suspension", spec.service[2])
	xmlFile:setValue(key .. ".vehicleService#finishday", spec.service[3])
	xmlFile:setValue(key .. ".vehicleService#finishhour", spec.service[4])
	xmlFile:setValue(key .. ".vehicleService#finishminute", spec.service[5])
	xmlFile:setValue(key .. ".vehicleService#amount", spec.service[6])
	xmlFile:setValue(key .. ".vehicleService#cost", spec.service[7])
	xmlFile:setValue(key .. ".vehicleService#damage", spec.service[8])
		
	xmlFile:setValue(key .. ".vehicleRepair#state", spec.repair[1])
	xmlFile:setValue(key .. ".vehicleRepair#suspension", spec.repair[2])
	xmlFile:setValue(key .. ".vehicleRepair#finishday", spec.repair[3])
	xmlFile:setValue(key .. ".vehicleRepair#finishhour", spec.repair[4])
	xmlFile:setValue(key .. ".vehicleRepair#finishminute", spec.repair[5])
	xmlFile:setValue(key .. ".vehicleRepair#amount", spec.repair[6])
	xmlFile:setValue(key .. ".vehicleRepair#cost", spec.repair[7])
	xmlFile:setValue(key .. ".vehicleRepair#damage", spec.repair[8])
	xmlFile:setValue(key .. ".vehicleRepair#factor", spec.repair[9])
	xmlFile:setValue(key .. ".vehicleRepair#inspection", spec.repair[10])
	
	xmlFile:setValue(key .. ".vehicleBattery#state", spec.battery[1])
	xmlFile:setValue(key .. ".vehicleBattery#suspension", spec.battery[2])
	xmlFile:setValue(key .. ".vehicleBattery#finishday", spec.battery[3])
	xmlFile:setValue(key .. ".vehicleBattery#finishhour", spec.battery[4])
	xmlFile:setValue(key .. ".vehicleBattery#finishminute", spec.battery[5])
	xmlFile:setValue(key .. ".vehicleBattery#amount", spec.battery[6])
	xmlFile:setValue(key .. ".vehicleBattery#cost", spec.battery[7])

	for i=1, #spec.parts do
		local keyss = string.format("%s.parts.part(%d)", key, i)
		xmlFile:setValue( keyss.."#name", spec.parts[i].name)
		xmlFile:setValue( keyss.."#lifetime", spec.parts[i].lifetime)
		xmlFile:setValue( keyss.."#operatingHours", spec.parts[i].operatingHours / 1000)
		xmlFile:setValue( keyss.."#repairreq", spec.parts[i].repairreq)
		xmlFile:setValue( keyss.."#amount", spec.parts[i].amount)
		xmlFile:setValue( keyss.."#cost", spec.parts[i].cost)
	end

	local spec_M = self.spec_motorized
	if spec_M.isMotorStarted then
		self:onStopOperatingHours()
		--self:onStartOperatingHours()
	end
		
end

function VehicleBreakdowns.onRegisterActionEvents(self, isActiveForInput, isActiveForInputIgnoreSelection)

	local rvbs = self.spec_faultData
	
	if self.isClient then

		if self.getIsEntered ~= nil and self:getIsEntered() then
		
			local spec = self.spec_lights

			self:clearActionEventsTable(spec.actionEvents)

			local rvbToggleLights = Lights.actionEventToggleLights
			local rvbToggleLightsBack = Lights.actionEventToggleLightsBack
			local rvbToggleLightFront = Lights.actionEventToggleLightFront
			local rvbToggleWorkLightBack = Lights.actionEventToggleWorkLightBack
			local rvbToggleWorkLightFront = Lights.actionEventToggleWorkLightFront
			local rvbToggleHighBeamLight = Lights.actionEventToggleHighBeamLight
			
			if self:getIsFaultLightings() or self:getIsFaultBattery() ~= 0 and tonumber(self:getIsFaultBattery()) >= 0.75 then
				rvbToggleLights = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleLightsBack = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleLightFront = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleWorkLightBack = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleWorkLightFront = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleHighBeamLight = VehicleBreakdowns.actionToggleLightsFault
			end

			if isActiveForInputIgnoreSelection then

				local _
					_, spec.actionEventIdLight = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHTS, self, rvbToggleLights, false, true, false, true, nil)
				local _, actionEventIdReverse = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHTS_BACK, self, rvbToggleLightsBack, false, true, false, true, nil)
				local _, actionEventIdFront = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHT_FRONT, self, rvbToggleLightFront, false, true, false, true, nil)
				local _, actionEventIdWorkBack = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_WORK_LIGHT_BACK, self, rvbToggleWorkLightBack, false, true, false, true, nil)
				local _, actionEventIdWorkFront = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_WORK_LIGHT_FRONT, self, rvbToggleWorkLightFront, false, true, false, true, nil)
				local _, actionEventIdHighBeam = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_HIGH_BEAM_LIGHT, self, rvbToggleHighBeamLight, false, true, false, true, nil)

				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_HAZARD, self, Lights.actionEventToggleTurnLightHazard, false, true, false, true, nil)
				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_LEFT, self, Lights.actionEventToggleTurnLightLeft, false, true, false, true, nil)
				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_RIGHT, self, Lights.actionEventToggleTurnLightRight, false, true, false, true, nil)
				local _, actionEventIdBeacon = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_BEACON_LIGHTS, self, Lights.actionEventToggleBeaconLights, false, true, false, true, nil)

				-- action events that are only active if getIsActiveForLights
				spec.actionEventsActiveChange = {actionEventIdFront, actionEventIdWorkBack, actionEventIdWorkFront, actionEventIdHighBeam, actionEventIdBeacon}

				for _,actionEvent in pairs(spec.actionEvents) do
					if actionEvent.actionEventId ~= nil then
						g_inputBinding:setActionEventTextVisibility(actionEvent.actionEventId, false)
						g_inputBinding:setActionEventTextPriority(actionEvent.actionEventId, GS_PRIO_LOW)
					end
				end

				if g_beaconLightManager:getNumOfLights() > 0 and getPlatformId() == PlatformId.PS4 then
					g_inputBinding:setActionEventTextPriority(actionEventIdBeacon, GS_PRIO_VERY_LOW)
					g_inputBinding:setActionEventTextVisibility(actionEventIdBeacon, true)
				end

				g_inputBinding:setActionEventTextVisibility(spec.actionEventIdLight, not g_currentMission.environment.isSunOn)
				g_inputBinding:setActionEventTextVisibility(actionEventIdReverse, false)
					
			end

		end

	end
	
end
	
function VehicleBreakdowns:actionToggleLightsFault()

	local spec = self.spec_faultData

	if self:getIsFaultLightings() or tonumber(self:getIsFaultBattery()) >= 0.75 then

		local vehicleBreakdownMain = g_currentMission.vehicleBreakdowns

		if vehicleBreakdownMain.generalSettings.alertmessage then
			if self.getIsEntered ~= nil and self:getIsEntered() then
				g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_lights"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_lights_hud"), self:getFullName()), 5000)
			end
		end

	end
  
end

function VehicleBreakdowns:StopAI(self)
    local rootVehicle = self.rootVehicle
    if rootVehicle ~= nil and rootVehicle:getIsAIActive() then
        rootVehicle:stopCurrentAIJob(AIMessageErrorVehicleBroken.new())
    end
end

function VehicleBreakdowns:onUpdate(dt)

	local spec = self.spec_faultData
	local motorized = self.spec_motorized

	if not self:getIsEntered() then
		self:raiseActive()
	end

	if self:getIsFaultLightings() or tonumber(self:getIsFaultBattery()) >= 0.75 then
		if self.isClient then
			if self:getIsEntered() then
				if not spec.lights_request then
					spec.lights_request = true
					self:requestActionEventUpdate()
				end
			end
		end
	else
		spec.lights_request = false
	end
	
	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	
	if spec.daysperiod ~= g_currentMission.environment.plannedDaysPerPeriod then
		spec.daysperiod = g_currentMission.environment.plannedDaysPerPeriod
		for i=1, #spec.parts do
			spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * g_currentMission.environment.plannedDaysPerPeriod * GSET.rvbDifficultyState
		end
	end

	if VehicleBreakdowns.GSET_Change ~= GSET.rvbDifficultyState then

		VehicleBreakdowns.GSET_Change = GSET.rvbDifficultyState

		for i=1, #spec.parts do
			if GSET.rvbDifficultyState == 1 then
				spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
			elseif GSET.rvbDifficultyState == 2 then
				spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
			else
				spec.parts[i].tmp_lifetime = spec.parts[i].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
			end
		end

	end
	
	if self:getIsFaultGlowPlug() then
		local rnumsec = 2500
		if spec.RandomNumber.glowPlug == 0 then
			spec.RandomNumber.glowPlug = math.random(1, 3)
			spec.TimesSoundPlayed.glowPlug = spec.RandomNumber.glowPlug
		end

		if not spec.DontStopMotor.glowPlug then

			if self:getIsMotorStarted() then
				spec.MotorTimer.glowPlug = spec.MotorTimer.glowPlug - dt
				spec.NumberMotorTimer.glowPlug = math.min(-spec.MotorTimer.glowPlug / rnumsec, 0.9) 
				if spec.NumberMotorTimer.glowPlug >= 0.243589 then
					self:stopMotor()
					spec.MotorTimer.glowPlug = -1
					self:startMotor()
					spec.TimesSoundPlayed.glowPlug = spec.TimesSoundPlayed.glowPlug - 1
					self:setVehicleDamageGlowplugFailure()
				end

				if spec.NumberMotorTimer.glowPlug >= 0.243589 and spec.TimesSoundPlayed.glowPlug == 0 then
					spec.DontStopMotor.glowPlug = true
					spec.TimesSoundPlayed.glowPlug = 2
					spec.RandomNumber.glowPlug = 0
				end
			end
		end
		
		if not self:getIsMotorStarted() then
			if spec.DontStopMotor.glowPlug then
				spec.DontStopMotor.glowPlug = false
			end
		end

	end

	if tonumber(self:getIsFaultBattery()) >= 0.75 or self:getIsFaultSelfStarter() and not motorized.isMotorStarted then

		if self.isClient then
			local rvbvolume = 0.550000
			if g_soundManager:getIsIndoor() then
				rvbvolume = 0.250000
			else
				rvbvolume = 0.550000
			end
			setSampleVolume(VehicleBreakdowns.sounds["self_starter"], rvbvolume)
		end
		
		if not spec.DontStopMotor.self_starter then

			if self:getIsRVBMotorStarted() then

				spec.MotorTimer.self_starter = spec.MotorTimer.self_starter - dt
				spec.NumberMotorTimer.self_starter = math.min(-spec.MotorTimer.self_starter / 2000, 0.9) 
				if spec.NumberMotorTimer.self_starter >= 0.9 then
					self:stopMotor()
					spec.MotorTimer.self_starter = -1
					self:startMotor()
					spec.TimesSoundPlayed.self_starter = spec.TimesSoundPlayed.self_starter - 1

					local oneGameMinute = 60 * 1000 / 3600000
					-- PARTS operatingHours
					spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
					spec.parts[3].operatingHours = spec.parts[3].operatingHours + oneGameMinute
					spec.parts[5].operatingHours = spec.parts[5].operatingHours + oneGameMinute
					spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute
					spec.parts[7].operatingHours = spec.parts[7].operatingHours + oneGameMinute

					--if self.isServer then
					--elseif self.isClient then
						RVBParts_Event.sendEvent(self, unpack(spec.parts))
						self:raiseDirtyFlags(spec.dirtyFlag)
					--end
					if GSET.alertmessage then
						if self.getIsEntered ~= nil and self:getIsEntered() then
							--g_currentMission:showBlinkingWarning(g_i18n:getText("fault_glowplug"), 2500)
							--g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("fault_glowplug_hud"), self:getFullName()), 5000)
						else
							--g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("fault_glowplug_hud"), self:getFullName()), 5000)
						end
					end
					
				end
				
				if spec.NumberMotorTimer.self_starter >= 0.9 and spec.TimesSoundPlayed.self_starter == 0 then
					spec.DontStopMotor.self_starter = true
					spec.TimesSoundPlayed.self_starter = 2
					self:stopMotor()
				end
			end

		end

		if not self:getIsRVBMotorStarted() then

			if spec.DontStopMotor.self_starter then
				spec.DontStopMotor.self_starter = false
			end

		end

	end


	if self:getIsMotorStarted() then
		if self.isClient then
			local MotorSounds = self.spec_motorized.motorSamples
			local gearboxSounds = self.spec_motorized.gearboxSamples
			if not g_soundManager:getIsSamplePlaying(MotorSounds[1]) then
				g_soundManager:playSamples(MotorSounds)
			end
			if not g_soundManager:getIsSamplePlaying(gearboxSounds[1]) then
				g_soundManager:playSamples(gearboxSounds)
			end
			if not g_soundManager:getIsSamplePlaying(self.spec_motorized.samples.retarder) then
				g_soundManager:playSample(self.spec_motorized.samples.retarder)
			end
		end	
	end
	
	if motorized.isMotorStarted then

		self:addDamage()
		
		local thermostatRandom = false
		
		
		local currentHour = g_currentMission.environment.currentHour
		local currentMinute = g_currentMission.environment.currentMinute
	
		local faultHour = math.random(7, 22)
		local faultMinute = math.random(2, 58)
		
		
		--PARTS FAULT SAVE
		for i=1, #spec.parts do

			local Partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime

			if Partfoot >= 95 then
				if i == 1 then
					thermostatRandom = true
				end
				if not spec.parts[i].repairreq then
					VehicleBreakdowns:DebugFaultPrint(i)
				end
				spec.parts[i].repairreq = true
				
			end
			self:raiseDirtyFlags(spec.dirtyFlag)
		end
	
		if thermostatRandom and not spec.faultStorage[1] and not spec.faultStorage[2] then
			local faultNum = {1,2}
			if faultNum[math.random(#faultNum)] == 1 then
				spec.faultStorage[1] = true
			else
				spec.faultStorage[2] = true
			end
			
			--if self.isServer then
			--elseif self.isClient then
				RVBParts_Event.sendEvent(self, unpack(spec.parts))
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			thermostatRandom = false
		end
		
	end
	
	if self:getIsFaultLightings() or self:getIsFaultBattery() ~= nil and self:getIsFaultBattery() ~= 0 then
		self:lightingsFault()
	end


	if self:getIsFaultGenerator() or self:getIsFaultEngine() then
		self:StopAI(self)
	end

	if g_workshopScreen.isOpen == true and g_workshopScreen.vehicle ~= nil and g_workshopScreen.vehicle.spec_motorized ~= nil then
	--	g_workshopScreen.repairButton.disabled = true
	end

	-- sync engine data with server
	spec.updateTimer = spec.updateTimer + dt
	if self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then 
		spec.motorTemperature = motorized.motorTemperature.value
		spec.fanEnabled = motorized.motorFan.enabled
		spec.lastFuelUsage = motorized.lastFuelUsage
		spec.lastDefUsage = motorized.lastDefUsage
		spec.lastAirUsage = motorized.lastAirUsage
		spec.fanEnableTemperature = motorized.motorFan.enableTemperature
		spec.fanDisableTemperature = motorized.motorFan.disableTemperature
		if spec.updateTimer >= 1000 and spec.motorTemperature ~= self.spec_motorized.motorTemperature.valueSend then
			self:raiseDirtyFlags(spec.dirtyFlag)
		end
		if spec.fanEnabled ~= spec.fanEnabledLast then
			spec.fanEnabledLast = spec.fanEnabled
			self:raiseDirtyFlags(spec.dirtyFlag)
		end
	end
	if self.isClient and not self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then
		motorized.motorTemperature.value = spec.motorTemperature
		motorized.motorFan.enabled = spec.fanEnabled
		motorized.lastFuelUsage = spec.lastFuelUsage
		motorized.lastDefUsage = spec.lastDefUsage
		motorized.lastAirUsage = spec.lastAirUsage
		motorized.motorFan.enableTemperature = spec.fanEnableTemperature
		motorized.motorFan.disableTemperature = spec.fanDisableTemperature
	end
	-- sync end

end


function VehicleBreakdowns:getSpeedLimit(superFunc, onlyIfWorking)
    local limit = math.huge
	
	local spec = self.spec_faultData
	if spec ~= nil and spec.parts[6].repairreq and spec.parts[6].operatingHours >= 96 then
		limit = 7
	end
	
    local doCheckSpeedLimit = self:doCheckSpeedLimit()
    if onlyIfWorking == nil or (onlyIfWorking and doCheckSpeedLimit) then
        limit = self:getRawSpeedLimit()

        local damage = self:getVehicleDamage()
        if damage > 0 then
            limit = limit * (1 - damage * Vehicle.DAMAGED_SPEEDLIMIT_REDUCTION)
        end
    end

    local attachedImplements
    if self.getAttachedImplements ~= nil then
        attachedImplements = self:getAttachedImplements()
    end
    if attachedImplements ~= nil then
        for _, implement in pairs(attachedImplements) do
            if implement.object ~= nil then
                local speed, implementDoCheckSpeedLimit = implement.object:getSpeedLimit(onlyIfWorking)
                if onlyIfWorking == nil or (onlyIfWorking and implementDoCheckSpeedLimit) then
					if spec ~= nil and spec.parts[6].repairreq and spec.parts[6].operatingHours >= 96 then
						limit = 3
					end
                    limit = math.min(limit, speed)
                end
                doCheckSpeedLimit = doCheckSpeedLimit or implementDoCheckSpeedLimit
            end
        end
    end
    return limit, doCheckSpeedLimit
end

---Start motor
-- @param boolean noEventSend no event send
function VehicleBreakdowns:startMotor(superFunc, noEventSend)

	local spec = self.spec_motorized
	local rvbs = self.spec_faultData
	
	local RVB = {}
	RVB.COLOR = {}
	RVB.COLOR.DEFAULT = {1, 1, 1, 0.2}
	RVB.COLOR.YELLOWFAULT = {1.0000, 0.6592, 0.0000, 1}
	RVB.COLOR.REDFAULT = {0.8069, 0.0097, 0.0097, 0.5}
	RVB.COLOR.BLUEFAULT = SpeedMeterDisplay.COLOR.CRUISE_CONTROL_ON
	local dashboard_icons = g_currentMission.vehicleBreakdowns.ui_hud.icons	
	dashboard_icons.temperature.overlay:setColor(unpack(RVB.COLOR.BLUEFAULT))
	dashboard_icons.battery.overlay:setColor(unpack(RVB.COLOR.REDFAULT))
	dashboard_icons.lights.overlay:setColor(unpack(RVB.COLOR.YELLOWFAULT))
	dashboard_icons.engine.overlay:setColor(unpack(RVB.COLOR.YELLOWFAULT))
	dashboard_icons.service.overlay:setColor(unpack(RVB.COLOR.YELLOWFAULT))
	rvbs.dashboard_check = true
	
	if self.spec_motorized.motorTemperature.value <= self.temperatureDayText then
		self.spec_motorized.motorTemperature.value = self.temperatureDayText
	end
	
	-- GLOWPLUG SERULES
	local oneGameMinute = 60 * 1000 / 3600000
	if self.temperatureDayText > 20 then
		oneGameMinute = oneGameMinute / 2
	elseif self.temperatureDayText <= 20 and self.temperatureDayText >= 5 then
		oneGameMinute = oneGameMinute
	else
		oneGameMinute = oneGameMinute * 1.5
	end
	rvbs.parts[3].operatingHours = rvbs.parts[3].operatingHours + oneGameMinute
	
	--SELFSTARTER SERULES
	--starter
	local oneGameMinute7 = 60 * 1000 / 3600000
	rvbs.parts[7].operatingHours = rvbs.parts[7].operatingHours + oneGameMinute7
	
	RVBParts_Event.sendEvent(self, unpack(rvbs.parts))
	self:raiseDirtyFlags(rvbs.dirtyFlag)
	

	if self:getIsFaultSelfStarter() or tonumber(self:getIsFaultBattery()) >= 0.75 then

		if not rvbs.isRVBMotorStarted then
			rvbs.isRVBMotorStarted = true
			if self.isClient then
				local rvbvolume = 0.550000
				if g_soundManager:getIsIndoor() then
					rvbvolume = 0.250000
				else
					rvbvolume = 0.550000
				end
				playSample(VehicleBreakdowns.sounds["self_starter"], 1, rvbvolume, 0, 0, 0)
			end
		
			rvbs.rvbmotorStartTime = g_currentMission.time + self.spec_motorized.motorStartDuration

		end
	else
		if not spec.isMotorStarted then
			--self:onStartOperatingHours()
		end
		superFunc(self, noEventSend)
	end

end

---Stop motor
-- @param boolean noEventSend no event send
function VehicleBreakdowns:stopMotor(superFunc, noEventSend)
	local spec = self.spec_motorized
	local rvbs = self.spec_faultData
	
	rvbs.dashboard_check_updateDelta = 0
	rvbs.dashboard_check = false
	rvbs.dashboard_check_ok = false
	
	if self:getIsFaultSelfStarter() or tonumber(self:getIsFaultBattery()) >= 0.75 then
		if rvbs.isRVBMotorStarted then
			rvbs.isRVBMotorStarted = false
			if self.isClient then
				stopSample(VehicleBreakdowns.sounds["self_starter"], 0 , 0)
			end
		end
	else
		if spec.isMotorStarted then
			--self:onStopOperatingHours()
		end
		superFunc(self, noEventSend)
	end
end


function VehicleBreakdowns:getIsRVBMotorStarted(isRunning)
    return self.spec_faultData.isRVBMotorStarted and (not isRunning or self.spec_faultData.rvbmotorStartTime < g_currentMission.time)
end

	
function VehicleBreakdowns:getIsActiveForWipers(superFunc)
	local spec = self.spec_faultData
	if self:getIsFaultWipers() and self.spec_motorized.isMotorStarted then
       return false
    end
    return superFunc(self)
end

function VehicleBreakdowns:onStartOperatingHours()

	local spec = self.spec_faultData
	
	local currentTime = g_currentMission.environment.dayTime / (1000 * 60 * 60)
	spec.rvb[2] = currentTime
	
	--if self.isServer then
	--elseif self.isClient then
		RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
		self:raiseDirtyFlags(spec.dirtyFlag)
	--end

end	

function VehicleBreakdowns:onStopOperatingHours()

	local spec = self.spec_faultData

	local oneGameMinute = 60 * 1000 / 3600000
	-- Service operatingHours
	spec.rvb[4] = spec.rvb[4] + oneGameMinute
	-- TotaloperatingHours
	spec.rvb[3] = spec.rvb[3] + oneGameMinute
	
	-- PARTS operatingHours
	spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
	spec.parts[5].operatingHours = spec.parts[5].operatingHours + oneGameMinute
	spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute
	spec.parts[8].operatingHours = spec.parts[8].operatingHours + oneGameMinute

	--if self.isServer then
	--elseif self.isClient then
		--RVB_Event.sendEvent(self, unpack(spec.faultStorage))
		RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
		RVBParts_Event.sendEvent(self, unpack(spec.parts))
		self:raiseDirtyFlags(spec.dirtyFlag)
	--end

end		

-- InfoDisplayExtension
function VehicleBreakdowns:showInfo(superFunc, box)
	if self.ideHasPower == nil then
		local powerConfig = Motorized.loadSpecValuePowerConfig(self.xmlFile)
		
		self.ideHasPower = 0
		
		if powerConfig ~= nil then
			for configName, config in pairs(self.configurations) do
				local configPower = powerConfig[configName][config]

				if configPower ~= nil then
					self.ideHasPower = configPower
				end
			end
		end
	end
	
	if self.ideHasPower ~= nil and self.ideHasPower ~= 0 then
		local hp, kw = g_i18n:getPower(self.ideHasPower)
		local neededPower = string.format(g_i18n:getText("shop_neededPowerValue"), MathUtil.round(kw), MathUtil.round(hp));
		box:addLine(g_i18n:getText("infoDisplayExtension_currentPower"), neededPower)
		
		local spec = self.spec_faultData
		
		-- BATTERY CHARGING
		if spec.battery[1] then	
			local tomorrowText = ""
			if spec.battery[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_batteryCh"), tomorrowText..string.format("%02d:%02d", spec.battery[4], spec.battery[5]))
		else
			box:addLine(g_i18n:getText("RVB_list_battery"), math.ceil((1 - self:getIsFaultBattery())*100) .. " %")
		end
		-- INSPECTION
		if spec.repair[1] and not spec.repair[10] and spec.repair[6] == 0 then
			local tomorrowText = ""
			if spec.repair[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_inspectionVheicle"), tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5]))
		end
		
		-- REPAIR
		if spec.repair[1] and spec.repair[10] then
			local tomorrowText = ""
			if spec.repair[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_repairVheicle"), tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5]))
		end
		
		if self:getIsService() then
			local tomorrowText = ""
			if spec.service[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_serviceVheicle"), tomorrowText..string.format("%02d:%02d", spec.service[4], spec.service[5]))
		end
		
	end
	superFunc(self, box)
end

function VehicleBreakdowns:onDelete()
    local spec = self.spec_faultData

	spec.messageCenter:unsubscribe(MessageType.MINUTE_CHANGED, self)
	spec.messageCenter:unsubscribe(MessageType.HOUR_CHANGED, self)
	
end


function VehicleBreakdowns:getBatteryChPrice()
	local spec = self.spec_faultData
	local currentChargeLevel = math.floor((1 - self:getIsFaultBattery())*100)
	local lackofcharge = 100 - currentChargeLevel
	spec.battery.chargeAmount = self.calculateBatteryChPrice(1000, self:getIsFaultBattery()) / lackofcharge

	return self.calculateBatteryChPrice(1000, self:getIsFaultBattery())
end

function VehicleBreakdowns.calculateBatteryChPrice(price, charge)
    -- up to 9% of the price at full damage
    -- repairing more often at low damages is rewarded - repairing always at 10% saves about half of the repair price
    return price * math.pow(charge, 1.5) * 0.09
end

function VehicleBreakdowns:addDamage()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns		

	--local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
	local _value = self.spec_motorized.motorTemperature.value
	local motor = self.spec_motorized.motor

	--if _useF then _value = _value * 1.8 + 32 end

	local maximumSpeed = motor:getMaximumForwardSpeed() * 3.6
	local maxspeedNotBreakdown = string.format("%.0f", maximumSpeed * 0.4)

	--local speedMulti = g_gameSettings:getValue('useMiles') and 0.621371192 or 1
	--maxspeedNotBreakdown = math.max(maxspeedNotBreakdown * speedMulti, 0)
	maxspeedNotBreakdown = string.format("%.0f", maxspeedNotBreakdown)

	local currentspeed = self:getSpeed(self)
	local currentTemp = _value
	local mintempNotBreakdown = 30
	
	local oneGameMinute = 60 * 1000 / 3600000
	
	--if _useF then mintempNotBreakdown = string.format("%.0f", mintempNotBreakdown * 1.8 + 32) end

	if tonumber(currentTemp) < tonumber(mintempNotBreakdown) and tonumber(currentspeed) > tonumber(maxspeedNotBreakdown) then
		
		local mennyivel = currentspeed - maxspeedNotBreakdown
		local breakdownValue = 0

		if tonumber(mennyivel) > 0 then
		
			if tonumber(mennyivel) > 0 and tonumber(mennyivel) < 6 then
				breakdownValue = 0.00001
				oneGameMinute = oneGameMinute
			elseif tonumber(mennyivel) > 5 and tonumber(mennyivel) < 16 then
				breakdownValue = 0.00002
				oneGameMinute = oneGameMinute * 1.5
			elseif tonumber(mennyivel) > 15 and tonumber(mennyivel) < 26 then
				breakdownValue = 0.00003
				oneGameMinute = oneGameMinute * 2
			elseif tonumber(mennyivel) > 25 then
				breakdownValue = 0.00005
				oneGameMinute = oneGameMinute * 2.5
			end

			local oneGameMinute = 60 * 1000 / 3600000
			-- PARTS operatingHours
			spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute
			spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute

			--if self.isServer then
			--elseif self.isClient then
				RVBParts_Event.sendEvent(self, unpack(spec.parts))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			local fault_text = "RVB_fault_"
			local fault_hud_text = "RVB_fault_hud"
			if spec.faultStorage[2] then
				fault_text = "RVB_fault_thermostatC"
				fault_hud_text = "RVB_fault_thermostatC_hud"
			end
			if RVBSET:getIsAlertMessage() and not spec.addDamage.alert then
				if self.getIsEntered ~= nil and self:getIsEntered() then
					g_currentMission:showBlinkingWarning(g_i18n:getText(fault_text), 2500)
				--	g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, "- "..string.format(g_i18n:getText(fault_hud_text), self:getFullName()))
				else
				--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText(fault_hud_text), self:getFullName()), 5000)
				end
				spec.addDamage.alert = true
			end

		end

	end

end

function VehicleBreakdowns:DebugFaultPrint(fault)
	local faultListText = {}
	table.insert(faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[fault]))
	if table.maxn(faultListText) > 0 then
		local NotifiText = g_i18n:getText("RVB_ErrorNotifi")..table.concat(faultListText,", ")
		g_currentMission:addGameNotification(g_i18n:getText("input_VEHICLE_BREAKDOWN_MENU"), NotifiText, "", 2048)
	end
end
		
-- IGAZÁBÓL NEM KELL
function VehicleBreakdowns:onEnterVehicle()

	local spec = self.spec_faultData
	--DebugUtil.printTableRecursively(g_currentMission.hud.vehicleSchema,"_",0,2)
end


function VehicleBreakdowns:onLeaveVehicle()
	local spec = self.spec_faultData
	if spec.isRVBMotorStarted then
        	spec.isRVBMotorStarted = false
		if self.isClient then
			stopSample(VehicleBreakdowns.sounds["self_starter"], 0 , 0)
		end
	end
end

function VehicleBreakdowns:mouseEvent(posX, posY, isDown, isUp, button)
end

function VehicleBreakdowns:keyEvent(unicode, sym, modifier, isDown)
end

function VehicleBreakdowns:lightingsFault()

	local spec = self.spec_faultData

	if self:getIsFaultLightings() or self:getIsFaultBattery() >= 0.75 then
		self:setLightsTypesMask(0, true, true)
	end

end

function VehicleBreakdowns:getCanMotorRun(superFunc)
	if self.spec_faultData ~= nil then
		local spec = self.spec_faultData
		local engine_percent = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
		if engine_percent < 99 and not spec.battery[1] and not spec.service[1] and not spec.repair[1] then -- not spec.parts[5].repairreq and not spec.parts[6].repairreq and
			return superFunc(self)
		end
	end
	
    return false
end

function VehicleBreakdowns:getMotorNotAllowedWarning()
    local spec = self.spec_motorized

    for _, fillUnit in pairs(spec.propellantFillUnitIndices) do
        if self:getFillUnitFillLevel(fillUnit) == 0 then
            return spec.consumersEmptyWarning
        end
    end
	
	local specf = self.spec_faultData
	
	if self:getIsFaultGenerator()and not specf.repair[1] then
        --return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_GENERATOR
    end

	local engine_percent = (specf.parts[6].operatingHours * 100) / specf.parts[6].tmp_lifetime
	if engine_percent >= 99 and not specf.repair[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE
    end
	
	if not specf.repair[10] and specf.repair[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_INSPECTION
	end
	if specf.repair[10] and specf.repair[1] and not specf.repair[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_REPAIR
	end
	if specf.repair[10] and specf.repair[1] and specf.repair[2] or not specf.repair[10] and specf.repair[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    end
	
	if specf.service[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SERVICE
    end
	if specf.service[1] and specf.service[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    end
	
	if specf.battery[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_BATTERY_CHARGING
    end
	if specf.battery[1] and specf.battery[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    end

    local canMotorRun, reason = spec.motor:getCanMotorRun()
    if not canMotorRun then
        if reason == VehicleMotor.REASON_CLUTCH_NOT_ENGAGED then
            return spec.clutchNoEngagedWarning
        end
    end

    return nil
end

function VehicleBreakdowns:updateMotorTemperature(superFunc, dt)
    local spec = self.spec_motorized

	local rvb = self.spec_faultData
	
    local delta = spec.motorTemperature.heatingPerMS * dt
    local factor = (1 + 4*spec.actualLoadPercentage) / 5
    delta = delta * (factor + self:getMotorRpmPercentage())
    spec.motorTemperature.value = math.min(spec.motorTemperature.valueMax, spec.motorTemperature.value + delta)

    -- cooling due to wind
    delta = spec.motorTemperature.coolingByWindPerMS * dt
    local speedFactor = math.pow( math.min(1.0, self:getLastSpeed() / 30), 2 )
    spec.motorTemperature.value = math.max(spec.motorTemperature.valueMin, spec.motorTemperature.value - (speedFactor * delta))

    -- cooling per fan
    if spec.motorTemperature.value > spec.motorFan.enableTemperature then
        spec.motorFan.enabled = true
    end

	if rvb.faultStorage[1] and not spec.motorFan.enabled then
		spec.motorFan.enabled = false
		spec.motorFan.enableTemperature = 121
	end

	if rvb.faultStorage[2] then
		spec.motorFan.enableTemperature = 45
		spec.motorFan.disableTemperature = 25
	end
	
    if spec.motorFan.enabled then
        if spec.motorTemperature.value < spec.motorFan.disableTemperature then
            spec.motorFan.enabled = false
        end
    end
    if spec.motorFan.enabled then
        delta = spec.motorFan.coolingPerMS * dt
        spec.motorTemperature.value = math.max(spec.motorTemperature.valueMin, spec.motorTemperature.value - delta)
    end
end


function VehicleBreakdowns:onDraw()
	 
	g_currentMission.vehicleBreakdowns.ui_hud:setVehicle(self)
	g_currentMission.vehicleBreakdowns.ui_hud:drawHUD()

end

function VehicleBreakdowns:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_motorized
	local rvb = self.spec_faultData
	local accInput = 0
	if self.getAxisForward ~= nil then
		accInput = self:getAxisForward()
	end

	
	if rvb.dashboard_check then
	
		rvb.dashboard_check_updateDelta = rvb.dashboard_check_updateDelta + dt
		if rvb.dashboard_check_updateDelta > rvb.dashboard_check_updateRate then
			rvb.dashboard_check_updateDelta = 0
			rvb.dashboard_check = false
			rvb.dashboard_check_ok = true
		end
	end

	
	
	--
	if self:getIsMotorStarted() then
	
		if self.getCruiseControlState ~= nil then
			if self:getCruiseControlState() ~= Drivable.CRUISECONTROL_STATE_OFF then
				accInput = 1
			end
		end
			
		if self.isClient and not self.isServer then

			--self:updateMotorTemperature(dt)

			if self.getConsumerFillUnitIndex ~= nil then
				VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME + dt
				if VehicleBreakdowns.ECONOMIZER.TIME > VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD then
					VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME - VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD
					local isDieselMotor = (self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil)
					if isDieselMotor then					
						--self:updateConsumers(dt, accInput)
						local value = spec.lastFuelUsage or 0.0
						rvb.instantFuel.Consumption = string.format("%.1f l/h", value)
						VehicleBreakdowns.ECONOMIZER.DISPLAY = true
					else -- no DIESEL
						VehicleBreakdowns.ECONOMIZER.DISPLAY = false
					end
				end
			else -- no fill unit
				VehicleBreakdowns.ECONOMIZER.DISPLAY = false
			end

		else

			if self.getConsumerFillUnitIndex ~= nil then
				VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME + dt
				if VehicleBreakdowns.ECONOMIZER.TIME > VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD then
					VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME - VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD
					local isDieselMotor = (self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil)
					if isDieselMotor then					
						local value = spec.lastFuelUsage or 0.0
						rvb.instantFuel.Consumption = string.format("%.1f l/h", value)
						VehicleBreakdowns.ECONOMIZER.DISPLAY = true
					else -- no DIESEL
						VehicleBreakdowns.ECONOMIZER.DISPLAY = false
					end
				end
			else -- no fill unit
				VehicleBreakdowns.ECONOMIZER.DISPLAY = false
			end
			
		end
    end
end

function VehicleBreakdowns:getSpeed(vehicle)

	local speedMulti = g_gameSettings:getValue('useMiles') and 0.621371192 or 1
	local speed = math.max(Utils.getNoNil(vehicle.lastSpeed, 0) * 3600 * speedMulti, 0)

	return string.format("%1.0f", speed)
end

function VehicleBreakdowns:updateConsumers(superFunc, dt, accInput)
    local spec = self.spec_motorized

    local idleFactor = 0.5
    local rpmPercentage = (spec.motor.lastMotorRpm - spec.motor.minRpm) / (spec.motor.maxRpm - spec.motor.minRpm)
    local rpmFactor = idleFactor + rpmPercentage * (1-idleFactor)
    local loadFactor = math.max(spec.smoothedLoadPercentage * rpmPercentage, 0)
    local motorFactor = 0.5 * ( (0.2*rpmFactor) + (1.8*loadFactor) )

    local rvb = self.spec_faultData

    local usageFactor = 1.5 -- medium
	if rvb.parts[1].repairreq or self:getIsFaultGlowPlug() then
		usageFactor = 2.4 -- 160%
	end
    if g_currentMission.missionInfo.fuelUsage == 1 then
        usageFactor = 1.0 -- low
		if rvb.parts[1].repairreq or self:getIsFaultGlowPlug() then
			usageFactor = 1.6
		end
    elseif g_currentMission.missionInfo.fuelUsage == 3 then
        usageFactor = 2.5 -- high
		if rvb.parts[1].repairreq or self:getIsFaultGlowPlug() then
			usageFactor = 4.0
		end
    end
	
    local damage = self:getVehicleDamage()
    if damage > 0 then
        usageFactor = usageFactor * (1 + damage * Motorized.DAMAGED_USAGE_INCREASE)
    end

    -- update permanent consumers
    for _,consumer in pairs(spec.consumers) do
        if consumer.permanentConsumption and consumer.usage > 0 then
            local used = usageFactor * motorFactor * consumer.usage * dt
            if used ~= 0 then
                consumer.fillLevelToChange = consumer.fillLevelToChange + used
                if math.abs(consumer.fillLevelToChange) > 1 then
                    used = consumer.fillLevelToChange
                    consumer.fillLevelToChange = 0

                    local fillType = self:getFillUnitLastValidFillType(consumer.fillUnitIndex)

                    local stats = g_currentMission:farmStats(self:getOwnerFarmId())
                    stats:updateStats("fuelUsage", used)

                    if self:getIsAIActive() then
                        if fillType == FillType.DIESEL or fillType == FillType.DEF then
                            if g_currentMission.missionInfo.helperBuyFuel then
                                if fillType == FillType.DIESEL then
                                    local price = used * g_currentMission.economyManager:getCostPerLiter(fillType) * 1.5
                                    stats:updateStats("expenses", price)

                                    g_currentMission:addMoney(-price, self:getOwnerFarmId(), MoneyType.PURCHASE_FUEL, true)
                                end

                                used = 0
                            end
                        end
                    end

                    if fillType == consumer.fillType then
                        self:addFillUnitFillLevel(self:getOwnerFarmId(), consumer.fillUnitIndex, -used, fillType, ToolType.UNDEFINED)
                    end
                end

                if consumer.fillType == FillType.DIESEL or consumer.fillType == FillType.ELECTRICCHARGE or consumer.fillType == FillType.METHANE then
                    spec.lastFuelUsage = used / dt * 1000 * 60 * 60 -- per hour
                elseif consumer.fillType == FillType.DEF then
                    spec.lastDefUsage = used / dt * 1000 * 60 * 60 -- per hour
                end
            end
        end
    end

    -- update air consuming
    if spec.consumersByFillTypeName["AIR"] ~= nil then
        local consumer = spec.consumersByFillTypeName["AIR"]
        local fillType = self:getFillUnitLastValidFillType(consumer.fillUnitIndex)
        if fillType == consumer.fillType then
            local usage = 0

            -- consume air on brake
            local direction = self.movingDirection * self:getReverserDirection()
            local forwardBrake = direction > 0 and accInput < 0
            local backwardBrake = direction < 0 and accInput > 0
            local brakeIsPressed = self:getLastSpeed() > 1.0 and (forwardBrake or backwardBrake)
            if brakeIsPressed then
                local delta = math.abs(accInput) * dt * self:getAirConsumerUsage() / 1000
                self:addFillUnitFillLevel(self:getOwnerFarmId(), consumer.fillUnitIndex, -delta, consumer.fillType, ToolType.UNDEFINED)

                usage = delta / dt * 1000 -- per sec
            end

            --refill air fill unit if it is below given level
            local fillLevelPercentage = self:getFillUnitFillLevelPercentage(consumer.fillUnitIndex)
            if fillLevelPercentage < consumer.refillCapacityPercentage then
                consumer.doRefill = true
            elseif fillLevelPercentage == 1 then
                consumer.doRefill = false
            end

            if consumer.doRefill then
                local delta = consumer.refillLitersPerSecond / 1000 * dt
                self:addFillUnitFillLevel(self:getOwnerFarmId(), consumer.fillUnitIndex, delta, consumer.fillType, ToolType.UNDEFINED)

                usage = -delta / dt * 1000 -- per sec
            end

            spec.lastAirUsage = usage
        end
    end
end


function VehicleBreakdowns:getIsOperatingHoursTemp()
	local spec = self.spec_faultData
	return spec.rvb[2]
end

function VehicleBreakdowns:getIsFaultThermostat()
	local spec = self.spec_faultData
	return spec.parts[1].repairreq
end

function VehicleBreakdowns:getIsFaultThermostatoverHeating()
	local spec = self.spec_faultData
	return spec.faultStorage[1]
end

function VehicleBreakdowns:getIsFaultThermostatoverCooling()
	local spec = self.spec_faultData
	return spec.faultStorage[2]
end

function VehicleBreakdowns:getIsFaultLightings()
	local spec = self.spec_faultData
	return spec.parts[2].repairreq
end

function VehicleBreakdowns:getIsFaultGlowPlug()
	local spec = self.spec_faultData
	return spec.parts[3].repairreq
end

function VehicleBreakdowns:getIsFaultWipers()
	local spec = self.spec_faultData
	return spec.parts[4].repairreq
end

function VehicleBreakdowns:getIsFaultGenerator()
	local spec = self.spec_faultData
	return spec.parts[5].repairreq
end

function VehicleBreakdowns:getIsFaultEngine()
	local spec = self.spec_faultData
	return spec.parts[6].repairreq
end

function VehicleBreakdowns:getIsFaultSelfStarter()
	local spec = self.spec_faultData
	return spec.parts[7].repairreq
end

function VehicleBreakdowns:getIsFaultBattery()
	local spec = self.spec_faultData
	return spec.rvb[5]
end

function VehicleBreakdowns:setIsFaultBattery(value)
	local spec = self.spec_faultData
	spec.rvb[5] = value
	return spec.rvb[5]
end

function VehicleBreakdowns:getIsFaultOperatingHours()
	local spec = self.spec_faultData
	return spec.rvb[4]
end


function VehicleBreakdowns:getIsService()
	local spec = self.spec_faultData
	return spec.service[1]
end

function VehicleBreakdowns:getIsDailyService()
	local spec = self.spec_faultData
	return spec.service[2]
end

function VehicleBreakdowns:getIsPeriodicServiceTime()
	local spec = self.spec_faultData
	return spec.service[3]
end

function VehicleBreakdowns:setIsPeriodicServiceTime(servicetime)
	local spec = self.spec_faultData
	spec.service[3] = servicetime
end

function VehicleBreakdowns:getIsRepairStartService()
	local spec = self.spec_faultData
	return spec.vehicleService[3]
end

function VehicleBreakdowns:getIsRepairClockService()
	local spec = self.spec_faultData
	return spec.vehicleService[4]
end

function VehicleBreakdowns:getIsRepairTimeService()
	local spec = self.spec_faultData
	return spec.vehicleService[5]
end

function VehicleBreakdowns:getIsRepairTimePassedService()
	local spec = self.spec_faultData
	return spec.vehicleService[6]
end

function VehicleBreakdowns:getIsRepairScaleService()
	local spec = self.spec_faultData
	return spec.vehicleService[7]
end

-- original Wearable
function VehicleBreakdowns:updateDamageAmount(superFunc, dt)
	local rvb = self.spec_faultData
	if rvb ~= nil then
		return 0
	else
		return superFunc(dt)
	end
end
--Wearable.updateDamageAmount = Utils.overwrittenFunction(Wearable.updateDamageAmount, VehicleBreakdowns.updateDamageAmount)

function VehicleBreakdowns:repairVehicle()
	local spec = self.spec_faultData
	
	if spec ~= nil then
		g_gui:showInfoDialog({
            text = g_i18n:getText("RVB_main_repair_fault")
        })
		repair_canfixed = false
	end
	if repair_canfixed then
		if self.isServer then

			g_currentMission:addMoney(-self:getRepairPrice(), self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR, true, true)
		
			self:setDamageAmount(0)

			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)

			local total = g_currentMission:farmStats(self:getOwnerFarmId()):updateStats("repairVehicleCount", 1)
			g_achievementManager:tryUnlock("VehicleRepairFirst", total)
			g_achievementManager:tryUnlock("VehicleRepair", total)
		end
    end
end

function VehicleBreakdowns:getSellPrice_RVBClone()
    local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
    return VehicleBreakdowns.calculateSellPriceClone(storeItem, self.age, self.operatingTime, self:getPrice(), self:getRepairPrice(), self:getRepairPrice_RVBClone(), self:getRepaintPrice())
end

---Calculate price of vehicle given a bunch of parameters
function VehicleBreakdowns.calculateSellPriceClone(storeItem, age, operatingTime, price, repairPrice, repairPriceRVBClone, repaintPrice)
    local operatingTimeHours = operatingTime / (60 * 60 * 1000)
    local maxVehicleAge = storeItem.lifetime
    local ageInYears = age / Environment.PERIODS_IN_YEAR

    StoreItemUtil.loadSpecsFromXML(storeItem)

    -- Motorized vehicles depreciate differently
    local motorizedFactor = 1.0
    if storeItem.specs.power == nil then
        motorizedFactor = 1.3
    end

    local operatingTimeFactor = 1 - operatingTimeHours ^ motorizedFactor / maxVehicleAge
    local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)
	
    return math.max(price * operatingTimeFactor * ageFactor - repairPrice - repairPriceRVBClone - repaintPrice, price * 0.03)
end


function VehicleBreakdowns:getRepairPrice_RVBClone()
	local spec = self.spec_faultData

	local faultListCosts = 0

	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)
	for i=1, #spec.parts do
		if spec.parts[i].repairreq then
			faultListCosts = faultListCosts + VehicleBreakdowns.repairCosts[i]
		end
	end

	return self:getPrice() * ageFactor * faultListCosts

end


function VehicleBreakdowns:getServicePrice()

	local spec = self.spec_faultData
	
	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)

    return self:getPrice() * ageFactor * VehicleBreakdowns.repairCosts[9]

end


function VehicleBreakdowns:getInspectionPrice()

	local spec = self.spec_faultData
	
	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)

    return self:getPrice() * ageFactor * VehicleBreakdowns.repairCosts[10]

end





function table:count()
	local c = 0
	if self ~= nil then
		for _ in pairs(self) do
			c = c + 1
		end
	end
	return c
end

function table:contains(value)
	for _, v in pairs(self) do
		if v == value then
			return true
		end
	end
	return false
end

function VehicleBreakdowns.addWorkshop(items)
    if items == nil then
	return
    end
    if table.count(items) > 0 then
        for _, item in pairs(items) do
            	if item.spec_workshop and item.spec_workshop.sellingPoint then
                	if item.spec_workshop.sellingPoint.sellTriggerNode then
                    		--table.insert(VehicleBreakdowns.repairTriggers, {node=item.spec_workshop.sellingPoint.sellTriggerNode, owner=item.ownerFarmId })
                	end
			if item.spec_workshop.sellingPoint.vehicleShapesInRange then
                    		table.insert(VehicleBreakdowns.ShapesInRange, {vehicleShapesInRange=item.spec_workshop.sellingPoint.vehicleShapesInRange, owner=item.ownerFarmId })
			end
		end
		if item.spec_serviceVehicle and item.spec_serviceVehicle.workshop then
			if item.spec_serviceVehicle.workshop.vehicleShapesInRange then
				table.insert(VehicleBreakdowns.ShapesInRange, {vehicleShapesInRange=item.spec_serviceVehicle.workshop.vehicleShapesInRange, owner=item.ownerFarmId })
			end
		end
        end
    end
end

function VehicleBreakdowns.workshopTriggers()
    VehicleBreakdowns.searchedForTriggers = true
    VehicleBreakdowns.repairTriggers = {}
	VehicleBreakdowns.ShapesInRange = {}
	if g_currentMission.placeableSystem.placeables ~= nil then
        VehicleBreakdowns.addWorkshop(g_currentMission.placeableSystem.placeables)
    end

    if g_currentMission.placeables ~= nil then
        VehicleBreakdowns.addWorkshop(g_currentMission.placeables)
    end

    if g_currentMission.ownedItems ~= nil then
        for _, ownedItem in pairs(g_currentMission.ownedItems) do
			VehicleBreakdowns.addWorkshop(ownedItem.items)
        end
    end

end

function VehicleBreakdowns.getRepairTriggers()
    --if not VehicleBreakdowns.searchedForTriggers then
        VehicleBreakdowns.workshopTriggers()
    --end
    return VehicleBreakdowns.repairTriggers
end

function VehicleBreakdowns.getShapesInRange()
	VehicleBreakdowns.workshopTriggers()
	return VehicleBreakdowns.ShapesInRange
end

-- original SpeedMeterDisplay
---Update the damage gauge state.
function VehicleBreakdowns:updateDamageGauge(superFunc, dt)
    if not self.fadeDamageGaugeAnimation:getFinished() then
        self.fadeDamageGaugeAnimation:update(dt)
    end

    if self.damageGaugeActive then
        local gaugeValue = 1

        -- Show the most damage any item in the vehicle has
        local vehicles = self.vehicle.rootVehicle.childVehicles
        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            --if vehicle.getDamageShowOnHud ~= nil and vehicle:getDamageShowOnHud() then
			if vehicle.getIsSelected ~= nil and vehicle:getIsSelected() then
                gaugeValue = math.min(gaugeValue, 1 - vehicle:getDamageAmount())
            end
        end
        self.damageBarElement:setValue(gaugeValue, "DAMAGE")

        local neededColor = SpeedMeterDisplay.COLOR.DAMAGE_GAUGE
        if gaugeValue < 0.2 then
            neededColor = SpeedMeterDisplay.COLOR.DAMAGE_GAUGE_LOW
        end
        self.damageBarElement:setBarColor(neededColor[1], neededColor[2], neededColor[3])
    end
end
SpeedMeterDisplay.updateDamageGauge = Utils.overwrittenFunction(SpeedMeterDisplay.updateDamageGauge, VehicleBreakdowns.updateDamageGauge)
