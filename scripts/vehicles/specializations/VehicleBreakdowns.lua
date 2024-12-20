
VehicleBreakdowns = {}

VehicleBreakdowns.Debug = {}
VehicleBreakdowns.Debug.Info = true

VehicleBreakdowns.ShapesInRange = {}

VehicleBreakdowns.repairCosts = { 0.0015, 0.0025, 0.001, 0.0007, 0.005, 0.02, 0.006, 0.0005, 0.005, 0.003 }
VehicleBreakdowns.IRSBTimes = { 10800, 5400, 7200, 1800, 5400, 21600, 5400, 60, 600, 900 }
VehicleBreakdowns.faultText = { "THERMOSTAT", "LIGHTINGS", "GLOWPLUG", "WIPERS", "GENERATOR", "ENGINE", "SELFSTARTER", "BATTERY", "TIRE", "TIRE", "TIRE", "TIRE" }

VehicleBreakdowns.INGAME_NOTIFICATION = {
	1, 0.27058823529412, 0,	1.0
}

VehicleBreakdowns.ECONOMIZER = {
	REFRESH_PERIOD = 250.0,
	TIME = 0,
	DISPLAY = false
}

VehicleBreakdowns.FSSET_Daysperiod = 1
VehicleBreakdowns.GSET_Change_difficulty = 1
VehicleBreakdowns.GPSET_Change_thermostat = 1
VehicleBreakdowns.GPSET_Change_lightings = 1
VehicleBreakdowns.GPSET_Change_glowplug = 1
VehicleBreakdowns.GPSET_Change_wipers = 1
VehicleBreakdowns.GPSET_Change_generator = 1
VehicleBreakdowns.GPSET_Change_engine = 1
VehicleBreakdowns.GPSET_Change_selfstarter = 1
VehicleBreakdowns.GPSET_Change_battery = 1
VehicleBreakdowns.GPSET_Change_tire = 1



VehicleBreakdowns.SET = {}
VehicleBreakdowns.SET.BatteryLevel = {}
-- charge level for starting the engine
VehicleBreakdowns.SET.BatteryLevel.MOTOR = 0.10 -- 0.75
VehicleBreakdowns.SET.BatteryLevel.LIGHTS = 0.05 -- 0.85
VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS = 0.03 -- 0.90
VehicleBreakdowns.SET.BatteryLevel.TurnLIGHTS = 0.03 -- 0.90
VehicleBreakdowns.SET.BatteryLevel.BATTERYDISC = 0.95

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
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "deactivateLights", VehicleBreakdowns.deactivateLights)
	--SpecializationUtil.registerOverwrittenFunction(vehicleType, "getRawSpeedLimit", VehicleBreakdowns.getRawSpeedLimit) -- PowerConsumer
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
	--SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", VehicleBreakdowns)
end

function VehicleBreakdowns.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "addDamage", VehicleBreakdowns.addDamage)
	SpecializationUtil.registerFunction(vehicleType, "getSpeed", VehicleBreakdowns.getSpeed)
	SpecializationUtil.registerFunction(vehicleType, "lightingsFault", VehicleBreakdowns.lightingsFault)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrain", VehicleBreakdowns.setBatteryDrain)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrainingIfGeneratorFailure", VehicleBreakdowns.setBatteryDrainingIfGeneratorFailure)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryDrainingIfStartMotor", VehicleBreakdowns.setBatteryDrainingIfStartMotor)
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
	SpecializationUtil.registerFunction(vehicleType, "addWorkshop", VehicleBreakdowns.addWorkshop)
	SpecializationUtil.registerFunction(vehicleType, "getShapesInRange", VehicleBreakdowns.getShapesInRange)
	
	SpecializationUtil.registerFunction(vehicleType, "CalculateFinishTime", VehicleBreakdowns.CalculateFinishTime)
	SpecializationUtil.registerFunction(vehicleType, "getRepairPrice_RVBClone", VehicleBreakdowns.getRepairPrice_RVBClone)
	SpecializationUtil.registerFunction(vehicleType, "getServicePrice", VehicleBreakdowns.getServicePrice)
	SpecializationUtil.registerFunction(vehicleType, "getInspectionPrice", VehicleBreakdowns.getInspectionPrice)
	SpecializationUtil.registerFunction(vehicleType, "getSellPrice_RVBClone", VehicleBreakdowns.getSellPrice_RVBClone)
	SpecializationUtil.registerFunction(vehicleType, "onStartOperatingHours", VehicleBreakdowns.onStartOperatingHours)
	
	SpecializationUtil.registerFunction(vehicleType, "minuteChanged", VehicleBreakdowns.minuteChanged)
	SpecializationUtil.registerFunction(vehicleType, "RVBhourChanged", VehicleBreakdowns.RVBhourChanged)
	SpecializationUtil.registerFunction(vehicleType, "setBatteryCharging", VehicleBreakdowns.setBatteryCharging)
	SpecializationUtil.registerFunction(vehicleType, "setGeneratorBatteryCharging", VehicleBreakdowns.setGeneratorBatteryCharging)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleInspection", VehicleBreakdowns.setVehicleInspection)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleRepair", VehicleBreakdowns.setVehicleRepair)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleRepairDisplayMessage", VehicleBreakdowns.setVehicleRepairDisplayMessage)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleService", VehicleBreakdowns.setVehicleService)
	SpecializationUtil.registerFunction(vehicleType, "setDamageService", VehicleBreakdowns.setDamageService)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleDamageThermostatoverHeatingFailure", VehicleBreakdowns.setVehicleDamageThermostatoverHeatingFailure)
	SpecializationUtil.registerFunction(vehicleType, "setVehicleDamageGlowplugFailure", VehicleBreakdowns.setVehicleDamageGlowplugFailure)
	SpecializationUtil.registerFunction(vehicleType, "setWiperOperatingHours", VehicleBreakdowns.setWiperOperatingHours)
	SpecializationUtil.registerFunction(vehicleType, "setLightingsOperatingHours", VehicleBreakdowns.setLightingsOperatingHours)
	SpecializationUtil.registerFunction(vehicleType, "displayMessage", VehicleBreakdowns.displayMessage)
	SpecializationUtil.registerFunction(vehicleType, "getIsRVBMotorStarted", VehicleBreakdowns.getIsRVBMotorStarted)
	SpecializationUtil.registerFunction(vehicleType, "RVBaddRemoveMoney", VehicleBreakdowns.RVBaddRemoveMoney)
	SpecializationUtil.registerFunction(vehicleType, "inRangeOfchargingStation", VehicleBreakdowns.inRangeOfchargingStation)
	SpecializationUtil.registerFunction(vehicleType, "getBatteryChPrice", VehicleBreakdowns.getBatteryChPrice)
	SpecializationUtil.registerFunction(vehicleType, "calculateBatteryChPrice", VehicleBreakdowns.calculateBatteryChPrice)

	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVB", VehicleBreakdowns.SyncClientServer_RVB)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBFaultStorage", VehicleBreakdowns.SyncClientServer_RVBFaultStorage)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBService", VehicleBreakdowns.SyncClientServer_RVBService)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBRepair", VehicleBreakdowns.SyncClientServer_RVBRepair)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBInspection", VehicleBreakdowns.SyncClientServer_RVBInspection)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBBattery", VehicleBreakdowns.SyncClientServer_RVBBattery)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_RVBParts", VehicleBreakdowns.SyncClientServer_RVBParts)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_BatteryChargeLevel", VehicleBreakdowns.SyncClientServer_BatteryChargeLevel)
	SpecializationUtil.registerFunction(vehicleType, "SyncClientServer_Other", VehicleBreakdowns.SyncClientServer_Other)
	
	SpecializationUtil.registerFunction(vehicleType, "getBatteryFillUnitIndex", VehicleBreakdowns.getBatteryFillUnitIndex)
	
	SpecializationUtil.registerFunction(vehicleType, "batteryChargeVehicle", VehicleBreakdowns.batteryChargeVehicle)
	SpecializationUtil.registerFunction(vehicleType, "setRVBLightsStrings", VehicleBreakdowns.setRVBLightsStrings)
	SpecializationUtil.registerFunction(vehicleType, "setRVBLightsTypesMask", VehicleBreakdowns.setRVBLightsTypesMask)
	SpecializationUtil.registerFunction(vehicleType, "rvbVehicleSetLifetime", VehicleBreakdowns.rvbVehicleSetLifetime)
	SpecializationUtil.registerFunction(vehicleType, "updatePartsLifetime", VehicleBreakdowns.updatePartsLifetime)

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

	local inspectionSavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.vehicleInspection", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.BOOL, inspectionSavegameKey .. "#state", "Inspection in progress")
	schemaSavegame:register(XMLValueType.BOOL, inspectionSavegameKey .. "#suspension", "Munka szüneteltetés")
	schemaSavegame:register(XMLValueType.INT, inspectionSavegameKey .. "#finishday", "")
	schemaSavegame:register(XMLValueType.INT, inspectionSavegameKey .. "#finishhour", "")
	schemaSavegame:register(XMLValueType.INT, inspectionSavegameKey .. "#finishminute", "")
	schemaSavegame:register(XMLValueType.FLOAT, inspectionSavegameKey .. "#cost", "Javítási költség")
	schemaSavegame:register(XMLValueType.FLOAT, inspectionSavegameKey .. "#factor", "")
	schemaSavegame:register(XMLValueType.BOOL, inspectionSavegameKey .. "#inspection", "")

	local batterySavegameKey = string.format("vehicles.vehicle(?).%s.vehicleBreakdowns.vehicleBattery", g_vehicleBreakdownsModName)
	schemaSavegame:register(XMLValueType.BOOL, batterySavegameKey .. "#state", "Töltés elkezdve")
	schemaSavegame:register(XMLValueType.BOOL, batterySavegameKey .. "#suspension", "Munka szüneteltetés")
	schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishday", "")
	schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishhour", "")
	schemaSavegame:register(XMLValueType.INT, batterySavegameKey .. "#finishminute", "")
	schemaSavegame:register(XMLValueType.FLOAT, batterySavegameKey .. "#amount", "Mennyit tölt")
	schemaSavegame:register(XMLValueType.FLOAT, batterySavegameKey .. "#cost", "Töltési költség")
	
	schemaSavegame:setXMLSpecializationType()
	
end

function VehicleBreakdowns:onPreLoad(savegame)
end

