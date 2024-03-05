
VehicleBreakdowns = {}

VehicleBreakdowns.Debug = {}
VehicleBreakdowns.Debug.Info = true

VehicleBreakdowns.repairTriggers = {}
VehicleBreakdowns.searchedForTriggers = false

VehicleBreakdowns.repairCosts = { 0.0015, 0.0015, 0.0025, 0.001, 0.0007, 0.005, 0.02, 0.006, 0.0005, 0.005, 0.003 }
VehicleBreakdowns.IRSBTimes = { 10800, 10800, 5400, 7200, 1800, 5400, 21600, 5400, 60, 600, 900 }
VehicleBreakdowns.faultText = { "thermostatoverHeating", "thermostatoverCooling", "lightings", "glow_plug", "wipers", "generator", "engine", "self_starter", "batteryisDead" }

VehicleBreakdowns.INGAME_NOTIFICATION = {
	1, 0.27058823529412, 0,	1.0
}

VehicleBreakdowns.ECONOMIZER = {
    REFRESH_PERIOD = 250.0,
	TIME = 0,
	DISPLAY = false
}


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
	SpecializationUtil.registerFunction(vehicleType, "randomFaultsGenerator", VehicleBreakdowns.randomFaultsGenerator)
	SpecializationUtil.registerFunction(vehicleType, "lightingsFault", VehicleBreakdowns.lightingsFault)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrain", VehicleBreakdowns.setBatteryDrain)
	SpecializationUtil.registerFunction(vehicleType, "StopAI", VehicleBreakdowns.StopAI)
	SpecializationUtil.registerFunction(vehicleType, "DebugFaultPrint", VehicleBreakdowns.DebugFaultPrint)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultThermostatoverHeating", VehicleBreakdowns.getIsFaultThermostatoverHeating)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultThermostatoverCooling", VehicleBreakdowns.getIsFaultThermostatoverCooling)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultLightings", VehicleBreakdowns.getIsFaultLightings)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultGlowPlug", VehicleBreakdowns.getIsFaultGlowPlug)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultWipers", VehicleBreakdowns.getIsFaultWipers)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultGenerator", VehicleBreakdowns.getIsFaultGenerator)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultEngine", VehicleBreakdowns.getIsFaultEngine)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultSelfStarter", VehicleBreakdowns.getIsFaultSelfStarter)
	SpecializationUtil.registerFunction(vehicleType, "getIsFaultBatteryIsDead", VehicleBreakdowns.getIsFaultBatteryIsDead)
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
	
    local savegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.faultStorage", g_vehicleBreakdownsModName)
    schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#thermostatoverHeating", "Overheating is the most common symptom of a failing thermostat. The engine will overheat, causing severe damage.")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#thermostatoverCooling", "Overcooling is the most common symptom of a failing thermostat. The engine will overcool, causing severe damage and the engine will run rich and consume more fuel.")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#lightings", "lightings")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#glowPlug", "glowPlug")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#wipers", "wipers")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#generator", "generator")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#engine", "engine")
	schemaSavegame:register(XMLValueType.BOOL, savegameKey .. "#selfStarter", "selfStarter")
	schemaSavegame:register(XMLValueType.FLOAT, savegameKey .. "#batteryisDead", "batteryisDead")
	schemaSavegame:register(XMLValueType.FLOAT, savegameKey .. "#operatingHours", "operatingHours")

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
	
	spec.rvb = { 5, 0, 0 }
	spec.faultStorage = { false, false, false, false, false, false, false, false, 0, 0 }
	spec.service = { false, false, 0, 0, 0, 0, 0, 0, 0 }
	spec.battery = { false, false, 0, 0, 0, 0, 0 }
	spec.repair = { false, false, 0, 0, 0, 0, 0, 0, 0, false }

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
 	local temperatureDayText = string.format("%.0f", currentTemperaturExpanded)
	if tonumber(temperatureDayText) < 0 then
		temperatureDayText = 0
	else
		temperatureDayText = temperatureDayText - 15
		if tonumber(temperatureDayText) < 0 then
			temperatureDayText = 0
		end
	end
	
	local specM = self.spec_motorized
	specM.motorTemperature = {}
	specM.motorTemperature.value = temperatureDayText
    specM.motorTemperature.valueSend = 20
    specM.motorTemperature.valueMax = 120
    specM.motorTemperature.valueMin = temperatureDayText
	specM.motorTemperature.heatingPerMS = 1.5 / 1000                                                    -- delta °C per ms, at full load
    specM.motorTemperature.coolingByWindPerMS = 1.00 / 1000
	specM.motorFan = {}
    specM.motorFan.enabled = false
    specM.motorFan.enableTemperature = 95
    specM.motorFan.disableTemperature = 85
    specM.motorFan.coolingPerMS = 3.0 / 1000

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

	spec.addDamage = {}
	spec.addDamage.alert = false

	spec.messageCenter:subscribe(MessageType.MINUTE_CHANGED, self.minuteChanged, self)
	spec.messageCenter:subscribe(MessageType.HOUR_CHANGED, self.RVBhourChanged, self)


	spec.updateDelta = 5001
	spec.updateRate = 5000
	
