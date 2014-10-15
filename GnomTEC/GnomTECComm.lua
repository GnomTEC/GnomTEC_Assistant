-- **********************************************************************
-- GnomTECComm Class
-- Version: 6.0.2.1
-- Author: Peter Jack
-- URL: http://www.gnomtec.de/
-- **********************************************************************
-- Copyright © 2014 by Peter Jack
--
-- Licensed under the EUPL, Version 1.1 only (the "Licence");
-- You may not use this work except in compliance with the Licence.
-- You may obtain a copy of the Licence at:
--
-- http://ec.europa.eu/idabc/eupl5
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the Licence is distributed on an "AS IS" basis,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the Licence for the specific language governing permissions and
-- limitations under the Licence.
-- **********************************************************************
local MAJOR, MINOR = "GnomTECComm-1.0", 1
local class, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not class then return end -- No Upgrade needed.

-- ----------------------------------------------------------------------
-- Class Global Constants (local)
-- ----------------------------------------------------------------------
-- localization
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC")

-- texure path
local T = [[Interface\Addons\]].. ... ..[[\GnomTEC\Textures\]]

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
local COMM_REQ_DATA	 			= "?D"	-- data = {t_adddondata, addonTitle}
local COMM_RES_DATA				= "!D"	-- data = {t_addondata, addonTitle, data or nil}


-- ----------------------------------------------------------------------
-- Class Static Variables
-- ----------------------------------------------------------------------
-- communication statistic data
class.commSendBytes = class.commSendBytes or 0
class.commReceiveBytes = class.commReceiveBytes or 0
class.commRequestCount = class.commRequestCount or 0
class.commRequestSendBytes = class.commRequestSendBytes or 0
class.commRequestReceiveBytes=  class.commRequestReceiveBytes or 0
class.commResponseCount = class.commResponseCount or 0
class.commResponseSendBytes = class.commResponseSendBytes or 0
class.commResponseReceiveBytes = class.commResponseReceiveBytes or 0


