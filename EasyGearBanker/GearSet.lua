GearSet = {}

function GearSet:Initialize()
  self.debug = true
  self.gearSetList = {{0},{1}}
  self.numberOfGearSets = 1
end

function GearSet.getGearSet(number)
  return GearSet.gearSets[number]
end 