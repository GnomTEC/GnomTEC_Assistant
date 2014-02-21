-- **********************************************************************
-- GnomTEC Assistant - T_GNOMTEC_BUTTON
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
function T_GNOMTEC_BUTTON_TABULATOR_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_BUTTON_TABULATOR_OnClick(button,id)
	local tabulator = button:GetParent()
	
	if (tabulator) then
		local childs = {tabulator:GetChildren()}

		for idx, value in ipairs(childs) do
			if (value:IsObjectType("Button")) then
				value:UnlockHighlight()
			end
		end

		local parent = tabulator:GetParent()
		
		if (parent) then
			if (parent.GnomTEC_InnerFrame) then
				childs = {parent.GnomTEC_InnerFrame:GetChildren()}
				for idx, value in ipairs(childs) do
					if (value:GetID() ~= id) then
						value:Hide()
					else
						value:Show()
					end
				end
				if (parent.GnomTEC_InnerFrame.GnomTEC_TriggerResize ~= nil) then
					parent.GnomTEC_InnerFrame.GnomTEC_TriggerResize(parent.GnomTEC_InnerFrame, 0, 0)
				end
			end
		end
	end
	button:LockHighlight()
end