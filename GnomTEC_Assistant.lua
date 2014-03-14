﻿-- **********************************************************************
-- GnomTEC Assistant
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Addon Global Constants (local)
-- ----------------------------------------------------------------------
-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Addon Static Variables (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Addon Startup Initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Addon Class
-- ----------------------------------------------------------------------

local function GnomTECAssistant()
	-- call base class
	local self, protected = GnomTECAddon("GnomTEC_Assistant")
		
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local mainWindow = nil
	local mainWindowMap = nil
		
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	local base_OnInitialize = protected.OnInitialize
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	 	base_OnInitialize()
	end

	local base_OnEnable = protected.OnEnable
	function protected.OnEnable()
  	  -- Called when the addon is enabled
  	  base_OnEnable()
  	  
		mainWindow = GnomTECWidgetContainerWindow("GnomTEC Widget Test", GnomTECLayoutFill())
		mainWindowMap = GnomTECWidgetMap("Map", mainWindow)
		mainWindow.Show()
	end

	local base_OnDisable = protected.OnDisable
	function protected.OnDisable()
		-- Called when the addon is disabled
		base_OnDisable()
	end
	
	-- public methods
	-- function self.f()
	
	-- constructor
	do
		self.LogMessage(LOG_DEBUG, "Willkommen bei GnomTEC Assistant")
	end
	
	-- return the instance table
	return self
end

-- ----------------------------------------------------------------------
-- Addon Instantiation
-- ----------------------------------------------------------------------

GnomTEC_Assistant = GnomTECAssistant()


