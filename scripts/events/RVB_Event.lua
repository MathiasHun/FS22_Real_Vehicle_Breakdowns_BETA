
RVB_Event = {}
local RVB_Event_mt = Class(RVB_Event, Event)

InitEventClass(RVB_Event, "RVB_Event")

function RVB_Event.emptyNew()
	local self = Event.new(RVB_Event_mt)
	self.className = "RVB_Event"
	return self
end

function RVB_Event.new(vehicle, b1, b2 )
	local elements = { b1, b2 }

	local self = RVB_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.faultStorage = { unpack(elements) }

	return self
end

function RVB_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)
	self.vehicle.spec_faultData.faultStorage[1] = streamReadBool(streamId)
	self.vehicle.spec_faultData.faultStorage[2] = streamReadBool(streamId)

	self:run(connection)
end

function RVB_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	streamWriteBool(streamId, self.vehicle.spec_faultData.faultStorage[1])
	streamWriteBool(streamId, self.vehicle.spec_faultData.faultStorage[2])

end

function RVB_Event:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        VehicleBreakdowns.SyncClientServer_RVBFaultStorage(self.vehicle, unpack(self.vehicle.spec_faultData.faultStorage))
		self.vehicle.spec_faultData.faultStorage = { unpack(self.vehicle.spec_faultData.faultStorage) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVB_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.faultStorage)), nil, connection, self.vehicle)
    end
	
end

function RVB_Event.sendEvent( vehicle, b1, b2, noEventSend )
	local elements = { b1, b2 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVB_Event.new(vehicle, unpack(elements)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVB_Event.new(vehicle, unpack(elements)))
		end
	end
end