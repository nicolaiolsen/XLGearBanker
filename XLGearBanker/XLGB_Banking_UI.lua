XLGB_Banking_UI = {}

local libShifterBox = LibShifterBox

function XLGB_Banking_UI:XLGB_Banking_Control_OnMoveStop()
    XLGearBanker.savedVariables.bank_ui_left = XLGB_Window_Control:GetLeft()
    XLGearBanker.savedVariables.bank_ui_top = XLGB_Window_Control:GetTop()
  end

  function XLGB_Banking_UI:RestorePosition()
    local left = XLGearBanker.savedVariables.bank_ui_left
    local top = XLGearBanker.savedVariables.bank_ui_top

    XLGB_Window_Control:ClearAnchors()
    XLGB_Window_Control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  end

function XLGB_Banking_UI:InitializeShifterBoxEntries(shifterBox)
    for i = 1, XLGB_GearSet:GetNumberOfGearSets() do
        local gearSet = XLGB_GearSet:GetGearSet(i)
        shifterBox:AddEntryToLeftList("Set_" .. i, gearSet.name, true)
    end
end

function XLGB_Banking_UI:InitializeShifterBox()
    local parentControl = XLGB_Banking_Control
    local customSettings = {
        showMoveAllButtons = true,  -- the >> and << buttons to move all entries can be hidden if set to false
        dragDropEnabled = true,     -- entries can be moved between lsit with drag-and-drop
        sortEnabled = true,         -- sorting of the entries can be disabled
        sortBy = "value",           -- sort the list by value or key (allowed are: "value" or "key")

        leftList = {                -- list-specific settings that apply to the LEFT list
        title = "Unmarked",             -- the title/header of the list
        rowHeight = 32,                 -- the height of an individual row/entry
            fontSize = 18,              -- size of the font
        },

        rightList = {               -- list-specific settings that apply to the RIGHT list
            title = "Marked",           -- the title/header of the list
            rowHeight = 32,             -- the height of an individual row/entry
            fontSize = 18,              -- size of the font
        } 
    }
    local shifterBox = libShifterBox.Create(
        "XL Gear Banker", 
        "XLGB_Banking_Control_ShiftBox", 
        parentControl, 
        customSettings)
    shifterBox:SetAnchor(TOPLEFT, parentControl:GetNamedChild("_Title"), TOPLEFT, 0, -10)
    shifterBox:SetAnchor(BOTTOMRIGHT, parentControl, BOTTOMRIGHT, 0, 10)
    XLGB_Banking_UI:InitializeShifterBoxEntries(shifterBox)
end

function XLGB_Banking_UI:Initialize()
    XLGB_Banking_UI:InitializeShifterBox()
end