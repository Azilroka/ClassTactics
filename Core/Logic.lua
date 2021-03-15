local CT = unpack(_G.ClassTactics)

local tonumber = tonumber
local select = select
local strsplit = strsplit
local wipe = wipe
local gsub = gsub

local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetTalentInfo = GetTalentInfo
local GetTalentInfoByID = GetTalentInfoByID
local LearnTalents = LearnTalents
local UnitLevel = UnitLevel

local TALENT_NOT_SELECTED = TALENT_NOT_SELECTED
local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS

CT.MacroList = {}
CT.TalentList = {}
CT.DiscordList = {}
CT.GuideList = {}

for i = 1, GetNumClasses() do
	local _, classTag = GetClassInfo(i)
	CT.TalentList[classTag] = {}
	CT.MacroList[classTag] = {}
end

function CT:GetTalentIDByString(classTag, specGroup, name)
	local defaultString = CT.TalentList[classTag] and CT.TalentList[classTag][specGroup] and CT.TalentList[classTag][specGroup][name]
	local customString = CT.db.talentBuilds[classTag] and CT.db.talentBuilds[classTag][specGroup] and CT.db.talentBuilds[classTag][specGroup][name]

	local talentString = customString or defaultString

	local talent1, talent2, talent3, talent4, talent5, talent6, talent7 = strsplit(",", talentString or "")
	return tonumber(talent1), tonumber(talent2), tonumber(talent3), tonumber(talent4), tonumber(talent5), tonumber(talent6), tonumber(talent7)
end

function CT:SetTalentsByName(name)
	LearnTalents(CT:GetTalentIDByString(CT.MyClass, GetSpecialization(), name))
end

function CT:ApplyTalents(classTag, specGroup, name)
	LearnTalents(CT:GetTalentIDByString(classTag, specGroup, name))
end

function CT:GetTalentInfoByID(id)
	local talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura = 0, TALENT_NOT_SELECTED, 136243
	if id then
		talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura = GetTalentInfoByID(id)
	end
	return talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura
end

CT.CurrentTalentTable = {}

function CT:GetSelectedTalents()
	wipe(CT.CurrentTalentTable)

	for tier = 1, MAX_TALENT_TIERS do
		CT.CurrentTalentTable[tier] = 0
		for column = 1, NUM_TALENT_COLUMNS do
			local talentID, name, texture, selected, available = GetTalentInfo(tier, column, GetActiveSpecGroup())
			if selected then
				CT.CurrentTalentTable[tier] = talentID
			end
		end
	end

	local talentString = table.concat(CT.CurrentTalentTable, ",")
	return talentString
end

local talentTierLevels = { [15] = 1, [25] = 2, [30] = 3, [35] = 4, [40] = 5, [45] = 6, [50] = 7 }
local autoTalentWait = false

function CT:AutoTalent()
	local playerLevel = UnitLevel('player')
	local activeSpecIndex = GetSpecialization()
	local specProfile = CT.db.autoTalents[CT.MyRealm][CT.MyName][activeSpecIndex]

	if CT.db.autoTalent and talentTierLevels[playerLevel] then
		local talent = select(talentTierLevels[playerLevel], CT:GetTalentIDByString(CT.MyClass, activeSpecIndex, specProfile))
		if talent then LearnTalents(talent) end
	end

	autoTalentWait = false
end

function CT:DelayAutoTalent()
	if InCombatLockdown() then
		CT:RegisterEvent('PLAYER_REGEN_ENABLED', 'DelayAutoTalent')
		return
	end

	CT:UnregisterEvent('PLAYER_REGEN_ENABLED')
	if not autoTalentWait then
		_G.C_Timer.After(.5, CT.AutoTalent)
		autoTalentWait = true
	end
end
