
RVBGeneralSet_Event = {}

local RVBGeneralSet_Event_mt = Class(RVBGeneralSet_Event, Event)
InitEventClass(RVBGeneralSet_Event, "RVBGeneralSet_Event")

function RVBGeneralSet_Event.emptyNew()
    local self = Event.new(RVBGeneralSet_Event_mt)
    return self
end

function RVBGeneralSet_Event.new(alertmessage, rvbDifficulty)
    local self = RVBGeneralSet_Event.emptyNew()
	self.alertmessage = alertmessage
	self.rvbDifficulty = rvbDifficulty
    return self
end

function RVBGeneralSet_Event:readStream(streamId, connection)
	self.alertmessage = streamReadBool(streamId)
	self.rvbDifficulty = streamReadInt32(streamId)
    self:run(connection)
end

function RVBGeneralSet_Event:writeStream(streamId, connection)
	streamWriteBool(streamId, self.alertmessage)
	streamWriteInt32(streamId, self.rvbDifficulty)
end

function RVBGeneralSet_Event:run(connection)

	local message = g_currentMission.vehicleBreakdowns:setCustomGeneralSet(self.alertmessage, self.rvbDifficulty)

	if g_dedicatedServer ~= nil and message ~= nil then
		Logging.info(message)
	end

end