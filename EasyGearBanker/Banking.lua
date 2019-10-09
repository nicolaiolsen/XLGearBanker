Banking = {}

function Banking:Initialize()
    self.bankOpen = IsBankOpen()
    self.debug = true
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
  end

function Banking.OnBankOpenEvent(event, bankBag)
    -- The ~= operator is "not equal to" in Lua.
    if not Banking.bankOpen then
      -- The player's state has changed. Update the stored state...
      Banking.bankOpen = IsBankOpen()
      
      easyDebug("Bank open!")
      --[[
      local slot = ZO_GetNextBagSlotIndex(bankBag)
  
      if CheckInventorySpaceSilently(1) then
        easyDebug("There's an empty slot in player inventory, moving first item from bank!")
        local emptySlotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)
        easyDebug(emptySlotIndex)
        local movedItem = CallSecureProtected("RequestMoveItem", BAG_BANK, slot, BAG_BACKPACK, emptySlotIndex, 1)
        easyDebug(movedItem)
      end
  
      while slot do
        if slot == 1 then
          
        end
        slot = ZO_GetNextBagSlotIndex(bag, slot)
      end
      ]]--
  
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
function Banking.depositGear(gearSet)
  easyDebug("Attempting to deposit gearSet #", gearSet)
  if not Banking.bankOpen then 
    easyDebug("Bank is not open!")
    return 
  else 
    local availableBagSpaces = Banking.getAvailableBagSpaces(BAG_BANK)
    
  end
end

--[[
  function withdrawGear
  Input:

  Output:
]]--
function Banking.withdrawGear(gearSet)
  easyDebug("Attempting to withdraw gearSet #", gearSet)
  if not Banking.bankOpen then 
    easyDebug("Bank is not open!")
    return 
  else 
    local availableBagSpaces = Banking.getAvailableBagSpaces(BAG_BACKPACK)

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