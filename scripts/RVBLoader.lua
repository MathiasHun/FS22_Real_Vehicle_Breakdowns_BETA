
local directory = g_currentModDirectory
local modName = g_currentModName

g_vehicleBreakdownsModName = modName
g_vehicleBreakdownsDirectory = directory

source(Utils.getFilename("scripts/RVBMain.lua", directory))

-- TABBEDMENU
source(Utils.getFilename("scripts/gui/RVBTabbedMenu.lua", directory))
-- FRAME FILES
source(Utils.getFilename("scripts/gui/RVBGamePlaySettings_Frame.lua", directory))
source(Utils.getFilename("scripts/gui/RVBGeneralSettings_Frame.lua", directory))
source(Utils.getFilename("scripts/gui/RVBVehicleList_Frame.lua", directory))
-- EVENT FILES
source(Utils.getFilename("scripts/events/RVBTotal_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVB_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBRepair_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBInspection_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBBattery_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBService_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBGamePSet_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBGeneralSet_Event.lua", directory))
source(Utils.getFilename("scripts/events/RVBParts_Event.lua", directory))

source(Utils.getFilename("scripts/events/BatteryFillUnitFillLevelEvent.lua", directory))
source(Utils.getFilename("scripts/events/RVBLightingsStringsEvent.lua", directory))
source(Utils.getFilename("scripts/events/RVBLightingsTypesMaskEvent.lua", directory))
source(Utils.getFilename("scripts/events/SetRVBMotorTurnedOnEvent.lua", directory))

-- HUD
source(Utils.getFilename("scripts/hud/RVB_HUD.lua", directory))

-- UTILS
source(Utils.getFilename("scripts/utils/stream.lua", directory))
source(Utils.getFilename("scripts/utils/rvb_Utils.lua", directory))

-- AIMessage
source(Utils.getFilename("scripts/ai/errors/AIMessageErrorBatteryDischarged.lua", directory))

local vehicleBreakdowns


local function isEnabled()
    return vehicleBreakdowns ~= nil
end

function init()

	vehicleBreakdowns = RVBMain:new(directory, modName)
	
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

    Mission00.load = Utils.prependedFunction(Mission00.load, loadMission)
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)

    FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, rvbgamePlaySetsaveToXMLFile)

    SavegameSettingsEvent.readStream = Utils.appendedFunction(SavegameSettingsEvent.readStream, readStream)
    SavegameSettingsEvent.writeStream = Utils.appendedFunction(SavegameSettingsEvent.writeStream, writeStream)
	
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateVehicleTypes)
	
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, registerActionEvents)
    BaseMission.unregisterActionEvents = Utils.appendedFunction(BaseMission.unregisterActionEvents, unregisterActionEvents)
	
end

function loadMission(mission)
   
    mission.vehicleBreakdowns = vehicleBreakdowns

    addModEventListener(vehicleBreakdowns)

end

function loadedMission(mission, node)
    if not isEnabled() then
        return
    end

    if mission.cancelLoading then
        return
    end

    vehicleBreakdowns:onMissionLoaded(mission)

end

function rvbgamePlaySetsaveToXMLFile(missionInfo)
    if isEnabled() and missionInfo.isValid then
		local savegameFolderPath = missionInfo.savegameDirectory
		if savegameFolderPath == nil then
			savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), missionInfo.savegameIndex)
		end
	
		local GAMEPLAY_SETTINGS_XML = Utils.getFilename("/RVBGamePlaySettings.xml", savegameFolderPath)
		vehicleBreakdowns:rvbsaveToXMLFile(GAMEPLAY_SETTINGS_XML)
    end
end

function validateVehicleTypes(typeManager)
    if typeManager.typeName == "vehicle" then
        RVBMain.installSpecializations(g_vehicleTypeManager, g_specializationManager, directory, modName)
    end
end

function registerActionEvents()
    vehicleBreakdowns:registerActionEvents()
end

function unregisterActionEvents()
    vehicleBreakdowns:unregisterActionEvents()
end

function unload()

    if not isEnabled() then
        return
    end

    removeModEventListener(vehicleBreakdowns)

    vehicleBreakdowns:delete()
    vehicleBreakdowns = nil

    if g_currentMission ~= nil then
        g_currentMission.vehicleBreakdowns = nil
    end
end

function readStream(e, streamId, connection)
    if not isEnabled() then
        return
    end

    vehicleBreakdowns:onReadStream(streamId, connection)
end

function writeStream(e, streamId, connection)
    if not isEnabled() then
        return
    end

    vehicleBreakdowns:onWriteStream(streamId, connection)
end

init()