-- **********************************************************************
-- GnomTEC Assistant - T_GNOMTEC_FRAME
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
function T_GNOMTEC_FRAME_Resize(frame, dx, dy)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, (dx+dy >= 0))
			width = width + w
			height = height + h
		end
	end
	if ( (math.abs(width - frame:GetWidth()) > 1) or (math.abs(height - frame:GetHeight()) > 1) ) then
		if ((width < UIParent:GetWidth()) and (height < UIParent:GetHeight())) then
			frame:SetWidth(width)
			frame:SetHeight(height)
		else
			if (frame.GnomTEC_Width and frame.GnomTEC_Height) then
				frame:SetWidth(frame.GnomTEC_Width)
				frame:SetHeight(frame.GnomTEC_Height)
			end
		end
	end
end


function T_GNOMTEC_FRAME_TriggerResize(frame, dx, dy)
	local parent = frame:GetParent()
	if (parent) then
		if (parent.GnomTEC_TriggerResize ~= nil) then
			parent.GnomTEC_TriggerResize(parent, dx, dy)
		end
	end
end


function T_GNOMTEC_FRAME_WINDOW_HEADER_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
		end
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_FRAME_WINDOW_INNERFRAME_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			height = height + h
		end
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_WINDOW_FOOTER_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
		end
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end



function T_GNOMTEC_FRAME_CONTAINER_HORIZONTAL_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incHeight = 0

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			if (h > incHeight) then
				incHeight = h
			end
		end
	end
	height = height + incHeight
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_VERTICAL_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incWidth = 0

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			height = height + h
			if (w > incWidth) then
				incWidth = w
			end
		end
	end
	width = width + incWidth
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABULATOR_ChangeSize(frame, larger)
	local childs
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local tabulator = frame.GnomTEC_Tabulator
	local innerFrame = frame.GnomTEC_InnerFrame
	local id = frame.GnomTEC_ID
	
	if (not id) then
		if (tabulator) then
			local childs = {tabulator:GetChildren()}

			for idx, value in ipairs(childs) do
				if (value:IsObjectType("Button")) and (value:IsShown()) then
					if (not id) then
						id = value:GetID()
					elseif (id > value:GetID()) then
						id = value:GetID()
					end
				end
			end

			if (id) then
				frame.GnomTEC_ID = id
				for idx, value in ipairs(childs) do
					if (value:IsObjectType("Button")) then
						if (value:GetID() ~= id) then
							value:UnlockHighlight()
						else
							value:LockHighlight()
						end
					end
				end

				if (innerFrame) then
					childs = {innerFrame:GetChildren()}
					for idx, value in ipairs(childs) do
						if (value:GetID() ~= id) then
							value:Hide()
						else
							value:Show()
						end
					end
						
					if (innerFrame.GnomTEC_TriggerResize ~= nil) then
						innerFrame.GnomTEC_TriggerResize(innerFrame, 0, 0)
					end
				end
			end
		end
	end
		
	childs = {frame:GetChildren()}
	-- only horizontal tabulators yet
	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			height = height + h
		end
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABULATOR_INNERFRAME_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			height = height + h
		end
	end

	if (width < 24) then
		width = 24
	end
	if (height < 24) then
		height = 24
	end

	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABULATOR_HORIZONTAL_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incHeight = 0

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			if (h > incHeight) then
				incHeight = h
			end
		end
	end
	height = height + incHeight
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_SPACER_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()
	
	if (width < 1) then
		width = 1
	end
	if (height < 1) then
		height = 1
	end
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_FRAME_SCROLLINGMESSAGE_ChangeSize(frame, larger)
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

function T_GNOMTEC_FRAME_SCROLLINGMESSAGE_SetSlider(frame)
	local num = frame.messages:GetNumMessages()
	local cur = frame.messages:GetCurrentScroll()
	
	if (num > 0) then
		frame.slider:SetMinMaxValues(1, num);
		frame.slider:SetValue(num - cur);   
	else
		frame.slider:SetMinMaxValues(0, 0);
		frame.slider:SetValue(0);   	
	end
end

