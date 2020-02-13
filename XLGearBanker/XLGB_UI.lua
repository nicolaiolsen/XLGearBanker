XLGB_UI = {}

local libDialog = LibDialog

function XLGB_UI:XLGB_Window_Control_OnMoveStop()
  XLGearBanker.savedVariables.main_ui_left = XLGB_Window_Control:GetLeft()
  XLGearBanker.savedVariables.main_ui_top = XLGB_Window_Control:GetTop()
end

function XLGB_UI:RestorePosition()
  local left = XLGearBanker.savedVariables.main_ui_left
  local top = XLGearBanker.savedVariables.main_ui_top

  XLGB_Window_Control:ClearAnchors()
  XLGB_Window_Control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function XLGB_UI:ToggleUI()
  if XLGB_Window_Control:IsHidden() then
    XLGB_UI:ShowUI()
  else
    XLGB_UI:HideUI()
  end
end

function XLGB_UI:ShowUI()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_Window_Control:SetHidden(false)
end

function XLGB_UI:HideUI()
  XLGB_Window_Control:SetHidden(true)
end

function XLGB_UI:OnBankOpen()
  local depositControl = XLGB_Window_Control_ListView:GetNamedChild("_Deposit")
  local withdrawControl = XLGB_Window_Control_ListView:GetNamedChild("_Withdraw")
  local itemAmountControl = XLGB_Window_Control_ListView:GetNamedChild("_ItemAmount")
  local addEquippedControl = XLGB_Window_Control_ListView:GetNamedChild("_AddEquipped")

  if(XLGearBanker.UI_Editable) then 
    itemAmountControl:SetAnchor(BOTTOMLEFT, addEquippedControl, TOPLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, addEquippedControl, TOPRIGHT, 0, -10)
  else
    itemAmountControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)
  end

  addEquippedControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
  addEquippedControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)

  depositControl:SetHidden(false)
  depositControl:SetMouseEnabled(true)

  withdrawControl:SetHidden(false)
  withdrawControl:SetMouseEnabled(true)
  XLGB_UI:ShowUI()
end

function XLGB_UI:OnBankClosed()
  local depositControl = XLGB_Window_Control_ListView:GetNamedChild("_Deposit")
  local withdrawControl = XLGB_Window_Control_ListView:GetNamedChild("_Withdraw")
  local itemAmountControl = XLGB_Window_Control_ListView:GetNamedChild("_ItemAmount")
  local addEquippedControl = XLGB_Window_Control_ListView:GetNamedChild("_AddEquipped")

  if(XLGearBanker.UI_Editable) then 
    itemAmountControl:SetAnchor(BOTTOMLEFT, addEquippedControl, TOPLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, addEquippedControl, TOPRIGHT, 0, -10)
  else
    itemAmountControl:SetAnchor(BOTTOMLEFT, XLGB_Window_Control_ListView, BOTTOMLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, XLGB_Window_Control_ListView, BOTTOMRIGHT, 0, -10)
  end

  addEquippedControl:SetAnchor(BOTTOMLEFT, XLGB_Window_Control_ListView, BOTTOMLEFT, 0, -10)
  addEquippedControl:SetAnchor(BOTTOMRIGHT, XLGB_Window_Control_ListView, BOTTOMRIGHT, 0, -10)

  depositControl:SetHidden(true)
  depositControl:SetMouseEnabled(false)

  withdrawControl:SetHidden(true)
  withdrawControl:SetMouseEnabled(false)
  XLGB_UI:HideUI()
end

function XLGB_UI:SelectEntireTextbox(gearTitleControl)
  gearTitleControl:SelectAll()
end

local function areThereAnyChanges()
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  if (gearTitleControl:GetText() == XLGearBanker.UI_GearSetNameBefore) 
  and #XLGearBanker.UI_ItemsMarkedForRemoval == 0 then 
    return false
  end
  return true
end

