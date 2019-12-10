XLGB_UI = {}

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

function XLGB_UI:SelectEntireTextbox(control)
  control:SelectAll()
end

function XLGB_UI:OnTextboxTextChanged(control)
  
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
      XLGB_UI:UpdateScrollList(tonumber(gearSetNumber))
  end
end

function XLGB_UI:ShowUI()
  --XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_Window_Control:SetHidden(false)
end

function XLGB_UI:HideUI()
  XLGB_Window_Control:SetHidden(true)
end

function XLGB_UI:RemoveItem()
  easyDebug("Removing item")
end

function XLGB_UI:UpdateScrollList(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  local scrollList = XLGB_Window_Control_ListView:GetNamedChild("_ScrollList")
  local scrollData = ZO_ScrollList_GetDataList(scrollList)
  ZO_ScrollList_Clear(scrollList)
  for _, item in pairs(gearSet.items) do
      local dataEntry = ZO_ScrollList_CreateDataEntry(XLGB_Constants.ITEM_ROW, {
        itemName = item.name,
        itemLink = item.link,
        itemID = item.ID
      })
      --scrollData[#scrollData + 1] = dataEntry
      table.insert(scrollData, dataEntry)
  end
  ZO_ScrollList_Commit(XLGB_Window_Control_ListView.scrollList)
end

local function fillItemRowWithData(control, data)
  control:GetNamedChild("_Name"):SetText(data.itemLink)
  --control:GetNamedChild("_Remove"):SetText(data.itemID)
end

function XLGB_UI:InitializeScrollList()
  XLGB_Window_Control_ListView.scrollList = XLGB_Window_Control_ListView:GetNamedChild("_ScrollList")
  ZO_ScrollList_EnableHighlight(XLGB_Window_Control_ListView.scrollList, "ZO_ThinListHighlight")
  ZO_ScrollList_AddDataType(XLGB_Window_Control_ListView.scrollList, XLGB_Constants.ITEM_ROW, "XLGB_Item_Row_Template", 35, fillItemRowWithData)
  XLGB_UI:UpdateScrollList(XLGearBanker.displayingSet)
end

function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeScrollList()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGearBanker.debug = true
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end