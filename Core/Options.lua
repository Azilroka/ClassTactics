local CT = unpack(_G.ClassTactics)

local _G = _G

local sort = sort
local select = select
local next = next

local GetSpecialization = GetSpecialization
local GetNumClasses = GetNumClasses
local GetClassInfo = GetClassInfo
local WrapTextInColorCode = WrapTextInColorCode
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local ClassAlphabeticalOrder = CopyTable(CLASS_SORT_ORDER)
local ClassNumericalOrder = {}
for i = 1, GetNumClasses() do
	local className, classTag, classID = GetClassInfo(i)
	ClassNumericalOrder[classTag] = classID
end

sort(ClassAlphabeticalOrder)

local ACH = CT.ACH

CT.Options = ACH:Group(CT.Title, nil, 6)
CT.Options.args.general = ACH:Group(_G.GENERAL, nil, 0, 'tab')

CT.Options.args.general.args.discordLinks = ACH:Group("Discord Links", nil, 1)
CT.Options.args.general.args.discordLinks.inline = true
CT.Options.args.general.args.discordLinks.args.wowhead = ACH:Input('Wowhead', nil, nil, nil, 'full', function() return 'https://discord.gg/wowhead' end)
CT.Options.args.general.args.discordLinks.args.weakaura = ACH:Input('WeakAuras', nil, nil, nil, 'full', function() return 'https://discord.gg/wa2' end)
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

	for classTag, classID in next, ClassNumericalOrder do
		Defaults.profile[classTag] = {}
		Defaults.profile.talentBuilds[classTag] = {}
		Defaults.profile.talentBuildsPvP[classTag] = {}

		for k = 1, GetNumSpecializationsForClassID(classID) do
			Defaults.profile[classTag][k] = { selectedTalentBuild = 'Leveling', selectedPvPTalentBuild = 'Custom' }
			Defaults.profile.talentBuilds[classTag][k] = {}
			Defaults.profile.talentBuildsPvP[classTag][k] = {}
		end
	end

	CT.data = _G.LibStub('AceDB-3.0'):New('ClassTacticsDB', Defaults, true)
	CT.data.RegisterCallback(CT, 'OnProfileChanged', 'SetupProfile')
	CT.data.RegisterCallback(CT, 'OnProfileCopied', 'SetupProfile')
	CT.db = CT.data.profile

	CT.db.autoTalents[CT.MyRealm][CT.MyName].classTag = CT.MyClass

	for classTag, classID in next, ClassNumericalOrder do
		for k = 1, GetNumSpecializationsForClassID(classID) do
			if not CT.db.autoTalents[CT.MyRealm][CT.MyName][k] then
				CT.db.autoTalents[CT.MyRealm][CT.MyName][k] = 'None'
			end
		end
	end
end

function CT:GetClassOrder(classTag)
	for i, className in ipairs(ClassAlphabeticalOrder) do
		if className == classTag then
			return i
		end
	end
end

function CT:GetTalentBuildOptions(classTag, specIndex)
	local values = { None = 'None' }

	for talentName in next, CT.TalentList[classTag][specIndex] do
		values[talentName] = talentName
	end

	for talentName in next, CT.db.talentBuilds[classTag][specIndex] do
		values[talentName] = talentName
	end

	return values
end

