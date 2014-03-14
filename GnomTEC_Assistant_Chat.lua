-- **********************************************************************
-- GnomTEC Assistant - Chat Module
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
-- Modul Startup Initialization
-- ----------------------------------------------------------------------

  
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
function GnomTEC_Assistant:CHAT_MSG_BATTLEGROUND(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_CHANNEL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_CHANNEL_JOIN(eventName, arg1, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_GUILD(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_OFFICER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_PARTY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_RAID(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_SAY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_TEXT_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_WHISPER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end

function GnomTEC_Assistant:CHAT_MSG_YELL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		GnomTEC_Assistant:CommRequestTimestamps(sender)
	end
end


-- ----------------------------------------------------------------------
-- Module Initialize, Enable and Disable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_Assistant:ModuleChatInitialize()
end

-- function called on enable of addon
function GnomTEC_Assistant:ModuleChatEnable()

	-- initialize hooks and events
	GnomTEC_Assistant:RegisterChatCommand("gnomtec", "ChatCommand_gnomtec")
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
end

-- function called on disable of addon
function GnomTEC_Assistant:ModuleChatDisable()
end
