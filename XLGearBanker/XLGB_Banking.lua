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
    XLGB_UI:OnBankOpen()
    KEYBIND_STRIP:AddKeybindButtonGroup(XLGB_Banking.bankButtonGroup)
    easyDebug("Bank open!")
  end
end

function XLGB_Banking.OnBankCloseEvent(event)
  if XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    XLGB_Banking.currentBankBag = XLGB.NO_BAG
    XLGB_Banking.moveCancelled = true
    XLGB_UI:OnBankClosed()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(XLGB_Banking.bankButtonGroup)
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
  local slot = FindFirstEmptySlotInBag(bag)
  while slot do
    if GetItemName(bag, slot) == "" then
      table.insert(availableBagSpaces, slot)
    end
    slot = ZO_GetNextBagSlotIndex(bag, slot)
  end
  -- for i = firstEmptySlot, GetBagSize(bag) do
  --   if GetItemName(bag, i) == "" then
  --     table.insert(availableBagSpaces, i)
  --   end
  -- end

  easyDebug("Found " .. #availableBagSpaces .. " available spaces in bag.")
  return availableBagSpaces
end

local function stopMovingItems()
  EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "MoveGearFromTwoBags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "MoveGear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  XLGB_Banking.waitingForBag = false
  XLGB_Banking.movingItems = false
end

local function moveItem(sourceBag, itemIndex, targetBag, availableSpace)
  local moveSuccesful = false
  moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, itemIndex, targetBag, availableSpace, 1)
  if moveSuccesful then
    easyDebug("Item move: Success!")
  end
end

local function moveItemDelayed(sourceBag, itemIndex, targetBag, availableSpace)
  zo_callLater(function () moveItem(sourceBag, itemIndex, targetBag, availableSpace) end, 50)
end

