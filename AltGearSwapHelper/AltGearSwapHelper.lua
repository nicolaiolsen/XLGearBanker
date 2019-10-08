-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
AltGearSwapHelper = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
AltGearSwapHelper.name = "AltGearSwapHelper"
 
-- Next we create a function that will initialize our addon
function AltGearSwapHelper:Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function AltGearSwapHelper.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == AltGearSwapHelper.name then
    AltGearSwapHelper:Initialize()
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(AltGearSwapHelper.name, EVENT_ADD_ON_LOADED, AltGearSwapHelper.OnAddOnLoaded)