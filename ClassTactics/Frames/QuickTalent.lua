local CT = unpack(_G.ClassTactics)

local strmatch = strmatch

local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS

local PickupTalent = PickupTalent
local SetDesaturation = SetDesaturation
local GetTalentInfo = GetTalentInfo
local LearnTalents = LearnTalents

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent

local QuickTalents = CreateFrame('Frame', 'ClassTactics_QuickTalents', UIParent, 'BackdropTemplate')
QuickTalents:SetMovable(true)
QuickTalents:SetPoint('LEFT', 0, 0)
QuickTalents:SetSize((24 * 3) + 7, (24 * 7) + 11)
QuickTalents:EnableMouse(true)
QuickTalents:SetClampedToScreen(true)
QuickTalents:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8X8'})
QuickTalents:SetBackdropColor(0, 0, 0, .6)
QuickTalents:RegisterForDrag('LeftButton')
QuickTalents:SetScript('OnDragStart', QuickTalents.StartMoving)
QuickTalents:SetScript('OnDragStop', QuickTalents.StopMovingOrSizing)

QuickTalents.Buttons = {}
CT.QuickTalents = QuickTalents

do
	local function OnEnter(btn)
		GameTooltip:SetOwner(btn, 'ANCHOR_RIGHT')
		GameTooltip:SetTalent(btn.talentID)
		GameTooltip:Show()
		btn:SetAlpha(1)
	end

	local function OnLeave(btn)
		GameTooltip:Hide()
		btn:SetAlpha(btn.selected and 1 or 0.25)
	end

	local function OnDragStart(btn)
		return not InCombatLockdown() and PickupTalent(btn.talentID)
	end

	local function OnEvent(btn, event)
		if event and strmatch(event, '^PLAYER_REGEN') then
			SetDesaturation(btn.icon, event == 'PLAYER_REGEN_DISABLED')
		else
			local talentID, _, texture, selected, _, _, _, _, _, _, grantedByAura = GetTalentInfo(btn.tier, btn.column, 1)
			btn.talentID, btn.selected = talentID, selected or grantedByAura
			btn:SetAlpha(btn.selected and 1 or 0.25)
			btn.icon:SetTexture(texture)
		end
	end

	local function OnClick(btn)
		return not InCombatLockdown() and not btn.selected and LearnTalents(btn.talentID)
	end

	for tier = 1, MAX_TALENT_TIERS do
		QuickTalents.Buttons[tier] = QuickTalents.Buttons[tier] or {}

		for column = 1, NUM_TALENT_COLUMNS do
			local button = CreateFrame('Button', nil, QuickTalents)
			button.tier, button.column = tier, column
			button:SetSize(24, 24)
			button:RegisterForDrag('LeftButton')
			button:RegisterEvent('PLAYER_TALENT_UPDATE')
			button:RegisterEvent('PLAYER_REGEN_ENABLED')
			button:RegisterEvent('PLAYER_REGEN_DISABLED')
			button:SetScript('OnLeave', OnLeave)
			button:SetScript('OnEnter', OnEnter)
			button:SetScript('OnDragStart', OnDragStart)
			button:SetScript('OnEvent', OnEvent)
			button:SetScript('OnClick', OnClick)

			if tier == 1 and column == 1 then
				button:SetPoint('TOPLEFT', QuickTalents, 'TOPLEFT', 3, -3)
			elseif column == 1 then
				button:SetPoint('TOPLEFT', QuickTalents.Buttons[tier - 1][1], 'BOTTOMLEFT', 0, -1)
			else
				button:SetPoint('LEFT', QuickTalents.Buttons[tier][column - 1], 'RIGHT', 1, 0)
			end

			button.icon = button:CreateTexture(nil, 'ARTWORK')
			button.icon:SetAllPoints()
			button.icon:SetTexCoord(.075, .925, .075, .925)

			OnEvent(button)

			QuickTalents.Buttons[tier][column] = button
		end
	end
end
