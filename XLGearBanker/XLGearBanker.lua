-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"

-- Default settings.
XLGearBanker.savedVariables = {
  safeMode = true,
  debug = false,
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
end

SLASH_COMMANDS["/xlgb_help"] = function (argsv)
  d("[XLGB] Commands")
  d("\'/xlgb_debug\': Toggles debug mode. (Note: quite verbose)")
end

SLASH_COMMANDS["/xlgb_event"] = function (argsv)
  local function _onInventoryChanged(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    local link = GetItemLink(bagId, slotIndex)
    d("Picked up a " .. link .. ".")
  end
  XLGearBanker.eventActive = XLGearBanker.eventActive or false
  if XLGearBanker.eventActive then
    d("Unregistering for event!")
    XLGearBanker.eventActive = false
    EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  else
    d("Registering for event!")
    EVENT_MANAGER:RegisterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    XLGearBanker.eventActive = true
  end
end

SLASH_COMMANDS["/xlgb"] = function () XLGB_UI.TogglePageUI() end
-------------------------------------------------------------------------------