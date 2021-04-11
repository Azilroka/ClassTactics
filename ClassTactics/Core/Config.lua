local CT = unpack(_G.ClassTactics)
if CT:IsAddOnEnabled('ProjectAzilroka', CT.MyName) or CT:IsAddOnEnabled('ElvUI', CT.MyName) then return end

local CTC = CT:NewModule("ClassTacticsConfig", 'AceConsole-3.0', 'AceEvent-3.0')
_G.ClassTactics_Config = CTC

CTC.Title = "|cff1784d1ClassTactics Config|r"
CTC.Authors = "Azilroka"

local DEVELOPERS = {
	'Elv',
	'Tukz',
	'Hydrazine',
	'Whiro',
}

local DEVELOPER_STRING = ''

sort(DEVELOPERS, function(a,b) return a < b end)
for _, devName in pairs(DEVELOPERS) do
	DEVELOPER_STRING = DEVELOPER_STRING..'\n'..devName
end

CTC.Options = {
	type = 'group',
	name = CT.Title,
	order = 205,
	args = {
		credits = {
			type = 'group',
			name = 'Credits',
			order = -1,
			args = {
				text = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = 'Coding:\n'..DEVELOPER_STRING,
				},
			},
		},
	},
}

function CTC:PositionGameMenuButton()
	local hasTukui = CT:IsAddOnEnabled('Tukui', CT.MyName)

	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)

	if hasTukui and Tukui[1].Miscellaneous.GameMenu.Tukui then
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	end

	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame['CTC'] then
		GameMenuFrame['CTC']:ClearAllPoints()
		GameMenuFrame['CTC']:SetPoint("TOPLEFT", hasTukui and Tukui[1].Miscellaneous.GameMenu.Tukui or relTo, "BOTTOMLEFT", 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:SetPoint("TOPLEFT", GameMenuFrame['CTC'], "BOTTOMLEFT", 0, offY)
	end
end

function CTC.OnConfigClosed(widget, event)
	CT.Libs.ACD.OpenFrames['ClassTactics'] = nil
	CT.Libs.GUI:Release(widget)
end

function CTC:ToggleConfig()
	if not CT.Libs.ACD.OpenFrames['ClassTactics'] then
		local Container = CT.Libs.GUI:Create('Frame')
		CT.Libs.ACD.OpenFrames['ClassTactics'] = Container
		Container:SetCallback('OnClose', CTC.OnConfigClosed)
		CT.Libs.ACD:Open('ClassTactics', Container)
	end

	GameTooltip:Hide()
end

function CTC:ADDON_LOADED(event, addon)
	if addon == 'Tukui' then
		Tukui[1].Miscellaneous.GameMenu.EnableTukuiConfig = function() end
		Tukui[1].Miscellaneous.GameMenu.AddHooks = function() end
		CTC:UnregisterEvent(event)
	end
end

function CTC:Initialize()
	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(CT.Title)
	GameMenuButton:SetScript("OnClick", function()
		CTC:ToggleConfig()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame['CTC'] = GameMenuButton

	if not IsAddOnLoaded("ConsolePortUI_Menu") then
		GameMenuButton:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', self.PositionGameMenuButton)
	end

	CT.Libs.AC:RegisterOptionsTable('ClassTactics', CTC.Options)
	CT.Libs.ACD:SetDefaultSize('ClassTactics', 1200, 800)
	CTC:RegisterChatCommand('classtactics', 'ToggleConfig')

	CTC:RegisterEvent('ADDON_LOADED')
end

CTC:Initialize()
