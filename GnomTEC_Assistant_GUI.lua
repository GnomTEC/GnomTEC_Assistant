-- **********************************************************************
-- GnomTEC Assistant - GUI Module
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Module Global Constants (local)
-- ----------------------------------------------------------------------
-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Modul Global Variables
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Modul Local Variables
-- ----------------------------------------------------------------------
local mainWindow = nil
local mainWindowMap = nil

-- ----------------------------------------------------------------------
-- Modul Startup Initialization
-- ----------------------------------------------------------------------
local gui = LibStub("AceGUI-3.0")

  
-- ----------------------------------------------------------------------
-- Local stubs for the GnomTEC API
-- ----------------------------------------------------------------------

local function GnomTEC_LogMessage(level, message, ...)
	GnomTEC:LogMessage(GnomTEC_Assistant, level, message, ...)
end

-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------

-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

local function fullunitname(unitName)
	if (nil ~= emptynil(unitName)) then
		local player, realm = strsplit( "-", unitName, 2 )
		if (not realm) then
			_,realm = UnitFullName("player")
		end
		unitName = player.."-"..realm
	end
	return unitName
end

-- ----------------------------------------------------------------------
-- Module Functions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Frame event handler and functions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Hook functions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Event handler
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Module Initialize, Enable and Disable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_Assistant:ModuleGUIInitialize()
end

-- function called on enable of addon
function GnomTEC_Assistant:ModuleGUIEnable()
	mainWindow = GnomTECWidgetContainerWindow("GnomTEC Widget Test", GnomTECLayoutFill())
	mainWindowMap = GnomTECWidgetMap("Map", mainWindow)
	mainWindow.Show()
end

-- function called on disable of addon
function GnomTEC_Assistant:ModuleGUIDisable()
end
