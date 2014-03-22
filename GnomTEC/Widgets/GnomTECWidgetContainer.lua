-- **********************************************************************
-- GnomTECWidgetContainer
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
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetContainer(init)

	-- call base class
	local self, protected = GnomTECWidget(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.childs = {}
	protected.containerFrame = nil
	protected.labelFontString = nil

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
		protected.LogMessage(CLASS_CLASS, logLevel, "GnomTECWidgetContainer", message, ...)
	end

	function self.AddChild(child, childProtected)
		self.RemoveChild(child)
		table.insert(protected.childs, {widget = child, widgetProtected = childProtected})
		childProtected.widgetFrame:SetParent(protected.containerFrame)
		childProtected.widgetFrame:ClearAllPoints()
		if (not self.GetLabel()) then
			childProtected.widgetFrame:SetPoint("CENTER")
		else
			childProtected.widgetFrame:SetPoint("CENTER", 0, -10)
		end		
		childProtected.widgetFrame:Show()
		
		self.TriggerResize(child, 0, 0)
	end

	function self.RemoveChild(child)
		local pos = nil
		for idx, value in ipairs(protected.childs) do
			if (value.widget == child) then
				pos = idx
			end
		end
		
		if (pos) then
			table.remove(protected.childs, pos)
			self.TriggerResize(nil, 0, 0)
		end
	end
	
	function self.GetMinReseize()
		-- should be calculated according childs and layout
		-- should be calculated according childs and layouter
		local minWidth = 0
		local minHeight = 0

		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				minWidth, minHeight = value.widget.GetMinReseize()
				break
			end
		end

		if (self.GetLabel()) then
			minHeight = minHeight + 20
		end
		
		if (minWidth > UIParent:GetWidth()) then
			minWidth = UIParent:GetWidth()
		end
		if (minHeight > UIParent:GetHeight()) then
			minHeight = UIParent:GetHeight()
		end

		return minWidth, minHeight
	end

	function self.GetMaxReseize()
		-- should be calculated according childs and layout
		local maxWidth = 0
		local maxHeight = 0

		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				maxWidth, maxHeight = value.widget.GetMaxReseize()
				break
			end
		end

		if (self.GetLabel()) then
			maxHeight = maxHeight + 20
		end

		if (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end
		if (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
		end
		
		return maxWidth, maxHeight
	end

	function self.IsHeightDependingOnWidth()
		-- should be calculated according childs and layout
		local depends = false
		
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				depends = value.widget.IsHeightDependingOnWidth()
				break
			end
		end
		return depends
	end

	function self.IsWidthDependingOnHeight()
		-- should be calculated according childs and layout
		local depends = false
		
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				depends = value.widget.IsWidthDependingOnHeight()
				break
			end
		end
		return depends
	end
	
	function self.PrepareResize()
		local child = nil
		
		-- for fill layout only one child should be visible
		for idx, value in ipairs(protected.childs) do
			if (not child) then
				if (value.widget.IsShown()) then
					child = value.widget
					if (not self.GetLabel()) then
						value.widgetProtected.widgetFrame:SetPoint("CENTER")
					else
						value.widgetProtected.widgetFrame:SetPoint("CENTER", 0, -10)
					end		
					child.PrepareResize()
				end
			else
				if (child ~= value.widget) then
					value.widget.Hide()
				end
			end
		end
	end
	
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				if (not self.GetLabel()) then
					pixelWidth, pixelHeight = value.widget.ResizeByWidth(pixelWidth, pixelHeight)
				else
					pixelWidth, pixelHeight = value.widget.ResizeByWidth(pixelWidth, pixelHeight - 20)
				end
				break
			end
		end

		-- we don't change the size in base classes as we don't know what to do
		-- but we can compute the needed size of container frame and report it to derived class
		return pixelWidth, pixelHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				if (not self.GetLabel()) then
					pixelWidth, pixelHeight = value.widget.ResizeByHeight(pixelWidth, pixelHeight)
				else
					pixelWidth, pixelHeight = value.widget.ResizeByHeight(pixelWidth, pixelHeight - 20)
				end
				break
			end
		end

		-- we don't change the size in base classes as we don't know what to do
		-- but we can compute the needed size of container frame and report it to derived class
		return pixelWidth, pixelHeight
	end
	
	function self.TriggerResize(child, dx, dy)
		if (protected.widgetParent) then
			protected.widgetParent.TriggerResize(self, dx, dy)
		else
			self.PrepareResize()

			local minWidth, minHeight = self.GetMinReseize()
			local maxWidth, maxHeight = self.GetMaxReseize()
			local width = self.GetPixelWidth()
			local height = self.GetPixelHeight()
			
			if (width < minWidth) then
				width = minWidth
			elseif (width > maxWidth) then
				width = maxWidth
			end

			if (height < minHeight) then
				height = minHeight
			elseif (height > maxHeight) then
				height = maxHeight
			end
			
			if (math.abs(dx) >= math.abs(dy)) then
				-- take width and resize widget
				self.ResizeByWidth(width, height)
			else
				-- take height and resize widget
				self.ResizeByHeight(width, height)
			end
		end
	end

	function self.SetLabel(label)
		protected.label = emptynil(label)
		if (protected.labelFontString) then
			protected.labelFontString:SetText(protected.label or "")
		end
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECWidgetContainer", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance and protected table
	return self, protected
end


