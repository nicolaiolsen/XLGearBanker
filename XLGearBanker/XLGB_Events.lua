XLGB_Events = {}

function XLGB_Events:OnGearSetItemAdd(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateScrollList()
end

function XLGB_Events:OnGearSetItemRemove(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateScrollList()
end

