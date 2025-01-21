function MBC:PrepareAutoLoot(arg1)
    local _, name, _, quality = GetLootRollItemInfo(arg1)
    if quality == 2 then
        StaticPopup_Hide("CONFIRM_LOOT_ROLL")
    end
end

function MBC:AutoLoot(arg1)
     local _, name, _, quality = GetLootRollItemInfo(arg1)

    for _, item in pairs(MBC.Session.ItemList) do
        if string.find(name , item) then
            RollOnLoot(arg1, 1)
        end 
    end

    if quality == 2 then
        RollOnLoot(arg1, 2)
    end
end