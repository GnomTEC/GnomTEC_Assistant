-- **********************************************************************
-- GnomTECWidgetContainerLayoutFill
-- Version: 5.4.8.1
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
local MAJOR, MINOR = "GnomTECWidgetContainerLayoutFill-1.0", 1
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

function GnomTECWidgetContainerLayoutFill(init)

	-- call base class
	local self, protected = GnomTECWidgetContainer(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetContainerLayoutFill", message, ...)
	end


	local base_ResizeByWidth = self.ResizeByWidth
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		pixelWidth, pixelHeight = base_ResizeByWidth(pixelWidth, pixelHeight)

		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(pixelHeight)

		return pixelWidth, pixelHeight
	end

	local base_ResizeByHeight = self.ResizeByHeight
	function self.ResizeByHeight(pixelWidth, pixelHeight)
		pixelWidth, pixelHeight = base_ResizeByHeight(pixelWidth, pixelHeight)

		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(pixelHeight)

		return pixelWidth, pixelHeight
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end

		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		local containerFrame = widgetFrame
		local labelFontString = containerFrame:CreateFontString()

		protected.widgetFrame = widgetFrame 
		protected.containerFrame = containerFrame 
		protected.labelFontString = labelFontString

		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			widgetFrame:SetWidth(400)		
		end
		local h, r = self.GetHeight()
		if (not r) then
			widgetFrame:SetHeight(h)		
		else
			widgetFrame:SetHeight(200)
		end

		labelFontString:SetFontObject(GameFontNormal)
		labelFontString:SetJustifyH("CENTER")
		labelFontString:SetTextColor(0.5, 0.5, 0.5, 1.0)
		labelFontString:SetWidth("32")		
		labelFontString:SetHeight("14")
		labelFontString:SetPoint("TOPLEFT", 0, -3)
		labelFontString:SetPoint("RIGHT")

		self.SetLabel(init.label)

		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetContainerLayoutFill", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self
end


