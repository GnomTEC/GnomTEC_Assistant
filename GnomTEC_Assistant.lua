-- **********************************************************************
-- GnomTEC Assistant
-- Version: 5.4.2.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Addon global Constants (local)
-- ----------------------------------------------------------------------


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
				name = "|cffffd700".."Version"..": ".._G["GREEN_FONT_COLOR_CODE"]..GetAddOnMetadata("GnomTEC_Assistant", "Version"),
				},
				descriptionAuthor = {
					order = 2,
					type = "description",
					name = "|cffffd700".."Autor"..": ".."|cffff8c00".."GnomTEC",
				},
				descriptionEmail = {
					order = 3,
					type = "description",
					name = "|cffffd700".."Email"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."info@gnomtec.de",
				},
				descriptionWebsite = {
					order = 4,
					type = "description",
					name = "|cffffd700".."Website"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."http://www.gnomtec.de/",
				},
				descriptionLicense = {
					order = 5,
					type = "description",
					name = "|cffffd700".."Copyright"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."(c)2014 by GnomTEC",
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


-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_Assistant = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_Assistant", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC Assistant Main", optionsMain)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC Assistant Main", "GnomTEC Assistant");

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
-- Addon OnInitialize, OnEnable and OnDisable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_Assistant:OnInitialize()
 	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("GnomTEC_AssistantDB")

  	GnomTEC_Assistant:Print("Willkommen bei GnomTEC_Assistant")
  	  	
end

-- function called on enable of addon
function GnomTEC_Assistant:OnEnable()
    -- Called when the addon is enabled
	local realm = GetRealmName()

	GnomTEC_Assistant:Print("GnomTEC_Assistant Enabled")

	-- Initialize options which are propably not valid because they are new added in new versions of addon
		
	-- set local parameters
	
	-- initialize hooks and events

	-- initialize some parts of GUI 
	GnomTEC_Assistant_Window_Header_Title:SetText("GnomTEC Assistant")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabAddons_Title:SetText("Addons")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabLog_Title:SetText("Log")
	GnomTEC_Assistant_Window_InnerFrame_Container_Tabulator_TabDemo_Title:SetText("Demo")


	T_GnomTEC_Demo_Window_InnerFrame_Container:SetParent(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo_Title:SetText("GnomTEC Templates Demonstration")
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("TOPLEFT", 0, -30)
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("BOTTOMRIGHT")
	GnomTEC_Assistant_Window:Show()

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

function GnomTEC:RegisterAddon(addon, addonInfo)
	GnomTEC_Assistant:AddMessage2Log("=== "..(addonInfo["Name"]  or "?").." registerd ===",0.0,1.0,0.0)
	GnomTEC_Assistant:AddMessage2Log("Version: "..(addonInfo["Version"]  or "?"))
	GnomTEC_Assistant:AddMessage2Log("Author: "..(addonInfo["Author"]  or "?"))
	GnomTEC_Assistant:AddMessage2Log("Email: "..(addonInfo["Email"]  or "?"))
	GnomTEC_Assistant:AddMessage2Log("Website: "..(addonInfo["Website"]  or "?"))
	GnomTEC_Assistant:AddMessage2Log("Copyright: "..(addonInfo["Copyright"]  or "?"))			
end

function GnomTEC:DebugMessage(addon, message)
	GnomTEC_Assistant:AddMessage2Log(addon:GetName()..": "..message,1.0,1.0,0.0)
end

