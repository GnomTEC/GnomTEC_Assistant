-- **********************************************************************
-- GnomTEC Assistant - T_GNOMTEC_SCROLLFRAME
-- Version: 5.4.2.1
-- Author: GnomTEC
-- Copyright 2014 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_Assistant")


-- ----------------------------------------------------------------------
-- Templates global Constants (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Templates global variables (local)
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Frame event handler and functions
-- ----------------------------------------------------------------------

function T_GNOMTEC_SCROLLFRAME_EDITBOX_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()
	
	if (width < 64) then
		width = 64
	end
	if (height < 64) then
		height = 64
	end
	
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end
