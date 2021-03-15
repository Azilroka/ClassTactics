local CT = unpack(_G.ClassTactics)

local _G = _G

local unpack = unpack
local tinsert = tinsert
local next = next
local wipe = wipe
local select = select
local sort = sort

local CreateFrame = CreateFrame
local GetSpecialization = GetSpecialization

local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS
local READY_CHECK_READY_TEXTURE = READY_CHECK_READY_TEXTURE

CT.CurrentTalentProfiles = {}

_G.StaticPopupDialogs.CLASSTACTICS_TALENTPROFILE = {
	button2 = 'Cancel',
	timeout = 0,
	whileDead = 1,
	enterClicksFirstButton = 1,
}

function CT:OrderedPairs(t, f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
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

function CT:SetupTalentPopup(setupType, name)
	local Dialog = _G.StaticPopupDialogs.CLASSTACTICS_TALENTPROFILE
	Dialog.text = 'Enter a Name:'
	Dialog.button1 = 'Create'
	Dialog.hasEditBox = 1
	Dialog.OnAccept = function(s) CT:SaveTalentBuild(s.editBox:GetText()) end
	Dialog.EditBoxOnEnterPressed = function(s) CT:SaveTalentBuild(s:GetText()) s:GetParent():Hide() end
	Dialog.EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end

	if setupType == 'delete' then
		Dialog.hasEditBox = nil
		Dialog.button1 = 'Delete'
		Dialog.text = format('Are you sure you want to delete %s?', name)
		Dialog.OnAccept = function()
			CT.db.talentBuilds[CT.MyClass][GetSpecialization()][name] = nil
			CT:UpdateOptions()
			CT:TalentProfiles_Update()
		end
	elseif setupType == 'rename' then
		Dialog.button1 = 'Update'
		Dialog.OnAccept = function(s)
			CT.db.talentBuilds[CT.MyClass][GetSpecialization()][name] = nil
			CT:SaveTalentBuild(s.editBox:GetText())
			CT:UpdateOptions()
			CT:TalentProfiles_Update()
		end
		Dialog.EditBoxOnEnterPressed = function(s)
			CT.db.talentBuilds[CT.MyClass][GetSpecialization()][name] = nil
			CT:SaveTalentBuild(s:GetText())
			CT:UpdateOptions()
			CT:TalentProfiles_Update()
			s:GetParent():Hide()
		end
	elseif setupType == 'overwrite' then
		Dialog.hasEditBox = nil
		Dialog.text = format('There is already a profile named %s. Do you want to overwrite it?', name)
		Dialog.OnAccept = function() CT:SaveTalentBuild(name) end
		Dialog.button1 = 'Update'
	end

	_G.StaticPopup_Show('CLASSTACTICS_TALENTPROFILE')
end

function CT:SaveTalentBuild(text)
	local activeSpecIndex = GetSpecialization()
	CT.db.talentBuilds[CT.MyClass][activeSpecIndex][text] = CT:GetSelectedTalents()

	CT:TalentProfiles_Update()
	CT:UpdateOptions()
end

function CT:TalentProfiles()
	local ProfileMenu = CreateFrame('Frame', 'ClassTacticsTalentProfiles', _G.PlayerTalentFrameTalents, 'BackdropTemplate')
	ProfileMenu:SetPoint('TOPLEFT', _G.PlayerTalentFrame, 'TOPRIGHT', 2, 0)
	ProfileMenu:SetSize(250, 50)
	ProfileMenu:SetShown(CT.db.isShown)

	ProfileMenu.Buttons = {}
	ProfileMenu.Gradients = {}

	ProfileMenu.Gradients[1] = CT:AddGradientColor(ProfileMenu, 240, 5, { 1, 1, 0 })
	ProfileMenu.Gradients[2] = CT:AddGradientColor(ProfileMenu, 240, 5, { 1, 1, 0 })

	ProfileMenu.Title = ProfileMenu:CreateFontString(nil, 'OVERLAY')
	ProfileMenu.Title:SetFont(CT.LSM:Fetch('font', 'Arial'), 12, 'OUTLINE')
	ProfileMenu.Title:SetText('Talent Profiles')
	ProfileMenu.Title:SetPoint('TOP', 0, -5)
	ProfileMenu.Title:SetJustifyH('CENTER')

	ProfileMenu.Gradients[1]:SetPoint('TOP', ProfileMenu.Title, 'BOTTOM', 0, -5)

	ProfileMenu.NewButton = CreateFrame('Button', nil, ProfileMenu, 'BackdropTemplate, UIPanelButtonTemplate')
	ProfileMenu.NewButton:SetText('New Talent Build')
	ProfileMenu.NewButton:SetSize(240, 20)
	ProfileMenu.NewButton:SetPoint('TOP', ProfileMenu.Gradients[2], 'BOTTOM', 0, -5)
	ProfileMenu.NewButton:SetScript('OnClick', function() CT:SetupTalentPopup() end)

	ProfileMenu.ToggleButton = CreateFrame('Button', 'ClassTacticsTalentManagerToggleButton', _G.PlayerTalentFrameTalents, 'BackdropTemplate, UIPanelButtonTemplate')
	ProfileMenu.ToggleButton:Point('BOTTOMRIGHT', _G.PlayerTalentFrameTalents, 'BOTTOMRIGHT', -5, -20)
	ProfileMenu.ToggleButton:SetText('Toggle Talent Manager')
	ProfileMenu.ToggleButton:SetSize(ProfileMenu.ToggleButton.Text:GetStringWidth() + 20, 25)
	ProfileMenu.ToggleButton:SetScript('OnClick', function() CT.db.isShown = not CT.db.isShown ProfileMenu:SetShown(CT.db.isShown) end)

	CT:SkinTalentManager()
	CT:TalentProfiles_Update()
end

function CT:AddGradientColor(frame, width, height, color)
	local r, g, b = unpack(color)

	local gradient = CreateFrame('Frame', nil, frame)
	gradient:SetSize(width, height)

	local leftGrad = gradient:CreateTexture(nil, 'OVERLAY')
	leftGrad:SetSize(gradient:GetWidth() * 0.5, gradient:GetHeight())
	leftGrad:SetPoint('LEFT', gradient, 'CENTER')
	leftGrad:SetTexture(CT.LSM:Fetch('background', 'Solid'))
	leftGrad:SetGradientAlpha('Horizontal', r, g, b, 0.35, r, g, b, 0)

	local rightGrad = gradient:CreateTexture(nil, 'OVERLAY')
	rightGrad:SetSize(gradient:GetWidth() * 0.5, gradient:GetHeight())
	rightGrad:SetPoint('RIGHT', gradient, 'CENTER')
	rightGrad:SetTexture(CT.LSM:Fetch('background', 'Solid'))
	rightGrad:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.35)

	return gradient
