-- **********************************************************************
-- GnomTECWidgetMap
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
local MAJOR, MINOR = "GnomTECWidgetMap-1.0", 1
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

function GnomTECWidgetMap(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.mapTextures = {}
	
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
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetMap", message, ...)
	end

	function self.GetMinReseize()
		
		local minWidth = (32 * 1000.0 * 4.0 / 1024.0)
		local minHeight = (32 * 667.0 * 3.0 / 768.0)
		
		return minWidth, minHeight
	end

	function self.GetMaxReseize()		
		local maxWidth = UIParent:GetWidth() * 1024.0 / 1000.0 / 4.0	-- frameWidth * textureSize / visibleSize / numTiles
		local maxHeight = UIParent:GetHeight() * 768.0 / 667.0 / 3.0 	-- frameHeight * textureSize / visibleSize / numTiles
	
		if maxWidth > maxHeight then
			maxWidth = maxHeight
		else
			maxHeight = maxWidth
		end

		maxWidth = (maxWidth * 1000.0 * 4.0 / 1024.0)
		maxHeight = (maxHeight * 667.0 * 3.0 / 768.0)

		return maxWidth, maxHeight
	end

	function self.IsHeightDependingOnWidth()
		return true
	end

	function self.IsWidthDependingOnHeight()
		return true
	end
	
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		pixelHeight = pixelWidth * 1024.0 / 1000.0 / 4.0	-- frameWidth * textureSize / visibleSize / numTiles

		for r = 1, 3 do
			for c = 1, 4 do
				local texture = protected.mapTextures[4 * (r-1) + c]
				texture:SetPoint("TOPLEFT",pixelHeight * (c-1), -pixelHeight * (r-1))
				texture:SetWidth(pixelHeight)
				texture:SetHeight(pixelHeight)
			end
		end				

		pixelHeight = (pixelHeight * 667.0 * 3.0 / 768.0)

		if (math.abs(self.GetPixelWidth() - pixelWidth) >= 1) then
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return pixelWidth, pixelHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		pixelWidth = pixelHeight * 768.0 / 667.0 / 3.0 	-- frameHeight * textureSize / visibleSize / numTiles

		for r = 1, 3 do
			for c = 1, 4 do
				local texture = protected.mapTextures[4 * (r-1) + c]
				texture:SetPoint("TOPLEFT",pixelWidth * (c-1), -pixelWidth * (r-1))
				texture:SetWidth(pixelWidth)
				texture:SetHeight(pixelWidth)
			end
		end				

		pixelWidth = (pixelWidth * 1000.0 * 4.0 / 1024.0)

		if (math.abs(self.GetPixelWidth() - pixelWidth) >= 1) then
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return pixelWidth, pixelHeight
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end

		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		protected.widgetFrame = widgetFrame 
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			widgetFrame:SetWidth((32 * 1000.0 * 4.0 / 1024.0))		
		end
		local h, r = self.GetHeight()
		if (not r) then
			widgetFrame:SetHeight(h)		
		else
			widgetFrame:SetHeight((32 * 667.0 * 3.0 / 768.0))
		end
		
		for r = 1, 3 do
			for c = 1, 4 do
				local texture = widgetFrame:CreateTexture(nil)
				protected.mapTextures[4 * (r-1) + c] = texture
				texture:SetTexture([[Interface\WorldMap\StormwindCity\StormwindCity]]..(4 * (r-1) + c))				
				texture:SetPoint("TOPLEFT",32 * (c-1), -32 * (r-1))
				texture:SetWidth(32)
				texture:SetHeight(32)
			end
		end				
				
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetMap", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


