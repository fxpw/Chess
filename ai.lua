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

local new, delete = _G.ChessInitData.newTable, _G.ChessInitData.deleteTable
local doMove = _G.ChessInitData.doMove
local random = math.random

local white_piece_enum, black_piece_enum = {}, {}
local wcheck, bcheck = _G.ChessInitData.white_check, _G.ChessInitData.black_check
local copyState = _G.ChessInitData.copyState

_G.ChessInitData.white_piece_enum, _G.ChessInitData.black_piece_enum = white_piece_enum, black_piece_enum

local white_piece_weight, black_piece_weight = {}, {}
local insert, remove = table.insert, table.remove
local floor = math.floor

white_piece_weight[0] = 0     -- Nothing
white_piece_weight[1] = 1     -- Pawn
white_piece_weight[2] = 5     -- Rook
white_piece_weight[3] = 2     -- Knight
white_piece_weight[4] = 3     -- Bishop
white_piece_weight[5] = 9     -- Queen
-- There is no weight set for the king, since no legal move can remove the king.

for i = 1,5 do
  -- Have white consider black's weights to be the opposite of its own.
  white_piece_weight[-i] = -white_piece_weight[i]
end

for i = -5,5 do
  -- Have weights for black be the opposite of white's weights.
  black_piece_weight[i] = -white_piece_weight[i]
end

local function nop()
  -- Do nothing.
end

_G.ChessInitData.piece_enum[0] = nop

for i, f in pairs(_G.ChessInitData.piece_enum) do
  black_piece_enum[i] = i <= 0 and f or nop
  white_piece_enum[i] = i >= 0 and f or nop
end

local shuffle = {}

for i = 0,63 do shuffle[i] = i end

local function addState(state, new_state)
  local mn, mx = 64,state.states+1
  local score = new_state.score
  
  state.states = mx
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if state[m].score < score then
      mn = m+1
    else
      mx = m
    end
  end
  
  insert(state, mn, new_state)
end

-- Returns true if the computer has figured out how to force checkmate (or stalemate, it is the best it can hope for.)
local function calcScore(state, enum, weight, k, nenum, nweight, nk)
  local n = state.states
  
  if n == 63 then
    -- Holy crap, we've solved chess!
    -- (Not really, this is probably just endgame)
    return true
  elseif n then
    local sub_state = state[n]
    
    if calcScore(sub_state, nenum, nweight, nk, enum, weight, k) then
      return true
    end
    
    state[n] = nil
    state.states = n-1
    
    addState(state, sub_state)
    
    state.score = -state[n].score
  else
    local moves = new()
    local score = state.score
    
    local king = state[k]
    state.states = 63
    
    for i = 0,63 do
      local j = random(i,63)
      local origin = shuffle[j]
      shuffle[i], shuffle[j] = origin, shuffle[i]
      
      enum[state[origin]](origin, state, moves, king)
      
      local n = #moves
      
      for i=1,n do
        j = random(i,n)
        local dest = moves[j]
        
        moves[j] = moves[i]
        moves[i] = nil
        
        local new_state = copyState(state)
        new_state.move = origin*64+dest
        
        assert(new_state[new_state.wk] == 6)
        assert(new_state[new_state.bk] == -6)
        
        if new_state[dest] == -6 or new_state[dest] == 6 then
          DEFAULT_CHAT_FRAME:AddMessage(state[origin].."@"..origin.." to "..state[dest].."@"..dest)
        end
        
        assert(new_state[dest] ~= -6)
        assert(new_state[dest] ~= 6)
        new_state.score = doMove(new_state, origin, dest, weight) - score
        assert(new_state[new_state.wk] == 6)
        assert(new_state[new_state.bk] == -6)
        addState(state, new_state)
      end
    end
    
    delete(moves)
    
    local n = state.states
    
    if n == 63 then
      -- Can't make any moves. We probably lose. Unless this was a stalemate.
      -- TODO: Check for stalemate.
      if k == "wk" then
        state.score = wcheck(state.wk, state) and 0 or 1000
      else
        state.score = bcheck(state.bk, state) and 0 or 1000
      end
    else
      state.score = -state[n].score
    end
  end
end

_G.ChessInitData.calcScore = function(state)
  if state.n%2 == 0 then
    return calcScore(state, white_piece_enum, white_piece_weight, "wk", black_piece_enum, black_piece_weight, "bk")
  else
    return calcScore(state, black_piece_enum, black_piece_weight, "bk", white_piece_enum, white_piece_weight, "wk")
  end
end

