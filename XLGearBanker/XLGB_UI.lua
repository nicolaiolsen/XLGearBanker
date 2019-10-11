XLGB_UI = {}

function XLGB_UI:XLGB_UI_Control_OnMoveStop()
  XLGearBanker.savedVariables.left = XLGB_UI_Control:GetLeft()
  XLGearBanker.savedVariables.top = XLGB_UI_Control:GetTop()
end

function XLGB_UI:RestorePosition()
  local left = XLGearBanker.savedVariables.left
  local top = XLGearBanker.savedVariables.top

  XLGB_UI_Control:ClearAnchors()
  XLGB_UI_Control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function XLGB_UI:CycleLeft()
  easyDebug("Cycle left called!")

  local previousSet = XLGearBanker.displayingSet - 1
  local totalSets = XLGB_GearSet:GetAmountOfGearSets()

  if previousSet <= 0 then
    previousSet = totalSets
  end

  XLGearBanker.displayingSet = previousSet
  XLGB_UI:ChangeDisplayedGearSet(previousSet)
end

function XLGB_UI:CycleRight()
  easyDebug("Cycle right called!")

  local nextSet = XLGearBanker.displayingSet + 1
  local totalSets = XLGB_GearSet:GetAmountOfGearSets()

  if nextSet > totalSets then
    nextSet = 1
  end

  XLGearBanker.displayingSet = nextSet
  XLGB_UI:ChangeDisplayedGearSet(nextSet)
end

function XLGB_UI:SetGearNameLabel(gearSetNumber)
  local gearSetName = XLGB_GearSet:GetGearSetName(gearSetNumber)

  easyDebug("Setting gear name label to: " .. gearSetName)
  XLGB_UI_Control_ListView_GearTitle:SetText(gearSetName)

end

function XLGB_UI:ChangeDisplayedGearSet(gearSetNumber)
  if gearSetNumber ~= nil  
    or gearSetNumber >= 1 
    or gearSetNumber <= XLGB_GearSet:GetAmountOfGearSets() then
      XLGB_UI:SetGearNameLabel(gearSetNumber)
      XLGB_UI:UpdateListView()
  end
end

function XLGB_UI:ShowUI()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_UI_Control:SetHidden(false)
end

function XLGB_UI:HideUI()
  XLGB_UI_Control:SetHidden(true)
end

function XLGB_UI:RemoveItem()
  easyDebug("Removing item")
end

-- Credit: Inventory Insight - IIfABackPack.lua -> IIfA:UpdateScrollDataLinesData
function XLGB_UI:UpdateItemDataList(gearSetNumber)

  local items = XLGB_GearSet:GetGearSet(gearSetNumber)
  
	XLGB_UI_Control_ListView.items = items
	XLGB_UI_Control_ListView.dataOffset = 0

end

-- Credit: Inventory Insight - IIfABackPack.lua -> fillLine
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

-- Credit: Inventory Insight - IIfABackPack.lua -> IIfA:SetDataLinesData
function XLGB_UI:fillEntriesWithItemData()
    local entry, item
    for i = 1, XLGB_UI_Control_ListView.maxEntries do

      entry = XLGB_UI_Control_ListView.entries[i]
      item = XLGB_UI_Control_ListView.items[XLGB_UI_Control_ListView.dataOffset + i]
      XLGB_UI_Control_ListView.lines[i] = entry

      if entry ~= nil then
        fillEntryWithItemData(entry, item)
      else
        fillEntryWithItemData(entry, nil)
      end
    end
  end

--Credit: Inventory Insight - IIfABackPack.lua -> IIfA:CreateLine
function XLGB_UI:CreateEmptyListEntry(i, predecessor, parent)
	local entry = WINDOW_MANAGER:CreateControlFromVirtual("XLGB_ListItem_".. i, parent, "XLGB_SlotTemplate")

  entry.number = i
	entry.text = entry:GetNamedChild("Name")
	entry.remove = entry:GetNamedChild("RemoveItem")

	entry:SetHidden(false)
	entry:SetMouseEnabled(true)
	entry:SetHeight(XLGB_UI_Control_ListView.rowHeight)

	if i == 1 then
		entry:SetAnchor(TOPLEFT, XLGB_UI_Control_ListView, TOPLEFT, 0, 0)
		entry:SetAnchor(TOPRIGHT, XLGB_UI_Control_ListView, TOPRIGHT, 0, 0)
	else
		entry:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
		entry:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)
	end
	return entry
end

-- Credit: Inventory Insight -  IIfABackPack.lua -> IIfA:CreateInventoryScroll
function XLGB_UI:InitializeListEntries()
	easyDebug("InitializeListEntries")

	XLGB_UI_Control_ListView.dataOffset = 0

	XLGB_UI_Control_ListView.items = {}
  XLGB_UI_Control_ListView.entries = {}
  
	--local width = 250 -- XLGB_UI_Control_ListView:GetWidth()

	-- we set those to 35 because that's the amount of lines we can show
	-- within the dimension constraints
	XLGB_UI_Control_ListView.maxEntries = 35
	local predecessor = nil
	for i = 1, XLGB_UI_Control_ListView.maxEntries do
		XLGB_UI_Control_ListView.entries[i] = XLGB_UI:CreateEmptyListEntry(i, predecessor, XLGB_UI_Control_ListView)
		predecessor = XLGB_UI_Control_ListView.entries[i]
	end

	-- setup slider
	--	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	--	XLGB_UI_Control_ListView_Slider:SetThumbTexture(tex, tex, tex, 16, 50, 0, 0, 1, 1)
	XLGB_UI_Control_ListView_Slider:SetMinMax(0, #XLGB_UI_Control_ListView.items - XLGB_UI_Control_ListView.maxEntries)

	return XLGB_UI_Control_ListView.entries
end

-- Credit: Inventory Insight -  IIfABackPack.lua -> IIfA:UpdateInventoryScroll
function XLGB_UI:UpdateListViewEntries()
  easyDebug("UpdateListViewEntries")

  if XLGB_UI_Control_ListView.dataOffset < 0 then 
    XLGB_UI_Control_ListView.dataOffset = 0 
  end

	if XLGB_UI_Control_ListView.maxLines == nil then
		XLGB_UI_Control_ListView.maxLines = 35
  end
  
	XLGB_UI:fillEntriesWithItemData()

	local total = #XLGB_UI_Control_ListView.dataLines - XLGB_UI_Control_ListView.maxLines
	XLGB_UI_Control_ListView_Slider:SetMinMax(0, total)
end

-- Credit: Inventory Insight -  IIfABackPack.lua -> IIfA:RefreshInventoryScroll
function XLGB_UI:UpdateListView()
	easyDebug("UpdateListView")
	XLGB_UI:UpdateItemDataList(XLGearBanker.displayingSet)
  XLGB_UI:UpdateListViewEntries()
end
---------
-- This block is for testing purposes only



---------
function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  XLGB_UI:RestorePosition()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)

  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end