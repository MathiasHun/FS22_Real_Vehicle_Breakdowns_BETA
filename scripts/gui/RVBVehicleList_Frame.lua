
RVBVehicleList_Frame = {}
local RVBVehicleList_Frame_mt = Class(RVBVehicleList_Frame, TabbedMenuFrameElement)

RVBVehicleList_Frame.CONTROLS = {"vehicleList", "vehicleIcon", "vehicleDetail", "settingsContainer", "boxLayout", "infoBoxText", "partsListTitle", "partsListBox", "partsList",
								"checkedThermostatPartToggle", "checkedLightingsPartToggle", "checkedGlowPlugPartToggle", "checkedWipersPartToggle", "checkedGeneratorPartToggle", "checkedEnginePartToggle", "checkedSelfstarterPartToggle", "checkedBatteryPartToggle",
								"THERMOSTAT", "LIGHTINGS", "GLOWPLUG", "WIPERS", "GENERATOR", "ENGINE", "SELFSTARTER", "BATTERY" }

function RVBVehicleList_Frame.new(rvbMain, modName)
	local self = TabbedMenuFrameElement.new(nil, RVBVehicleList_Frame_mt)

	self:registerControls(RVBVehicleList_Frame.CONTROLS)

	self.rvbMain         = rvbMain
	self.modName         = modName
	self.i18n            = g_i18n.modEnvironments[g_vehicleBreakdownsModName]
	self.vehicles        = {}
	self.messageCenter   = g_messageCenter
	self.GPSET           = g_currentMission.vehicleBreakdowns.gameplaySettings
	self.listSort        = "base"
	self.listVehicle	 = "vehicle"
	self.vehicle         = nil

	return self
end

function RVBVehicleList_Frame:copyAttributes(src)
	RVBVehicleList_Frame:superClass().copyAttributes(self, src)
	self.rvbMain = src.rvbMain
	self.modName = src.modName
	self.i18n = g_i18n.modEnvironments[self.modName]
end

function RVBVehicleList_Frame:onFrameOpen()

	RVBVehicleList_Frame:superClass().onFrameOpen(self)

	if g_currentMission.environment.currentHour < tonumber(self.rvbMain:getIsWorkshopOpen()) and g_currentMission.environment.currentHour > tonumber(self.rvbMain:getIsWorkshopClose()) then
		local timeText = string.format("%02d:%02d", self.rvbMain:getIsWorkshopOpen(), 0)
		self.onOpenInfoText = string.format(g_i18n:getText("RVB_WorkShopClose"), timeText)
	end

	if self.onOpenInfoText == nil then
		self.hasInfoText = false
		self.infoBoxText:setText("")
	else
		self.infoBoxText:setText(self.onOpenInfoText)
		self.onOpenInfoText = nil
	end

	self:rebuildTableList()

	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.vehicleList)
		self:setSoundSuppressed(false)
	end

	self.messageCenter:subscribe(SellVehicleEvent, self.onRefreshEvent, self)
	self.messageCenter:subscribe(MessageType.VEHICLE_REPAIRED, self.onRefreshEvent, self)
	self.messageCenter:subscribe(MessageType.VEHICLE_REPAINTED, self.onRefreshEvent, self)

end
	
function RVBVehicleList_Frame:setInfoText(text)
	if text ~= nil then
		if self.infoBoxText.text ~= text then
			self.infoBoxText:setText(text)
		end

		if text ~= "" then
			self.updateTimeInfoText = g_currentMission.time + 10000
			self.hasInfoText = true
		end
	else
		self.hasInfoText = false
		self.infoBoxText:setText("")
	end
end

function RVBVehicleList_Frame:update(dt)
	RVBVehicleList_Frame:superClass().update(self, dt)

	if self.hasInfoText and g_currentMission ~= nil then
		if g_currentMission.time > self.updateTimeInfoText then
			self.infoBoxText:setText("")
			self.hasInfoText = false
		end
	end

end

function RVBVehicleList_Frame:onFrameClose()
	RVBVehicleList_Frame:superClass().onFrameClose(self)
	--self:onSave()
	self.vehicles = {}
	self.vehicle = nil
	self.messageCenter:unsubscribeAll(self)
	--g_messageCenter:unsubscribeAll(self)
	g_currentMission:showMoneyChange(MoneyType.SHOP_VEHICLE_SELL)
end

function RVBVehicleList_Frame:initialize()

	self.backButtonInfo = {inputAction = InputAction.MENU_BACK}

	self.inspectionButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.ACTIVATE_OBJECT,
		text        = g_i18n:getText("RVB_button_inspection"),
		callback    = function ()
			self:onButtonInspectionVehicle()
		end
	}
	
	self.repairButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_EXTRA_2,
		text        = g_i18n:getText("button_repair"),
		callback    = function ()
			self:onButtonRepairVehicle()
		end
	}
	
	self.periodicServiceButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.TOGGLE_STORE,
		text        = g_i18n:getText("RVB_button_periodicservice"),
		callback    = function ()
			self:onButtonPeriodicService()
		end
	}

	self.batteryChargingButton = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_CANCEL,
		text        = g_i18n:getText("RVB_button_battery_ch"),
		callback    = function ()
			self:onButtonBatteryCharging()
		end
	}
	
	self.entervehicleButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_ACCEPT,
		text        = g_i18n:getText("button_enterVehicle"),
		callback    = function ()
			self:onButtonEnterVehicle()
		end
	}

	local hpsort_text = ""
	if self.listSort == "base" then
		hpsort_text = "Hp Asc"
	elseif self.listSort == "hpAsc" then
		hpsort_text = "Hp Desc"
	elseif self.listSort == "hpDesc" then
		hpsort_text = "Hp Asc"
	end
	self.hpAscSortButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.TOGGLE_WIPER,
		text        = hpsort_text,
		callback    = function ()
			self:onButtonHpAscSort()
		end
	}
	
	local vehicle_text = ""
	if self.listVehicle == "all" then
		vehicle_text = g_i18n:getText("RVB_button_vehicles")
	elseif self.listVehicle == "vehicle" then
		vehicle_text = g_i18n:getText("RVB_button_vehiclesandequipment")
	end
	self.vehicleOnlyButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.TOGGLE_LIGHTS,
		text        = vehicle_text,
		callback    = function ()
			self:onButtonvehicleOnly()
		end
	}

	self.configScreenButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_ACTIVATE,
		text        = g_i18n:getText("button_configurate"),
		callback    = function ()
			self:onClickConfigure()
		end
	}

	self.sellButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.TOGGLE_PIPE,
		text        = g_i18n:getText("button_sell"),
		callback    = function ()
			self:onButtonSellVehicle()
		end
	}
	
	self.repaintButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.RADIO_TOGGLE,
		text        = g_i18n:getText("button_repaint"),
		callback    = function ()
			self:onButtonRepaintVehicle()
		end
	}
	
	self.partsListTitle:setVisible(false)
	self.partsListBox:setVisible(false)
	--self.infoBoxText:setVisible(false)

end


function RVBVehicleList_Frame:onClickConfigure()
	
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	--self.vehicle = self_vehicle
	
	if g_workshopScreen.canBeConfigured then
		local changePrice = EconomyManager.CONFIG_CHANGE_PRICE

		if g_workshopScreen.isOwnWorkshop then
			changePrice = 0
		end

		local vehicle = self_vehicle
		local storeItem = g_workshopScreen.storeItem

		self:changeScreen(ShopConfigScreen, nil, "RVBTabbedMenu")
		g_shopConfigScreen:setReturnScreen("RVBTabbedMenu")
		g_shopConfigScreen:setStoreItem(storeItem, vehicle, nil, changePrice)
		g_shopConfigScreen:setCallbacks(g_workshopScreen.setConfigurations, g_workshopScreen)

		return false
	end

	return true

