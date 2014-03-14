-- **********************************************************************
-- GnomTECWidgetMap
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")


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


-- ----------------------------------------------------------------------
-- Widget Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetMap(title, parent)

	-- call base class
	local self, protected = GnomTECWidget(title, parent)
	
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
	function self.LogMessage(level, message, ...)
		protected.LogMessage("<Widget> GnomTECWidgetMap", level, message, ...)
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

	function self.IsProportionalReseize()
		return true
	end

	function self.ResizeByWidth(pixelWidth)
		local pixelHeight = pixelWidth * 1024.0 / 1000.0 / 4.0	-- frameWidth * textureSize / visibleSize / numTiles

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
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: old width (%i)", self.GetPixelWidth())
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: new width (%i)", pixelWidth)
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: old height (%i)", self.GetPixelHeight())
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: new height (%i)", pixelHeight)
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return self.GetPixelHeight()
	end

	function self.ResizeByHeight(pixelHeight)
		local pixelWidth = pixelHeight * 768.0 / 667.0 / 3.0 	-- frameHeight * textureSize / visibleSize / numTiles

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
			protected.LogMessage(LOG_DEBUG, "ResizeByHeight: old width (%i)", self.GetPixelWidth())
			protected.LogMessage(LOG_DEBUG, "ResizeByHeight: new width (%i)", pixelWidth)
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: old height (%i)", self.GetPixelHeight())
			protected.LogMessage(LOG_DEBUG, "ResizeByWidth: new height (%i)", pixelHeight)
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return self.GetPixelWidth()
	end
	
	-- constructor
	do
		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		protected.widgetFrame = widgetFrame 
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		widgetFrame:SetWidth((32 * 1000.0 * 4.0 / 1024.0))		
		widgetFrame:SetHeight((32 * 667.0 * 3.0 / 768.0))
		
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
				
		-- this enables resizing
		lastWidth = (32 * 1000.0 * 4.0 / 1024.0)
		lastHeight = (32 * 667.0 * 3.0 / 768.0)
		
		parent.AddChild(self, protected)

		self.LogMessage(LOG_DEBUG, "New GnomTECWidgetMap instance created (%s)", protected.widgetUID)
	end
	
	-- return the instance
	return self
end


