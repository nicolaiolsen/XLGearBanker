-- Namespace
EasyGearBanker = {}

EasyGearBanker.name = "EasyGearBanker"

function EasyGearBanker:Initialize()
  self.debug = true
  self.savedVariables = ZO_SavedVars:NewAccountWide("EasyGearBankerSavedVariables", 1, nil, {})
  self:RestorePosition()
end

function EasyGearBanker.OnAddOnLoaded(event, addonName)
    if addonName == EasyGearBanker.name then
      EasyGearBanker:Initialize()
      GearSet:Initialize()
      Banking:Initialize()
      MenuOverWriter:Initialize()
    end
end

function easyDebug(...)
  if EasyGearBanker.debug == true then
    d(...)
  end
end


function EasyGearBanker.OnEGBOverviewMoveStop()
  EasyGearBanker.savedVariables.left = EGBOverview:GetLeft()
  EasyGearBanker.savedVariables.top = EGBOverview:GetTop()
end

function EasyGearBanker:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top

  EGBOverview:ClearAnchors()
  EGBOverview:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function EasyGearBanker:ShowUI()
  EGBOverview:SetHidden(false)
end

function EasyGearBanker:HideUI()
  EGBOverview:SetHidden(true)
end

function EasyGearBanker:UICycleLeft()
  easyDebug("UI cycle left called!")
end

EVENT_MANAGER:RegisterForEvent(EasyGearBanker.name, EVENT_ADD_ON_LOADED, EasyGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!

SLASH_COMMANDS["/depositgear"] = Banking.depositGear
SLASH_COMMANDS["/withdrawgear"] = Banking.withdrawGear

SLASH_COMMANDS["/egboverview"] = EasyGearBanker.ShowUI
-------------------------------------------------------------------------------