end

function RVBVehicleList_Frame:onButtonSellVehicle()
    local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
    local isLeased      = self_vehicle.propertyState == Vehicle.PROPERTY_STATE_LEASED
    local l10nText      = "ui_youWantToSellVehicle"

    if isLeased then
        l10nText = "ui_youWantToReturnVehicle"
    end

    g_gui:showYesNoDialog({
        text      = g_i18n:getText(l10nText),
        callback  = self.onYesNoSellDialog,
        target    = self,
        yesButton = g_i18n:getText("button_yes"),
        noButton  = g_i18n:getText("button_cancel")
    })
end

function RVBVehicleList_Frame:onYesNoSellDialog(yes)
    if yes then
		local selectedIndex = self.vehicleList.selectedIndex
		local self_vehicle  = self.vehicles[selectedIndex]

		--g_client:getServerConnection():sendEvent(SellVehicleEvent.new(self_vehicle, EconomyManager.DIRECT_SELL_MULTIPLIER, true))
		g_client:getServerConnection():sendEvent(SellVehicleEvent.new(self_vehicle, 1, true))

    end
end

function RVBVehicleList_Frame:onButtonRepaintVehicle()
    local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]

    if self_vehicle ~= nil and self_vehicle:getRepaintPrice() >= 1 then
        g_gui:showYesNoDialog({
            text     = string.format(g_i18n:getText("ui_repaintDialog"), g_i18n:formatMoney(self_vehicle:getRepaintPrice())),
            callback = self.onYesNoRepaintDialog,
            target   = self,
            yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_SPRAY
        })

        return true
    else
        return false
    end
end

function RVBVehicleList_Frame:onYesNoRepaintDialog(yes)
    
    if yes then
		local selectedIndex = self.vehicleList.selectedIndex
		local self_vehicle  = self.vehicles[selectedIndex]
        if g_currentMission:getMoney() < self_vehicle:getRepaintPrice() then
            g_gui:showInfoDialog({
                text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
            })
        else
            g_client:getServerConnection():sendEvent(WearableRepaintEvent.new(self_vehicle, true))
        end
    end
end

function RVBVehicleList_Frame:onButtonInspectionVehicle()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec			= self_vehicle.spec_faultData

	if self_vehicle ~= nil and spec ~= nil then

		local AddHour = math.floor(VehicleBreakdowns.IRSBTimes[10] / 3600)
		local AddMinute = math.floor(((VehicleBreakdowns.IRSBTimes[10] / 3600) - AddHour) * 60)
		local FinishDay, FinishHour, FinishMinute = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
		local timeText = string.format("%02d:%02d", FinishHour, FinishMinute)

		local DialogInspectionText = "RVB_inspectionTimeDialog"
		if FinishDay > g_currentMission.environment.currentDay then
			DialogInspectionText = "RVB_inspectionDayDialog"
		end

		g_gui:showYesNoDialog({
			text	 = string.format(g_i18n:getText("RVB_inspectionDialog"), g_i18n:formatMoney(self_vehicle:getInspectionPrice(true))).."\n"..
					   string.format(g_i18n:getText(DialogInspectionText), timeText),
			callback = self.onYesNoInspectionDialog,
			target   = self,
			yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
		})

		return true

	end

end

function RVBVehicleList_Frame:onButtonRepairVehicle()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec			= self_vehicle.spec_faultData

	if self_vehicle ~= nil and spec ~= nil and self_vehicle:getRepairPrice_RVBClone(true) >= 1 then

		local faultListTime = 0
		local faultListText = {}
		for i=1, #spec.parts do
			if spec.parts[i].repairreq then
				table.insert(faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[i]))
				faultListTime = faultListTime + VehicleBreakdowns.IRSBTimes[i]
			end
		end
			
		local AddHour = math.floor(faultListTime / 3600)
		local AddMinute = math.floor(((faultListTime / 3600) - AddHour) * 60)
		local FinishDay, FinishHour, FinishMinute = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)

		local timeText = string.format("%02d:%02d", FinishHour, FinishMinute)

		local DialogRepairText = "RVB_repairTimeDialog"
		if FinishDay > g_currentMission.environment.currentDay then
			DialogRepairText = "RVB_repairDayDialog"
		end

		if table.maxn(faultListText) > 0 then
			g_gui:showYesNoDialog({
				text     = string.format(g_i18n:getText("ui_repairDialog"), g_i18n:formatMoney(self_vehicle:getRepairPrice_RVBClone(true))).."\n"..
				string.format(g_i18n:getText(DialogRepairText), timeText).."\n"..g_i18n:getText("RVB_ErrorList").."\n"..table.concat(faultListText,", "),
				callback = self.onYesNoRepairDialog,
				target   = self,
				yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
			})
		end

		return true

	end

	if self_vehicle ~= nil and spec == nil and self_vehicle:getRepairPrice(true) >= 1 then

		g_gui:showYesNoDialog({
			text     = string.format(g_i18n:getText("ui_repairDialog"), g_i18n:formatMoney(self_vehicle:getRepairPrice(true))),
			callback = self.onYesNoRepairDialog,
			target   = self,
			yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
		})

		return true
	else
		return false
	end

end

function RVBVehicleList_Frame:onButtonPeriodicService()
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle   = self.vehicles[selectedIndex]
	local spec			 = self_vehicle.spec_faultData

	if self_vehicle ~= nil and not spec.service[1] then
	
		local moreservice = 1
		local servicePeriodic = math.floor(spec.rvb[4])

		if servicePeriodic > self.rvbMain:getIsIsPeriodicService() then
			moreservice = math.ceil(servicePeriodic - self.rvbMain:getIsIsPeriodicService())
		end
		local alap = 10800

		local serviceTime = alap + VehicleBreakdowns.IRSBTimes[9] * moreservice

		local AddHour = math.floor(serviceTime / 3600)
		local AddMinute = math.floor(((serviceTime / 3600) - AddHour) * 60)
		local FinishDay, FinishHour, FinishMinute = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)

		local timeText = string.format("%02d:%02d", FinishHour, FinishMinute)

		local DialogServiceText = "RVB_periodicserviceTimeDialog"
		if FinishDay > g_currentMission.environment.currentDay then
			DialogServiceText = "RVB_periodicserviceDayDialog"
		end

		g_gui:showYesNoDialog({
			text     = string.format(g_i18n:getText("RVB_periodicserviceDialog"), g_i18n:formatMoney(self_vehicle:getServicePrice(true))).."\n"..
					   string.format(g_i18n:getText(DialogServiceText), timeText),
			callback = self.onYesNoServiceDialog,
			target   = self,
			yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
		})

		return true
	else
		return false
	end
end

function RVBVehicleList_Frame:onButtonBatteryCharging()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]

	if self_vehicle ~= nil and self_vehicle:getIsFaultBattery() <= 0.30 then

		g_gui:showYesNoDialog({
			text     = string.format(g_i18n:getText("RVB_batteryChDialog"), g_i18n:formatMoney(5)),
			callback = self.onYesNoBatteryChDialog,
			target   = self,
			yesSound = GuiSoundPlayer.SOUND_SAMPLES.CONFIG_WRENCH
		})

		return true
	else
		return false
	end

end

