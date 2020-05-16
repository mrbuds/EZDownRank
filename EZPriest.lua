local GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown, GetTime = GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown, GetTime
local LGF = LibStub("LibGetFrame-1.0")
local GetUnitFrame = LGF.GetUnitFrame
if select(2, UnitClass("player")) ~= "PRIEST" then return end
local debug = false

local print_debug = function(...)
    if debug then
        print(...)
    end
end

local greater = {
    { name = "H1", cost = 132, spellId = 2054, baseCastTime = 3 },
    { name = "H2", cost = 174, spellId = 2055, baseCastTime = 3 },
    { name = "H3", cost = 217, spellId = 6063, baseCastTime = 3 },
    { name = "H4", cost = 259, spellId = 6064, baseCastTime = 3 },
    { name = "GH1", cost = 314, spellId = 2060, baseCastTime = 3 },
    { name = "GH2", cost = 387, spellId = 10963, baseCastTime = 3 },
    { name = "GH3", cost = 463, spellId = 10964, baseCastTime = 3 },
    { name = "GH4", cost = 557, spellId = 10965, baseCastTime = 3 },
}

local flash = {
    { name = "F1", cost = 125, spellId = 2061, baseCastTime = 1.5 },
    { name = "F2", cost = 155, spellId = 9472, baseCastTime = 1.5 },
    { name = "F3", cost = 185, spellId = 9473, baseCastTime = 1.5 },
    { name = "F4", cost = 215, spellId = 9474, baseCastTime = 1.5 },
    { name = "F5", cost = 265, spellId = 10915, baseCastTime = 1.5 },
    { name = "F6", cost = 315, spellId = 10916, baseCastTime = 1.5 },
    { name = "F7", cost = 380, spellId = 10917, baseCastTime = 1.5 },
}

