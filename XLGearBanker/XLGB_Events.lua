XLGB_Events = {}

function XLGB_Events:OnGearSetRemove(gearSet)
  XLGB_Banking:UpdateStorageOnGearSetRemove(gearSet)
end

function XLGB_Events:OnGearSetItemAdd(gearSetBefore, gearSetAfter)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateScrollList()
end

function XLGB_Events:OnGearSetNameUpdate(gearSetBefore, gearSetAfter)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
end

function XLGB_Events:OnGearSetItemRemove(gearSetBefore, gearSetAfter)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSetBefore, gearSetAfter)
end

