-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"

-- Default settings.
XLGearBanker.savedVariables = {
  safeMode = true,
  debug = false,
  threshold = 70,
  safeModeDowntime = 10000,
}

function XLGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == XLGearBanker.name then
      XLGB_Constants:Initialize()
      XLGearBanker:Initialize()
      XLGB_GearSet:Initialize()
      XLGB_Page:Initialize()
      XLGB_Banking:Initialize()
      XLGB_MenuOverWriter:Initialize()
      XLGB_Settings:Initialize()
      XLGB_UI:Initialize()
    end
end

function easyDebug(...)
  if sV.debug == true then
    d("[XLGB_DEBUG] " ..  ...)
  end
end

function XLGearBanker:Initialize()
  self.savedVariables = ZO_SavedVars:NewAccountWide("XLGearBankerSavedVariables", 1, nil, XLGearBanker.savedVariables)
  sV = XLGearBanker.savedVariables
end

EVENT_MANAGER:RegisterForEvent(XLGearBanker.name, EVENT_ADD_ON_LOADED, XLGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!
SLASH_COMMANDS["/xlgb_debug"] = function (argsv)
  if sV.debug then
    d("[XLGB] Debugging = off.")
    sV.debug = false
  else 
    d("[XLGB] Debugging = on.")
    sV.debug = true
  end
end

SLASH_COMMANDS["/xlgb_safemode"] = function (argsv)
  if sV.safeMode then
    d("[XLGB] Safe mode = off.")
    sV.safeMode = false
  else 
    d("[XLGB] Safe mode = on.")
    sV.safeMode = true
  end
end

SLASH_COMMANDS["/xlgb_overlay"] = function (argsv)
  XLGB_GreyOverlay:SetHidden(not XLGB_GreyOverlay:IsHidden())
  XLGB_ProgressWindow:SetHidden(not XLGB_ProgressWindow:IsHidden())
end

SLASH_COMMANDS["/xlgb_missing"] = function (argsv)
  XLGB_GearSet:GetMissingItems(BAG_BACKPACK, sV.displayingSet)
end

SLASH_COMMANDS["/xlgb_help"] = function (argsv)
  d("[XLGB] Commands")
  d("\'/xlgb_debug\': Toggles debug mode. (Note: quite verbose)")
end

SLASH_COMMANDS["/xlgb"] = function () XLGB_UI.TogglePageUI() end
-------------------------------------------------------------------------------