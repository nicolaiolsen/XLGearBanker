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
  easyDebug("Finding available bagspaces in bag: ", bag )
  local availableBagSpaces = {}

  for i = 0, GetBagSize(bag)-1 do
    if GetItemName(bag, i) == "" then
      table.insert(availableBagSpaces, #availableBagSpaces, i)
    end
  end
  easyDebug("Found ", #availableBagSpaces, " available spaces in bag.")
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

local function moveGear(sourceBag, targetBag, gearSetNumber)
  easyDebug("Moving gearSet #", gearSetNumber)
  if not XLGB_Banking.bankOpen then
    easyDebug("Bank is not open!")
    return
  else
    -- retrieve list of item ids (gearSet) related to the gearSetNumber
    local gearSet = GearSet:GetGearSet(gearSetNumber)
    local availableBagSpaces = getAvailableBagSpaces(targetBag)
    --Move each item of the specified gearset from sourceBag to targetBag
    for _, item in pairs(gearSet.items) do
      moveItem(sourceBag, targetBag, item.link, availableBagSpaces)
    end
  end
end
--[[
  function depositGear
  Input:

  Output:
]]--
function XLGB_Banking:DepositGear(gearSetNumber)
  moveGear(BAG_BACKPACK, BAG_BANK, gearSetNumber)
end

--[[
  function withdrawGear
  Input:

  Output:
]]--
function XLGB_Banking:WithdrawGear(gearSetNumber)
  moveGear(BAG_BANK, BAG_BACKPACK, gearSetNumber)
end

function XLGB_Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.debug = true
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end