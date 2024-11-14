
RVBBattery_Event = {}
local RVBBattery_Event_mt = Class(RVBBattery_Event, Event)

InitEventClass(RVBBattery_Event, "RVBBattery_Event")

function RVBBattery_Event.emptyNew()
  local self = Event.new(RVBBattery_Event_mt)
  return self
end

function RVBBattery_Event.new(vehicle, b1, b2, b3, b4, b5, b6, b7 )
	local battery = { b1, b2, b3, b4, b5, b6, b7 }
	local self = RVBBattery_Event.emptyNew()

	self.vehicle = vehicle
	self.vehicle.spec_faultData.battery = { unpack(battery) }

	return self
end

function RVBBattery_Event:readStream(streamId, connection)

	self.vehicle = NetworkUtil.readNodeObject(streamId)

	self.vehicle.spec_faultData.battery[1] = streamReadBool(streamId)
	self.vehicle.spec_faultData.battery[2] = streamReadBool(streamId)
	self.vehicle.spec_faultData.battery[3] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.battery[4] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.battery[5] = streamReadInt16(streamId)
	self.vehicle.spec_faultData.battery[6] = streamReadFloat32(streamId)
	self.vehicle.spec_faultData.battery[7] = streamReadFloat32(streamId)

	self:run(connection)
end

function RVBBattery_Event:writeStream(streamId, connection)

	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	
	streamWriteBool(streamId, self.vehicle.spec_faultData.battery[1])
	streamWriteBool(streamId, self.vehicle.spec_faultData.battery[2])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.battery[3])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.battery[4])
	streamWriteInt16(streamId, self.vehicle.spec_faultData.battery[5])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.battery[6])
	streamWriteFloat32(streamId, self.vehicle.spec_faultData.battery[7])

end

function RVBBattery_Event:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then
        VehicleBreakdowns.SyncClientServer_RVBBattery(self.vehicle, unpack(self.vehicle.spec_faultData.battery))
		--self.vehicle.spec_faultData.battery = { unpack(self.vehicle.spec_faultData.battery) }
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(RVBBattery_Event.new(self.vehicle, unpack(self.vehicle.spec_faultData.battery)), nil, connection, self.vehicle)
    end
	
end

function RVBBattery_Event.sendEvent( vehicle, b1, b2, b3, b4, b5, b6, b7, noEventSend )
	local battery = { b1, b2, b3, b4, b5, b6, b7 }
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(RVBBattery_Event.new(vehicle, unpack(battery)), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(RVBBattery_Event.new(vehicle, unpack(battery)))
		end
	end
end