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
local floor = math.floor
local piece_enum = _G.ChessInitData.piece_enum

--[[
  
   ** Board Absolute Indices **
  
  56 57 58 59 60 61 62 63
  48 49 50 51 52 53 54 55
  40 41 42 43 44 45 46 47
  32 33 34 35 36 37 38 39
  24 25 26 27 28 29 30 31
  16 17 18 19 20 21 22 23
   8  9 10 11 12 13 14 15
   0  1  2  3  4  5  6  7
  
  ** Board Relative Indices **
  (added to positions to move pieces)
   
    21  22  23  24  25  26  27
    13  14  15  16  17  18  19
     5   6   7   8   9  10  11
    -3  -2  -1  [0]  1   2   3
   -11 -10  -9  -8  -7  -6  -5
   -19 -18 -17 -16 -15 -14 -13
   -27 -26 -25 -24 -23 -22 -21
]]--

_G.ChessInitData.newState = function()
  -- For the sake of speed, everything here is a numeric constant.
  -- The indexes 0 through 63 represent squares in the chess board.
  -- 0 is the bottom left square, and increasing numbers increase the file.
  -- Going past the last file moves to the start of the next rank.
  
  -- For each of the squares, the values are as follows:
  --  0 - An empty square.
  --  1 - Pawn
  --  2 - Rook
  --  3 - Knight
  --  4 - Bishop
  --  5 - Queen
  --  6 - King
  --
  -- Positive numbers corrospond to white pieces.
  -- Negative numbers corrospond to black pieces.
  
  -- Look at board.svg to get an idea of what each of these numbers mean.
  local b = new()
  
  -- White pieces.
  b[0] = 2
  b[1] = 3
  b[2] = 4
  b[3] = 5
  b[4] = 6
  b[5] = 4
  b[6] = 3
  b[7] = 2
  
  -- White pawns.
  for i = 8,15 do b[i] = 1 end
  
  -- Empty space
  for i = 16,47 do b[i] = 0 end
  
  -- Black pawns
  for i = 48,55 do b[i] = -1 end
  
  -- Black pieces.
  b[56] = -2
  b[57] = -3
  b[58] = -4
  b[59] = -5
  b[60] = -6
  b[61] = -4
  b[62] = -3
  b[63] = -2
  
  -- We need to keep track of where each player's king is, to make sure a player never puts their king in danger.
  b.wk = 4
  b.bk = 60
  
  -- We also keep track if castling is allowed.
  b.wck = true -- king-side
  b.wcq = true -- queen-side
  b.bck = true -- king-side
  b.bcq = true -- queen-side
  
  -- b.n goes down as moves are made.
  -- b[b.n] ... b[-1] are the moves that have been made so far, each one encoded in algebraic chess notation.
  b.n = 0
  
  -- The AI uses score for choosing moves.
  b.score = 0
  
  -- b.wep is the location of a cell allowed to be captured by white pawns, in the case if en-passant captures.
  -- There won't actually be a piece at this location, the piece that would be captured is below this location.
  -- Will be nil if white can't make an en-passant capture.
  
  -- b.bep is the same, but for the black player.
  
  -- if b.states isn't nil, then elements b[64] .. b[b.states] are substates used by the AI.
  
  -- The AI substates are like normal states, but:
  --  * The substates don't record move history, and b.n is nil.
  --  * They have a 'move' key, which contains the move it's parent state must make to reach state b.
  
  -- The substates are sorted by their score, so b[b.states].move is the the best known move the computer
  -- has discovered so far.
  
  return b
end

