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

function XLGB_UI:SelectEntireTextbox(gearTitleControl)
  gearTitleControl:SelectAll()
end

local function setEditFalse(editControl, gearTitleControl, acceptControl)
  XLGearBanker.UI_Editable = false
  gearTitleControl:ClearSelection()
  gearTitleControl:SetEditEnabled(false)
  gearTitleControl:SetMouseEnabled(false)
  gearTitleControl:SetColor(255, 204, 102, 100)
  editControl:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
  editControl:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
  editControl:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
  acceptControl:SetHidden(true)
end

function XLGB_UI:AcceptEdit(acceptControl)
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local editControl = XLGB_Window_Control_ListView:GetNamedChild("_Edit")

  local newGearName = gearTitleControl:GetText()
  if XLGB_GearSet:EditGearSetName(newGearName, XLGearBanker.displayingSet) then
    d("[XLGB] Gearset renamed to '" .. newGearName .. "'.")
    setEditFalse(editControl, gearTitleControl, acceptControl)
    ZO_ScrollList_RefreshVisible(XLGB_Window_Control_ListView.scrollList)
  end
end

function XLGB_UI:ToggleEdit(editControl)
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local acceptControl = XLGB_Window_Control_ListView:GetNamedChild("_AcceptEdit")
  if XLGearBanker.UI_Editable then
    setEditFalse(editControl, gearTitleControl, acceptControl)
    gearTitleControl:SetText(XLGearBanker.UI_GearSetNameBefore)
  else
    XLGearBanker.UI_Editable = true
    XLGearBanker.UI_GearSetNameBefore = gearTitleControl:GetText()
    gearTitleControl:SetEditEnabled(true)
    gearTitleControl:SelectAll()
    gearTitleControl:SetMouseEnabled(true)
    gearTitleControl:SetColor(255, 255, 255, 100)
    editControl:SetNormalTexture("/esoui/art/buttons/edit_cancel_up.dds")
    editControl:SetPressedTexture("/esoui/art/buttons/edit_cancel_down.dds")
    editControl:SetMouseOverTexture("/esoui/art/buttons/edit_cancel_over.dds")
    acceptControl:SetHidden(false)
    
  end
  ZO_ScrollList_RefreshVisible(XLGB_Window_Control_ListView.scrollList)
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

function XLGB_UI:UpdateScrollList()
  local gearSet = XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet)
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
  if XLGearBanker.UI_Editable then
    control:GetNamedChild("_Remove"):SetHidden(false)
  else 
    control:GetNamedChild("_Remove"):SetHidden(true)
  end
end

function XLGB_UI:InitializeScrollList()
  XLGB_Window_Control_ListView.scrollList = XLGB_Window_Control_ListView:GetNamedChild("_ScrollList")
  ZO_ScrollList_EnableHighlight(XLGB_Window_Control_ListView.scrollList, "ZO_ThinListHighlight")
  ZO_ScrollList_AddDataType(XLGB_Window_Control_ListView.scrollList, XLGB_Constants.ITEM_ROW, "XLGB_Item_Row_Template", 35, fillItemRowWithData)
  XLGB_UI:UpdateScrollList()
end

function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  XLGearBanker.UI_Editable = false
  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeScrollList()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGearBanker.debug = true
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end