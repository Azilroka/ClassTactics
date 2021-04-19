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
local sort = sort
local min = min

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
local GetActionInfo = GetActionInfo
local GetActionTexture = GetActionTexture
local GetActionText = GetActionText
local FindBaseSpellByID = FindBaseSpellByID
local PickupAction = PickupAction
local ClearCursor = ClearCursor
local GetMacroIndexByName = GetMacroIndexByName
local GetNumMacros = GetNumMacros
local PickupMacro = PickupMacro
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellTabInfo = GetSpellTabInfo
local GetSpellBookItemInfo = GetSpellBookItemInfo
local PickupSpellBookItem = PickupSpellBookItem
local PickupPvpTalent = PickupPvpTalent
local GetCursorInfo = GetCursorInfo
local IsSpellKnown = IsSpellKnown
local PickupPetSpell = PickupPetSpell
local PickupSpell = PickupSpell
local PickupItem = PickupItem
local PlaceAction = PlaceAction

local SaveBindings = SaveBindings or AttemptToSaveBindings

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
	return format('%02x%02x%02x', (dateTable.hour / 24) * 255, (dateTable.min / 60) * 255, (dateTable.sec / 60) * 255)
end

function CT:ClearDuplicates(current)
	for optionA, valueA in next, current do
		for optionB, valueB in next, current do
			if valueA == valueB and optionA ~= optionB then
				current[optionB] = nil
			end
		end
	end

	return current
end

function CT:NameDuplicates(current, default)
	if type(current) ~= 'table' or type(default) ~= 'table' then return default end

	for option, value in next, current do
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

		for option, value in next, default do
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

	local compareString = compareTable[1] and table.concat(compareTable, ',') or ''
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

--[[  -- Classic / TBC
	MAX_TALENT_TABS = 5;
	MAX_NUM_TALENTS = 40;
	MAX_NUM_TALENT_TIERS = 10;
	NUM_TALENT_COLUMNS = 4;

	for i = 1, MAX_NUM_TALENTS do
		local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), i);
	end
]]

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
local autoTalentWait, talentTierLevels = false, {}

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
local accountMacroTable, characterMacroTable, importedMacroTable = {}, {}, {}

function CT:GetAccountMacros()
	wipe(accountMacroTable)

	for i = 1, MAX_ACCOUNT_MACROS do
		local name = GetMacroInfo(i)
		if name then
			accountMacroTable[name] = name
		end
	end

	return accountMacroTable
end

function CT:GetCharacterMacros()
	wipe(characterMacroTable)

	for i = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
		local name = GetMacroInfo(i)
		if name then
			characterMacroTable[name] = name
		end
	end

	return characterMacroTable
end

function CT:GetImportedMacros()
	wipe(importedMacroTable)

	for name in next, CT.db.macros do
		importedMacroTable[name] = name
	end

	return importedMacroTable
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
	CreateMacro(newName, 'INV_MISC_QUESTIONMARK', text, perCharacter)
end

function CT:CanAddDefaultMacro(classTag, specGroup, selected)
	if classTag == CT.MyClass and specGroup == GetSpecialization() and CT.RetailData[classTag][specGroup].Macros[selected] then
		return true
	end
	return false
end

-- Keybinds
local keybindsTable = {}

function CT:SetupKeybindPopup()
	local Dialog = _G.StaticPopupDialogs.CLASSTACTICS
	Dialog.text = 'Enter a Name:'
	Dialog.button1 = 'Create'
	Dialog.hasEditBox = 1
	Dialog.EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end
	Dialog.OnAccept = function(s) CT:SaveKeybinds(s.editBox:GetText()) end
	Dialog.EditBoxOnEnterPressed = function(s) CT:SaveKeybinds(s:GetText()) s:GetParent():Hide() end

	_G.StaticPopup_Show('CLASSTACTICS')
end

function CT:GetKeybinds()
	wipe(keybindsTable)

	for bindSetName in next, CT.db.keybinds do
		keybindsTable[bindSetName] = bindSetName
	end

	if not next(keybindsTable) then
		keybindsTable.NONE = 'None'
	end

	return keybindsTable
