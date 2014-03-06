-- **********************************************************************
-- GnomTEC Assistant - GnomTEC API
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")

-- ----------------------------------------------------------------------
-- GnomTEC API Global Vonstants (local)
-- ----------------------------------------------------------------------

-- GnomTEC API revision
local GNOMTEC_REVISION = 0

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4


-- ----------------------------------------------------------------------
-- GnomTEC API Startup Initialization
-- ----------------------------------------------------------------------

ldb = LibStub:GetLibrary("LibDataBroker-1.1")

GnomTEC = {}
GnomTEC.callbacks = GnomTEC.callbacks or LibStub("CallbackHandler-1.0"):New(GnomTEC)

-- ----------------------------------------------------------------------
-- Local stubs for the GnomTEC API
-- ----------------------------------------------------------------------

local function GnomTEC_LogMessage(level, message)
	GnomTEC:LogMessage(GnomTEC_Assistant, level, message)
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
function GnomTEC:RegisterAddon(addon, addonInfo, revision)
	local addonName = addon:GetName()
	
	GnomTEC_Assistant.addonsList[addonName] = {
		["Addon"] = addonName,
		["AddonInfo"] = addonInfo,
		["Revision"] = revision	
	}
	
	GnomTEC_Assistant:CommUpdateAddonInfo(addonName, addonInfo["Name"], addonInfo["Version"], addonInfo["Date"], 0)

	if (GnomTEC_Assistant.ldbDataObjs["Addons"]) then
		local count = 0
		for _ in pairs(GnomTEC_Assistant.addonsList) do count = count + 1 end
 		GnomTEC_Assistant.ldbDataObjs["Addons"].value = count
		GnomTEC_Assistant.ldbDataObjs["Addons"].text = GnomTEC_Assistant.ldbDataObjs["Addons"].value.." "..GnomTEC_Assistant.ldbDataObjs["Addons"].suffix
	end
	
	GnomTEC_LogMessage(LOG_INFO, (addonInfo["Name"]).." ("..(addonInfo["Version"]).." / "..(addonInfo["Date"])..") registriert")

	if (GNOMTEC_REVISION < revision) then
		GnomTEC_LogMessage(LOG_WARN, (addonInfo["Name"]).." benötigt aktuellere GnomTEC API")
	end
	
	GnomTEC_Assistant:UpdateAddonsTable()
	GnomTEC:UpdateStaticData(GnomTEC_Assistant, GnomTEC_Assistant.addonsList)
	
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
		elseif (not GnomTEC_Assistant.addonsList[addonName]) then
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
--[[
	if (not addon) then
		GnomTEC_LogMessage(LOG_ERROR,"UpdateStaticData() called from unknown addon")
	else
		local addonName = addon:GetName()
		if (not addonName) then
			GnomTEC_LogMessage(LOG_ERROR,"UpdateStaticData() called from unknown addon")
		elseif (not GnomTEC_Assistant.addonsList[addonName]) then
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
--]]
end