end

function CT:TalentProfiles_Create()
	local Frame = CreateFrame('Frame', nil, _G.ClassTacticsTalentProfiles)
	Frame:SetSize(250, 20)
	Frame:Hide()

	for _, Button in next, {'Load', 'Delete', 'Update'} do
		Frame[Button] = CreateFrame('Button', nil, Frame, 'BackdropTemplate, UIPanelButtonTemplate')
		Frame[Button]:SetSize(20, 20)
		Frame[Button]:RegisterForClicks('AnyDown')
		Frame[Button]:StripTextures(true)
		Frame[Button]:SetTemplate()
	end

	Frame.Load:SetWidth(190)
	Frame.Load:SetPoint('LEFT', Frame, 0, 0)
	Frame.Load:SetText('Load')

	Frame.Load:SetScript('OnEnter', function() CT:SetupTalentMarkers() CT:ShowTalentMarkers(Frame.Name) end)
	Frame.Load:SetScript('OnLeave', function() CT:HideTalentMarkers() end)
	Frame.Load:SetScript('OnClick', function(_, btn)
		if btn == 'RightButton' then
			CT:SetupTalentPopup('rename', Frame.Name)
		else
			CT:SetTalentsByName(Frame.Name)
		end
	end)

	Frame.Update.Icon = Frame.Update:CreateTexture(nil, 'ARTWORK')
	Frame.Update.Icon:SetAllPoints()
	Frame.Update.Icon:SetTexture([[Interface\AddOns\ClassTactics\Media\Update]])
	Frame.Update:SetPoint('LEFT', Frame.Load, 'RIGHT', 5, 0)
	Frame.Update:SetScript('OnClick', function(_, btn) CT:SetupTalentPopup('overwrite', Frame.Name) end)

	Frame.Delete.Icon = Frame.Delete:CreateTexture(nil, 'ARTWORK')
	Frame.Delete.Icon:SetAllPoints()
	Frame.Delete.Icon:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
	Frame.Delete:SetPoint('LEFT', Frame.Update, 'RIGHT', 5, 0)
	Frame.Delete:SetScript('OnClick', function() CT:SetupTalentPopup('delete', Frame.Name) end)

	tinsert(_G.ClassTacticsTalentProfiles.Buttons, Frame)

	return Frame
