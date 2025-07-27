------------------------------------------------------------------------------------------------------
--------------------------------------------- Craftables! --------------------------------------------
------------------------------------------------------------------------------------------------------

--------------------------------------------- Transmutes ---------------------------------------------
	-- MB_useMoonclothCooldowns => True or False (Work or Not)
	-- MB_onlyTransMuteBars => True or False (Work or Not) will ignore all of MB_TransmuteBars, MB_TransmuteLiving and MB_TransmuteWater

	local MB_useMoonclothCooldowns = false
	local MB_onlyTransMuteBars = false

	-------------------------------------- Transmutes Tactics ----------------------------------------
	-- MB_TransmuteBars, Arcinite Bars
	-- MB_TransmuteLiving, Essence of Living
	-- MB_TransmuteWater, Essence of Water
	--------------------------------------------------------------------------------------------------

	local MB_TransmuteBars = { "Ajlano", "Rows", "Schmug", "Mukup" }
	local MB_TransmuteLiving = { "Trumptvänty", "Smalheal", "Cykcyk", "Jolf", "Æces", "Chirichi", "Shlongz", "Dl", "Adorii", "Aip" }
	local MB_TransmuteWater = { "Dekot", "Mantodea", "Baldred", "Heffodin", "Naturka" }
	
--------------------------------------------- Transmutes ---------------------------------------------

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

function mb_tradeCooldownMaterialsToLeader() -- This is our trade to Leader function
	
	if not MB_raidLeader then 
		RunLine("/w "..MB_raidInviter.." Press setFOCUS!")
		return
	end

	if myName == MB_raidLeader then 
		return 
	end

	local ItemsToTrade = {
        "Mooncloth",
        "Hourglass Sand",
        "Arcanite Bar",
        "Refined Deeprock Salt",
        "Living Essence",
        "Essence of Water",
        "Cured Rugged Hide"
    }

	for _, item in ipairs(ItemsToTrade) do
        if mb_haveInBags(item) then
            mb_pickAndDropItemOnTarget(item, MBID[MB_raidLeader])
        end
    end

	if not MB_onlyTransMuteBars then
        for _, name in ipairs(MB_TransmuteLiving) do
            if myName == name and mb_haveInBags("Arcane Crystal") then
                mb_pickAndDropItemOnTarget("Arcane Crystal", MBID[MB_raidLeader])
            end
        end

        for _, name in ipairs(MB_TransmuteWater) do
            if myName == name and mb_haveInBags("Arcane Crystal") then
                mb_pickAndDropItemOnTarget("Arcane Crystal", MBID[MB_raidLeader])
            end
        end
    end
end

local function mb_useTransmuteBars()

    if mb_haveInBags("Philosopher's Stone") then
        if mb_haveInBags("Thorium Bar") and mb_haveInBags("Arcane Crystal") then

            CastSpellByName("Alchemy")
            mb_useTradeSkill("Transmute: Arcanite")

        elseif not mb_haveInBags("Arcane Crystal") then

            mb_message(GetColors("Missing Arcane Crystal", 60))

        elseif not mb_haveInBags("Thorium Bar") then

            mb_message(GetColors("Missing Thorium Bar", 60))
        else
            mb_message(GetColors("Missing Thorium Bar and Arcane Crystal", 60))
        end
    else
        mb_message("Missing Philosopher's Stone", 60)
    end
end

local function mb_useTransmuteLiving()

    if mb_haveInBags("Philosopher's Stone") then
        if mb_haveInBags("Essence of Earth") then

            CastSpellByName("Alchemy")
            mb_useTradeSkill("Transmute: Earth to Life")
        else
            mb_message(GetColors("Missing Essence of Earth", 60))
        end
    else
        mb_message("Missing Philosopher's Stone", 60)
    end
end

local function mb_useTransmuteWater()

    if mb_haveInBags("Philosopher's Stone") then
        if mb_haveInBags("Essence of Undeath") then

            CastSpellByName("Alchemy")
            mb_useTradeSkill("Transmute: Undeath to Water")
        else
            mb_message(GetColors("Missing Essence of Undeath", 60))
        end
    else
        mb_message("Missing Philosopher's Stone", 60)
    end
end

local function mb_useTransmute()

    for _, name in ipairs(MB_TransmuteBars) do
        if myName == name then
            mb_useTransmuteBars()
            return
        end
    end

    for _, name in ipairs(MB_TransmuteLiving) do
        if myName == name then
            mb_useTransmuteLiving()
            return
        end
    end

    for _, name in ipairs(MB_TransmuteWater) do
        if myName == name then
            mb_useTransmuteWater()
            return
        end
    end

    mb_message("I've not been assigned a specific transmute!")
end

local function mb_useLeatherworking()

    if mb_knowSpell("Leatherworking") or mb_knowSpell("Dragonscale Leatherworking") then
        if mb_haveInBags("Salt Shaker") then
            if mb_haveInBags("Deeprock Salt") then

                UseItemByName("Salt Shaker")
            else
                mb_message(GetColors("Missing Deeprock Salt", 60))
            end
        else
            mb_message(GetColors("Missing Salt Shaker", 60))
        end
    end
end

local function mb_useMooncloth()

    if MB_useMoonclothCooldowns and mb_knowSpell("Tailoring") then
        if mb_haveInBags("Felcloth") then

            CastSpellByName("Tailoring")
            mb_useTradeSkill("Mooncloth")
        else
            mb_message(GetColors("Missing Felcloth", 60))
        end
    end
end

function mb_useTradeCooldowns()
    if mb_knowSpell("Alchemy") and not mb_imBusy() then
        if MB_onlyTransMuteBars then
            mb_useTransmuteBars()
        else
            mb_useTransmute()
        end
    end

    mb_useLeatherworking()
    mb_useMooncloth()
end