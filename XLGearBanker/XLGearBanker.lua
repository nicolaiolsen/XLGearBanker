-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"

function XLGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == XLGearBanker.name then
      XLGB_Constants:Initialize()
      XLGearBanker:Initialize()
      XLGB_GearSet:Initialize()
      XLGB_Banking:Initialize()
      XLGB_MenuOverWriter:Initialize()
      --XLGB_UI:Initialize()
    end
end

function easyDebug(...)
  if XLGearBanker.debug == true then
    d("[XLGB_DEBUG] " ..  ...)
  end
end

function XLGearBanker:Initialize()
  self.debug = false
  self.savedVariables = ZO_SavedVars:NewAccountWide("XLGearBankerSavedVariables", 1, nil, {})
end

EVENT_MANAGER:RegisterForEvent(XLGearBanker.name, EVENT_ADD_ON_LOADED, XLGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!
SLASH_COMMANDS["/xlgb_debug"] = function (argsv)
  if XLGearBanker.debug then
    d("[XLGB] Debugging = off.")
    XLGearBanker.debug = false
  else 
    d("[XLGB] Debugging = on.")
    XLGearBanker.debug = true
  end
end

SLASH_COMMANDS["/xlgb_help"] = function (argsv)
  d("[XLGB] Commands")
  d("\'/xlgb_sets\': Prints out saved sets to chat.")
  d("\'/xlgb_items setNumber\': Prints out set #(setNumber)s items to chat.")
  d("\'/xlgb_addset setName\': Creates a new set named (setName).")
  d("\'/xlgb_removeset setNumber\': Removes set #(setNumber).")
  d("\'/xlgb_deposit setNumber\': Deposit all items from set #(setNumber) into the bank.")
  d("\'/xlgb_withdraw setNumber\': Withdraw all items from set #(setNumber) into the player inventory.")
  d("\'/xlgb_debug\': Toggles debug mode. (Note: quite verbose)")
end

SLASH_COMMANDS["/xlgb_deposit"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:DepositGear(gearSetNumber)
  end
end
SLASH_COMMANDS["/xlgb_withdraw"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:WithdrawGear(gearSetNumber)
  end
end

--SLASH_COMMANDS["/xlgb_overview"] = XLGB_UI.ShowUI

SLASH_COMMANDS["/xlgb_sets"] = function (argsv)
  XLGB_GearSet:PrintGearSets()
end

SLASH_COMMANDS["/xlgb_items"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_GearSet:PrintGearSetItems(gearSetNumber)
  end
end

SLASH_COMMANDS["/xlgb_addset"] = function (argsv)
  local gearSetName = argsv
  if XLGB_GearSet:ValidGearSetName(gearSetName) then
    XLGB_GearSet:CreateNewGearSet(gearSetName)
  end
end

SLASH_COMMANDS["/xlgb_removeset"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_GearSet:RemoveGearSet(gearSetNumber)
  end
end

SLASH_COMMANDS["/xlgb_assign"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:AssignStorage(gearSetNumber)
  end
end

SLASH_COMMANDS["/xlgb_unassign"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:UnassignStorage(gearSetNumber)
  end
end
-------------------------------------------------------------------------------