function RVBVehicleList_Frame:onYesNoInspectionDialog(yes)
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec			= self_vehicle.spec_faultData

	if spec ~= nil and yes then

		if g_currentMission:getMoney() < self_vehicle:getInspectionPrice() then
			g_gui:showInfoDialog({
				text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
			})
		else

			local AddHour = math.floor(VehicleBreakdowns.IRSBTimes[10] / 3600)
			local AddMinute = math.floor(((VehicleBreakdowns.IRSBTimes[10] / 3600) - AddHour) * 60)

			spec.inspection[1] = true
			spec.inspection[2] = false
			spec.inspection[3], spec.inspection[4], spec.inspection[5] = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
			spec.inspection[6] = self_vehicle:getInspectionPrice()

			spec.rvb[1] = g_currentMission.missionInfo.timeScale

			--if self_vehicle.isServer then
			--elseif self_vehicle.isClient then
				RVBInspection_Event.sendEvent(self_vehicle, unpack(spec.inspection))
				RVBTotal_Event.sendEvent(self_vehicle, unpack(spec.rvb))
				self_vehicle:raiseDirtyFlags(spec.dirtyFlag)
			--end
			
			self_vehicle:StopAI(self_vehicle)
			self_vehicle:stopMotor()
			if self_vehicle.deactivateLights ~= nil then
				self_vehicle:deactivateLights()
			end
			local specm = self_vehicle.spec_motorized
			if specm.motor ~= nil then
				specm.motor:setGearShiftMode(specm.gearShiftMode)
			end
			
			self:rebuildTableList()

		end
	end

end

function RVBVehicleList_Frame:onYesNoRepairDialog(yes)
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec			= self_vehicle.spec_faultData

	if spec == nil and yes then
		if g_currentMission:getMoney() < self_vehicle:getRepairPrice() then
			g_gui:showInfoDialog({
				text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
			})
		else
			g_client:getServerConnection():sendEvent(WearableRepairEvent.new(self_vehicle, true))
		end
		self:rebuildTableList()
	end

	if spec ~= nil and yes then

		if g_currentMission:getMoney() < self_vehicle:getRepairPrice_RVBClone() then
			g_gui:showInfoDialog({
				text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
			})
		else

			local faultListTime = 0
			local fault = 0
			for i=1, #spec.parts do
				if spec.parts[i].repairreq then
					faultListTime = faultListTime + VehicleBreakdowns.IRSBTimes[i]
					fault = fault + 1
				end
			end

			local damage = self_vehicle.spec_wearable.damage
			local currentDamageLevel = math.ceil((1 - damage)*100)
			local AddHour = math.floor(faultListTime / 3600)
			local AddMinute = math.floor(((faultListTime / 3600) - AddHour) * 60)

			spec.repair[8] = fault
			spec.repair[1] = true
			spec.repair[2] = false
			spec.repair[3], spec.repair[4], spec.repair[5] = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
			spec.repair[6] = spec.repair[8] / faultListTime * 60
			spec.repair[7] = self_vehicle:getRepairPrice_RVBClone()

			local ageFactor = math.floor(self_vehicle.age / Environment.PERIODS_IN_YEAR)
			local stringformat = "0.0%s"
			local randfirst = 0
			if ageFactor <= 1 then
				randfirst = ageFactor
			elseif ageFactor > 1 and ageFactor < 6 then
				randfirst = ageFactor - 1
			elseif ageFactor > 5 and ageFactor < 10 then
				randfirst = ageFactor - 2
			elseif ageFactor > 9 then
				randfirst = ageFactor - 3
			end
			local stringformat = "0.0%s"
			local rand = math.random(randfirst, ageFactor)
			if rand > 9 then
				stringformat = "0.%s"
			end
			local randomfactor = math.ceil((1 - string.format(stringformat, rand)) * 100)
			if randomfactor <= currentDamageLevel then
				spec.repair[9] = 0
			elseif randomfactor > currentDamageLevel then
				spec.repair[9] = randomfactor - currentDamageLevel
			end

			spec.rvb[1] = g_currentMission.missionInfo.timeScale

			--if self_vehicle.isServer then
			--elseif self_vehicle.isClient then
				RVBRepair_Event.sendEvent(self_vehicle, unpack(spec.repair))
				RVBTotal_Event.sendEvent(self_vehicle, unpack(spec.rvb))
				self_vehicle:raiseDirtyFlags(spec.dirtyFlag)
			--end

			self_vehicle:StopAI(self_vehicle)
			self_vehicle:stopMotor()
			if self_vehicle.deactivateLights ~= nil then
				self_vehicle:deactivateLights()
			end
			local specm = self_vehicle.spec_motorized
			if specm.motor ~= nil then
				specm.motor:setGearShiftMode(specm.gearShiftMode)
			end

			self:rebuildTableList()

		end
	end
end

function RVBVehicleList_Frame:onYesNoServiceDialog(yes)
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec 			= self_vehicle.spec_faultData

	if yes then

		if g_currentMission:getMoney() < self_vehicle:getServicePrice() then
			g_gui:showInfoDialog({
				text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
			})
		else

			local moreservice = 1
			local servicePeriodic = math.floor(spec.rvb[4])

			if servicePeriodic > self.rvbMain:getIsIsPeriodicService() then
				moreservice = math.ceil(servicePeriodic - self.rvbMain:getIsIsPeriodicService())
			end

			local alap = 10800
			local RepairTime = (alap + (VehicleBreakdowns.IRSBTimes[10] * moreservice))	
			local AddHour = math.floor(RepairTime / 3600)
			local AddMinute = math.floor(((RepairTime / 3600) - AddHour) * 60)

			spec.service[8] = servicePeriodic

			spec.service[1] = true
			spec.service[2] = false
			spec.service[3], spec.service[4], spec.service[5] = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
			spec.service[6] = spec.service[8] / RepairTime * 60
			spec.service[7] = self_vehicle:getServicePrice()

			spec.rvb[1] = g_currentMission.missionInfo.timeScale

			--if self_vehicle.isServer then
			--elseif self_vehicle.isClient then
				RVBService_Event.sendEvent(self_vehicle, unpack(spec.service))
				RVBTotal_Event.sendEvent(self_vehicle, unpack(spec.rvb))
				self_vehicle:raiseDirtyFlags(spec.dirtyFlag)
			--end

			self_vehicle:StopAI(self_vehicle)
			self_vehicle:stopMotor()
			if self_vehicle.deactivateLights ~= nil then
				self_vehicle:deactivateLights()
			end
			local specm = self_vehicle.spec_motorized
			if specm.motor ~= nil then
				specm.motor:setGearShiftMode(specm.gearShiftMode)
			end

			self:rebuildTableList()

		end
	end
end


function RVBVehicleList_Frame:onYesNoBatteryChDialog(yes)
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec 			= self_vehicle.spec_faultData

	if yes then

		if g_currentMission:getMoney() < self:getBatteryChPrice() then
			g_gui:showInfoDialog({
				text = g_i18n:getText("shop_messageNotEnoughMoneyToBuy")
			})
		else

			g_client:getServerConnection():sendEvent(BatteryFillUnitFillLevelEvent.new(self_vehicle, true))

			self_vehicle:StopAI(self_vehicle)
			self_vehicle:stopMotor()
			if self_vehicle.deactivateLights ~= nil then
				self_vehicle:deactivateLights()
			end
			local specm = self_vehicle.spec_motorized
			if specm.motor ~= nil then
				specm.motor:setGearShiftMode(specm.gearShiftMode)
			end
	
		end
		
		self:rebuildTableList()

	end
end


function RVBVehicleList_Frame:getBatteryChPrice()
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	return self.calculateBatteryChPrice(300, spec.rvb[5])
end

function RVBVehicleList_Frame.calculateBatteryChPrice(price, charge)
	return price * math.pow(charge, 1.5) * 0.3
end

