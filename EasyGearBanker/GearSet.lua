GearSet = {}

function GearSet:Initialize()
  self.debug = true
  self.gearSetList = {{1},{2}}
  self.numberOfGearSets = 1
end

function GearSet.getGearSet(number)
  return GearSet.gearSets[number]
end 