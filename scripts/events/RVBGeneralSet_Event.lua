
RVBGeneralSet_Event = {}

local RVBGeneralSet_Event_mt = Class(RVBGeneralSet_Event, Event)
InitEventClass(RVBGeneralSet_Event, "RVBGeneralSet_Event")

function RVBGeneralSet_Event.emptyNew()
    local self = Event.new(RVBGeneralSet_Event_mt)
    return self
end

function RVBGeneralSet_Event.new(alertmessage)
    local self = RVBGeneralSet_Event.emptyNew()
	self.alertmessage = alertmessage
    return self
end

function RVBGeneralSet_Event:readStream(streamId, connection)
	self.alertmessage = streamReadBool(streamId)
    self:run(connection)
end

function RVBGeneralSet_Event:writeStream(streamId, connection)
	streamWriteBool(streamId, self.alertmessage)
end

function RVBGeneralSet_Event:run(connection)

	local message = g_currentMission.vehicleBreakdowns:setCustomGeneralSet(self.alertmessage)

	if g_dedicatedServer ~= nil and message ~= nil then
		Logging.info(message)
	end

end