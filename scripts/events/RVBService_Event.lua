
RVBService_Event = {}
local RVBService_Event_mt = Class(RVBService_Event, Event)

InitEventClass(RVBService_Event, "RVBService_Event")

function RVBService_Event.emptyNew()
	local self = Event.new(RVBService_Event_mt)
	return self
end

function RVBService_Event.new(vehicle, s1, s2, s3, s4, s5, s6, s7, s8 )
	local service = { s1, s2, s3, s4, s5, s6, s7, s8 }
	local self = RVBService_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.service = { unpack(service) }

	return self
end

function RVBService_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)

	self.vehicle.spec_faultData.service[1] = streamReadBool(streamId)
	self.vehicle.spec_faultData.service[2] = streamReadBool(streamId)
	self.vehicle.spec_faultData.service[3] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.service[4] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.service[5] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.service[6] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.service[7] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.service[8] = streamReadFloat32(streamId)


	self:run(connection)
end

function RVBService_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	streamWriteBool(streamId, self.vehicle.spec_faultData.service[1])
	streamWriteBool(streamId, self.vehicle.spec_faultData.service[2])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.service[3])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.service[4])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.service[5])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.service[6])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.service[7])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.service[8])

end

function RVBService_Event:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        VehicleBreakdowns.SyncClientServer_RVBService(self.vehicle, unpack(self.vehicle.spec_faultData.service))
		self.vehicle.spec_faultData.service = { unpack(self.vehicle.spec_faultData.service) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBService_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.service)), nil, connection, self.vehicle)
    end
	
end

function RVBService_Event.sendEvent( vehicle, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, noEventSend )
	local service = { r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVBService_Event.new(vehicle, unpack(service)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVBService_Event.new(vehicle, unpack(service)))
		end
	end
end