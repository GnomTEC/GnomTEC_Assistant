-- **********************************************************************
-- GnomTECWidgetContainerWindow
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


-- ----------------------------------------------------------------------
-- Widget Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetContainerWindow(title, layout)

	-- call base class
	local self, protected = GnomTECWidgetContainer(title, nil, layout)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.headerTitle = nil
	
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
		
		minWidth = minWidth + 10
		minHeight = minHeight + 65
		
		if (minWidth < 64) then
			minWidth = 64
		end

		if (minHeight < 64) then
			minHeight = 64
		end

		return minWidth, minHeight
	end

	local base_GetMaxReseize = self.GetMaxReseize
	function self.GetMaxReseize()
		local maxWidth, maxHeight = base_GetMaxReseize()
		
		maxWidth = maxWidth + 10
		maxHeight = maxHeight + 65
		
		if (maxWidth < 64) then
			maxWidth = 64
		elseif (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end

		if (maxHeight < 64) then
			maxHeight = 64
		elseif (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
		end

		return maxWidth, maxHeight
	end

	local base_ResizeByWidth = self.ResizeByWidth
	function self.ResizeByWidth(pixelWidth)
		local pixelHeight = base_ResizeByWidth(pixelWidth - 10)
		pixelHeight = pixelHeight + 65
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

	local base_ResizeByHeight = self.ResizeByHeight
	function self.ResizeByHeight(pixelHeight)
		local pixelWidth = base_ResizeByHeight(pixelHeight - 65)
		pixelWidth = pixelWidth + 10
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
	
	local base_SetTitle = self.SetTitle
	function self.SetTitle(title)
		base_SetTitle(title)
		protected.headerTitle:SetText(title)
	end
	-- constructor
	do
		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		local headerFrame = CreateFrame("Frame", nil, widgetFrame)
		local closeButton = CreateFrame("Button", nil, widgetFrame, "UIPanelCloseButton")
		local reseizeButton = CreateFrame("Button", nil, widgetFrame)
		local containerFrame = CreateFrame("Frame", nil, widgetFrame)
		local headerTitle = headerFrame:CreateFontString()

		protected.widgetFrame = widgetFrame 
		protected.containerFrame = containerFrame 
		protected.headerTitle = headerTitle 
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		widgetFrame:SetWidth("64")		
		widgetFrame:SetHeight("64")
		
		local backdrop = {
			bgFile 	= [[Interface\Addons\GnomTEC_Assistant\Textures\UI-Window-Background]],
			edgeFile	= [[Interface\Addons\GnomTEC_Assistant\Textures\UI-Window-Border]],
			tile 		= true,
			edgeSize = 32,
			TileSize	= 32,
			insets 	= {
				left 		= 5,
				right 	= 5,
				top 		= 5,
				bottom	= 5
			}
		}
		widgetFrame:SetBackdrop(backdrop)
		widgetFrame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
		widgetFrame:SetScript("OnShow", OnShow)
		widgetFrame:SetScript("OnSizeChanged", OnSizeChanged)
		widgetFrame:SetMovable(true)
		widgetFrame:SetResizable(true)
		
		
		closeButton:SetPoint("TOPRIGHT")

		reseizeButton:SetPoint("BOTTOMRIGHT")
		reseizeButton:SetWidth("16")		
		reseizeButton:SetHeight("16")
		reseizeButton:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
		reseizeButton:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])
		reseizeButton:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
		reseizeButton:SetScript("OnMouseDown", StartResize)
		reseizeButton:SetScript("OnMouseUp", StopResize)

		headerFrame:SetPoint("TOPLEFT", 5, -6)
		headerFrame:SetPoint("BOTTOMRIGHT", widgetFrame, "TOPRIGHT", -30, -26)
		headerFrame:SetScript("OnMouseDown", StartMoving)
		headerFrame:SetScript("OnMouseUp", StopMoving)

		headerTitle:SetFontObject(GameFontNormal)
		headerTitle:SetJustifyH("CENTER")
		headerTitle:SetTextColor(1.0, 1.0, 0.0, 1.0)
		headerTitle:SetWidth("32")		
		headerTitle:SetHeight("14")
		headerTitle:SetPoint("TOPLEFT", 0, -3)
		headerTitle:SetPoint("RIGHT")

		containerFrame:SetPoint("TOPLEFT", 5, -30)
		containerFrame:SetPoint("BOTTOMRIGHT", -5, 30)
		
		self.SetTitle(title)

		-- this enables resizing
		lastWidth = 64
		lastHeight = 64

		protected.LogMessage(LOG_DEBUG, "New GnomTECWidgetContainerWindow instance created (%s)", protected.widgetUID)
	end
	
	-- return the instance
	return self
end