function VehicleBreakdowns:onLoad(savegame)

	if self.spec_faultData == nil then
		self.spec_faultData = {}
	end

	-- ha valtozott az xml elrendezese akkor kell ez es nem lesz gond a frissitessel
	--XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.steering#index", "vehicle.drivable.steeringWheel#node")
	
	local spec = self.spec_faultData

	spec.messageCenter = g_messageCenter	
	spec.dirtyFlag = self:getNextDirtyFlag()

	spec.randoms = { 0, 0 }
	
	spec.rvb = { 5, 0, 0, 0, 0 }
	spec.faultStorage = { false, false }
	spec.service = { false, false, 0, 0, 0, 0, 0, 0, 0 }
	spec.battery = { false, false, 0, 0, 0, 0, 0 }
	spec.repair = { false, false, 0, 0, 0, 0, 0, 0, 0, false }
	spec.inspection = { false, false, 0, 0, 0, 0, 0, false }
	spec.parts = {}
	
	local xmlFilePath = Utils.getFilename('config/PartsSettingsSetup.xml', g_vehicleBreakdownsDirectory)
	local xmlFile = XMLFile.load("settingSetupXml", xmlFilePath)

	if xmlFile == nil then
		return
	end

	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings
	
	local partIndex = 1
	xmlFile:iterate("Parts.Part", function(_, key)
		local name = xmlFile:getString( key.."#name")
		local lifetime = xmlFile:getInt( key.."#lifetime", 100)
		local operatingHours = xmlFile:getFloat( key.."#operatingHours", 0)
		local repairreq = xmlFile:getBool( key.."#repairreq", false)
		local amount = xmlFile:getFloat( key.."#amount", 0)
		local cost = xmlFile:getFloat( key.."#cost", 0)

		spec.parts[partIndex] = {}
		spec.parts[partIndex].name = name or "Unknown"

		if partIndex == 1 then
			spec.parts[partIndex].lifetime = GPSET.thermostatLifetime or lifetime
		end
		if partIndex == 2 then
			spec.parts[partIndex].lifetime = GPSET.lightingsLifetime or lifetime
		end
		if partIndex == 3 then
			spec.parts[partIndex].lifetime = GPSET.glowplugLifetime or lifetime
		end
		if partIndex == 4 then
			spec.parts[partIndex].lifetime = GPSET.wipersLifetime or lifetime
		end
		if partIndex == 5 then
			spec.parts[partIndex].lifetime = GPSET.generatorLifetime or lifetime
		end
		if partIndex == 6 then
			spec.parts[partIndex].lifetime = GPSET.engineLifetime or lifetime
		end
		if partIndex == 7 then
			spec.parts[partIndex].lifetime = GPSET.selfstarterLifetime or lifetime
		end
		if partIndex == 8 then
			spec.parts[partIndex].lifetime = GPSET.batteryLifetime or lifetime
		end
		if partIndex == 9 or partIndex == 10 or partIndex == 11 or partIndex == 12 then
			spec.parts[partIndex].lifetime = GPSET.tireLifetime or lifetime
		end
		if GSET.difficulty == 1 then
			spec.parts[partIndex].tmp_lifetime = spec.parts[partIndex].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
		elseif GSET.difficulty == 2 then
			spec.parts[partIndex].tmp_lifetime = spec.parts[partIndex].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
		else
			spec.parts[partIndex].tmp_lifetime = spec.parts[partIndex].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
		end

		spec.parts[partIndex].operatingHours = operatingHours or 0
		spec.parts[partIndex].repairreq = repairreq or false
		spec.parts[partIndex].amount = amount or 0
		spec.parts[partIndex].cost = cost or 0
		
		partIndex = partIndex + 1

	end)

	for i, part in ipairs(spec.parts) do
		--print(string.format("Part %d: %s, Lifetime: %s, Operating Hours: %s, Repair Required: %s, Amount: %s, Cost: %s", i, part.name, part.lifetime, part.operatingHours, tostring(part.repairReq), part.amount, part.cost))
	end

	spec.partfoot = 0
	spec.rvblightsTypesMask = 0
	
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

	spec.DontStopMotor = {}
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

	spec.DontStopMotor.battery	= false
	
	spec.updateTimer = 0
	
	spec.addDamage = {}
	spec.addDamage.alert = false

	spec.messageCenter:subscribe(MessageType.MINUTE_CHANGED, self.minuteChanged, self)
	spec.messageCenter:subscribe(MessageType.HOUR_CHANGED, self.RVBhourChanged, self)

	VehicleBreakdowns.FSSET_Daysperiod = g_currentMission.environment.plannedDaysPerPeriod
	VehicleBreakdowns.GSET_Change_difficulty = g_currentMission.vehicleBreakdowns.generalSettings.difficulty
	VehicleBreakdowns.GPSET_Change_thermostat = g_currentMission.vehicleBreakdowns.gameplaySettings.thermostatLifetime
	VehicleBreakdowns.GPSET_Change_lightings = g_currentMission.vehicleBreakdowns.gameplaySettings.lightingsLifetime
	VehicleBreakdowns.GPSET_Change_glowplug = g_currentMission.vehicleBreakdowns.gameplaySettings.glowplugLifetime
	VehicleBreakdowns.GPSET_Change_wipers = g_currentMission.vehicleBreakdowns.gameplaySettings.wipersLifetime
	VehicleBreakdowns.GPSET_Change_generator = g_currentMission.vehicleBreakdowns.gameplaySettings.generatorLifetime
	VehicleBreakdowns.GPSET_Change_engine = g_currentMission.vehicleBreakdowns.gameplaySettings.engineLifetime
	VehicleBreakdowns.GPSET_Change_selfstarter = g_currentMission.vehicleBreakdowns.gameplaySettings.selfstarterLifetime
	VehicleBreakdowns.GPSET_Change_battery = g_currentMission.vehicleBreakdowns.gameplaySettings.batteryLifetime
	VehicleBreakdowns.GPSET_Change_tire = g_currentMission.vehicleBreakdowns.gameplaySettings.tireLifetime

	--self.speedLimit = 10

	spec.dashboard_check = false
	spec.dashboard_check_ok = false
	spec.dashboard_check_updateDelta = 0
	spec.dashboard_check_updateRate = 2000

	spec.lights_request_A = false
	spec.lights_request_B = false

	spec.faultListText = {}


	spec.RVB_Battery = {}
	spec.RVB_BatteryFillLevel = 100.000000
	spec.updateBatteryTimer = 0
	
	spec.BatteryPlusMinus = {}
	spec.BatteryPlusMinus.lightings = 0
	
	spec.batteryFillUnitIndex = nil
	spec.isInitialized = true
	
	local specFillunit = self.spec_fillUnit
	local batteryFillUnitsCount = 0

	spec.batteryCHActive = false
	local batteryLevel = 100
	local spec_fillUnit = self.spec_fillUnit
	
	spec.updateDelta = 5001
	spec.updateRate = 5000


	if self.isServer then

		if savegame ~= nil and savegame.xmlFile:hasProperty(savegame.key..".fillUnit") then
            local i = 0
            local xmlFile = savegame.xmlFile
            while true do
                local key = string.format("%s.fillUnit.unit(%d)", savegame.key, i)
				
                if not xmlFile:hasProperty(key) then
                    break
                end

				local fillTypeName = xmlFile:getValue(key.."#fillType")
				if fillTypeName == "ELECTRICCHARGE" then
					local fillUnitIndex = xmlFile:getValue(key.."#index")
					local fillLevel = xmlFile:getValue(key.."#fillLevel", 100)
					batteryLevel = fillLevel
					spec.RVB_BatteryFillLevel = fillLevel
				end	

                i = i + 1
			end
		end
		
	end



	local spec_m = self.spec_motorized

	if spec_m.motor ~= nil then
	
	

		local specFillUnit = self.spec_fillUnit

	
		local xmlFillUnit = XMLFile.load("vehicleXml", Utils.getFilename("config/battery_fillUnit.xml", g_currentMission.vehicleBreakdowns.modDirectory), Vehicle.xmlSchema)

		local fillUnitConfigurationId = 1 --Utils.getNoNil(self.configurations.fillUnit, 1)

		local batteryKey = string.format("vehicle.fillUnit.fillUnitConfigurations.fillUnitConfiguration(%d).fillUnits.fillUnit(%d)", fillUnitConfigurationId-1, fillUnitConfigurationId-1)

		local entry = {}
		if self:loadFillUnitFromXML(xmlFillUnit, batteryKey, entry, #self.spec_fillUnit.fillUnits + 1) then
			entry.capacity = 100
			entry.startFillLevel = 100
		--	entry.fillLevel = batteryLevel
			entry.fillType = FillType.ELECTRICCHARGE

		-- ha ezt hasznalnam loadFillUnitFromXML, de meg nem tom mert dedin szarakodik vmi
			entry.allowFoldingThreshold = entry.capacity

			table.insert(self.spec_fillUnit.fillUnits, entry)

			
			spec.batteryFillUnitIndex = #self.spec_fillUnit.fillUnits
			
			--self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
			--self:raiseDirtyFlags(spec.dirtyFlag)

		else
			Logging.xmlWarning(xmlFillUnit, "Could not load fillUnit for '%s'", batteryKey)
			self:setLoadingState(VehicleLoadingUtil.VEHICLE_LOAD_ERROR)
		end

	else
		spec.isInitialized = false
	end
	
	

	if self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil then
		local specConsumers = self.spec_motorized
		if spec.batteryFillUnitIndex ~= nil and spec.isInitialized then
		
		
			local xmlFillUnit = XMLFile.load("vehicleXml", Utils.getFilename("config/battery_consumer.xml", g_currentMission.vehicleBreakdowns.modDirectory), Vehicle.xmlSchema)
			local unitindex = 1

			local vkey, motorId = ConfigurationUtil.getXMLConfigurationKey(self.xmlFile, self.configurations["motor"], "vehicle.motorized.motorConfigurations.motorConfiguration", "vehicle.motorized", "motor")
			local fallbackConfigKey = "vehicle.motorized.motorConfigurations.motorConfiguration(0)"
			local consumerConfigurationIndex = ConfigurationUtil.getConfigurationValue(self.xmlFile, vkey, "#consumerConfigurationIndex", "", 1, fallbackConfigKey)
			local key = string.format("vehicle.motorized.consumerConfigurations.consumerConfiguration(%d)", consumerConfigurationIndex-1)
			local consumerKey = string.format(".consumer(%d)", #specConsumers.consumers + 1)
			local consumer = {}
			consumer.fillUnitIndex = spec.batteryFillUnitIndex
			
			self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillType = FillType.ELECTRICCHARGE
			self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillLevel = spec.RVB_BatteryFillLevel -- batteryLevel
			--self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
			local fillTypeName = "electricCharge"
			consumer.fillType = g_fillTypeManager:getFillTypeIndexByName(fillTypeName)
			consumer.capacity = nil
			local fillUnit = self:getFillUnitByIndex(consumer.fillUnitIndex)
			if fillUnit ~= nil then
				if fillUnit.supportedFillTypes[consumer.fillType] ~= nil then

					fillUnit.capacity = consumer.capacity or fillUnit.capacity
					fillUnit.startFillLevel = fillUnit.capacity
					fillUnit.startFillTypeIndex = consumer.fillType

					local usage = 0.1
					consumer.permanentConsumption = false
					if consumer.permanentConsumption then
						consumer.usage = usage / (60*60*1000)
					else
						consumer.usage = usage
					end
					consumer.refillLitersPerSecond = 0
					consumer.refillCapacityPercentage = 0
					consumer.fillLevelToChange = 0.1
					table.insert(specConsumers.consumers, consumer)
					specConsumers.consumersByFillTypeName[fillTypeName:upper()] = consumer
					specConsumers.consumersByFillType[consumer.fillType] = consumer
					
			--self:raiseDirtyFlags(specConsumers.dirtyFlag)

				else
					Logging.xmlWarning(self.xmlFile, "FillUnit '%d' does not  support fillType '%s' for consumer '%s'", consumer.fillUnitIndex, fillTypeName, key..consumerKey)
				end
			else
				Logging.xmlWarning(self.xmlFile, "Unknown fillUnit '%d' for consumer '%s'", consumer.fillUnitIndex, key..consumerKey)
			end
		end
	end


	
	

	
	spec.rvb_actionEventToggleLights = 0
		
end

---Update
-- @param float dt time since last call in ms
function VehicleBreakdowns:PlaceableChargingStationonUpdate(superFunc, dt)
    local spec = self.spec_chargingStation

    if spec.loadTrigger ~= nil then
        local isActive = next(spec.loadTrigger.fillableObjects) ~= nil

        if spec.chargeIndicatorNode ~= nil then
            if isActive then
                local color = spec.chargeIndicatorColorEmpty
                local fillLevel, capacity = self:getChargeState()
                if fillLevel / capacity > 0.95 then
                    color = spec.chargeIndicatorColorFull
                end

                setShaderParameter(spec.chargeIndicatorNode, "colorScale", color[1], color[2], color[3], color[4], false)
                spec.chargeIndicatorLightColor = color
				
				if g_currentMission.controlledVehicle ~= nil then
					local rvb = g_currentMission.controlledVehicle.spec_faultData
					rvb.batteryCHActive = false
				end
				
            end

            local blinkSpeed = spec.loadTrigger.isLoading and spec.chargeIndicatorBlinkSpeed or 0
            setShaderParameter(spec.chargeIndicatorNode, "blinkSpeed", blinkSpeed, 0, 0, 0, false)
            setShaderParameter(spec.chargeIndicatorNode, "lightControl", isActive and spec.chargeIndicatorIntensity or 0, 0, 0, 0, false)

            if spec.chargeIndicatorLight ~= nil then
                local alpha = 0
                if isActive then
                    local x, y, z, _ = getShaderParameter(spec.chargeIndicatorNode, "blinkOffset")
                    alpha = MathUtil.clamp(math.cos(blinkSpeed * z * (getShaderTimeSec() - y) + 2 * math.pi * x) + 0.2, 0, 1)
                end

                setLightColor(spec.chargeIndicatorLight, spec.chargeIndicatorLightColor[1]*alpha, spec.chargeIndicatorLightColor[2]*alpha, spec.chargeIndicatorLightColor[3]*alpha)
            end
        end

        if spec.loadTrigger.isLoading then
            local allowDisplay = false
            if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
                local distance = calcDistanceFrom(g_currentMission.player.rootNode, self.rootNode)
                if distance < spec.interactionRadius then
                    allowDisplay = true
                end
            else
                if g_currentMission.controlledVehicle ~= nil then
                    for _, object in pairs(spec.loadTrigger.fillableObjects) do
                        if object.object == g_currentMission.controlledVehicle then
                            allowDisplay = true
                        end
                    end
                end
            end

            if allowDisplay then
                local fillLevel, capacity = self:getChargeState()
                local fillLevelToFill = capacity - fillLevel
                local literPerSecond = spec.loadTrigger.fillLitersPerMS * 1000
                local seconds = fillLevelToFill / literPerSecond
                if seconds >= 1 then
                    local minutes = math.floor(seconds / 60)
                    seconds = seconds - (minutes * 60)
					
					if g_currentMission.controlledVehicle ~= nil then
						local rvb = g_currentMission.controlledVehicle.spec_faultData
						rvb.batteryCHActive = true
					end
					-- motor es vilagitas leallitas 
					local index = next(spec.loadTrigger.fillableObjects)
					local vehicle = spec.loadTrigger.fillableObjects[index].object
					if vehicle.configurations["motor"] ~= nil then
						if vehicle:getIsMotorStarted() then
							vehicle:stopMotor()
						end
						if vehicle.deactivateLights ~= nil then
							vehicle:deactivateLights()
						end
						local spec_m = vehicle.spec_motorized
						if spec_m.motor ~= nil then
							spec_m.motor:setGearShiftMode(spec_m.gearShiftMode)
						end
					end
					-- motor es vilagitas leallitas END

                    g_currentMission:addExtraPrintText(string.format(g_i18n:getText("info_chargeTime"), minutes, seconds, fillLevel / capacity * 100))

                end
            end
        end
    end

    self:raiseActive()
end
PlaceableChargingStation.onUpdate = Utils.overwrittenFunction(PlaceableChargingStation.onUpdate, VehicleBreakdowns.PlaceableChargingStationonUpdate)

	
function VehicleBreakdowns:getBatteryFillUnitIndex()
    local spec = self.spec_fillUnit
    local batteryFillType = g_fillTypeManager:getFillTypeIndexByName("ELECTRICCHARGE")

    for fillUnitIndex, _ in ipairs(spec.fillUnits) do
        if self:getFillUnitAllowsFillType(fillUnitIndex, batteryFillType) then
            return fillUnitIndex
        end
    end
    return nil
end

function VehicleBreakdowns:minuteChanged()

	local spec = self.spec_faultData
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings
	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	
	local currentMinute = g_currentMission.environment.currentMinute
	
	if g_currentMission.environment.currentMinute ~= 0 then
		self:setVehicleService()
		--self:setBatteryCharging()
		self:setVehicleInspection()
	--	self:setVehicleRepair()
		self:setVehicleRepairDisplayMessage()
	end
	
	local spec_M = self.spec_motorized
    if spec_M.isMotorStarted then


		--self:setDamageService()
		--self:setGeneratorBatteryCharging()
		--self:setVehicleDamageThermostatoverHeatingFailure()
		
		--self:addDamage()
		
		--ha a generator meghibasodik lemerul az akkumulator
		self:setBatteryDrainingIfGeneratorFailure()

	
	else

	--	self:setBatteryDrain()
	
		
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
			--local damage = self:getDamageAmount()
			--self:setDamageAmount(damage - ((spec.repair[9] / (1 / spec.repair[6])) / 100), true)
			--self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			spec.repair[2] = true
		end
		
		if spec.inspection[1] then
			spec.inspection[2] = true
		end
		
		--if spec.battery[1] then
		--	self:setIsFaultBattery(self:getIsFaultBattery() - spec.battery[6])
		--	spec.battery[2] = true
		--end
		
		--if self.isServer then
		--elseif self.isClient then
			if spec.service[1] then
				RVBService_Event.sendEvent(self, unpack(spec.service))
			end
			if spec.repair[1] then
				RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			end
			if spec.inspection[1] then
				RVBInspection_Event.sendEvent(self, unpack(spec.inspection))
			end
			if spec.battery[1] then
				RVBBattery_Event.sendEvent(self, unpack(spec.battery))
				RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
			end
			--self:raiseDirtyFlags(spec.dirtyFlag)
			
		--end
	end
	
	if g_currentMission.environment.currentHour == GPSET.workshopOpen and g_currentMission.environment.currentMinute == 0 then
	
		if spec.service[1] then
			spec.service[2] = false
		end
		if spec.repair[1] then
			spec.repair[2] = false
		end
		if spec.inspection[1] then
			spec.inspection[2] = false
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
			if spec.inspection[1] then
				RVBInspection_Event.sendEvent(self, unpack(spec.inspection))
			end
			if spec.battery[1] then
				RVBBattery_Event.sendEvent(self, unpack(spec.battery))
			end
			--self:raiseDirtyFlags(spec.dirtyFlag)
		--end
		
	end

	if (g_currentMission.environment.currentHour > GPSET.workshopOpen and g_currentMission.environment.currentMinute == tonumber(0)) and (g_currentMission.environment.currentHour < GPSET.workshopClose and g_currentMission.environment.currentMinute == tonumber(0)) then
		--self:setBatteryCharging()
		self:setVehicleInspection()
	--	self:setVehicleRepair()
		self:setVehicleRepairDisplayMessage()
		self:setVehicleService()
	end
	
end

function VehicleBreakdowns:setDamageService(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local servicePeriodic = math.floor(spec.rvb[4])

	if servicePeriodic > RVBSET:getIsIsPeriodicService() and self.spec_motorized.isMotorStarted then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		spec.parts[5].operatingHours = spec.parts[5].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			--self:raiseDirtyFlags(spec.dirtyFlag)
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

function VehicleBreakdowns:setVehicleDamageThermostatoverHeatingFailure(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local _value = self.spec_motorized.motorTemperature.value
	--local _useF = g_gameSettings:getValue(GameSettings.SETTING.USE_FAHRENHEIT)
	--if _useF then _value = _value * 1.8 + 32 end
	local currentTemp = _value

	if spec.faultStorage[1] and tonumber(currentTemp) > 95 and self.spec_motorized.isMotorStarted then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			--self:raiseDirtyFlags(spec.dirtyFlag)
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

function VehicleBreakdowns:setVehicleDamageGlowplugFailure(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if self:getIsFaultGlowPlug() then

		local oneGameMinute = 60 * 1000 / 3600000
		-- PARTS operatingHours
		spec.parts[1].operatingHours = spec.parts[1].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		spec.parts[5].operatingHours = spec.parts[5].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		spec.parts[6].operatingHours = spec.parts[6].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000

		--if self.isServer then
		--elseif self.isClient then
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			--self:raiseDirtyFlags(spec.dirtyFlag)
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


function VehicleBreakdowns:deactivateLights(superFunc, keepHazardLightsOn)
    local spec = self.spec_lights

    self:setLightsTypesMask(0, true, true)
    self:setBeaconLightsVisibility(false, true, true)
    if not keepHazardLightsOn or spec.turnLightState ~= Lights.TURNLIGHT_HAZARD then
        self:setTurnLightState(Lights.TURNLIGHT_OFF, true, true)
    end
    self:setBrakeLightsVisibility(false)
    self:setReverseLightsVisibility(false)
    self:setInteriorLightsVisibility(false)

    spec.currentLightState = 0
end

function VehicleBreakdowns:setLightsTypesMask(superFunc, lightsTypesMask, force, noEventSend)
	local spec = self.spec_lights

	if self.isServer then
		lightsTypesMask = bitAND(lightsTypesMask, spec.maxLightStateMask)

		if spec.turnLightState == Lights.TURNLIGHT_LEFT then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightLeft)
		end

		if spec.turnLightState == Lights.TURNLIGHT_RIGHT then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightRight)
		end

		if spec.turnLightState == Lights.TURNLIGHT_HAZARD then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightAny)
		end

		if spec.brakeLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.brakeLight)
		end

		if spec.reverseLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.reverseLight)
		end

		if spec.interiorLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.interiorLight)
		end
		
	else
		--[[lightsTypesMask = bitXOR(lightsTypesMask, 2^spec.additionalLightTypes.interiorLight)

		if spec.interiorLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.interiorLight)
		end]]
		
		--lightsTypesMask = bitAND(lightsTypesMask, spec.maxLightStateMask)
		lightsTypesMask = bitXOR(lightsTypesMask, 2^spec.additionalLightTypes.interiorLight)

		if spec.turnLightState == Lights.TURNLIGHT_LEFT then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightLeft)
		end

		if spec.turnLightState == Lights.TURNLIGHT_RIGHT then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightRight)
		end

		if spec.turnLightState == Lights.TURNLIGHT_HAZARD then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.turnLightAny)
		end

		if spec.brakeLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.brakeLight)
		end

		if spec.reverseLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.reverseLight)
		end

		if spec.interiorLightsVisibility then
			lightsTypesMask = bitOR(lightsTypesMask, 2^spec.additionalLightTypes.interiorLight)
		end

	end

	if lightsTypesMask ~= spec.lightsTypesMask or force then
		if noEventSend == nil or noEventSend == false then
			if g_server ~= nil then
				g_server:broadcastEvent(VehicleSetLightEvent.new(self, lightsTypesMask, spec.totalNumLightTypes), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(VehicleSetLightEvent.new(self, lightsTypesMask, spec.totalNumLightTypes))
			end
		end

		if bitAND(lightsTypesMask, spec.maxLightStateMask) ~= bitAND(spec.lightsTypesMask, spec.maxLightStateMask) and self.isClient then
			g_soundManager:playSample(spec.samples.toggleLights)
		end

		local activeLightSetup = spec.realLights.low
		local inactiveLightSetup = spec.realLights.high

		if self:getUseHighProfile() then
			activeLightSetup = spec.realLights.high
			inactiveLightSetup = spec.realLights.low
		end

		self:setLightsState(inactiveLightSetup.realLights, false)
		self:setLightsState(activeLightSetup.realLights, lightsTypesMask)
		self:setLightsState(spec.staticLights, lightsTypesMask)

		spec.lightsTypesMask = lightsTypesMask

		
		SpecializationUtil.raiseEvent(self, "onLightsTypesMaskChanged", lightsTypesMask)
	end

	return true
end
Lights.setLightsTypesMask = Utils.overwrittenFunction(Lights.setLightsTypesMask, VehicleBreakdowns.setLightsTypesMask)

function VehicleBreakdowns:setBatteryDrain(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if not self.spec_motorized.isMotorStarted and not spec.parts[2].repairreq then

		if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.LIGHTS and self:getIsFaultBattery() >= VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then
			if self.deactivateLights ~= nil then
				self:deactivateLights()
			end
		end
		if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then
			if self.deactivateBeaconLights ~= nil then
				self:deactivateBeaconLights()
			end
		end

		local drainValue = 0
		local dischargeValue = 0

		if spec.rvblightsTypesMask > 0 then
			if self.spec_lights.currentLightState == 1 then
				if spec.rvblightsTypesMask == 9 then
					drainValue = 0.015
					dischargeValue = 8500
				end
				drainValue = 0.012--0.1
				dischargeValue = 9000
			elseif self.spec_lights.currentLightState == 2 then
				drainValue = 0.024
				dischargeValue = 7200
			elseif self.spec_lights.currentLightState == 3 then
				drainValue = 0.036
				dischargeValue = 5400
			elseif self.spec_lights.currentLightState == 4 then
				drainValue = 0.041
				dischargeValue = 3600
			elseif self.spec_lights.currentLightState == 9 then
				drainValue = 0.041
				dischargeValue = 3600
			else
				if spec.rvblightsTypesMask ~= 32 and spec.rvblightsTypesMask ~= 64 and spec.rvblightsTypesMask ~= 128 and spec.rvblightsTypesMask ~= 256 then
					drainValue = 0.03
					dischargeValue = 5800
				end
			end
	
		end

		if self.spec_lights.beaconLightsActive then
			drainValue = drainValue + 0.001
			dischargeValue = dischargeValue - 600
		end
		--if self.spec_lights.brakeLightsVisibility then
		--	drainValue = drainValue + 0.02
		--end
		
	
		if self.spec_lights.turnLightState ~= Lights.TURNLIGHT_OFF then
			if self.spec_lights.turnLightState == Lights.TURNLIGHT_LEFT or self.spec_lights.turnLightState == Lights.TURNLIGHT_RIGHT then
				drainValue = drainValue + 0.002
				dischargeValue = dischargeValue - 1200
			end
			if self.spec_lights.turnLightState == Lights.TURNLIGHT_HAZARD then
				drainValue = drainValue + 0.004
				dischargeValue = dischargeValue - 1400
			end
		end
		
		if drainValue > 0 then
			if spec.isInitialized then
				local batteryFillLevel = self:getFillUnitFillLevel(spec.batteryFillUnitIndex)
				if batteryFillLevel > 0 then
					
					local repairTime = dischargeValue * 1000

					local delta = dt * g_currentMission.missionInfo.timeScale / repairTime * 100

					self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, -delta, self:getFillUnitFillType(spec.batteryFillUnitIndex), ToolType.UNDEFINED)
			
				end
			end
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

	end
	
end

function VehicleBreakdowns:setBatteryDrainingIfGeneratorFailure()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	if self.spec_motorized.isMotorStarted and not self:getIsFaultLightings() then

		if self:getIsFaultGenerator() then

			local drainValue = 0

			if spec.rvblightsTypesMask > 0 then

				if self.spec_lights.currentLightState == 1 then
					--if self.spec_lights.lightsTypesMask == 9 then
					if spec.rvblightsTypesMask == 9 then
						drainValue = 0.15
					end
					drainValue = 0.1
				elseif self.spec_lights.currentLightState == 2 then
					drainValue = 0.2
				elseif self.spec_lights.currentLightState == 3 then
					drainValue = 0.3
				elseif self.spec_lights.currentLightState == 4 then
					drainValue = 0.35
				elseif self.spec_lights.currentLightState == 9 then
					drainValue = 0.35
				else
					if spec.rvblightsTypesMask ~= 32 and spec.rvblightsTypesMask ~= 64 and spec.rvblightsTypesMask ~= 128 and spec.rvblightsTypesMask ~= 256 then
						drainValue = 0.3
					end
				end
	
			end
			
			if self.spec_lights.beaconLightsActive then
				drainValue = drainValue + 0.01
			end
			--if self.spec_lights.brakeLightsVisibility then
			--	drainValue = drainValue + 0.02
			--end
		
			if self.spec_lights.turnLightState ~= Lights.TURNLIGHT_OFF then
				if self.spec_lights.turnLightState == Lights.TURNLIGHT_LEFT or self.spec_lights.turnLightState == Lights.TURNLIGHT_RIGHT then
					drainValue = drainValue + 0.02
				end
				if self.spec_lights.turnLightState == Lights.TURNLIGHT_HAZARD then
					drainValue = drainValue + 0.04
				end
			end

			if spec.isInitialized and self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil then
				local batteryFillLevel = self:getFillUnitFillLevel(spec.batteryFillUnitIndex)
				if batteryFillLevel > 0 then
					self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, -drainValue, self:getFillUnitFillType( spec.batteryFillUnitIndex), ToolType.UNDEFINED, nil)
				end
			end
		end
	end
	
