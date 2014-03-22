-- **********************************************************************
-- GnomTECWidgetContainerLayoutHorizontal
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

function GnomTECWidgetContainerLayoutHorizontal(init)

	-- call base class
	local self, protected = GnomTECWidgetContainer(init)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
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
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetContainerLayoutHorizontal", message, ...)
	end

	function self.GetMinReseize()
		-- should be calculated according childs and layout
		local minWidth = 0
		local minHeight = 0

		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then				
				local widgetMinWidth, widgetMinHeight = child.widget.GetMinReseize()
				if (widgetMinHeight > minHeight) then
					minHeight = widgetMinHeight
				end
				minWidth = minWidth + widgetMinWidth
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
		local maxHeight = UIParent:GetHeight()

		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				local widgetMaxWidth, widgetMaxHeight = child.widget.GetMaxReseize()
				if (widgetMaxHeight < maxHeight) then
					maxHeight = widgetMaxHeight
				end
				maxWidth = maxWidth + widgetMaxWidth
			end
		end

		if (self.GetLabel()) then
			maxHeight = maxHeight + 20
		end

		if (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end
		
		return maxWidth, maxHeight
	end

	function self.IsHeightDependingOnWidth()
		-- should be calculated according childs and layout
		local depends = true
		
		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				if (not child.widget.IsHeightDependingOnWidth()) then
					local _, widgetHeightIsRelative = child.widget.GetHeight()
					if (widgetHeightIsRelative) then
						depends = false
						break
					end
				end
			end
		end
		return depends
	end

	function self.IsWidthDependingOnHeight()
		-- should be calculated according childs and layout
		local depends = true
		
		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				if (not child.widget.IsWidthDependingOnHeight()) then
					local _, widgetWidthIsRelative = child.widget.GetWidth()
					if (widgetWidthIsRelative) then
						depends = false
						break
					end
				end
			end
		end
		return depends
	end

	function self.PrepareResize()
		local parent = self
			
		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				child.widget.PrepareResize()
				if (parent == self) then
					child.widgetProtected.widgetFrame:ClearAllPoints()
					if (not self.GetLabel()) then
						child.widgetProtected.widgetFrame:SetPoint("LEFT", protected.containerFrame, 0, 0)
					else
						child.widgetProtected.widgetFrame:SetPoint("LEFT", protected.containerFrame, 0, -10)
					end
				else
					child.widgetProtected.widgetFrame:ClearAllPoints()
					child.widgetProtected.widgetFrame:SetPoint("LEFT", parent, "RIGHT", 0, 0)
				end
				parent = child.widgetProtected.widgetFrame
			end
		end
	end

	function self.ResizeByWidth(pixelWidth, pixelHeight)
		if (not self.IsWidthDependingOnHeight()) then
			return self.ResizeByHeight(pixelWidth, pixelHeight)
		else
			-- TODO
			return pixelWidth, pixelHeight
		end
	end
	
	function self.ResizeByHeight(pixelWidth, pixelHeight)

		local remainingWidth = pixelWidth
		local remainingRelativeWidthSum = 0
		local remainingWidgets = {}
		local widgetWidth, widgetHeight
		local widgetWidthIsRelative

		if (self.GetLabel()) then
			pixelHeight = pixelHeight - 20
		end

		-- first resize all elements to new width but don't change width yet.
		-- create list of all shown widgets which are changeable in height
		-- calculate remaining height and sum of relative width for above widgets
		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				widgetWidth, widgetHeight = child.widget.ResizeByHeight(child.widget.GetPixelWidth(), pixelHeight)
				if (child.widget.IsWidthDependingOnHeight()) then
					remainingWidth = remainingWidth - widgetWidth
				else
					widgetWidth, widgetWidthIsRelative = child.widget.GetWidth()
					if (widgetWidthIsRelative) then
						table.insert(remainingWidgets, child.widget)
						remainingRelativeWidthSum = remainingRelativeWidthSum + widgetWidth
					else
						remainingWidth = remainingWidth - widgetWidth
					end
				end
			end
		end

		-- reseize widget with not yet fixed height to fit to pixelHeight if possible
		while (0 ~= #remainingWidgets) do
			local actualWidth = 0
			local tempWidgets = {}

			-- reseize remaining widgets according relative heights
			for idx, widget in ipairs(remainingWidgets) do
				local min, _ = widget.GetMinReseize()
				local max, _ = widget.GetMaxReseize()
				
				widgetWidth = remainingWidth / remainingRelativeWidthSum * widget.GetWidth()
				if (widgetWidth > max) then
					widgetWidth = max
				elseif (widgetWidth < min) then
					widgetWidth = min
				end
				widgetWidth, widgetHeight = widget.ResizeByHeight(widgetWidth, pixelHeight)
				actualWidth = actualWidth + widgetWidth
			end


			remainingRelativeHeightSum = 0

			if (actualWidth  > remainingWidth) then
				-- size is yet to big so we have widgets with min size which we will now remove from list
				for idx, widget in ipairs(remainingWidgets) do
					local min, _ = widget.GetMinReseize()

					if (min >= widget.GetPixelWidth()) then
						remainingWidth = remainingWidth - min
					else
						table.insert(tempWidgets, widget)
						remainingRelativeWidthSum = remainingRelativeWidthSum + widget.GetWidth()
					end
				end
			elseif (actualWidth < remainingWidth) then
				-- size is yet to small so we have widgets with max size which we will now remove from list
				for idx, widget in ipairs(remainingWidgets) do
					local max, _ = widget.GetMaxReseize()
				
					if (max <= widget.GetPixelWidth()) then
						remainingWidth = remainingWidth - max
					else
						table.insert(tempWidgets, widget)
						remainingRelativeWidthSum = remainingRelativeWidthSum + widget.GetWidth()
					end
				end
			else
				remainingWidth = remainingWidth - actualWidth
			end

			-- check of we have finished resize of at least one widget 
			-- if not then we are either ready, have a rounding issue or some real issue
			-- but at least the result yet is the best we can get and we can finish
			if (#remainingWidgets == #tempWidgets) then
				remainingWidth = remainingWidth - actualWidth
				tempWidgets = {}
			end
			
			
			remainingWidgets = tempWidgets
		end
		
		if (self.GetLabel()) then
			pixelHeight = pixelHeight + 20
		end

		protected.widgetFrame:SetWidth(pixelWidth - remainingWidth)
		protected.widgetFrame:SetHeight(pixelHeight)

		return pixelWidth - remainingWidth, pixelHeight
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
			
			if (math.abs(dx) > math.abs(dy)) then
				-- take width and resize widget
				self.ResizeByWidth(width, height)
			else
				-- take height and resize widget
				self.ResizeByHeight(width, height)
			end
		end
	end
	
	-- constructor
	do
		if (not init) then
			init = {}
		end

		local widgetFrame = CreateFrame("Frame", nil, UIParent)
		widgetFrame:Hide()

		local containerFrame = widgetFrame
		local labelFontString = containerFrame:CreateFontString()

		protected.widgetFrame = widgetFrame 
		protected.containerFrame = containerFrame 
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
		
		labelFontString:SetFontObject(GameFontNormal)
		labelFontString:SetJustifyH("CENTER")
		labelFontString:SetTextColor(0.5, 0.5, 0.5, 1.0)
		labelFontString:SetWidth("32")		
		labelFontString:SetHeight("14")
		labelFontString:SetPoint("TOPLEFT", 0, -3)
		labelFontString:SetPoint("RIGHT")

		self.SetLabel(init.label)

		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetContainerLayoutHorizontal", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self
end


