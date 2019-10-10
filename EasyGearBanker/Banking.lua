--Namespace
Banking = {}

--[[
  Banking.lua

  This module contains all functionality related to item transfer.

  Functions:

]]--

function Banking:Initialize()
  self.bankOpen = IsBankOpen()
  self.debug = true
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
end

function Banking.OnBankOpenEvent(event, bankBag)
  if not Banking.bankOpen then
    Banking.bankOpen = IsBankOpen()
    easyDebug("Bank open!")
  end
end

function Banking.OnBankCloseEvent(event)
  if Banking.bankOpen then
    Banking.bankOpen = IsBankOpen()
    easyDebug("Bank closed")
  end
end

--[[
  function depositGear
  Input:

  Output:
]]--
function Banking.depositGear(gearSetNumber)
  Banking.moveGear(BAG_BACKPACK, BAG_BANK, gearSetNumber)
end

--[[
  function withdrawGear
  Input:

  Output:
]]--
function Banking.withdrawGear(gearSetNumber)
  Banking.moveGear(BAG_BANK, BAG_BACKPACK, gearSetNumber)
end

function Banking.moveGear(sourceBag, targetBag, gearSetNumber)
  easyDebug("Moving gearSet #", gearSetNumber)
  if not Banking.bankOpen then
    easyDebug("Bank is not open!")
    return
  else
    -- retrieve list of item ids (gearSet) related to the gearSetNumber
    local gearSet = GearSet.getGearSet(gearSetNumber)
    local availableBagSpaces = Banking.getAvailableBagSpaces(targetBag)
    --Move each item of the specified gearset from sourceBag to targetBag
    for _, item in ipairs(gearSet) do
      Banking.moveItem(sourceBag, targetBag, item, availableBagSpaces)
    end
  end
end


function Banking.moveItem(sourceBag, targetBag, item, availableBagSpaces)
  easyDebug("Moving item", item)
  --local itemIndex = Banking.findItemIndexInBag(sourceBag, item)
  local itemIndex = item
  local moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, itemIndex, targetBag, availableBagSpaces[#availableBagSpaces], 1)

  if moveSuccesful then
    easyDebug("Item move: Success!")
    table.remove(availableBagSpaces)
  else
    easyDebug("Item move: Failure!")
  end
end

function Banking.findItemIndexInBag(bag, itemID)
  for i = 0, GetBagSize(bag) do
    if GetItemUniqueID(bag, i) == itemID then
      return i
    end
  end
  return -1
end

--[[
  function getAvailableBagSpaces

    Returns a list of empty bag spaces.

  Input:
    bag = A bag as specified in the API constants (e.g. BAG_BANK, BAG_BACKPACK)

  Output:
    availableBagSpaces = Lua table containing indices of empty bag slots.
]]--
function Banking.getAvailableBagSpaces(bag)
  easyDebug("Finding available bagspaces in bag: ", bag )
  local availableBagSpaces = {}

  for i = FindFirstEmptySlotInBag(bag), GetBagSize(bag)-1 do
    if GetItemName(bag, i) == "" then
      table.insert(availableBagSpaces, #availableBagSpaces, i)
    end
  end
  easyDebug("Found ", #availableBagSpaces, " available spaces in bag.")
  return availableBagSpaces
end