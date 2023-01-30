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
local floor, min = math.floor, math.min

-- Check if a a piece (like, say, a king) is under threat from another piece.
-- These check return false if a piece is under threat, to avoid the 'not'
-- that would would be required in most checks.

-- Note: state[i] isn't checked, and can be anything. When checking if a king's move
-- is legal, you set the cell where the king was to 0 and call this on the kings new position
-- without setting state to 6 or -6.

_G.ChessInitData.white_check = function(i, state)
  local file, rank = i%8, floor(i/8)
  local rank8 = rank*8
  local n
  
  if rank < 7 then
    n = state[i+8]
    if n == -2 or n == -5 or n == -6 then return false end
    if n == 0 then
      for i=i+16,63,8 do
        n = state[i]
        if n ~= 0 then if n == -5 or n == -2 then return false end break end
      end
    end
    
    if file > 0 then
      n = state[i+7]
      if n == -1 or n == -4 or n == -5 or n == -6 then return false end
      if n == 0 then
        for i=i+14,i+min(file, 7-rank)*7,7 do
          n = state[i]
          if n ~= 0 then if n == -5 or n == -4 then return false end break end
        end
      end
      
      if file > 1 and state[i+6] == -3 then return false end
      if rank < 6 and state[i+15] == -3 then return false end
    end
    
    if file < 7 then
      n = state[i+9]
      if n == -1 or n == -4 or n == -5 or n == -6 then return false end
      if n == 0 then
        for i=i+18,i+min(7-file, 7-rank)*9,9 do
          n = state[i]
          if n ~= 0 then if n == -5 or n == -4 then return false end break end
        end
      end
      
      if file < 6 and state[i+10] == -3 then return false end
      if rank < 6 and state[i+17] == -3 then return false end
    end
  end
  
  if rank > 0 then
    n = state[i-8]
    if n == -2 or n == -5 or n == -6 then return false end
    if n == 0 then
      for i=i-16,file,-8 do
        n = state[i]
        if n ~= 0 then if n == -5 or n == -2 then return false end break end
      end
    end
    
    if file > 0 then
      n = state[i-9]
      if n == -4 or n == -5 or n == -6 then return false end
      if n == 0 then
        for i=i-18,i-min(file, rank)*9,-9 do
          n = state[i]
          if n ~= 0 then if n == -5 or n == -4 then return false end break end
        end
      end
      
      if file > 1 and state[i-10] == -3 then return false end
      if rank > 1 and state[i-17] == -3 then return false end
    end
    
    if file < 7 then
      n = state[i-7]
      if n == -4 or n == -5 or n == -6 then return false end
      if n == 0 then
        for i=i-14,i-min(7-file, rank)*7,-7 do
          n = state[i]
          if n ~= 0 then if n == -5 or n == -4 then return false end break end
        end
      end
      
      if file < 6 and state[i-6] == -3 then return false end
      if rank > 1 and state[i-15] == -3 then return false end
    end
  end
  
  if file > 0 then
    n = state[i-1]
    if n == -2 or n == -5 or n == -6 then return false end
    if n == 0 then
      for i=i-2,rank*8,-1 do
        n = state[i]
        if n ~= 0 then if n == -5 or n == -2 then return false end break end
      end
    end
  end
  
  if file < 7 then
    n = state[i+1]
    if n == -2 or n == -5 or n == -6 then return false end
    if n == 0 then
      for i=i+2,rank*8+7 do
        n = state[i]
        if n ~= 0 then if n == -5 or n == -2 then return false end break end
      end
    end
  end
  
  -- Not under threat from anything.
  return true
end

_G.ChessInitData.black_check = function(i, state)
  local file, rank = i%8, floor(i/8)
  local n
  
  if rank < 7 then
    n = state[i+8]
    if n == 2 or n == 5 or n == 6 then return false end
    if n == 0 then
      for i=i+16,63,8 do
        n = state[i]
        if n ~= 0 then if n == 5 or n == 2 then return false end break end
      end
    end
    
    if file > 0 then
      n = state[i+7]
      if n == 4 or n == 5 or n == 6 then return false end
      if n == 0 then
        for i=i+14,i+min(file, 7-rank)*7,7 do
          n = state[i]
          if n ~= 0 then if n == 5 or n == 4 then return false end break end
        end
      end
      
      if file > 1 and state[i+6] == 3 then return false end
      if rank < 6 and state[i+15] == 3 then return false end
    end
    
    if file < 7 then
      n = state[i+9]
      if n == 4 or n == 5 or n == 6 then return false end
      if n == 0 then
        for i=i+18,i+min(7-file, 7-rank)*9,9 do
          n = state[i]
          if n ~= 0 then if n == 5 or n == 4 then return false end break end
        end
      end
      
      if file < 6 and state[i+10] == 3 then return false end
      if rank < 6 and state[i+17] == 3 then return false end
    end
  end
  
  if rank > 0 then
    n = state[i-8]
    if n == 2 or n == 5 or n == 6 then return false end
    if n == 0 then
      for i=i-16,file,-8 do
        n = state[i]
        if n ~= 0 then if n == 5 or n == 2 then return false end break end
      end
    end
    
    if file > 0 then
      n = state[i-9]
      if n == 1 or n == 4 or n == 5 or n == 6 then return false end
      if n == 0 then
        for i=i-18,i-min(file, rank)*9,-9 do
          n = state[i]
          if n ~= 0 then if n == 5 or n == 4 then return false end break end
        end
      end
      
      if file > 1 and state[i-10] == 3 then return false end
      if rank > 1 and state[i-17] == 3 then return false end
    end
    
    if file < 7 then
      n = state[i-7]
      if n == 1 or n == 4 or n == 5 or n == 6 then return false end
      if n == 0 then
        for i=i-14,i-min(7-file, rank)*7,-7 do
          n = state[i]
          if n ~= 0 then if n == 5 or n == 4 then return false end break end
        end
      end
      
      if file < 6 and state[i-6] == 3 then return false end
      if rank > 1 and state[i-15] == 3 then return false end
    end
  end
  
  if file > 0 then
    n = state[i-1]
    if n == 2 or n == 5 or n == 6 then return false end
    if n == 0 then
      for i=i-2,rank*8,-1 do
        n = state[i]
        if n ~= 0 then if n == 5 or n == 2 then return false end break end
      end
    end
  end
  
  if file < 7 then
    n = state[i+1]
    if n == 2 or n == 5 or n == 6 then return false end
    if n == 0 then
      for i=i+2,rank*8+7 do
        n = state[i]
        if n ~= 0 then if n == 5 or n == 2 then return false end break end
      end
    end
  end
  
  -- Not under threat from anything.
  return true
end