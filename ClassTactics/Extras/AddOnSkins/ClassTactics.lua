local AS = _G.AddOnSkins and unpack(_G.AddOnSkins)

if not AS then return end

local CT = unpack(_G.ClassTactics)

function AS:ClassTactics(event, addon)
	if event == 'PLAYER_ENTERING_WORLD' and IsAddOnLoaded('Blizzard_TalentUI') or addon == 'Blizzard_TalentUI' then
		AS:SkinBackdropFrame(CT.TalentsFrames)
		AS:SkinBackdropFrame(CT.TalentsFrames.PvPTalents)
		AS:SkinButton(CT.TalentsFrames.NewButton)
		AS:SkinButton(CT.TalentsFrames.PvPTalents.NewButton)
		AS:SkinButton(CT.TalentsFrames.ToggleButton)
		AS:SkinButton(CT.TalentsFrames.PvPTalents.ToggleButton)

		CT.TalentsFrames:SetPoint('TOPLEFT', _G.PlayerTalentFrame, 'TOPRIGHT', 2, -1)
		CT.TalentsFrames.TitleText:SetFont(CT.Libs.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')
		CT.TalentsFrames.PvPTalents.TitleText:SetFont(CT.Libs.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')

		hooksecurefunc(CT, "TalentProfiles_CreateLoadout", function()
			for _, Frame in next, CT.TalentsFrames.Buttons do
				for _, Button in next, { 'Load', 'Options' } do
					AS:SkinButton(Frame[Button])
				end
			end

			for _, Frame in next, CT.TalentsFrames.PvPTalents.Buttons do
				for _, Button in next, { 'Load', 'Options' } do
					AS:SkinButton(Frame[Button])
				end
			end
		end)

		hooksecurefunc(CT, "TalentProfiles_CreateExtraButton", function()
			for _, Button in next, CT.TalentsFrames.ExtraButtons do
				AS:SkinButton(Button)
				AS:SkinTexture(Button.icon)
				AS:SetInside(Button.icon)
			end
		end)
	end
end

AS:RegisterSkin('ClassTactics', AS.ClassTactics, 'ADDON_LOADED')
