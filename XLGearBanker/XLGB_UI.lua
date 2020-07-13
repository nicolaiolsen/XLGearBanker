XLGB_UI = {}

local libDialog = LibDialog

function XLGB_UI:XLGB_SetWindow_OnMoveStop()
  XLGearBanker.savedVariables.main_ui_left = XLGB_SetWindow:GetLeft()
  XLGearBanker.savedVariables.main_ui_top = XLGB_SetWindow:GetTop()
end

function XLGB_UI:RestorePosition()
  local left = XLGearBanker.savedVariables.main_ui_left
  local top = XLGearBanker.savedVariables.main_ui_top

  XLGB_SetWindow:ClearAnchors()
  XLGB_SetWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function XLGB_UI:ToggleUI()
  if XLGB_SetWindow:IsHidden() then
    XLGB_UI:ShowUI()
  else
    XLGB_UI:HideUI()
  end
end

function XLGB_UI:ShowUI()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_SetWindow:SetHidden(false)
end

function XLGB_UI:HideUI()
  XLGB_SetWindow:SetHidden(true)
end

function XLGB_UI:OnBankOpen()
  -- local depositControl = XLGB_SetWindow_ListView:GetNamedChild("_Deposit")
  -- local withdrawControl = XLGB_SetWindow_ListView:GetNamedChild("_Withdraw")
  -- local itemAmountControl = XLGB_SetWindow_ListView:GetNamedChild("_ItemAmount")
  -- local addEquippedControl = XLGB_SetWindow_ListView:GetNamedChild("_AddEquipped")

  -- if(XLGearBanker.UI_Editable) then 
  --   itemAmountControl:SetAnchor(BOTTOMLEFT, addEquippedControl, TOPLEFT, 0, -10)
  --   itemAmountControl:SetAnchor(BOTTOMRIGHT, addEquippedControl, TOPRIGHT, 0, -10)
  -- else
  --   itemAmountControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
  --   itemAmountControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)
  -- end

  -- addEquippedControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
  -- addEquippedControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)

  -- depositControl:SetHidden(false)
  -- depositControl:SetMouseEnabled(true)

  -- withdrawControl:SetHidden(false)
  -- withdrawControl:SetMouseEnabled(true)
  XLGB_UI:ShowUI()
end

function XLGB_UI:OnBankClosed()
  -- local depositControl = XLGB_SetWindow_ListView:GetNamedChild("_Deposit")
  -- local withdrawControl = XLGB_SetWindow_ListView:GetNamedChild("_Withdraw")
  -- local itemAmountControl = XLGB_SetWindow_ListView:GetNamedChild("_ItemAmount")
  -- local addEquippedControl = XLGB_SetWindow_ListView:GetNamedChild("_AddEquipped")

  -- if(XLGearBanker.UI_Editable) then 
  --   itemAmountControl:SetAnchor(BOTTOMLEFT, addEquippedControl, TOPLEFT, 0, -10)
  --   itemAmountControl:SetAnchor(BOTTOMRIGHT, addEquippedControl, TOPRIGHT, 0, -10)
  -- else
  --   itemAmountControl:SetAnchor(BOTTOMLEFT, XLGB_SetWindow_ListView, BOTTOMLEFT, 0, -10)
  --   itemAmountControl:SetAnchor(BOTTOMRIGHT, XLGB_SetWindow_ListView, BOTTOMRIGHT, 0, -10)
  -- end

  -- addEquippedControl:SetAnchor(BOTTOMLEFT, XLGB_SetWindow_ListView, BOTTOMLEFT, 0, -10)
  -- addEquippedControl:SetAnchor(BOTTOMRIGHT, XLGB_SetWindow_ListView, BOTTOMRIGHT, 0, -10)

  -- depositControl:SetHidden(true)
  -- depositControl:SetMouseEnabled(false)

  -- withdrawControl:SetHidden(true)
  -- withdrawControl:SetMouseEnabled(false)
  XLGB_UI:HideUI()
end

function XLGB_UI:SelectEntireTextbox(gearTitleControl)
  gearTitleControl:SelectAll()
end

local function areThereAnyChanges()
  local gearTitleControl = XLGB_SetWindow_ListView:GetNamedChild("_GearTitle")
  if (gearTitleControl:GetText() == XLGearBanker.UI_GearSetNameBefore) 
  and not(XLGearBanker.itemChanges) then 
    return false
  end
  return true
end

