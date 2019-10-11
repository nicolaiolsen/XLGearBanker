XLGB_GearSet = {}

function XLGB_GearSet:Initialize()
  self.debug = true
  XLGearBanker.savedVariables.gearSetList = {}
end

function XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets)
  if gearSetNumber == nil
    or gearSetNumber == ""
    or gearSetNumber > totalGearSets
    or gearSetNumber < 1 then
      d("XLGB Error: GearSetNumber is invalid.")
      return false
  else
    return true
  end
end

function XLGB_GearSet:ValidGearSetName(gearSetName)
  if gearSetName == nil
    or gearSetName == "" then 
      d("XLGB Error: Enter a name for the set.")
      return false
  else 
    return true
  end
end

function XLGB_GearSet:GetGearSet(gearSetNumberString)
  local gearSetNumber = tonumber(gearSetNumberString)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()

  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    return XLGearBanker.savedVariables.gearSetList[gearSetNumber]
  end
end

function XLGB_GearSet:GetNumberOfGearSets()
  return #XLGearBanker.savedVariables.gearSetList
end

function XLGB_GearSet:CreateNewGearSet(gearSetName)
  if XLGB_GearSet:ValidGearSetName(gearSetName) then
    local gearSet = {}
    gearSet.name = "" .. gearSetName
    gearSet.items = {}
    table.insert(XLGearBanker.savedVariables.gearSetList, gearSet)
  end
end

function XLGB_GearSet:EditGearSetName(gearSetName, gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetName(gearSetName) 
  and XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    XLGearBanker.savedVariables.gearSetList[gearSetNumber].name = "" .. gearSetName
  end
end

function XLGB_GearSet:RemoveGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    table.remove(XLGearBanker.savedVariables.gearSetList, gearSetNumber)
  end
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
  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber].items, itemData)

  local gearSetName = XLGB_GearSet:GetGearSetName(gearSetNumber)
  d("Added item " .. itemLink .. " to " .. gearSetName)

end

function XLGB_GearSet:RemoveItemFromGearSet(itemLink, gearSetNumber)
  local gearSet = XLGB_GearSet:getGearSet(gearSetNumber)
  local gearSetName = gearSet.name
  for i, item in gearSet.items do
    if item.itemLink and item.itemLink == itemLink then
      table.remove(XLGearBanker.savedVariables.gearSetList[gearSetNumber], i)
      break
    end
  end

  d("Removed item " .. itemLink .. " from " .. gearSetName)

end

function XLGB_GearSet:PrintGearSet(gearSetNumber)
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets) then
    local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
    d("Printing: " .. gearSet.name)
    for i, item in gearSet.items do 
      d("Item " .. i .. " = " .. item.link)
    end
    d("Done!")
  end
end



