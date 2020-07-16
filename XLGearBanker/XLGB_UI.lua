XLGB_UI = {}

local libDialog = LibDialog
local libSB = LibShifterBox
local ui = {}
local sV = {}
local xl = {}

function XLGB_UI:XLGB_SetWindow_OnMoveStop()
  sV.setWindow_x = ui.set:GetLeft()
  sV.setWindow_y = ui.set:GetTop()
end

function XLGB_UI:XLGB_PageWindow_OnMoveStop()
  sV.pageWindow_x = ui.page:GetLeft()
  sV.pageWindow_y = ui.page:GetTop()
end

function XLGB_Events:OnPageSort(preSortList)
  local pageName = preSortList[sV.displayingPage]
  local newPageIndex = XLGB_Page:GetIndexOfPage(pageName)
  sV.displayingPage = newPageIndex
end

function XLGB_UI:OnGearSetSort(preSortList)
  local setName = preSortList[sV.displayingSet]
  local newSetIndex = XLGB_GearSet:GetGearSetIndex(setName)
  sV.displayingSet = newSetIndex
end

function XLGB_UI:RestorePosition()
  ui.set:ClearAnchors()
  ui.set:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.setWindow_x, sV.setWindow_y)

  ui.page:ClearAnchors()
  ui.page:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.pageWindow_x, sV.pageWindow_y)
end

local function reanchorScrollList(scrollList, top, bottom)
  scrollList:ClearAnchors()
  scrollList:SetAnchor(TOPLEFT, top, BOTTOMLEFT, 0, 10)
  scrollList:SetAnchor(BOTTOMRIGHT, bottom, TOPRIGHT, -21, -20)
end

local function refreshBankAndEditPageRow()
  ui.page.editPageRow:SetHidden(not xl.isPageEditable)
  ui.page.bankRow:SetHidden(xl.isPageEditable or (not XLGB_Banking.bankOpen))
end

local function reanchorPageScrollList()
  local p = ui.page
  if xl.isPageEditable then
    reanchorScrollList(p.scrollList, p.pageRow, p.editPageRow)
  elseif XLGB_Banking.bankOpen then
    reanchorScrollList(p.scrollList, p.pageRow, p.bankRow)
  else
    reanchorScrollList(p.scrollList, p.pageRow, p.totalPageItemsRow)
  end
end

local function areThereAnySetChanges()
  if (ui.set.setRow.editName:GetText() == xl.oldSetName)
  and not(xl.itemChanges) then
    return false
  end
  return true
end

local function areThereAnyPageChanges()
  if (ui.page.pageRow.editName:GetText() == xl.oldPageName)
  and not(xl.pageSetChange) then
    return false
  end
  return true
end

function XLGB_UI:ShowOrHideEditPage()
  XLGB_UI:ShowOrHideEdit(ui.page.pageRow.edit, XLGB_Page:GetNumberOfPages())
end

function XLGB_UI:ShowOrHideEditSet()
  XLGB_UI:ShowOrHideEdit(ui.set.setRow.edit, XLGB_GearSet:GetNumberOfGearSets())
end

function XLGB_UI:ShowOrHideEdit(edit, numberOfPagesOrSets)
  local isEmpty = numberOfPagesOrSets == 0
  edit:SetHidden(isEmpty)
end

function XLGB_UI:OnBankOpen()
  XLGB_UI:ShowPageUI()
  refreshBankAndEditPageRow()
  reanchorPageScrollList()
end

function XLGB_UI:OnBankClosed()
  ui.page:SetHidden(not xl.isPageEditable)
  ui.set:SetHidden(not xl.isSetEditable)
  refreshBankAndEditPageRow()
  reanchorPageScrollList()
end

function XLGB_UI:DepositPage()
  XLGB_Page:DepositPage(XLGB_Page:GetPageByIndex(sV.displayingPage).name)
end

function XLGB_UI:WithdrawPage()
  XLGB_Page:WithdrawPage(XLGB_Page:GetPageByIndex(sV.displayingPage).name)
end

