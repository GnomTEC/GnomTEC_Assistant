-- **********************************************************************
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
-- Addon Static Variables (local)
-- ----------------------------------------------------------------------
local addonDataObject =	{
	type = "launcher",
	label = "GnomTEC Assistant",
	icon = [[Interface\Icons\Inv_Misc_Tournaments_banner_Gnome]],
	OnClick = function(self, button)
		GnomTEC_Assistant.ShowMainWindow()
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine(" ")
		tooltip:AddLine("Hinweis: Links-Klick um GnomTEC Assistant zu öffnen",0.0,1.0,0.0)
	end,
}

local logDataObject =	{
	type = "data source",
	text = "0 new",
	value = "0",
	suffix = "new",
	label = "GnomTEC Log Messages",
	icon = [[Interface\Icons\INV_Inscription_Scroll]],
	OnClick = function(self, button)
		GnomTEC_Assistant.ShowLogWindow()
	end,
	OnTooltipShow = function(tooltip)
		GnomTEC_Assistant.ShowLogTooltip(tooltip)
	end,
}


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
	local logWindow = nil
	local logWindowMessages = nil

	local logNumAll = 0
	local logNumClass = 0
	local logNumLayout = 0
	local logNumWidget = 0
	local logNumAddon = 0
	local logNumOther = 0
	
	-- private methods
	-- local function f()
	local function LogReceiver(timestamp, classLevel, logLevel, title, message, ...)
		if (logWindowMessages) then
			local levelColor
			if (logLevel == LOG_FATAL) then
				levelColor = "FFFF0000"	-- red
			elseif (logLevel == LOG_ERROR) then
				levelColor = "FFFF8000"	-- orange
			elseif (logLevel == LOG_WARN) then
				levelColor = "FFFFFF00"	-- yellow
			elseif (logLevel == LOG_INFO) then
				levelColor = "FFFFFFFF"	-- white
			elseif (logLevel == LOG_DEBUG) then
				levelColor = "FFC0C0C0"	-- grey
			else
				-- LOG_???
				levelColor = "FF0000FF"	-- blue
			end

			logNumAll = logNumAll + 1
			local classColor
			local classText
			if (classLevel == CLASS_CLASS) then
				logNumClass = logNumClass + 1
				classColor = "FFFF0000"	-- red
				classText = "<class>"
			elseif (classLevel == CLASS_LAYOUT) then
				logNumLayout = logNumLayout + 1
				classColor = "FFFF8000"	-- orange
				classText = "<layout>"
			elseif (classLevel == CLASS_WIDGET) then
				logNumWidget = logNumWidget + 1
				classColor = "FFFFFF00"	-- yellow
				classText = "<widget>"
			elseif (classLevel == CLASS_ADDON) then
				logNumAddon = logNumAddon + 1
				classColor = "FF00FF00"	-- green
				classText = "<addon>"
			else
				-- CLASS_???
				logNumOther = logNumOther + 1
				classColor = "FF0000FF"	-- blue
				classText = "<unknown>"
			end

			local text = string.format("%s: |c%s%s %s:|r |c%s%s|r", timestamp, classColor, classText, title or "???", levelColor, string.format(message or "???", ...))
			logWindowMessages.AddMessage(text, 1.0, 1.0, 1.0, classLevel)

			if (logWindow.IsShown()) then
				logDataObject.value = 0
			else
				logDataObject.value = logDataObject.value + 1
			end
			logDataObject.text = logDataObject.value.." "..logDataObject.suffix
		end
	end
	
	local function OnShowLogWindow()
		logDataObject.value = 0
		logDataObject.text = logDataObject.value.." "..logDataObject.suffix
	end

	-- protected methods
	-- function protected.f()
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	end

	function protected.OnEnable()
  	  -- Called when the addon is enabled
		mainWindow = GnomTECWidgetContainerWindow("GnomTEC Widget Test", GnomTECLayoutFill())
		mainWindowMap = GnomTECWidgetMap("Map", mainWindow)
		
		logWindow = GnomTECWidgetContainerWindow("GnomTEC Log Messages", GnomTECLayoutFill())
		logWindowMessages = GnomTECWidgetScrollingMessage("Messages", logWindow)
		logWindow.OnShow = OnShowLogWindow
		
		self.RegisterLogReceiver(LogReceiver)

		addonDataObject = self.NewDataObject("", addonDataObject)
		logDataObject = self.NewDataObject("Log Messages", logDataObject)
		
		self.ShowMinimapIcon(addonDataObject)
	end

	function protected.OnDisable()
		-- Called when the addon is disabled
		self.UnregisterLogReceiver(LogReceiver)
	end
	
	-- public methods
	-- function self.f()
	function self.ShowMainWindow()
		mainWindow.Show()
	end

	function self.ShowLogWindow()
		logWindow.Show()
	end

	function self.ShowLogTooltip(tooltip)
		tooltip:AddLine("Anzahl empfangener Nachrichten",1.0,1.0,1.0)
		tooltip:AddDoubleLine("Nachrichten von Addons",logNumAddon,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Nachrichten von Widgets",logNumWidget,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Nachrichten von Layouter",logNumLayout,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Nachrichten von Klassen",logNumClass,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Nachrichten von Unbekannten",logNumOther,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Gesamte Anzahl von Nachrichten",logNumAll,1.0,1.0,1.0,1.0,1.0,1.0)

		tooltip:AddLine(" ")
		tooltip:AddLine("Hinweis: Links-Klick um die GnomTEC Log Messages zu öffnen",0.0,1.0,0.0)
	end

	-- constructor
	do
		self.LogMessage(LOG_INFO, "Willkommen bei GnomTEC Assistant")
	end
	
	-- return the instance table
	return self
end

-- ----------------------------------------------------------------------
-- Addon Instantiation
-- ----------------------------------------------------------------------

GnomTEC_Assistant = GnomTECAssistant()


