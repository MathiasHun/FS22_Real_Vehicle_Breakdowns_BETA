
RVBGamePSet_Event = {}

local RVBGamePSet_Event_mt = Class(RVBGamePSet_Event, Event)
InitEventClass(RVBGamePSet_Event, "RVBGamePSet_Event")

function RVBGamePSet_Event.emptyNew()
    local self = Event.new(RVBGamePSet_Event_mt)

    return self
end

function RVBGamePSet_Event.new(dailyServiceInterval, periodicServiceInterval, repairshop, workshopOpen, workshopClose)
    local self = RVBGamePSet_Event.emptyNew()

	self.dailyServiceInterval = dailyServiceInterval
    self.periodicServiceInterval = periodicServiceInterval
	self.repairshop = repairshop
	self.workshopOpen = workshopOpen
	self.workshopClose = workshopClose
    return self
end

function RVBGamePSet_Event:readStream(streamId, connection)
	self.dailyServiceInterval = streamReadInt32(streamId)
	self.periodicServiceInterval = streamReadInt32(streamId)
	self.repairshop = streamReadBool(streamId)
	self.workshopOpen = streamReadInt32(streamId)
	self.workshopClose = streamReadInt32(streamId)
    self:run(connection)
end

function RVBGamePSet_Event:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.dailyServiceInterval)
	streamWriteInt32(streamId, self.periodicServiceInterval)
	streamWriteBool(streamId, self.repairshop)
	streamWriteInt32(streamId, self.workshopOpen)
	streamWriteInt32(streamId, self.workshopClose)
end

function RVBGamePSet_Event:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBGamePSet_Event.new(self.dailyServiceInterval, self.periodicServiceInterval, self.repairshop, self.workshopOpen, self.workshopClose), nil, connection, self)
	end
	g_currentMission.vehicleBreakdowns:setCustomGamePlaySet(self.dailyServiceInterval, self.periodicServiceInterval, self.repairshop, self.workshopOpen, self.workshopClose)
end
