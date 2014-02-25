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
	["Date"] = "2014-02-25",
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

local addonsList = {}
local addonsTable = {}


-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_Assistant = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_Assistant", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC Assistant Main", optionsMain)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC Assistant Main", "GnomTEC Assistant");

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

function GnomTEC_Assistant:AddMessage2Log(...)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Log_Text:AddMessage(...)
end

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
	self.db = LibStub("AceDB-3.0"):New("GnomTEC_AssistantDB")

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

	-- initialize some parts of GUI 
	GnomTEC_Assistant_Window_Header_Title:SetText("GnomTEC Assistant")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabAddons_Title:SetText("Addons")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabLog_Title:SetText("Log")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabDemo_Title:SetText("Demo")

	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label1_Title:SetText("Name")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label2_Title:SetText("Version")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label3_Title:SetText("Datum")
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons_LabelFrame_Label4_Title:SetText("Autor")

	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons, addonsTable)	

	T_GnomTEC_Demo_Window_InnerFrame_Container:SetParent(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo_Title:SetText("GnomTEC Templates Demonstration")
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("TOPLEFT", 0, -30)
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("BOTTOMRIGHT")
--	GnomTEC_Assistant_Window:Show()

--	T_GnomTEC_Demo_Window:Show()
end

-- function called on disable of addon
function GnomTEC_Assistant:OnDisable()
    -- Called when the addon is disabled
    GnomTEC_Assistant:UnregisterAllEvents();
    
end

-- ----------------------------------------------------------------------
-- External API
-- ----------------------------------------------------------------------

GnomTEC = {}

--[[
GnomTEC:RegisterAddon()
Parameters: addon, addonInfo, revision
	addon - Ace3 addon object
	addonInfo - table with addon informations as string
		["Name"] 		- name
		["Version"] 	- version
		["Date"] = 		- date
		["Author"] 		- author
		["Email"] 		- contact email
		["Website"] 	- URL to addon website
		["Copyright"] 	- copyright information
	revision - GnomTEC API revision for which the registered addon is made
Returns: registerd
	registerd
		true 	- addon is successfuly registered and compatible to actual API
		false - addon is registerd but probably incompatible to actual API
--]]
function GnomTEC:RegisterAddon(addon, addonInfo, revision)
	local addonName = addon:GetName()
	
	addonsList[addonName] = {
		["Addon"] = addon,
		["AddonInfo"] = addonInfo,
		["Revision"] = revision		
	}
	
	GnomTEC_LogMessage(LOG_INFO, (addonInfo["Name"]).." ("..(addonInfo["Version"]).." / "..(addonInfo["Date"])..") registriert")

	if (GNOMTEC_REVISION < revision) then
		GnomTEC_LogMessage(LOG_WARN, (addonInfo["Name"]).." benötigt aktuellere GnomTEC API")
	end
	
	table.insert(addonsTable,{ {addonInfo["Name"]}, {addonInfo["Version"]}, {addonInfo["Date"]}, {addonInfo["Author"]} })
	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons, addonsTable)	

	return (GNOMTEC_REVISION >= revision)
end

--[[
GnomTEC:LogMessage()
Parameters: addon, level, message
	addon - Ace3 addon object
	level - debug level of the message
		0 	- FATAL	(severe error which leads to abort of addon)
		1	- ERROR	(harmful situation)
		2	- WARN	(potentially harmful situation)
		3	- INFO	(information about addon states)
		4	- DEBUG	(debugging message)
	message - message to show in log
Returns: -
--]]
function GnomTEC:LogMessage(addon, level, message)
	local name = "<nil>"
	local color = {1.0,1.0,1.0}
	
	if (addon) then
		name = addon:GetName() or "<???>"
	end
	
	if (0 == level) then			-- FATAL
		color = {1.0,0.0,0.0}
	elseif (1 == level) then	-- ERROR
		color = {1.0,0.5,0.0}
	elseif (2 == level) then	-- WARN
		color = {1.0,1.0,0.0}
	elseif (3 == level) then	-- INFO
		color = {1.0,1.0,1.0}
	else								-- DEBUG
		color = {0.5,0.5,0.5}
	end
	
	message = message or "?"
		
	GnomTEC_Assistant:AddMessage2Log(name..": "..message,unpack(color))
end

