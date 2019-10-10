-- Namespace
EasyGearBanker = {}

EasyGearBanker.name = "EasyGearBanker"
local EGB_Overview = "EGBOverview"

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

  local nextSet = EasyGearBanker.displayingSet - 1
  local totalSets = GearSet.getAmountOfGearSets()

  if nextSet <= 0 then
    nextSet = totalSets
  end

  EasyGearBanker.displayingSet = nextSet
  EasyGearBanker:UISetDisplaySet(nextSet)
end

function EasyGearBanker:UICycleRight()
  easyDebug("UI cycle right called!")

  local nextSet = EasyGearBanker.displayingSet + 1
  local totalSets = GearSet.getAmountOfGearSets()

  if nextSet >= totalSets then
    nextSet = 1
  end

  EasyGearBanker.displayingSet = nextSet
  EasyGearBanker:UISetDisplaySet(nextSet)
end

function EasyGearBanker:UISetGearNameLabel(gearSetNumber)
  local gearSetName = GearSet.getGearSetName(gearSetNumber)
  easyDebug("Setting gear name label to: " .. gearSetName)
  local labelControl = EGBOverview:GetNamedChild("EGBOverview_setlabel")
  easyDebug("Labelcontrol: ", labelControl)
  if labelControl then
    labelControl:setText(gearSetName)
  end
end

function EasyGearBanker:UISetDisplaySet(gearSetNumber)
  EasyGearBanker:UISetGearNameLabel(gearSetNumber)
end

function EasyGearBanker:ShowUI()
  EGBOverview:SetHidden(false)
end

function EasyGearBanker:HideUI()
  EGBOverview:SetHidden(true)
end

function EasyGearBanker:Initialize()
  self.debug = true
  self.savedVariables = ZO_SavedVars:NewAccountWide("EasyGearBankerSavedVariables", 1, nil, {})
  self:RestorePosition()
  self.displayingSet = 1
  self:UISetDisplaySet(self.displayingSet)
end

EVENT_MANAGER:RegisterForEvent(EasyGearBanker.name, EVENT_ADD_ON_LOADED, EasyGearBanker.OnAddOnLoaded)

-------------------------------------------------------------------------------
                              --Slash Commands! --
-- Note: Slash commands should not contain capital letters!

SLASH_COMMANDS["/depositgear"] = Banking.depositGear
SLASH_COMMANDS["/withdrawgear"] = Banking.withdrawGear

SLASH_COMMANDS["/egboverview"] = EasyGearBanker.ShowUI
-------------------------------------------------------------------------------