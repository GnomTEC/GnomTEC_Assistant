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
	["Date"] = "2014-03-01",
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

local ADDONMESSAGE_PREFIX = "GNOMTEC"

-- settings how often to check for data
local COMM_PROBE_FREQUENCY = 300.0 + math.random(0, 60) -- Wait 5-6 minutes for someone to respond before asking again
local COMM_FIELD_UPDATE_FREQUENCY = 10.0 + math.random(0, 5) -- Fields newer than 10-15 seconds old are still fresh

-- communication commands
local COMM_REQ_STATICDATA_TIMESTAMP		= "RQSDT"	-- data = nil
local COMM_RES_STATICDATA_TIMESTAMP		= "RSSDT"	-- data = {timestamp}
local COMM_REQ_STATICDATA_DATAPART	 	= "RQSDP"	-- data = {part, timestamp}
local COMM_RES_STATICDATA_DATAPART		= "RSSDP"	-- data = {part, timestamp, data}

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

local ldbDataObjs= {}

local lastTimerEvent = 0

local commResponseCount = 0
local commResponseBytes = 0
local commRequestCount = 0
local commRequestBytes= 0


-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_Assistant = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_Assistant", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC Assistant Main", optionsMain)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC Assistant Main", "GnomTEC Assistant");

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

GnomTEC = {}
GnomTEC.callbacks = GnomTEC.callbacks or LibStub("CallbackHandler-1.0"):New(GnomTEC)
  
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
	for key, value in pairsByKeys(addonsList) do
		if (not value["AvailableVersion"]) then
			tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,1.0,1.0,1.0)
		else
			tooltip:AddDoubleLine(value["AddonInfo"]["Name"],value["AddonInfo"]["Version"],1.0,1.0,0.0,1.0,0.5,0.0)
		end		
	end
	tooltip:AddLine(" ")
	tooltip:AddLine("Abfrage von Daten anderer Spieler",1.0,1.0,1.0)
	tooltip:AddDoubleLine("Anzahl getätigter Abfragen",commRequestCount,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddDoubleLine("Übertragene Bytes",commRequestBytes,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddLine(" ")
	tooltip:AddLine("Anfrage von anderern Spieler von Daten",1.0,1.0,1.0)
	tooltip:AddDoubleLine("Anzahl getätigter Anfragen",commResponseCount,1.0,1.0,0.0,1.0,1.0,1.0)
	tooltip:AddDoubleLine("Übertragene Bytes",commResponseBytes,1.0,1.0,0.0,1.0,1.0,1.0)
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

function GnomTEC_Assistant:CommSend(target, comm, ...)
	local sd = GnomTEC_Assistant:GetStaticData(target)
	local now = GetTime()
	
	if sd.supported == false and ( now < sd.scantime + COMM_PROBE_FREQUENCY ) then
		return
	elseif not sd.supported then
		sd.supported = false
		sd.scantime = now
	end

	local serialized = GnomTEC_Assistant:Serialize(comm, ...)
	local bytes = string.len(serialized)

	if (comm == COMM_REQ_STATICDATA_TIMESTAMP) then
		commRequestCount = commRequestCount + 1
		commRequestBytes = commRequestBytes + bytes
	elseif (comm == COMM_RES_STATICDATA_TIMESTAMP) then
		commResponseBytes = commResponseBytes + bytes
	elseif (comm == COMM_REQ_STATICDATA_DATAPART) then
		commRequestCount = commRequestCount + 1
		commRequestBytes = commRequestBytes + bytes
	elseif (comm == COMM_RES_STATICDATA_DATAPART) then
		commResponseBytes = commResponseBytes + bytes
	end

	GnomTEC_Assistant:SendCommMessage(ADDONMESSAGE_PREFIX, serialized, "WHISPER", target, "BULK")	
end


function GnomTEC_Assistant:CommRequestStaticDataTimestamp(target)
	GnomTEC_Assistant:CommSend(target, COMM_REQ_STATICDATA_TIMESTAMP, nil)
end

function GnomTEC_Assistant:CommResponseStaticDataTimestamp(target, timestamp)
	GnomTEC_Assistant:CommSend(target, COMM_RES_STATICDATA_TIMESTAMP, timestamp)
end

function GnomTEC_Assistant:CommRequestStaticDataDataPart(target, part, timestamp)
	GnomTEC_Assistant:CommSend(target, COMM_REQ_STATICDATA_DATAPART, part, timestamp)
end

function GnomTEC_Assistant:CommResponseStaticDataDataPart(target, part, timestamp, data)
	GnomTEC_Assistant:CommSend(target, COMM_RES_STATICDATA_DATAPART, part, timestamp, data)
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
function GnomTEC_Assistant:OnCommReceived(prefix, message, distribution, sender)
	if (prefix == ADDONMESSAGE_PREFIX) then
		local sd = GnomTEC_Assistant:GetStaticData(sender)

		sd.supported = true
		sd.scantime = 0

		local bytes = string.len(message)
		local messageParts = {GnomTEC_Assistant:Deserialize(message)}
		if (not messageParts[1]) then
			GnomTEC_LogMessage(LOG_ERROR,"Could not deserialize communication message: "..(messageParts[2] or "???").." from ".. sender)
		else
			local comm = messageParts[2]
			
			if (COMM_REQ_STATICDATA_TIMESTAMP == comm) then
				commResponseCount = commResponseCount + 1
				commResponseBytes = commResponseBytes + bytes
				GnomTEC_Assistant:CommResponseStaticDataTimestamp(sender, sd.timestamp or "0")
			elseif (COMM_RES_STATICDATA_TIMESTAMP == comm) then
				commRequestBytes = commRequestBytes + bytes
				local timestamp = messageParts[3]
				
				if (not timestamp) then
					GnomTEC_LogMessage(LOG_ERROR,"Comm respones: "..COMM_RES_STATICDATA_TIMESTAMP..": no timestamp received".." from ".. sender)
				elseif (timestamp ~= sd.timestamp) then
					-- request updates of static data for all addons we have set static data by our self
					for key, value in pairs(GnomTEC_Assistant:GetStaticData(UnitName("player")).addons) do
			 			GnomTEC_Assistant:CommRequestStaticDataDataPart(sender, key, value.timestamp)
					end
				end
			elseif (COMM_REQ_STATICDATA_DATAPART == comm) then
				commResponseCount = commResponseCount + 1
				commResponseBytes = commResponseBytes + bytes
				local addonName = messageParts[3]
				local timestamp = messageParts[4]
				local sdp = GnomTEC_Assistant:GetStaticData(UnitName("player"))
				
				if (sdp.addons[addonName]) then
					if (sdp.addons[addonName].timestamp ~= timestamp) then
						GnomTEC_Assistant:CommResponseStaticDataDataPart(sender, addonName, sdp.addons[addonName].timestamp, sdp.addons[addonName].data)
					end
				end
			elseif (COMM_RES_STATICDATA_DATAPART == comm) then
				commRequestBytes = commRequestBytes + bytes
				local addonName = messageParts[3]
				local timestamp = messageParts[4]
				local data = messageParts[5]
			
				sd.addons[addonName].timestamp = timestamp
				sd.addons[addonName].data = data
				if (timestamp > sd.timestamp) then
				 	sd.timestamp = timestamp
				end
				GnomTEC.callbacks:Fire("GNOMTEC_UPDATE_STATICDATA", sender, addonName, data)
			else
				GnomTEC_LogMessage(LOG_WARN,"Unknown communication request or response: "..(comm or "???").." from ".. sender)
			end
		end		
	end
end

function	GnomTEC_Assistant:RequestStaticData(player)
	local sd = GnomTEC_Assistant:GetStaticData(player)
	local now = GetTime()

	if (sd.time + COMM_FIELD_UPDATE_FREQUENCY < now) then
		GnomTEC_Assistant:CommRequestStaticDataTimestamp(player)
		sd.time = now
	end
end


function GnomTEC_Assistant:UPDATE_MOUSEOVER_UNIT(eventName)
	if (not UnitIsUnit("mouseover", "player")) then
		local player, realm = UnitName("mouseover")
		realm = string.gsub(realm or GetRealmName(), "%s+", "")

 		if Fixed_UnitIsPlayer("mouseover") and player and realm then
			GnomTEC_Assistant:RequestStaticData(player.."-"..realm)
	 	end
 	end
 end
 
function GnomTEC_Assistant:CHAT_MSG_BATTLEGROUND(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_CHANNEL(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_CHANNEL_JOIN(eventName, arg1, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_EMOTE(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_GUILD(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_OFFICER(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_PARTY(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_RAID(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_SAY(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_TEXT_EMOTE(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_WHISPER(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

function GnomTEC_Assistant:CHAT_MSG_YELL(eventName, message, sender)	
	-- Trigger the static data request for sender
	GnomTEC_Assistant:RequestStaticData(sender)
end

 function GnomTEC_Assistant:GNOMTEC_UPDATE_STATICDATA(eventName, sender, addonName, data)
 	if (self:GetName() == addonName) then
 		for key, value in pairs(data) do
 			if (addonsList[key]) then
 				local version = addonInfo["Version"] 
 				local _,_,_,revision = strsplit( ".", version, 4 )
 				local myVersion = addonsList[key]["Version"]
 				local _,_,_,myRevision = strsplit( ".", myVersion, 4 )
 				
 				if (tonumber(myRevision) < tonumber(revision)) then
 					if (not addonsList[key]["AvailableVersion"]) then
 						addonsList[key]["AvailableVersion"] = version
 					else
		 				local availableVersion = addonsList[key]["AvailableVersion"]
 						local _,_,_,availableRevision = strsplit( ".", availableVersion, 4 )

		 				if (tonumber(availableRevision) < tonumber(myRevision)) then
	 						addonsList[key]["AvailableVersion"] = version
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
	
	-- initialize libdatabroker dataobjects
	ldbDataObjs["Addons"] = ldb:NewDataObject("GnomTEC_Assistant", {
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
	icon:Register("GnomTEC_Assistant", ldbDataObjs["Addons"], self.db.profile.minimap)
	
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
	RegisterAddonMessagePrefix(ADDONMESSAGE_PREFIX);
	GnomTEC_Assistant:RegisterComm(ADDONMESSAGE_PREFIX)
	GnomTEC_Assistant:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_BATTLEGROUND");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_CHANNEL");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_CHANNEL_JOIN");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_EMOTE");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_GUILD");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_OFFICER");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_PARTY");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_RAID");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_SAY");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_WHISPER");
	GnomTEC_Assistant:RegisterEvent("CHAT_MSG_YELL");
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

	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons, addonsTable)	

	T_GnomTEC_Demo_Window_InnerFrame_Container:SetParent(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo)
	GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Demo_Title:SetText("GnomTEC Templates Demonstration")
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("TOPLEFT", 0, -30)
	T_GnomTEC_Demo_Window_InnerFrame_Container:SetPoint("BOTTOMRIGHT")
	
	-- show minimap button
	self.db.profile.minimap.hide = false
	icon:Show("GnomTEC_Assistant")
	
end

-- function called on disable of addon
function GnomTEC_Assistant:OnDisable()
	-- Called when the addon is disabled
	GnomTEC_Assistant:UnregisterAllEvents();

	self.db.profile.minimap.hide = true
	icon:Hide("GnomTEC_Assistant")
    
end

-- ----------------------------------------------------------------------
-- External API
-- ----------------------------------------------------------------------
 
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
function GnomTEC:RegisterAddon(addon, addonInfo, revision, callback)
	local addonName = addon:GetName()
	
	addonsList[addonName] = {
		["Addon"] = addonName,
		["AddonInfo"] = addonInfo,
		["Revision"] = revision	
	}
	
	if (callback) then
		addonsList[addonName]["Callback"] = function(sender) callback(sender) end
	else
		addonsList[addonName]["Callback"] = function(sender) end
	end		
	
	if (ldbDataObjs["Addons"]) then
		local count = 0
		for _ in pairs(addonsList) do count = count + 1 end
 		ldbDataObjs["Addons"].value = count
		ldbDataObjs["Addons"].text = ldbDataObjs["Addons"].value.." "..ldbDataObjs["Addons"].suffix
	end
	
	GnomTEC_LogMessage(LOG_INFO, (addonInfo["Name"]).." ("..(addonInfo["Version"]).." / "..(addonInfo["Date"])..") registriert")

	if (GNOMTEC_REVISION < revision) then
		GnomTEC_LogMessage(LOG_WARN, (addonInfo["Name"]).." benötigt aktuellere GnomTEC API")
	end
	
	table.insert(addonsTable,{ {addonInfo["Name"]}, {addonInfo["Version"]}, {addonInfo["Date"]}, {addonInfo["Author"]} })
	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(GnomTEC_Assistant_Window_InnerFrame_Container_InnerFrame_Addons, addonsTable)	

	GnomTEC:UpdateStaticData(GnomTEC_Assistant, addonsList)
	
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
	local addonName = "<nil>"
	local color = {1.0,1.0,1.0}
	
	if (addon) then
		addonName = addon:GetName() or "<???>"
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
		
	GnomTEC_Assistant:AddMessage2Log(addonName..": "..message,unpack(color))
end

--[[
GnomTEC:RegisterEvent(addon, event)
Parameters: addon, data
	addon 		- Ace3 addon object
	eventName 	- event to register for (like Ace3 do it)
		"GNOMTEC_UPDATE_STATICDATA" - static data for addon is updated by sender called f(eventName, sender, addonName, data)
Returns: -
--]]
function GnomTEC:RegisterEvent(addon, eventName)

	if (not addon) then
		GnomTEC_LogMessage(LOG_ERROR,"RegisterEvent() called from unknown addon")
	else
		local addonName = addon:GetName()
		if (not addonName) then
			GnomTEC_LogMessage(LOG_ERROR,"RegisterEvent() called from unknown addon")
		elseif (not addonsList[addonName]) then
			GnomTEC_LogMessage(LOG_ERROR,"RegisterEvent() called from unregistered addon "..addonName)
		else
			GnomTEC.RegisterCallback(addon, eventName)

-- MyLib.UnregisterCallback(self, "eventname")
--MyLib.UnregisterAllCallbacks(self)
		end
	end
end


--[[
GnomTEC:UpdateStaticData()
Parameters: addon, data
	addon 	- Ace3 addon object
	data  	- static data for this addon
Returns: -
--]]
function GnomTEC:UpdateStaticData(addon, data)

	if (not addon) then
		GnomTEC_LogMessage(LOG_ERROR,"UpdateStaticData() called from unknown addon")
	else
		local addonName = addon:GetName()
		if (not addonName) then
			GnomTEC_LogMessage(LOG_ERROR,"UpdateStaticData() called from unknown addon")
		elseif (not addonsList[addonName]) then
			GnomTEC_LogMessage(LOG_ERROR,"UpdateStaticData() called from unregistered addon "..addonName)
		else	
			local sd = GnomTEC_Assistant:GetStaticData(UnitName("player"))
			if (not sd.addons[addonName]) then
				sd.addons[addonName] = {}
			end
			sd.addons[addonName].timestamp = GnomTEC_Assistant:CreateTimestamp()
			sd.addons[addonName].data = data
			sd.timestamp = sd.addons[addonName].timestamp
			GnomTEC.callbacks:Fire("GNOMTEC_UPDATE_STATICDATA", UnitName("player"), addonName, data)
		end
	end
end

--[[
GnomTEC:GetPlayerStaticData()
Parameters: addon, player
	addon 	- Ace3 addon object
	player  	- name of player to get static data for given addon
Returns: data
	data 		- the static data for the player
--]]
function GnomTEC:GetPlayerStaticData(addon, player)
	if (not addon) then
		GnomTEC_LogMessage(LOG_ERROR,"GetPlayerStaticData() called from unknown addon")
	else
		local addonName = addon:GetName()
		if (not addonName) then
			GnomTEC_LogMessage(LOG_ERROR,"GetPlayerStaticData() called from unknown addon")
		elseif (not addonsList[addonName]) then
			GnomTEC_LogMessage(LOG_ERROR,"GetPlayerStaticData() called from unregistered addon "..addonName)
		else	
			local sd = GnomTEC_Assistant:GetStaticData(player)
			if (not sd.addons[addonName]) then
				return nil
			else
				return sd.addons[addonName].data
			end
		end
	end
end

--[[
GnomTEC:IteratorRealms()
Parameters: f
	f - (optional) comparision function for table.dort
Returns: iterator
	iterator - an iteration function over all realms with data 
--]]
function GnomTEC:IteratorRealms(f)
	local a = {}
		for n in pairs(self.db.global.staticData) do table.insert(a, n) end
		table.sort(a,f)
		local i = 0      -- iterator variable
		local iterator = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i]
			end
		end
	return iterator
end

--[[
GnomTEC:IteratorPlayers()
Parameters: realm, f
	realm - realm to iterate for known players
	f 		- (optional) comparision function for table.dort
Returns: iterator
	iterator - an iteration function over all players of a realms with data 
--]]
function GnomTEC:IteratorPlayers(realm, f)
	local a = {}
		if (self.db.global.staticData[realm]) then
			for n in pairs(self.db.global.staticData[realm]) do table.insert(a, n) end
		end
		table.sort(a,f)
		local i = 0      -- iterator variable
		local iterator = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i]
			end
		end
	return iterator
end