function RVBVehicleList_Frame:updateMenuButtons()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	
	self.menuButtonInfo = {
		{ inputAction = InputAction.MENU_BACK }
	}

	if self_vehicle ~= nil then
	
		local spec = self_vehicle.spec_faultData
		local isLeased      = self_vehicle.propertyState == Vehicle.PROPERTY_STATE_LEASED
		
		local repairPrice = 0
		if spec ~= nil then
			repairPrice = self_vehicle:getRepairPrice_RVBClone()
		else
			repairPrice = self_vehicle:getRepairPrice()
		end

		local servicePrice = 0
		if spec ~= nil then
			servicePrice = math.floor(spec.rvb[4])
		end

		local isBorrowed = self_vehicle.propertyState == Vehicle.PROPERTY_STATE_MISSION

		--local isMPGame = g_currentMission.missionDynamicInfo.isMultiplayer
		local batterycher = 0
		if spec ~= nil then
			batterycher = spec.rvb[5]
		end

		if spec ~= nil and self_vehicle.spec_motorized ~= nil and self_vehicle.getIsEntered ~= nil and not self_vehicle:getIsEntered() then
			table.insert(self.menuButtonInfo, self.entervehicleButtonInfo)
		end

		local hpsort_text = ""
		if self.listSort == "base" then
			hpsort_text = "Hp Asc"
		elseif self.listSort == "hpAsc" then
			hpsort_text = "Hp Desc"
		elseif self.listSort == "hpDesc" then
			hpsort_text = "Hp Asc"
		end
		self.hpAscSortButtonInfo.text = hpsort_text
		--table.insert(self.menuButtonInfo, self.hpAscSortButtonInfo)

		if g_currentMission:getHasPlayerPermission("farmManager") and not isBorrowed then

			if g_currentMission.environment.currentHour >= tonumber(self.rvbMain:getIsWorkshopOpen()) and g_currentMission.environment.currentHour < tonumber(self.rvbMain:getIsWorkshopClose()) then

				if spec ~= nil then
					--if spec.inspection ~= nil then
						--if not spec.repair[10] then
							if not spec.inspection[1] then
								self.inspectionButtonInfo.text = g_i18n:getText("RVB_button_inspection").." ("..g_i18n:formatMoney(self_vehicle:getInspectionPrice(true))..")"
								self.inspectionButtonInfo.disabled = false
							else
								self.inspectionButtonInfo.text = g_i18n:getText("RVB_button_inspection")
								self.inspectionButtonInfo.disabled = true
							end
							table.insert(self.menuButtonInfo, self.inspectionButtonInfo)
						--end

						if spec.inspection[8] then 
							if not spec.repair[1] and repairPrice > 1 then
								self.repairButtonInfo.text = g_i18n:getText("button_repair").." ("..g_i18n:formatMoney(self_vehicle:getRepairPrice_RVBClone(true))..")"
								self.repairButtonInfo.disabled = false
							else
								self.repairButtonInfo.text = g_i18n:getText("button_repair")
								self.repairButtonInfo.disabled = true
							end
							table.insert(self.menuButtonInfo, self.repairButtonInfo)
						end
					--end

				end

				if spec == nil and repairPrice > 1 then
					self.repairButtonInfo.text = g_i18n:getText("button_repair").." ("..g_i18n:formatMoney(self_vehicle:getRepairPrice(true))..")"
					self.repairButtonInfo.disabled = false
					table.insert(self.menuButtonInfo, self.repairButtonInfo)
				elseif spec == nil and repairPrice <= 1 then
					self.repairButtonInfo.text = g_i18n:getText("button_repair")
					self.repairButtonInfo.disabled = true
					table.insert(self.menuButtonInfo, self.repairButtonInfo)
				end

				if spec ~= nil then
					if spec.service ~= nil then
						if not spec.service[1] and servicePrice > 10 then
							self.periodicServiceButtonInfo.text = g_i18n:getText("RVB_button_periodicservice").." ("..g_i18n:formatMoney(self_vehicle:getServicePrice(true))..")"
							self.periodicServiceButtonInfo.disabled = false
						else
							self.periodicServiceButtonInfo.text = g_i18n:getText("RVB_button_periodicservice")
							self.periodicServiceButtonInfo.disabled = true
						end
						table.insert(self.menuButtonInfo, self.periodicServiceButtonInfo)
					end
				end

				if spec ~= nil and self_vehicle:getIsFaultBattery() ~= nil then
					if self_vehicle:getIsFaultBattery() <= 0.30 then
						self.batteryChargingButton.disabled = false
					else
						self.batteryChargingButton.disabled = true
					end
					self.batteryChargingButton.text = g_i18n:getText("RVB_button_battery_ch")
					table.insert(self.menuButtonInfo, self.batteryChargingButton)
				end

			else
				local timeText = string.format("%02d:%02d", self.rvbMain:getIsWorkshopOpen(), 0)
				self:setInfoText(string.format(g_i18n:getText("RVB_WorkShopClose"), timeText))
			end

            if not isLeased then
                self.sellButtonInfo.text = g_i18n:getText("button_sell")
            else
                self.sellButtonInfo.text  = g_i18n:getText("button_return")
            end
            table.insert(self.menuButtonInfo, self.sellButtonInfo)

			local repaintPrice = self_vehicle:getRepaintPrice() --* EconomyManager.DIRECT_SELL_MULTIPLIER
			if repaintPrice >= 1 then
				self.repaintButtonInfo.text  = string.format("%s (%s)", g_i18n:getText("button_repaint"), g_i18n:formatMoney(repaintPrice, 0, true, true))
			else
				self.repaintButtonInfo.text  = g_i18n:getText("button_repaint")
			end

			self.repaintButtonInfo.disabled = repaintPrice < 1 or self_vehicle.propertyState == Vehicle.PROPERTY_STATE_MISSION
			table.insert(self.menuButtonInfo, self.repaintButtonInfo)

		end

		if g_workshopScreen.canBeConfigured then
			self.configScreenButtonInfo.disabled = false
		end
		table.insert(self.menuButtonInfo, self.configScreenButtonInfo)
		
		local vehicle_text = ""
		if self.listVehicle == "all" then
			vehicle_text = g_i18n:getText("RVB_button_vehicles")
		elseif self.listVehicle == "vehicle" then
			vehicle_text = g_i18n:getText("RVB_button_vehiclesandequipment")
		end
		self.vehicleOnlyButtonInfo.text = vehicle_text
		table.insert(self.menuButtonInfo, self.vehicleOnlyButtonInfo)
		
	end

	self:setMenuButtonInfoDirty()

end

function RVBVehicleList_Frame:onGuiSetupFinished()
	RVBVehicleList_Frame:superClass().onGuiSetupFinished(self)
	self.vehicleList:setDataSource(self)
	self.vehicleDetail:setDataSource(self)
end

function RVBVehicleList_Frame:delete()
	RVBVehicleList_Frame:superClass().delete(self)
	self.messageCenter:unsubscribeAll(self)
end

function RVBVehicleList_Frame:onRefreshEvent()
	self:rebuildTableList()
end

function RVBVehicleList_Frame:onButtonEnterVehicle()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local isConned      = self_vehicle.getIsControlled ~= nil and self_vehicle:getIsControlled()
	
	if not isConned then
		g_gui:showGui("")
		if self_vehicle ~= nil then
			g_currentMission:requestToEnterVehicle(self_vehicle)
		end
	elseif self_vehicle.spec_enterable.controllerUserId == g_currentMission.playerUserId then
		g_gui:showGui("")
	else
		g_gui:showInfoDialog({
			text = g_i18n:getText("RVB_occupied")
		})
	end
	
end

