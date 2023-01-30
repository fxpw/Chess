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
local floor = math.floor

-- Moves for white knights.
_G.ChessInitData.piece_enum[3] = function(i, state, out, king)
  local file, rank = i%8, floor(i/8)
  state[i] = 0
  
  if rank < 7 then
    if file > 0 then
      if file > 1 then
        local t = i+6
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank < 6 then
        local t = i+15
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
    
    if file < 7 then
      if file < 6 then
        local t = i+10
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank < 6 then
        local t = i+17
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
  end
  
  if rank > 0 then
    if file > 0 then
      if file > 1 then
        local t = i-10
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank > 1 then
        local t = i-17
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
    
    if file < 7 then
      if file < 6 then
        local t = i-6
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank > 1 then
        local t = i-15
        local n = state[t] 
        if 0 >= n then
          state[t] = 3
          if wcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
  end
  
  state[i] = 3
end

-- Moves for black knights.
_G.ChessInitData.piece_enum[-3] = function(i, state, out, king)
  local file, rank = i%8, floor(i/8)
  state[i] = 0
  
  if rank < 7 then
    if file > 0 then
      if file > 1 then
        local t = i+6
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank < 6 then
        local t = i+15
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
    
    if file < 7 then
      if file < 6 then
        local t = i+10
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank < 6 then
        local t = i+17
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
  end
  
  if rank > 0 then
    if file > 0 then
      if file > 1 then
        local t = i-10
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank > 1 then
        local t = i-17
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
    
    if file < 7 then
      if file < 6 then
        local t = i-6
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
      
      if rank > 1 then
        local t = i-15
        local n = state[t] 
        if 0 <= n then
          state[t] = -3
          if bcheck(king, state) then
            insert(out, t)
          end
          state[t] = n
        end
      end
    end
  end
  
  state[i] = -3
end
