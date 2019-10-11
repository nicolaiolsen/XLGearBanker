--[[
  XLGB_MenuOverWriter.lua

  It adds an extra entry to the dropdown menu when you right click an item that allows you to add that item to a gearset of choice.

  The following code is heavily inspired by TTC's TamrielTradeCenterPrice.lua
]]--

-- Namespace
XLGB_MenuOverWriter = {}

-- Constants
local ADD_ITEM_TO_GEARSET = "XLGB add"
local REMOVE_ITEM_FROM_GEARSET = "XLGB remove"

-- Functions
local function MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
  local subEntries = {}
  local totalGearSets = XLGB_GearSet:GetNumberOfGearSets()
  if not (totalGearSets == 0) then
    for i = 1, totalGearSets do
      local subEntry = {
        label = XLGB_GearSet:GetGearSetName(i),
        callback = 
          function()
            XLGB_GearSet:AddItemToGearSet(itemLink, i)
          end
      }
      table.insert(subEntries, subEntry)
    end
    AddCustomSubMenuItem(ADD_ITEM_TO_GEARSET, subEntries)
    ShowMenu(inventorySlot)
  end
end

local function AddContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
  zo_callLater(
    function()
      MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
    end, 10)
end

local function OverWriteInventoryShowContextMenuHandler()
  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', 
      function(inventorySlot)
        local slotType = ZO_InventorySlot_GetType(inventorySlot)
        local link = nil
        if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM then
          local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
          link = GetItemLink(bag, index)
        end
        if link ~= nil then
          AddContextMenuEntry_AddItemToGearSet(link, inventorySlot)
        end
      end
    )
end

function XLGB_MenuOverWriter:Initialize()
  OverWriteInventoryShowContextMenuHandler()
end

