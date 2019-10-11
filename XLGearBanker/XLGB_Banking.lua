--[[
  XLGB_Banking.lua

  This module contains all functionality related to item transfer.

  Functions:

]]--

--Namespace
XLGB_Banking = {}

local ITEM_NOT_IN_BAG = -1

function XLGB_Banking.OnBankOpenEvent(event, bankBag)
  if not XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    easyDebug("Bank open!")
  end
end

function XLGB_Banking.OnBankCloseEvent(event)
  if XLGB_Banking.bankOpen then
    XLGB_Banking.bankOpen = IsBankOpen()
    easyDebug("Bank closed")
  end
end

local function findItemIndexInBag(bag, itemLink)
  local item_index = -1
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
  easyDebug("Finding available bagspaces in bag: " .. bag )
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
  if (itemIndex ~= ITEM_NOT_IN_BAG) then
    moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, itemIndex, targetBag, availableBagSpaces[#availableBagSpaces], 1)
  end

  if moveSuccesful then
    easyDebug("Item move: Success!")
    table.remove(availableBagSpaces)
  end
end

local function moveGear(sourceBag, targetBag, gearSet)
  if not XLGB_Banking.bankOpen then
    d("XLGB:Bank is not open, abort!")
    return false
  else
    local availableBagSpaces = getAvailableBagSpaces(targetBag)
    --Move each item of the specified gearset from sourceBag to targetBag
    for _, item in pairs(gearSet.items) do
      moveItem(sourceBag, targetBag, item.link, availableBagSpaces)
    end
    return true
  end
end

local function depositGearESOPlus(gearSet)
  if not XLGB_Banking.bankOpen then
    d("XLGB Error: Bank is not open, abort!")
    return false
  else
    local availableBagSpacesRegularBank = getAvailableBagSpaces(BAG_BANK)
    local availableBagSpacesESOPlusBank = getAvailableBagSpaces(BAG_SUBSCRIBER_BANK)
    local totalItems = #gearSet.items
    if (#availableBagSpacesRegularBank >= totalItems) then
      return moveGear(BAG_BACKPACK, BAG_BANK, gearSet)
    else
      local itemsToRegularBank = #availableBagSpacesRegularBank
      local itemsToESOPlusBank = totalItems - itemsToRegularBank
      if (#availableBagSpacesRegularBank >= totalItems) then
        for i = 1, itemsToRegularBank do
          local itemLink = gearSet.items[i].link
          moveItem(BAG_BACKPACK, BAG_BANK, itemLink, availableBagSpacesRegularBank)
        end
        for i = itemsToRegularBank, itemsToESOPlusBank do
          local itemLink = gearSet.items[i].link
          moveItem(BAG_BACKPACK, BAG_BANK, itemLink, availableBagSpacesESOPlusBank)
        end
      else 
        d("XLGB Error: Not enough space in bank.", 
        "Available bankspace = " .. (#availableBagSpacesRegularBank + #availableBagSpacesESOPlusBank),  
        "Amount of items in set \'" .. gearSet.name .. "\' = " .. totalItems)
        return false 
      end
    end
  end
end
--[[
  function depositGear
  Input:

  Output:
]]--
function XLGB_Banking:DepositGear(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("XLGB: Depositing " .. gearSet.name)
  if IsESOPlusSubscriber() then
    if depositGearESOPlus(gearSet) then
      d("XLGB: Set \'" .. gearSet.name .. "\' deposited!")
      return
    end
  elseif moveGear(BAG_BACKPACK, BAG_BANK, gearSet) then
    d("XLGB: Set \'" .. gearSet.name .. "\' deposited!")
  end
end

--[[
  function withdrawGear
  Input:

  Output:
]]--
function XLGB_Banking:WithdrawGear(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("XLGB: Withdrawing " .. gearSet.name)
  if IsESOPlusSubscriber() then
    if moveGear(BAG_BANK, BAG_BACKPACK, gearSet) and moveGear(BAG_SUBSCRIBER_BANK, BAG_BACKPACK, gearSet) then
      d("XLGB: Set \''" .. gearSet.name .. "\' withdrawn!'")
      return
    end
  elseif moveGear(BAG_BANK, BAG_BACKPACK, gearSet) then
    d("XLGB: Set \''" .. gearSet.name .. "\' withdrawn!'")
  end
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end