end

function CT:TalentProfiles_Update()
	if not _G.ClassTacticsTalentProfiles then return end

	wipe(CT.CurrentTalentProfiles)

	local activeSpecIndex = GetSpecialization()
	for name, _ in pairs(CT.TalentList[CT.MyClass][activeSpecIndex]) do tinsert(CT.CurrentTalentProfiles, name) end

	sort(CT.CurrentTalentProfiles)

	-- Default
	local numProfiles, PreviousButton = 0
	for name in CT:OrderedPairs(CT.TalentList[CT.MyClass][activeSpecIndex]) do
		numProfiles = numProfiles + 1
		local Button = _G.ClassTacticsTalentProfiles.Buttons[numProfiles] or CT:TalentProfiles_Create()
		Button:Show()
		Button.Load:SetWidth(240)
		Button.Load:SetText(name)
		Button.Update:Hide()
		Button.Delete:Hide()
		Button.Name = name

		if numProfiles == 1 then
			Button:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.Gradients[1], 'BOTTOMLEFT', 0, -5)
		else
			Button:SetPoint('TOPLEFT', PreviousButton, 'BOTTOMLEFT', 0, -5)
		end

		PreviousButton = Button
	end

	for i = numProfiles + 1, #_G.ClassTacticsTalentProfiles.Buttons do
		_G.ClassTacticsTalentProfiles.Buttons[i]:Hide()
	end

	_G.ClassTacticsTalentProfiles.Gradients[2]:ClearAllPoints()
	_G.ClassTacticsTalentProfiles.Gradients[2]:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.Buttons[numProfiles], 'BOTTOMLEFT', 0, -5)

	-- Saved
	local index = 1
	for name in CT:OrderedPairs(CT.db.talentBuilds[CT.MyClass][activeSpecIndex]) do
		numProfiles = numProfiles + 1
		local Button = _G.ClassTacticsTalentProfiles.Buttons[numProfiles] or CT:TalentProfiles_Create()
		Button:Show()
		Button.Load:SetText(name)
		Button.Name = name

		if index == 1 then
			Button:SetPoint('TOPLEFT', _G.ClassTacticsTalentProfiles.NewButton, 'BOTTOMLEFT', 0, -5)
		else
			Button:SetPoint('TOPLEFT', PreviousButton, 'BOTTOMLEFT', 0, -5)
		end

		PreviousButton = Button
		index = index + 1
	end

	for i = numProfiles + 1, #_G.ClassTacticsTalentProfiles.Buttons do
		_G.ClassTacticsTalentProfiles.Buttons[i]:Hide()
	end

	local maxHeight = _G.PlayerTalentFrame:GetHeight()
	local minHeight = (50 + (numProfiles + 1) * 25)
	if minHeight < maxHeight then
		_G.ClassTacticsTalentProfiles:SetHeight(minHeight)
	else
		_G.ClassTacticsTalentProfiles:SetHeight(_G.PlayerTalentFrame:GetHeight())
	end
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
		if id == talentID and row and column then
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

function CT:SkinTalentManager()
	if _G.ClassTacticsTalentProfiles.SetBackdrop and _G.ClassTacticsTalentProfiles.SetTemplate then
		_G.ClassTacticsTalentProfiles:StripTextures()
		_G.ClassTacticsTalentProfiles:SetTemplate('Transparent')

		_G.ClassTacticsTalentProfiles.NewButton:StripTextures(true)
		_G.ClassTacticsTalentProfiles.NewButton:SetTemplate()

		_G.ClassTacticsTalentProfiles.ToggleButton:StripTextures(true)
		_G.ClassTacticsTalentProfiles.ToggleButton:SetTemplate()
	end
end