local hiddenTooltip
local function GetHiddenTooltip()
  if not hiddenTooltip then
    hiddenTooltip = CreateFrame("GameTooltip", "EZPriestTooltip", nil, "GameTooltipTemplate")
    hiddenTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    hiddenTooltip:AddFontStrings(
      hiddenTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
      hiddenTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  return hiddenTooltip
end

local function getMinMax(spellId)
    local tooltip = GetHiddenTooltip()
    tooltip:ClearLines()
    tooltip:SetSpellByID(spellId)
    local tooltipTextLine = select(9, tooltip:GetRegions())
    local tooltipText = tooltipTextLine and tooltipTextLine:GetObjectType() == "FontString" and tooltipTextLine:GetText() or "";
    return tooltipText:match("(%d+) .+ (%d+)")
end

local buttons = {}
local shift = false
local healingPower, mana

local maxCost = 0
for _, spell in pairs(greater) do
    if spell.cost > maxCost then maxCost = spell.cost end
end
for _, spell in pairs(flash) do
    if spell.cost > maxCost then maxCost = spell.cost end
end


local f = CreateFrame("Frame")

local IterateGroupMembers = function(reversed, forceParty)
    local unit = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
      local ret
      if i == 0 and unit == 'party' then
        ret = 'player'
      elseif i <= numGroupMembers and i > 0 then
        ret = unit .. i
      end
      i = i + (reversed and -1 or 1)
      return ret
    end
end

local groupUnit = { ["player"] = true }
for i = 1, 4 do
    groupUnit["party"..i] = true
end
for i = 1, 40 do
    groupUnit["raid"..i] = true
end

local last
local function updateStats()
    print_debug("updateStats")
    local now = GetTime()
    if now ~= last then
        healingPower = GetSpellBonusHealing()
        mana = UnitPower("player", 0)
        last = now
    end
end

local buttonHide = function(button)
    print_debug("buttonHide")
    button:Hide()
    button:SetAttribute("unit", nil)
    button:SetAttribute("type1", nil)
    button:SetAttribute("spell1", nil)
    button:SetAttribute("shift-type1", nil)
    button:SetAttribute("shift-spell1", nil)
end

local alpha = 0.3

local updateUnitColor = function(unit)
    print_debug("updateUnitColor", unit)
    local activeSpells = shift and greater or flash
    local deficit = UnitHealthMax(unit) - UnitHealth(unit)
    local bestFound
    for i = 8, 1, -1 do
        local button = buttons[unit.."-"..i]
        local spell = activeSpells[i]
        if button and spell then
            if not spell.max then
                spell.min, spell.max = getMinMax(spell.spellId)
            end
            if spell.max then
                local bonus = healingPower * (spell.baseCastTime / 3.5)
                local spellMaxHealing = spell.max + bonus -- calculate max heal
                if spellMaxHealing > deficit then
                    button.texture:SetColorTexture(1, 0, 0, 0) -- invisible
                else
                    local enoughMana
                    if mana >= spell.cost then
                        enoughMana = true
                    end
                    if not bestFound then
                        if enoughMana then
                            button.texture:SetColorTexture(0, 1, 0, alpha) -- green
                        end
                        bestFound = true
                    else
                        if enoughMana then
                            button.texture:SetColorTexture(1, 1, 0, alpha) -- yellow
                        end
                    end
                    if not enoughMana then
                        button.texture:SetColorTexture(1, 0.5, 0, alpha) -- orange
                    end
                end
            end
        end
    end
end

local updateAllUnitColor = function()
    print_debug("updateAllUnitColor")
    for unit in IterateGroupMembers() do
        updateUnitColor(unit)
    end
end

local size = 15

local InitSquares = function()
    print_debug("InitSquares")
    for _, button in pairs(buttons) do
        buttonHide(button)
    end

    updateStats()
    for unit in IterateGroupMembers() do
        local frame = GetUnitFrame(unit)
        if frame then
            local scale = frame:GetEffectiveScale()
            -- local size = (frame:GetWidth() * scale - (space * scale * 2)) / 4
            local ssize = size * scale
            local x_space = (((frame:GetWidth() * scale) - (4 * ssize))) / 2
            local y_space = (((frame:GetHeight() * scale) - (2 * ssize))) / 2
            local x, y = x_space, - y_space
            for i = 1, 8 do
                local buttonName = unit.."-"..i
                local button = buttons[buttonName]
                if not button then
                    button = CreateFrame("Button", "EZPRIEST_BUTTON"..buttonName, f, "SecureActionButtonTemplate")
                    button:SetFrameStrata("DIALOG")
                    buttons[buttonName] = button
                    button.texture = button:CreateTexture(nil, "DIALOG")
                    button.texture:SetAllPoints()
                end
                button:SetAttribute("unit", unit)
                button:SetAttribute("type1", "spell")
                button:SetAttribute("spell1", flash[i] and flash[i].spellId)
                button:SetAttribute("shift-type1", "spell")
                button:SetAttribute("shift-spell1", greater[i] and greater[i].spellId)
                button:SetSize(ssize, ssize)
                button.texture:SetColorTexture(1, 0, 0, 0)
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
                if i == 4 then
                    x = x_space
                    y = y - ssize
                else
                    x = x + ssize
                end
                button:Show()
            end
        end
    end
    updateAllUnitColor()
end

local function Update()
    print_debug("Update")
    if not InCombatLockdown() then
        InitSquares()
    else -- in combat, try again in 2s
        C_Timer.After(2, Update)
    end
end

local DelayedUpdate = function()
    print_debug("DelayedUpdate")
    C_Timer.After(3, Update) -- wait 3s for addons to set their frames
end

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

function f:ADDON_LOADED(event, addonName)
    print_debug(event, addonName)
    if addonName == "EZPriest" then
        DelayedUpdate()
    end
end

LGF.RegisterCallback("EZPriest", "GETFRAME_REFRESH", function()
    Update()
end)

function f:MODIFIER_STATE_CHANGED(event, key, state)
    if key == "LSHIFT" or key == "RSHIFT" then
        print_debug(event)
        shift = state == 1
        updateStats()
        updateAllUnitColor()
    end
end

function f:UNIT_HEALTH_FREQUENT(event, unit)
    print_debug(event, unit)
    if groupUnit[unit] then
        updateStats()
        updateUnitColor(unit)
    end
end

function f:UNIT_POWER_UPDATE(event, unit)
    print_debug(event, unit)
    updateStats()
    if mana < maxCost then
        updateAllUnitColor()
    end
end

f:RegisterEvent("UNIT_HEALTH_FREQUENT")
f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("MODIFIER_STATE_CHANGED")