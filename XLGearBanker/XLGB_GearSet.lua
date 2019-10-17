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
    d("[XLGB_ERROR] GearSetNumber is invalid. Got:", gearSetNumber)
    return false
  else
    return true
  end
end

-- credit: https://gist.github.com/tylerneylon/81333721109155b2d244
--
local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
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

local function isNameUnique(name)
  local totalSets = XLGB_GearSet:GetNumberOfGearSets()
  local isUnique = true
  for i = 1, totalSets do
    local gearSet = XLGB_GearSet:GetGearSet(i)
    if (gearSet.name == name) then
      isUnique = false
    end
  end
  return isUnique
end

function XLGB_GearSet:CreateNewGearSet(gearSetName)
  if (not isNameUnique(gearSetName)) then
    d("[XLGB_ERROR] A set named ".. gearSetName .." does already exist! Set names should be unique.")
    return
  end
  local gearSet = {}
  gearSet.name = "" .. gearSetName
  gearSet.items = {}
  table.insert(XLGearBanker.savedVariables.gearSetList, gearSet)
  d("[XLGB] Created new set: " .. gearSetName)
end

function XLGB_GearSet:EditGearSetName(gearSetName, gearSetNumber)
  if (not isNameUnique(gearSetName)) then
    d("[XLGB_ERROR] A set named ".. gearSetName .." does already exist! Set names should be unique.")
    return
  end
  XLGearBanker.savedVariables.gearSetList[gearSetNumber].name = "" .. gearSetName
end

function XLGB_GearSet:RemoveGearSet(gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  XLGB_Events:OnGearSetRemove(gearSet)
  table.remove(XLGearBanker.savedVariables.gearSetList, gearSetNumber)
  XLGB_Events:OnGearSetRemoved()
  d("[XLGB] Removed set: " .. gearSet.name)
end

local function createItemData(itemLink, itemID)
  local itemData = {}
  itemData.link = itemLink
  itemData.name = GetItemLinkName(itemLink)
  itemData.quality = GetItemLinkQuality(itemLink)
  itemData.ID = itemID
  return itemData
end

function XLGB_GearSet:AddItemToGearSet(itemLink, itemID, gearSetNumber)
  local itemData = createItemData(itemLink, itemID)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)

  table.insert(XLGearBanker.savedVariables.gearSetList[gearSetNumber].items, itemData)

  XLGB_Events:OnGearSetItemAdd(gearSet, XLGearBanker.savedVariables.gearSetList[gearSetNumber])
  d("[XLGB] Added item " .. itemLink .. " to " .. gearSet.name)
end

function XLGB_GearSet:RemoveItemFromGearSet(itemLink, itemID, gearSetNumber)
  local gearSet = copy(XLGB_GearSet:GetGearSet(gearSetNumber))
  local gearSetName = gearSet.name

  for i, item in pairs(gearSet.items) do
    if item.ID == itemID then
      table.remove(XLGearBanker.savedVariables.gearSetList[gearSetNumber].items, i)
      XLGB_Events:OnGearSetItemRemove(gearSet, XLGearBanker.savedVariables.gearSetList[gearSetNumber])
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
      or item_index = ITEM_NOT_IN_SET if the item doesn't exist in the gearSet.
]]--
function XLGB_GearSet:GetItemIndexInGearSet(itemID, gearSetNumber)
  local gearSet = XLGB_GearSet:GetGearSet(gearSetNumber)
  local itemIndex = XLGB.ITEM_NOT_IN_SET
  for i, item in pairs(gearSet.items) do
    if (item.ID == itemID) then
      itemIndex = i
    end
  end
  return itemIndex
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