local function setEditFalse()
  local editControl = XLGB_SetWindow_ListView:GetNamedChild("_Edit")
  local gearTitleControl = XLGB_SetWindow_ListView:GetNamedChild("_GearTitle")
  local acceptControl = XLGB_SetWindow_ListView:GetNamedChild("_AcceptEdit")
  local removeControl = XLGB_SetWindow_ListView:GetNamedChild("_RemoveSet")
  local addEquippedControl = XLGB_SetWindow_ListView:GetNamedChild("_AddEquipped")
  local itemAmountControl = XLGB_SetWindow_ListView:GetNamedChild("_ItemAmount")

  XLGearBanker.UI_Editable = false
  gearTitleControl:ClearSelection()
  gearTitleControl:SetEditEnabled(false)
  gearTitleControl:SetCursorPosition(0)
  gearTitleControl:LoseFocus()
  gearTitleControl:SetMouseEnabled(false)
  gearTitleControl:SetAnchor(TOPRIGHT, editControl, TOPLEFT, -10, 0)
  editControl:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
  editControl:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
  editControl:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
  acceptControl:SetHidden(true)
  removeControl:SetHidden(true)
  addEquippedControl:SetHidden(true)

  if(XLGB_Banking.bankOpen) then
    local depositControl = XLGB_SetWindow_ListView:GetNamedChild("_Deposit")
    local withdrawControl = XLGB_SetWindow_ListView:GetNamedChild("_Withdraw")
    itemAmountControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)
  else
    itemAmountControl:SetAnchor(BOTTOMLEFT, XLGB_SetWindow_ListView, BOTTOMLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, XLGB_SetWindow_ListView, BOTTOMRIGHT, 0, -10)
  end
  ZO_ScrollList_RefreshVisible(XLGB_SetWindow_ListView.scrollList)
end

local function setEditTrue()
  local editControl = XLGB_SetWindow_ListView:GetNamedChild("_Edit")
  local gearTitleControl = XLGB_SetWindow_ListView:GetNamedChild("_GearTitle")
  local acceptControl = XLGB_SetWindow_ListView:GetNamedChild("_AcceptEdit")
  local removeControl = XLGB_SetWindow_ListView:GetNamedChild("_RemoveSet")
  local addEquippedControl = XLGB_SetWindow_ListView:GetNamedChild("_AddEquipped")
  local itemAmountControl = XLGB_SetWindow_ListView:GetNamedChild("_ItemAmount")

  XLGearBanker.UI_Editable = true
  XLGearBanker.UI_GearSetNameBefore = gearTitleControl:GetText()
  gearTitleControl:SetEditEnabled(true)
  gearTitleControl:SelectAll()
  gearTitleControl:TakeFocus()
  gearTitleControl:SetMouseEnabled(true)
  gearTitleControl:SetAnchor(TOPRIGHT, removeControl, TOPLEFT, -10, 0)
  editControl:SetNormalTexture("/esoui/art/buttons/edit_cancel_up.dds")
  editControl:SetPressedTexture("/esoui/art/buttons/edit_cancel_down.dds")
  editControl:SetMouseOverTexture("/esoui/art/buttons/edit_cancel_over.dds")
  acceptControl:SetHidden(false)
  removeControl:SetHidden(false)

  itemAmountControl:SetAnchor(BOTTOMLEFT, addEquippedControl, TOPLEFT, 0, -10)
  itemAmountControl:SetAnchor(BOTTOMRIGHT, addEquippedControl, TOPRIGHT, 0, -10)

  addEquippedControl:SetHidden(false)

  ZO_ScrollList_RefreshVisible(XLGB_SetWindow_ListView.scrollList)
end

local function acceptChanges()
  XLGearBanker.copyOfSet = {}
  setEditFalse()
  d("[XLGB] Gear set changes accepted!")
end

function XLGB_UI:AcceptEdit(acceptControl)
  local gearTitleControl = XLGB_SetWindow_ListView:GetNamedChild("_GearTitle")
  local newGearName = gearTitleControl:GetText()

  if newGearName == XLGearBanker.UI_GearSetNameBefore then
    if not(XLGearBanker.itemChanges) then
      setEditFalse()
    else
      libDialog:ShowDialog("XLGearBanker", "AcceptChanges", nil)
    end
  else
    if XLGB_GearSet:EditGearSetName(newGearName, XLGearBanker.displayingSet) then
      setEditFalse()
      d("[XLGB] Gearset renamed to '" .. newGearName .. "'.")
      if not(XLGearBanker.itemChanges) then
        setEditFalse()
      else
        libDialog:ShowDialog("XLGearBanker", "AcceptChanges", nil)
      end
    end
  end
  ZO_ScrollList_RefreshVisible(XLGB_SetWindow_ListView.scrollList)
