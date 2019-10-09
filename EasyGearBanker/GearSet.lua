GearSet = {}

function GearSet:Initialize()
  self.debug = true
  self.gearSets = {{0}, {1}}
end

function getGearSet(number)
  return Gearset.gearSets[number]
end 