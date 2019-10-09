Banking = {}

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
  easyDebug("\tMoving gearSet #", gearSetNumber)
  if not Banking.bankOpen then 
    easyDebug("\tBank is not open!")
    return 
  else 
    local gearSet = GearSet.getGearSet(gearSetNumber)
    local availableBagSpaces = Banking.getAvailableBagSpaces(targetBag)
    for item in gearSet do
      Banking.moveItem(sourceBag, targetBag, item, availableBagSpaces)
    end
  end
end

function Banking.moveItem(sourceBag, targetBag, item, availableBagSpaces)
  easyDebug("\t\tMoving item", item)

  local moveSuccesful = CallSecureProtected("RequestMoveItem", sourceBag, 1, targetBag, availableBagSpaces[1], 1)

  if moveSuccesful then
    easyDebug("\t\tItem move: Success!")
  else
    easyDebug("\t\tItem move: Failure!")

  end
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

  for i = FindFirstEmptySlotInBag(bag), GetBagSize(bag) do
    if GetItemName(bag, i) == "" then
      table.insert(availableBagSpaces, i)
    end
  end
  easyDebug("Found ", #availableBagSpaces, " available spaces in bag.")
  return availableBagSpaces
end