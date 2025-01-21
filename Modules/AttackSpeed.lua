function MBC:GetServerLatency(extraDelay)
    local extraDelay = extraDelay or 0
    local homeLatency, worldLatency = select(1, GetNetStats()), select(2, GetNetStats())
    worldLatency = math.max(0.01, math.min(0.09, worldLatency / 1000))
    return worldLatency + extraDelay
end

function MBC:GetRangedAttackSpeed(extraDelay)
    local worldLatency = MBC:GetServerLatency(extraDelay)
    local _, rangedSpeed = UnitRangedDamage("player")
    return rangedSpeed + worldLatency
end