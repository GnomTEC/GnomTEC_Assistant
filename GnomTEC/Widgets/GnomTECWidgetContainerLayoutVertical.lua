-- **********************************************************************
-- GnomTECWidgetContainerLayoutVertical
-- Version: 6.0.2.1
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
local MAJOR, MINOR = "GnomTECWidgetContainerLayoutVertical-1.0", 1
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


-- ----------------------------------------------------------------------
-- Widget Class
-- ----------------------------------------------------------------------

function GnomTECWidgetContainerLayoutVertical(init)

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
		protected.LogMessage(CLASS_WIDGET, logLevel, "GnomTECWidgetContainerLayoutVertical", message, ...)
	end

	function self.GetMinReseize()
		-- should be calculated according childs and layout
		local minWidth = 0
		local minHeight = 0

		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then				
				local widgetMinWidth, widgetMinHeight = child.widget.GetMinReseize()
				if (widgetMinWidth > minWidth) then
					minWidth = widgetMinWidth
				end
				minHeight = minHeight + widgetMinHeight
			end
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
		local maxWidth = UIParent:GetWidth()
		local maxHeight = 0

		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				local widgetMaxWidth, widgetMaxHeight = child.widget.GetMaxReseize()
				if (widgetMaxWidth < maxWidth) then
					maxWidth = widgetMaxWidth
				end
				maxHeight = maxHeight + widgetMaxHeight
			end
		end

		if (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
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
					child.widgetProtected.widgetFrame:SetPoint("TOP", protected.containerFrame, 0, 0)
				else
					child.widgetProtected.widgetFrame:ClearAllPoints()
					child.widgetProtected.widgetFrame:SetPoint("TOP", parent, "BOTTOM", 0, 0)
				end
				parent = child.widgetProtected.widgetFrame
			end
		end
	end
	
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		local remainingHeight = pixelHeight
		local remainingRelativeHeightSum = 0
		local remainingWidgets = {}
		local widgetWidth, widgetHeight
		local widgetHeightIsRelative

		-- first resize all elements to new width but don't change height yet.
		-- create list of all shown widgets which are changeable in height
		-- calculate remaining height and sum of relative height for above widgets
		for idx, child in ipairs(protected.childs) do
			if (child.widget.IsShown()) then
				widgetWidth, widgetHeight = child.widget.ResizeByWidth(pixelWidth, child.widget.GetPixelHeight())
				if (child.widget.IsHeightDependingOnWidth()) then
					remainingHeight = remainingHeight - widgetHeight
				else
					widgetHeight, widgetHeightIsRelative = child.widget.GetHeight()
					if (widgetHeightIsRelative) then
						table.insert(remainingWidgets, child.widget)
						remainingRelativeHeightSum = remainingRelativeHeightSum + widgetHeight
					else
						remainingHeight = remainingHeight - widgetHeight
					end
				end
			end
		end

		-- reseize widget with not yet fixed height to fit to pixelHeight if possible
		while (0 ~= #remainingWidgets) do
			local actualHeight = 0
			local tempWidgets = {}

			-- reseize remaining widgets according relative heights
			for idx, widget in ipairs(remainingWidgets) do
				local _, min = widget.GetMinReseize()
				local _, max = widget.GetMaxReseize()
				
				widgetHeight = remainingHeight / remainingRelativeHeightSum * widget.GetHeight()

				if (widgetHeight > max) then
					widgetHeight = max
				elseif (widgetHeight < min) then
					widgetHeight = min
				end
				widgetWidth, widgetHeight = widget.ResizeByWidth(pixelWidth, widgetHeight)
				actualHeight = actualHeight + widgetHeight
			end


			remainingRelativeHeightSum = 0

			if (actualHeight  > remainingHeight) then
				-- size is yet to big so we have widgets with min size which we will now remove from list
				for idx, widget in ipairs(remainingWidgets) do
					local _, min = widget.GetMinReseize()

					if (min >= widget.GetPixelHeight()) then
						remainingHeight = remainingHeight - min
					else
						table.insert(tempWidgets, widget)
						remainingRelativeHeightSum = remainingRelativeHeightSum + widget.GetHeight()
					end
				end
			elseif (actualHeight < remainingHeight) then
				-- size is yet to small so we have widgets with max size which we will now remove from list
				for idx, widget in ipairs(remainingWidgets) do
					local _, max = widget.GetMaxReseize()
				
					if (max <= widget.GetPixelHeight()) then
						remainingHeight = remainingHeight - max
					else
						table.insert(tempWidgets, widget)
						remainingRelativeHeightSum = remainingRelativeHeightSum + widget.GetHeight()
					end
				end
			else
				remainingHeight = remainingHeight - actualHeight
			end

			-- check of we have finished resize of at least one widget 
			-- if not then we are either ready, have a rounding issue or some real issue
			-- but at least the result yet is the best we can get and we can finish
			if (#remainingWidgets == #tempWidgets) then
				remainingHeight = remainingHeight - actualHeight
				tempWidgets = {}
			end

			remainingWidgets = tempWidgets
		end

		protected.widgetFrame:SetWidth(pixelWidth)
		protected.widgetFrame:SetHeight(pixelHeight - remainingHeight)

		return pixelWidth, pixelHeight - remainingHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		if (not self.IsHeightDependingOnWidth()) then
			return self.ResizeByWidth(pixelWidth, pixelHeight)
		else
			return pixelWidth, pixelHeight
		end

--[[
		local width = pixelWidth
		local height = 0
		local relativeHeight = 0
		local widgets = {}
		local widgetWidth
		local widgetHeight, widgetHeightIsRelative
		
		-- First get widget list and calculate overall relativeWidth and remaining pixelHeight
		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				table.insert(widgets, value.widget)
				widgetHeight, widgetHeightIsRelative = value.widget.GetHeight()
				if (widgetHeightIsRelative) then
					relativeHeight = relativeHeight + widgetHeight
				else
					pixelHeight = pixelHeight - widgetHeight
				end
			end
		end

		-- reseize widgets
		while (0 ~= #widgets) do
			local restWidgets = {}
			local restPixelHeight = pixelHeight
			local restRelativeHeight = 0
			
			if (1 > relativeHeight) then
				relativeHeight = 1
			end

			-- calculate proportional height for remaining widgets
			-- fix size of widgets which would be not in their margins or are fixed width
			for idx, value in ipairs(widgets) do
				local _, min = value.GetMinReseize()
				local _, max = value.GetMaxReseize()
				widgetHeight, widgetHeightIsRelative = value.GetHeight()


				if (widgetHeightIsRelative) then
					widgetHeight = pixelHeight / relativeHeight * widgetHeight
					if ((widgetHeight > max) or (widgetHeight < min)) then
						if (widgetHeight > max) then
							widgetHeight = max
						else 
							widgetHeight = min
						end
						widgetWidth, widgetHeight = value.ResizeByHeight(width, widgetHeight)

						restPixelHeight = restPixelHeight - widgetHeight
						height = height + widgetHeight

						if (widgetWidth > width) then
							width = widgetWidth
--						elseif (value.IsProportionalReseize()) then
--							local min, _ = self.GetMinReseize()
--							if (widgetWidth > min) then
--								width = widgetWidth
--							end
						end
					else
						table.insert(restWidgets, value)
						restRelativeHeight = restRelativeHeight + value.GetHeight()
					end
				else
					widgetWidth, widgetHeight = value.ResizeByHeight(width, widgetHeight)
					if (widgetWidth > width) then
						width = widgetWidth
--					elseif (value.IsProportionalReseize()) then
--						local min, _ = self.GetMinReseize()
--						if (widgetWidth > min) then
--							width = widgetWidth
--						end
					end
					restPixelHeight = restPixelHeight - widgetHeight
				end
			end

			widgets = restWidgets

			-- if restPixelHeight is same as pixelHeight we have to do above again
			-- else we can finish resize because all widgets fit the container height
			if (pixelHeight ~= restPixelHeight)	then
				pixelHeight = restPixelHeight
				relativeHeight = restRelativeHeight
			else
				for idx, value in ipairs(widgets) do
					widgetHeight = pixelHeight / relativeHeight * value.GetHeight()
					widgetWidth, widgetHeight = value.ResizeByHeight(width, widgetHeight)
					restPixelHeight = restPixelHeight - widgetHeight
					height = height + widgetHeight
					if (widgetWidth > width) then
						width = widgetWidth
--					elseif (value.IsProportionalReseize()) then
--						local min, _ = self.GetMinReseize()
--						if (widgetWidth > min) then
--							width = widgetWidth
--						end
					end
				end
				widgets = {}
			end

		end
		
		-- now resize all widgets to final width if possible
		width, height = self.ResizeByWidth(width, height)
--
		for idx, value in ipairs(protected.childs) do
			if (value.widget.IsShown()) then
				value.widget.ResizeByHeight(width, value.widget.GetPixelHeight())
			end
		end	

		protected.widgetFrame:SetWidth(width)
		protected.widgetFrame:SetHeight(height)
--
		return width, height
--]]
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
	
	-- constructor
	do
		if (not init) then
			init = {}
		end

		local widgetFrame = CreateFrame("Frame", protected.widgetUID, UIParent)
		widgetFrame:Hide()

		local containerFrame = widgetFrame

		protected.widgetFrame = widgetFrame 
		protected.containerFrame = containerFrame 
		
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
		
		if (init.parent) then
			init.parent.AddChild(self, protected)
		end

		protected.LogMessage(CLASS_WIDGET, LOG_DEBUG, "GnomTECWidgetContainerLayoutVertical", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self
end


