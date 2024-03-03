
RVBRepair_Event = {}
local RVBRepair_Event_mt = Class(RVBRepair_Event, Event)

InitEventClass(RVBRepair_Event, "RVBRepair_Event")

function RVBRepair_Event.emptyNew()
  local self = Event.new(RVBRepair_Event_mt)
  return self
end

function RVBRepair_Event.new(vehicle, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 )
	local repair = { r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 }
	local self = RVBRepair_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.repair = { unpack(repair) }

	return self
end

function RVBRepair_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)

	self.vehicle.spec_faultData.repair[1] = streamReadBool(streamId)
	self.vehicle.spec_faultData.repair[2] = streamReadBool(streamId)
	self.vehicle.spec_faultData.repair[3] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.repair[4] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.repair[5] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.repair[6] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.repair[7] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.repair[8] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.repair[9] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.repair[10] = streamReadBool(streamId)

	self:run(connection)
end

function RVBRepair_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	streamWriteBool(streamId, self.vehicle.spec_faultData.repair[1])
	streamWriteBool(streamId, self.vehicle.spec_faultData.repair[2])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.repair[3])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.repair[4])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.repair[5])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.repair[6])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.repair[7])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.repair[8])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.repair[9])
	streamWriteBool(streamId, self.vehicle.spec_faultData.repair[10])

end

function RVBRepair_Event:run(connection)

  if g_server == nil then
	self.vehicle.spec_faultData.repair = { unpack(self.vehicle.spec_faultData.repair) }
  end

  if not connection:getIsServer() then
    g_server:broadcastEvent(RVBRepair_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.repair)), nil, connection, self.vehicle)
  end
  
end

function RVBRepair_Event.sendEvent( vehicle, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 )
  local repair = { r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 }

  if g_server ~= nil then
    g_server:broadcastEvent(RVBRepair_Event.new(vehicle, unpack(repair)), nil, nil, vehicle)
  else
    g_client:getServerConnection():sendEvent(RVBRepair_Event.new(vehicle, unpack(repair)))
  end
end