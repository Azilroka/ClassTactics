local CT = unpack(_G.ClassTactics)

local _G = _G

local unpack = unpack
local tinsert = tinsert
local tonumber = tonumber
local next = next
local wipe = wipe
local select = select
local sort = sort
local strmatch = strmatch
local format = format

local CreateFrame = CreateFrame
local GetSpecialization = GetSpecialization
local IsResting = IsResting
local InCombatLockdown = InCombatLockdown
local UnitLevel = UnitLevel
local GetItemCount = GetItemCount
local GetItemIcon = GetItemIcon

local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS
local READY_CHECK_READY_TEXTURE = READY_CHECK_READY_TEXTURE
local READY_CHECK_READY_TEXTURE_INLINE = format('|T%s:16:16:0:0:64:64:4:60:4:60|t', READY_CHECK_READY_TEXTURE)

CT.CurrentTalentProfiles = {}

CT.EasyMenu = CreateFrame('Frame', 'ClassTacticsEasyMenu', UIParent, 'UIDropDownMenuTemplate')

CT.MenuList = {
	{ text = 'Update', arg1 = 'update', notCheckable = true},
	{ text = 'Rename', arg1 = 'rename', notCheckable = true},
	{ text = 'Delete', arg1 = 'delete', notCheckable = true},
}

_G.StaticPopupDialogs.CLASSTACTICS_TALENTPROFILE = {
	button2 = 'Cancel',
	timeout = 0,
	whileDead = 1,
	enterClicksFirstButton = 1,
}

local ExchangeTable = {
	Tomes = {
		[141640] = { min = 10, max = 50 }, -- Tome of the Clear Mind (Unit Level 10-50)
		[141446] = { min = 10, max = 50 }, -- Tome of the Tranquil Mind (Unit Level 10-50)
		[153647] = { min = 10, max = 59 }, -- Tome of the Quiet Mind (Unit Level 10-59)
		[173049] = { min = 51, max = 60 }, -- Tome of the Still Mind (Unit Level 51-60)
	},
	Codex = {
		[141641] = { min = 10, max = 50 }, -- Codex of the Clear Mind (Unit Level 10-50)
		[141333] = { min = 10, max = 50 }, -- Codex of the Tranquil Mind (Unit Level 10-50)
		[153646] = { min = 10, max = 59 }, -- Codex of the Quiet Mind (Unit Level 10-59)
		[173048] = { min = 51, max = 60 }, -- Codex of the Still Mind (Unit Level 51-60)
	}
}

function CT:SetupTalentPopup(setupType, funcSetup, name)
	local Dialog = _G.StaticPopupDialogs.CLASSTACTICS_TALENTPROFILE
	Dialog.text = 'Enter a Name:'
	Dialog.button1 = 'Create'
	Dialog.hasEditBox = 1
	Dialog.EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end

	local db = CT.db[funcSetup == 'PvP' and 'talentBuildsPvP' or 'talentBuilds'][CT.MyClass][GetSpecialization()]

	Dialog.OnAccept = function(s) CT:SaveTalentBuild(funcSetup, s.editBox:GetText()) end
	Dialog.EditBoxOnEnterPressed = function(s) CT:SaveTalentBuild(funcSetup, s:GetText()) s:GetParent():Hide() end

	if setupType == 'delete' then
		Dialog.hasEditBox = nil
		Dialog.button1 = 'Delete'
		Dialog.text = format('Are you sure you want to delete %s?', name)
		Dialog.OnAccept = function() db[name] = nil CT:UpdateOptions() CT:TalentProfiles_Update() end
	elseif setupType == 'rename' then
		Dialog.button1 = 'Update'
		Dialog.OnShow = function(s) s.editBox:SetAutoFocus(false) s.editBox:SetText(name) s.editBox:HighlightText() end
		Dialog.OnAccept = function(s) db[s.editBox:GetText()] = db[name] db[name] = nil CT:UpdateOptions() CT:TalentProfiles_Update() end
		Dialog.EditBoxOnEnterPressed = function(s) db[s:GetText()] = db[name] db[name] = nil CT:UpdateOptions() CT:TalentProfiles_Update() s:GetParent():Hide() end
	end

	_G.StaticPopup_Show('CLASSTACTICS_TALENTPROFILE')
