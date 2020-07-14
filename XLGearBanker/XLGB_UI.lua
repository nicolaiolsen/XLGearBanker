XLGB_UI = {}

local libDialog = LibDialog
local ui

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

function XLGB_UI:SelectEntireTextbox(editBoxControl)
  editBoxControl:SelectAll()
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

local function refreshAddRemoveIcon(addRemoveControl)
  if XLGearBanker.UI_Editable then
    addRemoveControl:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
    addRemoveControl:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")
    addRemoveControl:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")
  else
    addRemoveControl:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
    addRemoveControl:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")
    addRemoveControl:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")
  end
end

local function refreshEditIcon(editControl)
  if XLGearBanker.UI_Editable then
    editControl:SetNormalTexture("/esoui/art/buttons/edit_cancel_up.dds")
    editControl:SetPressedTexture("/esoui/art/buttons/edit_cancel_down.dds")
    editControl:SetMouseOverTexture("/esoui/art/buttons/edit_cancel_over.dds")
  else
    editControl:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    editControl:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
    editControl:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
  end
end

local function reanchorScrollList(scrollList, top, bottom)
  scrollList:ClearAnchors()
  scrollList:SetAnchor(TOPLEFT, top, BOTTOMLEFT, 0, 10)
  scrollList:SetAnchor(BOTTOMRIGHT, bottom, TOPRIGHT, -21, -20)

end

local function setEditSetFalse()
  local s = ui.set
  XLGearBanker.UI_Editable = false
  XLGearBanker.UI_GearSetNameBefore = ui.set.setRow.set.dropdown:GetSelectItemText()

  s.setRow.set:SetHidden(false) -- Make dropdown visible

  s.setRow.editName:SetHidden(true) -- hide editName 
  s.setRow.editName:SetEditEnabled(false)
  s.setRow.editName:SetMouseEnabled(false)

  s.setRow.accept:SetHidden(true)

  refreshEditIcon(s.setRow.edit)
  refreshAddRemoveIcon(s.setRow.addRemoveSet)

  s.addItemsRow:SetHidden(true)
  reanchorScrollList(s.scrollList, s.setRow, s.totalSetItemsRow)

  ZO_ScrollList_RefreshVisible(s.scrollList)
end

local function setEditSetTrue()
  local s = ui.set
  XLGearBanker.UI_Editable = true
  XLGearBanker.UI_GearSetNameBefore = XLGB_GearSet:GetGearSet(XLGearBanker.displayingSet).name

  s.setRow.set:SetHidden(true) -- Hide dropdown

  s.setRow.editName:SetHidden(false) -- Make editName visible
  s.setRow.editName:SetEditEnabled(true)
  s.setRow.editName:SetText(XLGearBanker.UI_GearSetNameBefore)
  s.setRow.editName:SelectAll()
  s.setRow.editName:TakeFocus()
  s.setRow.editName:SetMouseEnabled(true)

  s.setRow.accept:SetHidden(false)

  refreshEditIcon(s.setRow.edit)
  refreshAddRemoveIcon(s.setRow.addRemoveSet)

  s.addItemsRow:SetHidden(false)
  reanchorScrollList(s.scrollList, s.setRow, s.addItemsRow)

  ZO_ScrollList_RefreshVisible(s.scrollList)
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
    -- if areThereAnyChanges() then
    --   libDialog:ShowDialog("XLGearBanker", "DiscardChangesDialog", nil)
    -- else
    --   discardChanges()
      
    -- end
    setEditSetFalse()
  else
    XLGearBanker.copyOfSet = XLGB_GearSet:CopyGearSet(XLGearBanker.displayingSet)
    XLGearBanker.itemChanges = false
    XLGearBanker.nameChanges = false
    setEditSetTrue()
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

function XLGB_UI:SelectSet(setNumber)
  XLGearBanker.displayingSet = setNumber
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_UI:UpdateSetDropdown()
  local dd = XLGB_UI.set.dropdown
  dd:ClearItems()
  for i = 1, XLGB_GearSet:GetNumberOfGearSets() do
      local entry = ZO_ComboBox:CreateItemEntry(XLGB_GearSet:GetGearSet(i).name, function () XLGB_UI:SelectSet(i) end)
      dd:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
  end
  dd:SelectItemByIndex(XLGearBanker.displayingSet, true)
end

function XLGB_UI:InitializeSetDropdown()
  XLGB_UI.set = XLGB_SetWindow_SetRow_Set
  XLGB_UI.set.dropdown = ZO_ComboBox_ObjectFromContainer(XLGB_UI.set)
end

function XLGB_UI:UpdateSetScrollList()
  local scrollList = ui.set.scrollList
  local totalSetItems = ui.set.totalSetItemsRow.text
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

local function fillSetItemRowWithData(control, data)
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

function XLGB_UI:InitializeSetScrollList()
  ZO_ScrollList_AddDataType(ui.set.scrollList, XLGB_Constants.ITEM_ROW, "XLGB_Item_Row_Template", 35, fillSetItemRowWithData)
  ZO_ScrollList_EnableHighlight(ui.set.scrollList, "ZO_ThinListHighlight")
  XLGB_UI:UpdateSetScrollList()
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

local function InitUISetVariables()
  ui.set.setRow                   = XLGB_SetWindow_SetRow
  ui.set.setRow.edit              = XLGB_SetWindow_SetRow_EditSet
  ui.set.setRow.editName          = XLGB_SetWindow_SetRow_EditSetName
  ui.set.setRow.set               = XLGB_SetWindow_SetRow_Set
  ui.set.setRow.accept            = XLGB_SetWindow_SetRow_AcceptSet
  ui.set.setRow.addRemoveSet      = XLGB_SetWindow_SetRow_AddRemoveSet

  ui.set.scrollList               = XLGB_SetWindow_ScrollList

  ui.set.addItemsRow              = XLGB_SetWindow_AddItemsRow
  ui.set.addItemsRow.addEquipped  = XLGB_SetWindow_AddItemsRow_AddEquipped

  ui.set.totalSetItemsRow         = XLGB_SetWindow_TotalSetItemsRow
  ui.set.totalSetItemsRow.text    = XLGB_SetWindow_TotalSetItemsRow_TotalSetItems
end

function XLGB_UI:Initialize()
  XLGearBanker.displayingSet = 1
  XLGearBanker.UI_Editable = false
  XLGearBanker.copyOfSet = {}
  XLGearBanker.itemChanges = false
  XLGearBanker.nameChanges = false
  XLGearBanker.UI_ItemsMarkedForRemoval = {}

  InitUISetVariables()

  XLGB_UI:RestorePosition()
  XLGB_UI:InitializeSetScrollList()
  XLGB_UI:InitializeSetDropdown()
  XLGB_UI:UpdateSetDropdown()
  XLGB_UI:SelectSet(XLGearBanker.displayingSet)
  -- XLGB_UI:ChangeDisplayedGearSet(XLGearBanker.displayingSet)
  XLGB_UI:SetupDialogs()
  if XLGearBanker.debug then
    XLGB_UI:ShowUI()
  end

  
end