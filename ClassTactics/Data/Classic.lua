local CT = unpack(_G.ClassTactics)

CT.Data = {}

CT.Data['DRUID'] = {
	Discord =  {
		["Dreamgrove"] = "https://discordapp.gg/dreamgrove"
	},
	[1] = { -- Balance
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/balance-druid-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/balance-druid-pve-dps-guide",
		},
		Talents = {
			["Dungeons / AoE"] = "22385,18571,22159,21778,18580,22389,21648",
			["Leveling / World Quests"] = "22387,19283,22159,18577,21702,21712,21193",
			["Leveling"] = "22387,18571,22159,21778,21702,21712,21193",
			["Single Target"] = "22385,18571,22159,18577,21706,22165,21648",
		},
		Macros = {
			["Celestial Alignment & Ravenous Frenzy"] = "#showtooltip Celestial Alignment\n/cast Celestial Alignment\n/cast Ravenous Frenzy",
			["Force of Nature"] = "#showtooltip\n/cast [@cursor] Force of Nature",
			["Innervate"] = "#showtooltip Innervate\n/cast [@mouseover,exists][@player] Innervate",
			["Rebirth"] = "#showtooltip Rebirth\n/cast [@mouseover,exists][] Rebirth",
			["Stopcasting Bear Form"] = "#showtooltip\n/stopcasting\n/cast Bear Form",
			["Stopcasting Wild Charge"] = "#showtooltip\n/stopcasting\n/cast Wild Charge",
		}
	},
	[2] = { -- Feral
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/feral-druid-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/feral-druid-pve-dps-guide",
		},
		Talents = {
			["Raiding"] = "22364,18571,22163,21778,21708,21711,21649",
			["Mythic+"] = "22363,18571,22163,18577,21708,22370,21649",
			["Leveling"] = "22363,19283,22159,18577,21708,22370,21653",
		},
		Macros = {
			["Affinity Macro"] = "#showtooltip [talent:3/1] Typhoon; [talent:3/2] Incapacitating Roar; [talent:3/3] Ursol's Vortex\n/cast Typhoon\n/cast Incapacitating Roar\n/cast [@cursor] Ursol's Vortex",
			["Moonfire Degeneracy"] = "#showtooltip Tiger's Fury\n/cancelaura Clearcasting\n/cancelaura Predatory Swiftness\n/cast Moonfire\n/cast Tiger's Fury",
			["Movement Macro"] = "#showtooltip [talent:2/1] Tiger's Dash; [talent:2/3] Wild Charge; [talent: 2/2] Renewal\n/cast Tiger's Dash\n/cast Renewal\n/stopcasting\n/cancelform [@target,help,nostance:0]\n/cast [@target,help] Wild Charge\n/cast Wild Charge",
			["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
			["Utility Macro"] = "#showtooltip [talent:4/1] Mighty Bash; [talent:4/2] Mass Entanglement; [talent:4/3] Heart of the wild\n/cast [@mouseover,harm][] Mass Entanglement\n/cast Heart of the wild\n/cast Mighty Bash",
		}
	},
	[3] = { -- Guardian
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/guardian-druid-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/guardian-druid-pve-tank-guide",
		},
		Talents = {
			["Defensive - Single Target"] = "22420,18570,22159,18577,22388,22423,22425",
			["Beginners"] = "22418,18571,22159,18577,21709,22423,22426",
			["Leveling"] = "22419,18571,22159,18577,21707,21713,22426",
			["Offensive - Single Target"] = "22419,18571,22156,18577,21707,21713,22426",
			["Mythic+"] = "22419,18571,22163,18577,21707,22423,22426",
			["Offenseive - Multi Target"] = "22419,18571,22163,18577,21707,21713,22426",
			["Defensive - Multi Target"] = "22418,18570,22159,18577,22388,22423,22426",
			["Dungeons"] = "22418,18571,22159,18577,22388,22423,22426",
		},
		Macros = {
			["Dispel"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Remove Corruption",
			["Entangling Roots"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Entangling Roots",
			["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
			["Soothe"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Soothe",
			["Wild Charge"] = "#showtooltip\n/cast [@mouseover,exists][] Wild Charge",
		}
	},
	[4] = { -- Restoration
		Guides  = { -- Restoration
			["Wowhead"] = "https://www.wowhead.com/restoration-druid-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/restoration-druid-pve-healing-guide",
		},
		Talents = {
			["Flourish / SotF - Mythic +"] = "18572,19283,22366,18577,21710,18585,22404",
			["Lifebloom - Mythic +"] = "18572,19283,22366,18577,21705,18585,22403",
			["Leveling"] = "18572,19283,22367,18577,21705,18585,22403",
			["Raiding"] = "18569,19283,22366,18577,22421,18585,22404",
		},
		Macros = {
			["Barkskin & Bear Form"] = "#showtooltip Bear Form\n/cast Barkskin\n/cast [noform:1] Bear Form",
			["Innervate"] = "#showtooltip\n/cast [@mouseover,help][@player] Innervate",
			["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
			["Rejuvenation"] = "#showtooltip\n/cast [@mouseover,help][@target,help][@player] Rejuvenation",
		}
	},
}

local petAttack = format('/petattack\n/cast %s\n/cast %s', GetSpellInfo(16827), GetSpellInfo(17253))

CT.Data['HUNTER'] = {
	Discord =  {
		["Trueshot Lodge"] = "https://discord.gg/Trueshot",
		["Warcraft's Hunter Union"] = "https://discord.gg/G3tYdTG",
	},
	[1] = { -- Beast Mastery
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/beast-mastery-hunter-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/beast-mastery-hunter-pve-dps-guide",
		},
		Talents = {
			["Leveling"] = "22280,22290,19348,22347,22499,22002,22273",
			["Mythic+"] = "22280,22500,19348,22347,22499,19357,22273",
			["Single Target"] = "22280,22500,19348,22347,22276,19357,22295",
		},
		Macros = {
			["A Murder of Crows"] = "#showtooltip\n/cast A Murder of Crows\n"..petAttack,
			["Barbed Shot"] = "#showtooltip\n/cast Barbed Shot\n"..petAttack,
			["Chimaera Shot"] = "#showtooltip\n/cast Chimaera Shot\n"..petAttack,
			["Cobra Shot"] = "#showtooltip\n/cast Cobra Shot\n"..petAttack,
			["Counter Shot"] = "#showtooltip\n/stopcasting\n/cast [@focus,harm,nodead][@mouseover,harm][] Counter Shot",
			["Flare"] = "#showtooltip\n/cast [@cursor] Flare",
			["Freezing Trap"] = "#showtooltip\n/cast [@cursor] Freezing Trap",
			["Kill Command"] = "#showtooltip\n/cast Kill Command\n"..petAttack,
			["Kill Shot"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Kill Shot\n"..petAttack,
			["Misdirection"] = "#showtooltip\n/cast [@mouseover,help,nodead][@focus,help,nodead][@target,help,nodead][@pet] Misdirection",
			["Multi-Shot"] = "#showtooltip\n/cast Multi-Shot\n"..petAttack,
			["Spirit Mend"] = "#showtooltip\n/cast [@mouseover,help,nodead][@player] Spirit Mend",
			["Tar Trap"] = "#showtooltip\n/cast [@cursor] Tar Trap",
			["Feign Death"] = "#showtooltip\n/stopcasting\n/cast Feign Death",
		}
	},
	[2] = { -- Marksmanship
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/marksmanship-hunter-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/marksmanship-hunter-pve-dps-guide",
		},
		Talents = {
			["AoE / Mythic+"] = "22279,22498,19348,22286,22276,22287,22288",
			["Leveling"] = "22279,22498,19347,21998,22276,22287,22288",
			["Single Target"] = "22279,22495,19348,22267,22276,22287,22308",
		},
		Macros = {
			["Volley"] = "#showtooltip\n/cast [@cursor] Volley",
			["Arcane Shot"] = "#showtooltip\n/cast [nochanneling:Rapid Fire] Arcane Shot",
			["Kill Shot"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Kill Shot",
			["Disengage"] = "#showtooltip\n/stopcasting\n/cast Disengage",
			["Misdirection"] = "#showtooltip\n/cast [@mouseover,help,nodead][@focus,help,nodead][@target,help,nodead][@pet] Misdirection",
			["Counter Shot"] = "#showtooltip\n/stopcasting\n/cast [@focus,harm,nodead][@mouseover,harm][] Counter Shot",
			["Feign Death"] = "#showtooltip\n/stopcasting\n/cast Feign Death",
		}
	},
	[3] = { -- Survival
		Guides  = {
			["Wowhead"] = "https://www.wowhead.com/survival-hunter-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/survival-hunter-pve-dps-guide",
		},
		Talents = {
			["Leveling"] = "22283,21997,19347,22299,22276,22271,22301",
			["Mythic+"] = "22296,21997,19348,22277,22499,22300,22301",
			["Not Pure Single Target"] = "22296,21997,19347,22277,22276,22300,22301",
			["Single Target - Nesingwary"] = "22275,21997,19347,19361,22276,22278,22272",
		},
		Macros = {
			["Misdirection"] = "#showtooltip\n/cast [@mouseover,help,nodead][@focus,help,nodead][@target,help,nodead][@pet] Misdirection",
			["Feign Death"] = "#showtooltip\n/stopcasting\n/cast Feign Death",
			["Steel Trap / A Murder of Crows"] = "#showtooltip\n/cast [talent:4/2] Steel Trap; [talent4/3] A Murder of Crows"
		}
	},
}

CT.Data['MAGE'] = {
	Discord =  {
		["Altered Time"] = "https://discord.gg/0gLMHikX2aZ23VdA"
	},
	[1] = { -- Arcane
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/arcane-mage-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/arcane-mage-pve-dps-guide",
		},
		Talents = {
			["Raiding"] = "22458,22443,22447,22467,22907,22449,21630",
			["Mythic+"] = "22458,22443,22447,22453,22448,22449,21630",
			["Leveling"] = "22461,22443,22444,22453,22448,22449,21144",
		},
		Macros = { -- Arcane
			["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
			["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
		}
	},
	[2] = { -- Fire
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/fire-mage-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/fire-mage-pve-dps-guide",
		},
		Talents = {
			["Leveling"] = "22456,22443,22444,22450,22448,23362,21631",
			["Mythic+"] = "22462,22443,22447,22450,22904,22451,21631",
		},
		Macros = {
			["Combustion & Pyroblast"] = "#showtooltip Combustion\n/castsequence reset=30 Combustion, Pyroblast",
			["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
			["Flamestrike"] = "#showtooltip\n/cast [@cursor] Flamestrike",
			["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
			["Meteor"] = "#showtooltip\n/cast [@cursor] Meteor",
			["Scorch"] = "#showtooltip\n/cast [@focus,nodead,harm][] Scorch",
		}
	},
	[3] = { -- Frost
		Guides = { -- Frost
			["Wowhead"] = "https://www.wowhead.com/frost-mage-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/frost-mage-pve-dps-guide",
		},
		Talents = {
			["Raiding"] = "22460,22443,22447,22466,22446,23176,21632",
			["Leveling"] = "22463,22443,22444,22469,22448,23176,21634",
			["Mythic+"] = "22457,22443,22447,22466,22446,22454,21632",
		},
		Macros = {
			["Blizzard"] = "#showtooltip\n/cast [@cursor] Blizzard",
			["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
			["Frostbolt"] = "#showtooltip\n/cast Frostbolt\n/petattack",
			["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
			["Water Elemental / Freeze"] = "#showtooltip\n/cast [pet] Freeze; Summon Water Elemental",
		}
	},
}

CT.Data['PALADIN'] = {
	Discord =  {
		["Hammer of Wrath"] = "http://discord.gg/hammerofwrath",
	},
	[1] = { -- Holy
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/holy-paladin-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/holy-paladin-pve-healing-guide",
		},
		Talents = {
			["Dungeon"] = "17565,17577,22179,17593,17599,23191,21201",
			["Mythic+"] = "17565,17575,21811,22433,17597,23191,21201",
			["Leveling"] = "17565,17577,22179,22434,17601,23191,21201",
			["Raiding"] = "17565,17575,22179,17593,17597,22484,21201",
		},
		Macros = {
			["Divine Shield"] = "#showtooltip\n/stopcasting\n/cast [@mouseover,exists][@target,exists][@player] Divine Shield",
			["Holy Prism"] = "#showtooltip\n/cast [@mouseovertarget,harm,nodead][@target,harm,nodead][@mouseover,exists][@target,exists][@player] Holy Prism",
			["Holy Shock"] = "#showtooltip\n/cast [@mouseover,help,nodead][@target,help,nodead][@player] Holy Shock",
		}
	},
	[2] = { -- Protection
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/protection-paladin-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/protection-paladin-pve-tank-guide",
		},
		Talents = {
			["Raiding"] = "22428,22604,21811,22433,17597,23087,21202",
			["Mythic+ / Dungeons"] = "23469,22431,21811,22433,17597,22438,21202",
			["Leveling"] = "23469,22431,22179,22434,17597,22438,23457",
		},
		Macros = {
			["Blessing of Sacrifice"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Blessing of Sacrifice",
			["Cleanse Toxins"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Cleanse Toxins",
			["Flash of Light"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Flash of Light",
			["Holy Avenger / Seraphim"] = "#showtooltip\n/cast [talent:5/2] Holy Avenger; [talent:5/3] Seraphim",
			["Lay on Hands"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Lay on Hands",
			["Repentance / Blinding Light"] = "#showtooltip\n/cast [talent:3/2] Repentance; [talent:3/3] Blinding Light",
			["Word of Glory"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Word of Glory",
		}
	},
	[3] = { -- Retribution
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/retribution-paladin-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/retribution-paladin-pve-dps-guide",
		},
		Talents = {
			["AoE / Mythic+"] = "22590,23466,22179,22433,17601,23167,23456",
			["Leveling"] = "22590,22592,22179,22434,17597,23086,22634",
			["Single Target - Kyrian"] = "23467,22592,22179,22434,17601,23167,22634",
			["Single Target - Other"] = "22557,22592,22179,22434,17601,23167,23456",
			["Single Target - Venthyr"] = "22557,22592,22179,22434,17601,23167,22215",
		},
		Macros = {
			["Final Reckoning"] = "#showtooltip\n/cast [mod,@cursor][@player] Final Reckoning",
			["Holy Avenger / Seraphim"] = "#showtooltip\n/cast [talent:5/2] Holy Avenger; [talent:5/3] Seraphim",
			["Rebuke"] = "#showtooltip\n/cast [@focus,harm,nodead][] Rebuke",
		}
	}
}

CT.Data['PRIEST'] = {
	Discord =  {
		["Warcraft Priests"] = "https://discord.gg/WarcraftPriests",
		["Focused Will"] = "https://discord.gg/focusedwill",
	},
	[1] = { -- Discipline
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/discipline-priest-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/discipline-priest-pve-healing-guide",
		},
		Talents = {
			["Evangelism"] = "22329,19758,19755,19761,22330,22161,22976",
			["Leveling"] = "19752,19758,22094,19769,22330,22161,22183",
			["Mythic+"] = "22313,19758,19755,19761,22330,22161,21183",
			["Spirit Shell"] = "22329,19758,22094,19761,22330,22161,21184",
		},
		Macros = {
			["Angelic Feather"] = "#showtooltip\n/cast [@player] Angelic Feather\n/stopspelltarget",
			["Mass Dispel"] = "#showtooltip\n/cast [mod,@cursor][] Mass Dispel",
			["Rapture"] = "#showtooltip\n/cast [talent:7/2] Mindbender\n/cast [talent:7/2] Spirit Shell; [@mouseover,help,nodead] Rapture",
			["Shadow Mend"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Shadow Mend",
		}
	},
	[2] = { -- Holy
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/holy-priest-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/holy-priest-pve-healing-guide",
		},
		Talents = {
			["Leveling"] = "22312,19758,22487,21977,19764,19767,21636",
			["Mythic+ Flash"] = "19753,19758,22095,21977,19764,19767,21644",
			["Mythic+ Harmonious"] = "19754,19758,22095,21977,21754,19767,21644",
			["Raids"] = "22312,19758,22487,19761,19764,19767,23145",
		},
		Macros = {
			["Angelic Feather"] = "#showtooltip\n/cast [@player] Angelic Feather\n/stopspelltarget",
			["Flash Heal"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Flash Heal",
			["Mass Dispel"] = "#showtooltip\n/cast [mod,@cursor][] Mass Dispel",
		}
	},
	[3] = { -- Shadow
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/shadow-priest-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/shadow-priest-pve-dps-guide",
		},
		Talents = {
			["Leveling"] = "22136,22315,23126,21752,22311,21718,21979",
			["Raids"] = "22328,22315,23125,21752,22310,21720,21978",
			["Mythic+"] = "22136,22315,23127,21752,21755,21719,21979",
		},
		Macros = {
			["Dispersion"] = "#showtooltip\n/cast Dispersion\n/cancelaura Dispersion",
			["Leap of Faith"] = "#showtooltip\n/cast [@mouseover,help,nodead][help,nodead] Leap of Faith",
			["Shadow Crash"] = "#showtooltip\n/cast [mod,@cursor][] Shadow Crash",
			["Shadow Word: Pain"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Shadow Word: Pain",
			["Shadowfiend"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Shadowfiend",
			["Silence"] = "#showtooltip\n/cast [@focus,exists][] Silence",
			["Vampiric Touch"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Vampiric Touch",
			["Void Eruption"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Void Eruption",
		}
	},
}

CT.Data['ROGUE'] = {
	Discord =  {
		["Ravenholdt"] = "https://discord.gg/mnwuJ7e",
	},
	[1] = { -- Assassination
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/assassination-rogue-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/assassination-rogue-pve-dps-guide",
		},
		Talents = {
			["Single Target / Raid"] = "22339,23022,19239,22122,22115,23015,21186",
			["AoE / Mythic+"] = "22338,22332,19239,22122,23037,23015,23174",
			["World / Leveling"] = "22339,22332,19241,22340,19245,23015,21186",
			["Leveling"] = "22337,22331,19239,22340,19245,23015,21186",
		},
		Macros = {
			["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
			["Shadowstep"] = "#showtooltip\n/cast [@mouseover,exists,nodead][] Shadowstep",
			["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
		}
	},
	[2] = { -- Outlaw
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/outlaw-rogue-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/outlaw-rogue-pve-dps-guide",
		},
		Talents = {
			["AoE / Mythic+"] = "22119,23470,19241,22122,22115,23128,23175",
			["Single Target"] = "22120,23470,19241,22122,22115,23128,23075",
			["World / Leveling"] = "22119,23470,19241,22121,23077,23128,23075",
			["Leveling"] = "22119,23470,19239,22122,23077,23128,22125",
			["Mythic+"] = "22119,23470,19241,22122,23077,23128,23175",
		},
		Macros = {
			["Blade Rush / Killing Spree"] = "#showtooltip\n/cast [talent:7/2] Blade Rush; [talent:7/3] Killing Spree",
			["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
			["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
		}
	},
	[3] = { -- Subtlety
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/subtlety-rogue-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/subtlety-rogue-pve-dps-guide",
		},
		Talents = {
			["AoE / Mythic+"] = "19234,22333,19240,22122,23078,22336,23183",
			["Single Target / Raid"] = "19233,22333,19240,22122,22115,22336,22132",
			["World / Leveling"] = "19234,22331,19241,22128,23078,22336,23183",
			["Mythic+"] = "19234,22333,19240,22122,22115,22336,23183",
			["Leveling"] = "19233,22331,19239,22128,23036,22336,22132",
		},
		Macros = {
			["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
			["Secret Technique / Shuriken Tornado"] = "#showtooltip\n/cast [talent:7/2] Secret Technique; [talent:7/3] Shuriken Tornado",
			["Shadowstep"] = "#showtooltip\n/cast [@mouseover,exists,nodead][] Shadowstep",
			["Shadowstrike"] = "#showtooltip\n/cast [stance:0] Shadow Dance\n/cast Shadowstrike",
			["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
		}
	},
}

CT.Data['SHAMAN'] = {
	Discord =  {
		["Ancestral Guidance"] = "https://discord.gg/AcTek6e",
		["Earthshrine"] = "https://discord.gg/earthshrine",
	},
	[1] = { -- Elemental
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/elemental-shaman-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/elemental-shaman-pve-dps-guide",
		},
		Talents = {
			["Single Target"] = "22357,23460,23162,19271,22144,23111,22153",
			["AoE / Cleave"] = "22357,23104,23162,19272,22144,19266,22153",
			["Mythic+"] = "22357,23108,23162,19271,22144,19266,22153",
			["Leveling"] = "22357,23460,23162,19271,22144,23111,22153",
		},
		Macros = {
			["Bloodlust"] = "#showtooltip\n/stopmacro [nocombat]\n/cast Bloodlust",
			["Earthquake"] = "#showtooltip\n/cast [@cursor] Earthquake",
			["Primal Storm/Fire"] = "#showtooltip\n/cast Call Lightning\n/cast [talent:4/2,talent:6/2] !Eye of the Storm; [talent:6/2] Meteor",
			["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
		}
	},
	[2] = { -- Enhancement
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/enhancement-shaman-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/enhancement-shaman-pve-dps-guide",
		},
		Talents = {
			["Single Target"] = "22353,22636,23165,23089,22144,22351,21972",
			["AoE/Cleave"] = "22355,22636,23165,23090,22144,22351,21972",
			["Leveling"] = "22355,22636,23165,23090,22144,22351,21970",
		},
		Macros = {
			["Healing Surge"] = "#showtooltip\n/stopcasting\n/cast [@mouseover,exists][@player] Healing Surge",
			["Wind Rush Totem"] = "#showtooltip\n/stopcasting\n/cast [mod,@cursor][@player] Wind Rush Totem",
			["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
		}
	},
	[3] = { -- Restoration
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/restoration-shaman-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/restoration-shaman-pve-healing-guide",
		},
		Talents = {
			["Dungeon"] = "19263,19259,22127,22322,19269,21968,22359",
			["Raiding"] = "19264,19259,19275,22322,19269,21968,21199",
			["Mythic+"] = "19263,19259,22127,22152,19269,21968,22359",
			["Leveling"] = "19263,19259,19275,22322,22144,19265,22359",
		},
		Macros = {
			["Healing Rain"] = "#showtooltip\n/use [mod,@cursor][@player] Healing Rain",
			["Tier 4 Talents"] = "#showtooltip\n/use [talent:4/2] Earthen Wall Totem; [talent:4/3] Ancestral Protection Totem",
			["Tier 7 Talents"] = "#showtooltip\n/use [talent:7/2] Wellspring; [talent:7/3] Ascendance",
			["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
		}
	},
}

CT.Data['WARLOCK'] = {
	Discord =  {
		["Council of the Black Harvest"] = "https://discord.com/invite/BlackHarvest",
	},
	[1] = { -- Affliction
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/affliction-warlock-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/affliction-warlock-pve-dps-guide",
		},
		Talents = {
			["Raiding"] = "23141,22089,19285,19292,19291,23159,19293",
			["Questing"] = "23141,23141,19285,22046,19291,23159,19293",
			["Mythic+"] = "23141,21180,19285,22046,19291,23139,19293",
			["Leveling"] = "23141,21180,19280,22046,19291,23139,19281",
		},
		Macros = {
			["Agony"] = "#showtooltip\n/cast [@mouseover,exists][] Agony",
			["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
			["Vile Taint / Phantom Singularity"] = "#showtooltip\n/cast [@cursor,talent:4/3][talent:4/3] Vile Taint; [talent:4/2] Phantom Singularity",
		}
	},
	[2] = { -- Demonology
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/demonology-warlock-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/demonology-warlock-pve-dps-guide",
		},
		Talents = {
			["Raiding"] = "23138,22045,19280,23160,19291,21717,22479",
			["Mythic+"] = "23138,22045,19280,23160,19291,21717,22479",
			["Dog Mythic+"] = "19290,22045,19280,22477,19291,23147,22479",
			["Leveling"] = "22048,22045,19280,22042,19291,23146,23161",
			["Questing"] = "19290,22045,19280,23160,19291,21717,22479",
		},
		Macros = {
			["Shadowfury"] = "#showtooltip\n/cast [@cursor] Shadowfury",
			["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
		}
	},
	[3] = { -- Destruction
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/destruction-warlock-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/destruction-warlock-pve-dps-guide",
		},
		Talents = {
			["Single Target"] = "22038,23148,19285,23143,19291,23155,23144",
			["AoE / Cleave"] = "22038,23148,19285,23143,19291,23156,19284",
			["Leveling"] = "22038,23148,19280,23143,19291,23155,23092",
			["Mythic+"] = "22038,23148,19280,22043,19291,23156,19284",
		},
		Macros = {
			["Cataclysm"] = "#showtooltip\n/cast [@cursor] Cataclysm",
			["Channel Demonfire / Dark Soul"] = "#showtooltip\n/cast [talent:7/2] Channel Demonfire; [talent:7/3] Dark Soul: Instability",
			["Havoc"] = "#showtooltip\n/cast [@mouseover,exists][] Havoc",
			["Rain of Fire"] = "#showtooltip\n/cast [@cursor] Rain of Fire",
			["Shadowfury"] = "#showtooltip\n/cast [@cursor] Shadowfury",
			["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
			["Summon Infernal"] = "#showtooltip\n/cast [@cursor] Summon Infernal",
		}
	},
}

CT.Data['WARRIOR'] = {
	Discord =  {
		["Skyhold"] = "https://discord.gg/skyhold",
	},
	[1] = { -- Arms
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/arms-warrior-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/arms-warrior-pve-dps-guide",
		},
		Talents = {
			["Questing"] = "22624,19767,22380,22627,22362,22399,22407",
			["Dungeons"] = "22371,19676,22380,22627,22362,22397,22407",
			["Venthyr Raiding"] = "22360,19676,22380,22627,22391,22399,22407",
			["Raiding"] = "22371,19676,19138,22627,22391,22397,22407",
			["Mythic+"] = "22371,19676,22380,22628,22362,22397,22407",
			["Leveling"] = "22624,19676,22489,22627,22362,22394,22407",
		},
		Macros = {
			["Avatar or Deadly Calm"] = "#showtooltip\n/cast [talent:6/2] Avatar; [talent:6/3] Deadly Calm",
			["Charge / Victory Rush"] = "#showtooltip\n/cast Charge\n/cast Victory Rush",
			["Fervor of Battle"] = "#showtooltip\n/cast [talent:3/2] Whirlwind; Slam",
			["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
			["Pummel"] = "#showtooltip Pummel\n/cast [@focus,harm][] Pummel",
		}
	},
	[2] = { -- Fury
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/fury-warrior-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/fury-warrior-pve-dps-guide",
		},
		Talents = {
			["Questing"] = "22491,19676,23372,22627,22393,22398,22405",
			["Dungeons"] = "22491,19676,22379,22382,22393,22400,22405",
			["Raiding"] = "22633,19676,22379,22382,19140,22398,16037",
			["Mythic+"] = "22491,19676,22379,22382,19140,22400,22405",
			["Leveling"] = "22491,19676,23372,22627,22393,22398,22402",
		},
		Macros = {
			["Charge / Victory Rush"] = "#showtooltip\n/cast Charge\n/cast Victory Rush",
			["Dragon Roar / Bladestorm"] = "#showtooltip\n/cast [talent:6/2] Dragon Roar; [talent:6/3] Bladestorm",
			["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
			["Pummel"] = "#showtooltip Pummel\n/cast [@focus,harm][] Pummel",
		}
	},
	[3] = { -- Protection
		Guides = {
			["Wowhead"] = "https://www.wowhead.com/protection-warrior-guide",
			["IcyVeins"] = "https://www.icy-veins.com/wow/protection-warrior-pve-tank-guide",
		},
		Talents = {
			["Leveling"] = "15759,22629,22626,22627,22631,22395,23099",
			["Starter"] = "15760,19676,22626,23096,22631,22544,23455",
			["Raiding"] = "15774,22409,22626,22627,22631,22395,23455",
			["Mythic+"] = "15774,22409,22626,23096,22631,22401,23099",
		},
		Macros = {
			["Charge"] = "#showtooltip Charge\n/cast [mod,@focus,harm][] Charge",
			["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
			["Intervene"] = "#showtooltip Intervene\n/cast [mod,@focus,harm][] Intervene",
			["Pummel"] = "#showtooltip Pummel\n/cast [mod,@focus,harm][] Pummel",
			["Shockwave / Storm Bolt"] = "#showtooltip\n/cast [notalent:2/3] Shockwave; [talent:2/3] Storm Bolt",
			["Taunt"] = "/cast [mod,@focus,exists][] Taunt",
		}
	},
}
