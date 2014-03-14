-- **********************************************************************
-- GnomTECWidget
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Widget Global Constants (local)
-- ----------------------------------------------------------------------
-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Widget Static Variables (local)
-- ----------------------------------------------------------------------
local lastUID = 0

-- ----------------------------------------------------------------------
-- Widget Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidget(title, parent)
	-- the new instance
	local self = {}
	
	-- public fields go in the instance table
	-- self.field = value

	-- create protected table
	local protected = {}

	-- protected fields go in the protected table
	-- protected.field = value
	protected.widgetParent = nil
	protected.widgetTitle = nil
	protected.widgetUID = nil
	protected.widgetFrame = nil

	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
		
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	function protected.LogMessage(level, message, ...)
		GnomTEC:LogMessage(nil, level, message, ...)
	end
	
	-- public methods
	function self.Show()
		if (not self.IsShown()) then
			protected.widgetFrame:Show()
			self.TriggerResize(self, 0, 0)
		end
	end

	function self.Hide()
		if (self.IsShown()) then
			protected.widgetFrame:Hide()
			self.TriggerResize(self, 0, 0)
		end
	end

	function self.IsShown()
		return protected.widgetFrame:IsShown()
	end
	
	function self.GetPixelWidth()
		return protected.widgetFrame:GetWidth()
	end

	function self.GetPixelHeight()
		return protected.widgetFrame:GetHeight()
	end
	
	function self.GetMinReseize()
		return 0 , 0
	end

	function self.GetMaxReseize()
		return UIParent:GetWidth(), UIParent:GetHeight()
	end

	function self.IsProportionalReseize()
		return false
	end
	
	function self.ResizeByWidth(pixelWidth)
		-- we don't change the size in base classes as we don't know what to do
		-- but we can support derived classes with standard values
		return self.GetPixelHeight()
	end

	function self.ResizeByHeight(pixelHeight)
		-- we don't change the size in base classes as we don't know what to do
		-- but we can support derived classes with standard values
		return self.GetPixelWidth()
	end
		
	function self.TriggerResize(widget, dx, dy)
		if (protected.widgetParent) then
			protected.widgetParent.TriggerResize(self,dx, dy)
		end
	end
	
	function self.GetWidgetUID()
		return protected.widgetUID
	end
	
	function self.SetTitle(title)
		protected.widgetTitle = title
	end

	function self.GetTitle()
		return protected.widgetTitle
	end
	
	-- constructor
	do
		lastUID = lastUID + 1
		protected.widgetUID = "GnomTECWidgetInstance"..lastUID
		protected.widgetParent = parent
		protected.widgetTitle = title
		
		protected.LogMessage(LOG_DEBUG, "New GnomTECWidget instance created (%s)", protected.widgetUID)
	end
	
	-- return the instance and protected table
	return self, protected
end


