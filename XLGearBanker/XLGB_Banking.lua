--[[
  XLGB_Banking.lua

  This module contains all functionality related to item transfer.

  Functions:

]]--

--Namespace
XLGB_Banking = {}

local XLGB = XLGB_Constants

function XLGB_Banking.OnBankOpenEvent(event, bankBag)
  if not XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    XLGB_Banking.currentBankBag = bankBag
    if (bankBag ~= BAG_BANK) then
      KEYBIND_STRIP:AddKeybindButtonGroup(XLGB_Banking.storageChestButtonGroup)
    end
    easyDebug("Bank open!")
  end
end

function XLGB_Banking.OnBankCloseEvent(event)
  if XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    XLGB_Banking.currentBankBag = XLGB.NO_BAG
    KEYBIND_STRIP:RemoveKeybindButtonGroup(XLGB_Banking.storageChestButtonGroup)
    easyDebug("Bank closed")
  end
end

local function findItemIndexInBag(bag, itemID)
  local item_index = XLGB.ITEM_NOT_IN_BAG
  for i = 0, GetBagSize(bag) do
    if (Id64ToString(GetItemUniqueId(bag, i)) == itemID) then
      item_index = i
      return item_index
    end
  end
  return item_index
end

local function findItemsToMove(sourceBag, sourceItems)
  local itemsToMove = {}
  for _, item in pairs(sourceItems) do
    local itemIndex = findItemIndexInBag(sourceBag, item.ID)
    if (itemIndex ~= XLGB.ITEM_NOT_IN_BAG) then
      local itemToMoveEntry = {}
      itemToMoveEntry.item = item
      itemToMoveEntry.index = itemIndex
      table.insert(itemsToMove, itemToMoveEntry)
    end
  end
  return itemsToMove
end
--[[
  function getAvailableBagSpaces

    Returns a list of empty bag spaces.

  Input:
    bag = A bag as specified in the API constants (e.g. BAG_BANK, BAG_BACKPACK)

  Output:
    availableBagSpaces = Lua table containing indices of empty bag slots.
]]--
local function getAvailableBagSpaces(bag)
  easyDebug("Finding available bagspaces in bag: " .. bag)
  local availableBagSpaces = {}

  for i = 0, GetBagSize(bag) do
    if GetItemName(bag, i) == "" then
      table.insert(availableBagSpaces, i)
    end
  end
  easyDebug("Found " .. #availableBagSpaces .. " available spaces in bag.")
  return availableBagSpaces
end

local function moveItem(sourceBag, itemIndex, targetBag, availableSpace)
  local moveSuccesful = false
  moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, itemIndex, targetBag, availableSpace, 1)
  if moveSuccesful then
    easyDebug("Item move: Success!")
  end
end

local function moveGear(sourceBag, itemsToMove, targetBag, availableBagSpaces)
  --Move each item of the specified gearset from sourceBag to targetBag
  for i, itemEntry in ipairs(itemsToMove) do
    moveItem(sourceBag, itemEntry.index, targetBag, availableBagSpaces[i])
  end
end