end

function CT:OrderedPairs(t, f)
	local a = {}
	for n in next, t do tinsert(a, n) end
	sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

function CT:SaveTalentBuild(funcSetup, text)
	local activeSpecIndex = GetSpecialization()
	if funcSetup == 'PvP' then
		CT.db.talentBuildsPvP[CT.MyClass][activeSpecIndex][text] = CT:GetSelectedPvPTalents()
	else
		CT.db.talentBuilds[CT.MyClass][activeSpecIndex][text] = CT:GetSelectedTalents()
	end

	CT:TalentProfiles_Update()
	CT:UpdateOptions()
end

function CT:TalentProfiles()
	local ProfileMenu = CreateFrame('Frame', 'ClassTacticsTalentProfiles', _G.PlayerTalentFrameTalents, 'BackdropTemplate')
	ProfileMenu:SetPoint('TOPLEFT', _G.PlayerTalentFrame, 'TOPRIGHT', 2, 0)
	ProfileMenu:SetSize(250, 50)
	ProfileMenu:SetShown(CT.db.isShown)
	ProfileMenu:SetScript('OnShow', CT.TalentProfiles_Update)
	ProfileMenu:RegisterEvent('BAG_UPDATE_DELAYED')
	ProfileMenu:RegisterUnitEvent('UNIT_AURA', 'player')
	ProfileMenu:RegisterEvent('ZONE_CHANGED')
	ProfileMenu:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	ProfileMenu:SetScript('OnEvent', CT.TalentProfiles_CheckBags)

	ProfileMenu.Buttons = {}
	ProfileMenu.ExtraButtons = {}
	ProfileMenu.Gradients = {}

	ProfileMenu.Gradients[1] = CT:AddGradientColor(ProfileMenu, 240, 2, CT.ClassColor)
	ProfileMenu.Gradients[2] = CT:AddGradientColor(ProfileMenu, 240, 2, CT.ClassColor)

	ProfileMenu.Title = ProfileMenu:CreateFontString(nil, 'OVERLAY')
	ProfileMenu.Title:SetFont(CT.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')
	ProfileMenu.Title:SetText('Talent Profiles')
	ProfileMenu.Title:SetPoint('TOP', 0, -5)
	ProfileMenu.Title:SetJustifyH('CENTER')

	ProfileMenu.Gradients[1]:SetPoint('TOP', ProfileMenu.Title, 'BOTTOM', 0, -5)

	ProfileMenu.NewButton = CreateFrame('Button', nil, ProfileMenu, 'BackdropTemplate, UIPanelButtonTemplate')
	ProfileMenu.NewButton:SetText('Save Talents')
	ProfileMenu.NewButton:SetSize(240, 20)
	ProfileMenu.NewButton:SetPoint('TOP', ProfileMenu.Gradients[2], 'BOTTOM', 0, -5)
	ProfileMenu.NewButton:SetScript('OnClick', function() CT:SetupTalentPopup() end)

	ProfileMenu.ToggleButton = CreateFrame('Button', 'ClassTacticsTalentManagerToggleButton', _G.PlayerTalentFrameTalents, 'BackdropTemplate, UIPanelButtonTemplate')
	ProfileMenu.ToggleButton:Point('BOTTOMRIGHT', _G.PlayerTalentFrameTalents, 'BOTTOMRIGHT', -5, -20)
	ProfileMenu.ToggleButton:SetText('Toggle Talent Manager')
	ProfileMenu.ToggleButton:SetSize(ProfileMenu.ToggleButton.Text:GetStringWidth() + 20, 25)
	ProfileMenu.ToggleButton:SetScript('OnClick', function() CT.db.isShown = not CT.db.isShown ProfileMenu:SetShown(CT.db.isShown) end)

	ProfileMenu.Exchange = CreateFrame("Frame", nil, _G.PlayerTalentFrameTalents)
	ProfileMenu.Exchange:SetSize(32, 32)
	ProfileMenu.Exchange:SetPoint('TOPLEFT', _G.PlayerTalentFrame, 20, -31)
	ProfileMenu.Exchange.Status = ProfileMenu.Exchange:CreateTexture(nil, "ARTWORK")
	ProfileMenu.Exchange.Status:SetTexture([[Interface\AddOns\ClassTactics\Media\Exchange]])
	ProfileMenu.Exchange.Status:SetAllPoints()
	ProfileMenu.Exchange:RegisterUnitEvent('UNIT_AURA', 'player')
	ProfileMenu.Exchange:RegisterEvent('ZONE_CHANGED')
	ProfileMenu.Exchange:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	ProfileMenu.Exchange:RegisterEvent('PLAYER_REGEN_DISABLED')
	ProfileMenu.Exchange:RegisterEvent('PLAYER_REGEN_ENABLED')
	ProfileMenu.Exchange:SetScript('OnEvent', CT.CanChangeTalents)

	ProfileMenu.PvPTalents = CreateFrame('Frame', 'ClassTacticsTalentPvPProfiles', _G.ClassTacticsTalentProfiles, 'BackdropTemplate')
	ProfileMenu.PvPTalents:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles, 'TOPRIGHT', 2, 0)
	ProfileMenu.PvPTalents:SetSize(250, 50)
	ProfileMenu.PvPTalents:SetShown(CT.db.isShown)

	ProfileMenu.PvPTalents.Buttons = {}
	ProfileMenu.PvPTalents.Gradients = {}
	ProfileMenu.PvPTalents.Gradients[1] = CT:AddGradientColor(ProfileMenu, 240, 2, CT.ClassColor)

	ProfileMenu.PvPTalents.Title = ProfileMenu.PvPTalents:CreateFontString(nil, 'OVERLAY')
	ProfileMenu.PvPTalents.Title:SetFont(CT.LSM:Fetch('font', 'Expressway'), 12, 'OUTLINE')
	ProfileMenu.PvPTalents.Title:SetText('PvP Profiles')
	ProfileMenu.PvPTalents.Title:SetPoint('TOP', 0, -5)
	ProfileMenu.PvPTalents.Title:SetJustifyH('CENTER')

	ProfileMenu.PvPTalents.Gradients[1]:SetPoint('TOP', ProfileMenu.PvPTalents.Title, 'BOTTOM', 0, -5)

	ProfileMenu.PvPTalents.NewButton = CreateFrame('Button', nil, ProfileMenu.PvPTalents, 'BackdropTemplate, UIPanelButtonTemplate')
	ProfileMenu.PvPTalents.NewButton:SetText('Save Talents')
	ProfileMenu.PvPTalents.NewButton:SetSize(240, 20)
	ProfileMenu.PvPTalents.NewButton:SetPoint('TOP', ProfileMenu.PvPTalents.Gradients[1], 'BOTTOM', 0, -5)
	ProfileMenu.PvPTalents.NewButton:SetScript('OnClick', function() CT:SetupTalentPopup(nil, 'PvP') end)

	CT:TalentProfiles_Update()
	CT:TalentProfiles_CheckBags()

	CT:CanChangeTalents()
