local CT = unpack(_G.ClassTactics)

local strmatch = strmatch

local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS

local PickupTalent = PickupTalent
local SetDesaturation = SetDesaturation
local GetTalentInfo = GetTalentInfo
local LearnTalents = LearnTalents
local InCombatLockdown = InCombatLockdown

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip

local UIParent = UIParent
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut

local QuickTalents = CreateFrame('Frame', 'ClassTactics_QuickTalents', UIParent, 'BackdropTemplate')
QuickTalents:SetMovable(true)
QuickTalents:SetPoint('LEFT', 0, 0)

function CT:QuickTalents_Create()
	QuickTalents:EnableMouse(true)
	QuickTalents:SetClampedToScreen(true)
	QuickTalents:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8X8'})
	QuickTalents:SetBackdropColor(0, 0, 0, .6)

	if _G.ElvUI then
		QuickTalents:SetMovable(false)
		QuickTalents:EnableMouse(false)
		_G.ElvUI[1]:CreateMover(QuickTalents, 'QuickTalentsMover', 'QuickTalents Anchor', nil, nil, nil, 'ALL,GENERAL', nil, 'ClassTactics')
	else
		QuickTalents:RegisterForDrag('LeftButton')
		QuickTalents:SetScript('OnDragStart', QuickTalents.StartMoving)
		QuickTalents:SetScript('OnDragStop', QuickTalents.StopMovingOrSizing)
	end

	QuickTalents.Buttons = {}

	do
		local function OnEnter(btn)
			if InCombatLockdown() then return end

			GameTooltip:SetOwner(btn, 'ANCHOR_RIGHT')
			GameTooltip:SetTalent(btn.talentID)
			GameTooltip:Show()

			UIFrameFadeIn(btn, .1, btn:GetAlpha(), 1)
			UIFrameFadeIn(btn.parent, .1, btn.parent:GetAlpha(), 1)
		end

		local function OnLeave(btn)
			if InCombatLockdown() then return end

			GameTooltip:Hide()

			UIFrameFadeOut(btn, .1, btn:GetAlpha(), btn.selected and 1 or 0.25)
			UIFrameFadeOut(btn.parent, .1, btn.parent:GetAlpha(), CT.db.general.quicktalents.alpha)
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
				button.tier, button.column, button.parent = tier, column, QuickTalents
				button:RegisterForDrag('LeftButton')
				button:RegisterEvent('PLAYER_TALENT_UPDATE')
				button:RegisterEvent('PLAYER_REGEN_ENABLED')
				button:RegisterEvent('PLAYER_REGEN_DISABLED')
				button:RegisterEvent('PLAYER_ENTERING_WORLD')
				button:SetScript('OnLeave', OnLeave)
				button:SetScript('OnEnter', OnEnter)
				button:SetScript('OnDragStart', OnDragStart)
				button:SetScript('OnEvent', OnEvent)
				button:SetScript('OnClick', OnClick)

				button.icon = button:CreateTexture(nil, 'ARTWORK')
				button.icon:SetAllPoints()
				button.icon:SetTexCoord(.075, .925, .075, .925)

				QuickTalents.Buttons[tier][column] = button
			end
		end
	end

	CT:QuickTalents_Update()

	CT.QuickTalents = QuickTalents
end

function CT:QuickTalents_Update()
	local db = CT.db.general.quicktalents

	if db.layout == 'vertical' then
		QuickTalents:SetSize((db.buttonSize * 3) + 7, (db.buttonSize * 7) + 11)
	else
		QuickTalents:SetSize((db.buttonSize * 7) + 11, (db.buttonSize * 3) + 4)
	end

	QuickTalents:SetAlpha(CT.db.general.quicktalents.alpha)

	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			QuickTalents.Buttons[tier][column]:SetSize(db.buttonSize, db.buttonSize)

			if db.layout == 'vertical' then
				if tier == 1 and column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents, 'TOPLEFT', 3, -3)
				elseif column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents.Buttons[tier - 1][1], 'BOTTOMLEFT', 0, -1)
				else
					QuickTalents.Buttons[tier][column]:SetPoint('LEFT', QuickTalents.Buttons[tier][column - 1], 'RIGHT', 1, 0)
				end
			else
				if tier == 1 and column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents, 'TOPLEFT', 3, -3)
				elseif column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents.Buttons[tier - 1][1], 'TOPRIGHT', 1, 0)
				else
					QuickTalents.Buttons[tier][column]:SetPoint('TOP', QuickTalents.Buttons[tier][column - 1], 'BOTTOM', 0, 1)
				end
			end
		end
	end
end
