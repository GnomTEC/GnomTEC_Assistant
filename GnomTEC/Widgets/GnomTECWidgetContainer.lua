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

function GnomTECWidgetContainer(title, parent, layout)

	-- call base class
	local self, protected = GnomTECWidget(title, parent)
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.childs = {}
	protected.containerFrame = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local layout = layout
	
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(level, message, ...)
		protected.LogMessage("<Widget> GnomTECWidgetContainer", level, message, ...)
	end

	function self.AddChild(child, childProtected)
		self.RemoveChild(child)
		table.insert(protected.childs, {widget = child, widgetProtected = childProtected})
		childProtected.widgetFrame:SetParent(protected.containerFrame)
		childProtected.widgetFrame:ClearAllPoints()
		childProtected.widgetFrame:SetPoint("TOPLEFT", 0, 0)

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
			self.TriggerResize(child, 0, 0)
		end
	end
	
	function self.GetMinReseize()
		-- should be calculated according childs and layouter
		local minWidth, minHeight = layout.GetMinReseize()

		return minWidth, minHeight
	end

	function self.GetMaxReseize()
		-- should be calculated according childs and layouter
		local maxWidth, maxHeight = layout.GetMaxReseize()
		
		return maxWidth, maxHeight
	end

	function self.IsProportionalReseize()
		-- should be calculated according childs and layouter
		local isProp = layout.IsProportionalReseize()

		return isProp
	end
	
	function self.ResizeByWidth(pixelWidth)
		-- should be calculated according childs and layouter
		local pixelHeight = layout.ResizeByWidth(pixelWidth)

		-- we don't change the size in base classes as we don't know what to do
		-- but we can compute the needed size of container frame and report it to derived class
		return pixelHeight
	end

	function self.ResizeByHeight(pixelHeight)
		-- should be calculated according childs and layouter
		local pixelWidth = layout.ResizeByHeight(pixelHeight)

		-- we don't change the size in base classes as we don't know what to do
		-- but we can compute the needed size of container frame and report it to derived class
		return pixelWidth
	end
	
	function self.TriggerResize(child, dx, dy)
		layout.TriggerResize(child, dx, dy)
		if (protected.widgetParent) then
			protected.widgetParent.TriggerResize(self, dx, dy)
		else
			local minWidth, minHeight = self.GetMinReseize()
			local maxWidth, maxHeight = self.GetMaxReseize()
			local width = self.GetPixelWidth()
			local height = self.GetPixelHeight()
			
			
			if (math.abs(dx) >= math.abs(dy)) then
				-- take width and resize widget
				if (width < minWidth) then
					width = minWidth
				elseif (width > maxWidth) then
					width = maxWidth
				end
				self.ResizeByWidth(width)
			else
				-- take height and resize widget
				if (height < minHeight) then
					height = minHeight
				elseif (height > maxHeight) then
					height = maxHeight
				end
				self.ResizeByHeight(height)
			end
		end
	end
	
	-- constructor
	do
		layout.Init(self, protected)
		self.LogMessage(LOG_DEBUG, "New GnomTECWidgetContainer instance created (%s)", protected.widgetUID)
	end
	
	-- return the instance and protected table
	return self, protected
end


