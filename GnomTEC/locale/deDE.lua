-- **********************************************************************
-- GnomTEC Localization - deDE
-- Version: 5.4.8.1
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
local MAJOR, MINOR = "GnomTEC-deDE-1.0", 1
local localization, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not localization then return end -- No Upgrade needed.

-- German localization file for deDE.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC", "deDE")
if not L then return end

L["L_OPTIONS_TITLE"] = "GnomTEC Framework\n\n"