local function moveGearFromTwoBags(sourceBagOne, itemsToMoveOne, sourceBagTwo, itemsToMoveTwo, targetBag, availableBagSpaces)
  for i, itemEntry in ipairs(itemsToMoveOne) do
    -- Stop when there are no more bag spaces,
    -- return bag and index of item that was to be moved next.
    if (#availableBagSpaces < i) then return sourceBagOne, i end
    moveItem(sourceBagOne, itemEntry.index, targetBag, availableBagSpaces[i])
  end
  for i, itemEntry in ipairs(itemsToMoveTwo) do
    -- Stop when there are no more bag spaces,
    -- return bag and index of item that was to be moved next.
    if (#availableBagSpaces < i + #itemsToMoveOne) then return sourceBagTwo, i end
    moveItem(sourceBagTwo, itemEntry.index, targetBag, availableBagSpaces[i + #itemsToMoveOne])
  end
end

local function depositItemsToBankNonESOPlus(itemsToDeposit)
  local equippedItemsToMove = findItemsToMove(BAG_WORN, itemsToDeposit)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, itemsToDeposit)

  local availableBagSpaces = getAvailableBagSpaces(XLGB_Banking.currentBankBag)
  local numberOfItemsToMove = #equippedItemsToMove + #inventoryItemsToMove

  if (#availableBagSpaces < numberOfItemsToMove) then
    d("[XLGB_ERROR] Trying to move " .. numberOfItemsToMove.. "items into a bag with " .. #availableBagSpaces .." empty slots.")
    return false
  end

  moveGearFromTwoBags(
      BAG_BACKPACK, inventoryItemsToMove,
      BAG_WORN, equippedItemsToMove,
      XLGB_Banking.currentBankBag, availableBagSpaces)
  return true
end

local function getRemainingItems(items, fromIndex)
  local remainingItems = {}
  for i = fromIndex, #items do
    table.insert(remainingItems, items[i])
  end
  return remainingItems
end

local function depositGearToBankESOPlus(gearSet)
  local equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet.items)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet.items)

  local availableBagSpacesRegularBank = getAvailableBagSpaces(BAG_BANK)
  local availableBagSpacesESOPlusBank = getAvailableBagSpaces(BAG_SUBSCRIBER_BANK)
  -- 
  local numberOfAvailableSpaces = #availableBagSpacesRegularBank + #availableBagSpacesESOPlusBank
  local numberOfItemsToMove = #equippedItemsToMove + #inventoryItemsToMove

  if (numberOfAvailableSpaces < numberOfItemsToMove) then
    d("[XLGB_ERROR] Trying to move " .. numberOfItemsToMove.. "items into a bag with " .. numberOfAvailableSpaces .." empty slots.")
    return false
  end

  if (#availableBagSpacesRegularBank >= numberOfItemsToMove) then
    moveGearFromTwoBags(
        BAG_BACKPACK, inventoryItemsToMove,
        BAG_WORN, equippedItemsToMove,
        BAG_BANK, availableBagSpacesRegularBank)
    return true

  else
    -- Add items to regular bank
    local interruptedBag, fromIndex = moveGearFromTwoBags(
                                          BAG_BACKPACK, inventoryItemsToMove,
                                          BAG_WORN, equippedItemsToMove,
                                          BAG_BANK, availableBagSpacesRegularBank)

    if (interruptedBag == BAG_BACKPACK) then
      local remainingItems = getRemainingItems(inventoryItemsToMove, fromIndex)
      moveGearFromTwoBags(
        BAG_BACKPACK, remainingItems,
        BAG_WORN, equippedItemsToMove,
        BAG_SUBSCRIBER_BANK, availableBagSpacesESOPlusBank)
    else 
      moveGear(BAG_WORN, equippedItemsToMove, BAG_SUBSCRIBER_BANK, availableBagSpacesESOPlusBank)
    end
    return true
  end
end

--[[
  function DepositGear
  Input:

  Output:
]]--
function XLGB_Banking:DepositGear(gearSetNumber)
  --[[
  if XLGB_Banking.recentlyCalled then
    d("[XLGB_ERROR] You've recently transferred items! Let the servers catch their breath." )
    return
  end
  XLGB_Banking.recentlyCalled = true
  ]]--
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return
  end
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Depositing " .. gearSet.name)

  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if depositGearToBankESOPlus(gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
      return
    end
    
  else
    if depositItemsToBankNonESOPlus(gearSet.items) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
    end
  end
  --[[
  zo_callLater(function()
    XLGB_Banking.recentlyCalled = false
  end, 3000)
  ]]--
end

local function withdrawGearESOPlus(gearSet)
  local regularBankItemsToMove = findItemsToMove(BAG_BANK, gearSet.items)
  local ESOPlusItemsToMove = findItemsToMove(BAG_SUBSCRIBER_BANK, gearSet.items)
  local availableBagSpaces = getAvailableBagSpaces(BAG_BACKPACK)
  local numberOfItemsToMove = #regularBankItemsToMove + #ESOPlusItemsToMove
  if (#availableBagSpaces < numberOfItemsToMove) then
    d("[XLGB_ERROR] Trying to move " .. numberOfItemsToMove.. "items into a bag with " .. #availableBagSpaces .." empty slots.")
    return false
  end
  moveGearFromTwoBags(
      BAG_BANK, regularBankItemsToMove,
      BAG_SUBSCRIBER_BANK, ESOPlusItemsToMove,
      BAG_BACKPACK, availableBagSpaces)
end

local function withdrawItemsNonESOPlus(itemsToWithdraw)
  local itemsToMove = findItemsToMove(XLGB_Banking.currentBankBag, itemsToWithdraw)
  local availableBagSpaces = getAvailableBagSpaces(BAG_BACKPACK)
  if (#availableBagSpaces < #itemsToMove) then
    d("[XLGB_ERROR] Trying to move " .. #itemsToMove.. "items into a bag with " .. #availableBagSpaces .." empty slots.")
    return false
  end
  moveGear(XLGB_Banking.currentBankBag, itemsToMove, BAG_BACKPACK, availableBagSpaces)
  return true
end
--[[
  function WithdrawGear
  Input:

  Output:
]]--
function XLGB_Banking:WithdrawGear(gearSetNumber)
  --[[
  if XLGB_Banking.recentlyCalled then
    d("[XLGB_ERROR] You've recently transferred items! Let the servers catch their breath." )
    return
  end
  XLGB_Banking.recentlyCalled = true
  ]]--
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return
  end
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Withdrawing " .. gearSet.name)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if withdrawGearESOPlus(gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
    end
  else 
    if withdrawItemsNonESOPlus(gearSet.items) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
    end
  end
  --[[
  zo_callLater(function()
    XLGB_Banking.recentlyCalled = false
  end, 3000)
  ]]--
end

local function getStorageBag(storageBagID)
  return XLGearBanker.savedVariables.storageBags[storageBagID]
end

local function findGearSetInStorage(gearSetName, storageBag)
  local gearSetIndex = XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE
  for i, storageSetName in pairs(storageBag.assignedSets) do
    if (gearSetName == storageSetName) then
      gearSetIndex = i
      return gearSetIndex
    end
  end
  return gearSetIndex
end

local function findItemIndexInSet(sourceItem, targetItems)
  local itemIndex = XLGB.ITEM_NOT_IN_SET
  for i, targetItem in pairs(targetItems) do
    if (sourceItem.ID == targetItem.ID) then
      itemIndex = i
      return itemIndex
    end
  end
  return itemIndex
end

local function compareItemsWithStorage(sourceItems, storageBag)
  local uniqueItems = {}
  local duplicateItems = {}
  for _, sourceItem in pairs(sourceItems) do
    itemIndex = findItemIndexInSet(sourceItem, storageBag.assignedItems)
    if (itemIndex ~= XLGB.ITEM_NOT_IN_SET ) then
      table.insert(duplicateItems, itemIndex)
    else
      sourceItem.count = 1
      table.insert(uniqueItems, sourceItem)
    end
  end
  return uniqueItems, duplicateItems
end

local function addSetToStorageItems(uniqueItems, indicesOfDuplicates, gearSetName, storageBagID)
  local storageBag = XLGearBanker.savedVariables.storageBags[storageBagID]
  for _, duplicateIndex in pairs(indicesOfDuplicates) do
    storageBag.assignedItems[duplicateIndex].count = storageBag.assignedItems[duplicateIndex].count + 1
  end
  for _, uniqueItem in pairs(uniqueItems) do
    table.insert(storageBag.assignedItems, uniqueItem)
  end
  table.insert(storageBag.assignedSets, gearSetName)
end

local function assignSetToStorage(gearSet, storageBagID)
  local storageBag = getStorageBag(storageBagID)
  local gearSetIndex = findGearSetInStorage(gearSet.name, storageBag)
  if (gearSetIndex ~= XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
    return false
  end
  local compareItemsResult = {compareItemsWithStorage(gearSet.items, storageBag)}
  local itemsNotAlreadyAssigned = compareItemsResult[1]
  local indicesOfDuplicates = compareItemsResult[2]
  if (storageBag.slotsLeft < #itemsNotAlreadyAssigned) then
    d("[XLGB_ERROR] Cannot assign set to storage. Trying to assign " .. #itemsNotAlreadyAssigned .. " items when only " .. storageBag.slotsLeft .. " are open for assignment.")
    return false
  end
  addSetToStorageItems(itemsNotAlreadyAssigned, indicesOfDuplicates, gearSet.name, storageBagID)
  XLGearBanker.savedVariables.storageBags[storageBagID].slotsLeft = XLGearBanker.savedVariables.storageBags[storageBagID].slotsLeft - #itemsNotAlreadyAssigned
  return true
end
--[[
  function AssignStorage
  Input:

  Output:
]]--

function XLGB_Banking:AssignStorage(gearSetNumber)
  if (not XLGB_Banking.bankOpen)
  and (XLGB_Banking.currentBankBag ~= XLGB.NO_BAG)
  and (XLGB_Banking.currentBankBag ~= BAG_BANK) then
    d("[XLGB_ERROR] House storage chest not open, abort!")
    return false
  else
    local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
    if assignSetToStorage(gearSet, XLGB_Banking.currentBankBag) then
      d("[XLGB] Assigned \'" .. gearSet.name .. "\' to chest.")
      return true
    else 
      d("[XLGB_ERROR] Gearset already assigned to this storage chest.")
    end
  end
end

local function removeSetFromStorage(gearSet, gearSetNameIndex, storageBag, storageBagID)
  for _, item in pairs(gearSet.items) do
    itemIndex = findItemIndexInSet(item, storageBag.assignedItems)
    if (itemIndex ~= XLGB.ITEM_NOT_IN_SET) then
      local itemCount = storageBag.assignedItems[itemIndex].count - 1
      if (itemCount < 1) then
        table.remove(XLGearBanker.savedVariables.storageBags[storageBagID].assignedItems, itemIndex)
        XLGearBanker.savedVariables.storageBags[storageBagID].slotsLeft = XLGearBanker.savedVariables.storageBags[storageBagID].slotsLeft + 1
      else 
        XLGearBanker.savedVariables.storageBags[storageBagID].assignedItems[itemIndex].count = XLGearBanker.savedVariables.storageBags[storageBagID].assignedItems[itemIndex].count - 1
      end
    end
  end
  table.remove(XLGearBanker.savedVariables.storageBags[storageBagID].assignedSets, gearSetNameIndex)
end

local function unassignSetFromStorage(gearSet, storageBagID)
  local storageBag = getStorageBag(storageBagID)
  local gearSetNameIndex = findGearSetInStorage(gearSet.name, storageBag)
  if (gearSetNameIndex == XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
    return false
  else 
    removeSetFromStorage(gearSet, gearSetNameIndex, storageBag, storageBagID)
    return true
  end
end

function XLGB_Banking:UnassignStorage(gearSetNumber)
  if (not XLGB_Banking.bankOpen)
  and (XLGB_Banking.currentBankBag ~= XLGB.NO_BAG)
  and (XLGB_Banking.currentBankBag ~= BAG_BANK) then
    d("[XLGB_ERROR] House storage chest not open, abort!")
    return false
  else
    local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
    if unassignSetFromStorage(gearSet, XLGB_Banking.currentBankBag) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' is no longer assigned to this chest.")
    else 
      d("[XLGB_ERROR] Set \'" .. gearSet.name .. "\' is already not assigned to this chest.")
    end
  end
end

function XLGB_Banking:UpdateStorageOnGearSetRemoved(gearSet)
  for _, storageBagID in pairs(XLGB.storageBagIDs) do
    local storageBag = getStorageBag(storageBagID)
    if (findGearSetInStorage(gearSet.name, storageBag) ~= XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
      unassignSetFromStorage(gearSet, storageBagID)
    end
  end
end

function XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
  for _, storageBagID in pairs(XLGB.storageBagIDs) do
    local storageBag = getStorageBag(storageBagID)
    if (findGearSetInStorage(gearSetBefore.name, storageBag) ~= XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
      unassignSetFromStorage(gearSetBefore, storageBagID)
      if (not assignSetToStorage(gearSetAfter, storageBagID)) then
        d("[XLGB_ERROR] On item update: Couldn't reassign set \'".. gearSetAfter.name .."\' to storageBag with ID: " .. storageBagID)
      end
    end
  end
end

local function toStringOneLine(tableToPrint)
  local res = ""
  for i, entry in ipairs(tableToPrint) do
    if (i == #tableToPrint) then
      res = res .. entry
    else 
      res = res .. entry .. ", "
    end
  end
  return res
end

function XLGB_Banking:DepositStorageItems()
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return
  end
  local storageBag = getStorageBag(XLGB_Banking.currentBankBag)
  d("[XLGB] Depositing assigned items from sets: ", storageBag.assignedSets)
  if depositItemsToBankNonESOPlus(storageBag.assignedItems) then
    d("[XLGB] Assigned items deposited!")
  end
end

function XLGB_Banking:WithdrawStorageItems()
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return
  end
  local storageBag = getStorageBag(XLGB_Banking.currentBankBag)
  d("[XLGB] Withdrawing assigned items from sets", storageBag.assignedSets )
  if withdrawItemsNonESOPlus(storageBag.assignedItems) then
    d("[XLGB] Assigned items withdrawn!")
  end
end

local function createNewStorageBag(storageBagID)
  local storageBag = {}
    storageBag.assignedSets = {}
    storageBag.assignedItems = {}
    storageBag.size = GetBagSize(storageBagID)
    storageBag.slotsLeft = storageBag.size
    return storageBag
end

local function setupStorage(storageBagIDs)
  local storageBags = {}
  for _, storageBagID in pairs(storageBagIDs) do
    local storageBag = createNewStorageBag(storageBagID)
    storageBags[storageBagID] = storageBag
  end
  XLGearBanker.savedVariables.storageBags = storageBags
end

function XLGB_Banking:ClearAssignedSets()
  if not XLGB_Banking.bankOpen
  or (XLGB_Banking.currentBankBag == BAG_BANK) then
    d("[XLGB_ERROR] Storage chest is not open, abort!")
    return
  end
  local storageBag = createNewStorageBag(XLGB_Banking.currentBankBag)
  XLGearBanker.savedVariables.storageBags[XLGB_Banking.currentBankBag] = storageBag
  d("[XLGB] Cleared storage chest assigned sets.")
end

function XLGB_Banking:PrintAssignedSets()
  if not XLGB_Banking.bankOpen
  or (XLGB_Banking.currentBankBag == BAG_BANK) then
    d("[XLGB_ERROR] Storage chest is not open, abort!")
    return
  end
  d("[XLGB] Chest contains the following assigned sets:")
  local storageBag = getStorageBag(XLGB_Banking.currentBankBag)
  for _, gearSetName in pairs(storageBag.assignedSets) do
    d(gearSetName)
  end
  d("[XLGB] Total sets: " .. #storageBag.assignedSets)
  d("[XLGB] Total items: " .. #storageBag.assignedItems .. " out of " .. storageBag.size)
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.recentlyCalled = false
  
  if (XLGearBanker.savedVariables.storageBags == nil) then
    setupStorage(XLGB.storageBagIDs)
  end

  self.storageChestButtonGroup = {
    {
      name = "Deposit Assigned",
      keybind = "DEPOSIT_ASSIGNED_STORAGE_ITEMS",
      callback = function() XLGB_Banking:DepositStorageItems() end,
    },
    {
      name = "Withdraw Assigned",
      keybind = "WITHDRAW_ASSIGNED_STORAGE_ITEMS",
      callback = function() XLGB_Banking:WithdrawStorageItems() end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }
  

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end