
VehicleDamageUpdate_Event = {}

local VehicleDamageUpdate_Event_mt = Class(VehicleDamageUpdate_Event, Event)
InitEventClass(VehicleDamageUpdate_Event, "VehicleDamageUpdate_Event")

-- Esemény létrehozása
function VehicleDamageUpdate_Event:emptyNew()
    local self = Event:new(VehicleDamageUpdate_Event_mt)
    return self
end

-- Új esemény létrehozása (személyre szabott paraméterekkel)
function VehicleDamageUpdate_Event:new(vehicle, damageAmount)
    local self = VehicleDamageUpdate_Event.emptyNew()
    if damageAmount == nil then
        print("Hiba: damageAmount értéke nil!")
    else
        print("damageAmount értéke: " .. tostring(damageAmount))  -- Debug
    end
    self.vehicle = vehicle
    self.damageAmount = damageAmount
    return self
end


-- Adatok beolvasása a streamből
function VehicleDamageUpdate_Event:readStream(streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)  -- Jármű objektum beolvasása
    self.damageAmount = streamReadFloat32(streamId)       -- Sérülés mértékének beolvasása
	self:run(connection)
end

-- Adatok írása a streambe
function VehicleDamageUpdate_Event:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle)  -- Jármű objektum írása
    streamWriteFloat32(streamId, self.damageAmount)      -- Sérülés mértékének írása
end

-- Esemény futtatása (kliens oldalon frissíteni a sérülés mértékét)
function VehicleDamageUpdate_Event:run()
    if self.vehicle ~= nil then
        self.vehicle:setDamageAmount(self.damageAmount)  -- Sérülés mértékének beállítása
		print("VehicleDamageUpdate_Event:run self.damageAmount "..self.damageAmount)
    end
end