local function updatePageShifterBoxEntries(pageNumber)
  local p = ui.page
  local s = p.shifter

  s.left = {}
  s.right = {}
  s.shifterBox:ClearLeftList()
  s.shifterBox:ClearRightList()

  for i = 1, XLGB_GearSet:GetNumberOfGearSets() do
    local setName = XLGB_GearSet:GetGearSet(i).name
    if XLGB_Page:PageContainsSet(XLGB_Page:GetPageByIndex(sV.displayingPage).name, setName) then
      table.insert(s.left, i, setName)
    else
      table.insert(s.right, i, setName)
    end
  end

  s.shifterBox:AddEntriesToLeftList(s.left)
  s.shifterBox:AddEntriesToRightList(s.right)
end

local function chooseSetsTrue()
  local p = ui.page

  updatePageShifterBoxEntries(sV.displayingPage)

  p.shifterRow:SetHidden(false)
  p.shifter.shifterBox:SetHidden(false)
  p.editPageRow:SetHidden(true)
  p.scrollList:SetHidden(true)

  xl.isChoosingSets = true
end

local function chooseSetsFalse()
  local p = ui.page

  p.shifterRow:SetHidden(true)
  p.shifter.shifterBox:SetHidden(true)
  p.editPageRow:SetHidden(false)
  p.scrollList:SetHidden(false)

  xl.isChoosingSets = false
end

function XLGB_UI:ToggleChooseSets()
  if xl.isChoosingSets then
    local chosenSets = ui.page.shifter.shifterBox:GetLeftListEntriesFull()
    local pageName = XLGB_Page:GetPageByIndex(sV.displayingPage).name
    XLGB_Page:ClearPage(pageName)
    for _, set in pairs(chosenSets) do
        XLGB_Page:AddSetToPage(set, pageName)
    end
    chooseSetsFalse()
    XLGB_UI:UpdatePageScrollList()
  else
    chooseSetsTrue()
  end
end

function XLGB_UI:InitializePageShifterBox()
  ui.page.shifter = {}
  local s = ui.page.shifter

  s.left = {}
  s.right = {}

  local customSettings = {
    showMoveAllButtons = true,  -- the >> and << buttons to move all entries can be hidden if set to false
    dragDropEnabled = true,     -- entries can be moved between lsit with drag-and-drop
    sortEnabled = true,         -- sorting of the entries can be disabled
    sortBy = "value",           -- sort the list by value or key (allowed are: "value" or "key")
    leftList = {                -- list-specific settings that apply to the LEFT list
        title = "In",                                     -- the title/header of the list
        rowHeight = 32,                                 -- the height of an individual row/entry
        --rowTemplateName = "",    -- an individual XML (cirtual) control can be provided for the rows/entries
        emptyListText = GetString("No Sets"), -- the text to be displayed if there are no entries left in the list
        fontSize = 16,                                  -- size of the font
    },
    rightList = {               -- list-specific settings that apply to the RIGHT list
        title = "Out",                                     -- the title/header of the list
        rowHeight = 32,                                 -- the height of an individual row/entry
        -- rowTemplateName = "Page_ShifterBoxEntry_Template",    -- an individual XML (cirtual) control can be provided for the rows/entries
        emptyListText = GetString("All Sets"), -- the text to be displayed if there are no entries left in the list
        fontSize = 16,                                  -- size of the font
    }
  }

  s.shifterBox = libSB.Create(XLGearBanker.name, "XLGB_Page_ShifterBox", ui.page, customSettings)
  s.shifterBox:SetAnchor(BOTTOM, ui.page.shifterRow, TOP, 0, -10)
  s.shifterBox:SetDimensions(310, 380)
  -- Temp fix for library
  local leftAllButton = XLGearBanker_XLGB_Page_ShifterBoxLeftAllButton
  leftAllButton:ClearAnchors()
  leftAllButton:SetAnchor(BOTTOM, XLGearBanker_XLGB_Page_ShifterBoxLeftButton, TOP, 0, -51)
  -----------------------
  s.shifterBox:SetHidden(true)
end

function XLGB_UI:SelectEntireTextbox(editBoxControl)
  editBoxControl:SelectAll()
end

local function refreshAddRemoveIcon(addRemoveControl, editable)
  if editable then
    addRemoveControl:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
    addRemoveControl:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")
    addRemoveControl:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")
  else
    addRemoveControl:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
    addRemoveControl:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")
    addRemoveControl:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")
  end
end