function RVBVehicleList_Frame:onButtonHpAscSort()

	if self.listSort == "base" then
		self.listSort = "hpAsc"
	elseif self.listSort == "hpAsc" then
		self.listSort = "hpDesc"
	elseif self.listSort == "hpDesc" then
		self.listSort = "hpAsc"
	end
	self:rebuildTableList()
	
end

function RVBVehicleList_Frame:onButtonvehicleOnly()

	if self.listVehicle == "all" then
		self.listVehicle = "vehicle"
	elseif self.listVehicle == "vehicle" then
		self.listVehicle = "all"

	end
	self:rebuildTableList()
	
end


function RVBVehicleList_Frame:rebuildTableList()

	self.vehicles = {}

	if g_currentMission.player ~= nil then

		if self.rvbMain:getIsRepairShop() then
		
			for index, repairTrigger in pairs(VehicleBreakdowns.getShapesInRange()) do

				local playerFarmId = g_currentMission:getFarmId()
				if playerFarmId ~= FarmManager.SPECTATOR_FARM_ID then
		
					-- Find first vehicle, then get its rood and all children
					for shapeId, inRange in pairs(repairTrigger.vehicleShapesInRange) do
						if inRange ~= nil and entityExists(shapeId) then
							local vehicle = g_currentMission.nodeToObject[shapeId]
							if vehicle ~= nil then

								local isRidable = SpecializationUtil.hasSpecialization(Rideable, vehicle.specializations)

								if not isRidable and not vehicle.isPallet and vehicle.getSellPrice ~= nil and vehicle.price ~= nil and vehicle.typeName ~= "FS22_ToolBoxPack.service"
									and vehicle.typeName ~= "FS22_twine_addon.palletAttachable" and vehicle.typeName ~= "FS22_netWrap_addon_modland.palletAttachable" and vehicle.typeName ~= "FS22_lsfmFarmEquipmentPack.portableToolbox" then
									if self.listVehicle == "all" then
										local items = vehicle.rootVehicle:getChildVehicles()

										for _, item in ipairs(items) do
											local ownerFarmId = item:getOwnerFarmId()
											-- only show owned items
											if ownerFarmId == playerFarmId then
												-- uniqueness check builtin
												table.addElement(self.vehicles, item)
											end
										end

									end
									
									local isSteerImplement = vehicle.spec_attachable ~= nil
									local hasConned        = vehicle.getIsControlled ~= nil
									if self.listVehicle == "vehicle" and not isSteerImplement and hasConned then
										table.addElement(self.vehicles, vehicle)
									end
									
								end
							end
						else
							repairTrigger.vehicleShapesInRange[shapeId] = nil
						end
					end

					-- Consistent order independent on which piece of the vehicle entered the trigger first
					table.sort(self.vehicles, function(a, b)
						return a.rootNode < b.rootNode
					end)
					
					for i = 1, #self.vehicles do
						local self_vehicle = self.vehicles[i]
						local spec = self_vehicle.spec_faultData
						if spec ~= nil and self_vehicle.spec_motorized ~= nil and self_vehicle.getIsEntered ~= nil and self_vehicle:getIsEntered() then
							self.vehicleList.selectedIndex = i
							self.vehicleList.selectedSectionIndex = i
							self.vehicleList.selectOnScroll = true
							self.vehicleDetail.selectedIndex = i
							self.vehicleDetail.selectedSectionIndex = i
						end
					end
					
				end
				
			end
			
		else
	
			for _, vehicle in ipairs(g_currentMission.vehicles) do

				if vehicle ~= nil and vehicle.typeName ~= "locomotive" and vehicle.typeName ~= "trainTrailer" and vehicle.typeName ~= "trainTimberTrailer" and vehicle.typeName ~= "FS22_ToolBoxPack.service" 
					and vehicle.typeName ~= "FS22_twine_addon.palletAttachable" and vehicle.typeName ~= "FS22_netWrap_addon_modland.palletAttachable" and vehicle.typeName ~= "FS22_lsfmFarmEquipmentPack.portableToolbox" then

					local isSelling        = (vehicle.isDeleted ~= nil and vehicle.isDeleted) or (vehicle.isDeleting ~= nil and vehicle.isDeleting)
					local hasAccess        = g_currentMission.accessHandler:canPlayerAccess(vehicle)
					local isProperty       = vehicle.propertyState == Vehicle.PROPERTY_STATE_OWNED or vehicle.propertyState == Vehicle.PROPERTY_STATE_LEASED or vehicle.propertyState == Vehicle.PROPERTY_STATE_MISSION
					local isPallet         = vehicle.typeName == "pallet"
					local isTrain          = vehicle.typeName == "locomotive"
					local isBelt           = vehicle.typeName == "conveyorBelt" or vehicle.typeName == "pickupConveyorBelt"
					local isRidable        = SpecializationUtil.hasSpecialization(Rideable, vehicle.specializations)
					local isSteerImplement = vehicle.spec_attachable ~= nil
							
					local skipable         = isTrain or isBelt or isRidable or isPallet
					local hasConned        = vehicle.getIsControlled ~= nil

					if self.listVehicle == "vehicle" then
						skipable = isTrain or isBelt or isRidable or isPallet or isSteerImplement
					end

					if self.listVehicle == "all" and not isSelling and not skipable and hasAccess and vehicle.getSellPrice ~= nil and vehicle.price ~= nil and isProperty then
						table.insert(self.vehicles, vehicle)
					end

					if self.listVehicle == "vehicle" and not isSelling and not skipable and hasAccess and vehicle.getSellPrice ~= nil and vehicle.price ~= nil and isProperty and hasConned then
						table.insert(self.vehicles, vehicle)
					end
						
					for i = 1, #self.vehicles do
						local self_vehicle = self.vehicles[i]
						local spec = self_vehicle.spec_faultData
						if spec ~= nil and self_vehicle.spec_motorized ~= nil and self_vehicle.getIsEntered ~= nil and self_vehicle:getIsEntered() then
							self.vehicleList.selectedIndex = i
							self.vehicleList.selectedSectionIndex = i
							self.vehicleList.selectOnScroll = true
							self.vehicleDetail.selectedIndex = i
							self.vehicleDetail.selectedSectionIndex = i
						end
					end

				end
				
				if self.listSort == "base" then
					table.sort(self.vehicles, function (a, b)
						return a.rootNode < b.rootNode
					end)
				elseif self.listSort == "hpAsc" or self.listSort == "hpDesc" then

					table.sort(self.vehicles, function (a, b)

						local powerConfig = Motorized.loadSpecValuePowerConfig(a.xmlFile)
						a.ideHasPower = 0
						if powerConfig ~= nil then
							for configName, config in pairs(a.configurations) do
								local configPower = powerConfig[configName][config]
								if configPower ~= nil then
									a.ideHasPower = configPower
								end
							end
						end
						local hp, kw = g_i18n:getPower(a.ideHasPower)

						local powerConfig = Motorized.loadSpecValuePowerConfig(b.xmlFile)
						b.ideHasPower = 0
						if powerConfig ~= nil then
							for configName, config in pairs(b.configurations) do
								local configPower = powerConfig[configName][config]
								if configPower ~= nil then
									b.ideHasPower = configPower
								end
							end
						end
						local hpb, kwb = g_i18n:getPower(b.ideHasPower)

						if self.listSort == "hpAsc" then
							return hp > hpb
						elseif self.listSort == "hpDesc" then
							return hp < hpb
						end

					end)
				end

			end
		end
	end

	self.vehicleList:reloadData()
	self.vehicleDetail:reloadData()

end

function RVBVehicleList_Frame:getNumberOfItemsInSection(list, section)
	if list == self.vehicleList then
		return #self.vehicles
	else
		return 6
	end
