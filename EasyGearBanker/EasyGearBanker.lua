-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
EasyGearBanker = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
EasyGearBanker.name = "EasyGearBanker"
 
-------------------------------------------------------------------------------
--Slash Commands! --
SLASH_COMMANDS["/withdrawgear"] = function()
    EasyGearBanker.withdrawGear()
  end

-------------------------------------------------------------------------------
function EasyGearBanker:Initialize()
  self.bankOpen = IsBankOpen()
  self.debug = true
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
  
  self.savedVariables = ZO_SavedVars:NewAccountWide("EasyGearBankerSavedVariables", 1, nil, {})

  self:RestorePosition()
end

function EasyGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == EasyGearBanker.name then
      EasyGearBanker:Initialize()
    end
end

function easyDebug(...)
  if EasyGearBanker.debug == true then
    d(...)
  end
end


function EasyGearBanker.OnBankOpenEvent(event, bankBag)
  -- The ~= operator is "not equal to" in Lua.
  if not EasyGearBanker.bankOpen then
    -- The player's state has changed. Update the stored state...
    EasyGearBanker.bankOpen = IsBankOpen()
    
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

function EasyGearBanker.OnBankCloseEvent(event)
  if EasyGearBanker.bankOpen then
    EasyGearBanker.bankOpen = IsBankOpen()
    easyDebug("Bank closed")
  end
end

--[[
  function withdrawGear
  Input:

  Output:
]]--
function EasyGearBanker.withdrawGear()
  if not EasyGearBanker.bankOpen then 
    easyDebug("Bank is not open!")
    return 
  else 
    availableBagSpaces = getAvailableBagSpaces(BAG_BACKPACK)
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
function EasyGearBanker.getAvailableBagSpaces(bag)
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


function EasyGearBanker.OnIndicatorMoveStop()
  EasyGearBanker.savedVariables.left = EasyGearBankerIndicator:GetLeft()
  EasyGearBanker.savedVariables.top = EasyGearBankerIndicator:GetTop()
end

function EasyGearBanker:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  EasyGearBankerIndicator:ClearAnchors()
  EasyGearBankerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(EasyGearBanker.name, EVENT_ADD_ON_LOADED, EasyGearBanker.OnAddOnLoaded)