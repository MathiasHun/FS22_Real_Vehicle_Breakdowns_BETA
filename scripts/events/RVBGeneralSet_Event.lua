
RVBGeneralSet_Event = {}

local RVBGeneralSet_Event_mt = Class(RVBGeneralSet_Event, Event)
InitEventClass(RVBGeneralSet_Event, "RVBGeneralSet_Event")

function RVBGeneralSet_Event.emptyNew()
    local self = Event.new(RVBGeneralSet_Event_mt)
    return self
end

function RVBGeneralSet_Event.new(alertmessage, rvbDifficulty, basicrepairtrigger, cp_notice)
    local self = RVBGeneralSet_Event.emptyNew()
	self.alertmessage = alertmessage
	self.rvbDifficulty = rvbDifficulty
	self.basicrepairtrigger = basicrepairtrigger
	self.cp_notice = cp_notice
    return self
end

function RVBGeneralSet_Event:readStream(streamId, connection)
	self.alertmessage = streamReadBool(streamId)
	self.rvbDifficulty = streamReadInt32(streamId)
	self.basicrepairtrigger = streamReadBool(streamId)
	self.cp_notice = streamReadBool(streamId)
    self:run(connection)
end

function RVBGeneralSet_Event:writeStream(streamId, connection)
	streamWriteBool(streamId, self.alertmessage)
	streamWriteInt32(streamId, self.rvbDifficulty)
	streamWriteBool(streamId, self.basicrepairtrigger)
	streamWriteBool(streamId, self.cp_notice)
end

function RVBGeneralSet_Event:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBGeneralSet_Event.new(self.alertmessage, self.rvbDifficulty, self.basicrepairtrigger, self.cp_notice), nil, connection, self)
	end
	g_currentMission.vehicleBreakdowns:setCustomGeneralSet(self.alertmessage, self.rvbDifficulty, self.basicrepairtrigger, self.cp_notice)
end
