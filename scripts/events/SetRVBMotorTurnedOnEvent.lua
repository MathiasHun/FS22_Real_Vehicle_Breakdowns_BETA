---Event for motor turned on state


SetRVBMotorTurnedOnEvent = {}

local SetRVBMotorTurnedOnEvent_mt = Class(SetRVBMotorTurnedOnEvent, Event)

InitEventClass(SetRVBMotorTurnedOnEvent, "SetRVBMotorTurnedOnEvent")


---Create instance of Event class
-- @return table self instance of class event
function SetRVBMotorTurnedOnEvent.emptyNew()
    local self = Event.new(SetRVBMotorTurnedOnEvent_mt)
    return self
end


---Create new instance of event
-- @param table object object
-- @param boolean turnedOn is turned on
function SetRVBMotorTurnedOnEvent.new(object, turnedOn)
    local self = SetRVBMotorTurnedOnEvent.emptyNew()
    self.object = object
    self.turnedOn = turnedOn
    return self
end


---Called on client side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SetRVBMotorTurnedOnEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.turnedOn = streamReadBool(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function SetRVBMotorTurnedOnEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.turnedOn)
end


---Run action on receiving side
-- @param integer connection connection
function SetRVBMotorTurnedOnEvent:run(connection)
    if self.object ~= nil and self.object:getIsSynchronized() then
        if self.turnedOn then
            self.object:startMotor(true)
        else
            self.object:stopMotor(true)
        end
    end

    if not connection:getIsServer() then
        g_server:broadcastEvent(SetRVBMotorTurnedOnEvent.new(self.object, self.turnedOn), nil, connection, self.object)
    end
end