function CT:BuildOptions()
	CT.Options.args.general.args.AutoTalent = ACH:Group('Auto Talents', nil, 1)

	for realm, playerInfo in next, CT.db.autoTalents do
		local RealmInfo = ACH:Group(realm)
		RealmInfo.inline = false

		for player, option in next, playerInfo do
			local playerOption = ACH:Group(WrapTextInColorCode(player, RAID_CLASS_COLORS[option.classTag].colorStr), nil, CT:GetClassOrder(option.classTag))
			playerOption.inline = true

			for k = 1, GetNumSpecializationsForClassID(ClassNumericalOrder[option.classTag]) do
				local _, specName = GetSpecializationInfoForClassID(ClassNumericalOrder[option.classTag], k, 0);
				playerOption.args[''..k]= ACH:Select(specName, nil, k, function() return CT:GetTalentBuildOptions(option.classTag, k) end, nil, nil, function() return CT.db.autoTalents[realm][player][k] end, function(_, value) CT.db.autoTalents[realm][player][k] = value end)
			end

			RealmInfo.args[player] = playerOption
		end

		CT.Options.args.general.args.AutoTalent.args[realm] = RealmInfo
	end

	for i = 1, GetNumClasses() do
		local className, classTag, classID = GetClassInfo(i);

		CT.Options.args[classTag] = ACH:Group(WrapTextInColorCode(className, RAID_CLASS_COLORS[classTag].colorStr), nil, CT:GetClassOrder(classTag), 'tab')
		CT.Options.args[classTag].args.Discord = ACH:Group('Class Discord Links', nil, 0)
		CT.Options.args[classTag].args.Discord.inline = true

		for discordName, discordLink in next, CT.DiscordList[classTag] do
			CT.Options.args[classTag].args.Discord.args[discordName] = ACH:Input(discordName, nil, nil, nil, 'full', function() return discordLink end)
		end

		for specGroup = 1, GetNumSpecializationsForClassID(classID) do
			local _, specName = GetSpecializationInfoForClassID(classID, specGroup, 0);
			local specOption = ACH:Group(specName, nil, specGroup, 'tree')

			specOption.args.Macros = ACH:Group('Macros')

			for macroName in next, CT.MacroList[classTag][specGroup] do
				specOption.args.Macros.args[macroName] = ACH:Input(macroName, nil, nil, 4, 2, function(info) return CT.MacroList[classTag][specGroup][info[#info]] end)
			end

			specOption.args.Talents = ACH:Group('Talents')
			specOption.args.Talents.args.Preview = ACH:Group('Preview', nil, 0)
			specOption.args.Talents.args.Preview.inline = true
			specOption.args.Talents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:ApplyTalents(classTag, specGroup, CT.db[classTag][specGroup].selectedTalentBuild) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.Talents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.db[classTag][specGroup].selectedTalentBuild, strjoin('\a', 'talentBuilds', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return CT.TalentList[classTag][specGroup][CT.db[classTag][specGroup].selectedTalentBuild] end)

			for v = 1, 7 do
				specOption.args.Talents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.db[classTag][specGroup].selectedTalentBuild)) return select(2, CT:GetTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetTalentIDByString(classTag, specGroup, CT.db[classTag][specGroup].selectedTalentBuild)) return select(3, CT:GetTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.Talents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or { .1, .9, .1, .9} end
			end

			specOption.args.Talents.args.Defaults = ACH:MultiSelect('Defaults', nil, 1, {}, nil, nil, function(_, key) return CT.db[classTag][specGroup].selectedTalentBuild == key end, function(_, key) CT.db[classTag][specGroup].selectedTalentBuild = key end)

			for talentName in next, CT.TalentList[classTag][specGroup] do
				specOption.args.Talents.args.Defaults.values[talentName] = talentName
			end

			specOption.args.Talents.args.Custom = ACH:MultiSelect('Custom', nil, 2, {}, nil, nil, function(_, key) return CT.db[classTag][specGroup].selectedTalentBuild == key end, function(_, key) CT.db[classTag][specGroup].selectedTalentBuild = key end, nil, true)

			for talentName in next, CT.db.talentBuilds[classTag][specGroup] do
				specOption.args.Talents.args.Custom.values[talentName] = talentName
				specOption.args.Talents.args.Custom.hidden = false
			end

			specOption.args.PvPTalents = ACH:Group('PvP Talents')
			specOption.args.PvPTalents.args.Preview = ACH:Group('Preview', nil, 0)
			specOption.args.PvPTalents.args.Preview.inline = true
			specOption.args.PvPTalents.args.Preview.args.ApplyTalents = ACH:Execute('Apply Talents', nil, -2, function() CT:ApplyTalents(classTag, specGroup, CT.db[classTag][specGroup].selectedPvPTalentBuild) end, nil, nil, 'full', nil, nil, nil, function() return (classTag ~= CT.MyClass) or (classTag == CT.MyClass and (GetSpecialization() ~= specGroup)) end)
			specOption.args.PvPTalents.args.Preview.args.ExportTalents = ACH:Input('Export Talents', nil, -1, 5, 'full', function() local name, dbKey = CT.db[classTag][specGroup].selectedPvPTalentBuild, strjoin('\a', 'talentBuildsPvP', classTag, specGroup) return CT:ExportData(name, dbKey) end, nil, nil, function() return CT.TalentList[classTag][specGroup][CT.db[classTag][specGroup].selectedTalentBuild] end)

			for v = 1, 3 do
				specOption.args.PvPTalents.args.Preview.args['talent'..v] = ACH:Execute(function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.db[classTag][specGroup].selectedPvPTalentBuild)) return select(2, CT:GetPvPTalentInfoByID(talentID)) end, nil, v, nil, function() local talentID = select(v, CT:GetPvPTalentIDByString(classTag, specGroup, CT.db[classTag][specGroup].selectedPvPTalentBuild)) return select(3, CT:GetPvPTalentInfoByID(talentID)) end, nil, .75)
				specOption.args.PvPTalents.args.Preview.args['talent'..v].imageCoords = function() return _G.ElvUI and _G.ElvUI[1].TexCoords or { .1, .9, .1, .9} end
			end

			specOption.args.PvPTalents.args.Custom = ACH:MultiSelect('Custom', nil, 2, {}, nil, nil, function(_, key) return CT.db[classTag][specGroup].selectedPvPTalentBuild == key end, function(_, key) CT.db[classTag][specGroup].selectedPvPTalentBuild = key end, nil, true)

			for talentName in next, CT.db.talentBuildsPvP[classTag][specGroup] do
				specOption.args.PvPTalents.args.Custom.values[talentName] = talentName
				specOption.args.PvPTalents.args.Custom.hidden = false
			end

			CT.Options.args[classTag].args[''..specGroup] = specOption
		end
	end
end

function CT:UpdateOptions()
	for classTag, classID in next, ClassNumericalOrder do
		for k = 1, GetNumSpecializationsForClassID(classID) do
			CT.Options.args[classTag].args[''..k].args.Talents.args.Custom.values = {}
			CT.Options.args[classTag].args[''..k].args.Talents.args.Custom.hidden = true
		end
	end

	for classTag, classID in next, ClassNumericalOrder do
		for k = 1, GetNumSpecializationsForClassID(classID) do
			for talentName in pairs(CT.db.talentBuilds[classTag][k]) do
				CT.Options.args[classTag].args[''..k].args.Talents.args.Custom.values[talentName] = talentName
				CT.Options.args[classTag].args[''..k].args.Talents.args.Custom.hidden = false
			end
		end
	end
end

function CT:GetOptions()
	local Ace3OptionsPanel = _G.ElvUI and _G.ElvUI[1] or _G.Enhanced_Config
	Ace3OptionsPanel.Options.args.ClassTactics = CT.Options
end
