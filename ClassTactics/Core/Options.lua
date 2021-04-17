local CT = unpack(_G.ClassTactics)

local _G = _G

local strjoin = strjoin
local strsplit = strsplit
local format = format
local select = select
local next = next
local wipe = wipe

local GetSpecialization = GetSpecialization
local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo
local WrapTextInColorCode = WrapTextInColorCode
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local ACH = CT.Libs.ACH

CT.Options = ACH:Group(CT.Title, nil, 6)
CT.Options.args.general = ACH:Group(_G.GENERAL, nil, 0, 'tab')

CT.Options.args.general.args.discordLinks = ACH:Group("Discord Links", nil, 1)
CT.Options.args.general.args.discordLinks.inline = true
CT.Options.args.general.args.discordLinks.args.wowhead = ACH:Input('Wowhead', nil, nil, nil, 'full', function() return 'https://discord.gg/wowhead' end)
CT.Options.args.general.args.discordLinks.args.weakaura = ACH:Input('WeakAuras', nil, nil, nil, 'full', function() return 'https://discord.gg/weakauras' end)
CT.Options.args.general.args.discordLinks.args.tukui = ACH:Input('Tukui Community', nil, nil, nil, 'full', function() return 'https://discord.gg/xFWcfgE' end)
CT.Options.args.general.args.discordLinks.args.dbm = ACH:Input('Deadly Boss Mods', nil, nil, nil, 'full', function() return 'https://discord.gg/deadlybossmods' end)
CT.Options.args.general.args.discordLinks.args.bigwigs = ACH:Input('BigWigs', nil, nil, nil, 'full', function() return 'https://discord.gg/jGveg85' end)

function CT:SetupProfile()
	CT.db = CT.data.profile
end

function CT:BuildProfile()
	local Defaults = {
		profile = {
			isShown = true,
			pvpShown = true,
			autoTalent = true,
			accountKeybind = true,
			talentBuilds = {},
			talentBuildsPvP = {},
			macros = {},
			keybinds = {},
			actionbars = {},
			autoTalents = {
				[CT.MyRealm] = {
					[CT.MyName] = {}
				}
			},
		},
	}

	for classTag, classID in next, CT.ClassData.Numerical do
		Defaults.profile.talentBuilds[classTag] = {}
		Defaults.profile.talentBuildsPvP[classTag] = {}
		Defaults.profile.actionbars[classTag] = {}

		for k = 1, GetNumSpecializationsForClassID(classID) do
			Defaults.profile.talentBuilds[classTag][k] = {}
			Defaults.profile.talentBuildsPvP[classTag][k] = {}
			Defaults.profile.actionbars[classTag][k] = {}
		end
	end

	CT.data = CT.Libs.ADB:New('ClassTacticsDB', Defaults, true)
	CT.data.RegisterCallback(CT, 'OnProfileChanged', 'SetupProfile')
	CT.data.RegisterCallback(CT, 'OnProfileCopied', 'SetupProfile')

	CT.db = CT.data.profile

	CT.db.autoTalents[CT.MyRealm][CT.MyName].classTag = CT.MyClass

	for _, classID in next, CT.ClassData.Numerical do
		for k = 1, GetNumSpecializationsForClassID(classID) do
			if not CT.db.autoTalents[CT.MyRealm][CT.MyName][k] then
				CT.db.autoTalents[CT.MyRealm][CT.MyName][k] = 'None'
			end
		end
	end
end

function CT:GetClassOrder(classTag)
	for i, className in next, CT.ClassData.Sorted do
		if className == classTag then
			return i
		end
	end
end

function CT:GetTalentBuildOptions(classTag, specIndex)
	local values = { None = 'None' }

	for talentName in next, CT.RetailData[classTag][specIndex].Talents do
		values[talentName] = talentName
	end

	for talentName in next, CT.db.talentBuilds[classTag][specIndex] do
		if talentName ~= 'selected' then
			values[talentName] = talentName
		end
	end

	return values