local function setEditFalse()
  local editControl = XLGB_Window_Control_ListView:GetNamedChild("_Edit")
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local acceptControl = XLGB_Window_Control_ListView:GetNamedChild("_AcceptEdit")
  local removeControl = XLGB_Window_Control_ListView:GetNamedChild("_RemoveSet")
  local addEquippedControl = XLGB_Window_Control_ListView:GetNamedChild("_AddEquipped")
  local itemAmountControl = XLGB_Window_Control_ListView:GetNamedChild("_ItemAmount")

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
    local depositControl = XLGB_Window_Control_ListView:GetNamedChild("_Deposit")
    local withdrawControl = XLGB_Window_Control_ListView:GetNamedChild("_Withdraw")
    itemAmountControl:SetAnchor(BOTTOMLEFT, depositControl, TOPLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, withdrawControl, TOPRIGHT, 0, -10)
  else
    itemAmountControl:SetAnchor(BOTTOMLEFT, XLGB_Window_Control_ListView, BOTTOMLEFT, 0, -10)
    itemAmountControl:SetAnchor(BOTTOMRIGHT, XLGB_Window_Control_ListView, BOTTOMRIGHT, 0, -10)
  end
  ZO_ScrollList_RefreshVisible(XLGB_Window_Control_ListView.scrollList)
end

local function setEditTrue()
  local editControl = XLGB_Window_Control_ListView:GetNamedChild("_Edit")
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local acceptControl = XLGB_Window_Control_ListView:GetNamedChild("_AcceptEdit")
  local removeControl = XLGB_Window_Control_ListView:GetNamedChild("_RemoveSet")
  local addEquippedControl = XLGB_Window_Control_ListView:GetNamedChild("_AddEquipped")
  local itemAmountControl = XLGB_Window_Control_ListView:GetNamedChild("_ItemAmount")

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

  ZO_ScrollList_RefreshVisible(XLGB_Window_Control_ListView.scrollList)
end

local function removeItemsMarkedForRemoval()
  XLGB_GearSet:RemoveItemsFromGearSet(XLGearBanker.UI_ItemsMarkedForRemoval ,XLGearBanker.displayingSet)
  XLGearBanker.UI_ItemsMarkedForRemoval = {}
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  setEditFalse()
end

function XLGB_UI:AcceptEdit(acceptControl)
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local newGearName = gearTitleControl:GetText()

  if newGearName == XLGearBanker.UI_GearSetNameBefore then
    if #XLGearBanker.UI_ItemsMarkedForRemoval == 0 then
      setEditFalse()
    else
      libDialog:ShowDialog("XLGearBanker", "RemoveMarkedItems", nil)
    end
  else
    if XLGB_GearSet:EditGearSetName(newGearName, XLGearBanker.displayingSet) then
      setEditFalse()
      d("[XLGB] Gearset renamed to '" .. newGearName .. "'.")
      if #XLGearBanker.UI_ItemsMarkedForRemoval == 0 then
        setEditFalse()
      else
        libDialog:ShowDialog("XLGearBanker", "RemoveMarkedItems", nil)
      end
    end
  end
  ZO_ScrollList_RefreshVisible(XLGB_Window_Control_ListView.scrollList)
end

local function discardChanges()
  local gearTitleControl = XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")

  XLGearBanker.UI_ItemsMarkedForRemoval = {}
  setEditFalse()
  gearTitleControl:SetText(XLGearBanker.UI_GearSetNameBefore)
  gearTitleControl:SetCursorPosition(0)
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
    setEditTrue()
  end
end

function XLGB_UI:AddSet(addControl) 
  local editControl = XLGB_Window_Control_ListView:GetNamedChild("_Edit")
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
    XLGB_Window_Control_ListView_GearTitle:SetText(gearSetName)
  end
end

function XLGB_UI:ChangeDisplayedGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local editControl = XLGB_Window_Control_ListView:GetNamedChild("_Edit")
  local gearTitleControl =  XLGB_Window_Control_ListView:GetNamedChild("_GearTitle")
  local setXofYControl = XLGB_Window_Control_ListView:GetNamedChild("_SetXofY")
  

  if totalGearSets == 0 then
    editControl:SetHidden(true)
    gearTitleControl:SetText("No sets found")
    gearTitleControl:SetCursorPosition(0)
    gearTitleControl:SetAnchor(TOPRIGHT, editControl, TOPLEFT, -10, 0)
    setXofYControl:SetText("[0/0]")
    XLGB_UI:UpdateScrollList()
  else
    if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
      XLGB_UI:SetGearNameLabel(tonumber(gearSetNumber))
      gearTitleControl:SetCursorPosition(0)
      if not(XLGearBanker.UI_Editable) then
        gearTitleControl:SetAnchor(TOPRIGHT, editControl, TOPLEFT, -10, 0)
      end
      editControl:SetHidden(false)
      setXofYControl:SetText("[".. gearSetNumber .."/".. XLGB_GearSet:GetNumberOfGearSets() .."]")
      XLGB_UI:UpdateScrollList()
    end
  end
