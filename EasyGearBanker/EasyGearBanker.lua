-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
EasyGearBanker = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
EasyGearBanker.name = "EasyGearBanker"
 
-------------------------------------------------------------------------------
--Slash Commands! --

SLASH_COMMANDS["/depositgear"] = Banking.depositGear

SLASH_COMMANDS["/withdrawgear"] = Banking.withdrawGear

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