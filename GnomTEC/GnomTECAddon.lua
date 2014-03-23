-- **********************************************************************
-- GnomTECAddon Class
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTECAddon-1.0", 1
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

-- ----------------------------------------------------------------------
-- Class Static Variables (local)
-- ----------------------------------------------------------------------
local lastUID = 0
local dataObjects = {}

-- ----------------------------------------------------------------------
-- Class Startup Initialization
-- ----------------------------------------------------------------------
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")


-- ----------------------------------------------------------------------
-- Helper Functions (local)
-- ----------------------------------------------------------------------
-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

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
function GnomTECAddon(addonTitle, addonInfo)
	-- call base class
	local self, protected = GnomTECComm(addonTitle, addonInfo, frameworkRevision)
		
	-- public fields go in the instance table
	-- self.field = value

	-- protected fields go in the protected table
	-- protected.field = value
	
	-- private fields are implemented using locals
	-- they are faster than table access, and are truly private, so the code that uses your class can't get them
	-- local field
	local addonTitle = addonTitle
	local aceAddon = nil
	local minimapIconDataObject = nil
		
	-- private methods
	-- local function f()
	local function OnInitialize()
	 	-- Code that you want to run when the addon is first loaded goes here.
		self.db = LibStub("AceDB-3.0"):New(addonTitle.."DB", defaultsDb, true)
		if (not self.db.profile.GnomTECAddon) then
			self.db.profile.GnomTECAddon = {}
		end
		self.SafeCall(protected.OnInitialize)
	end

	local function OnEnable()
  	  -- Called when the addon is enabled
		self.SafeCall(protected.OnEnable)
	end

	local function OnDisable()
		-- Called when the addon is disabled
		self.SafeCall(protected.OnDisable)
		aceAddon:UnregisterAllEvents();
	end

	-- protected methods
	-- function protected.f()
	
	-- public methods
	-- function self.f()
	function self.LogMessage(logLevel, message, ...)
		protected.LogMessage(CLASS_ADDON, logLevel, addonTitle, message, ...)
	end

	function self.NewDataObject(name, dataObject)
		if (emptynil(name)) then
			name = addonTitle..": "..name
		else
			name = addonTitle
		end
		
		dataObject = ldb:NewDataObject(name, dataObject)
		dataObjects[addonTitle][name] = dataObject
		
		return dataObject 
	end
	
	function self.ShowMinimapIcon(dataObject)
		if (dataObject) and (not minimapIconDataObject) then
			minimapIconDataObject = dataObject
			if (not self.db.profile.GnomTECAddon.minimapIcon) then
				self.db.profile.GnomTECAddon.minimapIcon = {hide = false}
			end
			icon:Register(addonTitle, minimapIconDataObject, self.db.profile.GnomTECAddon.minimapIcon)
		end
		
		if (minimapIconDataObject) then
			self.db.profile.GnomTECAddon.minimapIcon.hide = false
			icon:Show(addonTitle)
		end
	end

	function self.HideMinimapIcon()
		if (minimapIconDataObject) then
			self.db.profile.GnomTECAddon.minimapIcon.hide = true
			icon:Hide(addonTitle)
		end
	end
	
	function self.GetAddonTitle()
		return addonTitle
	end
	
	-- constructor
	do
		-- get localization first.
		L = protected.GetLocale()

		-- get texture path
		T = protected.GetTexturePath()	

		lastUID = lastUID + 1
		protected.addonUID = "GnomTECAddonInstance"..lastUID
		
		dataObjects[addonTitle]= {}
		
		aceAddon = LibStub("AceAddon-3.0"):NewAddon(addonTitle, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")

		function aceAddon:OnInitialize()
			OnInitialize()
		end
		function aceAddon:OnEnable()
			OnEnable()
		end
		function aceAddon:OnDisable()
			OnDisable()
		end
		
		protected.LogMessage(CLASS_CLASS, LOG_DEBUG, "GnomTECAddon", "New instance created (%s / %s)", protected.UID, protected.addonUID)
	end
	
	-- return the instance and protected table
	return self, protected
end


