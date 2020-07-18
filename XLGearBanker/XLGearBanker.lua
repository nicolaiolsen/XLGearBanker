-- Namespace
XLGearBanker = {}

XLGearBanker.name = "XLGearBanker"
local sV

function XLGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == XLGearBanker.name then
      XLGB_Constants:Initialize()
      XLGearBanker:Initialize()
      XLGB_GearSet:Initialize()
      XLGB_Page:Initialize()
      XLGB_Banking:Initialize()
      XLGB_MenuOverWriter:Initialize()
      XLGB_UI:Initialize()
    end
end

function easyDebug(...)
  if sV.debug == true then
    d("[XLGB_DEBUG] " ..  ...)
  end
end

function XLGearBanker:Initialize()
  self.debug = false
  self.savedVariables = ZO_SavedVars:NewAccountWide("XLGearBankerSavedVariables", 1, nil, {})
  sV = self.savedVariables
  sV.debug = sV.debug or false
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
    EVENT_MANAGER:UnregisterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  else
    EVENT_MANAGER:RegisterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(XLGearBanker.name .. "InventoryChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
  end
end

SLASH_COMMANDS["/xlgb"] = function () XLGB_UI.TogglePageUI() end
-------------------------------------------------------------------------------