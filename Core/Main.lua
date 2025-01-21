-------------------------------------------------------------------------------
-- InterFace Frame {{{
-------------------------------------------------------------------------------

MBC = CreateFrame("Frame", "MoronBoxCore", UIParent)

-------------------------------------------------------------------------------
-- Core Event Code {{{
-------------------------------------------------------------------------------

MBC.Session = {
    ItemList = {
        [1] = "Fel Armament",
        [2] = "Arcane Tome",
    }
}

MBC:RegisterEvent("ADDON_LOADED")
MBC:RegisterEvent("START_LOOT_ROLL")

function MBC:OnEvent(event)
    if event == "ADDON_LOADED" and arg1 == MBC:GetName() then
        MBC:InterfaceOptionsFrame()
    elseif event == "START_LOOT_ROLL" then
        MBC:PrepareAutoLoot(arg1)
        C_Timer.After(math.random(5, 10), MBC:AutoLoot(arg1))
    end
end

MBC:SetScript("OnEvent", MBC.OnEvent)

-------------------------------------------------------------------------------
-- Gets dependent addons {{{
-------------------------------------------------------------------------------

function MBC:GetDependingAddons()
    local loadedAddons = {}

    for i = 1, GetNumAddOns() do
        local addonName = GetAddOnInfo(i)
        local dependencies = { GetAddOnDependencies(i) }

        for _, dep in ipairs(dependencies) do
            if dep == "MoronBoxCore" and IsAddOnLoaded(i) then
                table.insert(loadedAddons, addonName)
            end
        end
    end

    if #loadedAddons == 0 then
        table.insert(loadedAddons, "No dependent addons loaded.")
    end

    return loadedAddons
end