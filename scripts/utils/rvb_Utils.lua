
rvb_Utils = {}

function rvb_Utils.removeLifetimeText(field)
	return string.upper(field:gsub("%Lifetime", ""))
end

function rvb_Utils.table_count(array)
	local count = 0
	for _ in pairs(array) do count = count + 1 end
	return count
end

function rvb_Utils.getLargeLifetimeString(valueIndex)
	local value = rvb_Utils.getLargeLifetimeFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getLargeLifetimeFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.LargeArray[valueIndex]
end

function rvb_Utils.getLargeLifetimeIndex(value, defaultIndex)
	if value == nil then
		--print("Hiba: value értéke nil!")
		return defaultIndex
	end
	for i = #rvb_Utils.LargeArray, 1, -1 do
		if rvb_Utils.LargeArray[i] <= value then
			return i
		end
	end
	return defaultIndex
end

function rvb_Utils.getSmallLifetimeString(valueIndex)
	local value = rvb_Utils.getSmallLifetimeFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getSmallLifetimeFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.SmallArray[valueIndex]
end

function rvb_Utils.getSmallLifetimeIndex(value, defaultIndex)
	if value == nil then
		--print("Hiba: value értéke nil!")
		return defaultIndex
	end
	for i = #rvb_Utils.SmallArray, 1, -1 do
		if rvb_Utils.SmallArray[i] <= value then
			return i
		end
	end
	return defaultIndex
end

function rvb_Utils.getDailyServiceString(valueIndex)
	local value = rvb_Utils.getDailyServiceFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getDailyServiceFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.DailyService[valueIndex]
end

function rvb_Utils.getDailyServiceIndex(value, defaultIndex)
	if value == nil then
		--print("Hiba: value értéke nil!")
		return defaultIndex
	end
	for i = #rvb_Utils.DailyService, 1, -1 do
		if rvb_Utils.DailyService[i] <= value then
			return i
		end
	end
	return defaultIndex
end

function rvb_Utils.getPeriodicServiceString(valueIndex)
	local value = rvb_Utils.getPeriodicServiceFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getPeriodicServiceFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.PeriodicService[valueIndex]
end

function rvb_Utils.getPeriodicServiceIndex(value, defaultIndex)
	if value == nil then
		--print("Hiba: value értéke nil!")
		return defaultIndex
	end
	for i = #rvb_Utils.PeriodicService, 1, -1 do
		if rvb_Utils.PeriodicService[i] <= value then
			return i
		end
	end
	return defaultIndex
end

function rvb_Utils.getWorkshopOpenString(valueIndex)
	local value = rvb_Utils.getWorkshopOpenFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getWorkshopOpenFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.WorkshopOpen[valueIndex]
end

function rvb_Utils.getWorkshopOpenIndex(value, defaultIndex)
	if value == nil then
		--print("Hiba: value értéke nil!")
		return defaultIndex
	end
	for i = #rvb_Utils.WorkshopOpen, 1, -1 do
		if rvb_Utils.WorkshopOpen[i] <= value then
			return i
		end
	end
	return defaultIndex
end

function rvb_Utils.getWorkshopCloseString(valueIndex)
	local value = rvb_Utils.getWorkshopCloseFromIndex(valueIndex)
	return string.format(g_i18n:getText("ui_RVB_gameplaysetting_hour"), value)
end

function rvb_Utils.getWorkshopCloseFromIndex(valueIndex)
	valueIndex = math.max(valueIndex, 1)
	return rvb_Utils.WorkshopClose[valueIndex]
end

function rvb_Utils.getWorkshopCloseIndex(value, defaultIndex)
	if value == nil then
        --print("Hiba: value értéke nil!")
        return defaultIndex
    end
	for i = #rvb_Utils.WorkshopClose, 1, -1 do
		if rvb_Utils.WorkshopClose[i] <= value then
			return i
		end
	end
	return defaultIndex
end

rvb_Utils.DailyService = { 4, 6, 8, 10 }
rvb_Utils.PeriodicService = { 40, 60, 80, 100 }
rvb_Utils.WorkshopOpen = { 7, 8, 9, 10 }
rvb_Utils.WorkshopClose = { 16, 17, 18, 19, 20 }

rvb_Utils.LargeArray = {}
rvb_Utils.LargeArrayMin = 5
rvb_Utils.LargeArrayMax = 340
for i = rvb_Utils.LargeArrayMin, rvb_Utils.LargeArrayMax do
	if i % 5 == 0 then
		table.insert(rvb_Utils.LargeArray, i)
	end
end

rvb_Utils.SmallArray = {}
rvb_Utils.SmallArrayMin = 1
rvb_Utils.SmallArrayMax = 6
for i = rvb_Utils.SmallArrayMin, rvb_Utils.SmallArrayMax do
	table.insert(rvb_Utils.SmallArray, i)
end

function rvb_Utils.to_upper(str)
    local replacements = {
        ["á"] = "Á", ["é"] = "É", ["í"] = "Í", ["ó"] = "Ó", ["ö"] = "Ö",
        ["ő"] = "Ő", ["ú"] = "Ú", ["ü"] = "Ü", ["ű"] = "Ű"
    }
    -- Először alkalmazzuk a standard upper függvényt
    local upper_str = string.upper(str)
    -- Majd cseréljük ki az ékezetes kisbetűket nagybetűkre
    for lower, upper in pairs(replacements) do
        upper_str = upper_str:gsub(lower, upper)
    end
    return upper_str
end