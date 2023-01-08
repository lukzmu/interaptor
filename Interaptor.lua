local Interaptor = CreateFrame("Frame")

local playerGUID = UnitGUID("player")
local MSG_INTERRUPT = "Interrupted %s (%s) using %s!"

Interaptor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interaptor:SetScript("OnEvent", function(self, event, msg, sender)
    local _, subevent, _, sourceGUID, _, _, _, _, enemy = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_INTERRUPT" and sourceGUID == playerGUID then
        local playerSpellId = select(12, CombatLogGetCurrentEventInfo())
        local enemySpellId = select(15, CombatLogGetCurrentEventInfo())

        local playerSpell = GetSpellLink(playerSpellId)
        local enemySpell = GetSpellLink(enemySpellId)

        SendChatMessage(MSG_INTERRUPT:format(enemySpell, enemy, playerSpell))
    end
end)
