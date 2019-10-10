-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"

function XLGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == XLGearBanker.name then
      XLGearBanker:Initialize()
      GearSet:Initialize()
      Banking:Initialize()
      MenuOverWriter:Initialize()
      UI:Initialize()
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

SLASH_COMMANDS["/depositgear"] = Banking.depositGear
SLASH_COMMANDS["/withdrawgear"] = Banking.withdrawGear

SLASH_COMMANDS["/xlgboverview"] = XLGearBanker.ShowUI
-------------------------------------------------------------------------------