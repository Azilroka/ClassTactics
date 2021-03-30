local AddOnName, Engine = ...
local AddOn = _G.LibStub('AceAddon-3.0'):NewAddon('ClassTactics', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0', 'AceSerializer-3.0')

Engine[1] = AddOn
--Engine[2] = _G.LibStub("AceLocale-3.0"):GetLocale('ClassTactics', false)

_G.ClassTactics = AddOn

_G.ClassTactics = Engine
_G.ClassTactics.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
_G.ClassTactics.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

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
function AddOn:IsAddOnEnabled(addon, character)
	if (type(character) == 'boolean' and character == true) then
		character = nil
	end
	return GetAddOnEnableState(character, addon) == 2
end

AddOn.Title = GetAddOnMetadata(AddOnName, 'Title')
AddOn.Version = tonumber(GetAddOnMetadata(AddOnName, 'Version'))
AddOn.ProperVersion = format('%.2f', AddOn.Version)
AddOn.Authors = GetAddOnMetadata(AddOnName, 'Author'):gsub(", ", "    ")
AddOn.MyClass = select(2, UnitClass('player'))
AddOn.MyName = UnitName('player')
AddOn.MyRealm = GetRealmName()
AddOn.TexCoords = {.08, .92, .08, .92}
AddOn.TicketTracker = 'https://git.tukui.org/Azilroka/ClassTactics/issues'

AddOn.Libs = {
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
}

AddOn.AddOnSkins = AddOn:IsAddOnEnabled('AddOnSkins', AddOn.MyName)

local Color = _G.RAID_CLASS_COLORS[AddOn.MyClass]
AddOn.ClassColor = { Color.r, Color.g, Color.b }
