local CT = unpack(_G.ClassTactics)

local _G = _G

local strjoin = strjoin
local strsplit = strsplit
local format = format
local select = select
local next = next

local GetSpecialization = GetSpecialization
local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo
local WrapTextInColorCode = WrapTextInColorCode
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local ACH = CT.ACH

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
			talentBuilds = {},
			talentBuildsPvP = {},
			macros = {},
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
		Defaults.profile.macros[classTag] = {}

		for k = 1, GetNumSpecializationsForClassID(classID) do
			Defaults.profile.talentBuilds[classTag][k] = { selected = 'Leveling' }
			Defaults.profile.talentBuildsPvP[classTag][k] = { selected = '' }
			Defaults.profile.macros[classTag][k] = { selected = '' }
		end
	end

	CT.data = _G.LibStub('AceDB-3.0'):New('ClassTacticsDB', Defaults, true)
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
}

function CT:BuildOptions()
	-- Import / Export
	CT.Options.args.DataHandle = ACH:Group('Import / Export', nil, 1, 'tab')

	-- Import
	CT.Options.args.DataHandle.args.Import = ACH:Group('Import', nil, 1)
	CT.Options.args.DataHandle.args.Import.args.Input = ACH:Input('Import', nil, 0, 20, 'full', function() return CT.OptionsData.Import.Value end, function(_, value) CT.OptionsData.Import.Value = value CT.OptionsData.Import.Name, CT.OptionsData.Import.Data, CT.OptionsData.Import.Key = CT:DecodeData(value) CT.OptionsData.Import.Type = type(CT.OptionsData.Import.Type) == 'string' and strsplit('\a', CT.OptionsData.Import.Key) end, nil, nil, function(_, value) return CT.Base64:IsBase64(value) end)
	CT.Options.args.DataHandle.args.Import.args.Name = ACH:Description(function() return CT.OptionsData.Import.Name end, 0, 'large', nil, nil, nil, nil, nil, function() return CT.OptionsData.Import.Key end)

	CT.Options.args.DataHandle.args.Import.args.Preview = ACH:Group('Preview', nil, 1, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Data or not CT.OptionsData.Import.Key end)
	CT.Options.args.DataHandle.args.Import.args.Preview.inline = true
	CT.Options.args.DataHandle.args.Import.args.Preview.args.ClassSpec = ACH:Description(function() local _, classTag, specIndex if CT.OptionsData.Import.Key then _, classTag, specIndex = strsplit('\a', CT.OptionsData.Import.Key) end return classTag and WrapTextInColorCode(format('%s - %s', GetClassInfo(CT.ClassData.Numerical[classTag]), specIndex and select(2, GetSpecializationInfoForClassID(CT.ClassData.Numerical[classTag], specIndex, 0)) or ''), RAID_CLASS_COLORS[classTag].colorStr) or '' end, 0, 'large', nil, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Key end)
	CT.Options.args.DataHandle.args.Import.args.Preview.args.Spacer = ACH:Spacer(2, 'full')
	CT.Options.args.DataHandle.args.Import.args.Preview.args.TextInput = ACH:Input('Macro', nil, 0, 10, 'full', function() return CT.OptionsData.Import.Data end, nil, nil, function() return CT.OptionsData.Import.Type ~= 'macros' end)
	CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents = ACH:Group(function() return CT.OptionsData.Import.Type == 'talentBuilds' and 'Talents' or 'PvP Talents' end, nil, nil, nil, nil, nil, nil, function() return not CT.OptionsData.Import.Type or CT.OptionsData.Import.Type ~= 'talentBuilds' and CT.OptionsData.Import.Type ~= 'talentBuildsPvP' end)

	for v = 1, 7 do
		CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents.args['talent'..v] = ACH:Execute(function() local talentID = select(v, strsplit(',', CT.OptionsData.Import.Data)) local name, _ if CT.OptionsData.Import.Type == 'talentBuilds' then _, name = CT:GetTalentInfoByID(talentID) else _, name = CT:GetPvPTalentInfoByID(talentID) end return name end, nil, v, nil, function() local talentID = select(v, strsplit(',', CT.OptionsData.Import.Data)) local _, icon if CT.OptionsData.Import.Type == 'talentBuilds' then _, _, icon = CT:GetTalentInfoByID(talentID) else _, _, icon = CT:GetPvPTalentInfoByID(talentID) end return icon end, nil, .75, nil, nil, nil, function() return v > 3 and CT.OptionsData.Import.Type == 'talentBuildsPvP' end)
		CT.Options.args.DataHandle.args.Import.args.Preview.args.Talents.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or { .1, .9, .1, .9} end
	end

	CT.Options.args.DataHandle.args.Import.args.Import = ACH:Execute('Import Data', nil, -1, function() CT:ImportData(CT.OptionsData.Import.Data) wipe(CT.OptionsData.Import) end, nil, nil, 'full', nil, nil, function() return not CT.OptionsData.Import.Data end)

	-- Export
	CT.Options.args.DataHandle.args.Export = ACH:Group('Export', nil, 2)
	CT.Options.args.DataHandle.args.Export.args.DataType = ACH:MultiSelect('Export Data', nil, 1, nil, nil, nil, function(_, key) return CT.OptionsData.Export.Table == key end, function(_, key) CT.OptionsData.Export.Table = key end)

	CT.Options.args.DataHandle.args.Export.args.DataType.values = { none = 'None', macros = 'Macros', talentBuilds = 'Talents', talentBuildsPvP = 'PvP Talents'}

	CT.Options.args.DataHandle.args.Export.args.ExportData = ACH:Input('Export String', nil, -1, 20, 'full', function() return CT.OptionsData.Export.Table ~= 'none' and CT:ExportData(CT.OptionsData.Export.Table) end, nil, nil, function() return not CT.OptionsData.Export.Table end)

	-- Macros
	CT.Options.args.Macros = ACH:Group('Macro Management', nil, 1)

	CT.Options.args.Macros.args.AccountMacro = ACH:MultiSelect('Account Macros', nil, 2, function() return CT:GetAccountMacros() end, nil, nil, function(_, key) return CT.OptionsData.Selected == key end, function(_, key) CT.OptionsData.Selected = key end)
	CT.Options.args.Macros.args.CharacterMacro = ACH:MultiSelect('Character Macros', nil, 3, function() return CT:GetCharacterMacros() end, nil, nil, function(_, key) return CT.OptionsData.Selected == key end, function(_, key) CT.OptionsData.Selected = key end)
	CT.Options.args.Macros.args.MacroText = ACH:Input('Macro Text', nil, -2, 5, 'full', function() return select(3, CT:GetMacroInfo(CT.OptionsData.Selected)) end, nil, nil, function() return not CT.OptionsData.Selected or CT.OptionsData.Selected == '' end)
	CT.Options.args.Macros.args.MacroTextExport = ACH:Input('Export Macro', nil, -1, 5, 'full', function() local name, dataType = CT.OptionsData.Selected, 'macros' return CT:ExportDataFromString(name, dataType, select(3, CT:GetMacroInfo(CT.OptionsData.Selected))) end, nil, nil, function() return not CT.OptionsData.Selected or CT.OptionsData.Selected == '' end)

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

			-- Macros
			specOption.args.Macros = ACH:Group('Macros')
			specOption.args.Macros.args.Defaults = ACH:MultiSelect('Defaults', nil, 1, {}, nil, nil, function(_, key) return CT.db.macros[classTag][specGroup].selected == key end, function(_, key) CT.db.macros[classTag][specGroup].selected = key end)

			for macroName in next, CT.RetailData[classTag][specGroup].Macros do
				specOption.args.Macros.args.Defaults.values[macroName] = macroName
			end

			specOption.args.Macros.args.MacroText = ACH:Input('Macro Text', nil, -2, 5, 'full', function() return CT.RetailData[classTag][specGroup].Macros[CT.db.macros[classTag][specGroup].selected] or select(3, CT:GetMacroInfo(CT.db.macros[classTag][specGroup].selected)) end, nil, nil, function() return CT.db.macros[classTag][specGroup].selected == '' end)

			-- Talents
			specOption.args.Talents = ACH:Group('Talents')
			specOption.args.Talents.args.Preview = ACH:Group('Preview', nil, 0)
			specOption.args.Talents.args.Preview.inline = true
			specOption.args.Talents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:ApplyTalents(classTag, specGroup, CT.db.talentBuilds[classTag][specGroup].selected) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.Talents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.db.talentBuilds[classTag][specGroup].selected, strjoin('\a', 'talentBuilds', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return CT.RetailData[classTag][specGroup].Talents[CT.db.talentBuilds[classTag][specGroup].selected] end)

			for v = 1, 7 do
				specOption.args.Talents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.db.talentBuilds[classTag][specGroup].selected)) return select(2, CT:GetTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.db.talentBuilds[classTag][specGroup].selected)) return select(3, CT:GetTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.Talents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or { .1, .9, .1, .9} end
			end

			specOption.args.Talents.args.Defaults = ACH:MultiSelect('Defaults', nil, 1, function() local list = {} for talentName in next, CT.RetailData[classTag][specGroup].Talents do list[talentName] = talentName end return list end, nil, nil, function(_, key) return CT.db.talentBuilds[classTag][specGroup].selected == key end, function(_, key) CT.db.talentBuilds[classTag][specGroup].selected = key end)
			specOption.args.Talents.args.Custom = ACH:MultiSelect('Custom', nil, 2, function() local list = {} for talentName in next, CT.db.talentBuilds[classTag][specGroup] do if talentName ~= 'selected' then list[talentName] = talentName end end return list end, nil, nil, function(_, key) return CT.db.talentBuilds[classTag][specGroup].selected == key end, function(_, key) CT.db.talentBuilds[classTag][specGroup].selected = key end, nil, function() for talentName in next, CT.db.talentBuilds[classTag][specGroup] do if talentName ~= 'selected' then return false end end return true end)

			-- PvP Talents
			specOption.args.PvPTalents = ACH:Group('PvP Talents')
			specOption.args.PvPTalents.args.Preview = ACH:Group('Preview', nil, 0)
			specOption.args.PvPTalents.args.Preview.inline = true
			specOption.args.PvPTalents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:ApplyPvPTalents(classTag, specGroup, CT.db.talentBuildsPvP[classTag][specGroup].selected) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.PvPTalents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.db.talentBuildsPvP[classTag][specGroup].selected, strjoin('\a', 'talentBuildsPvP', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return not CT.db.talentBuildsPvP[classTag][specGroup][CT.db.talentBuildsPvP[classTag][specGroup].selected] end)

			for v = 1, 3 do
				specOption.args.PvPTalents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.db.talentBuildsPvP[classTag][specGroup].selected)) return select(2, CT:GetPvPTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.db.talentBuildsPvP[classTag][specGroup].selected)) return select(3, CT:GetPvPTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.PvPTalents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or { .1, .9, .1, .9} end
			end

			specOption.args.PvPTalents.args.Custom = ACH:MultiSelect('Custom', nil, 2, function() local list = {} for talentName in next, CT.db.talentBuildsPvP[classTag][specGroup] do if talentName ~= 'selected' then list[talentName] = talentName end end return list end, nil, nil, function(_, key) return CT.db.talentBuildsPvP[classTag][specGroup].selected == key end, function(_, key) CT.db.talentBuildsPvP[classTag][specGroup].selected = key end, nil, function() for talentName in next, CT.db.talentBuildsPvP[classTag][specGroup] do if talentName ~= 'selected' then return false end end return true end)

			CT.Options.args[classTag].args[''..specGroup] = specOption
		end
	end
end

function CT:GetOptions()
	local Ace3OptionsPanel = _G.ElvUI and _G.ElvUI[1] or _G.Enhanced_Config
	Ace3OptionsPanel.Options.args.ClassTactics = CT.Options
end
