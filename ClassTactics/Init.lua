local AddOnName, Engine = ...
local CT = _G.LibStub('AceAddon-3.0'):NewAddon('ClassTactics', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0', 'AceSerializer-3.0')

Engine[1] = CT
--Engine[2] = _G.LibStub("AceLocale-3.0"):GetLocale('ClassTactics', false)

_G.ClassTactics = Engine

CT.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
CT.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
CT.BCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local _G = _G
local select = select
local tonumber = tonumber
local type = type
local format = format

local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnMetadata = GetAddOnMetadata
local GetRealmName = GetRealmName
local UnitClass, UnitName = UnitClass, UnitName

-- Project Data
function CT:IsAddOnEnabled(addon, character)
	if (type(character) == 'boolean' and character == true) then
		character = nil
	end
	return GetAddOnEnableState(character, addon) == 2
end

CT.Title = GetAddOnMetadata(AddOnName, 'Title')
CT.Version = tonumber(GetAddOnMetadata(AddOnName, 'Version'))
CT.ProperVersion = format('%.2f', CT.Version)
CT.Authors = GetAddOnMetadata(AddOnName, 'Author'):gsub(", ", "    ")
CT.MyClass = select(2, UnitClass('player'))
CT.MyName = UnitName('player')
CT.MyRealm = GetRealmName()
CT.TexCoords = {.075, .925, .075, .925}
CT.TicketTracker = 'https://git.tukui.org/Azilroka/ClassTactics/issues'

CT.Libs = {
	LSM = _G.LibStub('LibSharedMedia-3.0', true),
	ACH = _G.LibStub('LibAceConfigHelper'),
	Compress = _G.LibStub('LibCompress'),
	Base64 = _G.LibStub('LibBase64-1.0-ElvUI'),
	AC = _G.LibStub('AceConfig-3.0'),
	GUI = _G.LibStub('AceGUI-3.0'),
	ACR = _G.LibStub('AceConfigRegistry-3.0'),
	ACD = _G.LibStub('AceConfigDialog-3.0'),
	ACL = Engine[2],
	ADB = _G.LibStub('AceDB-3.0'),
	LCS = _G.LibStub("LibClassicSpecs", true)
}

CT.AddOnSkins = CT:IsAddOnEnabled('AddOnSkins', CT.MyName)

local Color = _G.RAID_CLASS_COLORS[CT.MyClass]
CT.ClassColor = { Color.r, Color.g, Color.b }
