--[[
  XLGB_MenuOverWriter.lua

  It adds an extra entry to the dropdown menu when you right click an item that allows you to add that item to a gearset of choice.

  The following code is heavily inspired by TTC's TamrielTradeCenterPrice.lua
]]--

-- Namespace
XLGB_MenuOverWriter = {}

-- Constants
XLGB = XLGB_Constants

-- Functions
local function MakeContextMenuEntry_AddItemToGearSet(itemLink, itemID)
  local subEntries = {}
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if totalGearSets ~= 0 then
    for i = 1, totalGearSets do
      local gearSetName = XLGB_GearSet:GetGearSet(i).name
      local subEntry = {
        label = gearSetName,
        callback =
          function()
            if (XLGB_GearSet:GetItemIndexInGearSet(itemID, i) == XLGB.ITEM_NOT_IN_SET) then
              XLGB_GearSet:AddItemToGearSet(itemLink, itemID, i)
            else
              d("[XLGB] Item " .. itemLink .. " is already in " .. gearSetName)
            end
          end
      }
      table.insert(subEntries, subEntry)
    end
    AddCustomSubMenuItem(XLGB.ADD_ITEM_TO_GEARSET, subEntries)
  end
end

local function MakeContextMenuEntry_RemoveItemFromGearSet(itemLink, itemID)
  local subEntries = {}
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if totalGearSets ~= 0 then 
    for i = 1, totalGearSets do
      if (XLGB_GearSet:GetItemIndexInGearSet(itemID, i) ~= XLGB.ITEM_NOT_IN_SET) then
        local gearSetName = XLGB_GearSet:GetGearSet(i).name
        local subEntry = {
          label = gearSetName,
          callback = 
            function()
              XLGB_GearSet:RemoveItemFromGearSet(itemLink, itemID, i)
            end
        }
        table.insert(subEntries, subEntry)
      end
    end
    if (#subEntries ~= 0) then 
      AddCustomSubMenuItem(XLGB.REMOVE_ITEM_FROM_GEARSET, subEntries)
    end
  end
end

local function AddContextMenuEntries(itemLink, itemID, inventorySlot)
  zo_callLater(
    function()
      MakeContextMenuEntry_AddItemToGearSet(itemLink, itemID)
      MakeContextMenuEntry_RemoveItemFromGearSet(itemLink, itemID)
      ShowMenu(inventorySlot)
    end, 10)
end


local function OverWriteInventoryShowContextMenuHandler()
  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', 
      function(inventorySlot)
        local slotType = ZO_InventorySlot_GetType(inventorySlot)
        local itemLink = nil
        local itemID = nil
        -- Inventory slot should either be the player bag, equipment slots, or the bank.
        if slotType == SLOT_TYPE_ITEM
        or slotType == SLOT_TYPE_EQUIPMENT
        or slotType == SLOT_TYPE_BANK_ITEM then
          bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
          itemLink = GetItemLink(bag, index)
          itemType = GetItemLinkItemType(itemLink)
          itemID = Id64ToString(GetItemUniqueID(bag, index))

          -- Item should be armor or weapon.
          if itemType ~= ITEMTYPE_ARMOR
          and itemType ~= ITEMTYPE_WEAPON then
            itemLink = nil
            itemID = nil
          end
        end
        if (itemLink ~= nil) and (itemID ~= nil) then
          AddContextMenuEntries(itemLink, itemID, inventorySlot)
        end
      end
    )
end

function XLGB_MenuOverWriter:Initialize()
  OverWriteInventoryShowContextMenuHandler()
end

