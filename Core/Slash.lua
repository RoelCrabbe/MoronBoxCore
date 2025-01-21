for _, cmd in pairs({ "/rl", "/RL", "/Rl", "/rL" }) do
    _G["SLASH_RELOADUI" .. _] = cmd
end

SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end