end

function VehicleBreakdowns:setBatteryDrainingIfStartMotor()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns
	
	local drainValue = 2
	if self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.ELECTRICCHARGE) ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) == nil then
		drainValue = 1
	end


	if self:getIsFaultBattery() <= VehicleBreakdowns.SET.BatteryLevel.MOTOR or self:getIsFaultSelfStarter() then

		drainValue = 1
		
		if RVBSET:getIsAlertMessage() then
			--if self:displayMessage(currentMinute) == "0" or self:displayMessage(currentMinute) == "5" then
				if self.getIsEntered ~= nil and self:getIsEntered() then
					g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_BHlights"), 2500)
				else
				--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_fault_BHlights"), self:getFullName()), 2500)
				end
				if VehicleBreakdowns.Debug.Info then
					Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_fault_BHlights"), self:getFullName()))
				end
			--end
		end
		
	end

	if self:getIsFaultBattery() >= 0.03 then -- VehicleBreakdowns.SET.BatteryLevel.MOTOR then

		if self:getIsFaultGlowPlug() then
			drainValue = 1
		end
		if spec.isInitialized then
			local batteryFillLevel = self:getFillUnitFillLevel(spec.batteryFillUnitIndex)
			if batteryFillLevel > 0 then
				self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, -drainValue, self:getFillUnitFillType(spec.batteryFillUnitIndex), ToolType.UNDEFINED, nil)
				--print("addFillUnitFillLevel "..self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillLevel)
				--spec.RVB_BatteryFillLevel = self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillLevel
				--self:raiseDirtyFlags(spec.dirtyFlag)
			--	self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
			end
		end

	end

