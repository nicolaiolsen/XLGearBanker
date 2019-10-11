--[[
  XLGB_MenuOverWriter.lua

  It adds an extra entry to the dropdown menu when you right click an item that allows you to add that item to a gearset of choice.

  The following code is heavily inspired by TTC's TamrielTradeCenterPrice.lua
]]--

-- Namespace
XLGB_MenuOverWriter = {}

-- Constants
local ADD_ITEM_TO_GEARSET = "XLGB addItem"
local REMOVE_ITEM_FROM_GEARSET = "XLGB removeItem"

-- Functions
local function MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
  local subEntries = {}
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if totalGearSets ~= 0 then
    for i = 1, totalGearSets do
      local gearSetName = XLGB_GearSet:GetGearSet(i).name
      local subEntry = {
        label = gearSetName,
        callback = 
          function()
            if XLGB_GearSet:GearSetContainsItem(itemLink, i) == -1 then
              XLGB_GearSet:AddItemToGearSet(itemLink, i)
            else
              d("XLGB: Item " .. itemLink .. " is already in " .. gearSetName)
            end
          end
      }
      table.insert(subEntries, subEntry)
    end
    AddCustomSubMenuItem(ADD_ITEM_TO_GEARSET, subEntries)
  end
end

local function MakeContextMenuEntry_RemoveItemFromGearSet(itemLink, inventorySlot)
  local subEntries = {}
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if not (totalGearSets == 0) then
    for i = 1, totalGearSets do
      local gearSetName = XLGB_GearSet:GetGearSet(i).name
      local subEntry = {
        label = gearSetName,
        callback = 
          function()
            if XLGB_GearSet:GearSetContainsItem(itemLink, i) ~= -1 then
              XLGB_GearSet:RemoveItemFromGearSet(itemLink, i)
            else
              d("XLGB: Item " .. itemLink .. " is not in " .. gearSetName)
            end
          end
      }
      table.insert(subEntries, subEntry)
    end
    AddCustomSubMenuItem(REMOVE_ITEM_FROM_GEARSET, subEntries)
  end
end

local function AddContextMenuEntries(itemLink, inventorySlot)
  zo_callLater(
    function()
      MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
      MakeContextMenuEntry_RemoveItemFromGearSet(itemLink, inventorySlot)
      ShowMenu(inventorySlot)
    end, 10)
end


local function OverWriteInventoryShowContextMenuHandler()
  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', 
      function(inventorySlot)
        local slotType = ZO_InventorySlot_GetType(inventorySlot)
        local link = nil
        -- Inventory slot should either be the player bag, equipment slots, or the bank.
        if slotType == SLOT_TYPE_ITEM 
        or slotType == SLOT_TYPE_EQUIPMENT 
        or slotType == SLOT_TYPE_BANK_ITEM then
          local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
          link = GetItemLink(bag, index)
          itemType = GetItemLinkItemType(link)

          -- Item should be armor or weapon.
          if itemType ~= ITEMTYPE_ARMOR
          and itemType ~= ITEMTYPE_WEAPON then
            link = nil
          end
        end
        if link ~= nil then
          AddContextMenuEntries(link, inventorySlot)
        end
      end
    )
end

function XLGB_MenuOverWriter:Initialize()
  OverWriteInventoryShowContextMenuHandler()
end

