
RVBInspection_Event = {}
local RVBInspection_Event_mt = Class(RVBInspection_Event, Event)

InitEventClass(RVBInspection_Event, "RVBInspection_Event")

function RVBInspection_Event.emptyNew()
  local self = Event.new(RVBInspection_Event_mt)
  return self
end

function RVBInspection_Event.new(vehicle, i1, i2, i3, i4, i5, i6, i7, i8 )
	local inspection = { i1, i2, i3, i4, i5, i6, i7, i8 }
	local self = RVBInspection_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.inspection = { unpack(inspection) }

	return self
end

function RVBInspection_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)

	self.vehicle.spec_faultData.inspection[1] = streamReadBool(streamId)
	self.vehicle.spec_faultData.inspection[2] = streamReadBool(streamId)
	self.vehicle.spec_faultData.inspection[3] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.inspection[4] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.inspection[5] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.inspection[6] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.inspection[7] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.inspection[8] = streamReadBool(streamId)

	self:run(connection)
end

function RVBInspection_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	streamWriteBool(streamId, self.vehicle.spec_faultData.inspection[1])
	streamWriteBool(streamId, self.vehicle.spec_faultData.inspection[2])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.inspection[3])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.inspection[4])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.inspection[5])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.inspection[6])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.inspection[7])
	streamWriteBool(streamId, self.vehicle.spec_faultData.inspection[8])

end

function RVBInspection_Event:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        VehicleBreakdowns.SyncClientServer_RVBInspection(self.vehicle, unpack(self.vehicle.spec_faultData.inspection))
		--self.vehicle.spec_faultData.inspection = { unpack(self.vehicle.spec_faultData.inspection) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBInspection_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.inspection)), nil, connection, self.vehicle)
    end
	
end

function RVBInspection_Event.sendEvent( vehicle, i1, i2, i3, i4, i5, i6, i7, i8, noEventSend )
	local inspection = { i1, i2, i3, i4, i5, i6, i7, i8 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVBInspection_Event.new(vehicle, unpack(inspection)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVBInspection_Event.new(vehicle, unpack(inspection)))
		end
	end
end