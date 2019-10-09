GearSet = {}

function GearSet:Initialize()
  self.debug = true
  self.gearSetList = {{1}, {2, 2}, {3, 3, 3}}
  self.numberOfGearSets = 1
end

function GearSet.getGearSet(numberString)
  local number = tonumber(numberString)
  return GearSet.gearSetList[number]
end