local function moveGear(sourceBag, itemsToMove, targetBag, availableBagSpaces)
  local nextIndex = 1
  if nextIndex > #itemsToMove then
    return stopMovingItems()
  end

  local function _onTargetBagItemReceived(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    d("Received item!")
    if XLGB_Banking.moveCancelled then
      d("Move cancelled!")
      return stopMovingItems()
    end
    if (#availableBagSpaces < nextIndex) then
      return stopMovingItems()
    end
    if (nextIndex > #itemsToMove) then
      d("Bag done!")
      return stopMovingItems()
    end
    d("(".. tostring(sourceBag) .. ") Moving item [" .. tostring(nextIndex) .. "/" .. tostring(#itemsToMove) .. "]")
    moveItemDelayed(sourceBag, itemsToMove[nextIndex].index, targetBag, availableBagSpaces[nextIndex])
    nextIndex = nextIndex + 1
  end

  EVENT_MANAGER:RegisterForEvent(XLGearBanker.name .. "MoveGear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onTargetBagItemReceived)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, targetBag)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  moveItem(sourceBag, itemsToMove[nextIndex].index, targetBag, availableBagSpaces[nextIndex])
  nextIndex = nextIndex + 1

  -- for i, itemEntry in ipairs(itemsToMove) do
  --   zo_callLater(function()
  --     moveItem(sourceBag, itemEntry.index, targetBag, availableBagSpaces[i]) end,
  --     200
  --   )
  -- end
end

local function moveGearFromTwoBags(sourceBagOne, itemsToMoveOne, sourceBagTwo, itemsToMoveTwo, targetBag, availableBagSpaces)
  local nextIndex = 1
  local sourceBag = sourceBagOne
  local itemsToMove = itemsToMoveOne
  local availableSpaceOffset = 0

  if nextIndex > #itemsToMove then
    d("Bag 1 done! Swapping to bag 2! (before Event)")
    availableSpaceOffset = #itemsToMove
    sourceBag = sourceBagTwo
    itemsToMove = itemsToMoveTwo
  end

  if nextIndex > #itemsToMove then
    d("Bag 2 done! (before Event)")
    return stopMovingItems()
  end

  local function _onTargetBagItemReceived(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    d("Received item!")
    if XLGB_Banking.moveCancelled then
      d("Move cancelled!")
      return stopMovingItems()
    end
    if (#availableBagSpaces < nextIndex) then
      return stopMovingItems()
    end
    if (nextIndex > #itemsToMove) then
      if sourceBag == sourceBagTwo then 
        d("Bag 2 done!")
        return stopMovingItems()
      else
        d("Bag 1 done! Swapping to bag 2!")
        availableSpaceOffset = #itemsToMove
        sourceBag = sourceBagTwo
        itemsToMove = itemsToMoveTwo
        nextIndex = 1
        return _onTargetBagItemReceived()
      end
    end
    d("(".. tostring(sourceBag) .. ") Moving item [" .. tostring(nextIndex) .. "/" .. tostring(#itemsToMove) .. "]")
    moveItemDelayed(sourceBag, itemsToMove[nextIndex].index, targetBag, availableBagSpaces[nextIndex + availableSpaceOffset])
    nextIndex = nextIndex + 1
  end

  EVENT_MANAGER:RegisterForEvent(XLGearBanker.name .. "MoveGearFromTwoBags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onTargetBagItemReceived)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGearFromTwoBags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGearFromTwoBags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, targetBag)
  EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "MoveGearFromTwoBags", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  -- d("Source Bag 1: " .. tostring(sourceBagOne))
  -- d("ItemsToMove 1: " .. tostring(#itemsToMoveOne))
  -- d("-")
  -- d("Source Bag 2: " .. tostring(sourceBagTwo))
  -- d("ItemsToMove 2: " .. tostring(#itemsToMoveTwo))
  -- d("-")
  -- d("Equipment bag: " .. tostring(BAG_WORN))
  -- d("Backpack bag: " .. tostring(BAG_BACKPACK))
  -- d("-")

  moveItem(sourceBag, itemsToMove[nextIndex].index, targetBag, availableBagSpaces[nextIndex + availableSpaceOffset])
  nextIndex = nextIndex + 1
  -- for i, itemEntry in ipairs(itemsToMoveOne) do
  --   -- Stop when there are no more bag spaces,
  --   -- return bag and index of item that was to be moved next.
  --   if (#availableBagSpaces < i) then return sourceBagOne, i end
  --   zo_callLater(function()
  --     moveItem(sourceBagOne, itemEntry.index, targetBag, availableBagSpaces[i]) end,
  --     200
  --   )
  -- end
  -- for i, itemEntry in ipairs(itemsToMoveTwo) do
  --   -- Stop when there are no more bag spaces,
  --   -- return bag and index of item that was to be moved next.
  --   if (#availableBagSpaces < i + #itemsToMoveOne) then return sourceBagTwo, i end
  --   zo_callLater(function()
  --     moveItem(sourceBagTwo, itemEntry.index, targetBag, availableBagSpaces[i + #itemsToMoveOne]) end,
  --     200
  --   )
  -- end
end

local function depositItemsToBankNonESOPlus(itemsToDeposit)
  local equippedItemsToMove = findItemsToMove(BAG_WORN, itemsToDeposit)
  local inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, itemsToDeposit)

  local availableBagSpaces = getAvailableBagSpaces(XLGB_Banking.currentBankBag)
  local numberOfItemsToMove = #equippedItemsToMove + #inventoryItemsToMove

  if (#availableBagSpaces < numberOfItemsToMove) then
    return false
  end

  moveGearFromTwoBags(
      BAG_BACKPACK, inventoryItemsToMove,
      BAG_WORN, equippedItemsToMove,
      XLGB_Banking.currentBankBag, availableBagSpaces)
  return true
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
    moveGearFromTwoBags(
        BAG_BACKPACK, inventoryItemsToMove,
        BAG_WORN, equippedItemsToMove,
        BAG_BANK, availableBagSpacesRegularBank)

    XLGB_Banking.waitingForBag = true

    local function _waitForBag()
      d("Waiting for bag to finish...")
      if XLGB_Banking.waitingForBag then return end
      d("-")
      d("-")
      d("Starting 2nd bank bag ------------")
      d("-")
      d("-")
      inventoryItemsToMove = findItemsToMove(BAG_BACKPACK, gearSet.items)
      equippedItemsToMove = findItemsToMove(BAG_WORN, gearSet.items)

      moveGearFromTwoBags(
          BAG_BACKPACK, inventoryItemsToMove,
          BAG_WORN, equippedItemsToMove,
          BAG_SUBSCRIBER_BANK, availableBagSpacesESOPlusBank)

      EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "WaitingForBag")
    end

    EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "WaitingForBag")
    EVENT_MANAGER:RegisterForEvent(XLGearBanker.name .. "WaitingForBag", 500, _waitForBag)

    return true
  end
end

function XLGB_Banking:DepositSet(gearSetName)
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    PlaySound(SOUNDS.ABILITY_FAILED)
    return false
  end
  
  if XLGB_Banking.movingItems then
    d("Already moving")
    return false
  end
  XLGB_Banking.movingItems = true
  XLGB_Banking.moveCancelled = false

  local gearSet = XLGB_GearSet:FindGearSet(gearSetName)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if depositGearToBankESOPlus(gearSet) then
      PlaySound(SOUNDS.INVENTORY_ITEM_UNLOCKED)
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
      return true
    end
    
  else
    if depositItemsToBankNonESOPlus(gearSet.items) then
      PlaySound(SOUNDS.INVENTORY_ITEM_UNLOCKED)
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
      return true
    end
  end
  PlaySound(SOUNDS.ABILITY_FAILED)
  XLGB_Banking.movingItems = false
  return false
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
  return true
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

function XLGB_Banking:WithdrawSet(gearSetName)
  if not XLGB_Banking.bankOpen then
    d("[XLGB_ERROR] Bank is not open, abort!")
    PlaySound(SOUNDS.ABILITY_FAILED)
    return false
  end

  if XLGB_Banking.movingItems then
    d("Already moving")
    return false
  end
  XLGB_Banking.movingItems = true
  XLGB_Banking.moveCancelled = false

  local gearSet = XLGB_GearSet:FindGearSet(gearSetName)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if withdrawGearESOPlus(gearSet) then
      PlaySound(SOUNDS.RETRAITING_ITEM_TO_RETRAIT_REMOVED)
      d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
      return true
    end
  else 
    if withdrawItemsNonESOPlus(gearSet.items) then
      PlaySound(SOUNDS.RETRAITING_ITEM_TO_RETRAIT_REMOVED)
      d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
      return true
    end
  end
  PlaySound(SOUNDS.ABILITY_FAILED)
  XLGB_Banking.movingItems = false
  return false

end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.recentlyCalled = false
  self.moveCancelled = false
  self.movingItems = false
  self.waitingForBag = false
  
  self.bankButtonGroup = {
    {
      name = "Toggle XLGB UI",
      keybind = "TOGGLE_XLGB_UI",
      callback = function() XLGB_UI:TogglePageUI() end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }
  

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end