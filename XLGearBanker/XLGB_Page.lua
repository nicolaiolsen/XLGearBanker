XLGB_Page = {}
local sV

function XLGB_Page:GetNumberOfPages()
  return #sV.pages
end

local function sortPages()
  local function comparePages(pageA, pageB)
    return pageA.name < pageB.name
  end

  local preSortList = {}
  for i, page in pairs(sV.pages) do
      preSortList[i] = page.name
  end

  table.sort(sV.pages, comparePages)
  XLGB_Events:OnPageSort(preSortList)
end

function XLGB_Page:CreatePage()
  local x = "X"
  local pageName = "My " .. x .. "LGB Page"
  while XLGB_Page:GetPage(pageName) do
      x = x .. "X"
      pageName = "My " .. x .. "LGB Page"
  end
  local newPage = {
    name = pageName,
    sets = {}
  }
  table.insert(sV.pages, newPage)
  sortPages()
  return pageName
end

function XLGB_Page:GetPage(pageName)
  for _, page in pairs(sV.pages) do
      if page.name == pageName then
        return page
      end
  end
end

function XLGB_Page:GetIndexOfPage(pageName)
  for i, page in pairs(sV.pages) do
      if page.name == pageName then
        return i
      end
  end
end

function XLGB_Page:GetPageByIndex(index)
  return sV.pages[index]
end

function XLGB_Page:GetAllPages()
  return sV.pages
end

function XLGB_Page:RemovePage(name)
  for i, page in pairs(sV.pages) do
    if page.name == name then
      table.remove(sV.pages, i)
      return
    end
  end
end

function XLGB_Page:ClearPage(pageName)
  local page = XLGB_Page:GetPage(pageName)
  page.sets = {}
end

function XLGB_Page:SetPageName(oldName, newName)
  local page = XLGB_Page:GetPage(oldName)
  local isUnique = not XLGB_Page:GetPage(newName)
  if isUnique then
    page.name = newName
    sortPages()
    return true
  end
  return oldName == newName -- If they were the same don't change and return true
end

local function GetSetIndexInPage(setName, page)
  for i, set in pairs(page.sets) do
    if set.name == setName then
      return i
    end
  end
end

function XLGB_Page:AddSetToPage(setName, pageName)
  local page = XLGB_Page:GetPage(pageName)
  local isUnique = not GetSetIndexInPage(setName, page)
  if isUnique then
    table.insert(page.sets, setName)
    table.sort(page.sets)
  end
end

function XLGB_Page:RemoveSetFromPage(setName, pageName)
  local page = XLGB_Page:GetPage(pageName)
  local setIndex = GetSetIndexInPage(setName, page)
  table.remove(page.sets, setIndex)
end

function XLGB_Page:PageContainsSet(pageName, setName)
  local page = XLGB_Page:GetPage(pageName)
  for _, pageSetName in pairs(page.sets) do
    if setName == pageSetName then
      return true
    end
  end
  return false
end

function XLGB_Page:GetSetsInPage(pageName)
  local page = XLGB_Page:GetPage(pageName)
  return page.sets
end
-- function XLGB_Page:GetPageItems(pageName)
--   local page = XLGB_Page:GetPage(pageName)
--   local tempSet = {}
--   for _, set in pairs(page.sets) do
--   end
-- end
function XLGB_Page:DepositPage(pageName)
  local page = XLGB_Page:GetPage(pageName)
  for i, set in pairs(page.sets) do
    d("[XLGB] Depositing Page '" .. pageName .. "' [" .. tostring(i) .. "/" .. tostring(#page.sets) .. "] - " .. set)
    if not XLGB_Banking:DepositGearSet(XLGB_GearSet:FindGearSet(set)) then
      d("[XLGB] Page '" .. pageName .. "' deposit failed.")
      return false
    end
  end
  d("[XLGB] Page '" .. pageName .. "' deposited!")
  return true
end

function XLGB_Page:WithdrawPage(pageName)
  local page = XLGB_Page:GetPage(pageName)
  for i, set in ipairs(page.sets) do
    d("[XLGB] Withdrawing Page '" .. pageName .. "' [" .. tostring(i) .. "/" .. tostring(#page.sets) .. "] - " .. set)
    if not XLGB_Banking:WithdrawGearSet(XLGB_GearSet:FindGearSet(set)) then
      d("[XLGB] Page '" .. pageName .. "' withdraw failed.")
      return false
    end
  end
  d("[XLGB] Page '" .. pageName .. "' withdrawn!")
  return true
end

function XLGB_Page:OnRemoveSet(setName)
  for _, page in pairs(XLGB_Page:GetAllPages()) do
      XLGB_Page:RemoveSetFromPage(setName, page.name)
  end
end

local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function XLGB_Page:CopyPageSet(pageName)
  return copy(XLGB_Page:GetPage(pageName).sets)
end

function XLGB_Page:Initialize()
  sV = XLGearBanker.savedVariables
  sV.pages = sV.pages or {}
end