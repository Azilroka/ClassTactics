local CT = unpack(_G.ClassTactics)

local _G = _G
local date = date
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
local strtrim = strtrim
local next = next

local CopyTable = CopyTable
local tInvert = tInvert
local LearnPvpTalent = LearnPvpTalent
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetTalentInfo = GetTalentInfo
local GetTalentInfoByID = GetTalentInfoByID
local GetTalentTierInfo = GetTalentTierInfo
local LearnTalents = LearnTalents
local UnitLevel = UnitLevel
local InCombatLockdown = InCombatLockdown
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetMacroInfo = GetMacroInfo
local CreateMacro = CreateMacro
local GetNumBindings = GetNumBindings
local GetBinding = GetBinding
local GetCurrentBindingSet = GetCurrentBindingSet
local GetBindingKey = GetBindingKey
local SetBinding = SetBinding

local TALENT_NOT_SELECTED = TALENT_NOT_SELECTED
local MAX_TALENT_TIERS = MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS
local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS
local MAX_CHARACTER_MACROS = MAX_CHARACTER_MACROS

CT.ClassData = {
	Sorted = CopyTable(CLASS_SORT_ORDER),
	Numerical = {},
	Name = {},
}

CT.CurrentTalentTable = {}
CT.CurrentPvPTalentTable = {}

for i = 1, GetNumClasses() do
	local name, tag, id = GetClassInfo(i)
	CT.ClassData.Numerical[tag] = id
	CT.ClassData.Name[tag] = name
end

sort(CT.ClassData.Sorted)

function CT:ReturnTimeHex()
	local dateTable = date('*t')
	return format("%02x%02x%02x", (dateTable.hour / 24) * 255, (dateTable.min / 60) * 255, (dateTable.sec / 60) * 255)
end

function CT:ClearDuplicates(current)
	for optionA, valueA in pairs(current) do
		for optionB, valueB in pairs(current) do
			if valueA == valueB and optionA ~= optionB then
				current[optionB] = nil
			end
		end
	end

	return current
end

function CT:NameDuplicates(current, default)
	if type(current) ~= 'table' or type(default) ~= 'table' then return default end

	for option, value in pairs(current) do
		if option ~= 'selected' then
			if type(value) == 'table' then
				default[option] = CT:NameDuplicates(current[option], default[option])
			elseif default[option] and value ~= default[option] then
				default[format('%s %s', option, CT:ReturnTimeHex())] = default[option]
				default[option] = nil
			end
		end
	end

	return default
end

function CT:CopyTable(current, default)
	if type(current) ~= 'table' then
		current = {}
	end

	if type(default) == 'table' then
		default = CT:ClearDuplicates(default)
		default = CT:NameDuplicates(current, default)

		for option, value in pairs(default) do
			current[option] = (type(value) == 'table' and CT:CopyTable(current[option], value)) or value
		end
	end

	return current
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

	local decodedData = CT.Libs.Base64:Decode(dataString)
	local decompressedData = CT.Libs.Compress:Decompress(decodedData)

	if not decompressedData then
		return
	end

	local serializedData, nameKey = CT:SplitString(decompressedData, '^^;;') -- '^^' indicates the end of the AceSerializer string
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

	local data = type(db[name]) == 'table' and CT:CopyTable({}, db[name]) or db[name]

	if not data then
		return
	end

	local serialData = CT:Serialize(data)
	local exportString = format(dbKey and '%s;;%s\a%s' or '%s;;%s', serialData, name, dbKey)
	local compressedData = CT.Libs.Compress:Compress(exportString)
	local encodedData = CT.Libs.Base64:Encode(compressedData)

	return encodedData
end

function CT:ExportDataFromString(name, dataType, dataInfo)
	if not name or type(name) ~= 'string' then
		return
	end

	local data = type(dataInfo) == 'table' and CT:CopyTable({}, dataInfo) or dataInfo

	if not data then
		return
	end

	local serialData = CT:Serialize(data)
	local exportString = format(dataType and '%s;;%s\a%s' or '%s;;%s', serialData, name, dataType)
	local compressedData = CT.Libs.Compress:Compress(exportString)
	local encodedData = CT.Libs.Base64:Encode(compressedData)

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

	db[name] = type(data) == 'table' and CT:CopyTable(db[name], data) or data
end

-- Talents
function CT:GetTalentIDByString(classTag, specGroup, name)
	local defaultString = CT.RetailData[classTag] and CT.RetailData[classTag][specGroup] and CT.RetailData[classTag][specGroup].Talents[name]
	local customString = CT.db.talentBuilds[classTag] and CT.db.talentBuilds[classTag][specGroup] and CT.db.talentBuilds[classTag][specGroup][name]

	local talentString = customString or defaultString

	if talentString then
		return strsplit(',', talentString)
	else
		return nil
	end
end

