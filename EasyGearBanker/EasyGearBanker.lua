-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
EasyGearBanker = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
EasyGearBanker.name = "EasyGearBanker"
 
-- Next we create a function that will initialize our addon
function EasyGearBanker:Initialize()
  self.bankOpen = IsBankOpen()

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.OnBankOpenEvent)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.OnBankCloseEvent)
  
  self.savedVariables = ZO_SavedVars:NewAccountWide("EasyGearBankerSavedVariables", 1, nil, {})

  self:RestorePosition()
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function EasyGearBanker.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == EasyGearBanker.name then
      EasyGearBanker:Initialize()
    end
end


function EasyGearBanker.OnBankOpenEvent(event, bankBag)
  -- The ~= operator is "not equal to" in Lua.
  if not EasyGearBanker.bankOpen then
    -- The player's state has changed. Update the stored state...
    EasyGearBanker.bankOpen = isBankOpen()
    d("Bank open!")
    -- ...and then announce the change.
  end
end

function EasyGearBanker.OnBankCloseEvent(event)
  d("Bank closed")
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