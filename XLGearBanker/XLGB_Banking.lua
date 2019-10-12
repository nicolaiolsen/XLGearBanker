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

local function findItemIndexInBag(bag, itemLink)
  local item_index = XLGB.ITEM_NOT_IN_BAG
  for i = 0, GetBagSize(bag) do
    if GetItemLink(bag, i) == itemLink then
      item_index = i
      return item_index
    end
  end
  return item_index
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

  for i = 0, GetBagSize(bag)-1 do
    if GetItemName(bag, i) == "" then
      table.insert(availableBagSpaces, #availableBagSpaces, i)
    end
  end
  easyDebug("Found " .. #availableBagSpaces .. " available spaces in bag.")
  return availableBagSpaces
end

local function moveItem(sourceBag, targetBag, itemLink, availableBagSpaces)
  easyDebug("Moving item", itemLink)
  local itemIndex = findItemIndexInBag(sourceBag, itemLink)
  local moveSuccesful = false
  if (itemIndex ~= XLGB.ITEM_NOT_IN_BAG) and (#availableBagSpaces > 0) then
    moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, itemIndex, targetBag, availableBagSpaces[#availableBagSpaces], 1)
  end
  if moveSuccesful then
    easyDebug("Item move: Success!")
    table.remove(availableBagSpaces)
  end
end

local function moveGear(sourceBag, targetBag, gearSet)
  if not XLGB_Banking.bankOpen then
    d("[XLGB]Bank is not open, abort!")
    return false
  else
    local availableBagSpaces = getAvailableBagSpaces(targetBag)
    --Move each item of the specified gearset from sourceBag to targetBag
    for _, item in pairs(gearSet.items) do
      zo_callLater(
        function () 
          moveItem(sourceBag, targetBag, item.link, availableBagSpaces)
        end, 100)
    end
    return true
  end
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
          moveItem(BAG_BACKPACK, BAG_BANK, itemLink, availableBagSpacesRegularBank)
          moveItem(BAG_WORN, BAG_BANK, itemLink, availableBagSpacesRegularBank)
        end
      else 
        -- If no slots left in regular bank add items to subscriber bank
        itemsToRegularBank = 1
      end
      -- Add remaining items to available slots in subscriber bank
      for i = itemsToRegularBank, totalItems do
        local itemLink = gearSet.items[i].link
        moveItem(BAG_BACKPACK, BAG_BANK, itemLink, availableBagSpacesESOPlusBank)
        moveItem(BAG_WORN, BAG_BANK, itemLink, availableBagSpacesRegularBank)
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
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Depositing " .. gearSet.name)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if depositGearToBankESOPlus(gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
      return
    end
  
  elseif (self.currentBankBag == BAG_BANK) or (XLGB_Banking.currentBankBag == gearSet.assignedBag) then
    if moveGear(BAG_BACKPACK, XLGB_Banking.currentBankBag, gearSet) 
    and moveGear(BAG_WORN, XLGB_Banking.currentBankBag, gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' deposited!")
    end
  else
    d("[XLGB] Set \'" .. gearSet.name .. "\' does not belong to this storage chest.",
  "To assign this chest to  \'" .. gearSet.name .. "\' use  \'/xlgb_assign setNumber\'")
  end
end

--[[
  function WithdrawGear
  Input:

  Output:
]]--
function XLGB_Banking:WithdrawGear(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("[XLGB] Withdrawing " .. gearSet.name)
  if IsESOPlusSubscriber() and (XLGB_Banking.currentBankBag == BAG_BANK) then
    if moveGear(XLGB_Banking.currentBankBag, BAG_BACKPACK, gearSet) and moveGear(BAG_SUBSCRIBER_BANK, BAG_BACKPACK, gearSet) then
      d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
      return
    end
  elseif moveGear(XLGB_Banking.currentBankBag, BAG_BACKPACK, gearSet) then
    d("[XLGB] Set \'" .. gearSet.name .. "\' withdrawn!")
  end
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
    local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()

    local storageNotAlreadyAssigned = true
    for i = 1, totalGearSets do
      local assignedBag = XLGB_GearSet:GetGearSet(i).assignedBag
      if (assignedBag == XLGB_Banking.currentBankBag) 
      and (i ~= gearSetNumber) then
        storageNotAlreadyAssigned = false
        d("[XLGB_ERROR] Storage is already assigned to another set. Only one set allowed per chest!")
        return storageNotAlreadyAssigned
      end
    end

    if storageNotAlreadyAssigned then
      XLGB_GearSet:AssignBagToStorage(gearSetNumber, XLGB_Banking.currentBankBag)
      d("[XLGB] Assigned \'" .. gearSet.name .. "\' to chest.")
      return true
    end
  end
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end