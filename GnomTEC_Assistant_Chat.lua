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


-- ----------------------------------------------------------------------
-- Modul Global Variables
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Modul Startup Initialization
-- ----------------------------------------------------------------------

  
-- ----------------------------------------------------------------------
-- Local stubs for the GnomTEC API
-- ----------------------------------------------------------------------

local function GnomTEC_LogMessage(level, message)
	GnomTEC:LogMessage(GnomTEC_Assistant, level, message)
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