end

function CT:SaveKeybinds(bindSetName)
	for i = 1, GetNumBindings() do
		local commandName = GetBinding(i, GetCurrentBindingSet())
		local keys = { GetBindingKey(commandName) }

		CT.db.keybinds[bindSetName] = CT.db.keybinds[bindSetName] or {}
		CT.db.keybinds[bindSetName][commandName] = keys
	end

	CT.OptionsData.Keybind.SelectedSet = bindSetName

	if _G.ElvUI then
		_G.ElvUI[1].Libs.AceConfigRegistry:NotifyChange('ElvUI')
	else
		CT.Libs.ACR:NotifyChange('ClassTactics')
	end
end

function CT:LoadKeybinds(bindSetName)
	if CT.db.keybinds[bindSetName] then
		for commandName, keys in next, CT.db.keybinds[bindSetName] do
			for _, binding in next, { GetBindingKey(commandName) } do
				SetBinding(binding) -- Clear Binding
			end
			for _, binding in next, keys do
				SetBinding(binding, commandName) -- Set Binding
			end
		end

		SaveBindings(CT.db.characterKeybind and 2 or 1)
	end
end

function CT:DeleteKeybinds(bindSetName)
	CT.db.keybinds[bindSetName] = nil
end

-- ActionBar Slots
local ActionBarTable = {}

function CT:SaveAllActionSlots(profileName)
	local specGroup = GetSpecialization()

	local profileKey = CT.db.actionbars[CT.MyClass][specGroup][profileName]
	profileKey = wipe(profileKey or {})

	for slot = 1, 120 do
		local actionType, id, subType = GetActionInfo(slot)
		local icon, name, macroText = GetActionTexture(slot), GetActionText(slot)

		if actionType == 'spell' then
			id = FindBaseSpellByID(id) or id
		elseif actionType == 'macro' then
			if id == 0 then
				actionType, id, subType, icon, name, macroText = nil, nil, nil, nil, nil, nil
			else
				name, icon, macroText = GetMacroInfo(id)
				macroText = strtrim(macroText)
			end
		end

		profileKey[slot] = { actionType = actionType, id = id, subType = subType, icon = icon, name = name, macroText = macroText }
	end

	CT.db.actionbars[CT.MyClass][GetSpecialization()][profileName] = profileKey

	CT.OptionsData[CT.MyClass][specGroup].SelectedActionBarSet = profileName

	if _G.ElvUI then
		_G.ElvUI[1].Libs.AceConfigRegistry:NotifyChange('ElvUI')
	else
		CT.Libs.ACR:NotifyChange('ClassTactics')
	end
end

function CT:GetActionBarSets(classTag, specGroup)
	wipe(ActionBarTable)

	for name in next, CT.db.actionbars[classTag or CT.MyClass][specGroup or GetSpecialization()] do
		ActionBarTable[name] = name
	end

	if not next(ActionBarTable) then
		ActionBarTable.NONE = 'None'
	end

	return ActionBarTable
end

function CT:ClearActionBar(bar)
	local isAll = type(bar) == 'boolean'
	local slotMin, slotMax = isAll and 1 or ((bar - 1) * 12) + 1, isAll and 120 or bar * 12
	for slot = slotMin, slotMax do PickupAction(slot) ClearCursor() end
end