end

local function discardChanges()
  local gearTitleControl = XLGB_SetWindow_ListView:GetNamedChild("_GearTitle")

  XLGearBanker.savedVariables.gearSetList[XLGearBanker.displayingSet] = XLGearBanker.copyOfSet
  XLGearBanker.copyOfSet = {}
  setEditFalse()
  gearTitleControl:SetText(XLGearBanker.UI_GearSetNameBefore)
  gearTitleControl:SetCursorPosition(0)
  XLGB_UI:UpdateScrollList()
end

local function discardChangesAndCycle(dialog)
  discardChanges()
  XLGearBanker.displayingSet = dialog.data
  XLGB_UI:ChangeDisplayedGearSet(dialog.data)
end

function XLGB_UI:ToggleEdit(editControl)
  if XLGearBanker.UI_Editable then
    if areThereAnyChanges() then
      libDialog:ShowDialog("XLGearBanker", "DiscardChangesDialog", nil)
    else
      discardChanges()
    end
  else
    XLGearBanker.copyOfSet = XLGB_GearSet:CopyGearSet(XLGearBanker.displayingSet)
    XLGearBanker.itemChanges = false
    XLGearBanker.nameChanges = false
    setEditTrue()
  end
end

function XLGB_UI:AddSet(addControl)
  local editControl = XLGB_SetWindow_ListView:GetNamedChild("_Edit")
  if XLGearBanker.UI_Editable then 
    XLGB_UI:ToggleEdit(editControl)
  end

  XLGB_GearSet:GenerateNewSet()
  XLGearBanker.displayingSet = XLGB_GearSet:GetNumberOfGearSets()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)

  XLGB_UI:ToggleEdit(editControl)
end

local function removeSetConfirmed()
  XLGB_GearSet:RemoveGearSet(XLGearBanker.displayingSet)

  setEditFalse()

  XLGB_UI:CycleLeft()
end

function XLGB_UI:RemoveSet(removeControl) 
  if #XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet).items == 0 then
    removeSetConfirmed()
  else
    libDialog:ShowDialog("XLGearBanker", "RemoveSetDialog", nil)
  end
  
end

function XLGB_UI:CycleLeft()
  easyDebug("Cycle left called!")

  local previousSet = XLGearBanker.displayingSet - 1
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()

  if totalSets > 0 then 
    if previousSet <= 0 then
      previousSet = totalSets
    end

    if XLGearBanker.UI_Editable then
      if areThereAnyChanges() then
        libDialog:ShowDialog("XLGearBanker", "DiscardChangesAndCycleDialog", previousSet)
      else
        discardChangesAndCycle({data = previousSet})
      end
    else
      XLGearBanker.displayingSet = previousSet
      XLGB_UI:ChangeDisplayedGearSet(previousSet)
    end
  else
    XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  end
end

function XLGB_UI:CycleRight()
  easyDebug("Cycle right called!")

  local nextSet = XLGearBanker.displayingSet + 1
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()
  if totalSets > 0 then 
    if nextSet > totalSets then
      nextSet = 1
    end

    if XLGearBanker.UI_Editable then
      if areThereAnyChanges() then
        libDialog:ShowDialog("XLGearBanker", "DiscardChangesAndCycleDialog", nextSet)
      else
        discardChangesAndCycle({data = nextSet})
      end
    else
      XLGearBanker.displayingSet = nextSet
      XLGB_UI:ChangeDisplayedGearSet(nextSet)
    end
  else
    XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  end
end

