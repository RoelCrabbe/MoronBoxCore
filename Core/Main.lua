-------------------------------------------------------------------------------
-- InterFace Frame {{{
-------------------------------------------------------------------------------

MBC = CreateFrame("Frame", "MoronBoxCore", UIParent)

-------------------------------------------------------------------------------
-- Core Event Code {{{
-------------------------------------------------------------------------------

MBC:RegisterEvent("ADDON_LOADED")

function MBC:OnEvent(event)
    if event == "ADDON_LOADED" and arg1 == MBC:GetName() then
        MBC:InterfaceOptionsFrame()
    end
end

MBC:SetScript("OnEvent", MBC.OnEvent)

function Print(msg)
	if msg then return print(msg) end
end

function CapitalizeFirstLetter(str)
    if not str or str == "" then return str end
    return str:sub(1, 1):upper() .. str:sub(2)
end

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

for _, cmd in pairs({ "/rl", "/RL", "/Rl", "/rL" }) do
    _G["SLASH_RELOADUI" .. _] = cmd
end

SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end