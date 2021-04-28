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

local QuickTalentFlyoutBar = CreateFrame('Frame', 'ClassTactics_QuickTalentsFlyout', UIParent, 'BackdropTemplate')
QuickTalentFlyoutBar:SetMovable(true)
QuickTalentFlyoutBar:SetPoint('LEFT', 0, 0)

QuickTalentFlyoutBar.Flyout = CreateFrame('Frame', nil, QuickTalentFlyoutBar, 'BackdropTemplate')
QuickTalentFlyoutBar.Flyout:Hide()
QuickTalentFlyoutBar.Flyout:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8X8'})
QuickTalentFlyoutBar.Flyout:SetBackdropColor(0, 0, 0, .6)
QuickTalentFlyoutBar.Flyout.Buttons = {}
QuickTalentFlyoutBar.Flyout:SetScript('OnShow', function(self) for _, button in next, self.Buttons do button:Show() end end)
QuickTalentFlyoutBar.Flyout:SetScript('OnHide', function(self) for _, button in next, self.Buttons do button:Hide() end self:Hide() end)

function CT:QuickTalents_Create()
	QuickTalents:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8X8'})
	QuickTalents:SetBackdropColor(0, 0, 0, .6)

	QuickTalentFlyoutBar:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8X8'})
	QuickTalentFlyoutBar:SetBackdropColor(0, 0, 0, .6)

	if _G.ElvUI then
		QuickTalents:SetMovable(false)
		QuickTalents:EnableMouse(false)
		_G.ElvUI[1]:CreateMover(QuickTalents, 'QuickTalentsMover', 'QuickTalents Anchor', nil, nil, nil, 'ALL,GENERAL', nil, 'ClassTactics')
		_G.ElvUI[1]:CreateMover(QuickTalentFlyoutBar, 'QuickTalentFlyoutBarMover', 'QuickTalentFlyoutBar Anchor', nil, nil, nil, 'ALL,GENERAL', nil, 'ClassTactics')
	else
		QuickTalents:EnableMouse(true)
		QuickTalents:SetClampedToScreen(true)
		QuickTalents:RegisterForDrag('LeftButton')
		QuickTalents:SetScript('OnDragStart', QuickTalents.StartMoving)
		QuickTalents:SetScript('OnDragStop', QuickTalents.StopMovingOrSizing)

		QuickTalentFlyoutBar:EnableMouse(true)
		QuickTalentFlyoutBar:SetClampedToScreen(true)
		QuickTalentFlyoutBar:RegisterForDrag('LeftButton')
		QuickTalentFlyoutBar:SetScript('OnDragStart', QuickTalentFlyoutBar.StartMoving)
		QuickTalentFlyoutBar:SetScript('OnDragStop', QuickTalentFlyoutBar.StopMovingOrSizing)
	end

	QuickTalents.Buttons = {}
	QuickTalentFlyoutBar.Tier = {}

	do
		local function OnEnter(btn)
			if InCombatLockdown() then return end

			if btn.talentID then
				GameTooltip:SetOwner(btn, 'ANCHOR_RIGHT')
				GameTooltip:SetTalent(btn.talentID)
				GameTooltip:Show()
			end

			if not btn.flyout then
				UIFrameFadeIn(btn, .1, btn:GetAlpha(), 1)
				UIFrameFadeIn(btn.parent, .1, btn.parent:GetAlpha(), 1)
			end
		end

		local function OnLeave(btn)
			GameTooltip:Hide()

			if not btn.flyout then
				UIFrameFadeOut(btn, .1, btn:GetAlpha(), btn.selected and 1 or 0.25)
				UIFrameFadeOut(btn.parent, .1, btn.parent:GetAlpha(), CT.db.general.quicktalents.alpha)
			end
		end

		local function OnDragStart(btn)
			return not InCombatLockdown() and btn.talentID and PickupTalent(btn.talentID)
		end

		local function OnEvent(btn, event)
			if event and strmatch(event, '^PLAYER_REGEN') then
				SetDesaturation(btn.icon, event == 'PLAYER_REGEN_DISABLED')
			elseif btn.column and btn.tier then
				local talentID, _, texture, selected, _, _, _, _, _, _, grantedByAura = GetTalentInfo(btn.tier, btn.column, 1)
				btn.talentID, btn.selected = talentID, selected or grantedByAura
				btn.icon:SetTexture(texture)
			elseif btn.tier then
				for i = 1, 3 do
					local talentID, _, texture, selected = GetTalentInfo(btn.tier, i, 1)
					if selected then
						btn.talentID, btn.selected = talentID, selected
						btn.icon:SetTexture(texture)
					end
				end
				if not btn.icon:GetTexture() then
					btn.icon:SetTexture(136243)
				end
			end
		end

		local function OnClick(btn)
			QuickTalentFlyoutBar.Flyout:Hide()
			return not InCombatLockdown() and not btn.selected and LearnTalents(btn.talentID)
		end

		local function FlyoutOnClick(btn)
			if QuickTalentFlyoutBar.Flyout:IsShown() then
				QuickTalentFlyoutBar.Flyout:Hide()
			else
				QuickTalentFlyoutBar.Flyout:Hide()

				for _, button in next, QuickTalentFlyoutBar.Flyout.Buttons do
					button.tier = btn.tier
					button:SetSize(CT.db.general.quicktalents.buttonSize, CT.db.general.quicktalents.buttonSize)
				end

				QuickTalentFlyoutBar.Flyout:ClearAllPoints()

				if CT.db.general.quicktalents.layout == 'vertical' then
					QuickTalentFlyoutBar.Flyout:SetPoint('LEFT', btn, 'RIGHT', 3, 0)
					QuickTalentFlyoutBar.Flyout:SetSize((CT.db.general.quicktalents.buttonSize * 3) + 11, CT.db.general.quicktalents.buttonSize + 4)
				else
					QuickTalentFlyoutBar.Flyout:SetPoint('BOTTOM', btn, 'TOP', 0, 3)
					QuickTalentFlyoutBar.Flyout:SetSize(CT.db.general.quicktalents.buttonSize + 4, (CT.db.general.quicktalents.buttonSize * 3) + 4)
				end

				QuickTalentFlyoutBar.Flyout:Show()
			end
		end

		local function CreateBaseButton(parent, events, onEnter, onLeave, onEvent, onDragStart, onClick, onShow)
			local button = CreateFrame('Button', nil, parent)

			button.icon = button:CreateTexture(nil, 'ARTWORK')
			button.icon:SetAllPoints()
			button.icon:SetTexCoord(.075, .925, .075, .925)

			button.parent = parent

			if onEnter then button:SetScript('OnEnter', onEnter) end
			if onLeave then button:SetScript('OnLeave', onLeave) end
			if onEvent then FrameUtil.RegisterFrameForEvents(button, events) button:SetScript('OnEvent', onEvent) end
			if onShow then button:SetScript('OnShow', onShow) end
			if onClick then button:SetScript('OnClick', onClick) end
			if onDragStart then button:RegisterForDrag('LeftButton') button:SetScript('OnDragStart', onDragStart) end

			return button
		end

		for tier = 1, MAX_TALENT_TIERS do
			QuickTalents.Buttons[tier] = QuickTalents.Buttons[tier] or {}

			QuickTalentFlyoutBar.Tier[tier] = CreateBaseButton(QuickTalentFlyoutBar, { 'PLAYER_TALENT_UPDATE', 'PLAYER_REGEN_ENABLED', 'PLAYER_REGEN_DISABLED', 'PLAYER_ENTERING_WORLD' }, OnEnter, OnLeave, OnEvent, OnDragStart, FlyoutOnClick)
			QuickTalentFlyoutBar.Tier[tier].flyout = true
			QuickTalentFlyoutBar.Tier[tier].tier = tier

			for column = 1, NUM_TALENT_COLUMNS do
				QuickTalentFlyoutBar.Flyout.Buttons[column] = CreateBaseButton(QuickTalentFlyoutBar.Flyout, { 'PLAYER_TALENT_UPDATE' }, OnEnter, OnLeave, nil, OnDragStart, OnClick, OnEvent)
				QuickTalentFlyoutBar.Flyout.Buttons[column].flyout = true
				QuickTalentFlyoutBar.Flyout.Buttons[column].column = column

				QuickTalents.Buttons[tier][column] = CreateBaseButton(QuickTalents, { 'PLAYER_TALENT_UPDATE', 'PLAYER_REGEN_ENABLED', 'PLAYER_REGEN_DISABLED', 'PLAYER_ENTERING_WORLD' }, OnEnter, OnLeave, OnEvent, OnDragStart, OnClick)
				QuickTalents.Buttons[tier][column]:HookScript('OnEvent', function(btn) btn:SetAlpha(btn.selected and 1 or .25) end)
				QuickTalents.Buttons[tier][column].tier, QuickTalents.Buttons[tier][column].column = tier, column
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
		QuickTalentFlyoutBar:SetSize(db.buttonSize + 7, (db.buttonSize * 7) + 11)
	else
		QuickTalents:SetSize((db.buttonSize * 7) + 11, (db.buttonSize * 3) + 4)
		QuickTalentFlyoutBar:SetSize((db.buttonSize * 7) + 13, db.buttonSize + 6)
	end

	QuickTalents:SetAlpha(CT.db.general.quicktalents.alpha)
	QuickTalentFlyoutBar:SetAlpha(CT.db.general.quicktalents.alpha)

	QuickTalents:SetShown(CT.db.general.quicktalents.enable and CT.db.general.quicktalents.style == 'classic')
	QuickTalentFlyoutBar:SetShown(CT.db.general.quicktalents.enable and CT.db.general.quicktalents.style == 'flyout')

	for tier = 1, MAX_TALENT_TIERS do
		QuickTalentFlyoutBar.Tier[tier]:SetSize(db.buttonSize, db.buttonSize)

		if db.layout == 'vertical' then
			if tier == 1 then
				QuickTalentFlyoutBar.Tier[tier]:SetPoint('TOPLEFT', QuickTalentFlyoutBar, 'TOPLEFT', 3, -3)
			else
				QuickTalentFlyoutBar.Tier[tier]:SetPoint('TOP', QuickTalentFlyoutBar.Tier[tier - 1], 'BOTTOM', 0, -1)
			end
		else
			if tier == 1 then
				QuickTalentFlyoutBar.Tier[tier]:SetPoint('TOPLEFT', QuickTalentFlyoutBar, 'TOPLEFT', 3, -3)
			else
				QuickTalentFlyoutBar.Tier[tier]:SetPoint('LEFT', QuickTalentFlyoutBar.Tier[tier - 1], 'RIGHT', 1, 0)
			end
		end

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

				QuickTalentFlyoutBar.Flyout.Buttons[column]:SetPoint('LEFT', column == 1 and QuickTalentFlyoutBar.Flyout or QuickTalentFlyoutBar.Flyout.Buttons[column - 1], column == 1 and 'LEFT' or 'RIGHT', 3, 0)
			else
				if tier == 1 and column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents, 'TOPLEFT', 3, -3)
				elseif column == 1 then
					QuickTalents.Buttons[tier][column]:SetPoint('TOPLEFT', QuickTalents.Buttons[tier - 1][1], 'TOPRIGHT', 1, 0)
				else
					QuickTalents.Buttons[tier][column]:SetPoint('TOP', QuickTalents.Buttons[tier][column - 1], 'BOTTOM', 0, 1)
				end

				QuickTalentFlyoutBar.Flyout.Buttons[column]:SetPoint('BOTTOM', column == 1 and QuickTalentFlyoutBar.Flyout or QuickTalentFlyoutBar.Flyout.Buttons[column - 1], column == 1 and 'BOTTOM' or 'TOP', 0, 3)
			end
		end
	end
end