-- doMove only handle's queen promotions.
-- Non-queen promotions can be handled by doMoveNoWeight, which is used for user moves.
-- Doesn't update state information used by the AI, it is assumed that there isn't any.
local function doMove(state, origin, dest, weight)
  local score = -weight[state[dest]]
  local n = state[origin]
  
  state[origin] = 0
  
  if n > 0 then
    -- White's moves.
    
    -- Prevent castling.
    if origin == 0 then state.wcq = nil end
    if origin == 7 then state.wck = nil end
    if dest == 56 then state.bcq = nil end
    if dest == 63 then state.bck = nil end
    
    -- Keep track of where the king is.
    if n == 6 then
      state.wk = dest
      
      if origin == 4 then
        -- Move the rook if castling.
        if dest == 6 then
          state[7] = 0
          state[5] = 2
        elseif dest == 2 then
          state[0] = 0
          state[3] = 2
        end
      end
      
      -- Having moved the king, castling is now illegal.
      state.wcq, state.wck = nil, nil
    end
    
    if n == 1 then
      if dest == state.wep then
        -- Making an en passant capture.
        score = score - weight[-1]
        state[dest-8] = 0
      elseif dest >= 56 then
        -- Promote pawn to queen.
        score = score - weight[1] + weight[5]
        n = 5
      elseif dest-origin == 16 then
        -- Black may make an en passant capture of this pawn.
        state.bep = dest-8
      end
    end
    
    -- Having made a move, white loses its right to make any available en passant captures.
    state.wep = nil
  else
    -- Black's moves.
    
    -- Prevent castling.
    if origin == 56 then state.bcq = nil end
    if origin == 63 then state.bck = nil end
    if dest == 0 then state.wcq = nil end
    if dest == 7 then state.wck = nil end
    
    -- Keep track of where the king is.
    if n == -6 then
      state.bk = dest
      
      if origin == 60 then
        -- Move the rook if castling.
        if dest == 62 then
          state[63] = 0
          state[61] = -2
        elseif dest == 58 then
          state[56] = 0
          state[59] = -2
        end
      end
      
      -- Having moved the king, castling is now illegal.
      state.bcq, state.bck = nil, nil
    end
    
    if n == -1 then
      if dest == state.bep then
        -- Making an en passant capture.
        score = score - weight[1]
        state[dest+8] = 0
      elseif dest < 8 then
        -- Promote pawn to queen.
        score = score - weight[-1] + weight[-5]
        n = -5
      elseif origin-dest == 16 then
        -- White may make an en passant capture of this pawn.
        state.wep = dest+8
      end
    end
    
    -- Having made a move, black loses its right to make any available en passant captures.
    state.bep = nil
  end
  
  state[dest] = n
  
  return score
end

_G.ChessInitData.copyState = function(state)
  local new_state = new()
  
  for i=0,63 do new_state[i] = state[i] end
  
  new_state.wk, new_state.bk = state.wk, state.bk
  new_state.wck, new_state.wcq, new_state.bck, new_state.bcq = state.wck, state.wcq, state.bck, state.bcq
  new_state.wep, new_state.bep = state.wep, state.bep
  new_state.n = state.n
  
  -- Move names aren't copied!
  
  return new_state
end

local nil_weight= {}
for i = -6,6 do nil_weight[i] = 0 end

_G.ChessInitData.doMove = doMove

local function deleteState(state)
  for i = 64,state.states or 63 do
    deleteState(state[i])
  end
  
  delete(state)
end

