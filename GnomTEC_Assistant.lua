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
-- Addon global Constants (local)
-- ----------------------------------------------------------------------

-- internal used version number since WoW only updates from TOC on game start
local addonVersion = "5.4.7.1"

-- addonInfo for addon registration to GnomTEC API
local addonInfo = {
	["Name"] = "GnomTEC Assistant",
	["Version"] = addonVersion,
	["Date"] = "2014-03-02",
	["Author"] = "GnomTEC",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "(c)2014 by GnomTEC",
}

-- GnomTEC API revision
local GNOMTEC_REVISION = 0

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- default data for database
local defaultsDb = {
	global = {
		lastTimestamp = 0,
		staticData = {}
	},
	profile = {
		minimap = {
			hide = false,
		},
	},
}

-- ----------------------------------------------------------------------
-- Addon global variables (local)
-- ----------------------------------------------------------------------

-- Main options menue with general addon information
local optionsMain = {
	name = "GnomTEC Assistant",
	type = "group",
	args = {
		descriptionTitle = {
			order = 1,
			type = "description",
			name = L["L_OPTIONS_TITLE"],
		},
		descriptionAbout = {
			name = "About",
			type = "group",
			guiInline = true,
			order = 2,
			args = {
				descriptionVersion = {
				order = 1,
				type = "description",			
				name = "|cffffd700".."Version"..": ".._G["GREEN_FONT_COLOR_CODE"]..addonInfo["Version"],
				},
				descriptionAuthor = {
					order = 2,
					type = "description",
					name = "|cffffd700".."Author"..": ".."|cffff8c00"..addonInfo["Author"],
				},
				descriptionEmail = {
					order = 3,
					type = "description",
					name = "|cffffd700".."Email"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Email"],
				},
				descriptionWebsite = {
					order = 4,
					type = "description",
					name = "|cffffd700".."Website"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Website"],
				},
				descriptionLicense = {
					order = 5,
					type = "description",
					name = "|cffffd700".."Copyright"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Copyright"],
				},
			}
		},
		descriptionLogo = {
			order = 5,
			type = "description",
			name = "",
			image =  "Interface\\AddOns\\GnomTEC_Assistant\\Textures\\GnomTEC-Logo",
			imageCoords = {0.0,1.0,0.0,1.0},
			imageWidth = 512,
			imageHeight = 128,
		},
	}
}

local lastTimerEvent = 0

-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_Assistant = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_Assistant", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC Assistant Main", optionsMain)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC Assistant Main", "GnomTEC Assistant");

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

GnomTEC_Assistant.addonsList = {}
GnomTEC_Assistant.addonsTable = {}

GnomTEC_Assistant.ldbDataObjs= {}
  
-- ----------------------------------------------------------------------
-- Local stubs for the GnomTEC API
-- ----------------------------------------------------------------------

local function GnomTEC_LogMessage(level, message)
	GnomTEC:LogMessage(GnomTEC_Assistant, level, message)
end

local function GnomTEC_RegisterAddon()
	GnomTEC:RegisterAddon(GnomTEC_Assistant, addonInfo, GNOMTEC_REVISION) 
end


-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------

-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

-- function to cleanup control sequences
local function cleanpipe( x )
	x = x or ""
	
	-- Filter coloring
	x = string.gsub( x, "|c%x%x%x%x%x%x%x%x", "" )
	x = string.gsub( x, "|r", "" )
	
	-- Filter links
	x = string.gsub( x, "|H.-|h", "" )
	x = string.gsub( x, "|h", "" )
	
	-- Filter textures
	x = string.gsub( x, "|T.-|t", "" )

	-- Filter battle.net friend's name
	x = string.gsub( x, "|K.-|k", "" )
	x = string.gsub( x, "|k", "" )

	-- Filter newline
	x = string.gsub( x, "|n", "" )
	
	-- at last filter any left escape
	x = string.gsub( x, "|", "/" )	
	
	return strtrim(x)
end

local function pairsByKeys (t, f)
	local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end

-- function to detect that unit is a player from whom we could get a flag
-- Fix issue for NPC units for which the API function Fixed_UnitIsPlayer() don't return nil
-- (such as Wrathion quest line and Proving Grounds)
local function Fixed_UnitIsPlayer(unitId) 
	if (UnitIsPlayer(unitId)) then
		-- NPCs have no race (at least at the moment)
	   if (UnitRace(unitId)) then
	   	return true
	   else
	   	return false
	   end
	else
 	  return false
	end