--[[
class.commAddons = {
	[<addonTitle>] = {				-- addon title as in TOC
		["Name"] 	= <name>,		-- addon display name
		["Version"]	= <version>, 	-- addon version
		["Date"] 	= <date>,		-- addon date
	},
	...
--]]
class.commAddons = class.commAddons or {}

-- timestamp of the addon list --> t_addons
class.commAddonsTimestamp = class.commAddonsTimestamp or 0


--[[
class.commData = {
	[<addonTitle>] = {					-- addon title as in TOC
		["Data"] 	= ...,				-- addon data which should be transfered to others
		["Timestamp"]	= t_addondata,	-- timestamp of this data
	},
	...
--]]
class.commData = class.commData or {}

-- overall timestamp of the data --> t_data
class.commDataTimestamp = class.commDataTimestamp or 0

--[[
class.commUnitInformations = {
	[<unitName>] = {								-- name of other user in form "<player>-<realm>"
		["supported"]	= <supported>,			-- unit supports GnomTEC API
		["scantime"]	= <scantime>,			-- last time we scanned unit
		["time"]	= <time>,						-- last time we communicate with unit
		["t_addons"] 	= <t_addons>,			-- timestamp of addon list
		["t_data"]		= <t_data>, 			-- overall timestamp of data
		["Addons"] 	= {			
			[<addonTitle>] = <t_addondata>,	-- addon title as in TOC / timestamp of addon data 
		},
	},
	...
--]]
class.commUnitInformations = class.commUnitInformations or {}
class.commLastTimestamp = class.commLastTimestamp or 0
class.addonsList = class.addonsList or {}
class.addonsListReceivers = class.addonsListReceivers or {}

-- ----------------------------------------------------------------------
-- Class Startup Initialization
-- ----------------------------------------------------------------------
class.aceComm = class.aceComm or LibStub("AceComm-3.0")
class.aceEvent = class.aceEvent or LibStub("AceEvent-3.0")
class.aceSerializer = class.aceSerializer or LibStub("AceSerializer-3.0")

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

-- returns iterator for addonsList
local	function _pairsCommAddonsList()
	return pairsByKeys(class.addonsList)
end
-- ----------------------------------------------------------------------
-- Class Static Methods (local)
-- ----------------------------------------------------------------------
local function _LogMessage(logLevel, message, ...)
end

local function _commStatisticLogSend(isRequest, count, numBytes, addonTitle, unitName)
	if isRequest then
		if count then
			class.commRequestCount = class.commRequestCount + 1
		end
		class.commRequestSendBytes = class.commRequestSendBytes + numBytes
	else
		if count then
			class.commResponseCount = class.commResponseCount + 1
		end
		class.commResponseSendBytes = class.commResponseSendBytes + numBytes
	end
	class.commSendBytes = class.commSendBytes + numBytes	
end

local function _commStatisticLogReceive(isRequest, count, numBytes, addonTitle, unitName)
	if isRequest then
		if count then
			class.commRequestCount = class.commRequestCount + 1
		end
		class.commRequestReceiveBytes = class.commRequestReceiveBytes + numBytes		
	else
		if count then
			class.commResponseCount = class.commResponseCount + 1
		end
		class.commResponseReceiveBytes = class.commResponseReceiveBytes + numBytes
	end
	class.commReceiveBytes = class.commReceiveBytes + numBytes
end

local function _commGetUnitInfo(target)
	local unitInfo = class.commUnitInformations[target]
	
	if (not unitInfo) then
		class.commUnitInformations[target] = {}
		unitInfo = class.commUnitInformations[target]
		unitInfo.supported = false
		unitInfo.scantime = 0
		unitInfo.time = 0
		unitInfo.ts_addons = 0
		unitInfo.ts_data = 0
		unitInfo.Addons = {}	
	end

	return unitInfo
end

local function _commCreateTimestamp()
	local timestamp = time() * 100
	
	if (timestamp <= class.commLastTimestamp) then
		timestamp = class.commLastTimestamp + 1
	end

	class.commLastTimestamp = timestamp

	return timestamp
end

local function _commUpdateAddonInfo(addonTitle, name, version, date)
	class.commAddons[addonTitle] = {
		["Name"] 	= name,
		["Version"]	= version,
		["Date"] 	= date,
	}
	
	class.commAddonsTimestamp = _commCreateTimestamp()
end

local function _commSend(addonTitle, target, comm, ...)
	local now = GetTime()
	local unitInfo = _commGetUnitInfo(target)

	if (unitInfo.supported == false) and ( now < unitInfo.scantime + COMM_PROBE_FREQUENCY ) then
		return
	elseif not unitInfo.supported then
		unitInfo.scantime = now
	end

_LogMessage(LOG_DEBUG, "Sending %s to %s", comm, target)

	local serialized = class.aceSerializer:Serialize(comm, ...)
	local bytes = string.len(serialized)

	if (string.sub(comm,1,1) == '?') then
		_commStatisticLogSend(true, true, bytes, addonTitle, target)
	else
		_commStatisticLogSend(false, false, bytes, addonTitle, target)
	end
	class.aceComm:SendCommMessage(ADDONMESSAGE_PREFIX, serialized, "WHISPER", target, "BULK")	
end

local function _commRequestTimestamps(target, force)
	local now = GetTime()
	local unitInfo = _commGetUnitInfo(target)

	if (unitInfo.time + COMM_FIELD_UPDATE_FREQUENCY < now) or force then
		unitInfo.time = now
		_commSend("GnomTEC", target, COMM_REQ_TIMESTAMPS, nil)
	end
end

local function _commResponseTimestamps(target)
	_commSend("GnomTEC", target, COMM_RES_TIMESTAMPS, class.commAddonsTimestamp, class.commDataTimestamp)
end

local function _commRequestAddons(target)
	local unitInfo = _commGetUnitInfo(target)

	_commSend("GnomTEC", target, COMM_REQ_ADDONS, unitInfo.ts_addons)
end

local function _commResponseAddons(target)
	_commSend("GnomTEC", target, COMM_RES_ADDONS, class.commAddonsTimestamp, class.commAddons)
end

local function _commRequestData(target, addonTitle)
	local unitInfo = _commGetUnitInfo(target)
	
	if (unitInfo.Addons[addonTitle]) then
		_commSend(addonTitle, target, COMM_REQ_DATA, unitInfo.Addons[addonTitle], addonTitle)
	end
end

local function _commResponseData(target, addonTitle)
	
	if (class.commData[addonTitle]) then
		_commSend(addonTitle, target, COMM_RES_DATA, class.commData[addonTitle]["Timestamp"], class.commData[addonTitle]["Data"])
	end	
end

-- ----------------------------------------------------------------------
-- Class Static Event Handler (local)
-- ----------------------------------------------------------------------
local function _OnCommReceived(prefix, message, distribution, sender)
	if (prefix == ADDONMESSAGE_PREFIX) then
		sender = fullunitname(sender)
		local unitInfo = _commGetUnitInfo(sender)
		unitInfo.supported = true
		unitInfo.scantime = 0

		local bytes = string.len(message)
		local messageParts = {class.aceSerializer:Deserialize(message)}
		if (not messageParts[1]) then
			_LogMessage(LOG_ERROR,"Could not deserialize communication message: %s from ",(messageParts[2] or "???"), sender)
		else
			local comm = messageParts[2]

_LogMessage(LOG_DEBUG, "Receiving %s from %s", comm, sender)

			if (COMM_REQ_TIMESTAMPS == comm) then
				_commStatisticLogReceive(false, true, bytes, "GnomTEC", sender)
				_commResponseTimestamps(sender)
			elseif (COMM_RES_TIMESTAMPS == comm) then
				_commStatisticLogReceive(true, false, bytes, "GnomTEC", sender)
				local ts_addons = messageParts[3]
				local ts_data = messageParts[4]
				
				if (not ts_addons) then
					_LogMessage(LOG_ERROR,"Comm respones: %s: no timestamp received".." from %s", COMM_RES_TIMESTAMPS, sender)
				elseif (ts_addons ~= unitInfo.ts_addons) then
					_commRequestAddons(sender)
				elseif (ts_data ~= unitInfo.ts_data) then
					unitInfo.ts_data = ts_data
					-- request updates of data for all addons of other user
					for key, value in pairs(unitInfo["Addons"]) do
			 			_commRequestData(sender, key)
					end
				end
			elseif (COMM_REQ_ADDONS == comm) then
				_commStatisticLogReceive(false, true, bytes, "GnomTEC", sender)
				local ts_addons = messageParts[3]

				if (not ts_addons) then
					_LogMessage(LOG_ERROR,"Comm respones: %s: no timestamp received".." from %s", COMM_REQ_ADDONS, sender)
				elseif class.commAddonsTimestamp ~= ts_addons then
					_commResponseAddons(sender)
				end
			elseif (COMM_RES_ADDONS == comm) then
				_commStatisticLogReceive(true, false, bytes, "GnomTEC", sender)
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
						
						if (class.addonsList[key]) then
							local version = value["Version"] 
 							local _,_,_,revision = strsplit( ".", version, 4 )
 							local myVersion = class.addonsList[key]["AddonInfo"]["Version"]
 	
	 						if (myVersion) then
 								local _,_,_,myRevision = strsplit( ".", myVersion, 4 )
 					
			 					if (tonumber(myRevision) < tonumber(revision)) then
 									if (not class.addonsList[key]["AvailableVersion"]) then
 										class.addonsList[key]["AvailableVersion"] = version
 									else
						 				local availableVersion = class.addonsList[key]["AvailableVersion"]
 										local _,_,_,availableRevision = strsplit( ".", availableVersion, 4 )	

						 				if (tonumber(availableRevision) < tonumber(myRevision)) then
		 									class.addonsList[key]["AvailableVersion"] = version
			 							end
									end
								end
							end
						end
					end
					for idx, value in ipairs(class.addonsListReceivers) do
						value.func(_pairsCommAddonsList)
					end
					_commRequestTimestamps(sender, true)
				end
			elseif (COMM_REQ_DATA == comm) then
--[[
				class.commResponseCount = class.commResponseCount + 1
				class.commResponseBytes = class.commResponseBytes + bytes
				local addonTitle = messageParts[3]
				local timestamp = messageParts[4]
				local sdp = _GetStaticData(UnitName("player"))
				
				if (sdp.addons[addonTitle]) then
					if (sdp.addons[addonTitle].timestamp ~= timestamp) then
						_commResponseStaticDataDataPart(sender, addonTitle, sdp.addons[addonTitle].timestamp, sdp.addons[addonTitle].data)
					end
				end
--]]
			elseif (COMM_RES_DATA == comm) then
--[[
				class.commRequestBytes = class.commRequestBytes + bytes
				local addonTitle = messageParts[3]
				local timestamp = messageParts[4]
				local data = messageParts[5]
			
				sd.addons[addonTitle].timestamp = timestamp
				sd.addons[addonTitle].data = data
				if (timestamp > sd.timestamp) then
				 	sd.timestamp = timestamp
				end
				GnomTEC.callbacks:Fire("GNOMTEC_UPDATE_STATICDATA", sender, addonTitle, data)
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
			_commRequestTimestamps(unitName)
	 	end
 	end
 end
 
 function _CHAT_MSG_BATTLEGROUND(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_CHANNEL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_CHANNEL_JOIN(eventName, arg1, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_GUILD(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_OFFICER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_PARTY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_RAID(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_SAY(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_TEXT_EMOTE(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_WHISPER(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

function _CHAT_MSG_YELL(eventName, message, sender)	
	-- Trigger data exchange with sender
	sender = fullunitname(sender)
	
	if (emptynil(sender)) then
		_commRequestTimestamps(sender)
	end
end

-- ----------------------------------------------------------------------
-- Register Class Static Event Handler (local)
-- ----------------------------------------------------------------------
if (not RegisterAddonMessagePrefix(ADDONMESSAGE_PREFIX)) then
	-- !!! Probably nobody will receive this LogMessage as login is not set !!!
	_LogMessage(LOG_FAIL,"RegisterAddonMessagePrefix(%s) failed", ADDONMESSAGE_PREFIX)
else
	class.aceComm:RegisterComm(ADDONMESSAGE_PREFIX, _OnCommReceived)
end

class.aceEvent:RegisterEvent("UPDATE_MOUSEOVER_UNIT", _UPDATE_MOUSEOVER_UNIT)
class.aceEvent:RegisterEvent("CHAT_MSG_BATTLEGROUND", _CHAT_MSG_BATTLEGROUND);
class.aceEvent:RegisterEvent("CHAT_MSG_CHANNEL", _CHAT_MSG_CHANNEL);
class.aceEvent:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", _CHAT_MSG_CHANNEL_JOIN);
class.aceEvent:RegisterEvent("CHAT_MSG_EMOTE", _CHAT_MSG_EMOTE);
class.aceEvent:RegisterEvent("CHAT_MSG_GUILD", _CHAT_MSG_GUILD);
class.aceEvent:RegisterEvent("CHAT_MSG_OFFICER", _CHAT_MSG_OFFICER);
class.aceEvent:RegisterEvent("CHAT_MSG_PARTY", _CHAT_MSG_PARTY);
class.aceEvent:RegisterEvent("CHAT_MSG_RAID", _CHAT_MSG_RAID);
class.aceEvent:RegisterEvent("CHAT_MSG_SAY", _CHAT_MSG_SAY);
class.aceEvent:RegisterEvent("CHAT_MSG_TEXT_EMOTE", _CHAT_MSG_TEXT_EMOTE);
class.aceEvent:RegisterEvent("CHAT_MSG_WHISPER", _CHAT_MSG_WHISPER);
class.aceEvent:RegisterEvent("CHAT_MSG_YELL", _CHAT_MSG_YELL);
		
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
		["License"] 	- license information
--]]
function GnomTECComm(addonTitle, addonInfo)
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
			commSendBytes = class.commSendBytes,
			commReceiveBytes = class.commReceiveBytes,
			commRequestCount = class.commRequestCount,
			commRequestSendBytes= class.commRequestSendBytes,
			commRequestReceiveBytes= class.commRequestReceiveBytes,
			commResponseCount = class.commResponseCount,
			commResponseSendBytes = class.commResponseSendBytes,
			commResponseReceiveBytes = class.commResponseReceiveBytes,
		}
		return statistics
	end
	
	function self.pairsCommAddonsList()
		return pairsByKeys(class.addonsList)
	end

	function self.RegisterAddonsListReceiver(addonsListReceiver)
		if type(addonsListReceiver) == "function" then
			self.UnregisterAddonsListReceiver(addonsListReceiver)
			table.insert(class.addonsListReceivers, {func=addonsListReceiver})
			addonsListReceiver(self.pairsCommAddonsList)
		end

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "AddonsList receiver registered")
	end

	function self.UnregisterAddonsListReceiver(addonsListReceiver)
		if type(logReceiver) == "function" then
			local pos = 0
			for idx, value in ipairs(class.addonsListReceivers) do
				if (value.func == addonsListReceiver) then
					pos = idx
					break
				end
			end
			if (pos > 0) then
				table.remove(class.addonsListReceivers, pos)
				protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "AddonsList receiver unregistered")
			end
		end
	end

	-- constructor
	do
		_LogMessage = self.LogMessage

		class.addonsList[addonTitle] = {
			["Addon"] = addonTitle,
			["AddonInfo"] = addonInfo,
		}		
		for idx, value in ipairs(class.addonsListReceivers) do
			value.func(self.pairsCommAddonsList)
		end

		_commUpdateAddonInfo(addonTitle, addonInfo["Name"], addonInfo["Version"], addonInfo["Date"])

		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECComm", "New instance created (%s)", protected.UID)
	end
	
	-- return the instance table
	return self, protected
end


