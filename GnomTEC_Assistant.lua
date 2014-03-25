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
-- Addon Info Constants (local)
-- ----------------------------------------------------------------------
-- internal used version number since WoW only updates from TOC on game start
local addonVersion = "5.4.7.1"

-- addonInfo for addon registration to GnomTEC API
local addonInfo = {
	["Name"] = "GnomTEC Assistant",
	["Version"] = addonVersion,
	["Date"] = "2014-03-23",
	["Author"] = "GnomTEC",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "(c)2014 by GnomTEC",
}

-- ----------------------------------------------------------------------
-- Addon Global Constants (local)
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
-- Addon Static Variables (local)
-- ----------------------------------------------------------------------
local addonDataObject =	{
	type = "data source",
	text = "0 addons",
	value = "0",
	suffix = "addon(s)",
	label = "GnomTEC Assistant",
	icon = [[Interface\Icons\Inv_Misc_Tournaments_banner_Gnome]],
	OnClick = function(self, button)
		GnomTEC_Assistant.SwitchMainWindow()
	end,
	OnTooltipShow = function(tooltip)
		GnomTEC_Assistant.ShowAddonTooltip(tooltip)
	end,
}

local logDataObject =	{
	type = "data source",
	text = "0 new",
	value = "0",
	suffix = "new",
	label = "GnomTEC Logbuch",
	icon = [[Interface\Icons\INV_Inscription_Scroll]],
	OnClick = function(self, button)
		GnomTEC_Assistant.SwitchLogWindow()
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
	local self, protected = GnomTECAddon("GnomTEC_Assistant", addonInfo, 1)
		
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local mainWindowWidgets = nil
	local logWindowWidgets = nil
	local testWindowWidgets = {}

	local logNumAll = 0
	local logNumBase = 0
	local logNumClass = 0
	local logNumWidget = 0
	local logNumAddon = 0
	local logNumOther = 0
	
	-- private methods
	-- local function f()
	local function LogReceiver(timestamp, classLevel, logLevel, title, message, ...)
		if (logWindowWidgets) then
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
			if (classLevel == CLASS_BASE) then
				logNumBase = logNumBase + 1
				classColor = "FFFF0000"	-- red
				classText = "<base>"
			elseif (classLevel == CLASS_CLASS) then
				logNumClass = logNumClass + 1
				classColor = "FFFF8000"	-- orange
				classText = "<class>"
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
			logWindowWidgets.logWindowMessages.AddMessage(text, 1.0, 1.0, 1.0)

			if (logWindowWidgets.logWindow.IsShown()) then
				logDataObject.value = 0
			else
				logDataObject.value = logDataObject.value + 1
			end
			logDataObject.text = logDataObject.value.." "..logDataObject.suffix
		end
	end

	function AddonsListReceiver(pairsCommAddonsList)
		local numAddons = 0
		for key, value in pairsCommAddonsList() do
			numAddons = numAddons + 1
		end

		addonDataObject.value = numAddons
		addonDataObject.text = addonDataObject.value.." "..addonDataObject.suffix
	end
	
	local function OnShowLogWindow()
		logDataObject.value = 0
		logDataObject.text = logDataObject.value.." "..logDataObject.suffix
	end

	local function OnClickMainWindowLog(widget, button)
		self.SwitchLogWindow(true)
	end

	local function OnClickMainWindowTest(widget, button)
		self.SwitchTestWindow(widget.GetLabel(), true)
	end
	
	-- protected methods
	-- function protected.f()
	function protected.OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
	end

	function protected.OnEnable()
  	  -- Called when the addon is enabled
		
		-- force creation of logWindow and register LogReceiver		
		self.SwitchLogWindow(false)
		self.RegisterLogReceiver(LogReceiver)

		self.RegisterAddonsListReceiver(AddonsListReceiver)
		
		addonDataObject = self.NewDataObject("", addonDataObject)
		logDataObject = self.NewDataObject("Log Messages", logDataObject)
		
		self.ShowMinimapIcon(addonDataObject)
	end

	function protected.OnDisable()
		-- Called when the addon is disabled
		self.UnregisterLogReceiver(LogReceiver)
		self.UnregisterAddonsListReceiver(AddonsListReceiver)
	end
	
	-- public methods
	-- function self.f()
	function self.SwitchMainWindow(show)
		if (not mainWindowWidgets) then
			mainWindowWidgets = {}
			mainWindowWidgets.mainWindow = GnomTECWidgetContainerWindow({title="GnomTEC Assistant"})
			mainWindowWidgets.mainWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindow})

			mainWindowWidgets.mainWindowLayoutFunctions = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayout, label="Hauptfunktionen"})

			mainWindowWidgets.mainWindowLog = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutFunctions, label="GnomTEC Logbuch"})
			mainWindowWidgets.mainWindowLog.OnClick = OnClickMainWindowLog

			mainWindowWidgets.mainWindowLayoutTest = GnomTECWidgetContainerLayoutVertical({parent=mainWindowWidgets.mainWindowLayout, label="Widget Tests"})

			mainWindowWidgets.mainWindowTestGnomTECWidgetContainerLayoutHorizontal =  GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetContainerLayoutHorizontal"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetContainerLayoutHorizontal.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetContainerLayoutVertical = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetContainerLayoutVertical"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetContainerLayoutVertical.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetEditBox = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetEditBox"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetEditBox.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetMap = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetMap"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetMap.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetPanelButton = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetPanelButton"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetPanelButton.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetScrollingMessage = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetScrollingMessage"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetScrollingMessage.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetSpacer = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetSpacer"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetSpacer.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetText = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetText"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetText.OnClick = OnClickMainWindowTest
			mainWindowWidgets.mainWindowTestGnomTECWidgetTextureButton = GnomTECWidgetPanelButton({parent=mainWindowWidgets.mainWindowLayoutTest, label="GnomTECWidgetTextureButton"})
			mainWindowWidgets.mainWindowTestGnomTECWidgetTextureButton.OnClick = OnClickMainWindowTest
		end
		
		if (nil == show) then
			if mainWindowWidgets.mainWindow.IsShown() then
				mainWindowWidgets.mainWindow.Hide()
			else
				mainWindowWidgets.mainWindow.Show()
			end
		else
			if show then
				mainWindowWidgets.mainWindow.Show()
			else
				mainWindowWidgets.mainWindow.Hide()
			end
		end
	end

	function self.SwitchLogWindow(show)
		if (not logWindowWidgets) then
			logWindowWidgets = {}
			logWindowWidgets.logWindow = GnomTECWidgetContainerWindow({title="GnomTEC Logbuch"})
			logWindowWidgets.logWindowMessages = GnomTECWidgetScrollingMessage({parent=logWindowWidgets.logWindow})
			logWindowWidgets.logWindow.OnShow = OnShowLogWindow
		end
		
		if (nil == show) then
			if logWindowWidgets.logWindow.IsShown() then
				logWindowWidgets.logWindow.Hide()
			else
				logWindowWidgets.logWindow.Show()
			end
		else
			if show then
				logWindowWidgets.logWindow.Show()
			else
				logWindowWidgets.logWindow.Hide()
			end
		end
	end

	function self.SwitchTestWindow(test, show)
		if (not testWindowWidgets[test]) then
			if ("GnomTECWidgetContainerLayoutHorizontal" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowLayout = GnomTECWidgetContainerLayoutHorizontal({parent=testWindowWidgets[test].testWindow, label="Label"})
				testWindowWidgets[test].testWindowText = {}
				for t=0, 5 do
					local text = string.format("Spalte %d", t)
					testWindowWidgets[test].testWindowText[t] = GnomTECWidgetText({parent=testWindowWidgets[test].testWindowLayout, text=text})
				end
			elseif ("GnomTECWidgetContainerLayoutVertical" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=testWindowWidgets[test].testWindow, label="Label"})
				testWindowWidgets[test].testWindowText = {}
				for t=0, 5 do
					local text = string.format("Zeile %d", t)
					testWindowWidgets[test].testWindowText[t] = GnomTECWidgetText({parent=testWindowWidgets[test].testWindowLayout, text=text})
				end
			elseif ("GnomTECWidgetEditBox" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				local text = [[Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.]]
				testWindowWidgets[test].testWindowText = GnomTECWidgetEditBox({parent=testWindowWidgets[test].testWindow, text=text})
			elseif ("GnomTECWidgetMap" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowMap = GnomTECWidgetMap({parent=testWindowWidgets[test].testWindow})
			elseif ("GnomTECWidgetPanelButton" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowPanelButton = GnomTECWidgetPanelButton({parent=testWindowWidgets[test].testWindow, label="Label"})
			elseif ("GnomTECWidgetScrollingMessage" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowScrollingMessage = GnomTECWidgetScrollingMessage({parent=testWindowWidgets[test].testWindow})
				for r=0.0, 1.0, 0.5 do
					for g=0.0, 1.0, 0.5 do
						for b=0.0, 1.0, 0.5 do
							if (r+g+b > 0) then
								local text = string.format("Testzeile (r, g, b) = (%3.1f, %3.1f, %3.1f)",r, g, b)
								testWindowWidgets[test].testWindowScrollingMessage.AddMessage(text , r, g, b)
							end
						end
					end
				end
			elseif ("GnomTECWidgetSpacer" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowLayout = GnomTECWidgetContainerLayoutVertical({parent=testWindowWidgets[test].testWindow})
				testWindowWidgets[test].testWindowPanelButton1 = GnomTECWidgetPanelButton({parent=testWindowWidgets[test].testWindowLayout, label=[[\/ Spacer \/]]})
				testWindowWidgets[test].testWindowSpacer = GnomTECWidgetSpacer({parent=testWindowWidgets[test].testWindowLayout})
				testWindowWidgets[test].testWindowPanelButton2 = GnomTECWidgetPanelButton({parent=testWindowWidgets[test].testWindowLayout, label=[[/\ Spacer /\]]})
			elseif ("GnomTECWidgetText" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowText = GnomTECWidgetText({parent=testWindowWidgets[test].testWindow, text="text"})
			elseif ("GnomTECWidgetTextureButton" == test) then
				testWindowWidgets[test] = {}
				testWindowWidgets[test].testWindow = GnomTECWidgetContainerWindow({title=test})
				testWindowWidgets[test].testWindowLayout = GnomTECWidgetContainerLayoutHorizontal({parent=testWindowWidgets[test].testWindow})
				testWindowWidgets[test].testWindowTextureButton = {}
				for t=1, 5 do
					testWindowWidgets[test].testWindowTextureButton[t] = GnomTECWidgetTextureButton({
						parent=testWindowWidgets[test].testWindowLayout,
						texture=[[Interface\ICONS\Ability_Creature_Cursed_0]]..t,
					})
				end
			end


		end
		
		if (testWindowWidgets[test]) then
			if (nil == show) then
				if testWindowWidgets[test].testWindow.IsShown() then
					testWindowWidgets[test].testWindow.Hide()
				else
					testWindowWidgets[test].testWindow.Show()
				end
			else
				if show then
					testWindowWidgets[test].testWindow.Show()
				else
					testWindowWidgets[test].testWindow.Hide()	
				end
			end
		end
	end
	
	function	self.ShowAddonTooltip(tooltip)
		tooltip:AddLine("GnomTEC Addon Informationen",1.0,1.0,1.0)
		tooltip:AddLine(" ")
		tooltip:AddLine("Registrierte Addons",1.0,1.0,1.0)

		for key, value in self.pairsCommAddonsList() do
			if (not value["AvailableVersion"]) then
				tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,0.0,1.0,0.0)
			else
				tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,1.0,0.5,0.0)
			end		
		end

		local statistics = self.CommGetStatistics()		
		tooltip:AddLine(" ")
		tooltip:AddLine("Übertragen Daten (Gesamt)",1.0,1.0,1.0)
		tooltip:AddDoubleLine("Gesendete Bytes",statistics.commSendBytes,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Empfangene Bytes",statistics.commReceiveBytes,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddLine(" ")
		tooltip:AddLine("Abfrage an andere Spieler",1.0,1.0,1.0)
		tooltip:AddDoubleLine("Anzahl Abfragen",statistics.commRequestCount,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Gesendete Bytes",statistics.commRequestSendBytes,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Empfangene Bytes",statistics.commRequestReceiveBytes,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddLine(" ")
		tooltip:AddLine("Anfrage von anderern Spieler",1.0,1.0,1.0)
		tooltip:AddDoubleLine("Anzahl Anfragen",statistics.commResponseCount,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Empfangene Bytes",statistics.commResponseReceiveBytes,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Gesendete Bytes",statistics.commResponseSendBytes,1.0,1.0,0.0,1.0,1.0,1.0)

		tooltip:AddLine(" ")
		tooltip:AddLine("Hinweis: Links-Klick um GnomTEC Assistant zu öffnen/schließen",0.0,1.0,0.0)
	end	

	function self.ShowLogTooltip(tooltip)
		tooltip:AddLine("Anzahl Einträge im Logbuch",1.0,1.0,1.0)
		tooltip:AddDoubleLine("Einträge von Addons",logNumAddon,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Einträge von Widgets",logNumWidget,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Einträge von Klasssen",logNumClass,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Einträge von der Basisklasse",logNumBase,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Einträge von Unbekannten",logNumOther,1.0,1.0,0.0,1.0,1.0,1.0)
		tooltip:AddDoubleLine("Gesamte Anzahl von Einträge",logNumAll,1.0,1.0,1.0,1.0,1.0,1.0)

		tooltip:AddLine(" ")
		tooltip:AddLine("Hinweis: Links-Klick um das GnomTEC Logbuch zu öffnen/schließen",0.0,1.0,0.0)
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
