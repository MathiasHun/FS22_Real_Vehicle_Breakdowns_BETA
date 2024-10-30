
RVBGamePSet_Event = {}

local RVBGamePSet_Event_mt = Class(RVBGamePSet_Event, Event)
InitEventClass(RVBGamePSet_Event, "RVBGamePSet_Event")

function RVBGamePSet_Event.emptyNew()
    local self = Event.new(RVBGamePSet_Event_mt)

    return self
end

function RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose, thermostatLifetime, lightingsLifetime,
		glowplugLifetime, wipersLifetime, generatorLifetime, engineLifetime, selfstarterLifetime, batteryLifetime, tireLifetime)
    local self = RVBGamePSet_Event.emptyNew()

	self.dailyServiceInterval = dailyServiceInterval
    self.periodicServiceInterval = periodicServiceInterval
	self.repairshop = repairshop
	self.workshopOpen = workshopOpen
	self.workshopClose = workshopClose
	self.thermostatLifetime = thermostatLifetime
	self.lightingsLifetime = lightingsLifetime
	self.glowplugLifetime = glowplugLifetime
	self.wipersLifetime = wipersLifetime
	self.generatorLifetime = generatorLifetime
	self.engineLifetime = engineLifetime
	self.selfstarterLifetime = selfstarterLifetime
	self.batteryLifetime = batteryLifetime
	self.tireLifetime = tireLifetime
    return self
end

function RVBGamePSet_Event:readStream(streamId, connection)
	self.dailyServiceInterval = streamReadInt32(streamId)
	self.periodicServiceInterval = streamReadInt32(streamId)
	self.repairshop = streamReadBool(streamId)
	self.workshopOpen = streamReadInt32(streamId)
	self.workshopClose = streamReadInt32(streamId)
	self.thermostatLifetime = streamReadInt32(streamId)
	self.lightingsLifetime = streamReadInt32(streamId)
	self.glowplugLifetime = streamReadInt32(streamId)
	self.wipersLifetime = streamReadInt32(streamId)
	self.generatorLifetime = streamReadInt32(streamId)
	self.engineLifetime = streamReadInt32(streamId)
	self.selfstarterLifetime = streamReadInt32(streamId)
	self.batteryLifetime = streamReadInt32(streamId)
	self.tireLifetime = streamReadInt32(streamId)
    self:run(connection)
end

function RVBGamePSet_Event:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.dailyServiceInterval)
	streamWriteInt32(streamId, self.periodicServiceInterval)
	streamWriteBool(streamId, self.repairshop)
	streamWriteInt32(streamId, self.workshopOpen)
	streamWriteInt32(streamId, self.workshopClose)
	streamWriteInt32(streamId, self.thermostatLifetime)
	streamWriteInt32(streamId, self.lightingsLifetime)
	streamWriteInt32(streamId, self.glowplugLifetime)
	streamWriteInt32(streamId, self.wipersLifetime)
	streamWriteInt32(streamId, self.generatorLifetime)
	streamWriteInt32(streamId, self.engineLifetime)
	streamWriteInt32(streamId, self.selfstarterLifetime)
	streamWriteInt32(streamId, self.batteryLifetime)
	streamWriteInt32(streamId, self.tireLifetime)
end

function RVBGamePSet_Event:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBGamePSet_Event.new(self.dailyServiceInterval, self.periodicServiceInterval, self.repairshop, self.workshopOpen, self.workshopClose, self.thermostatLifetime, self.lightingsLifetime,
		self.glowplugLifetime, self.wipersLifetime, self.generatorLifetime, self.engineLifetime, self.selfstarterLifetime, self.batteryLifetime, self.tireLifetime), nil, connection, self)
	end
	g_currentMission.vehicleBreakdowns:setCustomGamePlaySet(self.dailyServiceInterval, self.periodicServiceInterval, self.repairshop, self.workshopOpen, self.workshopClose, self.thermostatLifetime, self.lightingsLifetime,
	self.glowplugLifetime, self.wipersLifetime, self.generatorLifetime, self.engineLifetime, self.selfstarterLifetime, self.batteryLifetime, self.tireLifetime)
end