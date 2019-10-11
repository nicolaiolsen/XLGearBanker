-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"

function XLGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == XLGearBanker.name then
      XLGearBanker:Initialize()
      XLGB_GearSet:Initialize()
      XLGB_Banking:Initialize()
      XLGB_MenuOverWriter:Initialize()
      XLGB_UI:Initialize()
    end
end

function easyDebug(...)
  if XLGearBanker.debug == true then
    d(...)
  end
end

function XLGearBanker:Initialize()
  self.debug = true
  self.savedVariables = ZO_SavedVars:NewAccountWide("XLGearBankerSavedVariables", 1, nil, {})
end

EVENT_MANAGER:RegisterForEvent(XLGearBanker.name, EVENT_ADD_ON_LOADED, XLGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!

SLASH_COMMANDS["/xlgb_depositgear"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:DepositGear(gearSetNumber)
  end
end
SLASH_COMMANDS["/xlgb_withdrawgear"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_Banking:WithdrawGear(gearSetNumber)
  end
end

SLASH_COMMANDS["/xlgb_overview"] = XLGB_UI.ShowUI

SLASH_COMMANDS["/xlgb_printgearset"] = function (argsv)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  local gearSetNumber = tonumber(argsv)
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGB_GearSet:PrintGearSet(gearSetNumber)
  end
end

SLASH_COMMANDS["/xlgb_addset"] = function (argsv)
  if XLGB_GearSet:ValidGearSetName(argsv) then
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
-------------------------------------------------------------------------------