end

function VehicleBreakdowns:setBatteryCharging()

	local spec = self.spec_faultData
	
	if spec.battery[1] then

		self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, 100, self:getFillUnitFillType(spec.batteryFillUnitIndex), ToolType.UNDEFINED, nil)

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
			--self:requestActionEventUpdate()
		end
		
		local batterycosts = spec.battery[7]
		self:RVBaddRemoveMoney(-batterycosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
		spec.battery[7] = 0
		RVBBattery_Event.sendEvent(self, unpack(spec.battery))
		--self:raiseDirtyFlags(spec.dirtyFlag)

	end

end

function VehicleBreakdowns:rvbVehicleSetLifetime(fieldNum, fieldValue)
	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings
	
	for _, vehicle in ipairs(g_currentMission.vehicles) do
		if vehicle.spec_faultData ~= nil then
			for i=1, #vehicle.spec_faultData.parts do
				if i == fieldNum then
					vehicle.spec_faultData.parts[i].lifetime = fieldValue
					if GSET.difficulty == 1 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
					elseif GSET.difficulty == 2 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
					else
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
					end
				end
			end
			RVBParts_Event.sendEvent(vehicle, unpack(vehicle.spec_faultData.parts))
			--self:raiseDirtyFlags(vehicle.spec_faultData.dirtyFlag)
		end
	end

end

		
function VehicleBreakdowns:batteryChargeVehicle()

	local spec = self.spec_faultData
	self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, 100, self:getFillUnitFillType(spec.batteryFillUnitIndex), ToolType.UNDEFINED, nil)
	
	if self.isServer then
		g_currentMission:addMoney(-5, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR, true, true)
		local total = g_currentMission:farmStats(self:getOwnerFarmId()):updateStats("repairVehicleCount", 1)
        g_achievementManager:tryUnlock("VehicleRepairFirst", total)
        g_achievementManager:tryUnlock("VehicleRepair", total)
	end
end

function VehicleBreakdowns:setGeneratorBatteryCharging(dt)

	local spec = self.spec_faultData

	if not self:getIsFaultGenerator() and self.spec_motorized.isMotorStarted then
			
		if spec.isInitialized and self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil then
			local batteryFillLevel = self:getFillUnitFillLevel(spec.batteryFillUnitIndex)
			if batteryFillLevel < 100 then

				local Plusbattery = 0.02
				local delta = dt * g_currentMission.missionInfo.timeScale * Plusbattery / 1000

				self:addFillUnitFillLevel(self:getOwnerFarmId(), spec.batteryFillUnitIndex, delta, self:getFillUnitFillType(spec.batteryFillUnitIndex), ToolType.UNDEFINED, nil)
				--print("setGeneratorBatteryCharging "..self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillLevel)
				--spec.RVB_BatteryFillLevel = self.spec_fillUnit.fillUnits[spec.batteryFillUnitIndex].fillLevel
				--self:raiseDirtyFlags(spec.dirtyFlag)
		--		self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
	
			end
		end

	end

end

function VehicleBreakdowns:setVehicleInspection()

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute

	if spec.inspection[1] then

		if not spec.inspection[2] then
	
			if RVBSET:getIsAlertMessage() then
				if self:displayMessage(currentMinute) == "0" then
					if self.getIsEntered ~= nil and self:getIsEntered() then
						g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_alertmessage_inspection"), 2500)
					else
					--	g_currentMission.hud:addSideNotification(FSBaseMission.INGAME_NOTIFICATION_OK, string.format(g_i18n:getText("RVB_alertmessage_inspection_hud"), self:getFullName()), 2500)
					end
					if VehicleBreakdowns.Debug.Info then
						Logging.info("[RVB] "..string.format(g_i18n:getText("RVB_alertmessage_inspection_hud"), self:getFullName()))
					end
				end
			end

		end

		if currentDay == spec.inspection[3] and currentHour >= spec.inspection[4] and currentMinute >= spec.inspection[5] then

			spec.inspection[1] = false
			spec.inspection[2] = false
			spec.inspection[3] = 0
			spec.inspection[4] = 0
			spec.inspection[5] = 0

			local specm = self.spec_motorized
			specm.motorTemperature.value = self.temperatureDayText
			--specm.motorFan.enableTemperature = 95
			--specm.motorFan.disableTemperature = 85

			if self.isClient and self:getIsEntered() then
				--self:requestActionEventUpdate()
			end

			local thermostatRandom = false
			
			
			
			for i=1, #spec.parts do
				--local Partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
				
				if i == 2 or i == 4 then
					spec.partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
					if spec.partfoot >= 100 and not spec.parts[i].repairreq then
						if not spec.parts[i].repairreq then
							table.insert(spec.faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
						end
						spec.parts[i].repairreq = true
					end
				else
					spec.partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
					--if Partfoot >= 96 and not spec.parts[i].repairreq then
					if spec.partfoot > 95 and not spec.parts[i].repairreq then
						if i == 1 then
							thermostatRandom = true
						end
						if not spec.parts[i].repairreq then
							table.insert(spec.faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
						end
						spec.parts[i].repairreq = true
					end
				end
			
				--[[spec.partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
				--if Partfoot >= 96 then
				if spec.partfoot > 95 then
					if i == 1 then
						thermostatRandom = true
					end
					spec.parts[i].repairreq = true
					table.insert(spec.faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
				end]]
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
					--self:raiseDirtyFlags(spec.dirtyFlag)
				--end
				thermostatRandom = false
			end
		
			if table.maxn(spec.faultListText) > 0 then
				spec.inspection[8] = true
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText("RVB_inspectionDialogFault"), self:getFullName(), g_i18n:formatMoney(self:getRepairPrice_RVBClone(true))).."\n"..g_i18n:getText("RVB_ErrorList").."\n"..table.concat(spec.faultListText,", "),
					dialogType=DialogElement.TYPE_INFO
				})
			else
				
				local damage = self:getDamageAmount()
				local end_text = ""

				if damage >= 0.90 then

					--if self.isServer then

						g_currentMission:addMoney(-self:getRepairPrice(), self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR, true, true)
						local damage_repair = math.random(20,50)
											-- 0
						self:setDamageAmount(damage_repair, true)
					
					--end
					end_text = "RVB_inspectionDialogEnd_other"
					
				else
					end_text = "RVB_inspectionDialogEnd"
				end
				
				spec.inspection[8] = false
				g_gui:showInfoDialog({
					text     = string.format(g_i18n:getText(end_text), self:getFullName()),
					dialogType=DialogElement.TYPE_INFO,
					yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
				})
				
			end
			
			if self.isClient and self:getIsEntered() then
				self:requestActionEventUpdate()
			end
			
			local inspectioncosts = spec.inspection[6]
			self:RVBaddRemoveMoney(-inspectioncosts, self:getOwnerFarmId(), MoneyType.VEHICLE_REPAIR)
			spec.inspection[6] = 0
			RVBInspection_Event.sendEvent(self, unpack(spec.inspection))
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			--self:raiseDirtyFlags(spec.dirtyFlag)
			
			VehicleBreakdowns:DebugFaultPrint(spec.faultListText)

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

function VehicleBreakdowns:setVehicleRepairDisplayMessage()
	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentMinute = g_currentMission.environment.currentMinute

	if spec.repair[1] and spec.inspection[8] then

		if not spec.repair[2] then

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
	end
