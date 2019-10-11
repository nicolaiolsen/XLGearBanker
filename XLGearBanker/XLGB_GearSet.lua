XLGB_GearSet = {}

function XLGB_GearSet:Initialize()
  self.debug = true
  XLGearBanker.savedVariables.gearSetList = {{1}, {1, 2}, {1, 2, 3}}
  XLGearBanker.savedVariables.gearSetNames = {"Set 1", "Set 2", "Set 3"}

end

function XLGB_GearSet.getGearSet(numberString)
  local number = tonumber(numberString)
  return XLGearBanker.savedVariables.gearSetList[number]
end

function XLGB_GearSet.getAmountOfGearSets()
  return #XLGearBanker.savedVariables.gearSetList
end

function XLGB_GearSet.getGearSetNames()
  return XLGearBanker.savedVariables.gearSetNames
end

function XLGB_GearSet.getGearSetName(gearSetNumber)
  return XLGB_GearSet.getGearSetNames()[gearSetNumber]
end

function XLGB_GearSet.addItemToGearSet(itemLink, gearSetNumber)
  local gearSetName = XLGB_GearSet.getGearSetNames()[gearSetNumber]
  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber], itemLink)
  d("Added item " .. itemLink .. " to " .. gearSetName)
end