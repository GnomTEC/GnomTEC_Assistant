-- **********************************************************************
-- GnomTECWidgetDropDownButton
-- Version: 6.0.2.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2014 by Peter Jack
--
-- Licensed under the EUPL, Version 1.1 only (the "Licence");
-- You may not use this work except in compliance with the Licence.
-- You may obtain a copy of the Licence at:
--
-- http://ec.europa.eu/idabc/eupl5
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the Licence is distributed on an "AS IS" basis,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Licence for the specific language governing permissions and
-- limitations under the Licence.
-- **********************************************************************
local MAJOR, MINOR = "GnomTECWidgetDropDownButton-1.0", 1
local _widget, _oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not _widget then return end -- No Upgrade needed.

-- ----------------------------------------------------------------------
-- Widget Global Constants (local)
-- ----------------------------------------------------------------------
-- localization 
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")

-- texure path
local T = [[Interface\Addons\]].. ... ..[[\GnomTEC\Textures\]]

-- Class levels
local CLASS_BASE		= 0
local CLASS_CLASS		= 1
local CLASS_WIDGET	= 2
local CLASS_ADDON		= 3

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Widget Static Variables (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Widget Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetDropDownButton(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.fontString = nil
	protected.values = nil
	protected.selectedValue = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	
	-- private methods
	-- local function f()
	local function OnClick(frame, button)
		protected.selectedValue = frame.value
		UIDropDownMenu_SetSelectedValue(protected.widgetFrame, protected.selectedValue); 
		self.SafeCall(self.OnClick, self, button)
	end

	local function Dropdown_Initialize()
		local info = UIDropDownMenu_CreateInfo()
		info.func = OnClick

		for value, text in pairs(protected.values) do
			info.value = value
			info.text = text
			UIDropDownMenu_AddButton(info);
		end	
		
		UIDropDownMenu_SetSelectedValue(protected.widgetFrame, protected.selectedValue);
	end 
	
	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetDropDownButton", message, ...)
	end

	function self.GetMinReseize()
		local minWidth = 0
		local minHeight = 24

		for value, text in pairs(protected.values) do
			protected.fontString:SetText(text)
			local width = protected.fontString:GetStringWidth() + 30
			if (width > minWidth) then
				minWidth = width
			end
		end	
		
		minWidth = minWidth + 48
		
		return minWidth, minHeight
	end

	function self.GetMaxReseize()		
		local maxWidth = UIParent:GetWidth()
		local maxHeight = 24

		return maxWidth, maxHeight
	end

	function self.IsHeightDependingOnWidth()
		return false
	end

	function self.IsWidthDependingOnHeight()
		return false
	end

	function self.ResizeByWidth(pixelWidth, pixelHeight)
		UIDropDownMenu_SetWidth(protected.widgetFrame, pixelWidth-50, 50);
		protected.widgetFrame:SetHeight(24)

		return pixelWidth, 24
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		UIDropDownMenu_SetWidth(protected.widgetFrame, pixelWidth-50, 50);
		protected.widgetFrame:SetHeight(24)

		return pixelWidth, 24
	end
	
	function self.Disable()
--		protected.widgetFrame:Disable()
	end

	function self.Enable()
--		protected.widgetFrame:Enable()
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end
		
		local widgetFrame = CreateFrame("Frame", protected.widgetUID, UIParent, "T_GNOMTECWIDGETDROPDOWNBUTTON")
		local fontString = widgetFrame:CreateFontString(nil, nil, "T_GNOMTECWIDGETDROPDOWNBUTTON_FONTSTRING")
		widgetFrame:Hide()

		protected.widgetFrame = widgetFrame 
		protected.fontString = fontString
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			widgetFrame:SetWidth("48")		
		end
		
		protected.widgetHeight = 24
		protected.widgetHeightIsRelative = false
		widgetFrame:SetHeight(protected.widgetHeight)
		
		if (type(init.values) == "table") then
			protected.values = init.values
		else
			protected.values = {}
		end

		if (init.selectedValue) then
			protected.selectedValue = init.selectedValue
		else
			protected.selectedValue = next(protected.values)
		end
		
		UIDropDownMenu_Initialize(protected.widgetFrame, Dropdown_Initialize);
				
		if (init.disabled) then
			self.Disable()
		end
		
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetDropDownButton", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