end
function VehicleBreakdowns:setVehicleRepair(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns

	local currentDay = g_currentMission.environment.currentDay
	local currentHour = g_currentMission.environment.currentHour
	local currentMinute = g_currentMission.environment.currentMinute

	if spec.repair[1] and spec.inspection[8] then

		if not spec.repair[2] then

			local repairTime = 0
			for i=1, #spec.parts do
				if spec.parts[i].repairreq then
					repairTime = repairTime + VehicleBreakdowns.IRSBTimes[i]
				end
			end
			repairTime = repairTime * 1000
			for i, value in pairs(spec.parts) do
				if value.repairreq then
					value.operatingHours = value.operatingHours - dt * g_currentMission.missionInfo.timeScale / repairTime * value.tmp_lifetime
					--RVBParts_Event.sendEvent(self, unpack(spec.parts))
					--self:raiseDirtyFlags(spec.dirtyFlag)
					self:raiseDirtyFlags(spec.dirtyFlag)
				end
			end

			
			--if self.isServer then
			--	self:raiseDirtyFlags(self.spec_wearable.dirtyFlag)
			--end

			--if self.isServer then
			--elseif self.isClient then
			--	RVBRepair_Event.sendEvent(self, unpack(spec.repair))
			--	self:raiseDirtyFlags(spec.dirtyFlag)
			--end



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
			
			spec.inspection[8] = false
			
			local specm = self.spec_motorized
			specm.motorTemperature.value = self.temperatureDayText
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
			RVBInspection_Event.sendEvent(self, unpack(spec.inspection))
			RVB_Event.sendEvent(self, unpack(spec.faultStorage))
			RVBParts_Event.sendEvent(self, unpack(spec.parts))
			--self:raiseDirtyFlags(spec.dirtyFlag)

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
			--self:raiseDirtyFlags(spec.dirtyFlag)

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
	local totaloperatinghours = savegame.xmlFile:getValue(rvbkey .. "#TotaloperatingHours", spec.rvb[3]) 
	spec.rvb[3] = math.max(Utils.getNoNil(totaloperatinghours, 0), 0)
	
	local periodic = savegame.xmlFile:getValue(rvbkey .. "#operatingHours", spec.rvb[4])
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
	
	local keyinspection = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.vehicleInspection")
	spec.inspection[1] = savegame.xmlFile:getValue(keyinspection .. "#state", false)
	spec.inspection[2] = savegame.xmlFile:getValue(keyinspection .. "#suspension", false)
	spec.inspection[3] = savegame.xmlFile:getValue(keyinspection .. "#finishday", 0)
	spec.inspection[4] = savegame.xmlFile:getValue(keyinspection .. "#finishhour", 0)
	spec.inspection[5] = savegame.xmlFile:getValue(keyinspection .. "#finishminute", 0)
	spec.inspection[6] = savegame.xmlFile:getValue(keyinspection .. "#cost", 0)
	spec.inspection[7] = savegame.xmlFile:getValue(keyinspection .. "#factor", 0)
	spec.inspection[8] = savegame.xmlFile:getValue(keyinspection .. "#inspection", false)

	local keybattery = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns.vehicleBattery")
	spec.battery[1] = savegame.xmlFile:getValue(keybattery .. "#state", false)
	spec.battery[2] = savegame.xmlFile:getValue(keybattery .. "#suspension", false)
	spec.battery[3] = savegame.xmlFile:getValue(keybattery .. "#finishday", 0)
	spec.battery[4] = savegame.xmlFile:getValue(keybattery .. "#finishhour", 0)
	spec.battery[5] = savegame.xmlFile:getValue(keybattery .. "#finishminute", 0)
	spec.battery[6] = savegame.xmlFile:getValue(keybattery .. "#amount", 0)
	spec.battery[7] = savegame.xmlFile:getValue(keybattery .. "#cost", 0)

	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	local keyparts = string.format("%s.%s.%s", savegame.key, g_vehicleBreakdownsModName, "vehicleBreakdowns")
	
	for i=1, #spec.parts do
		local keyss = string.format("%s.parts.part(%d)", keyparts, i)
		spec.parts[i].name = savegame.xmlFile:getValue(keyss .. "#name", spec.parts[i].name)
		spec.parts[i].lifetime = savegame.xmlFile:getValue(keyss .. "#lifetime", spec.parts[i].lifetime)
		if GSET.difficulty == 1 then
			spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
		elseif GSET.difficulty == 2 then
			spec.parts[i].tmp_lifetime = spec.parts[i].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
		else
			spec.parts[i].tmp_lifetime = spec.parts[i].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
		end
		spec.parts[i].operatingHours = savegame.xmlFile:getValue(keyss .. "#operatingHours", spec.parts[i].operatingHours)
		spec.parts[i].repairreq = savegame.xmlFile:getValue(keyss .. "#repairreq", spec.parts[i].repairreq)
		spec.parts[i].amount = savegame.xmlFile:getValue(keyss .. "#amount", spec.parts[i].amount)
		spec.parts[i].cost = savegame.xmlFile:getValue(keyss .. "#cost", spec.parts[i].cost)
	end


	local i = 0
	local xmlFile = savegame.xmlFile
	while true do
		local key = string.format("%s.fillUnit.unit(%d)", savegame.key, i)
		if not xmlFile:hasProperty(key) then
			break
		end

		local fillTypeName = xmlFile:getValue(key.."#fillType")
		if fillTypeName == "ELECTRICCHARGE" then
			local fillUnitIndex = xmlFile:getValue(key.."#index")
			local fillLevel = xmlFile:getValue(key.."#fillLevel", 100)
			self.spec_fillUnit.fillUnits[fillUnitIndex].fillLevel = fillLevel
			spec.RVB_BatteryFillLevel = fillLevel
			--self:raiseDirtyFlags(spec.dirtyFlag)
		end	

		i = i + 1
	end

	if self.isServer then
		--self:raiseDirtyFlags(spec.dirtyFlag)
	elseif self.isClient then
		spec.rvb = { unpack(spec.rvb) }
		spec.faultStorage = { unpack(spec.faultStorage) }
		spec.parts = { unpack(spec.parts) }
		spec.service = { unpack(spec.service) }
		spec.repair = { unpack(spec.repair) }
		spec.inspection = { unpack(spec.inspection) }
		spec.battery = { unpack(spec.battery) }
	end

end

function VehicleBreakdowns.SyncClientServer_Other(vehicle, batteryCHActive)
	local spec = vehicle.spec_faultData
	spec.batteryCHActive = batteryCHActive
end

function VehicleBreakdowns.SyncClientServer_RVB(vehicle, b1, b2, b3, b4, b5)
	local spec = vehicle.spec_faultData
	spec.rvb = spec.rvb or {}
	spec.rvb[1] = b1
    spec.rvb[2] = b2
	spec.rvb[3] = b3
	spec.rvb[4] = b4
	spec.rvb[5] = b5
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű rvb adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBFaultStorage(vehicle, b1, b2)
	local spec = vehicle.spec_faultData
	spec.faultStorage = spec.faultStorage or {}
	spec.faultStorage[1] = b1
    spec.faultStorage[2] = b2
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű faultStorage adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBService(vehicle, b1, b2, b3, b4, b5, b6, b7, b8)
	local spec = vehicle.spec_faultData
	spec.service = spec.service or {}
	spec.service[1] = b1
    spec.service[2] = b2
	spec.service[3] = b3
	spec.service[4] = b4
	spec.service[5] = b5
	spec.service[6] = b6
	spec.service[7] = b7
	spec.service[8] = b8
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű service adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBRepair(vehicle, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10)
	local spec = vehicle.spec_faultData
	spec.repair = spec.repair or {}
	spec.repair[1] = b1
    spec.repair[2] = b2
	spec.repair[3] = b3
	spec.repair[4] = b4
	spec.repair[5] = b5
	spec.repair[6] = b6
	spec.repair[7] = b7
	spec.repair[8] = b8
	spec.repair[9] = b9
	spec.repair[10] = b10
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű repair adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBInspection(vehicle, b1, b2, b3, b4, b5, b6, b7, b8)
	local spec = vehicle.spec_faultData
	spec.inspection = spec.inspection or {}
	spec.inspection[1] = b1
    spec.inspection[2] = b2
	spec.inspection[3] = b3
	spec.inspection[4] = b4
	spec.inspection[5] = b5
	spec.inspection[6] = b6
	spec.inspection[7] = b7
	spec.inspection[8] = b8
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű inspection adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBBattery(vehicle, b1, b2, b3, b4, b5, b6, b7)
    local spec = vehicle.spec_faultData
    spec.battery = spec.battery or {}
    spec.battery[1] = b1
    spec.battery[2] = b2
    spec.battery[3] = b3
    spec.battery[4] = b4
    spec.battery[5] = b5
    spec.battery[6] = b6
    spec.battery[7] = b7
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
    -- Ha a jármű szinkronizálva van, akkor végezhetünk el további frissítéseket
    if vehicle:getIsSynchronized() then
        --print("A jármű akkumulátor adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_RVBParts(vehicle, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12)
	local spec = vehicle.spec_faultData
	spec.parts = spec.parts or {}
	spec.parts[1] = b1
    spec.parts[2] = b2
	spec.parts[3] = b3
	spec.parts[4] = b4
	spec.parts[5] = b5
	spec.parts[6] = b6
	spec.parts[7] = b7
	spec.parts[8] = b8
	spec.parts[9] = b9
	spec.parts[10] = b10
	spec.parts[11] = b11
	spec.parts[12] = b12
	
	vehicle:raiseDirtyFlags(spec.dirtyFlag)
	if vehicle:getIsSynchronized() then
        --print("A jármű parts adatainak frissítése sikeres.")
    end
end

function VehicleBreakdowns.SyncClientServer_BatteryChargeLevel(vehicle, level)
	local spec = vehicle.spec_faultData
	spec.RVB_BatteryFillLevel = level
end

function VehicleBreakdowns:onReadStream(streamId, connection)

	if self.spec_faultData == nil then
		return
	end

	local spec = self.spec_faultData
	
	spec.rvb = {
		streamReadInt16(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId)
	}

	spec.faultStorage = {
		streamReadBool(streamId),
		streamReadBool(streamId)
	}

	spec.service = {
		streamReadBool(streamId),
		streamReadBool(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId)
	}

	spec.repair = {
		streamReadBool(streamId),
		streamReadBool(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadBool(streamId)
	}

	spec.inspection = {
		streamReadBool(streamId),
		streamReadBool(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId),
		streamReadBool(streamId)
	}

	spec.battery = {
		streamReadBool(streamId),
		streamReadBool(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadInt16(streamId),
		streamReadFloat32(streamId),
		streamReadFloat32(streamId)
	}

	for i = 1, #spec.parts do
		spec.parts[i] = {
			name = streamReadString(streamId),
			lifetime = streamReadInt16(streamId),
			tmp_lifetime = streamReadInt16(streamId),
			operatingHours = streamReadFloat32(streamId),
			repairreq = streamReadBool(streamId),
			amount = streamReadFloat32(streamId),
			cost = streamReadFloat32(streamId)
		}
	end

	spec.motorTemperature = streamReadFloat32(streamId)
	spec.fanEnabled = streamReadBool(streamId)

	spec.fanEnableTemperature = streamReadFloat32(streamId)
	spec.fanDisableTemperature = streamReadFloat32(streamId)
	spec.lastFuelUsage = streamReadFloat32(streamId)
	spec.lastDefUsage = streamReadFloat32(streamId)
	spec.lastAirUsage = streamReadFloat32(streamId)

	spec.RVB_BatteryFillLevel = streamReadFloat32(streamId)
	spec.batteryFillUnitIndex = streamReadInt16(streamId)
	spec.batteryCHActive = streamReadBool(streamId)

	VehicleBreakdowns.FSSET_Daysperiod = streamReadInt16(streamId)
	VehicleBreakdowns.GSET_Change_difficulty = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_thermostat = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_lightings = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_glowplug = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_wipers = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_generator = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_engine = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_selfstarter = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_battery = streamReadInt16(streamId)
	VehicleBreakdowns.GPSET_Change_tire = streamReadInt16(streamId)

	local lights_request_A = streamReadBool(streamId)
	local lights_request_B = streamReadBool(streamId)
	self:setRVBLightsStrings(lights_request_A, lights_request_B, true, true)
	
	local lightsTypesMask = streamReadInt16(streamId)
	self:setRVBLightsTypesMask(lightsTypesMask, true, true)

	local isRVBMotorStarted = streamReadBool(streamId)
	if isRVBMotorStarted then
		self:startMotor(true)
	else
		self:stopMotor(true)
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
	
	streamWriteFloat32(streamId, spec.rvb[4])
	streamWriteFloat32(streamId, spec.rvb[5])
	
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
	
	streamWriteBool(streamId, spec.inspection[1])
	streamWriteBool(streamId, spec.inspection[2])
	streamWriteInt16(streamId, spec.inspection[3])
	streamWriteInt16(streamId, spec.inspection[4])
	streamWriteInt16(streamId, spec.inspection[5])
	streamWriteFloat32(streamId, spec.inspection[6])
	streamWriteFloat32(streamId, spec.inspection[7])
	streamWriteBool(streamId, spec.inspection[8])

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

	streamWriteFloat32(streamId, spec.RVB_BatteryFillLevel)
	streamWriteInt16(streamId, spec.batteryFillUnitIndex)
	streamWriteBool(streamId, spec.batteryCHActive)
	
	streamWriteInt16(streamId, VehicleBreakdowns.FSSET_Daysperiod)
	streamWriteInt16(streamId, VehicleBreakdowns.GSET_Change_difficulty)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_thermostat)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_lightings)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_glowplug)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_wipers)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_generator)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_engine)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_selfstarter)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_battery)
	streamWriteInt16(streamId, VehicleBreakdowns.GPSET_Change_tire)
	
	streamWriteBool(streamId, spec.lights_request_A)
	streamWriteBool(streamId, spec.lights_request_B)
	
	streamWriteInt16(streamId, spec.rvblightsTypesMask)

	streamWriteBool(streamId, spec.isRVBMotorStarted)
	
end