end

function RVBVehicleList_Frame:populateCellForItemInSection(list, section, index, cell)

	if list == self.vehicleList then
	
		local self_vehicle = self.vehicles[index]
		local name         = self_vehicle:getFullName()
		local spec         = self_vehicle.spec_faultData

		--[[ title ]]
		cell:getAttribute("title"):setText(name)

		--[[ power ]]
		cell:getAttribute("power"):setText(self:powerString(self_vehicle, true))

		--[[ price ]]
		local getsellprice = ""
		if spec ~= nil then
			--getsellprice = g_i18n:formatMoney(math.min(math.floor(self_vehicle:getSellPrice_RVBClone() * EconomyManager.DIRECT_SELL_MULTIPLIER), self_vehicle:getPrice()))
			getsellprice = g_i18n:formatMoney(math.min(self_vehicle:getSellPrice_RVBClone(), self_vehicle:getPrice()))
		else
			--getsellprice = g_i18n:formatMoney(math.min(math.floor(self_vehicle:getSellPrice() * EconomyManager.DIRECT_SELL_MULTIPLIER), self_vehicle:getPrice()))
			getsellprice = g_i18n:formatMoney(math.min(self_vehicle:getSellPrice(), self_vehicle:getPrice()))
		end
		cell:getAttribute("price"):setText(getsellprice)

		--[[ age ]]
		cell:getAttribute("age"):setText(string.format(g_i18n:getText("shop_age"), self_vehicle.age))

		--[[ operating_time ]]
		local minutes = self_vehicle:getOperatingTime() / (1000 * 60)
		local hours = math.floor(minutes / 60)
		minutes = math.floor((minutes - hours * 60) / 6)
		if spec ~= nil then
			hours = math.floor(spec.rvb[3])
			minutes = math.floor((spec.rvb[3] - hours) * 60)
			if hours < 10 then hours = string.format("0%s", hours) else hours = string.format("%s", hours) end
			if minutes < 10 then minutes = string.format("0%s", minutes) else minutes = string.format("%s", minutes) end
		end
		cell:getAttribute("operating_time"):setText(string.format(g_i18n:getText("RVB_shop_operatingTimeG"), hours, minutes))

		--[[ real_operating_time ]]
		local minutes = self_vehicle:getOperatingTime() / (1000 * 60)
		local hours = math.floor(minutes / 60)
		minutes = math.floor((minutes - hours * 60) / 6)
		cell:getAttribute("real_operating_time"):setText(string.format(g_i18n:getText("RVB_shop_operatingTime"), hours, minutes))

		--[[ service ]]
		if spec ~= nil then
			local periodicServiceInterval = self.rvbMain:getIsIsPeriodicService()
			local ServiceAmount = math.floor(spec.rvb[4])
			ServiceAmount = ServiceAmount.."."..math.floor((spec.rvb[4] - ServiceAmount) * 60)
			cell:getAttribute("service"):setText(string.format(g_i18n:getText("RVB_serviceHours"), ServiceAmount, periodicServiceInterval))
		else
			cell:getAttribute("service"):setText("-")
		end

		--[[ lease ]]
		local isLeased = self_vehicle.propertyState == Vehicle.PROPERTY_STATE_LEASED
		local lease_text = "-"
		if isLeased then
			lease_text = g_i18n:getText("ui_on")
		end
		cell:getAttribute("lease"):setText(lease_text)

	else

		local selectedIndex      = self.vehicleList.selectedIndex
		local self_vehicle       = self.vehicles[selectedIndex]
		--local attachedImplements = {}
		local amount			 = 0

		if self_vehicle ~= nil then

			local spec = self_vehicle.spec_faultData

			self.vehicleIcon:setVisible(true)
			self.vehicleDetail:setVisible(true)
			
			--
			
			self.partsListTitle:setVisible(false)
			self.partsListBox:setVisible(false)

			if spec ~= nil and self_vehicle.spec_motorized ~= nil and self_vehicle.getIsEntered ~= nil then
				if spec.inspection[8] then
				
					self.partsListTitle:setVisible(true)
					self.partsListBox:setVisible(true)

					self.checkedThermostatPartToggle:setIsChecked(spec.parts[1].repairreq)
					local thermostat_Partfoot = (spec.parts[1].operatingHours * 100) / spec.parts[1].tmp_lifetime
					local thermostat_Pfoot = 100 - thermostat_Partfoot
					if thermostat_Pfoot < 0 then thermostat_Pfoot = 0 end
					self.THERMOSTAT:setText(g_i18n:getText("RVB_faultText_THERMOSTAT"))
					if thermostat_Partfoot >= 80 then
						self.THERMOSTAT:setText(g_i18n:getText("RVB_faultText_THERMOSTAT").." ("..string.format("%.0f", thermostat_Pfoot).."%)")
						self.checkedThermostatPartToggle:setDisabled(false)
					end
					if thermostat_Partfoot < 80 or thermostat_Partfoot >= 99 then
						self.checkedThermostatPartToggle:setDisabled(true)
					end
					
					self.checkedLightingsPartToggle:setIsChecked(spec.parts[2].repairreq)
					local lightings_Partfoot = (spec.parts[2].operatingHours * 100) / spec.parts[2].tmp_lifetime
					local lightings_Pfoot = 100 - lightings_Partfoot
					if lightings_Pfoot < 0 then lightings_Pfoot = 0 end
					self.LIGHTINGS:setText(g_i18n:getText("RVB_faultText_LIGHTINGS"))
					if lightings_Partfoot >= 80 then
						self.LIGHTINGS:setText(g_i18n:getText("RVB_faultText_LIGHTINGS").." ("..string.format("%.0f", lightings_Pfoot).."%)")
						self.checkedLightingsPartToggle:setDisabled(false)
					end
					if lightings_Partfoot < 80 or lightings_Partfoot >= 99 then
						self.checkedLightingsPartToggle:setDisabled(true)
					end
			
					self.checkedGlowPlugPartToggle:setIsChecked(spec.parts[3].repairreq)
					local glowPlug_Partfoot = (spec.parts[3].operatingHours * 100) / spec.parts[3].tmp_lifetime
					local glowPlug_Pfoot = 100 - glowPlug_Partfoot
					if glowPlug_Pfoot < 0 then glowPlug_Pfoot = 0 end
					self.GLOWPLUG:setText(g_i18n:getText("RVB_faultText_GLOWPLUG"))
					if glowPlug_Partfoot >= 80 then
						self.GLOWPLUG:setText(g_i18n:getText("RVB_faultText_GLOWPLUG").." ("..string.format("%.0f", glowPlug_Pfoot).."%)")
						self.checkedGlowPlugPartToggle:setDisabled(false)
					end
					if glowPlug_Partfoot < 80 or glowPlug_Partfoot >= 99 then
						self.checkedGlowPlugPartToggle:setDisabled(true)
					end
			
					self.checkedWipersPartToggle:setIsChecked(spec.parts[4].repairreq)
					local wipers_Partfoot = (spec.parts[4].operatingHours * 100) / spec.parts[4].tmp_lifetime
					local wipers_Pfoot = 100 - wipers_Partfoot
					if wipers_Pfoot < 0 then wipers_Pfoot = 0 end
					self.WIPERS:setText(g_i18n:getText("RVB_faultText_WIPERS"))
					if wipers_Partfoot >= 80 then
						self.WIPERS:setText(g_i18n:getText("RVB_faultText_WIPERS").." ("..string.format("%.0f", wipers_Pfoot).."%)")
						self.checkedWipersPartToggle:setDisabled(false)
					end
					if wipers_Partfoot < 80 or wipers_Partfoot >= 99 then
						self.checkedWipersPartToggle:setDisabled(true)
					end
			
					self.checkedGeneratorPartToggle:setIsChecked(spec.parts[5].repairreq)
					local generator_Partfoot = (spec.parts[5].operatingHours * 100) / spec.parts[5].tmp_lifetime
					local generator_Pfoot = 100 - generator_Partfoot
					if generator_Pfoot < 0 then generator_Pfoot = 0 end
					self.GENERATOR:setText(g_i18n:getText("RVB_faultText_GENERATOR"))
					if generator_Partfoot >= 80 then
						self.GENERATOR:setText(g_i18n:getText("RVB_faultText_GENERATOR").." ("..string.format("%.0f", generator_Pfoot).."%)")
						self.checkedGeneratorPartToggle:setDisabled(false)
					end
					if generator_Partfoot < 80 or generator_Partfoot >= 99 then
						self.checkedGeneratorPartToggle:setDisabled(true)
					end
			
					self.checkedEnginePartToggle:setIsChecked(spec.parts[6].repairreq)
					local engine_Partfoot = (spec.parts[6].operatingHours * 100) / spec.parts[6].tmp_lifetime
					local engine_Pfoot = 100 - engine_Partfoot
					if engine_Pfoot < 0 then engine_Pfoot = 0 end
					self.ENGINE:setText(g_i18n:getText("RVB_faultText_ENGINE"))
					if engine_Partfoot >= 80 then
						self.ENGINE:setText(g_i18n:getText("RVB_faultText_ENGINE").." ("..string.format("%.0f", engine_Pfoot).."%)")
						self.checkedEnginePartToggle:setDisabled(false)
					end
					if engine_Partfoot < 80 or engine_Partfoot >= 99 then
						self.checkedEnginePartToggle:setDisabled(true)
					end
			
					self.checkedSelfstarterPartToggle:setIsChecked(spec.parts[7].repairreq)
					local selfstarter_Partfoot = (spec.parts[7].operatingHours * 100) / spec.parts[7].tmp_lifetime
					local selfstarter_Pfoot = 100 - selfstarter_Partfoot
					if selfstarter_Pfoot < 0 then selfstarter_Pfoot = 0 end
					self.SELFSTARTER:setText(g_i18n:getText("RVB_faultText_SELFSTARTER"))
					if selfstarter_Partfoot >= 80 then
						self.SELFSTARTER:setText(g_i18n:getText("RVB_faultText_SELFSTARTER").." ("..string.format("%.0f", selfstarter_Pfoot).."%)")
						self.checkedSelfstarterPartToggle:setDisabled(false)
					end
					if selfstarter_Partfoot < 80 or selfstarter_Partfoot >= 99 then
						self.checkedSelfstarterPartToggle:setDisabled(true)
					end

					self.checkedBatteryPartToggle:setIsChecked(spec.parts[8].repairreq)
					local battery_Partfoot = (spec.parts[8].operatingHours * 100) / spec.parts[8].tmp_lifetime
					local battery_Pfoot = 100 - battery_Partfoot
					if battery_Pfoot < 0 then battery_Pfoot = 0 end
					self.BATTERY:setText(g_i18n:getText("RVB_faultText_BATTERY"))
					if battery_Partfoot >= 80 then
						self.BATTERY:setText(g_i18n:getText("RVB_faultText_BATTERY").." ("..string.format("%.0f", battery_Pfoot).."%)")
						self.checkedBatteryPartToggle:setDisabled(false)
					end
					if battery_Partfoot < 80 or battery_Partfoot >= 99 then
						self.checkedBatteryPartToggle:setDisabled(true)
					end
					
				end
			end
			
			if self_vehicle.getAttachedImplements ~= nil then
				--attachedImplements = self_vehicle:getAttachedImplements()
			end

			if index == 1 then

				cell:setVisible(false)

				if spec ~= nil then
					local defLevel = self:getDEF(self_vehicle)
					if defLevel ~= nil then
						self:setStatusBarValue(cell:getAttribute("detailBar"), defLevel, 1-defLevel, 0.1, 0.4)
						self:setDetailText(
							cell, false,
							"fillType_def",
							RVBVehicleList_Frame:rawToPerc(defLevel, false)
						)
						cell:setVisible(true)
					end
				end

			elseif index == 2 then

				cell:setVisible(false)
				--[[if spec ~= nil then
					amount = spec.rvb[5]
					self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.1, 0.4)
					self:setDetailText(
						cell, false,
						"RVB_list_battery",
						RVBVehicleList_Frame:rawToPerc(amount, true)
					)
					cell:setVisible(true)
				end]]
				
				if spec ~= nil then
					local batteryLevel = self:getBATTERY(self_vehicle)
					if batteryLevel ~= nil then
						self:setStatusBarValue(cell:getAttribute("detailBar"), batteryLevel, 1-batteryLevel, 0.1, 0.4)
						self:setDetailText(
							cell, false,
							"RVB_list_battery",
							RVBVehicleList_Frame:rawToPerc(batteryLevel, false)
						)
						cell:setVisible(true)
					end
				end

			elseif index == 3 then

				cell:setVisible(false)
				
				local fuelLevel = self:getFuel(self_vehicle)
				if fuelLevel[1] ~= false then
					self:setStatusBarValue(cell:getAttribute("detailBar"), fuelLevel[2], 1-fuelLevel[2], 0.1, 0.4)
					self:setDetailText(
						cell, false,
						fuelLevel[1],
						RVBVehicleList_Frame:rawToPerc(fuelLevel[2], false)
					)
					cell:setVisible(true)
				end

			elseif index == 4 then

				if self_vehicle.getDamageAmount ~= nil then
					amount = self_vehicle:getDamageAmount()
				end

				self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.1, 0.4)
				self:setDetailText(
					cell, false,
					"ui_condition",
					RVBVehicleList_Frame:rawToPerc(amount, true)
				)

			elseif index == 5 then

				if self_vehicle.getWearTotalAmount ~= nil then
					amount = self_vehicle:getWearTotalAmount()
				end

				self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.1, 0.4)
				self:setDetailText(
					cell, false,
					"ui_paintCondition",
					RVBVehicleList_Frame:rawToPerc(amount, true)
				)

			elseif index == 6 then

				 if self_vehicle.getDirtAmount ~= nil then
					amount = self_vehicle:getDirtAmount()
				end

				self:setStatusBarValue(cell:getAttribute("detailBar"), amount, amount, 0.1, 0.4)
				self:setDetailText(
					cell, false,
					"setting_dirt",
					RVBVehicleList_Frame:rawToPerc(amount, false)
				)

			end

		else

			self.vehicleIcon:setVisible(false)
			self.vehicleDetail:setVisible(false)

		end
	end
	
