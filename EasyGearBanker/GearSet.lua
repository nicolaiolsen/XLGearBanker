GearSet = {}

function GearSet:Initialize()
  self.debug = true
  EasyGearBanker.savedVariables.gearSetList = {{1}, {1, 2}, {1, 2, 3}}
  EasyGearBanker.savedVariables.gearSetNames = {"Set 1", "Set 2", "Set 3"}

end

function GearSet.getGearSet(numberString)
  local number = tonumber(numberString)
  return EasyGearBanker.savedVariables.gearSetList[number]
end

function GearSet.getAmountOfGearSets()
  return #EasyGearBanker.savedVariables.gearSetList
end

function GearSet.getGearSetNames()
  return EasyGearBanker.savedVariables.gearSetNames
end

function GearSet.addItemToGearSet(itemLink, gearSetNumber)
  easyDebug("Added item to itemset")
end