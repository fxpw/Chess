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

local wrook, wbishop, brook, bbishop = _G.ChessInitData.piece_enum[2],
                                       _G.ChessInitData.piece_enum[4],
                                       _G.ChessInitData.piece_enum[-2],
                                       _G.ChessInitData.piece_enum[-4]

-- Moves for white queens.
_G.ChessInitData.piece_enum[5] = function(i, state, out, king)
  wrook(i, state, out, king)
  wbishop(i, state, out, king)
  
  -- wbishop will have set state[i] to 4, assuming it was a white bishop being moved.
  state[i] = 5
end

-- Moves for black queens.
_G.ChessInitData.piece_enum[-5] = function(i, state, out, king)
  brook(i, state, out, king)
  bbishop(i, state, out, king)
  
  -- wbishop will have set state[i] to -4, assuming it was a black bishop being moved.
  state[i] = -5
end
