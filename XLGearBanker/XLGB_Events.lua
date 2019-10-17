XLGB_Events = {}

function XLGB_Events:OnGearSetRemoved(gearSet)
  XLGB_Banking:UpdateStorageOnGearSetRemove(gearSet)
end

function XLGB_Events:OnGearSetItemAdd(gearSet)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSet)
end

function XLGB_Events:OnGearSetItemRemove(gearSet)
  XLGB_Banking:UpdateStorageOnGearSetItemAddRemove(gearSet)
end