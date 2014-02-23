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

function T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_ChangeSize(frame, larger)
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local innerFrame = frame.GnomTEC_InnerFrame
	
	if (innerFrame) then
		local w,h = innerFrame:GnomTEC_ChangeSize(innerFrame, larger)
		width = width + w
		height = height + h
	end
	if (height < 80) then
		height = 80
	end
	if (width < 64) then
		width = 64
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_SetTable(frame, table)
	frame.GnomTEC_Table = table
	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_Redraw(frame, 0)
end

function T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_Redraw(frame, offset)
	local table = frame.GnomTEC_Table
	local innerFrame = frame.GnomTEC_InnerFrame
	
	frame.GnomTEC_Offset = offset

	if (innerFrame) then
		local lines = {innerFrame:GetChildren()}
		for idx, line in ipairs(lines) do
			if (line:IsShown()) then
				local l = line:GetID()
				local cells = {line:GetChildren()}
				for idx, cell in ipairs(cells) do
					if (cell:IsShown()) then
						local text = _G[cell:GetName().."_Text"]
						if (text) then
							local r = cell:GetID()
							text:SetText("")
							if (table) then
								if (table[l+offset]) then
									if (table[l+offset][r]) then
										text:SetText(table[l+offset][r][1] or "")
									end
								end
							end
						end
					end
				end	
			end
		end
	end	
end