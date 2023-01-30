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

local floor, ipairs = math.floor, ipairs
local char, byte, format, gsub, match = string.char, string.byte, string.format, string.gsub, string.match

local idtoname = {[-6]="K", [-5]="Q", [-4]="B", [-3]="N", [-2]="R", [-1]="", [1]="", [2]="R", [3]="N", [4]="B", [5]="Q", [6]="K"}
local nametoid = {[""] = 1, R=2, N=3, B=4, Q=5, K=6}
local new, delete = _G.ChessInitData.newTable, _G.ChessInitData.deleteTable
local piece_enum = _G.ChessInitData.piece_enum
local doMove = _G.ChessInitData.doMoveNoWeight
local wcheck, bcheck = _G.ChessInitData.white_check, _G.ChessInitData.black_check
local white_piece_enum, black_piece_enum = _G.ChessInitData.white_piece_enum, _G.ChessInitData.black_piece_enum

local promote_to_move = {R=4096, N=8192, B=12288, Q=16384, [""]=16384}

local copyState, deleteState = _G.ChessInitData.copyState, _G.ChessInitData.deleteState

-- Converts a move in algebraic chess notation to the internally used number format.
-- Returns nil if the move couldn't be parsed.
-- Returns false if the move could be parsed, but wasn't legal or was ambiguous.
-- Returns the number of move was legal.
local function nameToMove(state, name)
  -- Remove comments and white space.
  name = gsub(gsub(gsub(name, ";.*", ""), "%b{}", ""), "%s+", "")
  
  -- Remove game scores.
  name = gsub(name, "1%-0$", "")
  name = gsub(name, "0%-1$", "")
  name = gsub(name, "1/2%-1/2$", "")
  name = gsub(name, "½%-½$", "")
  
  -- Remove good/interesting/blunder markers.
  name = gsub(name, "%??%??!?!?$", "")
  
  -- Convert castles into something we can parse.
  if name == "0-0-0" or name == "O-O-O" then
    if state.n%2 == 0 then
      name = "Kc1"
    else
      name = "Kc8"
    end
  elseif name == "0-0" or name == "O-O" then
    if state.n%2 == 0 then
      name = "Kg1"
    else
      name = "Kg8"
    end
  end
  
  local piece, ambig, dest, prom = match(name, "^([RNBQK]?)([a-h]?[1-8]?)[:x%-]?([a-h][1-8])%(?([RNBQ]?)%)?[%+#]?%+?$")
  
  -- Couldn't parse move.
  if not piece then return nil end
  
  -- Get the piece id, negating if it's black's turn.
  local k, n
  
  if state.n%2 == 0 then
    k, n = state.wk, nametoid[piece]
  else
    k, n = state.bk, -nametoid[piece]
  end
  
  local enum = piece_enum[n]
  local file, rank = byte(dest, 1, 2)
  local dest = file+rank*8-489
  local origin
  
  if ambig == "" then
    -- This should be a totally unambiguous move.
    for i = 0,63 do if state[i] == n then
      local moves = new()
      enum(i, state, moves, k)
      
      for _, mv in ipairs(moves) do if mv == dest then
        if origin then delete(moves) return false end -- Can't accept ambiguous moves.
        origin = i
      end end
      
      delete(moves)
    end end
  elseif match(ambig, "..") then
    -- They specified the exact coordinates.
    file, rank = byte(ambig, 1, 2)
    local i = file+rank*8-489
    
    if state[i] == n then
      local moves = new()
      enum(i, state, moves, k)
      
      for _, mv in ipairs(moves) do if mv == dest then
        origin = i
      end end
      
      delete(moves)
    end
  elseif match(ambig, "[1-8]") then
    -- Specified the piece's rank.
    rank = byte(ambig)*8-392
    for i = rank,rank+7 do if state[i] == n then
      local moves = new()
      enum(i, state, moves, k)
      
      for _, mv in ipairs(moves) do if mv == dest then
        if origin then delete(moves) return false end -- Can't accept ambiguous moves.
        origin = i
      end end
      
      delete(moves)
    end end
  else
    -- Specified the piece's file.
    file = byte(ambig)-97
    for i = file,63,8 do if state[i] == n then
      local moves = new()
      enum(i, state, moves, k)
      
      for _, mv in ipairs(moves) do if mv == dest then
        if origin then delete(moves) return false end -- Can't accept ambiguous moves.
        origin = i
      end end
      
      delete(moves)
    end end
  end
  
  if origin and state[origin] == n then
    local extra = ((n == 1 and dest > 55) or (n == -1 and dest < 8)) and promote_to_move[prom] or 0
    return origin*64+dest+extra
  end
  
  return false