local function refreshEditIcon(editControl, editable)
  if editable then
    editControl:SetNormalTexture("/esoui/art/buttons/edit_cancel_up.dds")
    editControl:SetPressedTexture("/esoui/art/buttons/edit_cancel_down.dds")
    editControl:SetMouseOverTexture("/esoui/art/buttons/edit_cancel_over.dds")
  else
    editControl:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    editControl:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
    editControl:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
  end
end

local function setEditPageFalse()
  local p = ui.page
  chooseSetsFalse()
  xl.isPageEditable = false

  p.titleRow.title:SetText("XL Gear Banker")

  p.pageRow.page:SetHidden(xl.isPageEditable) -- Hide dropdown

  p.pageRow.editName:SetHidden(not xl.isPageEditable) -- Make editName visible
  p.pageRow.editName:SetEditEnabled(xl.isPageEditable)
  p.pageRow.editName:SetMouseEnabled(xl.isPageEditable)
  p.pageRow.editName:SetCursorPosition(0)

  p.pageRow.accept:SetHidden(not xl.isPageEditable)

  refreshEditIcon(p.pageRow.edit, xl.isPageEditable)
  refreshAddRemoveIcon(p.pageRow.addRemovePage, xl.isPageEditable)

  refreshBankAndEditPageRow()
  reanchorPageScrollList()

  ZO_ScrollList_RefreshVisible(p.scrollList)
  ClearTooltip(InformationTooltip)
end

local function setEditPageTrue()
  local p = ui.page
  xl.isPageEditable = true
  xl.oldPageName = XLGB_Page:GetPageByIndex(sV.displayingPage).name

  p.titleRow.title:SetText("XL Gear Banker (Edit Mode)")

  p.pageRow.page:SetHidden(xl.isPageEditable) -- Hide dropdown

  p.pageRow.editName:SetHidden(not xl.isPageEditable) -- Make editName visible
  p.pageRow.editName:SetEditEnabled(xl.isPageEditable)
  p.pageRow.editName:SetText(xl.oldPageName)
  p.pageRow.editName:SelectAll()
  p.pageRow.editName:TakeFocus()
  p.pageRow.editName:SetMouseEnabled(xl.isPageEditable)

  p.pageRow.accept:SetHidden(not xl.isPageEditable)

  refreshEditIcon(p.pageRow.edit, xl.isPageEditable)
  refreshAddRemoveIcon(p.pageRow.addRemovePage, xl.isPageEditable)

  refreshBankAndEditPageRow()
  reanchorPageScrollList()

  ZO_ScrollList_RefreshVisible(p.scrollList)
  ClearTooltip(InformationTooltip)
end

local function acceptPageChanges()
  local newPageName = ui.page.pageRow.editName:GetText()
  if XLGB_Page:SetPageName(xl.oldPageName, newPageName) then
    d("[XLGB] Page succesfully changed!")
    xl.copyOfPageSet = {}
    setEditPageFalse()
    XLGB_UI:UpdatePageDropdown()
  else
    d("[XLGB] Name was not unique")
  end
end

function XLGB_UI:AcceptPageEdit()
  local newPageName = ui.page.pageRow.editName:GetText()
  local hasNameChanged = newPageName ~= xl.oldPageName

  if not hasNameChanged then
    setEditPageFalse()
    XLGB_UI:UpdatePageDropdown()
  else
    libDialog:ShowDialog("XLGearBanker", "AcceptPageChanges", nil)
  end

  XLGB_UI:UpdatePageDropdown()
  ZO_ScrollList_RefreshVisible(ui.page.scrollList)
end

local function discardPageChanges()
  setEditPageFalse()
  XLGB_UI:UpdatePageDropdown()
  XLGB_UI:UpdatePageScrollList()
end

function XLGB_UI:TogglePageEdit()
  if xl.isPageEditable then
    if areThereAnyPageChanges() then
      libDialog:ShowDialog("XLGearBanker", "DiscardPageChangesDialog", nil)
    else
      discardPageChanges()
    end
  else
    xl.copyOfPageSet = XLGB_Page:CopyPageSet(XLGB_Page:GetPageByIndex(sV.displayingPage).name)
    xl.pageNameChange = false
    xl.pageSetChange = false
    setEditPageTrue()
  end
end

function XLGB_UI:AddRemovePage()
  if not xl.isPageEditable then
    XLGB_UI:AddPage()
  else
    XLGB_UI:RemovePage()
  end
