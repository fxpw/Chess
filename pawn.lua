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

local insert = table.insert
local wcheck, bcheck = _G.ChessInitData.white_check, _G.ChessInitData.black_check

-- Warning: this doesn't check if a pawn is at the top or bottom of the board, it is assumed that pawns in those
-- positions get promoted.

-- Moves for white pawns.
_G.ChessInitData.piece_enum[1] = function(i, state, out, king)
  state[i] = 0
  
  -- Move forward 1.
  if 0 == state[i+8] then
    -- Possible queen promotion.
    state[i+8] = i > 47 and 5 or 1
    if wcheck(king, state) then
      insert(out, i+8)
    end
    state[i+8] = 0
    
    -- Move forward 2.
    if i >= 8 and i < 16 and 0 == state[i+16] then
      state[i+16] = 1
      if wcheck(king, state) then
        insert(out, i+16)
      end
      state[i+16] = 0
    end
  end
  
  local file = i%8
  
  -- Capture left.
  if file > 0 then
    local n = state[i+7]
    if 0 > n then
      state[i+7] = 1
      if wcheck(king, state) then
        insert(out, i+7)
      end
      state[i+7] = n
    end
    
    if state.wep == i+7 then
      -- Make an en passant capture.
      state[i-1] = 0
      state[i+7] = 1
      if wcheck(king, state) then
        insert(out, i+7)
      end
      state[i-1] = -1
      state[i+7] = 0
    end
  end
  
  -- Capture right.
  if file < 7 then
    local n = state[i+9]
    if 0 > n then
      state[i+9] = 1
      if wcheck(king, state) then
        insert(out, i+9)
      end
      state[i+9] = n
    end
    
    if state.wep == i+9 then
      -- Make an en passant capture.
      state[i+1] = 0
      state[i+9] = 1
      if wcheck(king, state) then
        insert(out, i+9)
      end
      state[i+1] = -1
      state[i+9] = 0
    end
  end
  
  state[i] = 1
end

-- Moves for black pawns.
_G.ChessInitData.piece_enum[-1] = function(i, state, out, king)
  state[i] = 0
  
  -- Move down 1.
  if 0 == state[i-8] then
    -- Possible queen promotion.
    state[i-8] = i < 16 and -5 or -1
    
    if bcheck(king, state) then
      insert(out, i-8)
    end
    state[i-8] = 0
    
    -- Move forward 2.
    if i >= 48 and i < 56 and 0 == state[i-16] then
      state[i-16] = -1
      if bcheck(king, state) then
        insert(out, i-16)
      end
      state[i-16] = 0
    end
  end
  
  local file = i%8
  
  -- Capture left.
  if file > 0 then
    local n = state[i-9]
    if 0 < n then
      state[i-9] = -1
      if bcheck(king, state) then
        insert(out, i-9)
      end
      state[i-9] = n
    end
    
    if state.bep == i-9 then
      -- Make an en passant capture.
      state[i-1] = 0
      state[i-9] = -1
      if bcheck(king, state) then
        insert(out, i-9)
      end
      state[i-1] = 1
      state[i-9] = 0
    end
  end
  
  -- Capture right.
  if file < 7 then
    local n = state[i-7]
    if 0 < n then
      state[i-7] = -1
      if bcheck(king, state) then
        insert(out, i-7)
      end
      state[i-7] = n
    end
    
    if state.bep == i-7 then
      -- Make an en passant capture.
      state[i+1] = 0
      state[i-7] = -1
      if bcheck(king, state) then
        insert(out, i-7)
      end
      state[i+1] = 1
      state[i-7] = 0
    end
  end
  
  state[i] = -1
end
