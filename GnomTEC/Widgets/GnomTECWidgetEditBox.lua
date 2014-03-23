-- **********************************************************************
-- GnomTECWidgetEditBox
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECWidgetEditBox-1.0", 1
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

function GnomTECWidgetEditBox(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.scrollFrame = nil
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
		protected.scrollFrame:SetVerticalScroll(value);
	end

	local function OnClickUpButton(frame, button)
		protected.slider:SetValue(protected.slider:GetValue() - (protected.slider:GetHeight() / 2))
		PlaySound("UChatScrollButton");
	end

	local function OnClickDownButton(frame, button)
		protected.slider:SetValue(protected.slider:GetValue() + (protected.slider:GetHeight() / 2))
		PlaySound("UChatScrollButton");
	end
	
	local function OnChangedSizeWidgetFrame(frame, width, height)
		protected.editBoxFrame:SetWidth(protected.widgetFrame:GetWidth() - 16)
		protected.editBoxFrame:SetHeight(protected.widgetFrame:GetHeight())	
	end
	
	local function OnSizeChangedEditBox(frame, width, height)
		protected.scrollFrame:UpdateScrollChildRect();
	end

	local function OnEscapePressed(frame)
		protected.editBoxFrame:ClearFocus();
	end
	
	local function OnScrollRangeChanged(frame, xExtent, yExtent)
		protected.scrollFrame:UpdateScrollChildRect()
		protected.slider:SetMinMaxValues(0, protected.scrollFrame:GetVerticalScrollRange());
		protected.slider:SetValue(protected.scrollFrame:GetVerticalScroll());   
	end
	
	local function OnCursorChanged(frame, x, y, width, height)
		local widgetHeight = protected.widgetFrame:GetHeight()
		local offset = protected.slider:GetValue()
		
		if (offset > -y) then
			protected.slider:SetValue(-y)
		elseif (offset+widgetHeight < -y + height) then
			protected.slider:SetValue(-y+height-widgetHeight)
		end
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
		-- get localization first.
		L = protected.GetLocale()

		-- get texture path
		T = protected.GetTexturePath()	

		if (not init) then
			init = {}
		end
		
		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		local scrollFrame = CreateFrame("ScrollFrame", nil, widgetFrame)
		local editBoxFrame = CreateFrame("EditBox", nil, widgetFrame)
		local slider = CreateFrame("Slider", nil, widgetFrame)
		local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate")
		local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate")
		
		protected.widgetFrame = widgetFrame 
		protected.scrollFrame = scrollFrame 
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
		
		widgetFrame:SetScript("OnSizeChanged", OnChangedSizeWidgetFrame)

		scrollFrame:SetPoint("TOPLEFT", 0, 0)	
		scrollFrame:SetPoint("BOTTOMRIGHT", -16, 0)	
		scrollFrame:SetScript("OnScrollRangeChanged", OnScrollRangeChanged)
		scrollFrame:SetScript("OnMouseWheel", OnMouseWheel)
		scrollFrame:SetScrollChild(editBoxFrame)

		editBoxFrame:SetPoint("TOPLEFT", 0, 0)	
		editBoxFrame:SetPoint("BOTTOMRIGHT", -16, 0)	
		editBoxFrame:SetHeight(widgetFrame:GetHeight())	
		editBoxFrame:SetWidth(widgetFrame:GetWidth() - 16)	
		editBoxFrame:SetMultiLine(true)
		editBoxFrame:SetFontObject(ChatFontNormal)
		editBoxFrame:SetJustifyH("LEFT")
		editBoxFrame:EnableKeyboard(true);
		editBoxFrame:EnableMouse(true);			
		editBoxFrame:SetAutoFocus(false);			
		editBoxFrame:SetScript("OnMouseWheel", OnMouseWheel)
		editBoxFrame:SetScript("OnSizeChanged", OnSizeChangedEditBox)
		editBoxFrame:SetScript("OnEscapePressed", OnEscapePressed)
		editBoxFrame:SetScript("OnCursorChanged", OnCursorChanged)

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
				
		scrollFrame:UpdateScrollChildRect();
		slider:SetMinMaxValues(0, scrollFrame:GetVerticalScrollRange());
		slider:SetValue(scrollFrame:GetVerticalScroll());   

		self.SetText(init.text)
		
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetEditBox", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance
	return self
end