end

do
	local function SpellIDPredicate(spellIDToFind, _, _, _, _, _, _, _, _, _, _, _, spellID)
		return (spellIDToFind == spellID)
	end

	function CT:FindAuraBySpellID(spellID, unit, filter, caster)
		return _G.AuraUtil.FindAura(SpellIDPredicate, unit, filter, spellID, caster);
	end
end

function CT:CanChangeTalents(event)
	local inCombat, isTrue = InCombatLockdown()

	if not inCombat then
		if IsResting() then
			isTrue = true
		end

		if not isTrue then
			for _, spellID in next, { 325012, 227563, 227041, 256231, 321923, 226241, 227564, 324029, 256230 } do
				if CT:FindAuraBySpellID(spellID, "player", "HELPFUL") then
					isTrue = true
				end
			end
		end
	end

	_G.ClassTacticsTalentProfiles.Exchange.Status:SetVertexColor(unpack(isTrue and CT.ClassColor or {1, 1, 1}))
	_G.ClassTacticsTalentProfiles.Exchange.Status:SetAlpha(isTrue and 1 or .3)

	return isTrue
end

function CT:AddGradientColor(frame, width, height, color)
	local r, g, b = unpack(color)

	local gradient = CreateFrame('Frame', nil, frame)
	gradient:SetSize(width, height)

	gradient.left = gradient:CreateTexture(nil, 'OVERLAY')
	gradient.left:SetSize(gradient:GetWidth() * 0.5, gradient:GetHeight())
	gradient.left:SetPoint('LEFT', gradient, 'CENTER')
	gradient.left:SetTexture(CT.LSM:Fetch('background', 'Solid'))
	gradient.left:SetGradientAlpha('Horizontal', r, g, b, .7, r, g, b, .35)

	gradient.right = gradient:CreateTexture(nil, 'OVERLAY')
	gradient.right:SetSize(gradient:GetWidth() * 0.5, gradient:GetHeight())
	gradient.right:SetPoint('RIGHT', gradient, 'CENTER')
	gradient.right:SetTexture(CT.LSM:Fetch('background', 'Solid'))
	gradient.right:SetGradientAlpha('Horizontal', r, g, b, .35, r, g, b, .7)

	return gradient
