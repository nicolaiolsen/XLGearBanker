-- Namespace
EasyGearBanker = {}

EasyGearBanker.name = "EasyGearBanker"
local EGB_UI_STRING = "EGBOverview"
local EGB_UI = EGBOverview

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



function EasyGearBanker:UICycleLeft()
  easyDebug("UI cycle left called!")
end

function EasyGearBanker:UICycleRight()
  easyDebug("UI cycle right called!")
end

function EasyGearBanker:UISetGearNameLabel(gearSetNumber)
  local gearSetName = GearSet.getGearSetName(gearSetNumber)
  easyDebug("Setting gear name label to: " .. gearSetName)
  local labelControl = EGBOverview:GetNamedChild(EGB_UI_STRING .. "_setlabel")
  labelControl:setText(gearSetName)
end

function EasyGearBanker:UISetDisplaySet(gearSetNumber)
  EasyGearBanker:UISetGearNameLabel(gearSetNumber)
end

function EasyGearBanker:ShowUI()
  -- Default UI display is set 1
  EasyGearBanker.displayingSet = 1
  EasyGearBanker:UISetDisplaySet(EasyGearBanker.displayingSet)
  EGBOverview:SetHidden(false)
end

function EasyGearBanker:HideUI()
  EGBOverview:SetHidden(true)
end

EVENT_MANAGER:RegisterForEvent(EasyGearBanker.name, EVENT_ADD_ON_LOADED, EasyGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!

SLASH_COMMANDS["/depositgear"] = Banking.depositGear
SLASH_COMMANDS["/withdrawgear"] = Banking.withdrawGear

SLASH_COMMANDS["/egboverview"] = EasyGearBanker.ShowUI
-------------------------------------------------------------------------------