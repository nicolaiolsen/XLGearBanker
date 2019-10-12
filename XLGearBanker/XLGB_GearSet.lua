XLGB_GearSet = {}

local XLGB = XLGB_Constants

function XLGB_GearSet:Initialize()
  if XLGearBanker.savedVariables.gearSetList == nil then
    XLGearBanker.savedVariables.gearSetList = {}
  end

end

function XLGB_GearSet:ValidGearSetNumber(gearSetNumber, totalGearSets)
  if gearSetNumber == nil
  or gearSetNumber == ""
  or gearSetNumber > totalGearSets
  or gearSetNumber < 1 then
    d("[XLGB_ERROR] GearSetNumber is invalid.")
    return false
  else
    return true
  end
end

function XLGB_GearSet:ValidGearSetName(gearSetName)
  if gearSetName == nil
  or gearSetName == "" then 
    d("[XLGB_ERROR] Enter a name for the set.")
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
  gearSet.assignedBag = XLGB_Banking.NO_BAG
  table.insert(XLGearBanker.savedVariables.gearSetList, gearSet)
  d("[XLGB] Created new set: " .. gearSetName)
end

function XLGB_GearSet:EditGearSetName(gearSetName, gearSetNumber)
  XLGearBanker.savedVariables.gearSetList[gearSetNumber].name = "" .. gearSetName
end

function XLGB_GearSet:RemoveGearSet(gearSetNumber)
  gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name
  table.remove(XLGearBanker.savedVariables.gearSetList, gearSetNumber)
  d("[XLGB] Removed set: " .. gearSetName)
end

local function createItemData(itemLink)
  local itemData = {}
  itemData.link = itemLink
  itemData.name = GetItemLinkName(itemLink)
  itemData.quality = GetItemLinkQuality(itemLink)
  return itemData
end

function XLGB_GearSet:AddItemToGearSet(itemLink, gearSetNumber)
  local itemData = createItemData(itemLink)

  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber].items, itemData)

  local gearSetName = XLGB_GearSet:GetGearSet(gearSetNumber).name
  d("[XLGB] Added item " .. itemLink .. " to " .. gearSetName)
end

function XLGB_GearSet:RemoveItemFromGearSet(itemLink, gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  local gearSetName = gearSet.name

  for i, item in pairs(gearSet.items) do
    if item.link == itemLink then
      table.remove(XLGearBanker.savedVariables.gearSetList[gearSetNumber].items, i)
      break
    end
  end

  d("[XLGB] Removed item " .. itemLink .. " from " .. gearSetName)
end


--[[
  function XLGB_GearSet:GetItemIndexInGearSet(itemLink, gearSetNumber)
  Input: 
    itemLink = The itemLink of the item you wish to find index for in the gearSet.
    gearSetNumber = The number index of the gearSet you wish to check
  Output:
    (item_index, gearSetNumber) = Returns item_index that indicates where the item is located
      or item_index = ITEM_NOT_IN_BAG if the item doesn't exist in the gearSet.
]]--
function XLGB_GearSet:GetItemIndexInGearSet(itemLink, gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  local itemIndex = XLGB.ITEM_NOT_IN_BAG
  for i, item in pairs(gearSet.items) do
    if item.link == itemLink then
      itemIndex = i
    end
  end
  return itemIndex
end

function XLGB_GearSet:AssignBagToStorage(gearSetNumber, bag)
  XLGearBanker.savedVariables.gearSetList[gearSetNumber].assignedBag = bag
end

function XLGB_GearSet:PrintGearSets()
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  for i = 1, totalGearSets do
    local gearSet = XLGB_GearSet:GetGearSet(i)
    d("Set " .. i .. " = " .. gearSet.name)
  end
  d("[XLGB] Total sets = " .. totalGearSets)
end

function XLGB_GearSet:PrintGearSetItems(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)

  d("Set \'" .. gearSet.name .. "\' contains the following items:")
  for _, item in pairs(gearSet.items) do 
    d(item.link)
  end
  d("[XLGB] Total items = " .. #gearSet.items)
end



