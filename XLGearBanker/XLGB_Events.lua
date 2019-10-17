XLGB_Events = {}

function XLGB_Events:OnGearSetRemoved(gearSet)
  XLGB_Banking:UpdateStorageOnGearSetRemoved(gearSet)
end

function XLGB_Events:OnGearSetItemAdd(gearSetBefore, gearSetAfter)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
end

function XLGB_Events:OnGearSetItemRemove(gearSetBefore, gearSetAfter)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
end
