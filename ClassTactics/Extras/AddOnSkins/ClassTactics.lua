local AS = _G.AddOnSkins and unpack(_G.AddOnSkins)

if not AS then return end

local CT = unpack(_G.ClassTactics)

function AS:ClassTactics(event, addon)
	if CT.TalentProfiles then
		hooksecurefunc(CT, 'TalentProfiles', function()
			AS:SkinBackdropFrame(CT.TalentsFrames)
			AS:SkinBackdropFrame(CT.TalentsFrames.PvPTalents)
			AS:SkinButton(CT.TalentsFrames.NewButton)
			AS:SkinButton(CT.TalentsFrames.PvPTalents.NewButton)
			AS:SkinButton(CT.TalentsFrames.ToggleButton)
			AS:SkinButton(CT.TalentsFrames.PvPTalents.ToggleButton)

			CT.TalentsFrames:SetPoint('TOPLEFT', _G.PlayerTalentFrame, 'TOPRIGHT', 2, -1)
			CT.TalentsFrames.TitleText:SetFont(CT.Libs.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')
			CT.TalentsFrames.PvPTalents.TitleText:SetFont(CT.Libs.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')
		end)

		hooksecurefunc(CT, "TalentProfiles_Update", function()
			if CT.TalentsFrames then
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
			end
		end)

		hooksecurefunc(CT, "TalentProfiles_CreateExtraButton", function()
			if CT.TalentsFrames then
				for _, Button in next, CT.TalentsFrames.ExtraButtons do
					AS:SkinButton(Button)
					AS:SkinTexture(Button.icon)
					AS:SetInside(Button.icon)
				end
			end
		end)
	end
end

AS:RegisterSkin('ClassTactics', AS.ClassTactics)