end

function VehicleBreakdowns:minuteChanged()
	
	if g_currentMission.environment.currentMinute ~= 0 then
		self:setVehicleService()
		self:setBatteryCharging()
		self:setVehicleInspection()
		self:setVehicleRepair()
	end
	
	local spec_M = self.spec_motorized
    if spec_M.isMotorStarted then

		self:onStopOperatingHours()
		self:onStartOperatingHours()
		self:setDamageService()
		self:setGeneratorBatteryCharging()
		self:setVehicleDamageThermostatoverHeatingFailure()

	else
		self:setBatteryDrain()
	end
	
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
			local damage = self.spec_wearable.damage
			self:setDamageAmount(damage - ((spec.repair[9] / (1 / spec.repair[6])) / 100), true)
			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			spec.repair[2] = true
		end
		
		if spec.battery[1] then
			spec.faultStorage[9] = spec.faultStorage[9] - spec.battery[6]
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
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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
	local servicePeriodic = math.floor(spec.faultStorage[10])

	if servicePeriodic > RVBSET:getIsIsPeriodicService() and self.spec_motorized.isMotorStarted then
			
		local breakdownValue = 0.000005
		self:setDamageAmount(self.spec_wearable.damage + breakdownValue, true)
		if self.isServer then
			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
		end

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
	local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
	if _useF then _value = _value * 1.8 + 32 end
	local currentTemp = _value

	if spec.faultStorage[1] and tonumber(currentTemp) > 95 and self.spec_motorized.isMotorStarted then

		local breakdownValue = 0.0003
		self:setDamageAmount(self.spec_wearable.damage + breakdownValue, true)
		if self.isServer then
			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
		end

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

	if spec.faultStorage[4] then

		local breakdownValue = 0.005
		self:setDamageAmount(self.spec_wearable.damage + breakdownValue, true)
		if self.isServer then
			self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
		end

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

	if not self.spec_motorized.isMotorStarted and self.spec_lights.currentLightState > 0 and not spec.faultStorage[3] and spec.faultStorage[9] <= 0.75 then
		if spec.faultStorage[9] <= 0.75 and not self.spec_motorized.isMotorStarted then

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
			spec.faultStorage[9] = spec.faultStorage[9] + drainValue
			if self.isServer then
			elseif self.isClient then
				--RVB_Event.sendEvent(self, unpack(spec.faultStorage))
			end
			
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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

function VehicleBreakdowns:setBatteryCharging()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute
	
	if spec.battery[1] then
		
		if not spec.battery[2] then

			spec.faultStorage[9] = spec.faultStorage[9] - spec.battery[6]
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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

			spec.faultStorage[9] = 0

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
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
			self:raiseDirtyFlags(spec.dirtyFlag)

		end

	end

end

