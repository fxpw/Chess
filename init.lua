--  Copyright (C) 2008 Tyson Brown
--  
--  This file is part of Chess, an AddOn for World of Warcraft.
--  
--  Chess is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--  
--  Chess is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with Chess.  If not, see <http://www.gnu.org/licenses/>.

-- This global table is used by all the files to store shared data.
-- It is removed in chess.lua
local special_names = {P=UnitName("player"), C="Computer"}

_G.ChessInitData =
 {
  -- A table of functions for enumerating the types of pieces.
  piece_enum = {},
  special_names = special_names
 }

local lang = GetLocale():match("^..")

if lang == "de" then
  special_names.C = "Ordinateur"
elseif lang == "fr" then
  special_names.C = "Ordinateur"
elseif lang == "zh" then
  special_names.C = "计算机"
elseif lang == "ko" then
  special_names.C = "컴퓨터"
elseif lang == "es" then
  special_names.C = "Ordenador"
end