end

function CT:SetEasyMenuAnchor(button)
	UIDropDownMenu_SetAnchor(CT.EasyMenu, 3, 0, 'TOPLEFT', button, 'TOPRIGHT')
end

function CT:SetEasyMenu_Talents(funcSetup, name)
	CT.MenuList[1].func = function() CT:SaveTalentBuild(funcSetup, name) end
	CT.MenuList[2].func = function(_, setupType) CT:SetupTalentPopup(setupType, funcSetup, name) end
	CT.MenuList[3].func = function(_, setupType) CT:SetupTalentPopup(setupType, funcSetup, name) end

	EasyMenu(CT.MenuList, CT.EasyMenu, nil, nil, nil, 'MENU')
end

function CT:TalentProfiles_CreateLoadout()
	local Frame = CreateFrame('Frame', nil, _G.ClassTacticsTalentProfiles)
	Frame:SetSize(250, 20)
	Frame:Hide()

	for _, Button in next, { 'Load', 'Options' } do
		Frame[Button] = CreateFrame('Button', nil, Frame, 'BackdropTemplate, UIPanelButtonTemplate')
		Frame[Button]:SetSize(20, 20)
		Frame[Button]:RegisterForClicks('AnyDown')
	end

	Frame.Load:SetWidth(215)
	Frame.Load:SetPoint('LEFT', Frame, 0, 0)

	Frame.Options:SetPoint('LEFT', Frame.Load, 'RIGHT', 5, 0)

	Frame.Options.Icon = Frame.Options:CreateTexture(nil, 'ARTWORK')
	Frame.Options.Icon:SetPoint('TOPLEFT', 2, -2)
	Frame.Options.Icon:SetPoint('BOTTOMRIGHT', -2, 2)
	Frame.Options.Icon:SetTexture([[Interface\AddOns\ClassTactics\Media\Options]])

	return Frame
end

