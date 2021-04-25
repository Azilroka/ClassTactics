local CT = unpack(_G.ClassTactics)

local IsAddOnLoaded = IsAddOnLoaded

_G.StaticPopupDialogs.CLASSTACTICS = {
	button2 = 'Cancel',
	timeout = 0,
	whileDead = 1,
	enterClicksFirstButton = 1,
}

function CT:Init()
	CT:BuildProfile()
	CT:BuildOptions()

	local EP = _G.LibStub('LibElvUIPlugin-1.0', true)
	if EP then
		EP:RegisterPlugin('ClassTactics', CT.GetOptions)
	else
		CT:GetOptions()
	end

	CT:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", 'TalentProfiles_Update')
	CT:RegisterEvent("PLAYER_LEVEL_UP", 'DelayAutoTalent')

	if IsAddOnLoaded('Blizzard_TalentUI') then
		CT:ADDON_LOADED('ADDON_LOADED', 'Blizzard_TalentUI')
	else
		CT:RegisterEvent('ADDON_LOADED')
	end

	CT:AutoTalent()
	CT:QuickTalents_Create()
end

function CT:ADDON_LOADED(event, addon)
	if addon == 'Blizzard_TalentUI' then
		CT:TalentProfiles()
		CT:UnregisterEvent(event)
	end
end

CT:RegisterEvent('PLAYER_LOGIN', 'Init')
