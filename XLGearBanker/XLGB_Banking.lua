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
  if (not XLGB_Banking.bankOpen) then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return false
  else
    --Move each item of the specified gearset from sourceBag to targetBag
    for i, itemEntry in ipairs(itemsToMove) do
      moveItem(sourceBag, itemEntry.index, targetBag, availableBagSpaces[i])
    end
    return true
  end
end

local function moveGearFromTwoBags(sourceBagOne, itemsToMoveOne, sourceBagTwo, itemsToMoveTwo, targetBag, availableBagSpaces)
  for i, itemEntry in ipairs(itemsToMoveOne) do
    moveItem(sourceBagOne, itemEntry.index, targetBag, availableBagSpaces[i])
  end
  for i, itemEntry in ipairs(itemsToMoveTwo) do
    moveItem(sourceBagTwo, itemEntry.index, targetBag, availableBagSpaces[i + #itemsToMoveOne])
  end
end

local function depositGearFromTwoBags(gearSet)
  local equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet)
  local availableBagSpaces = getAvailableBagSpaces(XLGB_Banking.currentBankBag)
  local numberOfItemsToMove = #equippedItemsToMove + #inventoryItemsToMove
  if (availableBagSpaces < numberOfItemsToMove) then
    d("[XLGB_ERROR] Trying to move " .. numberOfItemsToMove.. "items into a bag with " .. #availableBagSpaces .." empty slots.")
    return
  end
  moveGearFromTwoBags(
      BAG_BACKPACK, inventoryItemsToMove,
      BAG_WORN, equippedItemsToMove,
      XLGB_Banking.currentBankBag, availableBagSpaces)
end

local function depositGearToBankESOPlus(gearSet)
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    return false
  else
    local availableBagSpacesRegularBank = getAvailableBagSpaces(BAG_BANK)
    local availableBagSpacesESOPlusBank = getAvailableBagSpaces(BAG_SUBSCRIBER_BANK)
    local totalItems = #gearSet.items
    if (#availableBagSpacesRegularBank >= totalItems) then
      return (moveGear(BAG_BACKPACK, BAG_BANK, gearSet) and moveGear(BAG_WORN, BAG_BANK, gearSet))

    elseif ((#availableBagSpacesRegularBank + #availableBagSpacesESOPlusBank) >= totalItems) then

      local itemsToRegularBank = #availableBagSpacesRegularBank
      -- Add items to regular bank
      if itemsToRegularBank > 0 then
        for i = 1, itemsToRegularBank do
          local itemLink = gearSet.items[i].link
          local itemID = gearSet.items[i].ID
          if (#availableBagSpacesRegularBank >= i) then
            moveItem(BAG_BACKPACK, BAG_BANK, itemLink, itemID, availableBagSpacesRegularBank[i])
            moveItem(BAG_WORN, BAG_BANK, itemLink, itemID, availableBagSpacesRegularBank[i])
          end
        end
      else 
        -- If no slots left in regular bank add items to subscriber bank
        itemsToRegularBank = 1
      end
      -- Add remaining items to available slots in subscriber bank
      for i = itemsToRegularBank, totalItems do
        local itemLink = gearSet.items[i].link
        local itemID = gearSet.items[i].ID
        if (#availableBagSpacesESOPlusBank >= i) then
          moveItem(BAG_BACKPACK, BAG_BANK, itemLink, itemID, availableBagSpacesESOPlusBank[i-itemsToRegularBank +1])
          moveItem(BAG_WORN, BAG_BANK, itemLink, itemID, availableBagSpacesESOPlusBank[i-itemsToRegularBank +1])
        end
      end
      return true
    end
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
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Depositing " .. gearSet.name)

  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    local equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet)
    local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet)
    if depositGearToBankESOPlus(equippedItemsToMove, inventoryItemsToMove) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
      return
    end

  elseif (XLGB_Banking.currentBankBag == BAG_BANK) 
  or (XLGB_Banking.currentBankBag == gearSet.assignedBag) then
    depositGearFromTwoBags(gearSet)
    d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
    
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
    return
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
    return
  end
  moveGear(XLGB_Banking.currentBankBag, BAG_BACKPACK, itemsToMove)
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
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Withdrawing " .. gearSet.name)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    withdrawGearESOPlus(gearSet)
    d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
  else 
    withdrawGearNonESOPlus(gearSet)
    d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
  end
  --[[
  zo_callLater(function()
    XLGB_Banking.recentlyCalled = false
  end, 3000)
  ]]--
end

--[[
  function AssignStorage
  Input:

  Output:
]]--
function XLGB_Banking:AssignStorage(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  if (not XLGB_Banking.bankOpen) 
  and (XLGB_Banking.currentBankBag ~= XLGB.NO_BAG)
  and (XLGB_Banking.currentBankBag ~= BAG_BANK) then
    d("[XLGB_ERROR] House storage chest not open, abort!")
    return false
  else
    XLGB_GearSet:AssignBagToStorage(gearSetNumber, XLGB_Banking.currentBankBag)
    d("[XLGB] Assigned \'" .. gearSet.name .. "\' to chest.")
    return true
  end
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.recentlyCalled = false
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end