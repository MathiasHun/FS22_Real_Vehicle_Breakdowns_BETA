
RVBVehicleList_Frame = {}
local RVBVehicleList_Frame_mt = Class(RVBVehicleList_Frame, TabbedMenuFrameElement)

RVBVehicleList_Frame.CONTROLS = {"vehicleList", "vehicleIcon", "vehicleDetail", "settingsContainer", "boxLayout", "infoBoxText" }

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

	self.messageCenter:subscribe(MessageType.VEHICLE_REPAIRED, self.onRefreshEvent, self)

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
	self.vehicles = {}
	self.messageCenter:unsubscribeAll(self)
end

function RVBVehicleList_Frame:initialize()

	self.backButtonInfo = {inputAction = InputAction.MENU_BACK}

	self.inspectionButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_EXTRA_2,
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
		inputAction = InputAction.MENU_ACCEPT,
		text        = g_i18n:getText("RVB_button_periodicservice"),
		callback    = function ()
			self:onButtonPeriodicService()
		end
	}

	self.batteryChargingButton = {
		profile     = "buttonActivate",
		inputAction = InputAction.ACTIVATE_OBJECT,
		text        = g_i18n:getText("RVB_button_battery_ch"),
		callback    = function ()
			self:onButtonBatteryCharging()
		end
	}
	
	self.entervehicleButtonInfo = {
		profile     = "buttonActivate",
		inputAction = InputAction.MENU_ACTIVATE,
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

end

function RVBVehicleList_Frame:onButtonInspectionVehicle()

	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec			= self_vehicle.spec_faultData

	if self_vehicle ~= nil and spec ~= nil then

		local AddHour = math.floor(VehicleBreakdowns.IRSBTimes[11] / 3600)
		local AddMinute = math.floor(((VehicleBreakdowns.IRSBTimes[11] / 3600) - AddHour) * 60)
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
		for index, value in pairs(spec.faultStorage) do
			if type(value) == "boolean" and value then
				table.insert(faultListText, g_i18n:getText("RVB_faultText_"..VehicleBreakdowns.faultText[index]))
				faultListTime = faultListTime + VehicleBreakdowns.IRSBTimes[index]
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
		local servicePeriodic = math.floor(spec.faultStorage[10])

		if servicePeriodic > self.rvbMain:getIsIsPeriodicService() then
			moreservice = math.ceil(servicePeriodic - self.rvbMain:getIsIsPeriodicService())
		end
		local alap = 5400

		local serviceTime = alap + VehicleBreakdowns.IRSBTimes[10] * moreservice

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
	local spec			= self_vehicle.spec_faultData

	if self_vehicle ~= nil and spec.faultStorage[9] >= 0.10 then

		local lackofcharge = math.floor(spec.faultStorage[9] * 100)
		local AddHour = math.floor((VehicleBreakdowns.IRSBTimes[9] * lackofcharge) / 3600)
		local AddMinute = math.floor((((VehicleBreakdowns.IRSBTimes[9] * lackofcharge) / 3600) - AddHour) * 60)
		local FinishDay, FinishHour, FinishMinute = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
		local timeText = string.format("%02d:%02d", FinishHour, FinishMinute)

		local DialogServiceText = "RVB_batteryChTimeDialog"
		if FinishDay > g_currentMission.environment.currentDay then
			DialogServiceText = "RVB_batteryChDayDialog"
		end

		g_gui:showYesNoDialog({
			text     = string.format(g_i18n:getText("RVB_batteryChDialog"), g_i18n:formatMoney(self:getBatteryChPrice(true))).."\n"..
					   string.format(g_i18n:getText(DialogServiceText), timeText),
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

			local AddHour = math.floor(VehicleBreakdowns.IRSBTimes[11] / 3600)
			local AddMinute = math.floor(((VehicleBreakdowns.IRSBTimes[11] / 3600) - AddHour) * 60)

			spec.repair[8] = 0
			spec.repair[1] = true
			spec.repair[2] = false
			spec.repair[3], spec.repair[4], spec.repair[5] = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
			spec.repair[6] = 0
			spec.repair[7] = self_vehicle:getInspectionPrice()

			spec.rvb[1] = g_currentMission.missionInfo.timeScale

			--if self_vehicle.isServer then
			--elseif self_vehicle.isClient then
				RVBRepair_Event.sendEvent(self_vehicle, unpack(spec.repair))
				RVBTotal_Event.sendEvent(self_vehicle, unpack(spec.rvb))
				self_vehicle:raiseDirtyFlags(spec.dirtyFlag)
			--end

			self_vehicle:stopMotor(true)
			self_vehicle:StopAI(self_vehicle)
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
			for index, value in pairs(spec.faultStorage) do
				if type(value) == "boolean" and value then
					faultListTime = faultListTime + VehicleBreakdowns.IRSBTimes[index]
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

			self_vehicle:stopMotor(true)
			self_vehicle:StopAI(self_vehicle)
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
			local servicePeriodic = math.floor(spec.faultStorage[10])

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

			self_vehicle:stopMotor(true)
			self_vehicle:StopAI(self_vehicle)
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

			local lackofcharge = math.floor(spec.faultStorage[9] * 100)
			local AddHour = math.floor((VehicleBreakdowns.IRSBTimes[9] * lackofcharge) / 3600)
			local AddMinute = math.floor((((VehicleBreakdowns.IRSBTimes[9] * lackofcharge) / 3600) - AddHour) * 60)

			spec.battery[1] = true
			spec.battery[2] = false
			spec.battery[3], spec.battery[4], spec.battery[5] = VehicleBreakdowns:CalculateFinishTime(AddHour, AddMinute)
			spec.battery[6] = spec.faultStorage[9] / (VehicleBreakdowns.IRSBTimes[9] * lackofcharge) * 60
			spec.battery[7] = self:getBatteryChPrice()

			spec.rvb[1] = g_currentMission.missionInfo.timeScale

			--if self_vehicle.isServer then
			--elseif self_vehicle.isClient then
				RVBBattery_Event.sendEvent(self_vehicle, unpack(spec.battery))
				RVBTotal_Event.sendEvent(self_vehicle, unpack(spec.rvb))
				self_vehicle:raiseDirtyFlags(spec.dirtyFlag)
			--end

			self_vehicle:stopMotor(true)
			self_vehicle:StopAI(self_vehicle)
			local specm = self_vehicle.spec_motorized
			if specm.motor ~= nil then
				specm.motor:setGearShiftMode(specm.gearShiftMode)
			end

			self:rebuildTableList()
		end
	end
end

function RVBVehicleList_Frame:getBatteryChPrice()
	local selectedIndex = self.vehicleList.selectedIndex
	local self_vehicle  = self.vehicles[selectedIndex]
	local spec          = self_vehicle.spec_faultData
	return self.calculateBatteryChPrice(1000, spec.faultStorage[9])
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
		
		local repairPrice = 0
		if spec ~= nil then
			repairPrice = self_vehicle:getRepairPrice_RVBClone()
		else
			repairPrice = self_vehicle:getRepairPrice()
		end

		local servicePrice = 0
		if spec ~= nil then
			servicePrice = math.floor(spec.faultStorage[10])
		end

		local isBorrowed = self_vehicle.propertyState == Vehicle.PROPERTY_STATE_MISSION

		--local isMPGame = g_currentMission.missionDynamicInfo.isMultiplayer
		local batterycher = 0
		if spec ~= nil then
			batterycher = spec.faultStorage[9]
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
					if spec.repair ~= nil then
						if not spec.repair[10] then
							if spec.repair[7] == 0 then
								self.inspectionButtonInfo.text = g_i18n:getText("RVB_button_inspection").." ("..g_i18n:formatMoney(self_vehicle:getInspectionPrice(true))..")"
								self.inspectionButtonInfo.disabled = false
							else
								self.inspectionButtonInfo.text = g_i18n:getText("RVB_button_inspection")
								self.inspectionButtonInfo.disabled = true
							end
							table.insert(self.menuButtonInfo, self.inspectionButtonInfo)
						end

						if spec.repair[10] then 
							if not spec.repair[1] and repairPrice > 1 then
								self.repairButtonInfo.text = g_i18n:getText("button_repair").." ("..g_i18n:formatMoney(self_vehicle:getRepairPrice_RVBClone(true))..")"
								self.repairButtonInfo.disabled = false
							else
								self.repairButtonInfo.text = g_i18n:getText("button_repair")
								self.repairButtonInfo.disabled = true
							end
							table.insert(self.menuButtonInfo, self.repairButtonInfo)
						end
					end

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

				if spec ~= nil then
					if spec.battery ~= nil then
						if not spec.battery[1] and batterycher > 0.10 then
							self.batteryChargingButton.text = g_i18n:getText("RVB_button_battery_ch").." ("..g_i18n:formatMoney(self:getBatteryChPrice(true))..")"
							self.batteryChargingButton.disabled = false
						else
							self.batteryChargingButton.text = g_i18n:getText("RVB_button_battery_ch")
							self.batteryChargingButton.disabled = true
						end
						table.insert(self.menuButtonInfo, self.batteryChargingButton)
					end
				end

			end
			
		end

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

		for _, vehicle in ipairs(g_currentMission.vehicles) do

			if vehicle ~= nil and vehicle.typeName ~= "locomotive" and vehicle.typeName ~= "trainTrailer" and vehicle.typeName ~= "trainTimberTrailer" then 
				local px, py, pz = getWorldTranslation(vehicle.components[1].node)
				local distance = {}
			
				if px ~= nil then

					for index, repairTrigger in pairs(VehicleBreakdowns.getRepairTriggers()) do
						if repairTrigger ~= nil then
							local triggerX, triggerY, triggerZ = getWorldTranslation(repairTrigger.node)
							distance[index] = MathUtil.vector3Length(triggerX - px, triggerY - py, triggerZ - pz)
						end
					end
					local _distance = false
					for index, value in pairs(distance) do
						if distance[index] <= 6.000000 then
							_distance = true
						end
					end

					if _distance or not self.rvbMain:getIsRepairShop() then

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
			getsellprice = g_i18n:formatMoney(math.min(math.floor(self_vehicle:getSellPrice_RVBClone() * EconomyManager.DIRECT_SELL_MULTIPLIER), self_vehicle:getPrice()))
		else
			getsellprice = g_i18n:formatMoney(math.min(math.floor(self_vehicle:getSellPrice() * EconomyManager.DIRECT_SELL_MULTIPLIER), self_vehicle:getPrice()))
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
		end
		cell:getAttribute("operating_time"):setText(string.format(g_i18n:getText("RVB_shop_operatingTime"), hours, minutes))

		--[[ real_operating_time ]]
		local minutes = self_vehicle:getOperatingTime() / (1000 * 60)
		local hours = math.floor(minutes / 60)
		minutes = math.floor((minutes - hours * 60) / 6)
		cell:getAttribute("real_operating_time"):setText(string.format(g_i18n:getText("RVB_shop_operatingTime"), hours, minutes))

		--[[ service ]]
		if spec ~= nil then
			local periodicServiceInterval = self.rvbMain:getIsIsPeriodicService()
			local ServiceAmount = math.floor(spec.faultStorage[10])
			ServiceAmount = ServiceAmount.."."..math.floor((spec.faultStorage[10] - ServiceAmount) * 60)
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

			if self_vehicle.getAttachedImplements ~= nil then
				--attachedImplements = self_vehicle:getAttachedImplements()
			end

			if index == 1 then

				cell:setVisible(false)

				if spec ~= nil then
					local defLevel = self:getDEF(self_vehicle)
					if defLevel ~= nil then
						self:setStatusBarValue(cell:getAttribute("detailBar"), defLevel, 1-defLevel, 0.3, 0.6)
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
				if spec ~= nil then
					amount = spec.faultStorage[9]
					self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.3, 0.7)
					self:setDetailText(
						cell, false,
						"RVB_list_battery",
						RVBVehicleList_Frame:rawToPerc(amount, true)
					)
					cell:setVisible(true)
				end

			elseif index == 3 then

				cell:setVisible(false)
				
				local fuelLevel = self:getFuel(self_vehicle)
				if fuelLevel[1] ~= false then
					self:setStatusBarValue(cell:getAttribute("detailBar"), fuelLevel[2], 1-fuelLevel[2], 0.3, 0.6)
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

				self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.1, 0.2)
				self:setDetailText(
					cell, false,
					"ui_condition",
					RVBVehicleList_Frame:rawToPerc(amount, true)
				)

			elseif index == 5 then

				if self_vehicle.getWearTotalAmount ~= nil then
					amount = self_vehicle:getWearTotalAmount()
				end

				self:setStatusBarValue(cell:getAttribute("detailBar"), 1-amount, amount, 0.3, 0.6)
				self:setDetailText(
					cell, false,
					"ui_paintCondition",
					RVBVehicleList_Frame:rawToPerc(amount, true)
				)

			elseif index == 6 then

				 if self_vehicle.getDirtAmount ~= nil then
					amount = self_vehicle:getDirtAmount()
				end

				self:setStatusBarValue(cell:getAttribute("detailBar"), amount, amount, 0.3, 0.6)
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

	statusBarElement:setSize(math.max(minSize, fullWidth * math.min(1, value)), nil)
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
		return math.ceil((value)*100) .. " %"
	end
	return math.ceil((1 - value)*100) .. " %"
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

		self.vehicleIcon:setImageFilename(storeItem.imageFilename)

		if spec ~= nil then

			if spec.repair ~= nil then
				if not spec.repair[10] and spec.repair[7] > 0 then
					infoText = g_i18n:getText("RVB_alertmessage_inspection")
				end
				if spec.repair[10] and spec.repair[1] then 
					infoText = g_i18n:getText("RVB_alertmessage_repair")
				end
				self:setInfoText(infoText)
			end

			if spec.service ~= nil then
				if spec.service[1] then
					infoText = g_i18n:getText("RVB_alertmessage_service")
				end
				self:setInfoText(infoText)
			end

			if spec.battery ~= nil then
				if spec.battery[1] then
					infoText = g_i18n:getText("RVB_alertmessage_batteryCh")
				end
				self:setInfoText(infoText)
			end

		else
			self:setInfoText(infoText)
		end

		self.vehicleDetail:reloadData()
	end

	self:updateMenuButtons()
	
end