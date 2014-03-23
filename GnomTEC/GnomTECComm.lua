-- **********************************************************************
-- GnomTECComm Class
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECComm-1.0", 1
local class, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not class then return end -- No Upgrade needed.

-- ----------------------------------------------------------------------
-- Class Global Constants (local)
-- ----------------------------------------------------------------------
-- localization (will be loaded from base class later)
local L = {}

-- texture path (will be loaded from base class later)
local T = ""

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

-- communication prefix
local ADDONMESSAGE_PREFIX = "GNOMTEC"

-- settings how often to check for data
local COMM_PROBE_FREQUENCY = 300.0 + math.random(0, 60) -- Wait 5-6 minutes for someone to respond before asking again
local COMM_FIELD_UPDATE_FREQUENCY = 10.0 + math.random(0, 5) -- Fields newer than 10-15 seconds old are still fresh

-- communication commands
local COMM_REQ_TIMESTAMPS		= "?"		-- data = nil
local COMM_RES_TIMESTAMPS		= "!"		-- data = {t_addons, t_data}
local COMM_REQ_ADDONS	 		= "?A"	-- data = {t_addons}
local COMM_RES_ADDONS			= "!A"	-- data = {t_addons, addons[] or nil}
local COMM_REQ_DATA	 			= "?D"	-- data = {t_adddondata, addonName}
local COMM_RES_DATA				= "!D"	-- data = {t_addondata, addonName, data or nil}


-- ----------------------------------------------------------------------
-- Class Static Variables (local)
-- ----------------------------------------------------------------------
-- communication statistic data
local _commSendBytes = 0
local _commReceiveBytes = 0
local _commRequestCount = 0
local _commRequestSendBytes= 0
local _commRequestReceiveBytes= 0
local _commResponseCount = 0
local _commResponseSendBytes = 0
local _commResponseReceiveBytes = 0


