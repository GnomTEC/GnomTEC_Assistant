-- **********************************************************************
-- GnomTEC Base Class
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")


-- ----------------------------------------------------------------------
-- Class Global Constants (local)
-- ----------------------------------------------------------------------
-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Class Static Variables (local)
-- ----------------------------------------------------------------------
local lastUID = 0

-- ----------------------------------------------------------------------
-- Class Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Class
-- ----------------------------------------------------------------------

function GnomTEC()
	-- the new instance
	local self = {}
	
	-- public fields go in the instance table
	-- self.field = value

	-- create protected table
	local protected = {}

	-- protected fields go in the protected table
	-- protected.field = value
	protected.UID = nil
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
		
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	function protected.LogMessage(title, level, message, ...)
--		GnomTEC:LogMessage(addonTitle, level, message, ...)
	end
	
	-- public methods
	-- function self.f()

	
	-- constructor
	do
		lastUID = lastUID + 1
		protected.UID = "GnomTECInstance"..lastUID
		
		protected.LogMessage("<class> GnomTEC", LOG_DEBUG, "New GnomTEC instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self, protected
end


