GearSet = {}

function GearSet:Initialize()
  self.debug = true
  XLGearBanker.savedVariables.gearSetList = {{1}, {1, 2}, {1, 2, 3}}
  XLGearBanker.savedVariables.gearSetNames = {"Set 1", "Set 2", "Set 3"}

end

function GearSet.getGearSet(numberString)
  local number = tonumber(numberString)
  return XLGearBanker.savedVariables.gearSetList[number]
end

function GearSet.getAmountOfGearSets()
  return #XLGearBanker.savedVariables.gearSetList
end

function GearSet.getGearSetNames()
  return XLGearBanker.savedVariables.gearSetNames
end

function GearSet.getGearSetName(gearSetNumber)
  return GearSet.getGearSetNames()[gearSetNumber]
end

function GearSet.addItemToGearSet(itemLink, gearSetNumber)
  local gearSetName = GearSet.getGearSetNames()[gearSetNumber]
  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber], itemLink)
  d("Added item " .. itemLink .. " to " .. gearSetName)
end