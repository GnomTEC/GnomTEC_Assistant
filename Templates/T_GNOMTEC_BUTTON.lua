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

	if (width < 16) then
		width = 16
	end
	if (height < 16) then
		height = 16
	end

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

function T_GNOMTEC_BUTTON_TABLELABEL_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()
	
	if (width < 32) then
		width = 32
	end
	if (height < 16) then
		height = 16
	end
	
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_BUTTON_TABLELABEL_OnClick(button,id)

end

function T_GNOMTEC_BUTTON_TABLECELL_SINGLELINE_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()

	if (width < 32) then
		width = 32
	end
	if (height < 16) then
		height = 16
	end

	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_BUTTON_TABLECELL_SINGLELINE_OnClick(button,rowId)
	local parent = button:GetParent()
	local lineId = parent:GetID()
	
	if button.GnomTEC_OnSelect then
		button.GnomTEC_OnSelect(button, lineId, rowId)
	end
end