end

local function moveToName(state, move, full)
  local real_origin, dest = floor(move/64), move%64
  local origin
  
  local prom = ""
  
  if real_origin > 64 then
    local index = floor(real_origin/64)
    prom = ("RNBQ"):sub(index, index)
    origin = real_origin%64
  else
    origin = real_origin
  end
  
  local deststr = char(dest%8+97, floor(dest/8)+49)
  
  local n = state[origin]
  
  if (n == 6 and move == 258) or (n == -6 and move == 3898) then
    assert(move == nameToMove(state, "0-0-0"))
    return "0-0-0"
  end
  
  if (n == 6 and move == 262) or (n == -6 and move == 3902) then
    assert(move == nameToMove(state, "0-0"))
    return "0-0"
  end
  
  local file, rank = origin%8, floor(origin/8)
  local enum, ambig, ambigf, ambigr = piece_enum[n], false, false, false
  
  if full then
    -- Pretend everything is ambiguous, no matter what.
    ambig, ambigf, ambigr = true, true, true
  else
    for i=0,63 do
      if state[i] == n and i ~= origin then
        local moves = new()
        
        enum(i, state, moves, state.n%2==0 and state.wk or state.bk)
        
        for _, mv in ipairs(moves) do
          if mv == dest then
            local _file, _rank = i%8, floor(i/8)
            ambig = true
            
            if file == _file then
              ambigf = true
            end
            
            if rank == _rank then
              ambigr = true
            end
            
            break
          end
        end
        
        delete(moves)
      end
    end
  end
  
  if ambig then
    if not ambigf then
      ambig = char(file+97)
    elseif not ambigr then
      ambig = char(rank+49)
    else
      ambig = char(file+97, rank+49)
    end
  else
    ambig = ""
  end
  
  local capture = (state[dest] ~= 0 or (n == 1 and dest == state.wep) or (n == -1 and dest == state.bep)) and "x" or ""
  
  local piece = idtoname[n]
  
  local extra = ""
  local next_state = copyState(state)
  local moves = new()
  doMove(next_state, real_origin*64+dest)
  local enum, k, check
  
  if state.n%2 == 0 then
    enum = black_piece_enum
    k = next_state.bk
    check = bcheck
  else
    enum = white_piece_enum
    k = next_state.wk
    check = wcheck
  end
  
  for i = 0,63 do enum[next_state[i]](i, next_state, moves, k) end
  
  local ret = nil
  
  if #moves == 0 then
    if check(k, next_state) then
      -- No moves and not in check, so stalemate.
      ret = "draw"
    else
      -- No moves and in check, so checkmate.
      extra = "#"
      ret = state.n%2 == 0 and "white" or "black"
    end
  elseif not check(k, next_state) then
    -- In check, but has moves so can get out of it.
    extra = "+"
  end
  
  delete(moves)
  deleteState(next_state)
  
  local result = format("%s%s%s%s%s%s", piece, ambig, capture, deststr, prom, extra)
  assert(move == nameToMove(state, result))
  return result, ret
end

local texName = _G.ChessInitData.texName
local textures =
 {
  R = format("|T%s:16|t", texName("fr.tga")),
  N = format("|T%s:16|t", texName("fn.tga")),
  B = format("|T%s:16|t", texName("fb.tga")),
  Q = format("|T%s:16|t", texName("fq.tga")),
  K = format("|T%s:16|t", texName("fk.tga")),
 }

_G.ChessInitData.moveToName = moveToName
_G.ChessInitData.nameToMove = nameToMove
_G.ChessInitData.nameToFAN = function(name)
  return gsub(name, "[RNBQK]", textures)
end

_G.ChessInitData.moveToFAN = function(state, move)
  return gsub(moveToName(state, move), "[RNBQK]", textures)
end