function CT:TalentProfiles_Create()
	local Frame = CT:TalentProfiles_CreateLoadout()

	Frame.Load:SetScript('OnEnter', function() CT:SetupTalentMarkers() CT:ShowTalentMarkers(Frame.Name) end)
	Frame.Load:SetScript('OnLeave', function() CT:HideTalentMarkers() end)
	Frame.Load:SetScript('OnClick', function() CT:SetTalentsByName(Frame.Name) end)
	Frame.Options:SetScript('OnClick', function(s) CT:SetEasyMenuAnchor(s) CT:SetEasyMenu_Talents(nil, Frame.Name) end)

	tinsert(_G.ClassTacticsTalentProfiles.Buttons, Frame)

	return Frame
end

function CT:PvPTalentProfiles_Create()
	local Frame = CT:TalentProfiles_CreateLoadout()
	Frame:SetParent(_G.ClassTacticsTalentProfiles.PvPTalents)

	Frame.Load:SetScript('OnClick', function() CT:SetPvPTalentsByName(Frame.Name) end)
	Frame.Options:SetScript('OnClick', function(s) CT:SetEasyMenuAnchor(s) CT:SetEasyMenu_Talents('PvP', Frame.Name) end)

	tinsert(_G.ClassTacticsTalentProfiles.PvPTalents.Buttons, Frame)

	return Frame
end

function CT:TalentProfiles_CreateExtraButton()
	local Button = CreateFrame("Button", nil, _G.PlayerTalentFrameTalents, "ActionButtonTemplate, InsecureActionButtonTemplate, BackdropTemplate")
	Button:SetSize(32, 32)
	Button:SetClampedToScreen(true)
	Button:SetAttribute("type", "item")
	Button:EnableMouse(true)
	Button:RegisterForClicks("AnyUp")
	Button:SetScript("OnEnter", function(s)
		_G.GameTooltip:SetOwner(s, "ANCHOR_BOTTOMRIGHT")
		_G.GameTooltip:SetItemByID(s.itemID)
		_G.GameTooltip:Show()
	end)
	Button:SetScript("OnLeave", _G.GameTooltip_Hide)

	tinsert(_G.ClassTacticsTalentProfiles.ExtraButtons, Button)

	return Button
end

function CT:TalentProfiles_CheckBags()
	if InCombatLockdown() then
		CT:RegisterEvent('PLAYER_REGEN_ENABLED', CT.TalentProfiles_CheckBags)
		return
	end

	local index = 1
	local level = UnitLevel('player')
	local isResting = IsResting()

	for _, itemTable in next, ExchangeTable do
		for itemID, levelTable in next, itemTable do
			local count = GetItemCount(itemID)
			if count and count > 0 and levelTable.min <= level and levelTable.max >= level then
				local Button = _G.ClassTacticsTalentProfiles.ExtraButtons[index] or CT:TalentProfiles_CreateExtraButton()
				Button:SetAttribute("item", 'item:'..itemID)
				Button.itemID = itemID
				Button.Count:SetText(count)
				Button.icon:SetTexture(GetItemIcon(itemID))
				Button.icon:SetDesaturated(isResting)
				Button:EnableMouse(not isResting)

				index = index + 1
			end
		end
	end

	for i, Button in next, _G.ClassTacticsTalentProfiles.ExtraButtons do
		Button:SetShown(i <= index)
		Button:SetPoint('LEFT', i == 1 and _G.ClassTacticsTalentProfiles.Exchange or _G.ClassTacticsTalentProfiles.ExtraButtons[i - 1], 'RIGHT', 10, 0)
	end
end