function CT:SetTalentsByName(classTag, specGroup, name)
	classTag = classTag or CT.MyClass
	specGroup = specGroup or GetSpecialization()

	CT.db.talentBuilds[classTag][specGroup].selected = name
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

	local noneSelected = true
	for tier = 1, MAX_TALENT_TIERS do
		CT.CurrentTalentTable[tier] = 0
		for column = 1, NUM_TALENT_COLUMNS do
			local talentID, _, _, selected = GetTalentInfo(tier, column, GetActiveSpecGroup())
			if selected then
				noneSelected = false
				CT.CurrentTalentTable[tier] = talentID
			end
		end
	end

	return noneSelected and '' or table.concat(CT.CurrentTalentTable, ',')
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

	local compareString = next(compareTable) and table.concat(compareTable, ',')

	return compareString and strmatch(talentString, compareString)
end

function CT:AddDefaultBuild(classTag, specGroup, selected)
	if classTag == CT.MyClass and specGroup == GetSpecialization() then
		CT.db.talentBuilds[classTag][specGroup][selected] = CT.RetailData[classTag][specGroup].Talents[selected]
	end
end

function CT:CanAddDefaultBuild(classTag, specGroup, selected)
	if classTag == CT.MyClass and specGroup == GetSpecialization() and CT.RetailData[classTag][specGroup].Talents[selected] then
		return true
	end
	return false
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

function CT:SetPvPTalentsByName(classTag, specGroup, name)
	local savedPvPTalents = tInvert({ CT:GetPvPTalentIDByString(classTag or CT.MyClass, specGroup or GetSpecialization(), name) })

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
local talentTierLevels = {}
local autoTalentWait = false

function CT:AutoTalent()
	if not next(talentTierLevels) then
		for tier = 1, 7 do
			local _, _, tierUnlockLevel = GetTalentTierInfo(tier, GetActiveSpecGroup())
			talentTierLevels[tierUnlockLevel] = tier
		end
	end

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

-- Macros
function CT:GetAccountMacros()
	local macroTable = {}

	for i = 1, MAX_ACCOUNT_MACROS do
		local name, icon, body = GetMacroInfo(i)
		if name then
			macroTable[name] = name
		end
	end

	return macroTable
end

function CT:GetCharacterMacros()
	local macroTable = {}

	for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
		local name, icon, body = GetMacroInfo(i)
		if name then
			macroTable[name] = name
		end
	end

	return macroTable
end

function CT:GetImportedMacros()
	local macroTable = {}

	for name in pairs(CT.db.macros) do
		macroTable[name] = name
	end

	return macroTable
end

function CT:GetMacroInfo(macroName)
	local name, icon, body = GetMacroInfo(macroName)

	if not name and CT.db.macros[macroName] then
		name, icon, body = macroName, CT.db.macros[macroName].icon, CT.db.macros[macroName].text
	end

	body = body and strtrim(body)

	return name, icon, body
end

function CT:SetupMacroPopup(macroName, perCharacter, defaultMacro)
	local Dialog = _G.StaticPopupDialogs.CLASSTACTICS
	Dialog.text = 'Enter a Name:'
	Dialog.button1 = 'Create'
	Dialog.hasEditBox = 1
	Dialog.EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end

	if defaultMacro then
		Dialog.OnAccept = function(s) CT:AddDefaultMacro(macroName, s.editBox:GetText(), perCharacter) end
		Dialog.EditBoxOnEnterPressed = function(s) CT:AddDefaultMacro(macroName, s:GetText(), perCharacter) s:GetParent():Hide() end
	else
		Dialog.OnAccept = function(s) CT:CreateMacro(macroName, s.editBox:GetText(), perCharacter) end
		Dialog.EditBoxOnEnterPressed = function(s) CT:CreateMacro(macroName, s:GetText(), perCharacter) s:GetParent():Hide() end
	end

	_G.StaticPopup_Show('CLASSTACTICS')
end

function CT:CreateMacro(macroName, newName, perCharacter)
	local data = CT.db.macros[macroName]
	CreateMacro(newName, data.icon, data.text, perCharacter)
end

function CT:DeleteImportedMacro(macroName)
	CT.db.macros[macroName] = nil
end

function CT:AddDefaultMacro(macroName, newName, perCharacter)
	local text = CT.RetailData[CT.MyClass][GetSpecialization()].Macros[macroName]
	CreateMacro(newName, "INV_MISC_QUESTIONMARK", text, perCharacter)
end

function CT:CanAddDefaultMacro(classTag, specGroup, selected)
	if classTag == CT.MyClass and specGroup == GetSpecialization() and CT.RetailData[classTag][specGroup].Macros[selected] then
		return true
	end
	return false
end

-- Keybinds
function CT:SaveKeybinds()
	for i = 1, GetNumBindings() do
		local commandName = GetBinding(i, GetCurrentBindingSet())
		local keys = { GetBindingKey(commandName) }
		if next(keys) then
			for _, binding in next, keys do
			end
		end
	end
end