end

function RVBVehicleList_Frame:setDetailText(cell, nukeBar, title, level)
	cell:getAttribute("detailBarBG"):setVisible(true)
	cell:getAttribute("detailBar"):setVisible(true)

	if title == "" then
		cell:getAttribute("detailTitle"):setText("")
	else
		cell:getAttribute("detailTitle"):setText(g_i18n:getText(title))
	end

	cell:getAttribute("detailLevel"):setText(level)

	if nukeBar then
		cell:getAttribute("detailLevel"):applyProfile("VehicleDetailLevelNoBar")
		cell:getAttribute("detailTitle"):applyProfile("VehicleDetailTitleNoBar")
		cell:getAttribute("detailBarBG"):setVisible(false)
		cell:getAttribute("detailBar"):setVisible(false)
	end

end

function RVBVehicleList_Frame:setStatusBarValue(statusBarElement, value, rawValue, levelGood, levelWarn)

	if rawValue < levelGood then
		statusBarElement:applyProfile("VehicleDetailBar")
	elseif rawValue < levelWarn then
		statusBarElement:applyProfile("VehicleDetailBarWarning")
	else
		statusBarElement:applyProfile("VehicleDetailBarDanger")
	end

	local fullWidth = statusBarElement.parent.absSize[1] - statusBarElement.margin[1] * 2
	local minSize = 0

	if statusBarElement.startSize ~= nil then
		minSize = statusBarElement.startSize[1] + statusBarElement.endSize[1]
	end

	--statusBarElement:setSize(math.max(minSize, fullWidth * math.min(1, value)), nil)
	statusBarElement:setSize(math.max(minSize, fullWidth * math.min(value, 1)), nil)