function VehicleBreakdowns:onReadUpdateStream(streamId, timestamp, connection)

	if connection.isServer then

		local spec = self.spec_faultData
		
		if streamReadBool(streamId) then

			spec.rvb = {
				streamReadInt16(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId)
			}

			spec.faultStorage = {
				streamReadBool(streamId),
				streamReadBool(streamId)
			}

			spec.service = {
				streamReadBool(streamId),
				streamReadBool(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId)
			}

			spec.repair = {
				streamReadBool(streamId),
				streamReadBool(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadBool(streamId)
			}

			spec.inspection = {
				streamReadBool(streamId),
				streamReadBool(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId),
				streamReadBool(streamId)
			}

			spec.battery = {
				streamReadBool(streamId),
				streamReadBool(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadInt16(streamId),
				streamReadFloat32(streamId),
				streamReadFloat32(streamId)
			}

			for i = 1, #spec.parts do
				spec.parts[i] = {
					name = streamReadString(streamId),
					lifetime = streamReadInt16(streamId),
					tmp_lifetime = streamReadInt16(streamId),
					operatingHours = streamReadFloat32(streamId),
					repairreq = streamReadBool(streamId),
					amount = streamReadFloat32(streamId),
				cost = streamReadFloat32(streamId)
				}
			end

			spec.motorTemperature = streamReadFloat32(streamId)
			spec.fanEnabled = streamReadBool(streamId)
			spec.fanEnableTemperature = streamReadFloat32(streamId)
			spec.fanDisableTemperature = streamReadFloat32(streamId)
			spec.lastFuelUsage = streamReadFloat32(streamId)
			spec.lastDefUsage = streamReadFloat32(streamId)
			spec.lastAirUsage = streamReadFloat32(streamId)
			
			spec.RVB_BatteryFillLevel = streamReadFloat32(streamId)
			spec.batteryFillUnitIndex = streamReadInt16(streamId)
			spec.batteryCHActive = streamReadBool(streamId)

		end
	end
end

function VehicleBreakdowns:onWriteUpdateStream(streamId, connection, dirtyMask)

	if not connection.isServer then

		local spec = self.spec_faultData
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then

			streamWriteInt16(streamId, spec.rvb[1])
			streamWriteFloat32(streamId, spec.rvb[2])
			streamWriteFloat32(streamId, spec.rvb[3])
			
			streamWriteFloat32(streamId, spec.rvb[4])
			streamWriteFloat32(streamId, spec.rvb[5])

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
			
			streamWriteBool(streamId, spec.inspection[1])
			streamWriteBool(streamId, spec.inspection[2])
			streamWriteInt16(streamId, spec.inspection[3])
			streamWriteInt16(streamId, spec.inspection[4])
			streamWriteInt16(streamId, spec.inspection[5])
			streamWriteFloat32(streamId, spec.inspection[6])
			streamWriteFloat32(streamId, spec.inspection[7])
			streamWriteBool(streamId, spec.inspection[8])

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

			streamWriteFloat32(streamId, spec.RVB_BatteryFillLevel)
			streamWriteInt16(streamId, spec.batteryFillUnitIndex)
			streamWriteBool(streamId, spec.batteryCHActive)

		end
	end

end


function VehicleBreakdowns:saveToXMLFile(xmlFile, key, usedModNames)
	local spec = self.spec_faultData
	
	xmlFile:setValue(key .. "#timeScale", spec.rvb[1])
	xmlFile:setValue(key .. "#operatingHoursTemp", self:getIsOperatingHoursTemp() / 1000)
	xmlFile:setValue(key .. "#TotaloperatingHours", spec.rvb[3])
	
	xmlFile:setValue(key .. "#operatingHours", spec.rvb[4])
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
	
	xmlFile:setValue(key .. ".vehicleInspection#state", spec.inspection[1])
	xmlFile:setValue(key .. ".vehicleInspection#suspension", spec.inspection[2])
	xmlFile:setValue(key .. ".vehicleInspection#finishday", spec.inspection[3])
	xmlFile:setValue(key .. ".vehicleInspection#finishhour", spec.inspection[4])
	xmlFile:setValue(key .. ".vehicleInspection#finishminute", spec.inspection[5])
	xmlFile:setValue(key .. ".vehicleInspection#cost", spec.inspection[6])
	xmlFile:setValue(key .. ".vehicleInspection#factor", spec.inspection[7])
	xmlFile:setValue(key .. ".vehicleInspection#inspection", spec.inspection[8])
	
	xmlFile:setValue(key .. ".vehicleBattery#state", spec.battery[1])
	xmlFile:setValue(key .. ".vehicleBattery#suspension", spec.battery[2])
	xmlFile:setValue(key .. ".vehicleBattery#finishday", spec.battery[3])
	xmlFile:setValue(key .. ".vehicleBattery#finishhour", spec.battery[4])
	xmlFile:setValue(key .. ".vehicleBattery#finishminute", spec.battery[5])
	xmlFile:setValue(key .. ".vehicleBattery#amount", spec.battery[6])
	xmlFile:setValue(key .. ".vehicleBattery#cost", spec.battery[7])

	for i=1, #spec.parts do
		if spec.parts[i].name ~= nil and spec.parts[i].name ~= "" then
			local keyss = string.format("%s.parts.part(%d)", key, i)
			xmlFile:setValue(keyss.."#name", spec.parts[i].name)
			xmlFile:setValue(keyss.."#lifetime", spec.parts[i].lifetime)
			xmlFile:setValue(keyss.."#operatingHours", spec.parts[i].operatingHours)
			xmlFile:setValue(keyss.."#repairreq", spec.parts[i].repairreq)
			xmlFile:setValue(keyss.."#amount", spec.parts[i].amount)
			xmlFile:setValue(keyss.."#cost", spec.parts[i].cost)
		end
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
			
			local rvbToggleBeaconLights = Lights.actionEventToggleBeaconLights
			local rvbToggleTurnLightHazard = Lights.actionEventToggleTurnLightHazard
			local rvbToggleTurnLightLeft = Lights.actionEventToggleTurnLightLeft
			local rvbToggleTurnLightRight = Lights.actionEventToggleTurnLightRight
			
			if self:getIsFaultLightings() or self:getIsFaultBattery() ~= 0 and self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.LIGHTS then
				rvbToggleLights = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleLightsBack = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleLightFront = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleWorkLightBack = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleWorkLightFront = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleHighBeamLight = VehicleBreakdowns.actionToggleLightsFault
			end
			
			if self:getIsFaultLightings() or self:getIsFaultBattery() ~= 0 and self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then
				rvbToggleBeaconLights = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleTurnLightHazard = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleTurnLightLeft = VehicleBreakdowns.actionToggleLightsFault
				rvbToggleTurnLightRight = VehicleBreakdowns.actionToggleLightsFault
			end

			if isActiveForInputIgnoreSelection then

				local _
					_, spec.actionEventIdLight = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHTS, self, rvbToggleLights, false, true, false, true, nil)
				local _, actionEventIdReverse = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHTS_BACK, self, rvbToggleLightsBack, false, true, false, true, nil)
				local _, actionEventIdFront = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_LIGHT_FRONT, self, rvbToggleLightFront, false, true, false, true, nil)
				local _, actionEventIdWorkBack = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_WORK_LIGHT_BACK, self, rvbToggleWorkLightBack, false, true, false, true, nil)
				local _, actionEventIdWorkFront = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_WORK_LIGHT_FRONT, self, rvbToggleWorkLightFront, false, true, false, true, nil)
				local _, actionEventIdHighBeam = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_HIGH_BEAM_LIGHT, self, rvbToggleHighBeamLight, false, true, false, true, nil)

				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_HAZARD, self, rvbToggleTurnLightHazard, false, true, false, true, nil)
				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_LEFT, self, rvbToggleTurnLightLeft, false, true, false, true, nil)
				self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_TURNLIGHT_RIGHT, self, rvbToggleTurnLightRight, false, true, false, true, nil)
				local _, actionEventIdBeacon = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_BEACON_LIGHTS, self, rvbToggleBeaconLights, false, true, false, true, nil)

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

	if self:getIsFaultLightings() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.LIGHTS then

		local GSET = g_currentMission.vehicleBreakdowns.generalSettings

		if GSET.alertmessage then
			if self.getIsEntered ~= nil and self:getIsEntered() then
				g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_lights"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_lights_hud"), self:getFullName()), 5000)
			end
		end

	end
	
	if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then

		local GSET = g_currentMission.vehicleBreakdowns.generalSettings

		if GSET.alertmessage then
			if self.getIsEntered ~= nil and self:getIsEntered() then
				g_currentMission:showBlinkingWarning(g_i18n:getText("RVB_fault_BHlights"), 2500)
			else
			--	g_currentMission.hud:addSideNotification(VehicleBreakdowns.INGAME_NOTIFICATION, string.format(g_i18n:getText("RVB_fault_BHlights_hud"), self:getFullName()), 5000)
			end
		end

	end

end

function VehicleBreakdowns:lightingsFault()

	local spec = self.spec_faultData

	if self:getIsFaultLightings() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.LIGHTS then
		self:setLightsTypesMask(0, true, true)
	end
	
	if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then
		self:setBeaconLightsVisibility(false, true, true)
		self:setTurnLightState(Lights.TURNLIGHT_OFF, true, true)
	end

end

function VehicleBreakdowns:StopAI(self)
    local rootVehicle = self.rootVehicle
    if rootVehicle ~= nil and rootVehicle:getIsAIActive() then
        rootVehicle:stopCurrentAIJob(AIMessageErrorVehicleBroken.new())
    end
end

function VehicleBreakdowns:inRangeOfchargingStation(chargingStation, vehicle, vehicleFarm)

	for rootNode, _ in pairs(chargingStation) do
		if rootNode ~= nil then
			local distanceToStation = calcDistanceFrom(vehicle, rootNode)
			if distanceToStation <= 6 then
				return true
			end
		end
	end

end

function VehicleBreakdowns:updatePartsLifetime(partsName, partsLifetime)
	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	for _, vehicle in ipairs(g_currentMission.vehicles) do
		if vehicle.spec_faultData ~= nil then
			for i=1, #vehicle.spec_faultData.parts do
				if string.match(vehicle.spec_faultData.parts[i].name, partsName) then
					vehicle.spec_faultData.parts[i].lifetime = partsLifetime
					if GSET.difficulty == 1 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
					elseif GSET.difficulty == 2 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
					else
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
					end
				end
			end
			RVBParts_Event.sendEvent(vehicle, unpack(vehicle.spec_faultData.parts))
			--vehicle:raiseDirtyFlags(vehicle.spec_faultData.dirtyFlag)
		end
	end
end

--[[
Növelje az ablaktörlő üzemidejét
Amikor a motor jár
Ha az ablaktörlő működik és esik az eső
Increase wiper operating hours
When the engine is running
If the wiper is working and it is raining
]]
function VehicleBreakdowns:setWiperOperatingHours(dt)
	local spec = self.spec_faultData
	local lastRainScale = g_currentMission.environment.weather:getRainFallScale()
	if self:getIsActiveForWipers() and lastRainScale > 0.01 then
		spec.parts[4].operatingHours = spec.parts[4].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		RVBParts_Event.sendEvent(self, unpack(spec.parts))
		--self:raiseDirtyFlags(spec.dirtyFlag)
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
function VehicleBreakdowns:setLightingsOperatingHours(dt)
	local spec = self.spec_faultData
	if spec.rvblightsTypesMask > 0 and not spec.parts[2].repairreq and not spec.parts[8].repairreq and self:getIsFaultBattery() >= VehicleBreakdowns.SET.BatteryLevel.LIGHTS then
		spec.parts[2].operatingHours = spec.parts[2].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
		if spec.parts[2].operatingHours > spec.parts[2].tmp_lifetime then
			spec.parts[2].operatingHours = spec.parts[2].tmp_lifetime
		end
		RVBParts_Event.sendEvent(self, unpack(spec.parts))
		--self:raiseDirtyFlags(spec.dirtyFlag)
	end

end

function VehicleBreakdowns:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)

	local spec = self.spec_faultData
	local motorized = self.spec_motorized




	if not self:getIsEntered() then
		self:raiseActive()
	end
	
	

	
	self:setVehicleRepair(dt)
	
	-- isActiveForInputIgnoreSelection
	if motorized.isMotorStarted then
	
		self:onStartOperatingHours(dt)
		self:setDamageService(dt)
		self:setGeneratorBatteryCharging(dt)
		self:setVehicleDamageThermostatoverHeatingFailure(dt)
		--ha a generator meghibasodik lemerul az akkumulator
		--self:setBatteryDrainingIfGeneratorFailure(dt)
 
		self:setWiperOperatingHours(dt)
		

	else

		self:setBatteryDrain(dt)

	
		--[[
			Motor hűtőfolyadék hőmérséklet csökkentése
			Ha a motor nem jár
			Ha még nem érte el az időjárásnak megfelelő hőmérsékletet
			~minden percben ~0.35 fokkal csökken
		]]

		if self.spec_motorized.motorTemperature.value > self.temperatureDayText then
			
			local engineTemp = 3600 * 1000

			self.spec_motorized.motorTemperature.value = self.spec_motorized.motorTemperature.value - dt * g_currentMission.missionInfo.timeScale / engineTemp * self.temperatureDayText
			
			
			--local engineTemp = dt * g_currentMission.missionInfo.timeScale * 0.0035 / 1000		
			--self.spec_motorized.motorTemperature.value = self.spec_motorized.motorTemperature.value - engineTemp

		end
		
		
		
	end

	self:setLightingsOperatingHours(dt)	
		
	--self:setBatteryCharging()
	



	
	
	
	local engine_percent = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
	if self:getIsFaultSelfStarter() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.MOTOR or engine_percent >= 99 then
	
		if g_modIsLoaded["FS22_AutoDrive"] then
			if FS22_AutoDrive ~= nil then
				if self.ad.stateModule:isActive() then
					self:stopAutoDrive(self)
					--self:updateVehiclePhysics(0, 0, 0, 16)
					self:stopVehicle()
					FS22_AutoDrive.AutoDriveMessageEvent.sendNotification(self, FS22_AutoDrive.ADMessagesManager.messageTypes.INFO, g_i18n:getText("RVB_aimessage_batterydischarged"), 8000, self:getFullName())
				end
			end
		end
		
		if g_modIsLoaded["FS22_Courseplay"] then
			if FS22_Courseplay ~= nil then
				if self:getIsCpActive() then
					if self.getIsAIActive and self:getIsAIActive() then
						self:stopCurrentAIJob(AIMessageErrorBatteryDischarged.new())
						self:stopVehicle()
					end
				end
			end
		end

	end
	
	if self.isServer then
		if spec.rvblightsTypesMask ~= self.spec_lights.lightsTypesMask then
			lightsTypesMask = self.spec_lights.lightsTypesMask
			if self.spec_lights.lightsTypesMask >= 512 then
				lightsTypesMask = self.spec_lights.lightsTypesMask - 512
			end
			self:setRVBLightsTypesMask(lightsTypesMask)
		end
	end

	if self:getIsEntered() then
		if self:getIsFaultLightings() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.LIGHTS then
			if not spec.lights_request_A then
				self:setRVBLightsStrings(true, spec.lights_request_B)
				self:requestActionEventUpdate()
			end
		else
			if spec.lights_request_A then
				self:setRVBLightsStrings(false, spec.lights_request_B)
				self:requestActionEventUpdate()
			end
		end

		if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.BeaconLIGHTS then
			if not spec.lights_request_B then
				self:setRVBLightsStrings(spec.lights_request_A, true)
				self:requestActionEventUpdate()
			end
		else
			if spec.lights_request_B then
				self:setRVBLightsStrings(spec.lights_request_A, false)
				self:requestActionEventUpdate()
			end
		end
	end
	

	local GSET = g_currentMission.vehicleBreakdowns.generalSettings
	local GPSET = g_currentMission.vehicleBreakdowns.gameplaySettings	
	
	if VehicleBreakdowns.GPSET_Change_thermostat ~= GPSET.thermostatLifetime then
		local thermostat = rvb_Utils.removeLifetimeText("thermostatLifetime")
		self:updatePartsLifetime(thermostat, GPSET.thermostatLifetime)
		VehicleBreakdowns.GPSET_Change_thermostat = GPSET.thermostatLifetime
	end

	if VehicleBreakdowns.GPSET_Change_lightings ~= GPSET.lightingsLifetime then
		local lightings = rvb_Utils.removeLifetimeText("lightingsLifetime")
		self:updatePartsLifetime(lightings, GPSET.lightingsLifetime)
		VehicleBreakdowns.GPSET_Change_lightings = GPSET.lightingsLifetime
	end

	if VehicleBreakdowns.GPSET_Change_glowplug ~= GPSET.glowplugLifetime then
		local glowplug = rvb_Utils.removeLifetimeText("glowplugLifetime")
		self:updatePartsLifetime(glowplug, GPSET.glowplugLifetime)
		VehicleBreakdowns.GPSET_Change_glowplug = GPSET.glowplugLifetime
	end

	if VehicleBreakdowns.GPSET_Change_wipers ~= GPSET.wipersLifetime then
		local wipers = rvb_Utils.removeLifetimeText("wipersLifetime")
		self:updatePartsLifetime(wipers, GPSET.wipersLifetime)
		VehicleBreakdowns.GPSET_Change_wipers = GPSET.wipersLifetime
	end

	if VehicleBreakdowns.GPSET_Change_generator ~= GPSET.generatorLifetime then
		local generator = rvb_Utils.removeLifetimeText("generatorLifetime")
		self:updatePartsLifetime(generator, GPSET.generatorLifetime)
		VehicleBreakdowns.GPSET_Change_generator = GPSET.generatorLifetime
	end

	if VehicleBreakdowns.GPSET_Change_engine ~= GPSET.engineLifetime then
		local engine = rvb_Utils.removeLifetimeText("engineLifetime")
		self:updatePartsLifetime(engine, GPSET.engineLifetime)
		VehicleBreakdowns.GPSET_Change_engine = GPSET.engineLifetime
	end

	if VehicleBreakdowns.GPSET_Change_selfstarter ~= GPSET.selfstarterLifetime then
		local selfstarter = rvb_Utils.removeLifetimeText("selfstarterLifetime")
		self:updatePartsLifetime(selfstarter, GPSET.selfstarterLifetime)
		VehicleBreakdowns.GPSET_Change_selfstarter = GPSET.selfstarterLifetime
	end

	if VehicleBreakdowns.GPSET_Change_battery ~= GPSET.batteryLifetime then
		local battery = rvb_Utils.removeLifetimeText("batteryLifetime")
		self:updatePartsLifetime(battery, GPSET.batteryLifetime)
		VehicleBreakdowns.GPSET_Change_battery = GPSET.batteryLifetime
	end

	if VehicleBreakdowns.GPSET_Change_tire ~= GPSET.tireLifetime then
		local tire = rvb_Utils.removeLifetimeText("tireLifetime")
		self:updatePartsLifetime(tire, GPSET.tireLifetime)
		VehicleBreakdowns.GPSET_Change_tire = GPSET.tireLifetime
	end

	if VehicleBreakdowns.FSSET_Daysperiod ~= g_currentMission.environment.plannedDaysPerPeriod or VehicleBreakdowns.GSET_Change_difficulty ~= GSET.difficulty then
		for _, vehicle in ipairs(g_currentMission.vehicles) do
			if vehicle.spec_faultData ~= nil then
				for i=1, #vehicle.spec_faultData.parts do
					if GSET.difficulty == 1 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 2 * g_currentMission.environment.plannedDaysPerPeriod
					elseif GSET.difficulty == 2 then
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime * 1 * g_currentMission.environment.plannedDaysPerPeriod
					else
						vehicle.spec_faultData.parts[i].tmp_lifetime = vehicle.spec_faultData.parts[i].lifetime / 2 * g_currentMission.environment.plannedDaysPerPeriod
					end
				end
				RVBParts_Event.sendEvent(vehicle, unpack(vehicle.spec_faultData.parts))
				--vehicle:raiseDirtyFlags(vehicle.spec_faultData.dirtyFlag)
			end
		end
		VehicleBreakdowns.FSSET_Daysperiod = g_currentMission.environment.plannedDaysPerPeriod
		VehicleBreakdowns.GSET_Change_difficulty = GSET.difficulty
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
					self:setVehicleDamageGlowplugFailure(dt)
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
	
