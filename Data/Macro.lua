local CT = unpack(_G.ClassTactics)

CT.MacroList['DEATHKNIGHT'][1] = { -- Blood
	["Death and Decay"] = "#showtooltip Death and Decay\n/cast [mod,@cursor][@player] Death and Decay",
	["Gorefiend's Grasp"] = "#showtooltip Gorefiend's Grasp\n/cast [@mouseover,exists,nodead][@focus,exists][@player] Gorefiend's Grasp",
	["Mind Freeze"] = "#showtooltip Mind Freeze\n/cast [@focus,harm,nodead][] Mind Freeze",
	["Raise Ally"] = "#showtooltip Raise Ally\n/cast [@mouseover,exists,help,dead][] Raise Ally",
	["Raise Dead / Sacrificial Pact"] = "#showtooltip\n/castsequence reset=61 Raise Dead, Sacrificial Pact",
	["Re-Control Pet"] = "/target pet\n/run PetDismiss()\n/use Control Undead\n/petassist",
}
CT.MacroList['DEATHKNIGHT'][2] = { -- Frost
	["Asphyxiate"] = "#showtooltip Asphyxiate\n/cast [@mouseover,exists][] Asphyxiate",
	["Breath of Sindragosa"] = "#showtooltip Breath of Sindragosa\n/cast !Breath of Sindragosa",
	["Death and Decay"] = "#showtooltip Death and Decay\n/cast [mod,@cursor][@player] Death and Decay",
	["Death Grip"] = "#showtooltip Death Grip\n/cast [@focus,exists][@mouseover,exists][] Death Grip",
	["Icebound Fortitude"] = "#showtooltip Icebound Fortitude\n/cancelaura Lichborne\n/cast Icebound Fortitude",
	["Mind Freeze"] = "#showtooltip Mind Freeze\n/cast [@focus,harm,nodead][] Mind Freeze",
	["Raise Ally"] = "#showtooltip Raise Ally\n/cast [@mouseover,help,dead][] Raise Ally",
	["Wraith Walk or Death Pact"] = "#showtooltip\n/cast [talent:5/2] Wraith Walk; [talent:5/3] Death Pact",
}
CT.MacroList['DEATHKNIGHT'][3] = { -- Unholy
	["Asphyxiate"] = "#showtooltip Asphyxiate\n/cast [@mouseover,exists][] Asphyxiate",
	["Death and Decay"] = "#showtooltip Death and Decay\n/cast [mod,@cursor][@player] Death and Decay",
	["Death Grip"] = "#showtooltip Death Grip\n/cast [@focus,exists][@mouseover,exists][] Death Grip",
	["Mind Freeze"] = "#showtooltip Mind Freeze\n/cast [@focus,exists,harm,nodead][] Mind Freeze",
	["Outbreak / Chains of Ice"] = "#showtooltip\n/cast [nomod,@mouseover,nodead,harm][nomod,@target,nodead,harm] Outbreak;\n/cast [mod:shift,@mouseover,nodead,harm][mod:shift,@target,nodead,harm] Chains of Ice",
	["Outbreak"] = "#showtooltip Outbreak\n/cast [@mouseover,exists][] Outbreak",
	["Raise Ally"] = "#showtooltip Raise Ally\n/cast [@mouseover,help,dead][] Raise Ally",
	["Summon Gargoyle or Unholy Assault"] = "#showtooltip\n/cast [talent:7/2] Summon Gargoyle; [talent:7/3] Unholy Assault",
	["Wraith Walk or Death Pact"] = "#showtooltip\n/cast [talent:5/2] Wraith Walk; [talent:5/3] Death Pact",
}

