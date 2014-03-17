-- **********************************************************************
-- GnomTECWidgetScrollingMessage
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
-- Class levels
local CLASS_CLASS		= 0
local CLASS_LAYOUT	= 1
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

function GnomTECWidgetScrollingMessage(title, parent)

	-- call base class
	local self, protected = GnomTECWidget(title, parent)
	
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
	local function OnMouseWheel(self, delta)
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

	local function OnMessageScrollChanged(self)
		local num = protected.scrollingMessageFrame:GetNumMessages()
		local cur = protected.scrollingMessageFrame:GetCurrentScroll()
		local disp = protected.scrollingMessageFrame:GetNumLinesDisplayed()
		local thumbTexture = protected.slider:GetThumbTexture()
		
		if (num > disp) then
			protected.slider:SetMinMaxValues(0, num-disp);
			protected.slider:SetValue(num-disp-cur);
			local thumbSize = protected.slider:GetHeight() / num-disp
			if (thumbSize < 16) then
				thumbSize = 16
			end 
			thumbTexture:SetHeight(thumbSize)
		else
			protected.slider:SetMinMaxValues(0, 0);
			protected.slider:SetValue(0);   	
			thumbTexture:SetHeight(protected.slider:GetHeight())
		end
	end

	local function OnValueChanged(self, value)
		local num = protected.scrollingMessageFrame:GetNumMessages()
		local disp = protected.scrollingMessageFrame:GetNumLinesDisplayed()
		local cur = num - disp - floor(value)

		if (num > disp) then
			protected.scrollingMessageFrame:SetScrollOffset(cur)
		else
			protected.scrollingMessageFrame:SetScrollOffset(0)
		end		
	end

	local function OnClickUpButton(self, button)
		protected.scrollingMessageFrame:ScrollUp()
		PlaySound("UChatScrollButton");
	end

	local function OnClickDownButton(self, button)
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

	function self.IsProportionalReseize()
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
		widgetFrame:SetWidth(600)		
		widgetFrame:SetHeight(400)
		
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
		slider:SetPoint("TOPRIGHT", 0, -16)	
		slider:SetPoint("BOTTOMRIGHT", 0, 16)	
		slider:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		slider:SetScript("OnMouseWheel", OnMouseWheel)
		slider:SetScript("OnValueChanged", OnValueChanged)

		upButton:SetPoint("BOTTOM", slider, "TOP")
		upButton:SetScript("OnMouseWheel", OnMouseWheel)
		upButton:SetScript("OnClick", OnClickUpButton)

		downButton:SetPoint("TOP", slider, "BOTTOM")
		downButton:SetScript("OnMouseWheel", OnMouseWheel)
		downButton:SetScript("OnClick", OnClickDownButton)
				
		-- this enables resizing
		lastWidth = (100)
		lastHeight = (100)
		
		parent.AddChild(self, protected)

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetScrollingMessage", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


