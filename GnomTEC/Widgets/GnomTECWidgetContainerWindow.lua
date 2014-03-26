-- **********************************************************************
-- GnomTECWidgetContainerWindow
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECWidgetContainerWindow-1.0", 1
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
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetContainerWindow(init)

	-- call base class
	local self, protected = GnomTECWidgetContainer(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.title = nil
	protected.titleFontString = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local lastWidth = nil
	local lastHeight = nil
	
	-- private methods
	-- local function f()

	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetContainerWindow", message, ...)
	end

	local function StartResize()
		if (protected.widgetFrame:IsResizable()) then
			protected.widgetFrame:StartSizing()
		end
	end

	local function StopResize()
		protected.widgetFrame:StopMovingOrSizing()
	end
	
	local function StartMoving()
		if (protected.widgetFrame:IsMovable()) then
			protected.widgetFrame:StartMoving()
		end
	end

	local function StopMoving()
		protected.widgetFrame:StopMovingOrSizing()
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
	
	local base_GetMinReseize = self.GetMinReseize
	function self.GetMinReseize()
		local minWidth, minHeight = base_GetMinReseize()
		
		minWidth = minWidth + 14
		minHeight = minHeight + 34
		
		if (minWidth < 100) then
			minWidth = 100
		end

		if (minHeight < 100) then
			minHeight = 100
		end

		return minWidth, minHeight
	end

	local base_GetMaxReseize = self.GetMaxReseize
	function self.GetMaxReseize()
		local maxWidth, maxHeight = base_GetMaxReseize()
		
		maxWidth = maxWidth + 14
		maxHeight = maxHeight + 34
		
		if (maxWidth < 100) then
			maxWidth = 100
		elseif (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end

		if (maxHeight < 100) then
			maxHeight = 100
		elseif (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
		end

		return maxWidth, maxHeight
	end

	local base_ResizeByWidth = self.ResizeByWidth
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		pixelWidth, pixelHeight = base_ResizeByWidth(pixelWidth - 14, pixelHeight - 34)
		pixelWidth = pixelWidth + 14
		pixelHeight = pixelHeight + 34
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
		pixelWidth, pixelHeight = base_ResizeByHeight(pixelWidth - 14, pixelHeight - 34)
		pixelWidth = pixelWidth + 14
		pixelHeight = pixelHeight + 34
		if (math.abs(self.GetPixelWidth() - pixelWidth) >= 1) then
			protected.widgetFrame:SetWidth(pixelWidth)
		end
		if (math.abs(self.GetPixelHeight() - pixelHeight) >= 1) then
			protected.widgetFrame:SetHeight(pixelHeight)
		end
		return pixelWidth, pixelHeight
	end
	
	function self.SetTitle(title)
		protected.title = emptynil(title)
		if (protected.titleFontString) then
			protected.titleFontString:SetText(protected.title or "")
		end
	end
	
	function self.GetTitle()
		return emptynil(protected.title)
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
		
		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		local headerFrame = CreateFrame("Frame", nil, widgetFrame)
		local closeButtonFrame = CreateFrame("Frame", nil, widgetFrame)
		local closeButton = CreateFrame("Button", nil, widgetFrame, "UIPanelCloseButton")
		local reseizeButton = CreateFrame("Button", nil, widgetFrame)
		local containerFrame = CreateFrame("Frame", nil, widgetFrame)
		local titleFontString = headerFrame:CreateFontString()
		local labelFontString = containerFrame:CreateFontString()

		protected.widgetFrame = widgetFrame 
		protected.containerFrame = containerFrame 
		protected.titleFontString = titleFontString 
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
		
		local backdrop = {
			bgFile 	= [[Interface\Tooltips\UI-Tooltip-Background]],
			edgeFile	= [[Interface\Tooltips\UI-Tooltip-Border]],
			tile 		= true,
			edgeSize = 16,
			TileSize	= 16,
			insets 	= {
				left 		= 4,
				right 	= 4,
				top 		= 4,
				bottom	= 4
			}
		}
		widgetFrame:SetBackdrop(backdrop)
		widgetFrame:SetBackdropColor(0.0, 0.0, 0.0, 0.9)
		widgetFrame:SetScript("OnShow", OnShow)
		widgetFrame:SetScript("OnSizeChanged", OnSizeChanged)
		widgetFrame:SetMovable(true)
		widgetFrame:SetResizable(true)
		widgetFrame:SetClampedToScreen(true)
		widgetFrame:SetToplevel(true)
		widgetFrame:EnableMouse(true)
		
		closeButtonFrame:SetPoint("TOPRIGHT")
		closeButtonFrame:SetWidth(24)		
		closeButtonFrame:SetHeight(24)
		closeButtonFrame:SetBackdrop(backdrop)
		closeButtonFrame:SetBackdropColor(0.0, 0.0, 0.0, 0.9)
		
		closeButton:SetPoint("TOPRIGHT", 4, 4)

		reseizeButton:SetPoint("BOTTOMRIGHT")
		reseizeButton:SetWidth("16")		
		reseizeButton:SetHeight("16")
		reseizeButton:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
		reseizeButton:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])
		reseizeButton:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
		reseizeButton:SetScript("OnMouseDown", StartResize)
		reseizeButton:SetScript("OnMouseUp", StopResize)

		headerFrame:SetPoint("TOPLEFT")
		headerFrame:SetPoint("BOTTOMRIGHT", widgetFrame, "TOPRIGHT", -20, -24)
		headerFrame:SetBackdrop(backdrop)
		headerFrame:SetBackdropColor(0.0, 0.0, 0.0, 0.9)
		headerFrame:SetScript("OnMouseDown", StartMoving)
		headerFrame:SetScript("OnMouseUp", StopMoving)

		titleFontString:SetFontObject(GameFontNormal)
		titleFontString:SetJustifyH("CENTER")
		titleFontString:SetJustifyV("CENTER")
		titleFontString:SetTextColor(1.0, 1.0, 0.0, 1.0)
		titleFontString:SetPoint("TOPLEFT", 4, -4)
		titleFontString:SetPoint("RIGHT", -4, 0)
		titleFontString:SetWidth("32")		
		titleFontString:SetHeight("16")

		containerFrame:SetPoint("TOPLEFT", 7, -25)
		containerFrame:SetPoint("BOTTOMRIGHT", -7, 7)
		
		labelFontString:SetFontObject(GameFontNormal)
		labelFontString:SetJustifyH("CENTER")
		labelFontString:SetTextColor(0.5, 0.5, 0.5, 1.0)
		labelFontString:SetWidth("32")		
		labelFontString:SetHeight("14")
		labelFontString:SetPoint("TOPLEFT", 0, -3)
		labelFontString:SetPoint("RIGHT")

		self.SetLabel(init.label)
		self.SetTitle(init.title)

		-- this enables resizing
		lastWidth = self.GetPixelWidth()
		lastHeight = self.GetPixelHeight()

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetContainerWindow", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


