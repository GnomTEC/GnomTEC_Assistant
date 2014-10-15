-- **********************************************************************
-- GnomTECWidget
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
local MAJOR, MINOR = "GnomTECWidget-1.0", 1
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
local lastUID = 0

-- ----------------------------------------------------------------------
-- Widget Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidget(init)
	-- call base class
	local self, protected = GnomTEC()
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.widgetName = nil
	protected.widgetDb = nil
	protected.widgetParent = nil
	protected.widgetUID = nil
	protected.widgetFrame = nil
	protected.widgetWidth = nil
	protected.widgetHeight = nil
	protected.widgetWidthIsRelative = nil
	protected.widgetHeightIsRelative = nil
	protected.widgetLabel = nil
	

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
		protected.LogMessage(CLASS_CLASS, logLevel, "GnomTECWidget", message, ...)
	end

	function self.Show()
		if (not self.IsShown()) then
			protected.widgetFrame:Show()
			self.TriggerResize(self, 0, 0)
			self.SafeCall(self.OnShow,self)
		end
	end

	function self.Hide()
		if (self.IsShown()) then
			protected.widgetFrame:Hide()
			self.TriggerResize(self, 0, 0)
			self.SafeCall(self.OnHide,self)
		end
	end

	function self.IsShown()
		return protected.widgetFrame:IsShown()
	end
	
	function self.GetPixelWidth()
		return floor(protected.widgetFrame:GetWidth())
	end

	function self.GetPixelHeight()
		return floor(protected.widgetFrame:GetHeight())
	end
	
	function self.GetMinReseize()
		return 0 , 0
	end

	function self.GetMaxReseize()
		return UIParent:GetWidth(), UIParent:GetHeight()
	end

	function self.IsHeightDependingOnWidth()
		return false
	end

	function self.IsWidthDependingOnHeight()
		return false
	end
	
	function self.PrepareResize()
	end
	
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		-- we don't change the size in base classes as we don't know what to do
		-- but we can support derived classes with standard values
		return pixelWidth, pixelHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		-- we don't change the size in base classes as we don't know what to do
		-- but we can support derived classes with standard values
		return pixelWidth, pixelHeight
	end
		
	function self.TriggerResize(widget, dx, dy)
		if (protected.widgetParent) then
			protected.widgetParent.TriggerResize(self,dx, dy)
		end
	end

	function self.SaveSize()
		if (protected.widgetDb) then
			protected.widgetDb.width = protected.widgetWidth
			protected.widgetDb.widthUnit = protected.widgetWidthUnit
			protected.widgetDb.height = protected.widgetHeight
			protected.widgetDb.heightUnit = protected.widgetHeightUnit
		end
	end
	
	function self.GetWidgetUID()
		return protected.widgetUID
	end
	
	function self.GetWidth()
		return protected.widgetWidth, protected.widgetWidthIsRelative
	end

	function self.GetHeight()
		return protected.widgetHeight,  protected.widgetHeightIsRelative
	end

	function self.SetLabel(label)
		protected.widgetLabel = emptynil(label)
	end	

	function self.GetLabel()
		return emptynil(protected.widgetLabel)
	end	
	
	
	
	-- constructor
	do
		lastUID = lastUID + 1
		protected.widgetUID = "GnomTECWidgetInstance"..lastUID

		if (not init) then
			init = {}
		end
		
		protected.widgetParent = init.parent
		
		-- get default values
		local width, widthUnit = string.match(init.width or "", "(%d+)(.)")
		local height, heightUnit = string.match(init.height or "", "(%d+)(.)")

		-- if widget have a name and a database then we can store frame positions 
		if (init.db and init.name) then
			protected.widgetName = init.name
			if not (init.db.char.GnomTECWidgets) then
				-- we are the first widget using the db so we have to create our table
				init.db.char.GnomTECWidgets = {}
			end
			if not (init.db.char.GnomTECWidgets[protected.widgetName]) then
				init.db.char.GnomTECWidgets[protected.widgetName] = {}
				protected.widgetDb = init.db.char.GnomTECWidgets[protected.widgetName]
				protected.widgetDb.width = width
				protected.widgetDb.widthUnit = widthUnit
				protected.widgetDb.height = height
				protected.widgetDb.heightUnit = heightUnit
			else
				protected.widgetDb = init.db.char.GnomTECWidgets[protected.widgetName]
			end

			-- saving default values 
			protected.widgetDb.defaultWidth = width
			protected.widgetDb.defaultWidthUnit = widthUnit
			protected.widgetDb.defaultHeight = height
			protected.widgetDb.defaultHeightUnit = heightUnit
			-- set actual values to values from database
			width = protected.widgetDb.width
			widthUnit = protected.widgetDb.widthUnit
			height = protected.widgetDb.height
			heightUnit = protected.widgetDb.heightUnit
			
		end
		
		-- set the actual width 
		if (not width) then
			protected.widgetWidth = 100
			protected.widgetWidthIsRelative = true
		else
			protected.widgetWidth = width
			if ("%" == widthUnit) then
				protected.widgetWidthIsRelative = true
			else
				protected.widgetWidthIsRelative = false
			end
		end

		-- set the actual height 
		if (not height) then
			protected.widgetHeight = 100
			protected.widgetHeightIsRelative = true
		else
			protected.widgetHeight = height
			if ("%" == heightUnit) then
				protected.widgetHeightIsRelative = true
			else
				protected.widgetHeightIsRelative = false
			end
		end

		self.SetLabel(init.label)

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECWidget", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance and protected table
	return self, protected
end


