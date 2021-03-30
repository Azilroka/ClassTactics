-- Widgets created by Adirelle

local AceGUI = LibStub("AceGUI-3.0")

-- Localization
local L_ACTIONTYPE = {
	spell = "Spell",
	macro = "Macro",
	item = "Item",
	equipmentset = "Equipment Set",
}

if GetLocale() == "frFR" then
	 L_ACTIONTYPE.spell = "Sort"
	 L_ACTIONTYPE.item = "Objet"
	 L_ACTIONTYPE.equipmentset = "Set"
end

local widgetVersion = 2

--------------------------------------------------------------------------------
-- Abtract action slot
--------------------------------------------------------------------------------

local BaseConstructor

do

	local function OnAcquire(self)
		self:SetWidth(200)
		self:SetHeight(44)
		self:SetDisabled(false)
		self:SetLabel()
	end

	local function OnRelease(self)
		self.rejectIcon:Hide()
		self.frame:ClearAllPoints()
		self.frame:Hide()
		self:SetDisabled(false)
		self:SetText()
	end

	local spellbooks = { "spell", "pet" }
	local companionTypes = { "MOUNT", "CRITTER" }

	local function Pickup(actionType, actionData)
		if actionType == "item" then
			return PickupItem(actionData)
		elseif actionType == "macro" then
			return PickupMacro(actionData)
		elseif actionType == "equipmentset" then
			return PickupEquipmentSetByName(actionData)
		elseif actionType == "spell" then
			local pattern = "spell:"..actionData.."|"
			for i, book in pairs(spellbooks) do
				local index, link = 1, GetSpellLink(1, book)
				while link do
					if link:match(pattern) then
						return PickupSpell(index, book)
					else
						index = index + 1
						link = GetSpellLink(index, book)
					end
				end
			end
			for i, companionType in pairs(companionTypes) do
				for index = 1, GetNumCompanions(companionType) do
					local _, _, spellId = GetCompanionInfo(companionType, index)
					if spellId == actionData then
						return PickupCompanion(companionType, index)
					end
				end
			end
		end
		ClearCursor()
	end

	local function ParseActionInfo(actionType, data1, data2)
		if actionType == "companion" then
			local _, _, spellId = GetCompanionInfo(data2, data1)
			return true, "spell", spellId
		elseif actionType == "spell" then
			local link = GetSpellLink(data1, data2)
			if link then
				return true, "spell", tonumber(link:match("spell:(%d+)"))
			end
		elseif actionType == "item" then
			return true, "item", data1
		elseif actionType == "macro" then
			return true, "macro", (GetMacroInfo(data1))
		elseif actionType == "equipmentset" then
			return true, "equipmentset", (GetEquipmentSetInfo(data1))
		elseif actionType == "action" then
			return ParseActionInfo(GetActionInfo(data1))
		end
		return actionType and true or false
	end

	local function ParseCursorInfo()
		return ParseActionInfo(GetCursorInfo())
	end

	local function Button_OnEnter(this)
		local self = this.obj
		local hasAction, actionType = ParseCursorInfo()
		if hasAction and not self:AcceptActionType(actionType) then
			self.rejectIcon:Show()
		else
			self.rejectIcon:Hide()
		end
		self:Fire("OnEnter")
	end

	local function Button_OnLeave(this)
		local self = this.obj
		self.rejectIcon:Hide()
		self:Fire("OnLeave")
	end

	local function SetNewAction(self, newType, newData)
		local oldType, oldData = self.actionType, self.actionData
		if newType ~= oldType or newData ~= oldData then
			local value = newType and newData and self:BuildValue(newType, newData)
			self:Fire("OnEnterPressed", value)
			if self.actionType ~= oldType or self.actionData ~= oldData then
				Pickup(oldType, oldData)
			end
		end
	end

	local function Button_OnReceiveDrag(this)
		local self = this.obj
		local hasAction, actionType, actionData = ParseCursorInfo()
		if hasAction and actionType and actionData and self:AcceptActionType(actionType) then
			SetNewAction(self, actionType, actionData)
		end
	end

	local function Button_OnDragStart(this)
		SetNewAction(this.obj)
	end

	local function Button_OnClick(this, button)
		if button == "RightButton" then
			this.obj:Fire("OnEnterPressed", "")
		else
			return Button_OnReceiveDrag(this)
		end
	end

	local function SetText(self, text)
		local actionType, actionData, name, texture
		if text and text ~= "" then
			actionType, actionData, name, texture = self:ParseValue(tostring(text))
		end
		if actionType and actionData and name and texture and self:AcceptActionType(actionType) then
			self.actionType, self.actionData = actionType, actionData
			self.button:SetNormalTexture([[Interface\Buttons\UI-Quickslot2]])
			self.icon:SetTexture(texture)
			self:SetActionText(L_ACTIONTYPE[actionType] or actionType, name)
			self.text:Show()
			self.icon:Show()
		else
			self.actionType, self.actionData = nil, nil
			self.button:SetNormalTexture([[Interface\Buttons\UI-Quickslot]])
			self.text:Hide()
			self.icon:Hide()
		end
	end

	local function OnHeightSet(self, height)
		local button = self.button
		local icon = self.icon
		local tex = button:GetNormalTexture()
		local size = height
		if self.label:IsShown() then
			size = size - self.label:GetHeight() - 8
		end
		size = math.min(size, 36)
		button:SetWidth(size)
		button:SetHeight(size)
		tex:SetWidth(size*60/36)
		tex:SetHeight(size*60/36)
		icon:SetWidth(size)
		icon:SetHeight(size)
	end

	local function SetLabel(self, label)
		if label and label ~= "" then
			self.label:SetText(label)
			self.label:Show()
		else
			self.label:SetText("")
			self.label:Hide()
		end
		OnHeightSet(self, self.frame:GetHeight())
	end

	local function SetDisabled(self, disabled)
		if disabled then
			self.button:EnableMouse(false)
			self.icon:SetDesaturated(true)
			self.label:SetTextColor(0.5,0.5,0.5)
			self.text:SetTextColor(0.5,0.5,0.5)
		else
			self.button:EnableMouse(true)
			self.icon:SetDesaturated(false)
			self.label:SetTextColor(1,.82,0)
			self.text:SetTextColor(1,1,1)
		end
	end

	function BaseConstructor(self)
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire

		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet

		self.SetLabel = SetLabel
		self.SetText = SetText
		self.SetDisabled = SetDisabled

		local frame = CreateFrame("Frame")
		frame:SetWidth(200)
		frame:SetHeight(128)
		frame.obj = self
		self.frame = frame

		local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("TOPLEFT")
		label:SetPoint("TOPRIGHT")
		label:SetJustifyH("LEFT")
		label:SetHeight(10)
		self.label = label

		local button = CreateFrame("Button", nil, frame)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:RegisterForDrag("LeftButton")
		button:SetPoint("BOTTOMLEFT",4,4)
		button:SetWidth(29)
		button:SetHeight(29)
		button:SetNormalTexture([[Interface\Buttons\UI-Quickslot]])
		button:SetPushedTexture([[Interface\Buttons\UI-Quickslot-Depress]])
		button:GetPushedTexture():SetBlendMode('ADD')
		button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
		button:GetHighlightTexture():SetBlendMode('ADD')
		button:SetScript('OnDragStart', Button_OnDragStart)
		button:SetScript('OnReceiveDrag', Button_OnReceiveDrag)
		button:SetScript('OnClick', Button_OnClick)
		button:SetScript('OnEnter', Button_OnEnter)
		button:SetScript('OnLeave', Button_OnLeave)
		button.obj = self
		self.button = button

		local tex = button:GetNormalTexture()
		tex:ClearAllPoints()
		tex:SetPoint("CENTER")

		local icon = button:CreateTexture("BACKGROUND")
		icon:SetPoint("CENTER")
		self.icon = icon

		local rejectIcon = frame:CreateTexture("OVERLAY")
		rejectIcon:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
		rejectIcon:SetAllPoints(icon)
		rejectIcon:Hide()
		self.rejectIcon = rejectIcon

		local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		text:SetPoint("TOPLEFT", button, "TOPRIGHT", 2, 0)
		text:SetPoint("BOTTOMRIGHT")
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		--text:SetWordWrap(false)
		self.text = text

		self:OnHeightSet(128)

		AceGUI:RegisterAsWidget(self)
		return self
	end
