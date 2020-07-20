XLGB_Events = {}

function XLGB_Events:OnGearSetItemAdd(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_Events:OnGearSetItemRemove(gearSetBefore, gearSetAfter)
  XLGB_UI:UpdateSetScrollList()
end

function XLGB_Events:OnGearSetRemove(gearSetName)
  XLGB_Page:OnRemoveSet(gearSetName)
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

function XLGB_Events:OnWithdrawPageStart(pageName)
  XLGB_UI:OnWithdrawPageStart(pageName)
end

function XLGB_Events:OnWithdrawPageStop()
  XLGB_UI:OnWithdrawPageStop()
end

function XLGB_Events:OnDepositPageStart(pageName)
end

function XLGB_Events:OnDepositPageStop()
end

