-- **********************************************************************
-- GnomTECWidgetEditBox
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

function GnomTECWidgetEditBox(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.editBoxFrame = nil
	protected.slider = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	
	-- private methods
	-- local function f()
	local function OnMouseWheel(frame, delta)
		protected.slider:SetValue(protected.slider:GetValue() - delta*14);
	end

	local function OnValueChanged(frame, value)
		protected.widgetFrame:SetVerticalScroll(value);
	end

	local function OnClickUpButton(frame, button)
		protected.slider:SetValue(protected.slider:GetValue() - (protected.slider:GetHeight() / 2))
		PlaySound("UChatScrollButton");
	end

	local function OnClickDownButton(frame, button)
		protected.slider:SetValue(protected.slider:GetValue() + (protected.slider:GetHeight() / 2))
		PlaySound("UChatScrollButton");
	end
	
	local function OnSizeChangedEditBox(frame, width, height)
		protected.widgetFrame:UpdateScrollChildRect();
	end

	local function OnEscapePressed(frame)
		protected.editBoxFrame:ClearFocus();
	end
	
	local function OnScrollRangeChanged(frame, xExtent, yExtent)
		protected.widgetFrame:UpdateScrollChildRect()
		protected.slider:SetMinMaxValues(0, protected.widgetFrame:GetVerticalScrollRange());
		protected.slider:SetValue(protected.widgetFrame:GetVerticalScroll());   
	end
	
	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetEditBox", message, ...)
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
	
	function self.SetText(text)
		protected.editBoxFrame:SetText(text or "")
	end

	function self.GetText()
		return protected.editBoxFrame:GetText()
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end
		
		local widgetFrame = CreateFrame("ScrollFrame", nil, UIParent)
		widgetFrame:Hide()

		local editBoxFrame = CreateFrame("EditBox", nil, widgetFrame)
		local slider = CreateFrame("Slider", nil, widgetFrame)
		local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate")
		local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate")
		
		protected.widgetFrame = widgetFrame 
		protected.editBoxFrame = editBoxFrame 
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
		
		widgetFrame:SetScript("OnScrollRangeChanged", OnScrollRangeChanged)
		widgetFrame:SetScript("OnMouseWheel", OnMouseWheel)

		widgetFrame:SetScrollChild(editBoxFrame)

		editBoxFrame:SetAllPoints(true)
		editBoxFrame:SetMultiLine(true)
		editBoxFrame:SetFontObject(ChatFontNormal)
		editBoxFrame:SetJustifyH("LEFT")
		editBoxFrame:EnableKeyboard(false);
		editBoxFrame:EnableMouse(false);			
		editBoxFrame:SetAutoFocus(false);			

		editBoxFrame:SetScript("OnMouseWheel", OnMouseWheel)
		editBoxFrame:SetScript("OnSizeChanged", OnChangedEditBoxSize)
		editBoxFrame:SetScript("OnEscapePressed", OnEscapePressed)

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
				
		widgetFrame:UpdateScrollChildRect();
		slider:SetMinMaxValues(0, widgetFrame:GetVerticalScrollRange());
		slider:SetValue(widgetFrame:GetVerticalScroll());   

		self.SetText(init.text)
		
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetEditBox", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


