-- **********************************************************************
-- GnomTEC Assistant - Communication Module
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
-- communication prefix
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
-- Modul Global Variables
-- ----------------------------------------------------------------------
-- communication statistic data
GnomTEC_Assistant.commResponseCount = 0
GnomTEC_Assistant.commResponseBytes = 0
GnomTEC_Assistant.commRequestCount = 0
GnomTEC_Assistant.commRequestBytes= 0


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
		GnomTEC_Assistant.commRequestCount = GnomTEC_Assistant.commRequestCount + 1
		GnomTEC_Assistant.commRequestBytes = GnomTEC_Assistant.commRequestBytes + bytes
	elseif (comm == COMM_RES_STATICDATA_TIMESTAMP) then
		GnomTEC_Assistant.commResponseBytes = GnomTEC_Assistant.commResponseBytes + bytes
	elseif (comm == COMM_REQ_STATICDATA_DATAPART) then
		GnomTEC_Assistant.commRequestCount = GnomTEC_Assistant.commRequestCount + 1
		GnomTEC_Assistant.commRequestBytes = GnomTEC_Assistant.commRequestBytes + bytes
	elseif (comm == COMM_RES_STATICDATA_DATAPART) then
		GnomTEC_Assistant.commResponseBytes = GnomTEC_Assistant.commResponseBytes + bytes
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
				GnomTEC_Assistant.commResponseCount = GnomTEC_Assistant.commResponseCount + 1
				GnomTEC_Assistant.GnomTEC_Assistant.commResponseBytes = GnomTEC_Assistant.commResponseBytes + bytes
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
				GnomTEC_Assistant.commResponseCount = GnomTEC_Assistant.commResponseCount + 1
				GnomTEC_Assistant.commResponseBytes = GnomTEC_Assistant.commResponseBytes + bytes
				local addonName = messageParts[3]
				local timestamp = messageParts[4]
				local sdp = GnomTEC_Assistant:GetStaticData(UnitName("player"))
				
				if (sdp.addons[addonName]) then
					if (sdp.addons[addonName].timestamp ~= timestamp) then
						GnomTEC_Assistant:CommResponseStaticDataDataPart(sender, addonName, sdp.addons[addonName].timestamp, sdp.addons[addonName].data)
					end
				end
			elseif (COMM_RES_STATICDATA_DATAPART == comm) then
				GnomTEC_Assistant.commRequestBytes = GnomTEC_Assistant.commRequestBytes + bytes
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

-- ----------------------------------------------------------------------
-- Module Initialize, Enable and Disable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_Assistant:ModuleCommInitialize()
end

-- function called on enable of addon
function GnomTEC_Assistant:ModuleCommEnable()
	RegisterAddonMessagePrefix(ADDONMESSAGE_PREFIX);
end

-- function called on disable of addon
function GnomTEC_Assistant:ModuleCommDisable()
end
