-- **********************************************************************
-- GnomTECWidgetScrollingMessage
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECWidgetScrollingMessage-1.0", 1
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

function GnomTECWidgetScrollingMessage(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.scrollingMessageFrame = nil
	protected.slider = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	
	-- private methods
	-- local function f()
	local function OnMouseWheel(frame, delta)
		local num = protected.scrollingMessageFrame:GetNumMessages()
		local cur = protected.scrollingMessageFrame:GetCurrentScroll()
		local disp = protected.scrollingMessageFrame:GetNumLinesDisplayed()

		local newValue = cur + delta

		if (newValue < 0) then
			newValue = 0
		elseif (newValue > (num-disp)) then
			newValue = (num-disp)
		end
		protected.scrollingMessageFrame:SetScrollOffset(newValue)
	end

	local function OnMessageScrollChanged(frame)
		local num = protected.scrollingMessageFrame:GetNumMessages()
		local cur = protected.scrollingMessageFrame:GetCurrentScroll()
		local disp = protected.scrollingMessageFrame:GetNumLinesDisplayed()
		
		if (num > disp) then
			protected.slider:SetMinMaxValues(0, num-disp);
			protected.slider:SetValue(num-disp-cur);
			local thumbSize = protected.slider:GetHeight() / num-disp
			if (thumbSize < 16) then
				thumbSize = 16
			end 
		else
			protected.slider:SetMinMaxValues(0, 0);
			protected.slider:SetValue(0);   	
		end
	end

	local function OnValueChanged(frame, value)
		local num = protected.scrollingMessageFrame:GetNumMessages()
		local disp = protected.scrollingMessageFrame:GetNumLinesDisplayed()
		local cur = num - disp - floor(value)

		if (num > disp) then
			protected.scrollingMessageFrame:SetScrollOffset(cur)
		else
			protected.scrollingMessageFrame:SetScrollOffset(0)
		end		
	end

	local function OnClickUpButton(frame, button)
		protected.scrollingMessageFrame:ScrollUp()
		PlaySound("UChatScrollButton");
	end

	local function OnClickDownButton(frame, button)
		protected.scrollingMessageFrame:ScrollDown()
		PlaySound("UChatScrollButton");
	end

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetScrollingMessage", message, ...)
	end

	function self.GetMinReseize()
		local minWidth = 100
		local minHeight = 100
		
		return minWidth, minHeight
	end

	function self.GetMaxReseize()		
		local maxWidth = UIParent:GetWidth()
		local maxHeight = UIParent:GetHeight()

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
		protected.widgetFrame:SetHeight(pixelHeight)

		return pixelWidth, pixelHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(pixelHeight)

		return pixelWidth, pixelHeight
	end
	
	function self.AddMessage(text, ...)
		protected.scrollingMessageFrame:AddMessage(text, ...)
	end

	function self.GetNumMessages(...)
		return protected.scrollingMessageFrame:GetNumMessages(...)
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

		local scrollingMessageFrame = CreateFrame("ScrollingMessageFrame", nil, widgetFrame)
		local slider = CreateFrame("Slider", nil, widgetFrame)
		local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate")
		local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate")
		
		protected.widgetFrame = widgetFrame 
		protected.scrollingMessageFrame = scrollingMessageFrame 
		protected.slider = slider 
		
		-- should be configurable later eg. saveable
		widgetFrame:SetPoint("CENTER")		
		local w, r = self.GetWidth()
		if (not r) then
			widgetFrame:SetWidth(w)		
		else
			widgetFrame:SetWidth("600")		
		end
		local h, r = self.GetHeight()
		if (not r) then
			widgetFrame:SetHeight(h)		
		else
			widgetFrame:SetHeight("400")
		end
		
		scrollingMessageFrame:SetPoint("TOPLEFT")		
		scrollingMessageFrame:SetPoint("BOTTOMRIGHT", -16, 0)	
		scrollingMessageFrame:SetFading(false)
		scrollingMessageFrame:SetIndentedWordWrap(true) 
		scrollingMessageFrame:SetMaxLines(1024)
		scrollingMessageFrame:SetFontObject(ChatFontNormal)
		scrollingMessageFrame:SetJustifyH("LEFT")
		
		scrollingMessageFrame:SetScript("OnMouseWheel", OnMouseWheel)
		scrollingMessageFrame:SetScript("OnMessageScrollChanged", OnMessageScrollChanged)
		
		slider:SetWidth(16)
		slider:SetPoint("TOPRIGHT", 0, -8)	
		slider:SetPoint("BOTTOMRIGHT", 0, 8)	
		slider:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		slider:SetScript("OnMouseWheel", OnMouseWheel)
		slider:SetScript("OnValueChanged", OnValueChanged)

		upButton:SetPoint("TOP", slider, "TOP", 0, 8)
		upButton:SetScript("OnMouseWheel", OnMouseWheel)
		upButton:SetScript("OnClick", OnClickUpButton)

		downButton:SetPoint("BOTTOM", slider, "BOTTOM", 0, -8)
		downButton:SetScript("OnMouseWheel", OnMouseWheel)
		downButton:SetScript("OnClick", OnClickDownButton)
				
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetScrollingMessage", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


