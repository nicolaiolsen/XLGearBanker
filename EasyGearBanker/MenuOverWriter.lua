-- Namespace
MenuOverWriter = {}

local ADD_ITEM_TO_GEARSET = "EGB add"
--[[
  MenuOverWriter.lua

  It adds an extra entry to the dropdown menu when you right click an item that allows you to add that item to a gearset of choice.

  The following code is heavily inspired by TTC's TamrielTradeCenterPrice.lua
]]--
local function MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
  local gearSetNames = GearSet.getGearSetNames()
  local subEntries = {}
  for i = 1, GearSet.getAmountOfGearSets() do
    local subEntry = {
      label = gearSetNames[i],
      callback = 
        function()
          GearSet.addItemToGearSet(itemLink, i)
        end
    }
    table.insert(subEntries, subEntry)
  end
  AddCustomSubMenuItem(ADD_ITEM_TO_GEARSET, subEntries)
  ShowMenu(inventorySlot)
end

local function AddContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
  zo_callLater(
    function()
      MakeContextMenuEntry_AddItemToGearSet(itemLink, inventorySlot)
    end, 50)
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

function MenuOverWriter:Initialize()
  OverWriteInventoryShowContextMenuHandler()
end

