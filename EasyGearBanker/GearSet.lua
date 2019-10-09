GearSet = {}

function GearSet:Initialize()
  self.debug = true
  self.gearSetList = {{0},{1}}
  self.numberOfGearSets = 1
end

function Gearset.getGearSet(number)
  return Gearset.gearSets[number]
end 