-- Do move, but doesn't take a weight array, and doesn't return the score offset.
-- 
-- In the special case of promotions, the origin/64 
-- 
-- returns [origin1], [dest1], [promote1], [origin2], [dest2], [promote2]
-- 
-- The return values can be used to figure out what moved where, for use in drawing or animations.
-- 
-- origin1 and dest1 is always origin and dest.
-- promote1 is usually what the piece at origin1 started as, unless it is a promoted pawn, then it's what it was promoted to.
-- promote1 will never be 0
-- origin2 and dest2 are usually equal to dest1, unless:
--   an en passent capture was made, then origin2 is where the captured pawn was.
--   castling occured, then origin2 is the rook that was moved, and dest2 is where it was moved to.
-- promote2 will be 0 for captures. in the case of castling, it will be 2 or -2 depending on who castled.
-- origin2, dest2, and promote2 will all be nil if only a single piece was affected by the move.
_G.ChessInitData.doMoveNoWeight = function(state, move)
  local origin, dest = floor(move/64), move%64
  local prom
  
  origin, prom = origin%64, floor(origin/64)
  
  local type = state[origin]
  local origin2, dest2, type2, promote2 = dest, dest, state[dest], 0
  
  if state[dest] == 0 then
    origin2, dest2, type2, promote2 = nil, nil, nil, nil
  end
  
  if state[origin] == 1 and dest == state.wep then
    -- White en passant capture
    origin2, dest2, type2, promote2 = dest-8, dest, -1, 0
  elseif state[origin] == -1 and dest == state.bep then
    -- Black en passant capture
    origin2, dest2, type2, promote2 = dest+8, dest, 1, 0
  elseif state[origin] == 6 and origin == 4 then
    if dest == 6 then
      -- White king-side castle.
      origin2, dest2, type2, promote2 = 7, 5, 2, 2
    elseif dest == 2 then
      -- White queen-side castle.
      origin2, dest2, type2, promote2 = 0, 3, 2, 2
    end
  elseif state[origin] == -6 and origin == 60 then
    if dest == 62 then
      -- Black king-side castle.
      origin2, dest2, type2, promote2 = 63, 61, -2, -2
    elseif dest == 58 then
      -- Black queen-side castle.
      origin2, dest2, type2, promote2 = 56, 59, -2, -2
    end
  end
  
  doMove(state, origin, dest, nil_weight)
  
  if type ~= state[dest] then
    -- A promotion happened.
    
    assert(type == 1 or type == -1) -- Should have been a queen.
    assert(prom ~= 0) -- Should have specified a multiplier.
    
    -- doMove assumed a queen, we'll instead multiply the original type by prom+1.
    -- This works out perfectly, since only pawns can be promoted, and their values are 1 or -1.
    state[dest] = type * (prom+1)
  end
  
  -- Try to preserve the state data used by the AI, if it created any.
  if state.states then
    local empty = true
    
    if move >= 16384 then
      -- Want to be able to find the computer's queen promotions.
      move = move - 16384
    end
    
    for i = 64,state.states do
      local sub_state = state[i]
      if sub_state.move == cmove then
        -- Found a state matching the move the player made.
        
        for i = i+1,state.states do
          -- Finish deleting the unrelated states.
          deleteState(state[i])
        end
        
        -- Copy any move sub_state's states into current game state.
        if sub_state.states then
          for i=64,sub_state.states do
            state[i] = sub_state[i]
          end
        end
        
        state.states = sub_state.states
        sub_state.states = nil
        deleteState(sub_state)
        
        empty = false
        
        break
      end
      
      deleteState(sub_state)
    end
    
    if empty then
      -- We'll have ended up deleting everything if a non-queen promotion was made.
      -- In that case, we set states to nil and let the computer rebuild from scratch.
      state.states = nil
    end
  end
  
  state.n = state.n-1
  
  return origin, dest, type, state[dest], origin2, dest2, type2, promote2
end

_G.ChessInitData.deleteState = deleteState

local insert, concat = table.insert, table.concat

-- This returns a string representing a unique state, to determine if a draw can be claimed by three-fold repetition.
-- The contents of the string aren't important, just how many times that exact string has been returned.
_G.ChessInitData.stateID = function(state)
  local moves, result = new(), new()
  
  for i = 0,63 do
    local n = state[i]
    insert(result, tostring(n))
    
    if n < 0 then
      piece_enum[n](i, state, moves, state.bk)
    else
      piece_enum[n](i, state, moves, state.wk)
    end
    
    for i = 1,#moves do
      local mv = moves[i]
      moves[i] = nil
      insert(result, "."..tostring(mv))
    end
  end
  
  local id = concat(result, " ")
  
  delete(result)
  delete(moves)
  
  return id
end
