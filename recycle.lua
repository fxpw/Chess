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

local free_tables = setmetatable({}, {__mode="k"})
local free_textures = {}
local next, pairs = next, pairs

local used = 0

_G.ChessInitData.newTable = function()
  used = used + 1
  local tbl = next(free_tables)
  if tbl then
    for key in pairs(tbl) do tbl[key] = nil end
    free_tables[tbl] = nil
    return tbl
  else
    return {}
  end
end

_G.ChessInitData.deleteTable = function(tbl)
  --assert(type(tbl) == "table")
  --assert(free_tables[tbl] == nil)
  
  free_tables[tbl] = true
  
  used = used-1
end

_G.ChessInitData.usedTables = function () return used end

-- This has nothing to do with recycling, it's just here because it's used by newTexture,
-- and it wasn't important enough for its own file.
local function texName(name)
  return "Interface\\AddOns\\Chess\\Textures\\"..name
end

_G.ChessInitData.texName = texName

_G.ChessInitData.newTexture = function(parent, texture, layer)
  local tex = next(free_textures)
  if tex then
    free_textures[tex] = nil
    tex:SetParent(parent)
    tex:SetDrawLayer(layer)
    tex:SetVertexColor(1,1,1)
    tex:SetAlpha(1)
    tex:Show()
  else
    tex = parent:CreateTexture(nil, layer)
  end
  
  if not tex:SetTexture(texture) and
     not tex:SetTexture(texName(texture)) then
    tex:SetTexture(1, 0, 1, .2)
  end
  
  return tex
end

_G.ChessInitData.deleteTexture = function(tex)
  tex:SetTexture(1,1,1)
  tex:Hide()
  tex:ClearAllPoints()
  tex:SetParent(UIParent)
  
  free_textures[tex] = true
end