end

function XLGB_UI:AddPage()
  local newPageName = XLGB_Page:CreatePage()
  sV.displayingPage = XLGB_Page:GetIndexOfPage(XLGB_Page:GetPage(newPageName))
  XLGB_UI:SelectPage(sV.displayingPage)

  XLGB_UI:TogglePageEdit()
  XLGB_UI:ShowOrHideEditPage()
  XLGB_UI:UpdatePageDropdown()
end

local function removePageConfirmed()
  XLGB_Page:RemovePage(XLGB_Page:GetPageByIndex(sV.displayingPage).name)
  setEditPageFalse()
  XLGB_UI:SelectPage(sV.displayingPage - 1)
  XLGB_UI:ShowOrHideEditPage()
  XLGB_UI:UpdatePageDropdown()
end

function XLGB_UI:RemovePage() 
  if #XLGB_Page:GetSetsInPage(XLGB_Page:GetPageByIndex(sV.displayingPage).name) == 0 then
    removePageConfirmed()
  else
    libDialog:ShowDialog("XLGearBanker", "RemovePageDialog", nil)
  end
end

local function CreatePageTooltip(control, text, editText)
  control.tooltipText = text
  control.tooltipEditText = editText or text -- If no special edit text tooltip, then use default.

  local function ShowTooltip(self)
    InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
    if not xl.isPageEditable then
      SetTooltipText(InformationTooltip, self.tooltipText)
    else
      SetTooltipText(InformationTooltip, self.tooltipEditText)
    end
  end

  local function HideTooltip(self)
    ClearTooltip(InformationTooltip)
  end

  control:SetHandler("OnMouseEnter", ShowTooltip)
  control:SetHandler("OnMouseExit", HideTooltip)
end

local function InitPageWindowTooltips()
  CreatePageTooltip(ui.page.pageRow.edit, "Edit current set", "Discard changes")
  CreatePageTooltip(ui.page.pageRow.accept, "Accept changes")
  CreatePageTooltip(ui.page.pageRow.addRemovePage, "Create new page", "Remove current page")
  CreatePageTooltip(ui.page.editPageRow.chooseSets, "Choose sets in current page")
  CreatePageTooltip(ui.page.editPageRow.setEditor, "Toggle the Set Editor")
end

function XLGB_UI:SelectPage(pageNumber)
  local totalPages = XLGB_Page:GetNumberOfPages()

  if pageNumber < 1 then
    sV.displayingPage = 1
  elseif pageNumber > totalPages then
    sV.displayingPage = totalPages
  else
    sV.displayingPage = pageNumber
  end

  XLGB_UI:UpdatePageScrollList()
end

function XLGB_UI:UpdatePageDropdown()
  local dd = ui.page.pageRow.page.dropdown
  dd:ClearItems()
  for i = 1, XLGB_Page:GetNumberOfPages() do
      local entry = ZO_ComboBox:CreateItemEntry(XLGB_Page:GetPageByIndex(i).name, function () XLGB_UI:SelectPage(i) end)
      dd:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
  end
  dd:SelectItemByIndex(sV.displayingPage, true)
end

function XLGB_UI:InitializePageDropdown()
  local p = ui.page.pageRow.page
  p.dropdown = ZO_ComboBox_ObjectFromContainer(p)
end

function XLGB_UI:UpdatePageScrollList()
  local scrollList = ui.page.scrollList
  local scrollData = ZO_ScrollList_GetDataList(scrollList)
  ZO_ScrollList_Clear(scrollList)
  if XLGB_Page:GetNumberOfPages() > 0 then
    local page = XLGB_Page:GetPageByIndex(sV.displayingPage)
    for _, set in pairs(XLGB_Page:GetSetsInPage(page.name)) do
      local dataEntry = ZO_ScrollList_CreateDataEntry(XLGB_Constants.PAGE_ITEM_ROW, {
        setName = set,
      })
      table.insert(scrollData, dataEntry)
    end
  end
  ZO_ScrollList_Commit(scrollList)
end

function XLGB_UI:WithdrawSet(withdrawControl)
  local data = withdrawControl:GetParent().data
  local gearSetIndex = XLGB_GearSet:GetGearSetIndex(data.setName)
  XLGB_Banking:WithdrawGear(gearSetIndex)
end