function VehicleBreakdowns:setGeneratorBatteryCharging()

	local spec = self.spec_faultData

	if not spec.faultStorage[6] and self.spec_motorized.isMotorStarted then
		if spec.faultStorage[9] > 0 then
			spec.faultStorage[9] = spec.faultStorage[9] - 0.005
			if spec.faultStorage[9] < 0 then
				spec.faultStorage[9] = 0
			end
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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
			specm.motorFan.enableTemperature = 95
			specm.motorFan.disableTemperature = 85

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end
			
			local faultListText = {}
			for index, value in pairs(spec.faultStorage) do
				if type(value) == "boolean" and value then
					table.insert(faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[index]))
				end
			end
		
			if table.maxn(faultListText) > 0 then
				spec.repair[10] = true
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText("RVB_inspectionDialogFault"), self:getFullName(), g_i18n:formatMoney(self:getRepairPrice_RVBClone(true))).."\n"..g_i18n:getText("RVB_ErrorList").."\n"..table.concat(faultListText,", "),
					dialogType=DialogElement.TYPE_INFO
				})
			else
				spec.repair[10] = false
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText("RVB_inspectionDialogEnd"), self:getFullName()),
					dialogType=DialogElement.TYPE_INFO,
					yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
				})
			end
			
			local inspectioncosts = spec.repair[7]
			self:RVBaddRemoveMoney(-inspectioncosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.repair[7] = 0
			RVBRepair_Event.sendEvent(self, unpack(spec.repair))
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
			local damage = self.spec_wearable.damage
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

			local repaircosts = spec.repair[7]
			self:RVBaddRemoveMoney(-repaircosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.repair[7] = 0
			RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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
			spec.faultStorage[10] = 0

			local specm = self.spec_motorized
			specm.motorTemperature.value = 15

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end

			local servicecosts = spec.service[7]
			self:RVBaddRemoveMoney(-servicecosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.service[7] = 0
			RVBService_Event.sendEvent(self, unpack(spec.service))
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
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
	
    local key = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.faultStorage")
	spec.faultStorage[1] = savegame.xmlFile:getValue(key .. "#thermostatoverHeating", false)
	spec.faultStorage[2] = savegame.xmlFile:getValue(key .. "#thermostatoverCooling", false)
	spec.faultStorage[3] = savegame.xmlFile:getValue(key .. "#lightings", false)
	spec.faultStorage[4] = savegame.xmlFile:getValue(key .. "#glowPlug", false)
	spec.faultStorage[5] = savegame.xmlFile:getValue(key .. "#wipers", false)
	spec.faultStorage[6] = savegame.xmlFile:getValue(key .. "#generator", false)
	spec.faultStorage[7] = savegame.xmlFile:getValue(key .. "#engine", false)
	spec.faultStorage[8] = savegame.xmlFile:getValue(key .. "#selfStarter", false)
	spec.faultStorage[9] = savegame.xmlFile:getValue(key .. "#batteryisDead", 0)
	local periodic = savegame.xmlFile:getValue(key .. "#operatingHours", 0) * 1000
	spec.faultStorage[10] = math.max(Utils.getNoNil(periodic, 0), 0)
	
	--local partskey = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.parts.part")

	
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
	

	if self.isServer then
	elseif self.isClient then

		spec.rvb = { unpack(spec.rvb) }
		spec.faultStorage = { unpack(spec.faultStorage) }
		--spec.parts = { unpack(spec.parts.want) }
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

function VehicleBreakdowns:onReadStream(streamId, connection)
	
	if self.spec_faultData == nil then
        return
    end

	local spec = self.spec_faultData
	
	spec.rvb[1] = streamReadInt16(streamId)
	spec.rvb[2] = streamReadFloat32(streamId)
	spec.rvb[3] = streamReadFloat32(streamId)
		
	for index=1, 8 do
		spec.faultStorage[index] = streamReadBool(streamId)
	end
	for index=9, 10 do
		spec.faultStorage[index] = streamReadFloat32(streamId)
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

	
	if self.isClient then
		spec.rvb = { unpack(spec.rvb) }
		spec.faultStorage = { unpack(spec.faultStorage) }
		--spec.parts = { unpack(spec.parts) }
		spec.service = { unpack(spec.service) }
		spec.repair = { unpack(spec.repair) }
		spec.battery = { unpack(spec.battery) }
	end

end


function VehicleBreakdowns:onWriteStream(streamId, connection)
	
	if self.spec_faultData == nil then
		return
	end
	
	local spec = self.spec_faultData
	
	streamWriteInt16(streamId, spec.rvb[1])
	streamWriteFloat32(streamId, spec.rvb[2])
	streamWriteFloat32(streamId, spec.rvb[3])
	
	for index=1, 8 do
		streamWriteBool(streamId, spec.faultStorage[index])
	end
	for index=9, 10 do
		streamWriteFloat32(streamId, spec.faultStorage[index])
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

end


	

	
function VehicleBreakdowns:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_faultData
		if streamReadBool(streamId) then			
			spec.rvb[1] = streamReadInt16(streamId)
			spec.rvb[2] = streamReadFloat32(streamId)
			spec.rvb[3] = streamReadFloat32(streamId)
			
			for index=1, 8 do
				spec.faultStorage[index] = streamReadBool(streamId)
			end
			for index=9, 10 do
				spec.faultStorage[index] = streamReadFloat32(streamId)
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
			
		end
	end
end

function VehicleBreakdowns:onWriteUpdateStream(streamId, connection, dirtyMask)

	if connection:getIsServer() then
		local spec = self.spec_faultData
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
		
			streamWriteInt16(streamId, spec.rvb[1])
			streamWriteFloat32(streamId, spec.rvb[2])
			streamWriteFloat32(streamId, spec.rvb[3])
	
			for index=1, 8 do
				streamWriteBool(streamId, spec.faultStorage[index])
			end
			for index=9, 10 do
				streamWriteFloat32(streamId, spec.faultStorage[index])
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
			
		end
	end
end


function VehicleBreakdowns:saveToXMLFile(xmlFile, key, usedModNames)
	local spec = self.spec_faultData
	
	xmlFile:setValue(key .. "#timeScale", spec.rvb[1])
	xmlFile:setValue(key .. "#operatingHoursTemp", self:getIsOperatingHoursTemp() / 1000)
	xmlFile:setValue(key .. "#TotaloperatingHours", spec.rvb[3] / 1000)
	
    xmlFile:setValue(key .. ".faultStorage#thermostatoverHeating", self:getIsFaultThermostatoverHeating())
	xmlFile:setValue(key .. ".faultStorage#thermostatoverCooling", self:getIsFaultThermostatoverCooling())
	xmlFile:setValue(key .. ".faultStorage#lightings", self:getIsFaultLightings())
	xmlFile:setValue(key .. ".faultStorage#glowPlug", self:getIsFaultGlowPlug())
	xmlFile:setValue(key .. ".faultStorage#wipers", self:getIsFaultWipers())
	xmlFile:setValue(key .. ".faultStorage#generator", self:getIsFaultGenerator())
	xmlFile:setValue(key .. ".faultStorage#engine", self:getIsFaultEngine())
	xmlFile:setValue(key .. ".faultStorage#selfStarter", self:getIsFaultSelfStarter())
	xmlFile:setValue(key .. ".faultStorage#batteryisDead", self:getIsFaultBatteryIsDead())
	xmlFile:setValue(key .. ".faultStorage#operatingHours", self:getIsFaultOperatingHours() / 1000)
	
	--xmlFile:setValue(key .. ".parts.part#name", spec.parts[1])
	--xmlFile:setValue(key .. ".parts.part#state", spec.parts[2])
	--xmlFile:setValue(key .. ".parts.part#damage", spec.parts[3])
	--xmlFile:setValue(key .. ".parts.part#amount", spec.parts[4])
	--xmlFile:setValue(key .. ".parts.part#cost", spec.parts[5])
	--xmlFile:setValue(key .. ".parts.part#time", spec.parts[6])
	
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

	local spec_M = self.spec_motorized
	if spec_M.isMotorStarted then
		self:onStopOperatingHours()
		self:onStartOperatingHours()
	end
		
end

function VehicleBreakdowns.onRegisterActionEvents(self, isActiveForInput, isActiveForInputIgnoreSelection)

	local rvb = self.spec_faultData
	
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
			
			if rvb.faultStorage[3] or tonumber(rvb.faultStorage[9]) >= 0.75 then
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

	if spec.faultStorage[3] or tonumber(spec.faultStorage[9]) >= 0.75 then

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
		--self:raiseActive()
	end

	local GSET = g_currentMission.vehicleBreakdowns.generalSettings

	if spec.faultStorage[4] then
		local rnumsec = 2500
		if spec.RandomNumber.glowPlug == 0 then
			spec.RandomNumber.glowPlug = math.random(1, 3)
			spec.TimesSoundPlayed.glowPlug = spec.RandomNumber.glowPlug
		end

		if not spec.DontStopMotor.glowPlug then

			if self:getIsMotorStarted() then
				spec.MotorTimer.glowPlug = spec.MotorTimer.glowPlug - dt
				spec.NumberMotorTimer.glowPlug = math.min(-spec.MotorTimer.glowPlug / rnumsec, 0.9) 
				if spec.NumberMotorTimer.glowPlug >= 0.243589 then -- 0.290789
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
	
	if self:getIsControlled() then
		local motorized = self.spec_motorized
		local motor = motorized.motor
		spec.updateDelta = spec.updateDelta + dt * g_currentMission.missionInfo.timeScale
		if spec.updateDelta * g_currentMission.missionInfo.timeScale > spec.updateRate * g_currentMission.missionInfo.timeScale then
			--print(self:getFullName())
		spec.updateDelta = 0
		end
	end


	if tonumber(spec.faultStorage[9]) >= 0.75 or spec.faultStorage[8] and not motorized.isMotorStarted then

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
					self:startMotore()
					spec.TimesSoundPlayed.self_starter = spec.TimesSoundPlayed.self_starter - 1

					local breakdownValue = 0.000005
					self:setDamageAmount(self.spec_wearable.damage + breakdownValue, true)
					if self.isServer then
						self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
					end
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
		self:randomFaultsGenerator(self)
	end

	if spec.faultStorage[3] or spec.faultStorage[9] ~= nil and spec.faultStorage[9] ~= 0 then
		self:lightingsFault()
	end

	if spec.faultStorage[6] or spec.faultStorage[7] then
		self:StopAI(self)
	end

	if g_workshopScreen.isOpen == true and g_workshopScreen.vehicle ~= nil and g_workshopScreen.vehicle.spec_motorized ~= nil then
	--	g_workshopScreen.repairButton.disabled = true
	end
	
end

--[[
function Motorized:updateMotorProperties()
    local spec = self.spec_motorized
    local motor = spec.motor
    local torques, rotationSpeeds = motor:getTorqueAndSpeedValues()
    setMotorProperties(spec.motorizedNode, motor:getMinRpm()*math.pi/30, motor:getMaxRpm()*math.pi/30, motor:getRotInertia(), motor:getDampingRateFullThrottle(),
	motor:getDampingRateZeroThrottleClutchEngaged(), motor:getDampingRateZeroThrottleClutchDisengaged(), rotationSpeeds, torques)
end
]]

--[[
function VehicleMotor:getTorqueCurveValue(rpm)
    local damage = 1 - (self.vehicle:getVehicleDamage() * VehicleMotor.DAMAGE_TORQUE_REDUCTION)
    return self:getTorqueCurve():get(rpm) * damage
end
]]


---Start motor
-- @param boolean noEventSend no event send
function VehicleBreakdowns:startMotor(superFunc, noEventSend)
	local spec = self.spec_motorized
	local rvb = self.spec_faultData
	if rvb.faultStorage[8] or tonumber(rvb.faultStorage[9]) >= 0.75 then
		rvb.isRVBMotorStarted = true
		if self.isClient then
			local rvbvolume = 0.550000
			if g_soundManager:getIsIndoor() then
				rvbvolume = 0.250000
			else
				rvbvolume = 0.550000
			end
				playSample(VehicleBreakdowns.sounds["self_starter"], 1, rvbvolume, 0, 0, 0)
			end
		
			rvb.rvbmotorStartTime = g_currentMission.time + self.spec_motorized.motorStartDuration
		end
	else
		if not spec.isMotorStarted then
			self:onStartOperatingHours()
		end
		superFunc(self, noEventSend)
	end
end

---Stop motor
-- @param boolean noEventSend no event send
function VehicleBreakdowns:stopMotor(superFunc, noEventSend)
	local spec = self.spec_motorized
	local rvb = self.spec_faultData
	
	if rvb.faultStorage[8] or tonumber(rvb.faultStorage[9]) >= 0.75 then
		if rvb.isRVBMotorStarted then
			rvb.isRVBMotorStarted = false
			if self.isClient then
				stopSample(VehicleBreakdowns.sounds["self_starter"], 0 , 0)
			end
		end
	else
		if spec.isMotorStarted then
			self:onStopOperatingHours()
		end
		superFunc(self, noEventSend)
	end
end


function VehicleBreakdowns:getIsRVBMotorStarted(isRunning)
    return self.spec_faultData.isRVBMotorStarted and (not isRunning or self.spec_faultData.rvbmotorStartTime < g_currentMission.time)
end

function VehicleBreakdowns:getIsActiveForWipers(superFunc)
	local spec = self.spec_faultData
	if spec.faultStorage[5] and self.spec_motorized.isMotorStarted then
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

	-- Service operatingHours
	spec.faultStorage[10] = spec.faultStorage[10] + 0.016667
	-- TotaloperatingHours
	spec.rvb[3] = spec.rvb[3] + 0.016667

	--if self.isServer then
	--elseif self.isClient then
		RVB_Event.sendEvent(self, unpack(spec.faultStorage))
		RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
		self:raiseDirtyFlags(spec.dirtyFlag)
	--end

end		

-- InfoDisplayExtension
function VehicleBreakdowns:showInfo(superFunc, box)
	if self.ideHasPower == nil then
		local powerConfig = Motorized.loadSpecValuePowerConfig(self.xmlFile)
		
		self.ideHasPower = 0;
		
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
				tomorrowText = "holnap "
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_batteryCh"), tomorrowText..string.format("%02d:%02d", spec.battery[4], spec.battery[5]))
		else
			box:addLine(g_i18n:getText("RVB_list_battery"), math.ceil((1 - spec.faultStorage[9])*100) .. " %")
		end
		-- INSPECTION
		if spec.repair[1] and not spec.repair[10] and spec.repair[6] == 0 then
			local tomorrowText = ""
			if spec.repair[3] > g_currentMission.environment.currentDay then
				tomorrowText = "holnap "
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_inspectionVheicle"), tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5]))
		end
		
		-- REPAIR
		if spec.repair[1] and spec.repair[10] then
			local tomorrowText = ""
			if spec.repair[3] > g_currentMission.environment.currentDay then
				tomorrowText = "holnap "
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_repairVheicle"), tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5]))
		end
		
		if self:getIsService() then
			local tomorrowText = ""
			if spec.service[3] > g_currentMission.environment.currentDay then
				tomorrowText = "holnap "
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
	local currentChargeLevel = math.floor((1 - spec.faultStorage[9])*100)
	local lackofcharge = 100 - currentChargeLevel
	spec.battery.chargeAmount = self.calculateBatteryChPrice(1000, spec.faultStorage[9]) / lackofcharge
	
    return self.calculateBatteryChPrice(1000, spec.faultStorage[9])
end

function VehicleBreakdowns.calculateBatteryChPrice(price, charge)
    -- up to 9% of the price at full damage
    -- repairing more often at low damages is rewarded - repairing always at 10% saves about half of the repair price
    return price * math.pow(charge, 1.5) * 0.09
end

function VehicleBreakdowns:addDamage()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns		

	local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
	local _value = self.spec_motorized.motorTemperature.value
	local motor = self.spec_motorized.motor

	if _useF then _value = _value * 1.8 + 32 end

	local maximumSpeed = motor:getMaximumForwardSpeed() * 3.6
	local maxspeedNotBreakdown = string.format("%.0f", maximumSpeed * 0.4)

	local speedMulti = g_gameSettings:getValue('useMiles') and 0.621371192 or 1
	maxspeedNotBreakdown = math.max(maxspeedNotBreakdown * speedMulti, 0)
	maxspeedNotBreakdown = string.format("%.0f", maxspeedNotBreakdown)

	local currentspeed = self:getSpeed(self)
	local currentTemp = _value
	local mintempNotBreakdown = 30

	if _useF then mintempNotBreakdown = string.format("%.0f", mintempNotBreakdown * 1.8 + 32) end

	if tonumber(currentTemp) < tonumber(mintempNotBreakdown) and tonumber(currentspeed) > tonumber(maxspeedNotBreakdown) then
		
		local mennyivel = currentspeed - maxspeedNotBreakdown
		local breakdownValue = 0

		if tonumber(mennyivel) > 0 then
		
			if tonumber(mennyivel) > 0 and tonumber(mennyivel) < 6 then
				breakdownValue = 0.00001
			elseif tonumber(mennyivel) > 5 and tonumber(mennyivel) < 16 then
				breakdownValue = 0.00002
			elseif tonumber(mennyivel) > 15 and tonumber(mennyivel) < 26 then
				breakdownValue = 0.00003
			elseif tonumber(mennyivel) > 25 then
				breakdownValue = 0.00005
			end

			--self:addDamageAmount(math.min(0.0002*(spec.rvb[3]/1000000)+(self:getLastSpeed()/100), 1))
			--print(math.min(0.0002*(spec.rvb[3]/1000000)+(self:getLastSpeed()/100), 1))
			self:setDamageAmount(self.spec_wearable.damage + breakdownValue, true)
			if self.isServer then
				self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			end

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

function VehicleBreakdowns:randomFaultsGenerator(self)

	local spec = self.spec_faultData
    local VehicleOperatingTime = self:getOperatingTime()
	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)
	local Chance = 100	
	local VehicleDamage = math.floor(self.spec_wearable.damage * 100) / 100

	-- thermostatoverHeating or thermostatoverCooling
	if ageFactor < 0.8 and VehicleDamage > 0.03 and not spec.faultStorage[1] and not spec.faultStorage[2] then
	
		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 3500000000) * ageFactor
        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end
		
        if RandomNumber1 == RandomNumber2 then
			
			local faultNum = {1,2}
			if faultNum[math.random(#faultNum)] == 1 then
				spec.faultStorage[1] = true
				-- ez csak a fejlesztesehz kell
				VehicleBreakdowns:DebugFaultPrint(1)
			else
				spec.faultStorage[2] = true
				-- ez csak a fejlesztesehz kell
				VehicleBreakdowns:DebugFaultPrint(2)
			end
			
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end
			
		end
    end
		
	-- lightings
	if ageFactor < 0.8 and VehicleDamage > 0.01 and not spec.faultStorage[3] then
		
		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 1500000000) * ageFactor

        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end
		
        if RandomNumber1 == RandomNumber2 then
			spec.faultStorage[3] = true
			-- ez csak a fejlesztesehz kell
			VehicleBreakdowns:DebugFaultPrint(3)

			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end
		end
		
    end
	
	-- glow_plug
	if ageFactor < 0.8 and VehicleDamage > 0.06 and not spec.faultStorage[4] then

		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 4500000000) * ageFactor
        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end

        if RandomNumber1 == RandomNumber2 then

			spec.faultStorage[4] = true
			-- ez csak a fejlesztesehz kell
			VehicleBreakdowns:DebugFaultPrint(4)

			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

		end
    end
	
	-- wipers ablaktorlok
	if ageFactor < 0.8 and VehicleDamage > 0.05 and not spec.faultStorage[5] then

		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 4500000000) * ageFactor
        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end
		
        if RandomNumber1 == RandomNumber2 then
			
			spec.faultStorage[5] = true
			-- ez csak a fejlesztesehz kell
			VehicleBreakdowns:DebugFaultPrint(5)
			
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end

		end
    end
	
	-- generator or self_starter generator v önindító
	if ageFactor < 0.8 and VehicleDamage > 0.08 and not spec.faultStorage[6] and not spec.faultStorage[8] then

		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 5000000000) * ageFactor
        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end
		
        if RandomNumber1 == RandomNumber2 then
			
			local faultNum = {6,8}
			if faultNum[math.random(#faultNum)] == 6 then
				spec.faultStorage[6] = true
				-- ez csak a fejlesztesehz kell
				VehicleBreakdowns:DebugFaultPrint(6)
			else
				spec.faultStorage[8] = true
				-- ez csak a fejlesztesehz kell
				VehicleBreakdowns:DebugFaultPrint(8)
			end
			
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end
		end
    end
	
	
	-- engine motor
	if ageFactor < 0.8 and VehicleDamage > 0.15 and not spec.faultStorage[7] then

		Chance = 50000 / (VehicleDamage * VehicleOperatingTime / 9000000000) * ageFactor
        local RandomNumber1 = math.random(math.floor(Chance))
        local RandomNumber2 = math.random(math.floor(Chance))

        if Chance < 100 then
            RandomNumber1 = 0
            RandomNumber2 = 0
        end

        if RandomNumber1 == RandomNumber2 then
			spec.faultStorage[7] = true
			-- ez csak a fejlesztesehz kell
			VehicleBreakdowns:DebugFaultPrint(7)
			
			--if self.isServer then
			--elseif self.isClient then
				RVB_Event.sendEvent(self, unpack(spec.faultStorage))
				self:raiseDirtyFlags(spec.dirtyFlag)
			--end
		end
    end

	self:addDamage()

end

function VehicleBreakdowns:DebugFaultPrint(fault)
	local spec = self.spec_faultData
	print("Fault: "..fault)
	print("Fault: "..VehicleBreakdowns.faultText[fault])
end
		
-- IGAZÁBÓL NEM KELL
function VehicleBreakdowns:onEnterVehicle()

	local spec = self.spec_faultData

	if self.spec_enterable ~= nil and self.getIsEntered ~= nil and self:getIsEntered() then
	
		local count  = 9
		local i      = 0
		local failureStorageText = "semmi"
		
		while i < count do
			if spec.faultStorage[i] then
				print("onEnterVehicle Fault: "..VehicleBreakdowns.faultText[i])
				failureStorageText = VehicleBreakdowns.faultText[i]
			end
			i = i + 1
		end
	
	end
	
	--DebugUtil.printTableRecursively(g_workshopScreen,"_",0,2)
	
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

	if self:getIsFaultLightings() or self:getIsFaultBatteryIsDead() >= 0.75 then
		self:setLightsTypesMask(0, true, true)
	end

end

function VehicleBreakdowns:getCanMotorRun(superFunc)
	if self.spec_faultData ~= nil then
		local spec = self.spec_faultData
		if not spec.faultStorage[6] and not spec.faultStorage[7] and not spec.battery[1] and not spec.service[1] and not spec.repair[1] then
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
	
    if specf.faultStorage[6] and not specf.repair[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_GENERATOR
    end
	
	if specf.faultStorage[7] and not specf.repair[1] then
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

	local specf = self.spec_faultData

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
	
	if specf.faultStorage[1] then
		spec.motorFan.enabled = false
		spec.motorFan.enableTemperature = 120
	end
	
	if specf.faultStorage[2] then
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
	local specf = self.spec_faultData
	local accInput = 0
	if self.getAxisForward ~= nil then
		accInput = self:getAxisForward()
	end

	if self:getIsMotorStarted() then
	
		if self.getCruiseControlState ~= nil then
			if self:getCruiseControlState() ~= Drivable.CRUISECONTROL_STATE_OFF then
				accInput = 1
			end
		end
			
		if self.isClient and not self.isServer then

			self:updateMotorTemperature(dt)

			if self.getConsumerFillUnitIndex ~= nil then
				VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME + dt
				if VehicleBreakdowns.ECONOMIZER.TIME > VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD then
					VehicleBreakdowns.ECONOMIZER.TIME = VehicleBreakdowns.ECONOMIZER.TIME - VehicleBreakdowns.ECONOMIZER.REFRESH_PERIOD
					local isDieselMotor = (self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil)
					if isDieselMotor then					
						self:updateConsumers(dt, accInput)
						local value = spec.lastFuelUsage or 0.0
						specf.instantFuel.Consumption = string.format("%.1f l/h", value)
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
						specf.instantFuel.Consumption = string.format("%.1f l/h", value)
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

    local specf = self.spec_faultData
	
    local usageFactor = 1.5 -- medium
	if specf.faultStorage[1] or specf.faultStorage[2] or specf.faultStorage[4] then
		usageFactor = 2.4 -- 160%
	end
    if g_currentMission.missionInfo.fuelUsage == 1 then
        usageFactor = 1.0 -- low
		if specf.faultStorage[1] or specf.faultStorage[2] or specf.faultStorage[4] then
			usageFactor = 1.6
		end
    elseif g_currentMission.missionInfo.fuelUsage == 3 then
        usageFactor = 2.5 -- high
		if specf.faultStorage[1] or specf.faultStorage[2] or specf.faultStorage[4] then
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
	return spec.faultStorage[3]
end

function VehicleBreakdowns:getIsFaultGlowPlug()
	local spec = self.spec_faultData
	return spec.faultStorage[4]
end

function VehicleBreakdowns:getIsFaultWipers()
	local spec = self.spec_faultData
	return spec.faultStorage[5]
end

function VehicleBreakdowns:getIsFaultGenerator()
	local spec = self.spec_faultData
	return spec.faultStorage[6]
end

function VehicleBreakdowns:getIsFaultEngine()
	local spec = self.spec_faultData
	return spec.faultStorage[7]
end

function VehicleBreakdowns:getIsFaultSelfStarter()
	local spec = self.spec_faultData
	return spec.faultStorage[8]
end

function VehicleBreakdowns:getIsFaultBatteryIsDead()
	local spec = self.spec_faultData
	return spec.faultStorage[9]
end

function VehicleBreakdowns:getIsFaultOperatingHours()
	local spec = self.spec_faultData
	return spec.faultStorage[10]
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
	for index, value in pairs(spec.faultStorage) do
		if type(value) == "boolean" and value then
			faultListCosts = faultListCosts + VehicleBreakdowns.repairCosts[index]
		end
	end

	return self:getPrice() * ageFactor * faultListCosts

end


function VehicleBreakdowns:getServicePrice()

	local spec = self.spec_faultData
	
	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)

    return self:getPrice() * ageFactor * VehicleBreakdowns.repairCosts[10]

end


function VehicleBreakdowns:getInspectionPrice()

	local spec = self.spec_faultData
	
	local ageInYears = self.age / Environment.PERIODS_IN_YEAR
	local ageFactor = math.min(-0.1 * math.log(ageInYears) + 0.75, 0.8)

    return self:getPrice() * ageFactor * VehicleBreakdowns.repairCosts[11]

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
                    table.insert(VehicleBreakdowns.repairTriggers, {node=item.spec_workshop.sellingPoint.sellTriggerNode, owner=item.ownerFarmId })
                end
            end
			if item.spec_serviceVehicle and item.spec_serviceVehicle.workshop then
				if item.spec_serviceVehicle.workshop.vehicleTrigger then
					table.insert(VehicleBreakdowns.repairTriggers, {node=item.spec_serviceVehicle.workshop.vehicleTrigger, owner=item.ownerFarmId })
				end
			end
        end
    end
end

function VehicleBreakdowns.workshopTriggers()
    VehicleBreakdowns.searchedForTriggers = true
    VehicleBreakdowns.repairTriggers = {}

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
