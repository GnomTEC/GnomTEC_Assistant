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
local COMM_REQ_TIMESTAMPS		= "?"		-- data = nil
local COMM_RES_TIMESTAMPS		= "!"		-- data = {ts_addons, ts_data}
local COMM_REQ_ADDONS	 		= "?A"	-- data = {ts_addons}
local COMM_RES_ADDONS			= "!A"	-- data = {ts_addons, addons[] or nil}
local COMM_REQ_DATA	 			= "?D"	-- data = {ts_adddondata, addonName}
local COMM_RES_DATA				= "!D"	-- data = {ts_addondata, addonName, data or nil}

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

-- ----------------------------------------------------------------------
-- Modul Global Variables
-- ----------------------------------------------------------------------
-- communication statistic data
GnomTEC_Assistant.commSendBytes = 0
GnomTEC_Assistant.commReceiveBytes = 0
GnomTEC_Assistant.commRequestCount = 0
GnomTEC_Assistant.commRequestSendBytes= 0
GnomTEC_Assistant.commRequestReceiveBytes= 0
GnomTEC_Assistant.commResponseCount = 0
GnomTEC_Assistant.commResponseSendBytes = 0
GnomTEC_Assistant.commResponseReceiveBytes = 0


--[[
GnomTEC_Assistant.commAddons = {
	[<addonName>] = {					-- addon name as in TOC
		["Name"] 	= <name>,		-- addon display name
		["Version"]	= <version>, 	-- addon version
		["Date"] 	= <date>,		-- addon date
		["CompRev"]	= <comprev>,	-- addon compatibility revision
	},
	...
--]]
GnomTEC_Assistant.commAddons = {}

-- timestamp of the addon list --> ts_addons
GnomTEC_Assistant.commAddonsTimestamp = 0


--[[
GnomTEC_Assistant.commData = {
	[<addonName>] = {							-- addon name as in TOC
		["Data"] 	= ...,					-- addon data which should be transfered to others
		["Timestamp"]	= ts_addondata,	-- timestamp of this data
	},
	...
--]]
GnomTEC_Assistant.commData = {}

-- overall timestamp of the data --> ts_data
GnomTEC_Assistant.commDataTimestamp = 0

--[[
GnomTEC_Assistant.commUnitInformations = {
	[<unitName>] = {								-- name of other user in form "<player>-<realm>"
		["supported"]	= <supported>,			-- unit supports GnomTEC API
		["scantime"]	= <scantime>,			-- last time we scanned unit
		["time"]	= <time>,						-- last time we communicate with unit
		["ts_addons"] 	= <ts_addons>,			-- timestamp of addon list
		["ts_data"]		= <ts_data>, 			-- overall timestamp of data
		["Addons"] 	= {			
			[<addonName>] = <ts_addondata>,	-- addon name as in TOC / timestamp of addon data 
		},
	},
	...
--]]
GnomTEC_Assistant.commUnitInformations = {}


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
function GnomTEC_Assistant:CommStatisticLogSend(isRequest, count, numBytes, addonName, unitName)
	if isRequest then
		if count then
			GnomTEC_Assistant.commRequestCount = GnomTEC_Assistant.commRequestCount + 1
		end
		GnomTEC_Assistant.commRequestSendBytes = GnomTEC_Assistant.commRequestSendBytes + numBytes
	else
		if count then
			GnomTEC_Assistant.commResponseCount = GnomTEC_Assistant.commResponseCount + 1
		end
		GnomTEC_Assistant.commResponseSendBytes = GnomTEC_Assistant.commResponseSendBytes + numBytes
	end
	GnomTEC_Assistant.commSendBytes = GnomTEC_Assistant.commSendBytes + numBytes	
end

function GnomTEC_Assistant:CommStatisticLogReceive(isRequest, count, numBytes, addonName, unitName)
	if isRequest then
		if count then
			GnomTEC_Assistant.commRequestCount = GnomTEC_Assistant.commRequestCount + 1
		end
		GnomTEC_Assistant.commRequestReceiveBytes = GnomTEC_Assistant.commRequestReceiveBytes + numBytes		
	else
		if count then
			GnomTEC_Assistant.commResponseCount = GnomTEC_Assistant.commResponseCount + 1
		end
		GnomTEC_Assistant.commResponseReceiveBytes = GnomTEC_Assistant.commResponseReceiveBytes + numBytes
	end
	GnomTEC_Assistant.commReceiveBytes = GnomTEC_Assistant.commReceiveBytes + numBytes
end

function GnomTEC_Assistant:CommGetUnitInfo(target)
	local unitInfo = GnomTEC_Assistant.commUnitInformations[target]
	
	if (not unitInfo) then
		GnomTEC_Assistant.commUnitInformations[target] = {}
		unitInfo = GnomTEC_Assistant.commUnitInformations[target]
		unitInfo.supported = false
		unitInfo.scantime = 0
		unitInfo.time = 0
		unitInfo.ts_addons = 0
		unitInfo.ts_data = 0
		unitInfo.Addons = {}	
	end

	return unitInfo
end

function GnomTEC_Assistant:CommCreateTimestamp()
	local timestamp = time()
	
	if (timestamp <= self.db.global.commLastTimestamp) then
		timestamp = self.db.global.commLastTimestamp + 1
	end

	self.db.global.commLastTimestamp = timestamp

	return timestamp
end

function GnomTEC_Assistant:CommUpdateAddonInfo(addonName, name, version, date, compRev)
	GnomTEC_Assistant.commAddons[addonName] = {
		["Name"] 	= name,
		["Version"]	= version,
		["Date"] 	= date,
		["CompRev"]	= comRev,
	}
	
	GnomTEC_Assistant.commAddonsTimestamp = GnomTEC_Assistant:CommCreateTimestamp()
end

function GnomTEC_Assistant:CommSend(addonName, target, comm, ...)
	local now = GetTime()
	local unitInfo = GnomTEC_Assistant:CommGetUnitInfo(target)

	if (unitInfo.supported == false) and ( now < unitInfo.scantime + COMM_PROBE_FREQUENCY ) then
		return
	elseif not unitInfo.supported then
		unitInfo.scantime = now
	end

	local serialized = GnomTEC_Assistant:Serialize(comm, ...)
	local bytes = string.len(serialized)

	if (string.sub(comm,1,1) == '?') then
		GnomTEC_Assistant:CommStatisticLogSend(true, true, bytes, addonName, target)
	else
		GnomTEC_Assistant:CommStatisticLogSend(false, false, bytes, addonName, target)
	end
	GnomTEC_Assistant:SendCommMessage(ADDONMESSAGE_PREFIX, serialized, "WHISPER", target, "BULK")	
end

function GnomTEC_Assistant:CommRequestTimestamps(target, force)
	local now = GetTime()
	local unitInfo = GnomTEC_Assistant:CommGetUnitInfo(target)

	if (unitInfo.time + COMM_FIELD_UPDATE_FREQUENCY < now) or force then
		unitInfo.time = now
		GnomTEC_Assistant:CommSend("GnomTEC_Assistant", target, COMM_REQ_TIMESTAMPS, nil)
	end
end

function GnomTEC_Assistant:CommResponseTimestamps(target)
	GnomTEC_Assistant:CommSend("GnomTEC_Assistant", target, COMM_RES_TIMESTAMPS, GnomTEC_Assistant.commAddonsTimestamp, GnomTEC_Assistant.commDataTimestamp)
end

function GnomTEC_Assistant:CommRequestAddons(target)
	local unitInfo = GnomTEC_Assistant:CommGetUnitInfo(target)

	GnomTEC_Assistant:CommSend("GnomTEC_Assistant", target, COMM_REQ_ADDONS, unitInfo.ts_addons)
end

function GnomTEC_Assistant:CommResponseAddons(target)
	local count = 0
	if GnomTEC_Assistant.commAddons then
		for key, value in pairs(GnomTEC_Assistant.commAddons) do
			count = count + 1
		end
	end

	GnomTEC_Assistant:CommSend("GnomTEC_Assistant", target, COMM_RES_ADDONS, GnomTEC_Assistant.commAddonsTimestamp, GnomTEC_Assistant.commAddons)
end

function GnomTEC_Assistant:CommRequestData(target, addonName)
	local unitInfo = GnomTEC_Assistant:CommGetUnitInfo(target)
	
	if (unitInfo.Addons[addonName]) then
		GnomTEC_Assistant:CommSend(addonName, target, COMM_REQ_DATA, unitInfo.Addons[addonName], addonName)
	end
end

function GnomTEC_Assistant:CommResponseData(target, addonName)
	
	if (GnomTEC_Assistant.commData[addonName]) then
		GnomTEC_Assistant:CommSend(addonName, target, COMM_RES_DATA, GnomTEC_Assistant.commData[addonName]["Timestamp"], GnomTEC_Assistant.commData[addonName]["Data"])
	end	
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
		sender = fullunitname(sender)
		local unitInfo = GnomTEC_Assistant:CommGetUnitInfo(sender)
		unitInfo.supported = true
		unitInfo.scantime = 0

		local bytes = string.len(message)
		local messageParts = {GnomTEC_Assistant:Deserialize(message)}
		if (not messageParts[1]) then
			GnomTEC_LogMessage(LOG_ERROR,"Could not deserialize communication message: "..(messageParts[2] or "???").." from ".. sender)
		else
			local comm = messageParts[2]

			if (COMM_REQ_TIMESTAMPS == comm) then
				GnomTEC_Assistant:CommStatisticLogReceive(false, true, bytes, "GnomTEC_Assistant", sender)
				GnomTEC_Assistant:CommResponseTimestamps(sender)
			elseif (COMM_RES_TIMESTAMPS == comm) then
				GnomTEC_Assistant:CommStatisticLogReceive(true, false, bytes, "GnomTEC_Assistant", sender)
				local ts_addons = messageParts[3]
				local ts_data = messageParts[4]
				
				if (not ts_addons) then
					GnomTEC_LogMessage(LOG_ERROR,"Comm respones: "..COMM_RES_TIMESTAMPS..": no timestamp received".." from ".. sender)
				elseif (ts_addons ~= unitInfo.ts_addons) then
					GnomTEC_Assistant:CommRequestAddons(sender)
				elseif (ts_data ~= unitInfo.ts_data) then
					unitInfo.ts_data = ts_data
					-- request updates of data for all addons of other user
					for key, value in pairs(unitInfo["Addons"]) do
			 			GnomTEC_Assistant:CommRequestData(sender, key)
					end
				end
			elseif (COMM_REQ_ADDONS == comm) then
				GnomTEC_Assistant:CommStatisticLogReceive(false, true, bytes, "GnomTEC_Assistant", sender)
				local ts_addons = messageParts[3]

				if (not ts_addons) then
					GnomTEC_LogMessage(LOG_ERROR,"Comm respones: "..COMM_REQ_ADDONS..": no timestamp received".." from ".. sender)
				elseif GnomTEC_Assistant.commAddonsTimestamp ~= ts_addons then
					GnomTEC_Assistant:CommResponseAddons(sender)
				end
			elseif (COMM_RES_ADDONS == comm) then
				GnomTEC_Assistant:CommStatisticLogReceive(true, false, bytes, "GnomTEC_Assistant", sender)
				local ts_addons = messageParts[3]
				local addons = messageParts[4]
				
				if (not ts_addons) then
					GnomTEC_LogMessage(LOG_ERROR,"Comm respones: "..COMM_RES_ADDONS..": no timestamp received".." from ".. sender)
				elseif addons then
					unitInfo.ts_addons = ts_addons
					for key, value in pairs(addons) do
						if (not unitInfo.Addons[key]) then
							unitInfo.Addons[key] = 0
						end
						
						if (GnomTEC_Assistant.addonsList[key]) then
							local version = value["Version"] 
 							local _,_,_,revision = strsplit( ".", version, 4 )
 							local myVersion = GnomTEC_Assistant.addonsList[key]["AddonInfo"]["Version"]
 	
	 						if (myVersion) then
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
					GnomTEC_Assistant:UpdateAddonsTable()
					-- request timestamps again to check for changed data
					GnomTEC_Assistant:CommRequestTimestamps(sender, true)
				end
			elseif (COMM_REQ_DATA == comm) then
--[[
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
--]]
			elseif (COMM_RES_DATA == comm) then
--[[
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
--]]
			else
				GnomTEC_LogMessage(LOG_WARN,"Unknown communication request or response: "..(comm or "???").." from ".. sender)
			end
		end		
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
	if (not RegisterAddonMessagePrefix(ADDONMESSAGE_PREFIX)) then
		GnomTEC_LogMessage(LOG_FAIL,"RegisterAddonMessagePrefix("..ADDONMESSAGE_PREFIX..") failed")
	else
		GnomTEC_Assistant:RegisterComm(ADDONMESSAGE_PREFIX)
	end
end

-- function called on disable of addon
function GnomTEC_Assistant:ModuleCommDisable()
end
