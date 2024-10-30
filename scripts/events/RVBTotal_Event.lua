
RVBTotal_Event = {}
local RVBTotal_Event_mt = Class(RVBTotal_Event, Event)

InitEventClass(RVBTotal_Event, "RVBTotal_Event")

function RVBTotal_Event.emptyNew()
	local self = Event.new(RVBTotal_Event_mt)
	return self
end

function RVBTotal_Event.new(vehicle, r1, r2, r3, r4, r5 )
	local rvb = { r1, r2, r3, r4, r5 }
	local self = RVBTotal_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.rvb = { unpack(rvb) }

	return self
end

function RVBTotal_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)

	self.vehicle.spec_faultData.rvb[1] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.rvb[2] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.rvb[3] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.rvb[4] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.rvb[5] = streamReadFloat32(streamId)

	self:run(connection)
end

function RVBTotal_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	streamWriteInt16(streamId, self.vehicle.spec_faultData.rvb[1])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.rvb[2])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.rvb[3])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.rvb[4])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.rvb[5])

end

function RVBTotal_Event:run(connection)
	if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
		VehicleBreakdowns.SyncClientServer_RVB(self.vehicle, unpack(self.vehicle.spec_faultData.rvb))
		self.vehicle.spec_faultData.rvb = { unpack(self.vehicle.spec_faultData.rvb) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBTotal_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.rvb)), nil, connection, self.vehicle)
	end

end

function RVBTotal_Event.sendEvent( vehicle, r1, r2, r3, r4, r5, noEventSend )
	local rvb = { r1, r2, r3, r4, r5 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVBTotal_Event.new(vehicle, unpack(rvb)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVBTotal_Event.new(vehicle, unpack(rvb)))
		end
	end
end