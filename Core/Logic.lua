local CT = unpack(_G.ClassTactics)

local _G = _G
local tonumber = tonumber
local select = select
local strsplit = strsplit
local wipe = wipe
local assert = assert
local type = type
local strlen = strlen
local strfind = strfind
local tinsert = tinsert
local strsub = strsub
local unpack = unpack
local format = format
local strmatch = strmatch
local next = next

local CopyTable = CopyTable
local tInvert = tInvert
local LearnPvpTalent = LearnPvpTalent
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetTalentInfo = GetTalentInfo
local GetTalentInfoByID = GetTalentInfoByID
local LearnTalents = LearnTalents
local UnitLevel = UnitLevel
local InCombatLockdown = InCombatLockdown
local GetPvpTalentInfoByID = GetPvpTalentInfoByID

local TALENT_NOT_SELECTED = TALENT_NOT_SELECTED
local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS

CT.MacroList = {}
CT.TalentList = {}
CT.DiscordList = {}
CT.GuideList = {}

CT.CurrentTalentTable = {}
CT.CurrentPvPTalentTable = {}

for i = 1, GetNumClasses() do
	local _, classTag = GetClassInfo(i)
	CT.TalentList[classTag] = {}
	CT.MacroList[classTag] = {}
	CT.GuideList[classTag] = {}
end

do	--Split string by multi-character delimiter (the strsplit / string.split function provided by WoW doesn't allow multi-character delimiter)
	local splitTable = {}
	function CT:SplitString(str, delim)
		assert(type (delim) == 'string' and strlen(delim) > 0, 'bad delimiter')

		local start = 1
		wipe(splitTable)

		while true do
			local pos = strfind(str, delim, start, true)
			if not pos then break end

			tinsert(splitTable, strsub(str, start, pos - 1))
			start = pos + strlen(delim)
		end

		tinsert(splitTable, strsub(str, start))

		return unpack(splitTable)
	end
end

function CT:DecodeData(dataString)
	if not dataString then
		return
	end

	local decodedData = CT.Base64:Decode(dataString)
	local decompressedData = CT.Compress:Decompress(decodedData)

	if not decompressedData then
		return
	end

	local serializedData, nameKey = CT:SplitString(decompressedData, '^^::') -- '^^' indicates the end of the AceSerializer string
	local name, dbKey = strsplit('\a', nameKey, 2)
	serializedData = format('%s%s', serializedData, '^^') --Add back the AceSerializer terminator
	local success, data = CT:Deserialize(serializedData)

	if not success then
		return
	end

	return name, data, dbKey
end

function CT:ExportData(name, dbKey)
	if not name or type(name) ~= 'string' then
		return
	end

	local db = CT.db

	if dbKey then
		for _, v in next, { strsplit('\a', dbKey) } do
			db = db[tonumber(v) or v]
		end
	end

	local data = type(db[name]) == 'table' and CopyTable(db[name]) or db[name]

	if not data then
		return
	end

	local serialData = CT:Serialize(data)
	local exportString = format('%s::%s\a%s', serialData, name, dbKey)
	local compressedData = CT.Compress:Compress(exportString)
	local encodedData = CT.Base64:Encode(compressedData)

	return encodedData
end

function CT:ImportData(dataString)
	local name, data, dbKey = CT:DecodeData(dataString)

	if not data then
		return
	end

	local db = CT.db

	if dbKey then
		for _, v in next, { strsplit('\a', dbKey) } do
			db = db[tonumber(v) or v]
			if not db then db = {} end
		end
	end

	db[name] = type(data) == 'table' and CopyTable(data) or data
end

-- Talents
function CT:GetTalentIDByString(classTag, specGroup, name)
	local defaultString = CT.TalentList[classTag] and CT.TalentList[classTag][specGroup] and CT.TalentList[classTag][specGroup][name]
	local customString = CT.db.talentBuilds[classTag] and CT.db.talentBuilds[classTag][specGroup] and CT.db.talentBuilds[classTag][specGroup][name]

	local talentString = customString or defaultString

	if talentString then
		return strsplit(',', talentString)
	else
		return nil
	end
end

function CT:SetTalentsByName(name)
	LearnTalents(CT:GetTalentIDByString(CT.MyClass, GetSpecialization(), name))
end

function CT:ApplyTalents(classTag, specGroup, name)
	LearnTalents(CT:GetTalentIDByString(classTag, specGroup, name))
end

function CT:GetTalentInfoByID(id)
	id = tonumber(id)
	local talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura = 0, TALENT_NOT_SELECTED, 136243

	if id and id > 0 then
		talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura = GetTalentInfoByID(id)
	end

	return talentID, name, texture, selected, available, spellID, _, row, column, known, grantedByAura
end

function CT:GetSelectedTalents()
	wipe(CT.CurrentTalentTable)

	for tier = 1, MAX_TALENT_TIERS do
		CT.CurrentTalentTable[tier] = 0
		for column = 1, NUM_TALENT_COLUMNS do
			local talentID, _, _, selected = GetTalentInfo(tier, column, GetActiveSpecGroup())
			if selected then
				CT.CurrentTalentTable[tier] = talentID
			end
		end
	end

	return table.concat(CT.CurrentTalentTable, ',')
end

local compareTable = {}

function CT:GetMaximumTalentsByString(talentString)
	wipe(compareTable)
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local talentID, _, _, selected = GetTalentInfo(tier, column, GetActiveSpecGroup())
			if not compareTable[tier] and selected then
				compareTable[tier] = talentID
			end
		end
	end

	local compareString = table.concat(compareTable, ',')

	return strmatch(talentString, compareString)
end

-- PvP Talents
function CT:GetPvPTalentIDByString(classTag, specGroup, name)
	local talentString = CT.db.talentBuildsPvP[classTag] and CT.db.talentBuildsPvP[classTag][specGroup] and CT.db.talentBuildsPvP[classTag][specGroup][name]

	if talentString then
		return strsplit(',', talentString)
	else
		return nil
	end
end

function CT:GetSelectedPvPTalents()
	CT.CurrentPvPTalentTable = _G.C_SpecializationInfo.GetAllSelectedPvpTalentIDs()

	return table.concat(CT.CurrentPvPTalentTable, ',')
end

function CT:SetPvPTalentsByName(name)
	local savedPvPTalents = tInvert({ CT:GetPvPTalentIDByString(CT.MyClass, GetSpecialization(), name) })

	for talentID, index in next, savedPvPTalents do
		LearnPvpTalent(talentID, index)
	end
end

function CT:ApplyPvPTalents(classTag, specGroup, name)
	local savedPvPTalents =  tInvert({ CT:GetPvPTalentIDByString(classTag, specGroup, name) })

	for talentID, index in next, savedPvPTalents do
		LearnPvpTalent(talentID, index)
	end
end

function CT:GetPvPTalentInfoByID(id)
	id = tonumber(id)
	local talentID, name, icon, selected, available, spellID, unlocked = 0, TALENT_NOT_SELECTED, 136243

	if id and id > 0 then
		talentID, name, icon, selected, available, spellID, unlocked = GetPvpTalentInfoByID(id)
	end

	return talentID, name, icon, selected, available, spellID, unlocked
end

-- Auto Talent
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
