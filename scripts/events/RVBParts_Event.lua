
RVBParts_Event = {}
local RVBParts_Event_mt = Class(RVBParts_Event, Event)

InitEventClass(RVBParts_Event, "RVBParts_Event")

function RVBParts_Event.emptyNew()
  local self = Event.new(RVBParts_Event_mt)
  return self
end

function RVBParts_Event.new(vehicle, p1, p2, p3, p4, p5, p6, p7, p8 )
	local parts = { p1, p2, p3, p4, p5, p6, p7, p8 }
	local self = RVBParts_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.parts = { unpack(parts) }

	return self
end

function RVBParts_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)
	for i=1, #self.vehicle.spec_faultData.parts do
		self.vehicle.spec_faultData.parts[i].name = streamReadString(streamId)
		self.vehicle.spec_faultData.parts[i].lifetime = streamReadInt16(streamId)
		self.vehicle.spec_faultData.parts[i].tmp_lifetime = streamReadInt16(streamId)
		self.vehicle.spec_faultData.parts[i].operatingHours = streamReadFloat32(streamId)
		self.vehicle.spec_faultData.parts[i].repairreq = streamReadBool(streamId)
		self.vehicle.spec_faultData.parts[i].amount = streamReadFloat32(streamId)
		self.vehicle.spec_faultData.parts[i].cost = streamReadFloat32(streamId)
	end
	self:run(connection)
end

function RVBParts_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	for i=1, #self.vehicle.spec_faultData.parts do
		streamWriteString(streamId, self.vehicle.spec_faultData.parts[i].name)
		streamWriteInt16(streamId, self.vehicle.spec_faultData.parts[i].lifetime)
		streamWriteInt16(streamId, self.vehicle.spec_faultData.parts[i].tmp_lifetime)
		streamWriteFloat32(streamId, self.vehicle.spec_faultData.parts[i].operatingHours)
		streamWriteBool(streamId, self.vehicle.spec_faultData.parts[i].repairreq)
		streamWriteFloat32(streamId, self.vehicle.spec_faultData.parts[i].amount)
		streamWriteFloat32(streamId, self.vehicle.spec_faultData.parts[i].cost)
	end

end

function RVBParts_Event:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        VehicleBreakdowns.SyncClientServer_RVBParts(self.vehicle, unpack(self.vehicle.spec_faultData.parts))
		self.vehicle.spec_faultData.parts = { unpack(self.vehicle.spec_faultData.parts) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBParts_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.parts)), nil, connection, self.vehicle)
    end
	
end

function RVBParts_Event.sendEvent( vehicle, p1, p2, p3, p4, p5, p6, p7, p8, noEventSend )
	local parts = { p1, p2, p3, p4, p5, p6, p7, p8 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVBParts_Event.new(vehicle, unpack(parts)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVBParts_Event.new(vehicle, unpack(parts)))
		end
	end
end