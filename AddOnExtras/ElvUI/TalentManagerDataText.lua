if not _G.ElvUI then return end

local E = unpack(_G.ElvUI)
local CT = unpack(_G.ClassTactics)
local DT = E:GetModule('DataTexts')

local _G = _G
local next = next

local menuList = {}

local specIndex

local function OnEvent(self)
	specIndex = GetSpecialization()
end

local function OnUpdate(self, t)
	self.timeElapsed = (self.timeElapsed or 1) - t
	if self.timeElapsed > 0 then return end
	self.timeElapsed = 1

	local selectedTalentSet

	if specIndex and CT.db then
		for talentName in next, CT.TalentList[E.myclass][specIndex] do
			if CT:IsTalentSetSelected(talentName) then
				selectedTalentSet = talentName
				break
			end
		end

		if not selectedTalentSet then
			for talentName in next, CT.db.talentBuilds[E.myclass][specIndex] do
				if CT:IsTalentSetSelected(talentName) then
					selectedTalentSet = talentName
					break
				end
			end
		end
	end

	self.text:SetText(selectedTalentSet or 'Talent Manager')
end

local function OnClick(self)
	if not specIndex then return end

	DT:SetEasyMenuAnchor(DT.EasyMenu, self)

	local index = 1

	for talentName in next, CT.TalentList[E.myclass][specIndex] do
		menuList[index] = menuList[index] or {}
		menuList[index].text = talentName
		menuList[index].func = function(_, name) CT:SetTalentsByName(name) end
		menuList[index].checked = function() return CT:IsTalentSetSelected(talentName) end
		menuList[index].arg1 = talentName

		index = index + 1
	end

	for talentName in next, CT.db.talentBuilds[E.myclass][specIndex] do
		menuList[index] = menuList[index] or {}
		menuList[index].text = talentName
		menuList[index].func = function(_, name) CT:SetTalentsByName(name) end
		menuList[index].checked = function() return CT:IsTalentSetSelected(talentName) end
		menuList[index].arg1 = talentName

		index = index + 1
	end

	for i = index + 1, #menuList do
		menuList[i] = nil
	end

	_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, 'MENU')
end

DT:RegisterDatatext('ClassTactics Talent Manager', 'ClassTactics', { 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED' }, OnEvent, OnUpdate, OnClick, nil, nil, "Talent Manager")