end

--------------------------------------------------------------------------------
-- Generic action slot
--------------------------------------------------------------------------------

do
	local function AcceptActionType(self, actionType)
		return actionType == "item" or actionType == "spell" or actionType == "macro" or actionType == "equipmentset"
	end

	local function BuildValue(self, actionType, actionData)
		return strjoin(":", tostringall(actionType, actionData))
	end

	local function ParseValue(self, value)
		local itemId = tonumber(value:match("item:(%d+)"))
		if itemId then
			local name, _, _, _,  _, _, _, _,  _, texture = GetItemInfo(itemId)
			return "item", itemId, name, texture
		end
		local spellId = tonumber(value:match("spell:(%d+)"))
		if spellId then
			local name, _, texture = GetSpellInfo(spellId)
			return "spell", spellId, name, texture
		end
		local macroName = value:match("macro:([^:]+)")
		if macroName then
			local name, texture = GetMacroInfo(macroName:trim())
			return "macro", name, name, texture
		end
		local setName = value:match("equipmentset:([^:]+)")
		if setName then
			setName = setName:trim():lower()
			for i = 1, GetNumEquipmentSets() do
				local name, texture = GetEquipmentSetInfo(i)
				if setName:lower() == name then
					return "equipmentset", name, name, texture
				end
			end
		end
	end

	local function SetActionText(self, actionType, name)
		self.text:SetFormattedText("%s: %s", actionType, name)
	end

	local widgetType = "ActionSlot"

	local function Constructor()
		return BaseConstructor{
			type = widgetType,
			AcceptActionType = AcceptActionType,
			ParseValue = ParseValue,
			BuildValue = BuildValue,
			SetActionText = SetActionText,
		}
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end

