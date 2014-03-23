-- **********************************************************************
-- GnomTECWidgetPanelButton
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECWidgetPanelButton-1.0", 1
local _widget, _oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not _widget then return end -- No Upgrade needed.

-- ----------------------------------------------------------------------
-- Widget Global Constants (local)
-- ----------------------------------------------------------------------
-- localization (will be loaded from base class later)
local L = {}

-- texture path (will be loaded from base class later)
local T = ""

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

function GnomTECWidgetPanelButton(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	
	-- private methods
	-- local function f()
	local function OnClick(frame, button)
		self.SafeCall(self.OnClick, self, button)
	end

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetPanelButton", message, ...)
	end

	function self.GetMinReseize()
		local minWidth = protected.widgetFrame:GetTextWidth() + 10
		local minHeight = 24
		
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
		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(24)

		return pixelWidth, 24
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(24)

		return pixelWidth, 24
	end
	
	function self.Disable()
		protected.widgetFrame:Disable()
	end

	function self.Enable()
		protected.widgetFrame:Enable()
	end
	
	-- constructor
	do
		-- get localization first.
		L = protected.GetLocale()

		-- get texture path
		T = protected.GetTexturePath()	

		if (not init) then
			init = {}
		end
		
		local widgetFrame = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
		widgetFrame:Hide()

		protected.widgetFrame = widgetFrame 
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			widgetFrame:SetWidth("16")		
		end
		
		protected.widgetHeight = 24
		protected.widgetHeightIsRelative = false
		widgetFrame:SetHeight(protected.widgetHeight)
		
		widgetFrame:SetText(init.label or "")				
		widgetFrame:SetScript("OnClick",OnClick)
		
		if (init.disabled) then
			self.Disable()
		end
		
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetPanelButton", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


