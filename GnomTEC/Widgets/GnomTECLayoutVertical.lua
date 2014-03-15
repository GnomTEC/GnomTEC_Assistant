-- **********************************************************************
-- GnomTECLayoutFill
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")


-- ----------------------------------------------------------------------
-- Layout Global Constants (local)
-- ----------------------------------------------------------------------
-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Layout Static Variables (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Layout Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Layout Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Layout Class
-- ----------------------------------------------------------------------

function GnomTECLayoutVertical()
	-- call base class
	local self, protected = GnomTECLayout()	

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
	function self.LogMessage(level, message, ...)
		protected.LogMessage("<Layout> GnomTECLayoutFill", level, message, ...)
	end

	local base_Init = self.Init
	function self.Init(containerWidget, containerProtected)
		base_Init(containerWidget, containerProtected)
	end
	
	function self.GetMinReseize()
		-- should be calculated according childs and layouter
		local minWidth = 0
		local minHeight = 0

		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then				
				local widgetMinWidth, widgetMinHeight = value.widget.GetMinReseize()
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
		-- should be calculated according childs and layouter
		local maxWidth = 0
		local maxHeight = 0

		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				local widgetMaxWidth, widgetMaxHeight = value.widget.GetMaxReseize()
				if (0 == maxWidth) or (widgetMaxWidth < maxWidth) then
					maxWidth = widgetMaxWidth
				end
				maxHeight = maxHeight + widgetMaxHeight
			end
		end

		if (maxWidth > UIParent:GetWidth()) then
			maxWidth = UIParent:GetWidth()
		end
		if (maxHeight > UIParent:GetHeight()) then
			maxHeight = UIParent:GetHeight()
		end
		
		return maxWidth, maxHeight
	end

	function self.IsProportionalReseize()
		-- should be calculated according childs and layouter
		local isProp = false
		
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				isProp = value.widget.IsProportionalReseize()
				break
			end
		end
		return isProp
	end
	
	function self.ResizeByWidth(pixelWidth)
		-- should be calculated according childs and layouter
		local pixelHeight = 0
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				pixelHeight = value.widget.ResizeByWidth(pixelWidth)
				break
			end
		end

		-- we don't change the size in layouter as we don't know what to do
		-- but we can compute the needed size of layout and report it to the container widget
		return pixelHeight
	end

	function self.ResizeByHeight(pixelHeight)
		-- should be calculated according childs and layouter
		local pixelWidth = 0
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (value.widget.IsShown()) then
				pixelWidth = value.widget.ResizeByHeight(pixelHeight)
				break
			end
		end

		-- we don't change the size in layouter as we don't know what to do
		-- but we can compute the needed size of layout and report it to the container widget
		return pixelWidth
	end

	function self.TriggerResize(child, dx, dy)
		-- a resize is triggered by some child
		-- here we can prepare for later resize

		if (child) then
			if (not child.IsShown()) then
				child = nil
			end
		end
			
		-- for fill layout only one child should be visible
		for idx, value in ipairs(protected.containerProtected.childs) do
			if (not child) then
				if (value.widget.IsShown()) then
					child = value.widget
				end
			else
				if (child ~= value.widget) then
					value.widget.Hide()
				end
			end
		end
		
		if (not child) and protected.containerProtected.childs[1] then
			protected.containerProtected.childs[1].widget.Show()
		end
		
	end
	
	-- constructor
	do

		self.LogMessage(LOG_DEBUG, "New GnomTECLayoutVertical instance created (%s)", protected.layoutUID)
	end
	
	-- return the instance and protected table
	return self, protected
end