if self.isClient and isActiveForInputIgnoreSelection then


	if self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.MOTOR or self:getIsFaultSelfStarter() and not motorized.isMotorStarted then
		--spec.DontStopMotor.battery = true
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

			spec.DontStopMotor.battery = true
			
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
					spec.parts[1].operatingHours = spec.parts[1].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
					spec.parts[5].operatingHours = spec.parts[5].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
					spec.parts[6].operatingHours = spec.parts[6].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000

					--if self.isServer then
					--elseif self.isClient then
						RVBParts_Event.sendEvent(self, unpack(spec.parts))
						--self:raiseDirtyFlags(spec.dirtyFlag)

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
					--self:setBatteryDrainingIfStartMotor()
				end
				--self:raiseActive()
			end

		end

		if not self:getIsRVBMotorStarted() then

			if spec.DontStopMotor.self_starter then
				spec.DontStopMotor.self_starter = false
				spec.DontStopMotor.battery = false
			end

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

		spec.updateDelta = spec.updateDelta + dt * g_currentMission.missionInfo.timeScale
		--if spec.updateDelta * g_currentMission.missionInfo.timeScale > spec.updateRate * g_currentMission.missionInfo.timeScale then
			self:addDamage(dt)
			spec.updateDelta = 0
		--end
		
		
		local thermostatRandom = false
		
		
		local currentHour = g_currentMission.environment.currentHour
		local currentMinute = g_currentMission.environment.currentMinute
		

		--PARTS FAULT SAVE
		for i=1, #spec.parts do

			--local Partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime

			if i == 2 or i == 4 then
				spec.partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
				if spec.partfoot >= 100 and not spec.parts[i].repairreq then
					if not spec.parts[i].repairreq then
						table.insert(spec.faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
					end
					spec.parts[i].repairreq = true
					self:raiseDirtyFlags(spec.dirtyFlag)
				end
			else
				spec.partfoot = (spec.parts[i].operatingHours * 100) / spec.parts[i].tmp_lifetime
				--if Partfoot >= 96 and not spec.parts[i].repairreq then
				if spec.partfoot > 95 and not spec.parts[i].repairreq then
					if i == 1 then
						thermostatRandom = true
					end
					if not spec.parts[i].repairreq then
						table.insert(spec.faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
					end
					spec.parts[i].repairreq = true
					self:raiseDirtyFlags(spec.dirtyFlag)
				end
			end
			--self:raiseDirtyFlags(spec.dirtyFlag)
		end
		VehicleBreakdowns:DebugFaultPrint(spec.faultListText)

	
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
				--self:raiseDirtyFlags(spec.dirtyFlag)
			--end

			thermostatRandom = false
		end
		
	end
	
	if self:getIsFaultLightings() or self:getIsFaultBattery() ~= nil and self:getIsFaultBattery() ~= 0 then
		self:lightingsFault()
	end


	--if self:getIsFaultEngine() then -- self:getIsFaultGenerator() or
	local engine_percent = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
	if engine_percent >= 99 then
		self:StopAI(self)
	end

	if g_workshopScreen.isOpen == true and g_workshopScreen.vehicle ~= nil and g_workshopScreen.vehicle.spec_motorized ~= nil then
	--	g_workshopScreen.repairButton.disabled = true
	end

end

function VehicleBreakdowns:setRVBLightsStrings(lights_request_A, lights_request_B, force, noEventSend)
    local spec = self.spec_faultData

    if lights_request_A ~= spec.lights_request_A or lights_request_B ~= spec.lights_request_B or force then
        if noEventSend == nil or noEventSend == false then
            if g_server ~= nil then
                g_server:broadcastEvent(RVBLightingsStringsEvent.new(self, lights_request_A, lights_request_B), nil, nil, self)
            else
                g_client:getServerConnection():sendEvent(RVBLightingsStringsEvent.new(self, lights_request_A, lights_request_B))
            end
        end

        spec.lights_request_A = lights_request_A
		spec.lights_request_B = lights_request_B

    end

    return true
end

function VehicleBreakdowns:setRVBLightsTypesMask(rvblightsTypesMask, force, noEventSend)
    local spec = self.spec_faultData

    if rvblightsTypesMask ~= spec.rvblightsTypesMask or force then
        if noEventSend == nil or noEventSend == false then
            if g_server ~= nil then
                g_server:broadcastEvent(RVBLightingsTypesMaskEvent.new(self, rvblightsTypesMask), nil, nil, self)
            else
                g_client:getServerConnection():sendEvent(RVBLightingsTypesMaskEvent.new(self, rvblightsTypesMask))
            end
        end

        spec.rvblightsTypesMask = rvblightsTypesMask

    end

    return true
end

function VehicleBreakdowns:getSpeedLimit(superFunc, onlyIfWorking)
    local limit = math.huge

	local spec = self.spec_faultData
	if spec ~= nil then
		local Pfoot = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
		if spec.parts[6].repairreq and Pfoot > 95 then
			limit = 7
		end
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
					if spec ~= nil and Pfoot ~= nil and spec.parts[6].repairreq and Pfoot > 95 then
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

	if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(SetRVBMotorTurnedOnEvent.new(self, true), nil, nil, self)
        else
            g_client:getServerConnection():sendEvent(SetRVBMotorTurnedOnEvent.new(self, true))
        end
    end
	
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
	local oneGameMinute = 60
	if self.temperatureDayText > 20 then
		oneGameMinute = oneGameMinute / 2
	elseif self.temperatureDayText <= 20 and self.temperatureDayText >= 5 then
		oneGameMinute = oneGameMinute
	else
		oneGameMinute = oneGameMinute * 1.5
	end
	
	if rvbs.parts[3].operatingHours < rvbs.parts[3].tmp_lifetime then
		rvbs.parts[3].operatingHours = rvbs.parts[3].operatingHours + oneGameMinute / 3600
	end
	
	--SELFSTARTER SERULES
	--starter
	local oneGameMinute7 = 60
	if rvbs.parts[7].operatingHours < rvbs.parts[7].tmp_lifetime then
		rvbs.parts[7].operatingHours = rvbs.parts[7].operatingHours + oneGameMinute7 / 3600
	end

	RVBParts_Event.sendEvent(self, unpack(rvbs.parts))

	
	--if not rvbs.DontStopMotor.battery then
		self:setBatteryDrainingIfStartMotor()
	--end
	
	self:raiseDirtyFlags(rvbs.dirtyFlag)

	
	if self:getIsFaultSelfStarter() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.MOTOR then

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
		
		if self.isServer then
			self:wakeUp()
		end
	
	else
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
	
	if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(SetRVBMotorTurnedOnEvent.new(self, false), nil, nil, self)
        else
            g_client:getServerConnection():sendEvent(SetRVBMotorTurnedOnEvent.new(self, false))
        end
    end

	if rvbs.isRVBMotorStarted and self:getIsFaultSelfStarter() or self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.MOTOR and not self:getIsFaultGenerator() and not self:getIsFaultGlowPlug() then
		if rvbs.isRVBMotorStarted then
			rvbs.isRVBMotorStarted = false
			if self.isClient then
				stopSample(VehicleBreakdowns.sounds["self_starter"], 0 , 0)
			end
		end
	
	elseif rvbs.isRVBMotorStarted and self:getIsFaultGenerator() and self:getIsFaultBattery() < VehicleBreakdowns.SET.BatteryLevel.MOTOR and not self:getIsFaultSelfStarter() and not self:getIsFaultGlowPlug() then
		if rvbs.isRVBMotorStarted then
			rvbs.isRVBMotorStarted = false
			if self.isClient then
				stopSample(VehicleBreakdowns.sounds["self_starter"], 0 , 0)
			end
		end

	else
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

function VehicleBreakdowns:onStartOperatingHours(dt)

	local spec = self.spec_faultData

	-- TotaloperatingHours
	spec.rvb[3] = spec.rvb[3] + dt * g_currentMission.missionInfo.timeScale / 3600000
	-- Service operatingHours
	spec.rvb[4] = spec.rvb[4] + dt * g_currentMission.missionInfo.timeScale / 3600000

	-- PARTS operatingHours
	spec.parts[1].operatingHours = spec.parts[1].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
	spec.parts[5].operatingHours = spec.parts[5].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
	spec.parts[6].operatingHours = spec.parts[6].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000
	spec.parts[8].operatingHours = spec.parts[8].operatingHours + dt * g_currentMission.missionInfo.timeScale / 3600000

	RVBTotal_Event.sendEvent(self, unpack(spec.rvb))
	RVBParts_Event.sendEvent(self, unpack(spec.parts))
	--self:raiseDirtyFlags(spec.dirtyFlag)

end		

function VehicleBreakdowns:FillUnit_showInfo(superFunc, box)
end
FillUnit.showInfo = Utils.overwrittenFunction(FillUnit.showInfo, VehicleBreakdowns.FillUnit_showInfo)

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
	
		-- INSPECTION
		if spec.inspection[1] then -- and not spec.repair[10]
			local tomorrowText = ""
			if spec.inspection[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_inspectionVheicle"), tomorrowText..string.format("%02d:%02d", spec.inspection[4], spec.inspection[5]))
		end
		
		-- REPAIR
		if spec.repair[1] then
			local tomorrowText = ""
			if spec.repair[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_repairVheicle"), tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5]))
		end
		
		-- SERVICE
		if self:getIsService() then
			local tomorrowText = ""
			if spec.service[3] > g_currentMission.environment.currentDay then
				tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
			end
			box:addLine(g_i18n:getText("infoDisplayExtension_serviceVheicle"), tomorrowText..string.format("%02d:%02d", spec.service[4], spec.service[5]))
		end
		
	end
	
	local specFillU = self.spec_fillUnit

    if specFillU.isInfoDirty then
        specFillU.fillUnitInfos = {}
        local fillTypeToInfo = {}

        for fillUnitIndex, fillUnit in ipairs(specFillU.fillUnits) do
			
			if self.getConsumerFillUnitIndex ~= nil then
				local fillUnitIndexELECTRIC = self:getConsumerFillUnitIndex(FillType.ELECTRICCHARGE)
				local fillUnitIndexDIESEL = self:getConsumerFillUnitIndex(FillType.DIESEL)
				
				if fillUnitIndexELECTRIC ~= nil and fillUnitIndexDIESEL ~= nil then

					if fillUnit.fillType ~= FillType.ELECTRICCHARGE then
						if fillUnit.showOnInfoHud and fillUnit.fillLevel > 0 then
							local info = fillTypeToInfo[fillUnit.fillType]
							if info == nil then
								local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)
								info = {title=fillType.title, fillLevel=0, unit=fillUnit.unitText, precision=0}
								table.insert(specFillU.fillUnitInfos, info)
								fillTypeToInfo[fillUnit.fillType] = info
							end

							info.fillLevel = info.fillLevel + fillUnit.fillLevel
							if info.precision == 0 and fillUnit.fillLevel > 0 then
								info.precision = fillUnit.uiPrecision or 0
							end
						end
					end

					if fillUnit.fillType == FillType.ELECTRICCHARGE then
						local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)
							
						local info = fillTypeToInfo[fillUnit.fillType]
						if info == nil then
							local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)
							info = {title=g_i18n:getText("RVB_list_battery"), fillLevel=0, unit="%", precision=0}
							table.insert(specFillU.fillUnitInfos, info)
							fillTypeToInfo[fillUnit.fillType] = info
						end

						info.fillLevel = info.fillLevel + fillUnit.fillLevel / fillUnit.capacity * 100
						if info.precision == 0 and fillUnit.fillLevel >= 0 then
							info.precision = fillUnit.uiPrecision or 0
						end
							
					end

				else

					local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)

					if fillUnit.showOnInfoHud and fillUnit.fillLevel > 0 then
						local info = fillTypeToInfo[fillUnit.fillType]
						if info == nil then
							local fillType = g_fillTypeManager:getFillTypeByIndex(fillUnit.fillType)
							info = {title=fillType.title, fillLevel=0, unit=fillUnit.unitText, precision=0}
							table.insert(specFillU.fillUnitInfos, info)
							fillTypeToInfo[fillUnit.fillType] = info
						end

						info.fillLevel = info.fillLevel + fillUnit.fillLevel
						if info.precision == 0 and fillUnit.fillLevel > 0 then
							info.precision = fillUnit.uiPrecision or 0
						end
					end
				
				end
				
			end

        end

        specFillU.isInfoDirty = false
    end

    for _, info in ipairs(specFillU.fillUnitInfos) do
        local formattedNumber
        if info.precision > 0 then
            local rounded = MathUtil.round(info.fillLevel, info.precision)
            formattedNumber = string.format("%d%s%0"..info.precision.."d", math.floor(rounded), g_i18n.decimalSeparator, (rounded - math.floor(rounded)) * 10 ^ info.precision)
        else
            formattedNumber = string.format("%d", MathUtil.round(info.fillLevel))
        end

        formattedNumber = formattedNumber .. " " .. (info.unit or g_i18n:getVolumeUnit())

        box:addLine(info.title, formattedNumber)
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
	return VehicleBreakdowns.calculateBatteryChPrice(300, spec.rvb[5])
