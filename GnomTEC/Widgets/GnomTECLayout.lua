-- **********************************************************************
-- GnomTECLayout
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
-- Layout Static Variables (local)
-- ----------------------------------------------------------------------
local lastUID = 0


-- ----------------------------------------------------------------------
-- Layout Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Layout Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Layout Class
-- ----------------------------------------------------------------------

function GnomTECLayout()
	-- call base class
	local self, protected = GnomTEC()
	
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	protected.containerWidget = nil
	protected.containerProtected = nil

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
		protected.LogMessage(CLASS_LAYOUT, logLevel, "GnomTECLayout", message, ...)
	end

	function self.Init(containerWidget, containerProtected)
		protected.containerWidget = containerWidget
		protected.containerProtected = containerProtected
	end
	
	function self.GetMinReseize()
		-- should be calculated according childs and layouter
		local minWidth = 0
		local minHeight = 0

		return minWidth, minHeight
	end

	function self.GetMaxReseize()
		-- should be calculated according childs and layouter
		local maxWidth = UIParent:GetWidth()
		local maxHeight = UIParent:GetHeight()
		
		return maxWidth, maxHeight
	end

	function self.IsProportionalReseize()
		-- should be calculated according childs and layouter
		return false
	end
	
	function self.ResizeByWidth(pixelWidth, pixelHeight)
		-- should be calculated according childs and layouter

		-- we don't change the size in layouter as we don't know what to do
		-- but we can compute the needed size of layout and report it to the container widget
		return pixelWidth, pixelHeight
	end

	function self.ResizeByHeight(pixelWidth, pixelHeight)
		-- should be calculated according childs and layouter

		-- we don't change the size in layouter as we don't know what to do
		-- but we can compute the needed size of layout and report it to the container widget
		return pixelWidth, pixelHeight
	end
	
	function self.TriggerResize(child, dx, dy)
		-- a resize is triggered by some child
		-- here we can prepare for later resize
	end
	
	-- constructor
	do
		lastUID = lastUID + 1
		protected.layoutUID = "GnomTECLayoutInstance"..lastUID

		protected.LogMessage(CLASS_LAYOUT, LOG_DEBUG, "GnomTECLayout", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance and protected table
	return self, protected
end