function CT:TalentProfiles_Update()
	if not _G.ClassTacticsTalentProfiles then return end

	wipe(CT.CurrentTalentProfiles)

	local activeSpecIndex = GetSpecialization()
	for name, _ in next, CT.TalentList[CT.MyClass][activeSpecIndex] do tinsert(CT.CurrentTalentProfiles, name) end

	sort(CT.CurrentTalentProfiles)

	-- Default
	local numProfiles, PreviousButton = 0
	for name in CT:OrderedPairs(CT.TalentList[CT.MyClass][activeSpecIndex]) do
		numProfiles = numProfiles + 1
		local Button = _G.ClassTacticsTalentProfiles.Buttons[numProfiles] or CT:TalentProfiles_Create()
		Button:Show()
		Button.Load:SetWidth(240)
		Button.Load:SetText(CT:IsTalentSetSelected(name) and format('%s %s', READY_CHECK_READY_TEXTURE_INLINE, name) or name)
		Button.Options:Hide()
		Button.Name = name

		if numProfiles == 1 then
			Button:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.Gradients[1], 'BOTTOMLEFT', 0, -5)
		else
			Button:SetPoint('TOPLEFT', PreviousButton, 'BOTTOMLEFT', 0, -5)
		end

		PreviousButton = Button
	end

	_G.ClassTacticsTalentProfiles.Gradients[2]:ClearAllPoints()
	_G.ClassTacticsTalentProfiles.Gradients[2]:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.Buttons[numProfiles], 'BOTTOMLEFT', 0, -5)

	-- Saved
	local index = 0
	for name in CT:OrderedPairs(CT.db.talentBuilds[CT.MyClass][activeSpecIndex]) do
		index = index + 1
		numProfiles = numProfiles + 1

		local Button = _G.ClassTacticsTalentProfiles.Buttons[numProfiles] or CT:TalentProfiles_Create()
		Button:Show()
		Button.Load:SetText(CT:IsTalentSetSelected(name) and format('%s %s', READY_CHECK_READY_TEXTURE_INLINE, name) or name)
		Button.Name = name

		if index == 1 then
			Button:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.NewButton, 'BOTTOMLEFT', 0, -5)
		else
			Button:SetPoint('TOPLEFT', PreviousButton, 'BOTTOMLEFT', 0, -5)
		end

		PreviousButton = Button
	end

	for i = numProfiles + 1, #_G.ClassTacticsTalentProfiles.Buttons do
		_G.ClassTacticsTalentProfiles.Buttons[i]:Hide()
	end

	local maxHeight = _G.PlayerTalentFrame:GetHeight()
	local minHeight = (45 + (numProfiles + 1) * 25)
	if minHeight < maxHeight then
		_G.ClassTacticsTalentProfiles:SetHeight(minHeight)
	else
		_G.ClassTacticsTalentProfiles:SetHeight(_G.PlayerTalentFrame:GetHeight())
	end

	-- PvP Saved
	local pvpIndex = 0
	for name in CT:OrderedPairs(CT.db.talentBuildsPvP[CT.MyClass][activeSpecIndex]) do
		pvpIndex = pvpIndex + 1

		local Button = _G.ClassTacticsTalentProfiles.PvPTalents.Buttons[pvpIndex] or CT:PvPTalentProfiles_Create()
		Button:Show()
		Button.Load:SetText(CT:IsPvPTalentSetSelected(name) and format('%s %s', READY_CHECK_READY_TEXTURE_INLINE, name) or name)
		Button.Name = name

		if pvpIndex == 1 then
			Button:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.PvPTalents.NewButton, 'BOTTOMLEFT', 0, -5)
		else
			Button:SetPoint('TOPLEFT', PreviousButton, 'BOTTOMLEFT', 0, -5)
		end

		PreviousButton = Button
	end

	for i = pvpIndex + 1, #_G.ClassTacticsTalentProfiles.PvPTalents.Buttons do
		_G.ClassTacticsTalentProfiles.PvPTalents.Buttons[i]:Hide()
	end

	maxHeight = _G.PlayerTalentFrame:GetHeight()
	minHeight = (45 + (pvpIndex + 1) * 25)
	if minHeight < maxHeight then
		_G.ClassTacticsTalentProfiles.PvPTalents:SetHeight(minHeight)
	else
		_G.ClassTacticsTalentProfiles.PvPTalents:SetHeight(_G.PlayerTalentFrame:GetHeight())
	end

	CT:SkinTalentManager()
end

