-- **********************************************************************
-- GnomTEC Localization - deDE
-- Version: 5.4.7.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
local MAJOR, MINOR = "GnomTEC-deDE-1.0", 1
local localization, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not localization then return end -- No Upgrade needed.

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC", "deDE")
if not L then return end

L["L_OPTIONS_TITLE"] = "GnomTEC Framework\n\n"