function XLGB_UI:DepositSet(depositControl)
  local data = depositControl:GetParent().data
  local gearSetIndex = XLGB_GearSet:GetGearSetIndex(data.setName)
  XLGB_Banking:DepositGear(gearSetIndex)
end

local function fillPageItemRowWithData(control, data)
  control.data = data
  local gearSet = XLGB_GearSet:FindGearSet(data.setName)
  -- local gearSetIndex = XLGB_GearSet:GetGearSetIndex(data.setName)

  control:GetNamedChild("_Name"):SetText("|cffecbc" .. data.setName .. "|r")
  control:GetNamedChild("_ItemsInSet"):SetText("Items: " .. tostring(#gearSet.items))

  --
  local function toggleSetUI(self)
    local gearSetIndex = XLGB_GearSet:GetGearSetIndex(self.data.setName)
    if gearSetIndex == sV.displayingSet then
      XLGB_UI:ToggleSetUI()
    else
      XLGB_UI:SelectSet(gearSetIndex)
      XLGB_UI:ShowSetUI()
      XLGB_UI:UpdateSetDropdown()
    end
  end
  control:SetMouseEnabled(true)
  control:SetHandler("OnMouseUp", toggleSetUI)
  --
  CreatePageTooltip(control:GetNamedChild("_Withdraw"), "Withdraw " .. data.setName)
  CreatePageTooltip(control:GetNamedChild("_Deposit"), "Deposit " .. data.setName)
end

function XLGB_UI:InitializePageScrollList()
  ZO_ScrollList_AddDataType(ui.page.scrollList, XLGB_Constants.PAGE_ITEM_ROW, "XLGB_Page_SetEntry_Template", 70, fillPageItemRowWithData)
  ZO_ScrollList_EnableHighlight(ui.page.scrollList, "ZO_ThinListHighlight")
  XLGB_UI:UpdatePageScrollList()
end

function XLGB_UI:ShowPageUI()
  XLGB_UI:ShowOrHideEditPage()
  ui.page:SetHidden(false)
end

function XLGB_UI:HidePageUI()
  if xl.isPageEditable and areThereAnyPageChanges() then
    libDialog:ShowDialog("XLGearBanker", "DiscardPageChangesDialog", nil)
  else
    setEditPageFalse()
    ui.page:SetHidden(true)
  end
end

function XLGB_UI:TogglePageUI()
  if ui.page:IsHidden() then
    XLGB_UI:ShowPageUI()
  else
    XLGB_UI:HidePageUI()
  end
end

function XLGB_UI:SetupPageDialogs()

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "RemovePageDialog", 
    "XL Gear Banker", 
    "You are about to remove the page.\n\nAre you sure?",
    removePageConfirmed, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "AcceptPageChanges", 
    "XL Gear Banker", 
    "Are you sure you want to save the changes?", 
    acceptPageChanges, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardPageChangesDialog", 
    "XL Gear Banker", 
    "You are about to discard any changes you made.\n\nAre you sure?", 
    discardPageChanges, 
    nil,
    nil)
end

local function InitUIPageVariables()
  ui.page                         = XLGB_PageWindow

  ui.page.titleRow                = XLGB_PageWindow_TitleRow
  ui.page.titleRow.title          = XLGB_PageWindow_TitleRow_Title

  ui.page.pageRow                 = XLGB_PageWindow_PageRow
  ui.page.pageRow.edit            = XLGB_PageWindow_PageRow_EditPage
  ui.page.pageRow.editName        = XLGB_PageWindow_PageRow_EditPageName
  ui.page.pageRow.page            = XLGB_PageWindow_PageRow_Page
  ui.page.pageRow.accept          = XLGB_PageWindow_PageRow_AcceptPage
  ui.page.pageRow.addRemovePage   = XLGB_PageWindow_PageRow_AddRemovePage

  ui.page.scrollList              = XLGB_PageWindow_ScrollList

  ui.page.bankRow                 = XLGB_PageWindow_BankRow
  ui.page.bankRow.deposit         = XLGB_PageWindow_BankRow_DepositPage
  ui.page.bankRow.withdraw        = XLGB_PageWindow_BankRow_WithdrawPage

  ui.page.editPageRow             = XLGB_PageWindow_EditPageRow
  ui.page.editPageRow.chooseSets  = XLGB_PageWindow_EditPageRow_ChooseSets
  ui.page.editPageRow.setEditor   = XLGB_PageWindow_EditPageRow_SetEditor

  ui.page.shifterRow              = XLGB_PageWindow_ShifterRow
  ui.page.shifterRow.done         = XLGB_PageWindow_ShifterRow_Done

  ui.page.totalPageItemsRow       = XLGB_PageWindow_TotalPageItemsRow
  ui.page.totalPageItemsRow.text  = XLGB_PageWindow_TotalPageItemsRow_TotalPageItems
end



------------------------------------------------------------------------------------------------------



local function setEditSetFalse()
  local s = ui.set
  xl.isSetEditable = false

  s.titleRow.title:SetText("XLGB - Sets")

  s.setRow.set:SetHidden(false) -- Make dropdown visible

  s.setRow.editName:SetHidden(true) -- hide editName
  s.setRow.editName:SetEditEnabled(false)
  s.setRow.editName:SetMouseEnabled(false)
  s.setRow.editName:SetCursorPosition(0)

  s.setRow.accept:SetHidden(true)

  refreshEditIcon(s.setRow.edit, xl.isSetEditable)
  refreshAddRemoveIcon(s.setRow.addRemoveSet, xl.isSetEditable)

  s.addItemsRow:SetHidden(true)

  reanchorScrollList(s.scrollList, s.setRow, s.totalSetItemsRow)
  ZO_ScrollList_RefreshVisible(s.scrollList)
  ClearTooltip(InformationTooltip)
end

local function setEditSetTrue()
  local s = ui.set
  xl.isSetEditable = true
  xl.oldSetName = XLGB_GearSet:GetGearSet(sV.displayingSet).name

  s.titleRow.title:SetText("XLGB - Sets (Edit Mode)")

  s.setRow.set:SetHidden(true) -- Hide dropdown

  s.setRow.editName:SetHidden(false) -- Make editName visible
  s.setRow.editName:SetEditEnabled(true)
  s.setRow.editName:SetText(xl.oldSetName)
  s.setRow.editName:SelectAll()
  s.setRow.editName:TakeFocus()
  s.setRow.editName:SetMouseEnabled(true)

  s.setRow.accept:SetHidden(false)

  refreshEditIcon(s.setRow.edit, xl.isSetEditable)
  refreshAddRemoveIcon(s.setRow.addRemoveSet, xl.isSetEditable)

  s.addItemsRow:SetHidden(false)

  reanchorScrollList(s.scrollList, s.setRow, s.addItemsRow)
  ZO_ScrollList_RefreshVisible(s.scrollList)
  ClearTooltip(InformationTooltip)
end

local function acceptSetChanges()
  xl.copyOfSet = {}
  setEditSetFalse()
  d("[XLGB] Gear set changes accepted!")
end

function XLGB_UI:AcceptSetEdit()
  local newGearName = ui.set.setRow.editName:GetText()

  if newGearName == xl.oldSetName then
    if not(xl.itemChanges) then
      setEditSetFalse()
    else
      libDialog:ShowDialog("XLGearBanker", "AcceptSetChanges", nil)
    end
  else
    if XLGB_GearSet:EditGearSetName(newGearName, sV.displayingSet) then
      d("[XLGB] Gearset renamed to '" .. newGearName .. "'.")
      if not(xl.itemChanges) then
        setEditSetFalse()
      else
        libDialog:ShowDialog("XLGearBanker", "AcceptSetChanges", nil)
      end
    end
  end
  XLGB_UI:UpdateSetDropdown()
  ZO_ScrollList_RefreshVisible(ui.set.scrollList)
end

local function discardSetChanges()
  sV.gearSetList[sV.displayingSet] = xl.copyOfSet
  xl.copyOfSet = {}
  setEditSetFalse()
  
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_UI:ToggleSetEdit()
  if xl.isSetEditable then
    if areThereAnySetChanges() then
      libDialog:ShowDialog("XLGearBanker", "DiscardSetChangesDialog", nil)
    else
      discardSetChanges()
    end
  else
    xl.copyOfSet = XLGB_GearSet:CopyGearSet(sV.displayingSet)
    xl.itemChanges = false
    xl.nameChanges = false
    setEditSetTrue()
  end
end

function XLGB_UI:AddRemoveSet()
  if not xl.isSetEditable then
    XLGB_UI:AddSet()
  else
    XLGB_UI:RemoveSet()
  end
end

function XLGB_UI:AddSet()
  local newSetName = XLGB_GearSet:GenerateNewSet()
  sV.displayingSet = XLGB_GearSet:GetGearSetIndex(newSetName)
  XLGB_UI:SelectSet(sV.displayingSet)

  XLGB_UI:ToggleSetEdit()
  XLGB_UI:ShowOrHideEditSet()
  XLGB_UI:UpdateSetDropdown()
end

local function removeSetConfirmed()
  XLGB_Events:OnGearSetRemove(XLGB_GearSet:GetGearSet(sV.displayingSet))
  XLGB_GearSet:RemoveGearSet(sV.displayingSet)
  setEditSetFalse()
  XLGB_UI:SelectSet(sV.displayingSet - 1)
  XLGB_UI:ShowOrHideEditSet()
  XLGB_UI:UpdateSetDropdown()
  
end

function XLGB_UI:RemoveSet() 
  if #XLGB_GearSet:GetGearSet(sV.displayingSet).items == 0 then
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
  xl.itemChanges = true
  XLGB_GearSet:RemoveItemFromGearSet(itemLink, itemID, sV.displayingSet)
end

function XLGB_UI:AddEquippedItemsToSet()
  -- libDialog:ShowDialog("XLGearBanker", "AddEquippedItemsToSet", nil)
  xl.itemChanges = true
  XLGB_GearSet:AddEquippedItemsToGearSet(sV.displayingSet)
  XLGB_UI:UpdateSetScrollList()
end

local function ShowItemTooltip(self)
  InitializeTooltip(ItemTooltip, self)
  ItemTooltip:SetLink(self.data.itemLink)
end

local function HideItemTooltip(control)
  ClearTooltip(ItemTooltip)
end

local function CreateSetTooltip(control, text, editText)
  control.tooltipText = text
  control.tooltipEditText = editText or text -- If no special edit text tooltip, then use default.

  local function ShowTooltip(self)
    InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
    if not xl.isSetEditable then
      SetTooltipText(InformationTooltip, self.tooltipText)
    else
      SetTooltipText(InformationTooltip, self.tooltipEditText)
    end
  end

  local function HideTooltip(self)
    ClearTooltip(InformationTooltip)
  end

  control:SetHandler("OnMouseEnter", ShowTooltip)
  control:SetHandler("OnMouseExit", HideTooltip)
end

local function InitSetWindowTooltips()
  CreateSetTooltip(ui.set.setRow.edit, "Edit current set", "Discard changes")
  CreateSetTooltip(ui.set.setRow.accept, "Accept changes")
  CreateSetTooltip(ui.set.setRow.addRemoveSet, "Create new set", "Remove current set")
  CreateSetTooltip(ui.set.addItemsRow.addEquipped, "Add the items you're currently wearing to this set")
end

function XLGB_UI:SelectSet(setNumber)
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()

  if setNumber < 1 then
    sV.displayingSet = 1
  elseif setNumber > totalSets then
    sV.displayingSet = totalSets
  else
    sV.displayingSet = setNumber
  end

  XLGB_UI:UpdateSetScrollList()
end

function XLGB_UI:UpdateSetDropdown()
  local dd = ui.set.setRow.set.dropdown
  dd:ClearItems()
  for i = 1, XLGB_GearSet:GetNumberOfGearSets() do
      local entry = ZO_ComboBox:CreateItemEntry(XLGB_GearSet:GetGearSet(i).name, function () XLGB_UI:SelectSet(i) end)
      dd:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
  end
  dd:SelectItemByIndex(sV.displayingSet, true)
end

function XLGB_UI:InitializeSetDropdown()
  local s = ui.set.setRow.set
  s.dropdown = ZO_ComboBox_ObjectFromContainer(s)
end

function XLGB_UI:UpdateSetScrollList()
  local scrollList = ui.set.scrollList
  local totalSetItems = ui.set.totalSetItemsRow.text
  local scrollData = ZO_ScrollList_GetDataList(scrollList)
  ZO_ScrollList_Clear(scrollList)
  totalSetItems:SetText("Total items in set: 0")
  if XLGB_GearSet:GetNumberOfGearSets() > 0 then
    local gearSet = XLGB_GearSet:GetGearSet(sV.displayingSet)
    for _, item in pairs(gearSet.items) do
      local dataEntry = ZO_ScrollList_CreateDataEntry(XLGB_Constants.ITEM_ROW, {
        itemName = item.name,
        itemLink = item.link,
        itemID = item.ID
      })
      table.insert(scrollData, dataEntry)
    end
    totalSetItems:SetText("Total items in set: ".. #XLGB_GearSet:GetGearSet(sV.displayingSet).items)
  end
  ZO_ScrollList_Commit(XLGB_SetWindow.scrollList)
end

local function fillSetItemRowWithData(control, data)
  control.data = data
  control:GetNamedChild("_Name"):SetText(data.itemLink)
  control:SetMouseEnabled(true)
  control:SetHandler("OnMouseEnter", ShowItemTooltip)
  control:SetHandler("OnMouseExit", HideItemTooltip)
  if xl.isSetEditable then
    control:GetNamedChild("_Remove"):SetHidden(false)
  else 
    control:GetNamedChild("_Remove"):SetHidden(true)
  end
  CreateSetTooltip(control:GetNamedChild("_Remove"), "Remove item from set")
end

function XLGB_UI:InitializeSetScrollList()
  ZO_ScrollList_AddDataType(ui.set.scrollList, XLGB_Constants.ITEM_ROW, "XLGB_Item_Row_Template", 35, fillSetItemRowWithData)
  ZO_ScrollList_EnableHighlight(ui.set.scrollList, "ZO_ThinListHighlight")
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_UI:ShowSetUI()
  XLGB_UI:ShowOrHideEditSet()
  ui.set:SetHidden(false)
end

function XLGB_UI:HideSetUI()
  if xl.isSetEditable and areThereAnySetChanges() then
    libDialog:ShowDialog("XLGearBanker", "DiscardSetChangesDialog", nil)
  else
    setEditSetFalse()
    ui.set:SetHidden(true)
  end
end

function XLGB_UI:ToggleSetUI()
  if ui.set:IsHidden() then
    XLGB_UI:ShowSetUI()
  else
    XLGB_UI:HideSetUI()
  end
end

function XLGB_UI:SetupSetDialogs()

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
    "AcceptSetChanges", 
    "XL Gear Banker", 
    "You have added/removed items to/from this set.\n\nAre you sure you want to keep these changes?", 
    acceptSetChanges, 
    nil,
    nil)

  libDialog:RegisterDialog(
    "XLGearBanker", 
    "DiscardSetChangesDialog", 
    "XL Gear Banker", 
    "Looks like you've edited the current set and are about to discard any changes you've made including recently added/removed items.\n\nAre you sure?", 
    discardSetChanges, 
    nil,
    nil)
end

local function InitUISetVariables()
  ui.set                          = XLGB_SetWindow

  ui.set.titleRow                 = XLGB_SetWindow_TitleRow
  ui.set.titleRow.title           = XLGB_SetWindow_TitleRow_Title

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
  xl = XLGearBanker or {}
  sV = XLGearBanker.savedVariables or {}
  sV.displayingSet = sV.displayingSet or 1
  sV.displayingPage = sV.displayingPage or 1

  xl.isSetEditable = false
  xl.isPageEditable = false
  xl.isChoosingSets = false
  xl.chooseSetsBefore = {}
  xl.copyOfSet = {}
  xl.itemChanges = false
  xl.nameChanges = false

  InitUISetVariables()
  InitSetWindowTooltips()

  InitUIPageVariables()
  InitPageWindowTooltips()

  XLGB_UI:RestorePosition()

  XLGB_UI:InitializeSetScrollList()
  XLGB_UI:InitializeSetDropdown()
  XLGB_UI:UpdateSetDropdown()
  XLGB_UI:SelectSet(sV.displayingSet)
  XLGB_UI:SetupSetDialogs()

  XLGB_UI:InitializePageScrollList()
  XLGB_UI:InitializePageDropdown()
  XLGB_UI:UpdatePageDropdown()
  XLGB_UI:SelectPage(sV.displayingPage)
  XLGB_UI:SetupPageDialogs()
  XLGB_UI:InitializePageShifterBox()

  if sV.debug then
    XLGB_UI:ShowPageUI()
  end
  
end