end

local function isItemMarkedForRemoval(itemID)
  for _, markedID in pairs(XLGearBanker.UI_ItemsMarkedForRemoval) do
    if itemID == markedID then
      return true
    end
  end
  return false
end

local function toggleToBeRemoved(itemRowControl)
  local itemNameControl = itemRowControl:GetNamedChild("_Name")
  local removeItemControl = itemRowControl:GetNamedChild("_Remove")
  if isItemMarkedForRemoval(itemRowControl.data.itemID) then
    itemNameControl:SetText(itemRowControl.data.itemName)
    itemNameControl:SetColor(155, 0, 0, 100)
    
    removeItemControl:SetNormalTexture("/esoui/art/buttons/edit_cancel_up.dds")
    removeItemControl:SetPressedTexture("/esoui/art/buttons/edit_cancel_down.dds")
    removeItemControl:SetMouseOverTexture("/esoui/art/buttons/edit_cancel_over.dds")
  else
    itemNameControl:SetText(itemRowControl.data.itemLink)
    
    removeItemControl:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    removeItemControl:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    removeItemControl:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
  end
end

local function unmarkItemFromRemoval(itemID)
  for i, markedID in pairs(XLGearBanker.UI_ItemsMarkedForRemoval) do
    if itemID == markedID then
      table.remove(XLGearBanker.UI_ItemsMarkedForRemoval, i)
      return
    end
  end
end

function XLGB_UI:RemoveItem(removeItemControl)
  easyDebug("Removing item")
  itemRowControl = removeItemControl:GetParent()
  if isItemMarkedForRemoval(itemRowControl.data.itemID) then
    unmarkItemFromRemoval(itemRowControl.data.itemID)
  else
    table.insert(XLGearBanker.UI_ItemsMarkedForRemoval, itemRowControl.data.itemID)
  end
  toggleToBeRemoved(itemRowControl)
end

local function addEquippedItemsToGearSet()
  XLGB_GearSet:AddEquippedItemsToGearSet(XLGearBanker.displayingSet)
  XLGB_UI:UpdateScrollList()
end

function XLGB_UI:AddEquippedItemsToSet()
  libDialog:ShowDialog("XLGearBanker", "AddEquippedItemsToSet", nil)
end

function XLGB_UI:DepositSet()
  XLGB_Banking:DepositGear(XLGearBanker.displayingSet)
end

function XLGB_UI:WithdrawSet()
  XLGB_Banking:WithdrawGear(XLGearBanker.displayingSet)
end


function XLGB_UI:UpdateScrollList()
  local scrollList = XLGB_Window_Control_ListView:GetNamedChild("_ScrollList")
  local itemAmountControl = XLGB_Window_Control_ListView:GetNamedChild("_ItemAmount")
  local scrollData = ZO_ScrollList_GetDataList(scrollList)
  ZO_ScrollList_Clear(scrollList)
  itemAmountControl:SetText("Total items in set: 0")
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
    itemAmountControl:SetText("Total items in set: ".. #XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet).items)
  end
  ZO_ScrollList_Commit(XLGB_Window_Control_ListView.scrollList)
end

local function fillItemRowWithData(control, data)
  control.data = data
  control:GetNamedChild("_Name"):SetText(data.itemLink)
  if XLGearBanker.UI_Editable then
    toggleToBeRemoved(control)
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
    "RemoveMarkedItems", 
    "XL Gear Banker", 
    "You have marked items for removal from this set.\n\nAre you sure you want these items removed?", 
    removeItemsMarkedForRemoval, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardChangesDialog", 
    "XL Gear Banker", 
    "Looks like you've edited the current set and are about to discard any changes you've made.\n\nAre you sure?", 
    discardChanges, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardChangesAndCycleDialog", 
    "XL Gear Banker", 
    "Looks like you've edited the current set and are about to discard any changes you've made.\n\nAre you sure?", 
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
  XLGearBanker.UI_ItemsMarkedForRemoval = {}
  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeScrollList()
  XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_UI:SetupDialogs()
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end
end