function CT:SetActionSlot(slot, slotInfo)
	ClearCursor() -- Clear the cursor

	if not next(slotInfo) then
		PickupAction(slot) -- Pickup the slot
		ClearCursor() -- Clear the slot
		return
	end

	local actionType, id, subType, icon, name, macroText = slotInfo.actionType, slotInfo.id, slotInfo.subType, slotInfo.icon, slotInfo.name, slotInfo.macroText
	local index

	if actionType == 'item' then
		PickupItem(id)
	elseif actionType == 'spell' or actionType == 'flyout' then
		if actionType == 'spell' then
			id = FindBaseSpellByID(id) or id
		end

		if not subType or actionType == 'flyout' then
			for tabIndex = 1, min(2, GetNumSpellTabs()) do
				local offset, numEntries = select(3, GetSpellTabInfo(tabIndex))
				for spellIndex = offset, offset + numEntries do
					local skillType, spellID = GetSpellBookItemInfo(spellIndex, 'spell')
					if ((actionType == 'spell' and skillType == 'SPELL') or (actionType == 'flyout' and skillType == 'FLYOUT')) and id == spellID then
						index = spellIndex
						if not subType then
							subType = 'spell'
						end
						break
					end
				end
			end
		elseif subType then
			local spellIndex = 1
			local skillType, spellID = GetSpellBookItemInfo(spellIndex, subType)
			while skillType do
				if (skillType == 'SPELL' or (skillType == 'PETACTION' and subType == 'pet')) and id == spellID then
					index = spellIndex
					break
				end

				spellIndex = spellIndex + 1
				skillType, spellID = GetSpellBookItemInfo(spellIndex, subType)
			end
		end

		if index then
			PickupSpellBookItem(index, subType)
		elseif actionType == 'spell' then
			for _, talentId in next, C_SpecializationInfo.GetAllSelectedPvpTalentIDs() do
				if select(6, GetPvpTalentInfoByID(talentId)) == id then
					PickupPvpTalent(talentId)
				end
			end

			if not GetCursorInfo() and (subType == 'pet' or subType == 'spell') then
				if IsSpellKnown(id, subType == 'pet') then
					(subType == 'pet' and PickupPetSpell or PickupSpell)(id)
				end
			end
		end
	elseif actionType == 'macro' then
		index = GetMacroIndexByName(name)
		local account, character = GetNumMacros()
		local canMakeMacro = CT.db.createMissingMacros and (character < MAX_CHARACTER_MACROS or account < MAX_ACCOUNT_MACROS)
		local preferCharacterMacro = CT.db.preferCharacterMacros and character < MAX_CHARACTER_MACROS

		if (not index or index == 0) and canMakeMacro then
			index = CreateMacro(name, icon, macroText, preferCharacterMacro and 1)
		end

		if index then
			PickupMacro(index)
		end
	elseif actionType == 'summonmount' then
		if id == 0xFFFFFFF then
			C_MountJournal.Pickup(0)
		else
			PickupSpell((select(2, C_MountJournal.GetMountInfoByID(id))))
		end
	elseif actionType == 'summonpet' then
		C_PetJournal.PickupPet(id)
	elseif actionType == 'equipmentset' then
		local equipID = C_EquipmentSet.GetEquipmentSetID(id)
		if equipID then
			C_EquipmentSet.PickupEquipmentSet(equipID)
		end
	end

	if GetCursorInfo() then
		PlaceAction(slot)
		ClearCursor()
	end
end

function CT:LoadActionSet(profileName)
	local profileKey = CT.db.actionbars[CT.MyClass][GetSpecialization()][profileName]
	if not profileKey then return end

	for slot = 1, 120 do
		CT:SetActionSlot(slot, profileKey[slot])
	end
end

function CT:DeleteActionBarSet(classTag, specGroup, profileName)
	CT.db.actionbars[classTag or CT.MyClass][specGroup or GetSpecialization()][profileName] = nil
end

function CT:SetupActionBarPopup(name)
	local Dialog = _G.StaticPopupDialogs.CLASSTACTICS
	Dialog.text = 'Enter a Name:'
	Dialog.button1 = 'Create'
	Dialog.hasEditBox = 1
	Dialog.EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end
	Dialog.OnAccept = function(s) CT:SaveAllActionSlots(s.editBox:GetText()) end
	Dialog.EditBoxOnEnterPressed = function(s) CT:SaveAllActionSlots(s:GetText()) s:GetParent():Hide() end
	Dialog.OnShow = function(s) if name then s.editBox:SetAutoFocus(false) s.editBox:SetText(name) s.editBox:HighlightText() end end

	_G.StaticPopup_Show('CLASSTACTICS')
end