end

CT.OptionsData = {
	Import = {},
	Export = {},
	Macros = {},
	Keybind = {},
}

for classTag, classID in next, CT.ClassData.Numerical do
	CT.OptionsData[classTag] = {}
	for i = 1, GetNumSpecializationsForClassID(classID) do
		CT.OptionsData[classTag][i] = {}
	end
end

function CT:BuildOptions()
	-- Import / Export
	CT.Options.args.DataHandle = ACH:Group('Import / Export', nil, 1, 'tab')

	-- Import
	CT.Options.args.DataHandle.args.Import = ACH:Group('Import', nil, 1)
	CT.Options.args.DataHandle.args.Import.args.Input = ACH:Input('Import', nil, 0, 20, 'full', function() return CT.OptionsData.Import.Value end, function(_, value) CT.OptionsData.Import.Value = value CT.OptionsData.Import.Name, CT.OptionsData.Import.Data, CT.OptionsData.Import.Key = CT:DecodeData(value) CT.OptionsData.Import.Type = type(CT.OptionsData.Import.Type) == 'string' and strsplit('\a', CT.OptionsData.Import.Key) end, nil, nil, function(_, value) return CT.Libs.Base64:IsBase64(value) end)
	CT.Options.args.DataHandle.args.Import.args.Name = ACH:Description(function() return CT.OptionsData.Import.Name end, 0, 'large', nil, nil, nil, nil, nil, function() return CT.OptionsData.Import.Key end)

	CT.Options.args.DataHandle.args.Import.args.Preview = ACH:Group('Preview', nil, 1, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Data or not CT.OptionsData.Import.Key end)
	CT.Options.args.DataHandle.args.Import.args.Preview.inline = true
	CT.Options.args.DataHandle.args.Import.args.Preview.args.ClassSpec = ACH:Description(function() local _, classTag, specIndex if CT.OptionsData.Import.Key then _, classTag, specIndex = strsplit('\a', CT.OptionsData.Import.Key) end return classTag and WrapTextInColorCode(format('%s - %s', GetClassInfo(CT.ClassData.Numerical[classTag]), specIndex and select(2, GetSpecializationInfoForClassID(CT.ClassData.Numerical[classTag], specIndex, 0)) or ''), RAID_CLASS_COLORS[classTag].colorStr) or '' end, 0, 'large', nil, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Key end)
	CT.Options.args.DataHandle.args.Import.args.Preview.args.Spacer = ACH:Spacer(2, 'full')
	CT.Options.args.DataHandle.args.Import.args.Preview.args.TextInput = ACH:Input('Macro', nil, 0, 10, 'full', function() return CT.OptionsData.Import.Data end, nil, nil, function() return CT.OptionsData.Import.Type ~= 'macros' end)
	CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents = ACH:Group(function() return CT.OptionsData.Import.Type == 'talentBuilds' and 'Talents' or 'PvP Talents' end, nil, nil, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Type or CT.OptionsData.Import.Type ~= 'talentBuilds' and CT.OptionsData.Import.Type ~= 'talentBuildsPvP' end)

	for v = 1, 7 do
		CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents.args['talent'..v] = ACH:Execute(function() local talentID = select(v, strsplit(',', CT.OptionsData.Import.Data)) local name, _ if CT.OptionsData.Import.Type == 'talentBuilds' then _, name = CT:GetTalentInfoByID(talentID) else _, name = CT:GetPvPTalentInfoByID(talentID) end return name end, nil, v, nil, function() local talentID = select(v, strsplit(',', CT.OptionsData.Import.Data)) local _, icon if CT.OptionsData.Import.Type == 'talentBuilds' then _, _, icon = CT:GetTalentInfoByID(talentID) else _, _, icon = CT:GetPvPTalentInfoByID(talentID) end return icon end, nil, .75, nil, nil, nil, function() return v > 3 and CT.OptionsData.Import.Type == 'talentBuildsPvP' end)
		CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or CT.TexCoords end
	end

	CT.Options.args.DataHandle.args.Import.args.Import = ACH:Execute('Import Data', nil, -1, function() CT:ImportData(CT.OptionsData.Import.Value) wipe(CT.OptionsData.Import) end, nil, nil, 'full', nil, nil, function() return not CT.OptionsData.Import.Data end)

	-- Export
	CT.Options.args.DataHandle.args.Export = ACH:Group('Export', nil, 2)
	CT.Options.args.DataHandle.args.Export.args.DataType = ACH:MultiSelect('Export Data', nil, 1, nil, nil, nil, function(_, key) return CT.OptionsData.Export.Table == key end, function(_, key) CT.OptionsData.Export.Table = key end)

	CT.Options.args.DataHandle.args.Export.args.DataType.values = { none = 'None', macros = 'Macros', talentBuilds = 'Talents', talentBuildsPvP = 'PvP Talents', keybinds = 'Key Bindings', actionbars = 'ActionBars' }

	CT.Options.args.DataHandle.args.Export.args.ExportData = ACH:Input('Export String', nil, -1, 20, 'full', function() return CT.OptionsData.Export.Table ~= 'none' and CT:ExportData(CT.OptionsData.Export.Table) end, nil, nil, function() return not CT.OptionsData.Export.Table end)

	-- Macros
	CT.Options.args.Macros = ACH:Group('Macro Management', nil, 1)

	CT.Options.args.Macros.args.AccountMacro = ACH:MultiSelect('Account Macros', nil, 1, function() return CT:GetAccountMacros() end, nil, .5, function(_, key) return CT.OptionsData.Macros.Selected == key end, function(_, key) CT.OptionsData.Macros.Selected = key CT.OptionsData.Macros.SelectedImport = nil end, nil, function() return not next(CT:GetAccountMacros()) end)
	CT.Options.args.Macros.args.CharacterMacro = ACH:MultiSelect('Character Macros', nil, 2, function() return CT:GetCharacterMacros() end, nil, .5, function(_, key) return CT.OptionsData.Macros.Selected == key end, function(_, key) CT.OptionsData.Macros.Selected = key CT.OptionsData.Macros.SelectedImport = nil end, nil, function() return not next(CT:GetCharacterMacros()) end)
	CT.Options.args.Macros.args.ImportedMacros = ACH:MultiSelect('Imported Macros', nil, 3, function() return CT:GetImportedMacros() end, nil, .5, function(_, key) return CT.OptionsData.Macros.SelectedImport == key end, function(_, key) CT.OptionsData.Macros.SelectedImport = key CT.OptionsData.Macros.Selected = nil end, nil, function() return not next(CT:GetImportedMacros()) end)

	CT.Options.args.Macros.args.MacroText = ACH:Input('Macro Text', nil, -5, 5, 'full', function() return select(3, CT:GetMacroInfo(CT.OptionsData.Macros.Selected or CT.OptionsData.Macros.SelectedImport)) end, nil, nil, function() return not (CT.OptionsData.Macros.Selected or CT.OptionsData.Macros.SelectedImport) or CT.OptionsData.Macros.Selected == '' or CT.OptionsData.Macros.SelectedImport == '' end)
	CT.Options.args.Macros.args.MacroTextExport = ACH:Input('Export Macro', nil, -4, 5, 'full', function() local name, dataType = CT.OptionsData.Macros.Selected, 'macros' local macroTable = {} macroTable.icon, macroTable.text = select(2, CT:GetMacroInfo(CT.OptionsData.Macros.Selected)) return CT:ExportDataFromString(name, dataType, macroTable) end, nil, nil, function() return not CT.OptionsData.Macros.Selected or CT.OptionsData.Macros.Selected == '' end)

	CT.Options.args.Macros.args.MacroCreateAccount = ACH:Execute('Create Account Macro', nil, -3, function() CT:SetupMacroPopup(CT.OptionsData.Macros.SelectedImport) end, nil, nil, 'full', nil, nil, nil, function() return not CT.OptionsData.Macros.SelectedImport or CT.OptionsData.Macros.SelectedImport == '' end)
	CT.Options.args.Macros.args.MacroCreateCharacter = ACH:Execute('Create Character Macro', nil, -2, function() CT:SetupMacroPopup(CT.OptionsData.Macros.SelectedImport, 1) end, nil, nil, 'full', nil, nil, nil, function() return not CT.OptionsData.Macros.SelectedImport or CT.OptionsData.Macros.SelectedImport == '' end)
	CT.Options.args.Macros.args.MacroDelete = ACH:Execute('Delete Selected Macro', nil, -1, function() CT:DeleteImportedMacro(CT.OptionsData.Macros.SelectedImport) CT.OptionsData.Macros.SelectedImport = nil end, nil, nil, 'full', nil, nil, nil, function() return not CT.OptionsData.Macros.SelectedImport or CT.OptionsData.Macros.SelectedImport == '' end)

	-- Keybinds
	CT.Options.args.Keybind = ACH:Group('Key Bindings Management', nil, 1)
	CT.Options.args.Keybind.args.CharacterKeybinds = ACH:Toggle('Character Specific Bindings', nil, 0, nil, nil, 1.25, function() return CT.db.characterKeybind end, function(_, value) CT.db.characterKeybind = value end)
	CT.Options.args.Keybind.args.LoadKeyBindSet = ACH:Execute('Load Binding Set', nil, 1, function() CT:LoadKeybinds(CT.OptionsData.Keybind.SelectedSet) end, nil, nil, nil, nil, nil, nil, function() return not CT.OptionsData.Keybind.SelectedSet or CT.OptionsData.Keybind.SelectedSet == '' or CT.OptionsData.Keybind.SelectedSet == 'NONE' end)
	CT.Options.args.Keybind.args.SaveKeyBindSet = ACH:Execute('Save Binding Set', nil, 2, function() CT:SetupKeybindPopup() end)
	CT.Options.args.Keybind.args.DeleteKeyBindSet = ACH:Execute('Delete Binding Set', nil, 3, function() CT:DeleteKeybinds(CT.OptionsData.Keybind.SelectedSet) CT.OptionsData.Keybind.SelectedSet = nil end, nil, nil, nil, nil, nil, nil, function() return not CT.OptionsData.Keybind.SelectedSet or CT.OptionsData.Keybind.SelectedSet == '' or CT.OptionsData.Keybind.SelectedSet == 'NONE' end)
	CT.Options.args.Keybind.args.KeyBindSets = ACH:MultiSelect('Binding Sets', nil, 4, function() return CT:GetKeybinds() end, nil, nil, function(_, key) return CT.OptionsData.Keybind.SelectedSet == key end, function(_, key) CT.OptionsData.Keybind.SelectedSet = key end)
	CT.Options.args.Keybind.args.KeybindTextExport = ACH:Input('Export Keybinds', nil, -4, 10, 'full', function() local name, dbKey = CT.OptionsData.Keybind.SelectedSet, 'keybinds' return CT:ExportData(name, dbKey) end, nil, nil, function() return not CT.OptionsData.Keybind.SelectedSet or CT.OptionsData.Keybind.SelectedSet == '' or CT.OptionsData.Keybind.SelectedSet == 'NONE' end)

	-- Auto Talent
	CT.Options.args.AutoTalent = ACH:Group('Auto Talents', nil, 1, 'select')

	for realm, playerInfo in next, CT.db.autoTalents do
		local RealmInfo = ACH:Group(realm)
		RealmInfo.inline = false

		for player, option in next, playerInfo do
			local playerOption = ACH:Group(WrapTextInColorCode(player, RAID_CLASS_COLORS[option.classTag].colorStr), nil, CT:GetClassOrder(option.classTag))
			playerOption.inline = true

			for k = 1, GetNumSpecializationsForClassID(CT.ClassData.Numerical[option.classTag]) do
				local _, specName = GetSpecializationInfoForClassID(CT.ClassData.Numerical[option.classTag], k, 0);
				playerOption.args[''..k]= ACH:Select(specName, nil, k, function() return CT:GetTalentBuildOptions(option.classTag, k) end, nil, nil, function() return CT.db.autoTalents[realm][player][k] end, function(_, value) CT.db.autoTalents[realm][player][k] = value end)
			end

			RealmInfo.args[player] = playerOption
		end

		CT.Options.args.AutoTalent.args[realm] = RealmInfo
	end

	-- Class Section
	for i = 1, GetNumClasses() do
		local className, classTag, classID = GetClassInfo(i);

		CT.Options.args[classTag] = ACH:Group(WrapTextInColorCode(className, RAID_CLASS_COLORS[classTag].colorStr), nil, CT:GetClassOrder(classTag), 'tab')
		CT.Options.args[classTag].args.Discord = ACH:Group('Class Discord Links', nil, 0)
		CT.Options.args[classTag].args.Discord.inline = true

		for discordName, discordLink in next, CT.RetailData[classTag].Discord do
			CT.Options.args[classTag].args.Discord.args[discordName] = ACH:Input(discordName, nil, nil, nil, 'full', function() return discordLink end)
		end

		for specGroup = 1, GetNumSpecializationsForClassID(classID) do
			local _, specName = GetSpecializationInfoForClassID(classID, specGroup, 0);
			local specOption = ACH:Group(specName, nil, specGroup, 'tree')

			-- Guides
			specOption.args.Guides = ACH:Group('Class Guides')
			specOption.args.Guides.inline = true

			for siteName, siteLink in next, CT.RetailData[classTag][specGroup].Guides do
				specOption.args.Guides.args[siteName] = ACH:Input(siteName, nil, nil, nil, 'full', function() return siteLink end)
			end

			-- ActionBars
			specOption.args.ActionBars = ACH:Group('ActionBars Management', nil, 1)
			specOption.args.ActionBars.args.CreateCharacterMacros = ACH:Toggle('Create Character Macros', nil, 0, nil, nil, 1.25, function() return CT.db.CreateCharacterMacros end, function(_, value) CT.db.CreateCharacterMacros = value end)
			specOption.args.ActionBars.args.LoadActionBarSet = ACH:Execute('Load ActionBar Set', nil, 1, function() CT:LoadActionSet(CT.OptionsData[classTag][specGroup].SelectedActionBarSet) end, nil, nil, nil, nil, nil, nil, function() return classTag ~= CT.MyClass or specGroup ~= GetSpecialization() or not CT.OptionsData[classTag][specGroup].SelectedActionBarSet or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == '' or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == 'NONE' end)
			specOption.args.ActionBars.args.SaveActionBarSet = ACH:Execute('Save ActionBar Set', nil, 2, function() CT:SetupActionBarPopup() end, nil, nil, nil, nil, nil, nil, function() return classTag ~= CT.MyClass or specGroup ~= GetSpecialization() end)
			specOption.args.ActionBars.args.DeleteActionBarSet = ACH:Execute('Delete ActionBar Set', nil, 3, function() CT:DeleteActionBarSet(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedActionBarSet) CT.OptionsData[classTag][specGroup].SelectedActionBarSet = nil end, nil, nil, nil, nil, nil, nil, function() return not CT.OptionsData[classTag][specGroup].SelectedActionBarSet or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == '' or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == 'NONE' end)

			specOption.args.ActionBars.args.ActionBarSets = ACH:MultiSelect('ActionBar Sets', nil, 4, function() return CT:GetActionBarSets(classTag, specGroup) end, nil, nil, function(_, key) return CT.OptionsData[classTag][specGroup].SelectedActionBarSet == key end, function(_, key) CT.OptionsData[classTag][specGroup].SelectedActionBarSet = key end)
			specOption.args.ActionBars.args.ExportActionBarSet = ACH:Input('Export ActionBar Set', nil, -1, 5, 'full', function() local name, dbKey = CT.OptionsData[classTag][specGroup].SelectedActionBarSet or CT.OptionsData[classTag][specGroup].SelectedActionBarSet, strjoin('\a', 'actionbars', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return not CT.OptionsData[classTag][specGroup].SelectedActionBarSet or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == '' or CT.OptionsData[classTag][specGroup].SelectedActionBarSet == 'NONE' end)

			-- Macros
			specOption.args.Macros = ACH:Group('Macros')
			specOption.args.Macros.args.Defaults = ACH:MultiSelect('Defaults', nil, 1, {}, nil, nil, function(_, key) return CT.OptionsData[classTag][specGroup].SelectedMacro == key end, function(_, key) CT.OptionsData[classTag][specGroup].SelectedMacro = key end)

			for macroName in next, CT.RetailData[classTag][specGroup].Macros do
				specOption.args.Macros.args.Defaults.values[macroName] = macroName
			end

			specOption.args.Macros.args.MacroText = ACH:Input('Macro Text', nil, -3, 5, 'full', function() return CT.RetailData[classTag][specGroup].Macros[CT.OptionsData[classTag][specGroup].SelectedMacro] end, nil, nil, function() return not CT.OptionsData[classTag][specGroup].SelectedMacro or CT.OptionsData[classTag][specGroup].SelectedMacro == '' end)
			specOption.args.Macros.args.MacroCreateAccount = ACH:Execute('Create Account Macro', nil, -2, function() CT:SetupMacroPopup(CT.OptionsData[classTag][specGroup].SelectedMacro, nil, true) end, nil, nil, 'full', nil, nil, nil, function() return not CT:CanAddDefaultMacro(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedMacro) end)
			specOption.args.Macros.args.MacroCreateCharacter = ACH:Execute('Create Character Macro', nil, -1, function() CT:SetupMacroPopup(CT.OptionsData[classTag][specGroup].SelectedMacro, 1, true) end, nil, nil, 'full', nil, nil, nil, function() return not CT:CanAddDefaultMacro(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedMacro) end)

			-- Talents
			specOption.args.Talents = ACH:Group('Talents')
			specOption.args.Talents.args.Defaults = ACH:MultiSelect('Defaults', nil, 1, function() local list = {} for talentName in next, CT.RetailData[classTag][specGroup].Talents do list[talentName] = talentName end return list end, nil, nil, function(_, key) return CT.OptionsData[classTag][specGroup].SelectedTalent == key end, function(_, key) CT.OptionsData[classTag][specGroup].SelectedTalent = key CT.OptionsData[classTag][specGroup].SelectedTalentCustom = nil end)
			specOption.args.Talents.args.Custom = ACH:MultiSelect('Custom', nil, 2, function() local list = {} for talentName in next, CT.db.talentBuilds[classTag][specGroup] do if talentName ~= 'selected' then list[talentName] = talentName end end return list end, nil, nil, function(_, key) return CT.OptionsData[classTag][specGroup].SelectedTalentCustom == key end, function(_, key) CT.OptionsData[classTag][specGroup].SelectedTalentCustom = key CT.OptionsData[classTag][specGroup].SelectedTalent = nil end, nil, function() for talentName in next, CT.db.talentBuilds[classTag][specGroup] do if talentName ~= 'selected' then return false end end return true end)

			specOption.args.Talents.args.Preview = ACH:Group('Preview', nil, -1, nil, nil, nil, nil, function() return not (CT.OptionsData[classTag][specGroup].SelectedTalent or CT.OptionsData[classTag][specGroup].SelectedTalentCustom) or CT.OptionsData[classTag][specGroup].SelectedTalent == '' or CT.OptionsData[classTag][specGroup].SelectedTalentCustom == '' end)
			specOption.args.Talents.args.Preview.inline = true
			specOption.args.Talents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:SetTalentsByName(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedTalent) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.Talents.args.Preview.args.AddToSaved = ACH:Execute('Add to Saved Talents', nil, -1, function() CT:AddDefaultBuild(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedTalent) CT:TalentProfiles_Update() end, nil, nil, 'full', nil, nil, nil, function() return not CT:CanAddDefaultBuild(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedTalent) end)
			specOption.args.Talents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.OptionsData[classTag][specGroup].SelectedTalent or CT.OptionsData[classTag][specGroup].SelectedTalentCustom, strjoin('\a', 'talentBuilds', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return CT.RetailData[classTag][specGroup].Talents[CT.OptionsData[classTag][specGroup].SelectedTalent] end)

			for v = 1, 7 do
				specOption.args.Talents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedTalent or CT.OptionsData[classTag][specGroup].SelectedTalentCustom)) return select(2, CT:GetTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedTalent or CT.OptionsData[classTag][specGroup].SelectedTalentCustom)) return select(3, CT:GetTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.Talents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or CT.TexCoords end
			end

			-- PvP Talents
			specOption.args.PvPTalents = ACH:Group('PvP Talents')
			specOption.args.PvPTalents.args.NoBuilds = ACH:Description('No Saved Builds', 1, 'large', nil, nil, nil, nil, nil, function() for index in next, CT.db.talentBuildsPvP[classTag][specGroup] do if index then return true end end return false end)
			specOption.args.PvPTalents.args.Custom = ACH:MultiSelect('Custom', nil, 1, function() local list = {} for talentName in next, CT.db.talentBuildsPvP[classTag][specGroup] do if talentName ~= 'selected' then list[talentName] = talentName end end return list end, nil, nil, function(_, key) return CT.OptionsData[classTag][specGroup].SelectedPvPTalent == key end, function(_, key) CT.OptionsData[classTag][specGroup].SelectedPvPTalent = key end, nil, function() for talentName in next, CT.db.talentBuildsPvP[classTag][specGroup] do if talentName ~= 'selected' then return false end end return true end)

			specOption.args.PvPTalents.args.Preview = ACH:Group('Preview', nil, -1, nil, nil, nil, nil, function() return not CT.OptionsData[classTag][specGroup].SelectedPvPTalent or CT.OptionsData[classTag][specGroup].SelectedPvPTalent == '' end)
			specOption.args.PvPTalents.args.Preview.inline = true
			specOption.args.PvPTalents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:SetPvPTalentsByName(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedPvPTalent) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.PvPTalents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.OptionsData[classTag][specGroup].SelectedPvPTalent, strjoin('\a', 'talentBuildsPvP', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return not CT.db.talentBuildsPvP[classTag][specGroup][CT.OptionsData[classTag][specGroup].SelectedPvPTalent] end)

			for v = 1, 3 do
				specOption.args.PvPTalents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedPvPTalent)) return select(2, CT:GetPvPTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.OptionsData[classTag][specGroup].SelectedPvPTalent)) return select(3, CT:GetPvPTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.PvPTalents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or CT.TexCoords end
			end

			CT.Options.args[classTag].args[''..specGroup] = specOption
		end
	end
end

function CT:GetOptions()
	local Ace3OptionsPanel = _G.ElvUI and _G.ElvUI[1] or _G.Enhanced_Config
	if Ace3OptionsPanel then
		CT.Options.childGroups = _G.ElvUI and 'tree' or 'tab'
		Ace3OptionsPanel.Options.args.ClassTactics = CT.Options
	elseif _G.ClassTactics_Config then
		_G.ClassTactics_Config.Options.args = CT.Options.args
	end
end