--------------------------------------------------------------------------------
-- Item-only action slot
--------------------------------------------------------------------------------

do
	local function AcceptActionType(self, actionType)
		return actionType == "item"
	end

	local function BuildValue(self, actionType, actionData)
		return tostring(actionData)
	end

	local function ParseValue(self, value)
		local itemId = tonumber(value) or tonumber(value:match("item:(%d+)"))
		if itemId then
			local name, _, _, _,  _, _, _, _,  _, texture = GetItemInfo(itemId)
			return "item", itemId, name, texture
		end
	end

	local function SetActionText(self, actionType, name)
		self.text:SetText(name)
	end

	local widgetType = "ActionSlotItem"

	local function Constructor()
		return BaseConstructor{
			type = widgetType,
			AcceptActionType = AcceptActionType,
			ParseValue = ParseValue,
			BuildValue = BuildValue,
			SetActionText = SetActionText,
		}
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end

--------------------------------------------------------------------------------
-- Spell-only action slot
--------------------------------------------------------------------------------

do
	local function AcceptActionType(self, actionType)
		return actionType == "spell"
	end

	local function BuildValue(self, actionType, actionData)
		return tostring(actionData)
	end

	local function ParseValue(self, value)
		local spellId = tonumber(value) or tonumber(value:match("spell:(%d+)"))
		if spellId then
			local name, _, texture = GetSpellInfo(spellId)
			return "spell", spellId, name, texture
		end
	end

	local function SetActionText(self, actionType, name)
		self.text:SetText(name)
	end

	local widgetType = "ActionSlotSpell"

	local function Constructor()
		return BaseConstructor{
			type = widgetType,
			AcceptActionType = AcceptActionType,
			ParseValue = ParseValue,
			BuildValue = BuildValue,
			SetActionText = SetActionText,
		}
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end

--------------------------------------------------------------------------------
-- Macro-only action slot
--------------------------------------------------------------------------------

do
	local function AcceptActionType(self, actionType)
		return actionType == "macro"
	end

	local function BuildValue(self, actionType, actionData)
		return tostring(actionData)
	end

	local function ParseValue(self, value)
		local macroName = value:match("macro:([^:]+)") or value
		if macroName then
			local name, texture = GetMacroInfo(macroName:trim())
			return "macro", name, name, texture
		end
	end

	local function SetActionText(self, actionType, name)
		self.text:SetText(name)
	end

	local widgetType = "ActionSlotMacro"

	local function Constructor()
		return BaseConstructor{
			type = widgetType,
			AcceptActionType = AcceptActionType,
			ParseValue = ParseValue,
			BuildValue = BuildValue,
			SetActionText = SetActionText,
		}
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end

--------------------------------------------------------------------------------
-- Equipmentset-only action slot
--------------------------------------------------------------------------------

do
	local function AcceptActionType(self, actionType)
		return actionType == "equipmentset"
	end

	local function BuildValue(self, actionType, actionData)
		return tostring(actionData)
	end

	local function SetActionText(self, actionType, name)
		self.text:SetText(name)
	end

	local function ParseValue(self, value)
		local setName = value:match("equipmentset:([^:]+)") or value
		if setName then
			setName = setName:trim():lower()
			for i = 1, GetNumEquipmentSets() do
				local name, texture = GetEquipmentSetInfo(i)
				if setName:lower() == name then
					return "equipmentset", name, name, texture
				end
			end
		end
	end

	local widgetType = "ActionSlotEquipmentSet"

	local function Constructor()
		return BaseConstructor{
			type = widgetType,
			AcceptActionType = AcceptActionType,
			ParseValue = ParseValue,
			BuildValue = BuildValue,
			SetActionText = SetActionText,
		}
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end