--[[
local _commAddons = {
	[<addonName>] = {					-- addon name as in TOC
		["Name"] 	= <name>,		-- addon display name
		["Version"]	= <version>, 	-- addon version
		["Date"] 	= <date>,		-- addon date
		["CompRev"]	= <comprev>,	-- addon compatibility revision
	},
	...
--]]
local _commAddons = {}

-- timestamp of the addon list --> t_addons
local _commAddonsTimestamp = 0


--[[
local _commData = {
	[<addonName>] = {							-- addon name as in TOC
		["Data"] 	= ...,					-- addon data which should be transfered to others
		["Timestamp"]	= t_addondata,	-- timestamp of this data
	},
	...
--]]
local _commData = {}

-- overall timestamp of the data --> t_data
local _commDataTimestamp = 0

--[[
local _commUnitInformations = {
	[<unitName>] = {								-- name of other user in form "<player>-<realm>"
		["supported"]	= <supported>,			-- unit supports GnomTEC API
		["scantime"]	= <scantime>,			-- last time we scanned unit
		["time"]	= <time>,						-- last time we communicate with unit
		["t_addons"] 	= <t_addons>,			-- timestamp of addon list
		["t_data"]		= <t_data>, 			-- overall timestamp of data
		["Addons"] 	= {			
			[<addonName>] = <t_addondata>,	-- addon name as in TOC / timestamp of addon data 
		},
	},
	...
--]]
local _commUnitInformations = {}

local _commLastTimestamp = 0

local _addonsList = {}

local _addonsListReceivers = {}


-- ----------------------------------------------------------------------
-- Class Startup Initialization
-- ----------------------------------------------------------------------
local _aceComm = nil
local _aceEvent = nil
local _aceSerializer = nil

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

-- generic sorted iterator
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

-- ----------------------------------------------------------------------
-- Class Static Methods (local)
-- ----------------------------------------------------------------------
local function _LogMessage(logLevel, message, ...)
end

local function _CommStatisticLogSend(isRequest, count, numBytes, addonName, unitName)
	if isRequest then
		if count then
			_commRequestCount = _commRequestCount + 1
		end
		_commRequestSendBytes = _commRequestSendBytes + numBytes
	else
		if count then
			_commResponseCount = _commResponseCount + 1
		end
		_commResponseSendBytes = _commResponseSendBytes + numBytes
	end
	_commSendBytes = _commSendBytes + numBytes	
end

local function _CommStatisticLogReceive(isRequest, count, numBytes, addonName, unitName)
	if isRequest then
		if count then
			_commRequestCount = _commRequestCount + 1
		end
		_commRequestReceiveBytes = _commRequestReceiveBytes + numBytes		
	else
		if count then
			_commResponseCount = _commResponseCount + 1
		end
		_commResponseReceiveBytes = _commResponseReceiveBytes + numBytes
	end
	_commReceiveBytes = _commReceiveBytes + numBytes
end

local function _CommGetUnitInfo(target)
	local unitInfo = _commUnitInformations[target]
	
	if (not unitInfo) then
		_commUnitInformations[target] = {}
		unitInfo = _commUnitInformations[target]
		unitInfo.supported = false
		unitInfo.scantime = 0
		unitInfo.time = 0
		unitInfo.ts_addons = 0
		unitInfo.ts_data = 0
		unitInfo.Addons = {}	
	end

	return unitInfo
end

local function _CommCreateTimestamp()
	local timestamp = time() * 100
	
	if (timestamp <= _commLastTimestamp) then
		timestamp = _commLastTimestamp + 1
	end

	_commLastTimestamp = timestamp

	return timestamp
end

local function _CommUpdateAddonInfo(addonName, name, version, date, compRev)
	_commAddons[addonName] = {
		["Name"] 	= name,
		["Version"]	= version,
		["Date"] 	= date,
		["CompRev"]	= comRev,
	}
	
	_commAddonsTimestamp = _CommCreateTimestamp()
end

local function _CommSend(addonName, target, comm, ...)
	local now = GetTime()
	local unitInfo = _CommGetUnitInfo(target)

	if (unitInfo.supported == false) and ( now < unitInfo.scantime + COMM_PROBE_FREQUENCY ) then
		return
	elseif not unitInfo.supported then
		unitInfo.scantime = now
	end

_LogMessage(LOG_DEBUG, "Sending %s to %s", comm, target)

	local serialized = _aceSerializer:Serialize(comm, ...)
	local bytes = string.len(serialized)

	if (string.sub(comm,1,1) == '?') then
		_CommStatisticLogSend(true, true, bytes, addonName, target)
	else
		_CommStatisticLogSend(false, false, bytes, addonName, target)
	end
	_aceComm:SendCommMessage(ADDONMESSAGE_PREFIX, serialized, "WHISPER", target, "BULK")	
end

local function _CommRequestTimestamps(target, force)
	local now = GetTime()
	local unitInfo = _CommGetUnitInfo(target)

	if (unitInfo.time + COMM_FIELD_UPDATE_FREQUENCY < now) or force then
		unitInfo.time = now
		_CommSend("GnomTEC", target, COMM_REQ_TIMESTAMPS, nil)
	end
end

local function _CommResponseTimestamps(target)
	_CommSend("GnomTEC", target, COMM_RES_TIMESTAMPS, _commAddonsTimestamp, _commDataTimestamp)
end

local function _CommRequestAddons(target)
	local unitInfo = _CommGetUnitInfo(target)

	_CommSend("GnomTEC", target, COMM_REQ_ADDONS, unitInfo.ts_addons)
end

local function _CommResponseAddons(target)
	local count = 0
	if _commAddons then
		for key, value in pairs(_commAddons) do
			count = count + 1
		end
	end

	_CommSend("GnomTEC", target, COMM_RES_ADDONS, _commAddonsTimestamp, _commAddons)
end

local function _CommRequestData(target, addonName)
	local unitInfo = _CommGetUnitInfo(target)
	
	if (unitInfo.Addons[addonName]) then
		_CommSend(addonName, target, COMM_REQ_DATA, unitInfo.Addons[addonName], addonName)
	end
end

local function _CommResponseData(target, addonName)
	
	if (_commData[addonName]) then
		_CommSend(addonName, target, COMM_RES_DATA, _commData[addonName]["Timestamp"], _commData[addonName]["Data"])
	end	
end

-- ----------------------------------------------------------------------
-- Class Static Event Handler (local)
-- ----------------------------------------------------------------------
local function _OnCommReceived(prefix, message, distribution, sender)
	if (prefix == ADDONMESSAGE_PREFIX) then
		sender = fullunitname(sender)
		local unitInfo = _CommGetUnitInfo(sender)
		unitInfo.supported = true
		unitInfo.scantime = 0

		local bytes = string.len(message)
		local messageParts = {_aceSerializer:Deserialize(message)}
		if (not messageParts[1]) then
			_LogMessage(LOG_ERROR,"Could not deserialize communication message: %s from ",(messageParts[2] or "???"), sender)
		else
			local comm = messageParts[2]

_LogMessage(LOG_DEBUG, "Receiving %s from %s", comm, sender)

			if (COMM_REQ_TIMESTAMPS == comm) then
				_CommStatisticLogReceive(false, true, bytes, "GnomTEC", sender)
				_CommResponseTimestamps(sender)
			elseif (COMM_RES_TIMESTAMPS == comm) then
				_CommStatisticLogReceive(true, false, bytes, "GnomTEC", sender)
				local ts_addons = messageParts[3]
				local ts_data = messageParts[4]
				
				if (not ts_addons) then
					_LogMessage(LOG_ERROR,"Comm respones: %s: no timestamp received".." from %s", COMM_RES_TIMESTAMPS, sender)
				elseif (ts_addons ~= unitInfo.ts_addons) then
					_CommRequestAddons(sender)
				elseif (ts_data ~= unitInfo.ts_data) then
					unitInfo.ts_data = ts_data
					-- request updates of data for all addons of other user
					for key, value in pairs(unitInfo["Addons"]) do
			 			_CommRequestData(sender, key)
					end
				end
			elseif (COMM_REQ_ADDONS == comm) then
				_CommStatisticLogReceive(false, true, bytes, "GnomTEC", sender)
				local ts_addons = messageParts[3]

				if (not ts_addons) then
					_LogMessage(LOG_ERROR,"Comm respones: %s: no timestamp received".." from %s", COMM_REQ_ADDONS, sender)
				elseif _commAddonsTimestamp ~= ts_addons then
					_CommResponseAddons(sender)
				end
			elseif (COMM_RES_ADDONS == comm) then
				_CommStatisticLogReceive(true, false, bytes, "GnomTEC", sender)
				local ts_addons = messageParts[3]
				local addons = messageParts[4]
				
				if (not ts_addons) then
					_LogMessage(LOG_ERROR,"Comm respones: %s: no timestamp received".." from %s", COMM_RES_ADDONS, sender)
				elseif addons then
					unitInfo.ts_addons = ts_addons
					for key, value in pairs(addons) do
						if (not unitInfo.Addons[key]) then
							unitInfo.Addons[key] = 0
						end
						
						if (_addonsList[key]) then
							local version = value["Version"] 
 							local _,_,_,revision = strsplit( ".", version, 4 )
 							local myVersion = _addonsList[key]["AddonInfo"]["Version"]
 	
	 						if (myVersion) then
 								local _,_,_,myRevision = strsplit( ".", myVersion, 4 )
 					
			 					if (tonumber(myRevision) < tonumber(revision)) then
 									if (not _addonsList[key]["AvailableVersion"]) then
 										_addonsList[key]["AvailableVersion"] = version
 									else
						 				local availableVersion = _addonsList[key]["AvailableVersion"]
 										local _,_,_,availableRevision = strsplit( ".", availableVersion, 4 )	

						 				if (tonumber(availableRevision) < tonumber(myRevision)) then
		 									_addonsList[key]["AvailableVersion"] = version
			 							end
									end
								end
							end
						end
					end
					for idx, value in ipairs(_addonsListReceivers) do
						value.func(self.pairsCommAddonsList)
					end
					_CommRequestTimestamps(sender, true)
				end
			elseif (COMM_REQ_DATA == comm) then
--[[
				_commResponseCount = _commResponseCount + 1
				_commResponseBytes = _commResponseBytes + bytes
				local addonName = messageParts[3]
				local timestamp = messageParts[4]
				local sdp = _GetStaticData(UnitName("player"))
				
				if (sdp.addons[addonName]) then
					if (sdp.addons[addonName].timestamp ~= timestamp) then
						_CommResponseStaticDataDataPart(sender, addonName, sdp.addons[addonName].timestamp, sdp.addons[addonName].data)
					end
				end
--]]
			elseif (COMM_RES_DATA == comm) then
--[[
				_commRequestBytes = _commRequestBytes + bytes
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
				_LogMessage(LOG_WARN,"Unknown communication request or response: %s from %s", (comm or "???"), sender)
			end
		end		
	end
end

local function _UPDATE_MOUSEOVER_UNIT(eventName)
	if (not UnitIsUnit("mouseover", "player")) then
		if (Fixed_UnitIsPlayer(unitId)) then
			local unitName = fullunitname(UnitName("mouseover"))
			-- Trigger data exchange with unit
			_CommRequestTimestamps(unitName)
	 	end
 	end
 end
 
 function _CHAT_MSG_BATTLEGROUND(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_CHANNEL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_CHANNEL_JOIN(eventName, arg1, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_GUILD(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_OFFICER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_PARTY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_RAID(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_SAY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_TEXT_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_WHISPER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

function _CHAT_MSG_YELL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_CommRequestTimestamps(sender)
	end
end

-- ----------------------------------------------------------------------
-- Class
-- ----------------------------------------------------------------------
--[[
	addonInfo - table with addon informations as string
		["Name"] 		- name
		["Version"] 	- version
		["Date"] = 		- date
		["Author"] 		- author
		["Email"] 		- contact email
		["Website"] 	- URL to addon website
		["Copyright"] 	- copyright information
--]]
function GnomTECComm(addonTitle, addonInfo, frameworkRevision)
	-- call base class
	local self, protected = GnomTEC()
		
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
		
	-- private methods
	-- local function f()

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_CLASS, logLevel, "GnomTECComm", message, ...)
	end
	
	function self.CommGetStatistics()
		local statistics = {
			commSendBytes = _commSendBytes,
			commReceiveBytes = _commReceiveBytes,
			commRequestCount = _commRequestCount,
			commRequestSendBytes= _commRequestSendBytes,
			commRequestReceiveBytes= _commRequestReceiveBytes,
			commResponseCount = _commResponseCount,
			commResponseSendBytes = _commResponseSendBytes,
			commResponseReceiveBytes = _commResponseReceiveBytes,
		}
		return statistics
	end
	
	function self.pairsCommAddonsList()
		return pairsByKeys(_addonsList)
	end

	function self.RegisterAddonsListReceiver(addonsListReceiver)
		if type(addonsListReceiver) == "function" then
			self.UnregisterAddonsListReceiver(addonsListReceiver)
			table.insert(_addonsListReceivers, {func=addonsListReceiver})
			addonsListReceiver(self.pairsCommAddonsList)
		end

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "AddonsList receiver registered")
	end

	function self.UnregisterAddonsListReceiver(addonsListReceiver)
		if type(logReceiver) == "function" then
			local pos = 0
			for idx, value in ipairs(_addonsListReceivers) do
				if (value.func == addonsListReceiver) then
					pos = idx
					break
				end
			end
			if (pos > 0) then
				table.remove(_addonsListReceivers, pos)
				protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "AddonsList receiver unregistered")
			end
		end
	end

	-- constructor
	do
		-- get localization first.
		L = protected.GetLocale()

		-- get texture path
		T = protected.GetTexturePath()	

		if (not _aceComm) then
			_aceComm = LibStub("AceComm-3.0")
			_aceEvent = LibStub("AceEvent-3.0")
			_aceSerializer = LibStub("AceSerializer-3.0")

			_LogMessage = self.LogMessage

			if (not RegisterAddonMessagePrefix(ADDONMESSAGE_PREFIX)) then
				_LogMessage(LOG_FAIL,"RegisterAddonMessagePrefix(%s) failed", ADDONMESSAGE_PREFIX)
			else
				_aceComm:RegisterComm(ADDONMESSAGE_PREFIX, _OnCommReceived)
			end

			_aceEvent:RegisterEvent("UPDATE_MOUSEOVER_UNIT", _UPDATE_MOUSEOVER_UNIT)
			_aceEvent:RegisterEvent("CHAT_MSG_BATTLEGROUND", _CHAT_MSG_BATTLEGROUND);
			_aceEvent:RegisterEvent("CHAT_MSG_CHANNEL", _CHAT_MSG_CHANNEL);
			_aceEvent:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", _CHAT_MSG_CHANNEL_JOIN);
			_aceEvent:RegisterEvent("CHAT_MSG_EMOTE", _CHAT_MSG_EMOTE);
			_aceEvent:RegisterEvent("CHAT_MSG_GUILD", _CHAT_MSG_GUILD);
			_aceEvent:RegisterEvent("CHAT_MSG_OFFICER", _CHAT_MSG_OFFICER);
			_aceEvent:RegisterEvent("CHAT_MSG_PARTY", _CHAT_MSG_PARTY);
			_aceEvent:RegisterEvent("CHAT_MSG_RAID", _CHAT_MSG_RAID);
			_aceEvent:RegisterEvent("CHAT_MSG_SAY", _CHAT_MSG_SAY);
			_aceEvent:RegisterEvent("CHAT_MSG_TEXT_EMOTE", _CHAT_MSG_TEXT_EMOTE);
			_aceEvent:RegisterEvent("CHAT_MSG_WHISPER", _CHAT_MSG_WHISPER);
			_aceEvent:RegisterEvent("CHAT_MSG_YELL", _CHAT_MSG_YELL);

		end
	
		_addonsList[addonTitle] = {
			["Addon"] = addonTitle,
			["AddonInfo"] = addonInfo,
			["Revision"] = frameworkRevision	
		}		
		for idx, value in ipairs(_addonsListReceivers) do
			value.func(self.pairsCommAddonsList)
		end

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self, protected
end


