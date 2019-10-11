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
    easyDebug("XLGB Error: GearSetNumber is invalid.")
    return false
  else
    return true
  end
end

function XLGB_GearSet:ValidGearSetName(gearSetName)
  if gearSetName == nil
  or gearSetName == "" then 
    easyDebug("XLGB Error: Enter a name for the set.")
    return false
  else 
    return true
  end
end

function XLGB_GearSet:GetGearSet(gearSetNumber)  
  return XLGearBanker.savedVariables.gearSetList[gearSetNumber]
end

function XLGB_GearSet:GetNumberOfGearSets()
  return #XLGearBanker.savedVariables.gearSetList
end

function XLGB_GearSet:CreateNewGearSet(gearSetName)
  local gearSet = {}
  gearSet.name = "" .. gearSetName
  gearSet.items = {}
  table.insert(XLGearBanker.savedVariables.gearSetList, gearSet)
  d("XLGB: Created new set: " .. gearSetName)
end

function XLGB_GearSet:EditGearSetName(gearSetName, gearSetNumber)
  XLGearBanker.savedVariables.gearSetList[gearSetNumber].name = "" .. gearSetName
end

function XLGB_GearSet:RemoveGearSet(gearSetNumber)
  gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name
  table.remove(XLGearBanker.savedVariables.gearSetList, gearSetNumber)
  d("XLGB: Removed set: " .. gearSetName)
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

  local gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name
  d("XLGB: Added item " .. itemLink .. " to " .. gearSetName)
end

function XLGB_GearSet:RemoveItemFromGearSet(itemLink, gearSetNumber)
  local gearSet = XLGB_GearSet:getGearSet(gearSetNumber)
  local gearSetName = gearSet.name

  for i, item in pairs(gearSet.items) do
    if item.itemLink and item.itemLink == itemLink then
      table.remove(XLGearBanker.savedVariables.gearSetList[gearSetNumber], i)
      break
    end
  end

  d("XLGB: Removed item " .. itemLink .. " from " .. gearSetName)
end


--[[
  function XLGB_GearSet:GearSetContainsItem(itemLink, gearSetNumber)
  Input: 
    itemLink = The itemLink of the item you wish to check exists in the gearSet.
    gearSetNumber = The number index of the gearSet you wish to check
  Output:
    (item_index, gearSetNumber) = Returns item_index that indicates where the item is located
      or item_index = -1 if the item doesn't exist in the gearSet.
]]--
function XLGB_GearSet:GearSetContainsItem(itemLink, gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  local item_index = -1

  for i, item in pairs(gearSet.items) do
    if item.link == itemLink then
      item_index = i
    end
  end

  return item_index
end 

function XLGB_GearSet:PrintGearSet(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  d("Printing: " .. gearSet.name)

  for i, item in pairs(gearSet.items) do 
    d("Item " .. i .. " = " .. item.link)
  end

  d("Done!")
end



