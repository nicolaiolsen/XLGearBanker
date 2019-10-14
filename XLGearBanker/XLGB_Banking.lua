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
    easyDebug("Bank open!")
  end
end

function XLGB_Banking.OnBankCloseEvent(event)
  if XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    XLGB_Banking.currentBankBag = XLGB.NO_BAG
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

local function findItemsToMove(sourceBag, gearSet)
  local itemsToMove = {}
  for _, item in pairs(gearSet.items) do
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

local function depositGearToBankNonESOPlus(gearSet)
  local equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet)

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
  local equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet)

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
    

  elseif (XLGB_Banking.currentBankBag == BAG_BANK) 
  or (XLGB_Banking.currentBankBag == gearSet.assignedBag) then
    if depositGearToBankNonESOPlus(gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
    end
    
  else
    d("[XLGB] Set \'" .. gearSet.name .. "\' does not belong to this storage chest.",
  "To assign this chest to  \'" .. gearSet.name .. "\' use  \'/xlgb_assign setNumber\'")
  end
  --[[
  zo_callLater(function()
    XLGB_Banking.recentlyCalled = false
  end, 3000)
  ]]--
end

local function withdrawGearESOPlus(gearSet)
  local regularBankItemsToMove = findItemsToMove(BAG_BANK, gearSet)
  local ESOPlusItemsToMove = findItemsToMove(BAG_SUBSCRIBER_BANK, gearSet)
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

local function withdrawGearNonESOPlus(gearSet)
  local itemsToMove = findItemsToMove(XLGB_Banking.currentBankBag, gearSet)
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
    if withdrawGearNonESOPlus(gearSet) then
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

local function findGearSetInStorage(gearSet, storageBag)
  local gearSetIndex = XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE
  for i, storageGearSet in pairs(storageBag.gearSets) do
    if (gearSet.name == storageGearSet.name) then
      gearSetIndex = i
      return gearSetIndex
    end
  end
  return gearSetIndex
end

local function isItemDuplicate(sourceItem, targetItems)
  local isDuplicate = false
  for _, targetItem in pairs(targetItems) do
    if (sourceItem.ID == targetItem.ID) then
      isDuplicate = true
      return isDuplicate
    end
  end
  return isDuplicate
end

local function compareItemSets(sourceItems, targetItems)
  local uniqueItems, duplicateItems = {}
  for _, sourceItem in pairs(sourceItems) do
    if (isItemDuplicate(sourceItem, targetItems)) then
      table.insert(duplicateItems, sourceItem)
    else
      table.insert(uniqueItems, sourceItem)
    end
  end
  return uniqueItems, duplicateItems
end

local function compareItemsWithStorage(sourceItems, storageBag)
  local duplicateItems = {}
  local uniqueItems = sourceItems
  for _, gearSet in pairs(storageBag.gearSets) do 
    uniqueItems, duplicateItems = compareItemSets(uniqueItems, gearSet.items)
  end
  return uniqueItems, duplicateItems
end

local function addSetToStorageSets(gearSet, storageBagID)
  table.insert(XLGearBanker.savedVariables[storageBagID].gearSets, gearSet)
end

local function assignSetToStorage(gearSetNumber, storageBagID)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("Assigning storagebagID " .. storageBagID)
  local storageBag = getStorageBag(storageBagID)
  d(storageBag)
  local gearSetIndex = findGearSetInStorage(gearSet, storageBag)
  if (gearSetIndex ~= XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
    d("[XLGB_ERROR] Gearset already assigned to this storage chest.")
    return false
  end
  local _, itemsNotAlreadyAssigned = compareItemsWithStorage(gearSet, storageBag)
  local slotsLeft = storageBag.size - storageBag.slotsLeft
  if (slotsLeft < #itemsNotAlreadyAssigned) then
    d("[XLGB_ERROR] Cannot assign set to storage. Trying to assign " .. #itemsNotAlreadyAssigned .. " items when only " .. slotsLeft .. " are open for assignment.")
    return false
  end
  addSetToStorageSets(gearSet, storageBagID)
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
    end
  end
end

local function unassignSetFromStorage(gearSet, storageBagID)
  local storageBag = getStorageBag(storageBagID)
  local gearSetIndex = findGearSetInStorage(gearSet, storageBag)
  if (gearSetIndex == XLGB.GEARSET_NOT_ASSIGNED_TO_STORAGE) then
    d("[XLGB_ERROR] Set \'" .. gearSet.name .. "\' is already not assigned to this chest.")
    return false
  else 
    table.remove(storageBag.gearSets, gearSetIndex)
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
      d("[XLGB] Set \'" .. gearSet.name .. "\' is no more assigned to this chest.")
    end
  end
end

local function setupStorage(storageBagIDs)
  local storageBags = {}
  for _, storageBagID in pairs(storageBagIDs) do
    local storageBag = {}
    storageBag.gearSets = {}
    storageBag.assignedItems = {}
    storageBag.size = GetBagSize(storageBagID)
    storageBag.slotsLeft = storageBag.size
    storageBags[storageBagID] = storageBag
  end
  XLGearBanker.savedVariables.storageBags = storageBags
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.recentlyCalled = false
  self.storageBagIDs = {
    bag_eight = BAG_HOUSE_BANK_EIGHT,
    bag_five = BAG_HOUSE_BANK_FIVE,
    bag_four = BAG_HOUSE_BANK_FOUR,
    bag_nine = BAG_HOUSE_BANK_NINE,
    bag_one = BAG_HOUSE_BANK_ONE,
    bag_seven = BAG_HOUSE_BANK_SEVEN,
    bag_size = BAG_HOUSE_BANK_SIX,
    bag_ten = BAG_HOUSE_BANK_TEN,
    bag_three = BAG_HOUSE_BANK_THREE,
    bag_two = BAG_HOUSE_BANK_TWO
  }
  if (XLGearBanker.savedVariables.storageBags == nil) then
    setupStorage(self.storageBagIDs)
  end
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end