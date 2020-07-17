XLGB_Events = {}

function XLGB_Events:OnGearSetItemAdd(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_Events:OnGearSetItemRemove(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_Events:OnGearSetRemove(gearSet)
  XLGB_Page:OnRemoveSet(gearSet.name)
end

function XLGB_Events:OnGearSetSort(preSortList)
  XLGB_UI:OnGearSetSort(preSortList)
end

function XLGB_Events:OnGearSetNameChange(oldName, newName)
  XLGB_Page:OnGearSetNameChange(oldName, newName)
end

function XLGB_Events:OnPageSort(preSortList)
  XLGB_UI:OnPageSort(preSortList)
end