end

function RVBVehicleList_Frame:powerString(vehicle, noBrace)
	local storeItem = g_storeManager:getItemByXMLFilename(vehicle.configFileName)

	if vehicle.configurations == nil or vehicle.configurations.motor == nil then
		return ""
	end

	local boughtMotor = vehicle.configurations.motor
	local motorPower  = storeItem.configurations.motor[boughtMotor].power

	if motorPower == nil then return "" end

	local hp, _ = g_i18n:getPower(motorPower)

	local returnText = string.format(g_i18n:getText("shop_maxPowerValueSingle"), math.floor(hp))

	if noBrace == nil or noBrace == false then
		return " [" .. returnText .. "]"
	end

	return returnText
end

function RVBVehicleList_Frame:rawToPerc(value, invert)
	if not invert then
		return MathUtil.round((value)*100) .. " %"
	end
	return MathUtil.round((1 - value)*100) .. " %"
end

function RVBVehicleList_Frame:getDEF(vehicle)

	local defFillUnitIndex = vehicle:getConsumerFillUnitIndex(FillType.DEF)

	if defFillUnitIndex ~= nil then
		local fillLevel = vehicle:getFillUnitFillLevel(defFillUnitIndex)
		local capacity  = vehicle:getFillUnitCapacity(defFillUnitIndex)
		return fillLevel / capacity
	end
	return nil

end

function RVBVehicleList_Frame:getBATTERY(vehicle)

	local batteryFillUnitIndex = vehicle:getConsumerFillUnitIndex(FillType.ELECTRICCHARGE)
	local dieselFillUnitIndex = vehicle:getConsumerFillUnitIndex(FillType.DIESEL)
	
	if batteryFillUnitIndex ~= nil and dieselFillUnitIndex ~= nil then
		local fillLevel = vehicle:getFillUnitFillLevel(batteryFillUnitIndex)
		local capacity  = vehicle:getFillUnitCapacity(batteryFillUnitIndex)
		--return fillLevel / capacity
		return vehicle:getFillUnitFillLevelPercentage(batteryFillUnitIndex)
		--return MathUtil.round(vehicle:getFillUnitFillLevelPercentage(batteryFillUnitIndex))
	end
	return nil

end

function RVBVehicleList_Frame:getFuel(vehicle)

	local fuelTypeList = {
		{ FillType.DIESEL, "fillType_diesel" },
		{ FillType.ELECTRICCHARGE, "fillType_electricCharge" },
		{ FillType.METHANE,	"fillType_methane" }
	}

	if vehicle.getConsumerFillUnitIndex ~= nil then
		for _, fuelType in pairs(fuelTypeList) do
			local fillUnitIndex = vehicle:getConsumerFillUnitIndex(fuelType[1])
			if ( fillUnitIndex ~= nil ) then
				local fuelLevel  = vehicle:getFillUnitFillLevel(fillUnitIndex)
				local capacity   = vehicle:getFillUnitCapacity(fillUnitIndex)
				local percentage = fuelLevel / capacity
				return { fuelType[2], percentage }
			end
		end
	end
	return { false }
end

function RVBVehicleList_Frame:onListSelectionChanged(list, section, index)

	if list == self.vehicleList then

		local self_vehicle = self.vehicles[index]
		local spec         = self_vehicle.spec_faultData
		local storeItem    = g_storeManager:getItemByXMLFilename(self_vehicle.configFileName)
		local infoText     = ""
		local tomorrowText = ""
		
		g_workshopScreen:setVehicle(self_vehicle)
		
		self.vehicleIcon:setImageFilename(storeItem.imageFilename)

		if spec ~= nil then

			if spec.repair ~= nil then
				if spec.repair[1] and spec.inspection[8] then
					if spec.repair[3] > g_currentMission.environment.currentDay then
						tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
					end
					infoText = g_i18n:getText("RVB_alertmessage_repair").." "..tomorrowText..string.format("%02d:%02d", spec.repair[4], spec.repair[5])
				end
				self:setInfoText(infoText)
			end
			
			if spec.inspection ~= nil then
				if spec.inspection[1] then
					local tomorrowText = ""
					if spec.inspection[3] > g_currentMission.environment.currentDay then
						tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
					end
					infoText = g_i18n:getText("RVB_alertmessage_inspection").." "..tomorrowText..string.format("%02d:%02d", spec.inspection[4], spec.inspection[5])
				end
				self:setInfoText(infoText)
			end

			if spec.service ~= nil then
				if spec.service[1] then
					if spec.service[3] > g_currentMission.environment.currentDay then
						tomorrowText = g_i18n:getText("infoDisplayExtension_tomorrow")
					end
					infoText = g_i18n:getText("RVB_alertmessage_service").." "..tomorrowText..string.format("%02d:%02d", spec.service[4], spec.service[5])
				end
				self:setInfoText(infoText)
			end

			if spec.battery ~= nil then
				if spec.battery[1] then
					infoText = g_i18n:getText("RVB_alertmessage_batteryCh")
				end
				self:setInfoText(infoText)
			end
			
			local textsNoYes = { self.i18n:getText("ui_off"), self.i18n:getText("ui_on") }

			self.checkedThermostatPartToggle:setTexts(textsNoYes)
			self.checkedLightingsPartToggle:setTexts(textsNoYes)
			self.checkedGlowPlugPartToggle:setTexts(textsNoYes)
			self.checkedWipersPartToggle:setTexts(textsNoYes)
			self.checkedGeneratorPartToggle:setTexts(textsNoYes)

		else
			self:setInfoText(infoText)
		end

		self.vehicleDetail:reloadData()
	end

	self:updateMenuButtons()
	
end

function RVBVehicleList_Frame:onClickThermostatPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'ThermostatPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[1].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickLightingsPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'LightingsPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[2].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickGlowPlugPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'GlowPlugPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[3].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickWipersPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'WipersPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[4].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickGeneratorPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'GeneratorPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[5].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickEnginePart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'EnginePart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[6].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickSelfstarterPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'Self-StarterPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[7].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:onClickBatteryPart(state)
	local fault = state == CheckedOptionElement.STATE_CHECKED
	Logging.info("[RVB] Repair Part 'BatteryPart': ".. tostring(fault))
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	spec.parts[8].repairreq = fault
	self:updateMenuButtons()
end

function RVBVehicleList_Frame:updateMenuButtons_AFM()
	self.extra1ButtonInfo.disabled = true
end

if FS22_AdvancedFarmManager ~= nil and FS22_AdvancedFarmManager.AIMGuiVehicleFrame ~= nil then
	FS22_AdvancedFarmManager.AIMGuiVehicleFrame.updateMenuButtons = Utils.appendedFunction(FS22_AdvancedFarmManager.AIMGuiVehicleFrame.updateMenuButtons, RVBVehicleList_Frame.updateMenuButtons_AFM)
end