end

function GnomTEC_Assistant:AddMessage2Log(...)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Log_Text:AddMessage(...)
end

function	GnomTEC_Assistant:AddToooltipLines_Addons(tooltip)
	tooltip:AddLine("GnomTEC Addon Informationen",1.0,1.0,1.0)
	tooltip:AddLine(" ")
	tooltip:AddLine("Registrierte Addons",1.0,1.0,1.0)
	for key, value in pairsByKeys(GnomTEC_Assistant.addonsList) do
		if (not value["AvailableVersion"]) then
			tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,1.0,1.0,1.0)
		else
			tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,1.0,0.5,0.0)
		end		
	end
	tooltip:AddLine(" ")
	tooltip:AddLine("Abfrage von Daten anderer Spieler",1.0,1.0,1.0)
	tooltip:AddDoubleLine("Anzahl getätigter Abfragen",GnomTEC_Assistant.commRequestCount,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddDoubleLine("Übertragene Bytes",GnomTEC_Assistant.commRequestBytes,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddLine(" ")
	tooltip:AddLine("Anfrage von anderern Spieler von Daten",1.0,1.0,1.0)
	tooltip:AddDoubleLine("Anzahl getätigter Anfragen",GnomTEC_Assistant.commResponseCount,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddDoubleLine("Übertragene Bytes",GnomTEC_Assistant.commResponseBytes,1.0,1.0,0.0,1.0,1.0,1.0)
end

function GnomTEC_Assistant:CreateTimestamp()
	local timestamp = time()
	
	if (timestamp < self.db.global.lastTimestamp) then
		timestamp = self.db.global.lastTimestamp + 1
	end

	self.db.global.lastTimestamp = timestamp

	return timestamp
end

function GnomTEC_Assistant:GetStaticData(target)
	local player, realm = strsplit( "-", target, 2 )
	realm = string.gsub(realm or GetRealmName(), "%s+", "")

	if (not self.db.global.staticData[realm]) then self.db.global.staticData[realm] = {} end
	if (not self.db.global.staticData[realm][player]) then
		self.db.global.staticData[realm][player] = {}
		self.db.global.staticData[realm][player].scantime = 0
		self.db.global.staticData[realm][player].supported = false
		self.db.global.staticData[realm][player].time = 0
		self.db.global.staticData[realm][player].addons = {}
	end

	return self.db.global.staticData[realm][player]
end

-- ----------------------------------------------------------------------
-- Frame event handler and functions
-- ----------------------------------------------------------------------
function GnomTEC_Assistant:TimerEvent()
	local t = GetTime()

	-- Check every 5 seconds
	if ((t-lastTimerEvent) > 5) then
		lastTimerEvent = t

	end
end

-- ----------------------------------------------------------------------
-- Hook functions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Event handler
-- ----------------------------------------------------------------------


function GnomTEC_Assistant:UPDATE_MOUSEOVER_UNIT(eventName)
	if (not UnitIsUnit("mouseover", "player")) then
		local player, realm = UnitName("mouseover")
		realm = string.gsub(realm or GetRealmName(), "%s+", "")

 		if Fixed_UnitIsPlayer("mouseover") and player and realm then
			GnomTEC_Assistant:RequestStaticData(player.."-"..realm)
	 	end
 	end
 end
 
 function GnomTEC_Assistant:GNOMTEC_UPDATE_STATICDATA(eventName, sender, addonName, data)
 	if (self:GetName() == addonName) then
 		for key, value in pairs(data) do
 			if (GnomTEC_Assistant.addonsList[key]) then
 				local version = addonInfo["Version"] 
 				local _,_,_,revision = strsplit( ".", version, 4 )
 				local myVersion = GnomTEC_Assistant.addonsList[key]["Version"]
 				local _,_,_,myRevision = strsplit( ".", myVersion, 4 )
 				
 				if (tonumber(myRevision) < tonumber(revision)) then
 					if (not GnomTEC_Assistant.addonsList[key]["AvailableVersion"]) then
 						GnomTEC_Assistant.addonsList[key]["AvailableVersion"] = version
 					else
		 				local availableVersion = GnomTEC_Assistant.addonsList[key]["AvailableVersion"]
 						local _,_,_,availableRevision = strsplit( ".", availableVersion, 4 )

		 				if (tonumber(availableRevision) < tonumber(myRevision)) then
	 						GnomTEC_Assistant.addonsList[key]["AvailableVersion"] = version
		 				end
 					end	
 				end
 			end
		end
	end
 end
 
-- ----------------------------------------------------------------------
-- chat commands
-- ----------------------------------------------------------------------
function GnomTEC_Assistant:ChatCommand_gnomtec(input)
	GnomTEC_Assistant_Window:Show()
end


-- ----------------------------------------------------------------------
-- Addon OnInitialize, OnEnable and OnDisable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_Assistant:OnInitialize()
 	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("GnomTEC_AssistantDB", defaultsDb, true)

	-- cleanup all staticData (at least for alpha versions)
	self.db.global.lastTimestamp = 0
	self.db.global.staticData = {}
	
	-- initialize libdatabroker dataobjects
	GnomTEC_Assistant.ldbDataObjs["Addons"] = ldb:NewDataObject("GnomTEC_Assistant", {
		type = "data source",
		text = "0 Addons",
		value = "0",
		suffix = "Addons",
		label = "GnomTEC",
		icon = "Interface\\Icons\\Inv_Misc_Tournaments_banner_Gnome",
		OnClick = function(self, button)
			GnomTEC_Assistant_Window:Show()
		end,
		OnTooltipShow = function(tooltip)
			GnomTEC_Assistant:AddToooltipLines_Addons(tooltip)
			tooltip:AddLine(" ")
			tooltip:AddLine("Hinweis: Links-Klick um GnomTEC Assistant zu öffnen",0.0,1.0,0.0)
		end,
	})

	-- register minimap button
	icon:Register("GnomTEC_Assistant", GnomTEC_Assistant.ldbDataObjs["Addons"], self.db.profile.minimap)

	-- initialize modules
	GnomTEC_Assistant:ModuleChatInitialize()
	GnomTEC_Assistant:ModuleCommInitialize()
		
	-- we also register us in your own list
  	GnomTEC_RegisterAddon() 	

  	GnomTEC_LogMessage(LOG_INFO,"Willkommen bei GnomTEC_Assistant")
end

-- function called on enable of addon
function GnomTEC_Assistant:OnEnable()
    -- Called when the addon is enabled
	local realm = GetRealmName()

	GnomTEC_LogMessage(LOG_INFO,"GnomTEC_Assistant Enabled")

	-- Initialize options which are propably not valid because they are new added in new versions of addon
		
	-- set local parameters
	
	-- initialize hooks and events
	GnomTEC_Assistant:RegisterChatCommand("gnomtec", "ChatCommand_gnomtec")
	GnomTEC_Assistant:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	GnomTEC:RegisterEvent(self, "GNOMTEC_UPDATE_STATICDATA")

	-- initialize some parts of GUI 
	GnomTEC_Assistant_Window_Header_Title:SetText("GnomTEC Assistant")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabAddons_Title:SetText("Addons")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabLog_Title:SetText("Log")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabDemo_Title:SetText("Demo")

	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label1_Title:SetText("Name")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label2_Title:SetText("Version")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label3_Title:SetText("Datum")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label4_Title:SetText("Autor")

	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons, GnomTEC_Assistant.addonsTable)	

	T_GnomTEC_Demo_Window_InnerFrame_Container:SetParent(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo_Title:SetText("GnomTEC Templates Demonstration")
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("TOPLEFT", 0, -30)
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("BOTTOMRIGHT")
	
	-- Enable Modules
	GnomTEC_Assistant:ModuleChatEnable()
	GnomTEC_Assistant:ModuleCommEnable()
	
	-- show minimap button
	self.db.profile.minimap.hide = false
	icon:Show("GnomTEC_Assistant")
	
end

-- function called on disable of addon
function GnomTEC_Assistant:OnDisable()
	-- Called when the addon is disabled
	GnomTEC_Assistant:ModuleChatDisable()
	GnomTEC_Assistant:ModuleCommDisable()
	GnomTEC_Assistant:UnregisterAllEvents();

	self.db.profile.minimap.hide = true
	icon:Hide("GnomTEC_Assistant")
    
end