CT.MacroList['DEMONHUNTER'][1] = { -- Havoc
	["Consume Magic"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Consume Magic",
	["Disrupt"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Disrupt",
	["Imprison"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Imprison",
	["Metamorphosis"] = "#showtooltip\n/stopmacro [channeling:Eye Beam]\n/stopmacro [channeling:Fel Barrage]\n/cast [mod,@cursor][@player] Metamorphosis",
}
CT.MacroList['DEMONHUNTER'][2] = { -- Vengence
	["Consume Magic"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Consume Magic",
	["Disrupt"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Disrupt",
	["Imprison"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Imprison",
	["Sigil of Chains"] = "#showtooltip\n/cast [@cursor] Sigil of Chains",
	["Sigil of Elysian Decree"] = "#showtooltip\n/cast [@cursor] Elysian Decree",
	["Sigil of Flame"] = "#showtooltip\n/cast [@cursor] Sigil of Flame",
	["Sigil of Mastery"] = "#showtooltip\n/cast [@cursor] Sigil of Misery",
	["Sigil of Silence"] = "#showtooltip\n/cast [@cursor] Sigil of Silence",
	["Torment"] = "#showtooltip\n/cast [mod:alt,@target][@focus,harm,nodead][] Torment",
}

CT.MacroList['DRUID'][1] = { -- Balance
	["Celestial Alignment & Ravenous Frenzy"] = "#showtooltip Celestial Alignment\n/cast Celestial Alignment\n/cast Ravenous Frenzy",
	["Force of Nature"] = "#showtooltip\n/cast [@cursor] Force of Nature",
	["Innervate"] = "#showtooltip Innervate\n/cast [@mouseover,exists][@player] Innervate",
	["Rebirth"] = "#showtooltip Rebirth\n/cast [@mouseover,exists][] Rebirth",
	["Stopcasting Bear Form"] = "#showtooltip\n/stopcasting\n/cast Bear Form",
	["Stopcasting Wild Charge"] = "#showtooltip\n/stopcasting\n/cast Wild Charge",
}
CT.MacroList['DRUID'][2] = { -- Feral
	["Affinity Macro"] = "#showtooltip [talent:3/1] Typhoon; [talent:3/2] Incapacitating Roar; [talent:3/3] Ursol's Vortex\n/cast Typhoon\n/cast Incapacitating Roar\n/cast [@cursor] Ursol's Vortex",
	["Moonfire Degeneracy"] = "#showtooltip Tiger's Fury\n/cancelaura Clearcasting\n/cancelaura Predatory Swiftness\n/cast Moonfire\n/cast Tiger's Fury",
	["Movement Macro"] = "#showtooltip [talent:2/1] Tiger's Dash; [talent:2/3] Wild Charge; [talent: 2/2] Renewal\n/cast Tiger's Dash\n/cast Renewal\n/stopcasting\n/cancelform [@target,help,nostance:0]\n/cast [@target,help] Wild Charge\n/cast Wild Charge",
	["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
	["Utility Macro"] = "#showtooltip [talent:4/1] Mighty Bash; [talent:4/2] Mass Entanglement; [talent:4/3] Heart of the wild\n/cast [@mouseover,harm][] Mass Entanglement\n/cast Heart of the wild\n/cast Mighty Bash",
}
CT.MacroList['DRUID'][3] = { -- Guardian
	["Dispel"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Remove Corruption",
	["Entangling Roots"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Entangling Roots",
	["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
	["Soothe"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Soothe",
	["Wild Charge"] = "#showtooltip\n/cast [@mouseover,exists][] Wild Charge",
}
CT.MacroList['DRUID'][4] = { -- Restoration
	["Barkskin & Bear Form"] = "#showtooltip Bear Form\n/cast Barkskin\n/cast [noform:1] Bear Form",
	["Innervate"] = "#showtooltip\n/cast [@mouseover,help][@player] Innervate",
	["Rebirth"] = "#showtooltip\n/cast [@mouseover,help][] Rebirth",
	["Rejuvenation"] = "#showtooltip\n/cast [@mouseover,help][@target,help][@player] Rejuvenation",
}

local petAttack = format('/petattack\n/cast %s\n/cast %s\n/cast %s', GetSpellInfo(16827), GetSpellInfo(17253), GetSpellInfo(49966))
CT.MacroList['HUNTER'][1] = { -- Beast Mastery
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
CT.MacroList['HUNTER'][2] = { -- Marksmanship
	["Volley"] = "#showtooltip\n/cast [@cursor] Volley",
	["Arcane Shot"] = "#showtooltip\n/cast [nochanneling:Rapid Fire] Arcane Shot",
	["Kill Shot"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Kill Shot",
	["Disengage"] = "#showtooltip\n/stopcasting\n/cast Disengage",
	["Misdirection"] = "#showtooltip\n/cast [@mouseover,help,nodead][@focus,help,nodead][@target,help,nodead][@pet] Misdirection",
	["Counter Shot"] = "#showtooltip\n/stopcasting\n/cast [@focus,harm,nodead][@mouseover,harm][] Counter Shot",
	["Feign Death"] = "#showtooltip\n/stopcasting\n/cast Feign Death",
}
CT.MacroList['HUNTER'][3] = { -- Survival
	["Misdirection"] = "#showtooltip\n/cast [@mouseover,help,nodead][@focus,help,nodead][@target,help,nodead][@pet] Misdirection",
	["Feign Death"] = "#showtooltip\n/stopcasting\n/cast Feign Death",
	["Steel Trap / A Murder of Crows"] = "#showtooltip\n/cast [talent:4/2] Steel Trap; [talent4/3] A Murder of Crows"
}

CT.MacroList['MAGE'][1] = { -- Arcane
	["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
	["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
}
CT.MacroList['MAGE'][2] = { -- Fire
	["Combustion & Pyroblast"] = "#showtooltip Combustion\n/castsequence reset=30 Combustion, Pyroblast",
	["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
	["Flamestrike"] = "#showtooltip\n/cast [@cursor] Flamestrike",
	["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
	["Meteor"] = "#showtooltip\n/cast [@cursor] Meteor",
	["Scorch"] = "#showtooltip\n/cast [@focus,nodead,harm][] Scorch",
}
CT.MacroList['MAGE'][3] = { -- Frost
	["Blizzard"] = "#showtooltip\n/cast [@cursor] Blizzard",
	["Counterspell"] = "#showtooltip\n/stopcasting\n/cast [@focus,exists][] Counterspell",
	["Frostbolt"] = "#showtooltip\n/cast Frostbolt\n/petattack",
	["Ice Block"] = "#showtooltip\n/stopcasting\n/cast Ice Block\n/cancelaura Ice Block",
	["Water Elemental / Freeze"] = "#showtooltip\n/cast [pet] Freeze; Summon Water Elemental",
}

CT.MacroList['MONK'][1] = { -- Brewmaster
	["Bonedust Brew"] = "#showtooltip\n/cast [mod, @cursor][@player] Bonedust Brew",
	["Healing Elixir / Dampen Harm"] = "#showtooltip\n/cast [talent:5/2] Healing Elixir; [talent:5/3] Dampen Harm",
	["Provoke"] = "#showtooltip\n/cast [mod,@focus][] Provoke",
	["Spear Hand Strike"] = "#showtooltip\n/cast [mod:alt,@focus,exists][] Spear Hand Strike",
	["Taunt / Black Ox Statue"] = "#showtooltip\n/tar [mod] Black Ox Statue\n/cast [mod] Provoke; Summon Black Ox Statue\n/targetlasttarget [mod]",
	["Tiger's Lust"] = "#showtooltip /cast [@mouseover,help][@player] Tiger’s Lust",
}
CT.MacroList['MONK'][2] = { -- Mistweaver
	["Rising Sun Kick"] = "#showtooltip\n/stopmacro [channeling:Essence Font]\n/cast Rising Sun Kick",
	["Soothing Mist"] = "#showtooltip\n/cast [@mouseover,nodead,help][] Soothing Mist",
	["Tier 5 Talents"] = "#showtooltip\n/cast [talent:5/1] Healing Elixir; [talent:5/2] Diffuse Magic; [talent:5/3] Dampen Harm",
	["Tier 6 Talents"] = "#showtooltip\n/cast [talent:6/1] Summon Jade Serpent Statue; [talent:6/2] Refreshing Jade Wind; [talent:6/3] Invoke Chi-Ji, the Red Crane",
}
CT.MacroList['MONK'][3] = { -- Windwalker
	["Tier 1 Talents"] = "#showtooltip\n/stopmacro [channeling:Fists of Fury]\n/cast [talent:1/1] Eye of the Tiger; [talent:1/2] Chi Wave; [talent:1/3] Chi Burst",
	["Tier 5 Talents"] = "#showtooltip\n/cast [talent:5/1] Inner Strength; [talent:5/2] Diffuse Magic; [talent:5/3] Dampen Harm",
	["Tier 6 Talents"] = "#showtooltip\n/stopmacro [channeling:Fists of Fury]\n/cast [talent:6/1] Hit Combo; [talent:6/2] Rushing Jade Wind; [talent:6/3] Dance of Chi-Ji",
	["Tiger's Palm"] = "#showtooltip\n/stopmacro [channeling:Fists of Fury]\n/cast Tiger Palm",
}

CT.MacroList['PALADIN'][1] = { -- Holy
	["Divine Shield"] = "#showtooltip\n/stopcasting\n/cast [@mouseover,exists][@target,exists][@player] Divine Shield",
	["Holy Prism"] = "#showtooltip\n/cast [@mouseovertarget,harm,nodead][@target,harm,nodead][@mouseover,exists][@target,exists][@player] Holy Prism",
	["Holy Shock"] = "#showtooltip\n/cast [@mouseover,help,nodead][@target,help,nodead][@player] Holy Shock",
}
CT.MacroList['PALADIN'][2] = { -- Protection
	["Blessing of Sacrifice"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Blessing of Sacrifice",
	["Cleanse Toxins"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Cleanse Toxins",
	["Flash of Light"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Flash of Light",
	["Holy Avenger / Seraphim"] = "#showtooltip\n/cast [talent:5/2] Holy Avenger; [talent:5/3] Seraphim",
	["Lay on Hands"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Lay on Hands",
	["Repentance / Blinding Light"] = "#showtooltip\n/cast [talent:3/2] Repentance; [talent:3/3] Blinding Light",
	["Word of Glory"] = "#showtooltip\n/cast [@mouseover,help][@target,help,nodead][@player] Word of Glory",
}
CT.MacroList['PALADIN'][3] = { -- Retribution
	["Final Reckoning"] = "#showtooltip\n/cast [mod,@cursor][@player] Final Reckoning",
	["Holy Avenger / Seraphim"] = "#showtooltip\n/cast [talent:5/2] Holy Avenger; [talent:5/3] Seraphim",
	["Rebuke"] = "#showtooltip\n/cast [@focus,harm,nodead][] Rebuke",
}

CT.MacroList['PRIEST'][1] = { -- Discipline
	["Angelic Feather"] = "#showtooltip\n/cast [@player] Angelic Feather\n/stopspelltarget",
	["Mass Dispel"] = "#showtooltip\n/cast [mod,@cursor][] Mass Dispel",
	["Rapture"] = "#showtooltip\n/cast [talent:7/2] Mindbender\n/cast [talent:7/2] Spirit Shell; [@mouseover,help,nodead] Rapture",
	["Shadow Mend"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Shadow Mend",
}
CT.MacroList['PRIEST'][2] = { -- Holy
	["Angelic Feather"] = "#showtooltip\n/cast [@player] Angelic Feather\n/stopspelltarget",
	["Flash Heal"] = "#showtooltip\n/cast [@mouseover,help,nodead][] Flash Heal",
	["Mass Dispel"] = "#showtooltip\n/cast [mod,@cursor][] Mass Dispel",
}
CT.MacroList['PRIEST'][3] = { -- Shadow
	["Dispersion"] = "#showtooltip\n/cast Dispersion\n/cancelaura Dispersion",
	["Leap of Faith"] = "#showtooltip\n/cast [@mouseover,help,nodead][help,nodead] Leap of Faith",
	["Shadow Crash"] = "#showtooltip\n/cast [mod,@cursor][] Shadow Crash",
	["Shadow Word: Pain"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Shadow Word: Pain",
	["Shadowfiend"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Shadowfiend",
	["Silence"] = "#showtooltip\n/cast [@focus,exists][] Silence",
	["Vampiric Touch"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Vampiric Touch",
	["Void Eruption"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Void Eruption",
}

CT.MacroList['ROGUE'][1] = { -- Assassination
	["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
	["Shadowstep"] = "#showtooltip\n/cast [@mouseover,exists,nodead][] Shadowstep",
	["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
}
CT.MacroList['ROGUE'][2] = { -- Outlaw
	["Blade Rush / Killing Spree"] = "#showtooltip\n/cast [talent:7/2] Blade Rush; [talent:7/3] Killing Spree",
	["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
	["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
}
CT.MacroList['ROGUE'][3] = { -- Subtlety
	["Marked for Death"] = "#showtooltip\n/cast [@mouseover,harm,nodead][] Marked for Death",
	["Secret Technique / Shuriken Tornado"] = "#showtooltip\n/cast [talent:7/2] Secret Technique; [talent:7/3] Shuriken Tornado",
	["Shadowstep"] = "#showtooltip\n/cast [@mouseover,exists,nodead][] Shadowstep",
	["Shadowstrike"] = "#showtooltip\n/cast [stance:0] Shadow Dance\n/cast Shadowstrike",
	["Tricks of the Trade"] = "#showtooltip\n/cast [@focus,exists][] Tricks of the Trade",
}

CT.MacroList['SHAMAN'][1] = { -- Elemental
	["Bloodlust"] = "#showtooltip\n/stopmacro [nocombat]\n/cast Bloodlust",
	["Earthquake"] = "#showtooltip\n/cast [@cursor] Earthquake",
	["Primal Storm/Fire"] = "#showtooltip\n/cast Call Lightning\n/cast [talent:4/2,talent:6/2] !Eye of the Storm; [talent:6/2] Meteor",
	["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
}
CT.MacroList['SHAMAN'][2] = { -- Enhancement
	["Healing Surge"] = "#showtooltip\n/stopcasting\n/cast [@mouseover,exists][@player] Healing Surge",
	["Wind Rush Totem"] = "#showtooltip\n/stopcasting\n/cast [mod,@cursor][@player] Wind Rush Totem",
	["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
}
CT.MacroList['SHAMAN'][3] = { -- Restoration
	["Healing Rain"] = "#showtooltip\n/use [mod,@cursor][@player] Healing Rain",
	["Tier 4 Talents"] = "#showtooltip\n/use [talent:4/2] Earthen Wall Totem; [talent:4/3] Ancestral Protection Totem",
	["Tier 7 Talents"] = "#showtooltip\n/use [talent:7/2] Wellspring; [talent:7/3] Ascendance",
	["Wind Shear"] = "#showtooltip\n/stopcasting\n/use [@focus,exists][@target] Wind Shear",
}

CT.MacroList['WARLOCK'][1] = { -- Affliction
	["Agony"] = "#showtooltip\n/cast [@mouseover,exists][] Agony",
	["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
	["Vile Taint / Phantom Singularity"] = "#showtooltip\n/cast [@cursor,talent:4/3][talent:4/3] Vile Taint; [talent:4/2] Phantom Singularity",
}
CT.MacroList['WARLOCK'][2] = { -- Demonology
	["Shadowfury"] = "#showtooltip\n/cast [@cursor] Shadowfury",
	["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
}
CT.MacroList['WARLOCK'][3] = { -- Destruction
	["Cataclysm"] = "#showtooltip\n/cast [@cursor] Cataclysm",
	["Channel Demonfire / Dark Soul"] = "#showtooltip\n/cast [talent:7/2] Channel Demonfire; [talent:7/3] Dark Soul: Instability",
	["Havoc"] = "#showtooltip\n/cast [@mouseover,exists][] Havoc",
	["Rain of Fire"] = "#showtooltip\n/cast [@cursor] Rain of Fire",
	["Shadowfury"] = "#showtooltip\n/cast [@cursor] Shadowfury",
	["Soulstone"] = "#showtooltip\n/cast [@mouseover,exists][] Soulstone",
	["Summon Infernal"] = "#showtooltip\n/cast [@cursor] Summon Infernal",
}

CT.MacroList['WARRIOR'][1] = { -- Arms
	["Avatar or Deadly Calm"] = "#showtooltip\n/cast [talent:6/2] Avatar; [talent:6/3] Deadly Calm",
	["Charge / Victory Rush"] = "#showtooltip\n/cast Charge\n/cast Victory Rush",
	["Fervor of Battle"] = "#showtooltip\n/cast [talent:3/2] Whirlwind; Slam",
	["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
	["Pummel"] = "#showtooltip Pummel\n/cast [@focus,harm][] Pummel",
}
CT.MacroList['WARRIOR'][2] = { -- Fury
	["Charge / Victory Rush"] = "#showtooltip\n/cast Charge\n/cast Victory Rush",
	["Dragon Roar / Bladestorm"] = "#showtooltip\n/cast [talent:6/2] Dragon Roar; [talent:6/3] Bladestorm",
	["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
	["Pummel"] = "#showtooltip Pummel\n/cast [@focus,harm][] Pummel",
}
CT.MacroList['WARRIOR'][3] = { -- Protection
	["Charge"] = "#showtooltip Charge\n/cast [mod,@focus,harm][] Charge",
	["Heroic Leap"] = "#showtooltip Heroic Leap\n/cast [mod,@cursor][] Heroic Leap",
	["Intervene"] = "#showtooltip Intervene\n/cast [mod,@focus,harm][] Intervene",
	["Pummel"] = "#showtooltip Pummel\n/cast [mod,@focus,harm][] Pummel",
	["Shockwave / Storm Bolt"] = "#showtooltip\n/cast [notalent:2/3] Shockwave; [talent:2/3] Storm Bolt",
	["Taunt"] = "/cast [mod,@focus,exists][] Taunt",
}
