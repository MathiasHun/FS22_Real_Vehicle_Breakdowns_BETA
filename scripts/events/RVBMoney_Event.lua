
RVBMoney_Event = {}

local RVBMoney_Event_mt = Class(RVBMoney_Event, Event)
InitEventClass(RVBMoney_Event, "RVBMoney_Event")

function RVBMoney_Event.emptyNew()
    local self = Event.new(RVBMoney_Event_mt)

    return self
end

function RVBMoney_Event.new(amount, farmId, moneyType)
    local self = RVBMoney_Event.emptyNew()

    self.amount = amount
    self.farmId = farmId
    self.moneyTypeId = moneyType.id

    return self
end

function RVBMoney_Event:readStream(streamId, connection)
    self.amount = streamReadInt32(streamId)
    self.farmId = streamReadInt32(streamId, 0)
    self.moneyTypeId = streamReadInt32(streamId, MoneyType.VEHICLE_REPAIR.id)

    self:run(connection)
end

function RVBMoney_Event:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.amount)
    streamWriteInt32(streamId, self.farmId, 0)
    streamWriteInt32(streamId, self.moneyTypeId, MoneyType.VEHICLE_REPAIR.id)
end

function RVBMoney_Event:run(connection)
    if not connection:getIsServer() then
        local moneyType = MoneyType.getMoneyTypeById(self.moneyTypeId)
		VehicleBreakdowns:RVBaddRemoveMoney(self.amount, self.farmId, moneyType)
    end
end