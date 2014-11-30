-- **********************************************************************
-- GnomTECWidgetContainerToolbox
-- Version: 6.0.3.1
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
local MAJOR, MINOR = "GnomTECWidgetContainerToolbox-1.0", 1
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
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetContainerToolbox(init)

	-- call base class
	local self, protected = GnomTECWidgetContainer(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.framePoint = nil
	protected.frameXOffset = nil
	protected.frameYOffset = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local lastWidth = nil
	local lastHeight = nil
	
	-- private methods
	-- local function f()

	local function StartResize()
		if (protected.widgetFrame:IsResizable()) then
			protected.widgetFrame:StartSizing()
		end
	end

	local function StopResize()
		protected.widgetFrame:StopMovingOrSizing()
		protected.widgetWidth = protected.widgetFrame:GetWidth()
		protected.widgetWidthIsRelative = false
		protected.widgetHeight = protected.widgetFrame:GetHeight()
		protected.widgetHeightIsRelative = false
		if (protected.widgetAttach) then
			protected.widgetAttach.Attach(self, protected)
		end
		self.SaveSize()
	end
	
	local function StartMoving()
		if (protected.widgetFrame:IsMovable()) then
			protected.widgetFrame:StartMoving()
		end
	end

	local function StopMoving()
		protected.widgetFrame:StopMovingOrSizing()
		local point, _, _, xOffset, yOffset = protected.widgetFrame:GetPoint(1)
		protected.framePoint = point
		protected.frameXOffset = xOffset
		protected.frameYOffset = yOffset
		self.SavePosition()
	end

	local function OnShow()
		self.TriggerResize(self,0,0)
	end

	local function OnSizeChanged(frame, width, height)
		if (lastWidth and lastHeight) then
			self.TriggerResize(self, width - lastWidth, height - lastHeight)
			lastWidth = width
			lastHeight = height
		end
	end
		
	-- protected methods
	-- function protected.f()

	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetContainerToolbox", message, ...)
	end
	
	local base_AddChild = self.AddChild
	function self.AddChild(child, childProtected)
		self.RemoveChild(child)
		base_AddChild(child, childProtected)
	end

	local base_RemoveChild = self.RemoveChild
	function self.RemoveChild(child)
		local pos = nil
		for idx, value in ipairs(protected.childs) do
			if (value.widget == child) then
				pos = idx
			end
		end
		
		if (pos) then

			base_RemoveChild(child)
		end
	end

	local base_GetMinReseize = self.GetMinReseize
	function self.GetMinReseize()
		local minWidth, minHeight = base_GetMinReseize()
		
		minWidth = minWidth + 8
		minHeight = minHeight + 8
		
		if (minWidth < 16) then
			minWidth = 16
		end

		if (minHeight < 16) then
			minHeight = 16
		end
		
		return minWidth, minHeight
	end

	local base_GetMaxReseize = self.GetMaxReseize
	function self.GetMaxReseize()
		local maxWidth, maxHeight = base_GetMaxReseize()
		
		maxWidth = maxWidth + 4
		maxHeight = maxHeight + 4
		
		if (maxWidth < 16) then
			maxWidth = 16
		elseif (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end

		if (maxHeight < 16) then
			maxHeight = 16
		elseif (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
		end

		return maxWidth, maxHeight
	end

	local base_ResizeByWidth = self.ResizeByWidth
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		pixelWidth, pixelHeight = base_ResizeByWidth(pixelWidth - 8, pixelHeight - 8)
		pixelWidth = pixelWidth + 8
		pixelHeight = pixelHeight + 8
		if (math.abs(self.GetPixelWidth() - pixelWidth) >= 1) then
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return pixelWidth, pixelHeight
	end

	local base_ResizeByHeight = self.ResizeByHeight
	function self.ResizeByHeight(pixelWidth, pixelHeight)
		pixelWidth, pixelHeight = base_ResizeByHeight(pixelWidth - 8, pixelHeight - 8)
		pixelWidth = pixelWidth + 8
		pixelHeight = pixelHeight + 8
		if (math.abs(self.GetPixelWidth() - pixelWidth) >= 1) then
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return pixelWidth, pixelHeight
	end
	
	function self.SavePosition()
		if (protected.widgetDb) then
			protected.widgetDb.point = protected.framePoint
			protected.widgetDb.xOffset = protected.frameXOffset
			protected.widgetDb.yOffset = protected.frameYOffset
		end
	end
	
	function self.ReloadPositionAndSize(default)
		if (protected.widgetDb) then
			
			-- we have only a position if user moved the frame or when widget is attached!

			if (protected.widgetAttach) then
				protected.widgetAttach.Attach(self, protected)
			elseif (protected.widgetDb.point) then
				protected.framePoint = protected.widgetDb.point
				protected.frameXOffset = protected.widgetDb.xOffset
				protected.frameYOffset = protected.widgetDb.yOffset
		
				protected.widgetFrame:SetPoint(protected.framePoint, protected.frameXOffset, protected.frameYOffset)
			end
					
			-- we have only a size if user resized the frame!
			if (protected.widgetDb.width) then
				-- we expect no relative size with window
				local widgetWidth = protected.widgetDb.width
				local widgetHeight = protected.widgetDb.height
				
				self.ResizeByWidth(widgetWidth + 14, widgetHeight + 34)
				self.ResizeByHeight(widgetWidth + 14, widgetHeight + 34)
			end
		end
	end
	
	local base_Attach = self.Attach
	function self.Attach(attachedWidget, attachedWidgetProtected)
		local atachedWidgetFrame = attachedWidgetProtected.widgetFrame
		base_Attach(attachedWidget, attachedWidgetProtected)
		atachedWidgetFrame:SetMovable(true)
		atachedWidgetFrame:SetScript("OnMouseDown", StartMoving)
		atachedWidgetFrame:SetScript("OnMouseUp", StopMoving)
	end

	-- constructor
	do
		if (not init) then
			init = {}
		end
		
		local widgetFrame = CreateFrame("Frame", protected.widgetUID, UIParent, "T_GNOMTECWIDGETCONTAINERTOOLBOX")

		local reseizeButton = CreateFrame("Button", nil, widgetFrame)
		local containerFrame = widgetFrame.containerFrame

		protected.widgetFrame = widgetFrame 
		protected.widgetAttachFrame = widgetFrame.attachFrame
		protected.widgetHelpFrame = widgetFrame.helpFrame

		protected.containerFrame = containerFrame 
				
		local point = init.point or "CENTER"
		local xOffset = init.xOffset or 0
		local yOffset = init.yOffset or 0
		
		-- if widget have a database then we can store frame positions and size
		if (protected.widgetDb) then
			-- saving default values 
			protected.widgetDb.defaultPoint = point
			protected.widgetDb.defaultXOffset = xOffset
			protected.widgetDb.defaultYOffset = yOffset
			-- set actual values to values from database or defaults
			point = protected.widgetDb.point or point
			xOffset = protected.widgetDb.xOffset or xOffset
			yOffset = protected.widgetDb.yOffset or yOffset
			--- and save them back
			protected.widgetDb.point = point
			protected.widgetDb.xOffset = xOffset
			protected.widgetDb.yOffset = yOffset

			-- saving default values 
			protected.widgetDb.defaultWidth = width
			protected.widgetDb.defaultWidthUnit = widthUnit
			protected.widgetDb.defaultHeight = height
			protected.widgetDb.defaultHeightUnit = heightUnit
			-- set actual values to values from database or defaults
			width = protected.widgetDb.width or width
			widthUnit = protected.widgetDb.widthUnit or widthUnit
			height = protected.widgetDb.height or height
			heightUnit = protected.widgetDb.heightUnit or heigtUnit
			--- and save them back
			protected.widgetDb.width = width
			protected.widgetDb.widthUnit = widthUnit
			protected.widgetDb.height = height
			protected.widgetDb.heightUnit = heightUnit
			
		end

		if (protected.widgetAttach) then
			protected.widgetAttach.Attach(self, protected, init.attachPoint, init.attachAlign)
		else
			widgetFrame:SetPoint(point, xOffset, yOffset)
			protected.framePoint = point
			protected.frameXOffset = xOffset
			protected.frameYOffset	= yOffset
		end

		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			protected.widgetWidth = 64
			protected.widgetWidthIsRelative = false
			widgetFrame:SetWidth(protected.widgetWidth)		
		end
		local h, r = self.GetHeight()
		if (not r) then
			widgetFrame:SetHeight(h)		
		else
			protected.widgetHeight = 64
			protected.widgetHeightIsRelative = false
			widgetFrame:SetHeight(protected.widgetHeight)
		end
		
		widgetFrame:SetScript("OnShow", OnShow)
		widgetFrame:SetScript("OnSizeChanged", OnSizeChanged)
		if (not protected.widgetAttach) then
			widgetFrame:SetScript("OnMouseDown", StartMoving)
			widgetFrame:SetScript("OnMouseUp", StopMoving)
		end
		reseizeButton:SetPoint("BOTTOMRIGHT")
		reseizeButton:SetWidth("16")		
		reseizeButton:SetHeight("16")
		reseizeButton:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
		reseizeButton:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])
		reseizeButton:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
		reseizeButton:SetScript("OnMouseDown", StartResize)
		reseizeButton:SetScript("OnMouseUp", StopResize)
		
		-- this enables resizing
		lastWidth = self.GetPixelWidth()
		lastHeight = self.GetPixelHeight()

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetContainerToolbox", "New instance created (%s)", protected.UID)
		
	end
	
	-- return the instance
	return self
end