function XLGB_UI:SetGearNameLabel(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then  
    local gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name

    easyDebug("Setting gear name label to: " .. gearSetName)
    XLGB_SetWindow_ListView_GearTitle:SetText(gearSetName)
  end
end

function XLGB_UI:ChangeDisplayedGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local setRow = XLGB_SetWindow_SetRow
  local editSet = setRow:GetNamedChild("_EditSet")

  if totalGearSets == 0 then
    editSet:SetHidden(true)
    XLGB_UI:UpdateScrollList()
  else
    if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
      -- XLGB_UI:SetGearNameLabel(tonumber(gearSetNumber))
      if not(XLGearBanker.UI_Editable) then
      end
      editSet:SetHidden(false)
      XLGB_UI:UpdateScrollList()
    end
  end
end



function XLGB_UI:RemoveItem(removeItemControl)
  easyDebug("Removing item")
  local itemRowControl = removeItemControl:GetParent()
  local itemLink = itemRowControl.data.itemLink
  local itemID = itemRowControl.data.itemID
  XLGearBanker.itemChanges = true
  XLGB_GearSet:RemoveItemFromGearSet(itemLink, itemID, XLGearBanker.displayingSet)
end

local function addEquippedItemsToGearSet()
  XLGB_GearSet:AddEquippedItemsToGearSet(XLGearBanker.displayingSet)
  XLGB_UI:UpdateScrollList()
end

function XLGB_UI:AddEquippedItemsToSet()
  -- libDialog:ShowDialog("XLGearBanker", "AddEquippedItemsToSet", nil)
  XLGearBanker.itemChanges = true
  XLGB_GearSet:AddEquippedItemsToGearSet(XLGearBanker.displayingSet)
  XLGB_UI:UpdateScrollList()
end

function XLGB_UI:DepositSet()
  XLGB_Banking:DepositGear(XLGearBanker.displayingSet)
end

function XLGB_UI:WithdrawSet()
  XLGB_Banking:WithdrawGear(XLGearBanker.displayingSet)
end

local function ShowItemTooltip(self)
  InitializeTooltip(ItemTooltip, self)
  ItemTooltip:SetLink(self.data.itemLink)
end

local function HideItemTooltip(control)
  ClearTooltip(ItemTooltip)
end

function XLGB_UI:UpdateScrollList()
  local scrollList = XLGB_SetWindow.scrollList
  local totalSetItems = XLGB_SetWindow_TotalSetItemsRow_TotalSetItems
  local scrollData = ZO_ScrollList_GetDataList(scrollList)
  ZO_ScrollList_Clear(scrollList)
  totalSetItems:SetText("Total items in set: 0")
  if XLGB_GearSet:GetNumberOfGearSets() > 0 then
    local gearSet = XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet)
    for _, item in pairs(gearSet.items) do
      local dataEntry = ZO_ScrollList_CreateDataEntry(XLGB_Constants.ITEM_ROW, {
        itemName = item.name,
        itemLink = item.link,
        itemID = item.ID
      })
      table.insert(scrollData, dataEntry)
    end
    totalSetItems:SetText("Total items in set: ".. #XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet).items)
  end
  ZO_ScrollList_Commit(XLGB_SetWindow.scrollList)
end

local function fillItemRowWithData(control, data)
  control.data = data
  control:GetNamedChild("_Name"):SetText(data.itemLink)
  control:SetMouseEnabled(true)
  control:SetHandler("OnMouseEnter", ShowItemTooltip)
  control:SetHandler("OnMouseExit", HideItemTooltip)
  if XLGearBanker.UI_Editable then
    control:GetNamedChild("_Remove"):SetHidden(false)
  else 
    control:GetNamedChild("_Remove"):SetHidden(true)
  end
end

function XLGB_UI:InitializeScrollList()
  XLGB_SetWindow.scrollList = XLGB_SetWindow:GetNamedChild("_ScrollList")
  ZO_ScrollList_AddDataType(XLGB_SetWindow.scrollList, XLGB_Constants.ITEM_ROW, "XLGB_Item_Row_Template", 35, fillItemRowWithData)
  ZO_ScrollList_EnableHighlight(XLGB_SetWindow.scrollList, "ZO_ThinListHighlight")
  XLGB_UI:UpdateScrollList()
end

function XLGB_UI:SetupDialogs()

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "RemoveSetDialog", 
    "XL Gear Banker", 
    "You are about to remove the set.\n\nAre you sure you want the set removed?",
    removeSetConfirmed, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "AcceptChanges", 
    "XL Gear Banker", 
    "You have added/removed items to/from this set.\n\nAre you sure you want to keep these changes?", 
    acceptChanges, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardChangesDialog", 
    "XL Gear Banker", 
    "Looks like you've edited the current set and are about to discard any changes you've made including recently added/removed items.\n\nAre you sure?", 
    discardChanges, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardChangesAndCycleDialog", 
    "XL Gear Banker", 
    "Looks like you've edited the current set and are about to discard any changes you've made including recently added/removed items.\n\nAre you sure?", 
    discardChangesAndCycle, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "AddEquippedItemsToSet", 
    "XL Gear Banker", 
    "You're about to add all of your your currently equipped items to this item set.\n\nAre you sure?", 
    addEquippedItemsToGearSet, 
    nil,
    nil) 
   

end

function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  XLGearBanker.UI_Editable = false
  XLGearBanker.copyOfSet = {}
  XLGearBanker.itemChanges = false
  XLGearBanker.nameChanges = false
  XLGearBanker.UI_ItemsMarkedForRemoval = {}
  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeScrollList()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_UI:SetupDialogs()
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end