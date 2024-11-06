
RVBGeneralSet_Event = {}

local RVBGeneralSet_Event_mt = Class(RVBGeneralSet_Event, Event)
InitEventClass(RVBGeneralSet_Event, "RVBGeneralSet_Event")

function RVBGeneralSet_Event.emptyNew()
    local self = Event.new(RVBGeneralSet_Event_mt)
    return self
end

function RVBGeneralSet_Event.new(alertmessage, difficulty, basicrepairtrigger, debugdisplay, cp_notice)
    local self = RVBGeneralSet_Event.emptyNew()
	self.alertmessage = alertmessage
	self.difficulty = difficulty
	self.basicrepairtrigger = basicrepairtrigger
	self.debugdisplay = debugdisplay
	self.cp_notice = cp_notice
    return self
end

function RVBGeneralSet_Event:readStream(streamId, connection)
	self.alertmessage = streamReadBool(streamId)
	self.difficulty = streamReadInt32(streamId)
	self.basicrepairtrigger = streamReadBool(streamId)
	self.debugdisplay = streamReadBool(streamId)
	self.cp_notice = streamReadBool(streamId)
    self:run(connection)
end

function RVBGeneralSet_Event:writeStream(streamId, connection)
	streamWriteBool(streamId, self.alertmessage)
	streamWriteInt32(streamId, self.difficulty)
	streamWriteBool(streamId, self.basicrepairtrigger)
	streamWriteBool(streamId, self.debugdisplay)
	streamWriteBool(streamId, self.cp_notice)
end

function RVBGeneralSet_Event:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBGeneralSet_Event.new(self.alertmessage, self.difficulty, self.basicrepairtrigger, self.debugdisplay, self.cp_notice), nil, connection, self)
	end
	g_currentMission.vehicleBreakdowns:setCustomGeneralSet(self.alertmessage, self.difficulty, self.basicrepairtrigger, self.debugdisplay, self.cp_notice)
end