function T_GNOMTEC_FRAME_SCROLLINGMESSAGE_SliderOnValueChanged(frame, value)
	local num = frame.messages:GetNumMessages()
	local cur = frame.messages:GetCurrentScroll()

	if (value > num) then
		frame.messages:SetScrollOffset(0);	
	elseif (value > 0) then
		frame.messages:SetScrollOffset(num - value);
	else
		frame.messages:SetScrollOffset(num);
	end
end


function T_GNOMTEC_FRAME_CONTAINER_TABLE_INNERFRAME_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incWidth = 0
	local heightLines = 0

	if (height < 32) then
		height = 32
	end
	for idx, value in ipairs(childs) do
		heightLines = heightLines + value:GetHeight()
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			if (w > incWidth) then
				incWidth = w
			end
		end
	end
	
	if (height > heightLines+5) then
		height = heightLines+5
	end
	
	width = width + incWidth
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end

function T_GNOMTEC_FRAME_CONTAINER_TABLE_INNERFRAME_LINE_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incHeight = 0

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			if (h > incHeight) then
				incHeight = h
			end
		end
	end
	height = height + incHeight
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABLE_LABELFRAME_ChangeSize(frame, larger)
	local childs = {frame:GetChildren()}
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	local incHeight = 0

	for idx, value in ipairs(childs) do
		if (value.GnomTEC_ChangeSize ~= nil) and (value:IsShown()) then
			local w,h = value:GnomTEC_ChangeSize(value, larger)
			width = width + w
			if (h > incHeight) then
				incHeight = h
			end
		end
	end
	height = height + incHeight
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABLE_SCROLLBAR_ChangeSize(frame, larger)
	local width, height 

	width = frame:GetWidth()
	height = frame:GetHeight()
	
	if (height < 64) then
		height = 64
	end
	
	return (width-frame:GetWidth()), (height-frame:GetHeight())
end


function T_GNOMTEC_FRAME_CONTAINER_TABLE_SCROLLBAR_SetSlider(frame)	
	if (frame:GetParent().GnomTEC_Table) then
		local lines = #(frame:GetParent().GnomTEC_Table)
		local visibleLines = lines
		local child = frame:GetParent():GetScrollChild()
		local offset = frame:GetParent().GnomTEC_Offset
		
		if (child) then
			local firstFrame = select(1,child:GetChildren())
			if (firstFrame) then
				visibleLines = floor((frame:GetParent():GetHeight()-24) / firstFrame:GetHeight())
				if (visibleLines > lines) then
					visibleLines = lines
				end
			end
		end 
		
		if (offset > lines-visibleLines) then
			offset = lines-visibleLines
			frame:GetParent().GnomTEC_Offset = offset
		end

		frame.slider:SetMinMaxValues(0, lines-visibleLines);
		frame.slider:SetValue(offset);   
	else
		frame.slider:SetMinMaxValues(0, 0);
		frame.slider:SetValue(0);   
	end
end

function T_GNOMTEC_FRAME_CONTAINER_TABLE_SCROLLBAR_SliderOnValueChanged(frame, value)
	T_GNOMTEC_SCROLLFRAME_CONTAINER_TABLE_Redraw(frame:GetParent(), value)
end

						
function T_GNOMTEC_FRAME_MAP_ChangeSize(frame, larger)
	local name 
	local width, height 
	local x, y, w, h, map

	name = frame:GetName()
	width = frame:GetWidth()
	height = frame:GetHeight()
	
	width = width * 1024.0 / 1000.0 / 4.0	-- frameWidth * textureSize / visibleSize / numTiles
	height = height * 768.0 / 667.0 / 3.0 	-- frameHeight * textureSize / visibleSize / numTiles
	
	if (width < 32) then
		width = 32
	end
	if (height < 32) then
		height = 32
	end
	
	if (larger) then
		if width < height then
			width = height
		else
			height = width
		end
	else
		if width > height then
			width = height
		else
			height = width
		end
	end
	for x=0,3,1 do
		for y=0,2,1 do
			map = getglobal(name.."_Map"..(4*y + x + 1))
			map:SetWidth(width)
			map:SetHeight(height)
			map:SetPoint("TOPLEFT", x * width, -y * height)
		end
	end	

	width = (width * 1000.0 * 4.0 / 1024.0)
	height = (height * 667.0 * 3.0 / 768.0)

	return (width-frame:GetWidth()), (height-frame:GetHeight())
end
