XLGB_GearSet = {}

function XLGB_GearSet:Initialize()
  self.debug = true
  XLGearBanker.savedVariables.gearSetList = {}
  XLGearBanker.savedVariables.gearSetNames = {}

end



function XLGB_GearSet:GetGearSet(numberString)
  local number = tonumber(numberString)
  return XLGearBanker.savedVariables.gearSetList[number]
end

function XLGB_GearSet:GetAmountOfGearSets()
  return #XLGearBanker.savedVariables.gearSetList
end

function XLGB_GearSet:GetGearSetNames()
  return XLGearBanker.savedVariables.gearSetNames
end

function XLGB_GearSet:GetGearSetName(gearSetNumber)
  return XLGB_GearSet:GetGearSetNames()[gearSetNumber]
end

local function createItemData(itemLink)
  if itemLink then 
    local itemData = {}
    itemData.link = itemLink
    itemData.name = GetItemLinkName(itemLink)
    itemData.quality = GetItemLinkQuality(itemLink)
  end
end

function XLGB_GearSet:AddItemToGearSet(itemLink, gearSetNumber)

  local itemData = createItemData(itemLink)
  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber], itemData)

  local gearSetName = XLGB_GearSet:GetGearSetNames()[gearSetNumber]
  d("Added item " .. itemLink .. " to " .. gearSetName)

end

function XLGB_GearSet:RemoveItemFromGearSet(itemLink, gearSetNumber)

  local gearSet = XLGB_GearSet:getGearSet(gearSetNumber)
  for i, item in gearSet do
    if item.itemLink and item.itemLink == itemLink then
      table.remove(XLGearBanker.savedVariables.gearSetList[gearSetNumber], i)
      break
    end
  end

  local gearSetName = XLGB_GearSet:GetGearSetNames()[gearSetNumber]
  d("Removed item " .. itemLink .. " from " .. gearSetName)

end

function XLGB_GearSet:PrintGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetAmountOfGearSets()
  if gearSetNumber == nil
    or gearSetNumber == "" 
    or gearSetNumber > totalGearSets 
    or gearSetNumber < 1 then
      d("Invalid argument.")
  else
    local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
    local gearSetName = XLGB_GearSet:GetGearSetNames()[gearSetNumber]

    d("Printing: " .. gearSetName)
    for i, item in gearSet do 
      d("Item " .. i .. " = " .. item.link)
    end
    d("Done!")
  end
end