end

function VehicleBreakdowns:getBatteryChPrice_AAAA()
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

function VehicleBreakdowns:addDamage(dt)

	local spec = self.spec_faultData
	local RVBSET = g_currentMission.vehicleBreakdowns		

	local _value = self.spec_motorized.motorTemperature.value
	local motor = self.spec_motorized.motor

	local maximumSpeed = motor:getMaximumForwardSpeed() * 3.6
	local maxspeedNotBreakdown = string.format("%.0f", maximumSpeed * 0.4)

	maxspeedNotBreakdown = string.format("%.0f", maxspeedNotBreakdown)

	local currentspeed = self:getSpeed(self)
	local currentTemp = _value
	local mintempNotBreakdown = 30
	
	local oneGameMinute = 60 * 1000 / 3600000

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
			oneGameMinute = oneGameMinute / 60
			--local oneGameMinute = 60 * 1000 / 3600000
			-- PARTS operatingHours
			spec.parts[1].operatingHours = spec.parts[1].operatingHours + oneGameMinute + dt * g_currentMission.missionInfo.timeScale / 3600000
			spec.parts[6].operatingHours = spec.parts[6].operatingHours + oneGameMinute + dt * g_currentMission.missionInfo.timeScale / 3600000

			--if self.isServer then
			--elseif self.isClient then
				RVBParts_Event.sendEvent(self, unpack(spec.parts))
				--self:raiseDirtyFlags(spec.dirtyFlag)
			--end


			local fault_text = "RVB_fault_"
			local fault_hud_text = "RVB_fault_hud"
			if spec.faultStorage[2] then
				fault_text = "RVB_fault_thermostatC"
				fault_hud_text = "RVB_fault_thermostatC_hud"
			end
			if RVBSET:getIsAlertMessage() and not spec.addDamage.alert then
				if self.getIsEntered ~= nil and self:getIsEntered() then
					if self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil then
						g_currentMission:showBlinkingWarning(g_i18n:getText(fault_text), 2500)
					end
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

	if table.maxn(fault) > 0 then
		local NotifiText = g_i18n:getText("RVB_ErrorNotifi")..table.concat(fault,", ")
		g_currentMission:addGameNotification(g_i18n:getText("input_VEHICLE_BREAKDOWN_MENU"), NotifiText, "", 2048)
	end
	for i in pairs(fault) do
		fault[i] = nil
	end
end
		
-- IGAZÁBÓL NEM KELL
function VehicleBreakdowns:onEnterVehicle()
	local spec = self.spec_faultData
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

function VehicleBreakdowns:getCanMotorRun(superFunc)
	if self.spec_faultData ~= nil then
		local spec = self.spec_faultData
		if spec ~= nil then
			local engine_percent = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
			if engine_percent < 99 and not spec.battery[1] and not spec.service[1] and not spec.repair[1] and not spec.inspection[1] and self:getIsFaultBattery() >= 0.06 and spec.batteryCHActive == false then
				return superFunc(self)
			end
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
	
	if specf.inspection[1] and not specf.inspection[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_INSPECTION
	end
	if specf.inspection[1] and specf.inspection[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
	end
	
	if specf.repair[1] and not specf.repair[2] and specf.inspection[8] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_REPAIR
	end
	if specf.repair[1] and specf.repair[2] and specf.inspection[8] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    end
	
	if specf.service[1] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SERVICE
    end
	if specf.service[1] and specf.service[2] then
        return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    end
	
	--if specf.battery[1] then
    --    return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_BATTERY_CHARGING
    --end
	if self:getIsFaultBattery() > 0.03 and self:getIsFaultBattery() < 0.10 then -- VehicleBreakdowns.SET.BatteryLevel.MOTOR then
		return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_BATTERY
	end
	--if specf.battery[1] and specf.battery[2] then
    --    return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_SUSPENSION
    --end
	if specf.batteryCHActive == true then
		return g_i18n.modEnvironments[g_vehicleBreakdownsModName].texts.VehicleBreakdown_DEAD_ENGINE_BATTERY
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
		spec.motorFan.disableTemperature = 100
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

	if g_specializationManager:getSpecializationByName("vehicleBreakdowns") ~= nil and	self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) ~= nil
	then
		if g_client ~= nil and g_currentMission.hud.isVisible and g_currentMission.controlledVehicle ~= nil then
			g_currentMission.vehicleBreakdowns.ui_hud:setVehicle(self)
			g_currentMission.vehicleBreakdowns.ui_hud:drawHUD()
		end
	end
	
	if g_specializationManager:getSpecializationByName("vehicleBreakdowns") ~= nil and	self.getConsumerFillUnitIndex ~= nil and self:getConsumerFillUnitIndex(FillType.ELECTRICCHARGE) ~= nil and self:getConsumerFillUnitIndex(FillType.DIESEL) == nil
	then
		local dashboard_icons = g_currentMission.vehicleBreakdowns.ui_hud.icons	
		dashboard_icons.temperature.overlay:setVisible(false)
		dashboard_icons.battery.overlay:setVisible(false)
		dashboard_icons.lights.overlay:setVisible(false)
		dashboard_icons.engine.overlay:setVisible(false)
		dashboard_icons.service.overlay:setVisible(false)
	end

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
	
	
	-- sync engine data with server
	rvb.updateTimer = rvb.updateTimer + dt
	if self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then
		rvb.motorTemperature = spec.motorTemperature.value
		rvb.fanEnabled = spec.motorFan.enabled
		rvb.lastFuelUsage = spec.lastFuelUsage
		rvb.lastDefUsage = spec.lastDefUsage
		rvb.lastAirUsage = spec.lastAirUsage
		rvb.fanEnableTemperature = spec.motorFan.enableTemperature
		rvb.fanDisableTemperature = spec.motorFan.disableTemperature
		
		if rvb.updateTimer >= 1000 and rvb.motorTemperature ~= self.spec_motorized.motorTemperature.valueSend then
			self:raiseDirtyFlags(rvb.dirtyFlag)
		end
		if rvb.fanEnabled ~= rvb.fanEnabledLast then
			rvb.fanEnabledLast = rvb.fanEnabled
			self:raiseDirtyFlags(rvb.dirtyFlag)
		end
	end
	if self.isClient and not self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then
		spec.motorTemperature.value = rvb.motorTemperature
		spec.motorFan.enabled = rvb.fanEnabled
		spec.lastFuelUsage = rvb.lastFuelUsage
		spec.lastDefUsage = rvb.lastDefUsage
		spec.lastAirUsage = rvb.lastAirUsage
		spec.motorFan.enableTemperature = rvb.fanEnableTemperature
		spec.motorFan.disableTemperature = rvb.fanDisableTemperature
	end
	-- sync end


	rvb.updateBatteryTimer = rvb.updateBatteryTimer + dt
	if self.isServer then
		rvb.RVB_BatteryFillLevel = self.spec_fillUnit.fillUnits[rvb.batteryFillUnitIndex].fillLevel
		--self:raiseDirtyFlags(spec.dirtyFlag)
		
		if rvb.updateBatteryTimer >= 1000 then
			self:raiseDirtyFlags(rvb.dirtyFlag)
			--self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
			rvb.updateBatteryTimer = 0
			--print("isServer "..self.spec_fillUnit.fillUnits[rvb.batteryFillUnitIndex].fillLevel.." rvb.RVB_BatteryFillLevel "..rvb.RVB_BatteryFillLevel)
		end
	end
	if self.isClient and not self.isServer then
		self.spec_fillUnit.fillUnits[rvb.batteryFillUnitIndex].fillLevel = rvb.RVB_BatteryFillLevel
		self.spec_fillUnit.fillUnits[rvb.batteryFillUnitIndex].fillType = FillType.ELECTRICCHARGE
		--self:raiseDirtyFlags(self.spec_fillUnit.dirtyFlag)
		--print("isClient "..self.spec_fillUnit.fillUnits[rvb.batteryFillUnitIndex].fillLevel.." rvb.RVB_BatteryFillLevel "..rvb.RVB_BatteryFillLevel)
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
	local batteryFillUnitIndex = self:getConsumerFillUnitIndex(FillType.ELECTRICCHARGE)
	if batteryFillUnitIndex ~= nil then
		return tonumber(self:getFillUnitFillLevelPercentage(batteryFillUnitIndex)) or 1
	end
	return 1
end

function VehicleBreakdowns:setIsFaultBattery(value)
	local spec = self.spec_faultData
	spec.rvb[5] = value
	--if spec.rvb[5] > 1 then
	--	spec.rvb[5] = 1
	--end
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

function VehicleBreakdowns:updateDamageAmount(superFunc, dt)

	local spec = self.spec_faultData
	
	if spec ~= nil then
			
		local currentPartslifetime = 0
		local currentPartsoperatingHours = 0

		for i, value in pairs(spec.parts) do
			if i ~= 9 and i ~= 10 and i ~= 11 and i ~= 12 then
				currentPartslifetime = currentPartslifetime + value.tmp_lifetime
				currentPartsoperatingHours = currentPartsoperatingHours + value.operatingHours
			end
		end
	
		self:setDamageAmount(currentPartsoperatingHours/currentPartslifetime)
		
		return 0
		
	else
		return superFunc(dt)
	end
end


function VehicleBreakdowns:repairVehicle()
	local spec = self.spec_faultData
	
	if spec ~= nil then
		--g_gui:showInfoDialog({
        --    text = g_i18n:getText("RVB_main_repair_fault")
        --})
		spec.repair_canfixed = false

		g_gui:showGui("RVBTabbedMenu")

	end
	if spec.repair_canfixed then
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
				--if item.spec_workshop.sellingPoint.sellTriggerNode then
					--table.insert(VehicleBreakdowns.repairTriggers, {node=item.spec_workshop.sellingPoint.sellTriggerNode, owner=item.ownerFarmId })
				--end
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
			if vehicle.getDamageShowOnHud ~= nil and vehicle:getDamageShowOnHud() and vehicle.getIsSelected ~= nil and vehicle:getIsSelected() then
				--if vehicle.getDamageAmount ~= nil then
				gaugeValue = math.min(gaugeValue, 1 - vehicle:getDamageAmount())
				--end
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
