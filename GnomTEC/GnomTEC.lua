-- **********************************************************************
-- GnomTEC Base Class
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTEC-1.0", 1
local class, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not class then return end -- No Upgrade needed.

-- ----------------------------------------------------------------------
-- Class Global Constants (local)
-- ----------------------------------------------------------------------
-- localization (will be loaded from base class later)
local L = {}

-- texure path
local T = [[Interface\Addons\GnomTEC_Assistant\GnomTEC\Textures\]]

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
-- Class Static Variables (local)
-- ----------------------------------------------------------------------
local lastUID = 0
local maxLogBuffer = 1024
local logBuffer = {}
local logReceivers = {}

-- ----------------------------------------------------------------------
-- Class Startup Initialization
-- ----------------------------------------------------------------------
L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")

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
	function protected.LogMessage(classLevel, logLevel, title, message, ...)
		local timestamp = date("%H:%M:%S")
		table.insert(logBuffer, {timestamp, classLevel, logLevel, title, message, ...})
		while (maxLogBuffer < #logBuffer) do
			table.remove(logBuffer, 1)
			for idx, value in ipairs(logReceivers) do
				if (logReceivers[idx].logReceived > 0) then
					logReceivers[idx].logReceived = logReceivers[idx].logReceived - 1
				end
			end
		end
		
		for idx, value in ipairs(logReceivers) do
			for i=logReceivers[idx].logReceived + 1, #logBuffer do
				value.func(unpack(logBuffer[i]))
			end
			logReceivers[idx].logReceived = #logBuffer
		end
	end
	
	function protected.GetLocale()
		return L
	end

	function protected.GetTexturePath()
		return T
	end
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_BASE, logLevel, "GnomTEC", message, ...)
	end

	function self.SafeCall(func, ...)
		if type(func) == "function" then
			return func(...)
		end
	end

	function self.RegisterLogReceiver(logReceiver)
		if type(logReceiver) == "function" then
			self.UnregisterLogReceiver(logReceiver)
			table.insert(logReceivers, {func=logReceiver, logReceived=0})
			protected.LogMessage(CLASS_BASE, LOG_DEBUG, "GnomTEC", "log receiver registered")
		end
	end

	function self.UnregisterLogReceiver(logReceiver)
		if type(logReceiver) == "function" then
			local pos = 0
			for idx, value in ipairs(logReceivers) do
				if (value.func == logReceiver) then
					pos = idx
					break
				end
			end
			if (pos > 0) then
				table.remove(logReceivers, pos)
				protected.LogMessage(CLASS_BASE, LOG_DEBUG, "GnomTEC", "log receiver unregistered")
			end
		end
	end


	-- constructor
	do
		lastUID = lastUID + 1
		protected.UID = "GnomTECInstance"..lastUID
		
		protected.LogMessage(CLASS_BASE, LOG_DEBUG, "GnomTEC", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self, protected
end


