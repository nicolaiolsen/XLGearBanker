UI = {}

function UI:OnXLGBOverviewMoveStop()
  XLGearBanker.savedVariables.left = XLGBOverview:GetLeft()
  XLGearBanker.savedVariables.top = XLGBOverview:GetTop()
end

function UI:RestorePosition()
  local left = XLGearBanker.savedVariables.left
  local top = XLGearBanker.savedVariables.top

  XLGBOverview:ClearAnchors()
  XLGBOverview:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function UI:UICycleLeft()
  easyDebug("UI cycle left called!")

  local nextSet = XLGearBanker.displayingSet - 1
  local totalSets = GearSet.getAmountOfGearSets()

  if nextSet <= 0 then
    nextSet = totalSets
  end

  XLGearBanker.displayingSet = nextSet
  UI:UISetDisplaySet(nextSet)
end

function UI:UICycleRight()
  easyDebug("UI cycle right called!")

  local nextSet = XLGearBanker.displayingSet + 1
  local totalSets = GearSet.getAmountOfGearSets()

  if nextSet > totalSets then
    nextSet = 1
  end

  XLGearBanker.displayingSet = nextSet
  UI:UISetDisplaySet(nextSet)
end

function UI:UISetGearNameLabel(gearSetNumber)
  local gearSetName = GearSet.getGearSetName(gearSetNumber)
  easyDebug("Setting gear name label to: " .. gearSetName)
  local labelControl = XLGBOverview:GetNamedChild("XLGBOverview_setlabel")
  easyDebug("Labelcontrol: ", labelControl)
  if labelControl then
    labelControl:setText(gearSetName)
  end
end

function UI:UISetDisplaySet(gearSetNumber)
  UI:UISetGearNameLabel(gearSetNumber)
end

function UI:ShowUI()
  XLGBOverview:SetHidden(false)
end

function UI:HideUI()
  XLGBOverview:SetHidden(true)
end
--[[
function UI:UpdateScrollDataLinesData()
  
	local index = 0
	local dataLines = {}
	local DBv3 = IIfA.database
	local itemLink, itemKey, iconFile, itemQuality, tempDataLine = nil
	local itemTypeFilter
	local itemCount
	local match = false
	local bWorn = false
	local dbItem
	local totItems = 0

	if(DBv3)then
		for itemKey, dbItem in pairs(DBv3) do
			if zo_strlen(itemKey) < 10 then
				itemLink = dbItem.itemLink
			else
				itemLink = itemKey
			end

			if (itemKey ~= IIfA.EMPTY_STRING) then

				itemTypeFilter = 0
				if (dbItem.filterType) then
					itemTypeFilter = dbItem.filterType
				end

				itemCount = 0
				bWorn = false
				local itemIcon = GetItemLinkIcon(itemLink)

				local locationName, locData
				local itemCount = 0
				for locationName, locData in pairs(dbItem.locations) do
					itemCount = itemCount + itemSum(locData)
					if DoesInventoryMatchList(locationName, locData) then
						match = true
					end
					bWorn = bWorn or (locData.bagID == BAG_WORN)
				end
				if not dbItem.itemName or #dbItem.itemName == 0 then
					p("Filling in missing itemName/Quality")
					dbItem.itemName = GetItemLinkName(itemLink)
					dbItem.itemQuality = GetItemLinkQuality(itemLink)
				end
				tempDataLine = {
					link = itemLink,
					qty = itemCount,
					icon = itemIcon,
					name = dbItem.itemName,
					quality = dbItem.itemQuality,
					filter = itemTypeFilter,
					worn = bWorn
				}

				if(itemCount > 0) and matchFilter(dbItem.itemName, itemLink) and matchQuality(dbItem.itemQuality) and match then
					table.insert(dataLines, tempDataLine)
					totItems = totItems + (itemCount or 0)
				end
				match = false
			end
		end
	end

	IIFA_GUI_ListHolder.dataLines = dataLines
	sort(IIFA_GUI_ListHolder.dataLines)
	IIFA_GUI_ListHolder.dataOffset = 0

	-- even if the counts aren't visible, update them so they show properly if user turns them on
	IIFA_GUI_ListHolder_Counts_Items:SetText("Item Count: " .. totItems)
	IIFA_GUI_ListHolder_Counts_Slots:SetText("Appx. Slots Used: " .. #dataLines)

end
]]--

function UI:Initialize()
  XLGearBanker.displayingSet = 1
  UI:RestorePosition()
  UI:UISetDisplaySet(XLGearBanker.displayingSet)
end