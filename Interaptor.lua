local Interaptor = CreateFrame("Frame")

local playerGUID = UnitGUID("player")
local playerName, _ = UnitName("player")

local defaultData = {
    targetName = true,
    playerSpell = true,
}

function Interaptor:OnEvent(event, ...)
    self[event](self, event, ...)
end

function Interaptor:ADDON_LOADED(event, addOnName)
    if addOnName == "Interaptor" then
        InteraptorDB = InteraptorDB or CopyTable(defaultData)
        self.db = InteraptorDB

        -- Options Panel --
        self.panel = CreateFrame("Frame")
        self.panel.name = addOnName

        local title = self.panel:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Huge1")
        title:SetPoint("TOPLEFT", 7, -22)
        title:SetText(addOnName)

        local exampleTitle = self.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftOrange")
        exampleTitle:SetPoint("TOPLEFT", 7, -120)
        exampleTitle:SetText("Example message:")

        local exampleText = format("%s: ", playerName) .. self:BuildMessage(86620, "Hogger", 96231)
        local exampleMessage = self.panel:CreateFontString(nil, "OVERLAY", "CombatLogFont")
        exampleMessage:SetPoint("TOPLEFT", 7, -140)
        exampleMessage:SetText(exampleText)

        -- Checkboxes --
        local cbTargetName = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
        cbTargetName:SetPoint("TOPLEFT", 7, -50)
        cbTargetName.Text:SetText(" Show target name in message")
        cbTargetName:HookScript("OnClick", function(_, btn, down)
            self.db.targetName = cbTargetName:GetChecked()
            exampleText = format("%s: ", playerName) .. self:BuildMessage(86620, "Hogger", 96231)
            exampleMessage:SetText(exampleText)
        end)
        cbTargetName:SetChecked(self.db.targetName)

        local cbPlayerSpell = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
        cbPlayerSpell:SetPoint("TOPLEFT", 7, -70)
        cbPlayerSpell.Text:SetText(" Show player spell in message")
        cbPlayerSpell:HookScript("OnClick", function(_, btn, down)
            self.db.playerSpell = cbPlayerSpell:GetChecked()
            exampleText = format("%s: ", playerName) .. self:BuildMessage(86620, "Hogger", 96231)
            exampleMessage:SetText(exampleText)
        end)
        cbPlayerSpell:SetChecked(self.db.playerSpell)

        -- Footer --
        local footerCreator = self.panel:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall")
        footerCreator:SetPoint("BOTTOMLEFT", 7, 50)
        footerCreator:SetText("Created by Divinebanana - Burning Legion")

        local version, build, _, _ = GetBuildInfo()
        local footerVersion = self.panel:CreateFontString(nil, "OVERLAY", "GameFontDarkGraySmall")
        footerVersion:SetPoint("BOTTOMLEFT", 7, 38)
        footerVersion:SetText(format("Interaptor for World of Warcraft %s (%d)", version, build))

        local footerGitHub = self.panel:CreateFontString(nil, "OVERLAY", "GameFontDarkGraySmall")
        footerGitHub:SetPoint("BOTTOMLEFT", 7, 26)
        footerGitHub:SetText("https://github.com/lukzmu/interaptor")

        Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(self.panel, addOnName))
    end
end

function Interaptor:COMBAT_LOG_EVENT_UNFILTERED(event)
    local _, subevent, _, sourceGUID, _, _, _, _, enemyName = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_INTERRUPT" and sourceGUID == playerGUID then
        local playerSpellId = select(12, CombatLogGetCurrentEventInfo())
        local enemySpellId = select(15, CombatLogGetCurrentEventInfo())

        local message = self:BuildMessage(enemySpellId, enemyName, playerSpellId)
        SendChatMessage(message)
    end
end

function Interaptor:BuildMessage(enemySpellId, enemyName, playerSpellId)
    local msgStart = "Interrupted %s"
    local msgTargetName = " (%s)"
    local msgPlayerSpell = " using %s"
    local msgEnd = "!"

    local result = format(msgStart, C_Spell.GetSpellLink(enemySpellId))
    if self.db.targetName then
        result = result .. format(msgTargetName, enemyName)
    end
    if self.db.playerSpell then
        result = result .. format(msgPlayerSpell, C_Spell.GetSpellLink(playerSpellId))
    end

    return result .. msgEnd
end

Interaptor:RegisterEvent("ADDON_LOADED")
Interaptor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Interaptor:SetScript("OnEvent", Interaptor.OnEvent)