function CT:SetupTalentMarkers()
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local button = _G.PlayerTalentFrameTalents['tier'..tier]['talent'..column]
			if not button.ClassTacticsCheck then
				button.ClassTacticsCheck = button:CreateTexture(nil, 'OVERLAY')
				button.ClassTacticsCheck:SetSize(32, 32)
				button.ClassTacticsCheck:SetPoint('CENTER', button.icon, 'LEFT')
				button.ClassTacticsCheck:SetTexture(READY_CHECK_READY_TEXTURE)
				button.ClassTacticsCheck:Hide()
			end
		end
	end
end

function CT:ShowTalentMarkers(name)
	local activeSpecIndex = GetSpecialization()

	for i = 1, 7 do
		local id = select(i, CT:GetTalentIDByString(CT.MyClass, activeSpecIndex, name))
		local talentID, _, _, _, _, _, _, row, column = CT:GetTalentInfoByID(id)
		if tonumber(id) == talentID and row and column then
			_G.PlayerTalentFrameTalents['tier'..row]['talent'..column].ClassTacticsCheck:Show()
		end
	end
end

function CT:HideTalentMarkers()
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			_G.PlayerTalentFrameTalents['tier'..tier]['talent'..column].ClassTacticsCheck:Hide()
		end
	end
end

function CT:IsTalentSetSelected(name)
	if not CT.db then return end

	local activeSpecIndex, selectedTalents = GetSpecialization(), CT:GetSelectedTalents()

	for talentSet, talentString in next, CT.TalentList[CT.MyClass][activeSpecIndex] do
		local returnString = CT:GetMaximumTalentsByString(talentString)
		if talentSet == name and (returnString and strmatch(selectedTalents, returnString)) then
			return true
		end
	end

	for talentSet, talentString in next, CT.db.talentBuilds[CT.MyClass][activeSpecIndex] do
		local returnString = CT:GetMaximumTalentsByString(talentString)
		if talentSet == name and (returnString and strmatch(selectedTalents, returnString)) then
			return true
		end
	end

	return false
end

function CT:IsPvPTalentSetSelected(name)
	local activeSpecIndex = GetSpecialization()
	local selectedTalents = CT:GetSelectedTalents()

	for talentSet, talentString in next, CT.TalentList[CT.MyClass][activeSpecIndex] do
		local returnString = CT:GetMaximumTalentsByString(talentString)
		if talentSet == name and (returnString and strmatch(selectedTalents, returnString)) then
			return true
		end
	end

	for talentSet, talentString in next, CT.db.talentBuilds[CT.MyClass][activeSpecIndex] do
		local returnString = CT:GetMaximumTalentsByString(talentString)
		if talentSet == name and (returnString and strmatch(selectedTalents, returnString)) then
			return true
		end
	end

	return false
end

function CT:SkinTalentManager()
	if CT.AddOnSkins then
		local AS = _G.AddOnSkins[1]
		AS:SkinBackdropFrame(_G.ClassTacticsTalentProfiles)
		AS:SkinBackdropFrame(_G.ClassTacticsTalentPvPProfiles)
		AS:SkinButton(_G.ClassTacticsTalentProfiles.NewButton)
		AS:SkinButton(_G.ClassTacticsTalentPvPProfiles.NewButton)
		AS:SkinButton(_G.ClassTacticsTalentProfiles.ToggleButton)

		for _, Frame in next, _G.ClassTacticsTalentProfiles.Buttons do
			for _, Button in next, { 'Load', 'Options' } do
				AS:SkinButton(Frame[Button])
			end
		end

		for _, Frame in next, _G.ClassTacticsTalentProfiles.PvPTalents.Buttons do
			for _, Button in next, { 'Load', 'Options' } do
				AS:SkinButton(Frame[Button])
			end
		end

		for _, Button in next, _G.ClassTacticsTalentProfiles.ExtraButtons do
			AS:SkinButton(Button)
			AS:SkinTexture(Button.icon)
			AS:SetInside(Button.icon)
		end
	end
end
