XLGB_UI = {}

--Credit: Inventory Insight - IIfABackPack.lua

function XLGB_UI:XLGB_Window_Control_OnMoveStop()
  XLGearBanker.savedVariables.left = XLGB_Window_Control:GetLeft()
  XLGearBanker.savedVariables.top = XLGB_Window_Control:GetTop()
end

function XLGB_UI:RestorePosition()
  local left = XLGearBanker.savedVariables.left
  local top = XLGearBanker.savedVariables.top

  XLGB_Window_Control:ClearAnchors()
  XLGB_Window_Control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function XLGB_UI:CycleLeft()
  easyDebug("Cycle left called!")

  local previousSet = XLGearBanker.displayingSet - 1
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()

  if previousSet <= 0 then
    previousSet = totalSets
  end

  XLGearBanker.displayingSet = previousSet
  XLGB_UI:ChangeDisplayedGearSet(previousSet)
end

function XLGB_UI:CycleRight()
  easyDebug("Cycle right called!")

  local nextSet = XLGearBanker.displayingSet + 1
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()

  if nextSet > totalSets then
    nextSet = 1
  end

  XLGearBanker.displayingSet = nextSet
  XLGB_UI:ChangeDisplayedGearSet(nextSet)
end

function XLGB_UI:SetGearNameLabel(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then  
    local gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name

    easyDebug("Setting gear name label to: " .. gearSetName)
    XLGB_Window_Control_ListView_GearTitle:SetText(gearSetName)
  end
end

function XLGB_UI:ChangeDisplayedGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
      XLGB_UI:SetGearNameLabel(tonumber(gearSetNumber))
      XLGB_UI:UpdateListView()
  end
end

function XLGB_UI:ShowUI()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_Window_Control:SetHidden(false)
end

function XLGB_UI:HideUI()
  XLGB_Window_Control:SetHidden(true)
end

function XLGB_UI:RemoveItem()
  easyDebug("Removing item")
end


--[[
function XLGB_UI:UpdateItemDataList(gearSetNumber)

  local items = XLGB_GearSet:GetGearSet(gearSetNumber).items
  
	XLGB_Window_Control_ListView.items = items
	XLGB_Window_Control_ListView.dataOffset = 0

end

local function fillEntryWithItemData(entry, item)
	local color
	if item == nil then
		entry.itemLink = ""
		entry.text:SetText("")
	else
		local r, g, b, a = 255, 255, 255, 1
		if item.quality then
			color = GetItemQualityColor(item.quality)
			r, g, b, a = color:UnpackRGBA()
		end
		entry.itemLink = item.link
		local text = zo_strformat(SI_TOOLTIP_ITEM_NAME, item.name)
		entry.text:SetText(text)
		entry.text:SetColor(r, g, b, a)
	end
end

function XLGB_UI:fillEntriesWithItemData()
    local entry, item = nil
    for i = 1, XLGB_Window_Control_ListView.maxEntries do

      entry = XLGB_Window_Control_ListView.entries[i]
      item = XLGB_Window_Control_ListView.items[XLGB_Window_Control_ListView.dataOffset + i]
      XLGB_Window_Control_ListView.entries[i] = entry

      if entry ~= nil then
        fillEntryWithItemData(entry, item)
      else
        fillEntryWithItemData(entry, nil)
      end
    end
  end

function XLGB_UI:CreateEmptyListEntry(i, predecessor, parent)
	local entry = WINDOW_MANAGER:CreateControlFromVirtual("XLGB_ListItem_".. i, parent, "XLGB_SlotTemplate")

  entry.number = i
	entry.text = entry:GetNamedChild("_Name")
	--entry.remove = entry:GetNamedChild("_RemoveItem")

	entry:SetHidden(false)
	entry:SetMouseEnabled(true)
	entry:SetHeight(XLGB_Window_Control_ListView.rowHeight)

	if i == 1 then
		entry:SetAnchor(TOPLEFT, XLGB_Window_Control_ListView, TOPLEFT, 0, 0)
		entry:SetAnchor(TOPRIGHT, XLGB_Window_Control_ListView, TOPRIGHT, 0, 0)
	else
		entry:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
		entry:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)
	end
	return entry
end

function XLGB_UI:InitializeListEntries()
	easyDebug("InitializeListEntries")

  listview = WINDOW_MANAGER:GetControlByName("XLGB_Window_Control_ListView")
	-- XLGB_Window_Control_ListView.dataOffset = 0

	-- XLGB_Window_Control_ListView.items = {}
  -- XLGB_Window_Control_ListView.entries = {}
  
	--local width = 250 -- XLGB_Window_Control_ListView:GetWidth()

	-- we set those to 35 because that's the amount of lines we can show
	-- within the dimension constraints
  -- XLGB_Window_Control_ListView.maxEntries = 10
  
  listview.dataOffset = 0

	listview.items = {}
  listview.entries = {}
  listview.maxEntries = 10

	local predecessor = nil
	for i = 1, listview.maxEntries do
		XLGB_Window_Control_ListView.entries[i] = XLGB_UI:CreateEmptyListEntry(i, predecessor, listview)
		predecessor = listview.entries[i]
	end

	-- setup slider
	--	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	--	XLGB_Window_Control_ListView_Slider:SetThumbTexture(tex, tex, tex, 16, 50, 0, 0, 1, 1)
	XLGB_Window_Control_ListView_Slider:SetMinMax(0, #listview.items - listview.maxEntries)

	return listview.entries
end

function XLGB_UI:UpdateListViewEntries()
  easyDebug("UpdateListViewEntries")

  if XLGB_Window_Control_ListView.dataOffset < 0 then
    XLGB_Window_Control_ListView.dataOffset = 0
  end

	if XLGB_Window_Control_ListView.maxEntries == nil then
		XLGB_Window_Control_ListView.maxEntries = 10
  end

	XLGB_UI:fillEntriesWithItemData()

	local total = #XLGB_Window_Control_ListView.items - XLGB_Window_Control_ListView.maxEntries
	XLGB_Window_Control_ListView_Slider:SetMinMax(0, total)
end

function XLGB_UI:UpdateListView()
	easyDebug("UpdateListView")
	XLGB_UI:UpdateItemDataList(XLGearBanker.displayingSet)
  XLGB_UI:UpdateListViewEntries()
end

--[[
function XLGB_UI:CreateEmptyListEntry(i, predecessor, parent)
  local entry = WINDOW_MANAGER:CreateControlFromVirtual("XLGB_ListItem_".. i, parent, "XLGB_SlotTemplate")

  entry:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
	entry:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)

  return entry
end

function XLGB_UI:InitializeListEntries()
  XLGB_Window_Control_ListView.maxEntries = 10
  XLGB_Window_Control_ListView.entries = {}
  local predecessor = XLGB_Window_Control_ListView_GearTitle
  for i = 1, 10 do
    local entry = XLGB_UI:CreateEmptyListEntry(i, predecessor, XLGB_Window_Control_ListView)
    table.append(XLGB_Window_Control_ListView.entries, entry)
    predecessor = entry
  end
end
]]

function XLGB_UI:InitializeScrollList()
  XLGB_Window_Control_ListView.scrollList = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_scrollList", XLGB_Window_Control_ListView, "ZO_ScrollList")
  XLGB_Window_Control_ListView.scrollList:SetAnchor(TOPLEFT, XLGB_Window_Control_ListView_GearTitle, BOTTOMLEFT, 0, 0)

end

function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  -- XLGB_Window_Control_ListView.rowHeight = 30
  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeScrollList()
  -- XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGearBanker.debug = true
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end