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

-- Returns where the mouse is relative to a frame.
function _G.ChessInitData.mousePosition(self)
  local scale = self:GetEffectiveScale()
  local x, y = GetCursorPosition()
  return x/scale-self:GetLeft(), y/scale-self:GetBottom()
end

-- Created close buttons do this if you don't give them a function to execute.
local function hideParent(self)
  self:GetParent():Hide()
end

-- Creates a close button for a frame.
function _G.ChessInitData.closeButton(frame, script, w, h, x, y)
  local button = CreateFrame("Button", nil, assert(frame))
  button:SetWidth(w or 23)
  button:SetHeight(h or 23)
  button:SetPoint("TOPRIGHT", x or -3, y or -3)
  button:SetScript("OnClick", script or hideParent)
  button:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up.blp")
  button:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Down.blp")
  button:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight.blp")
  return button
end

-- Create some text for a frame.
function _G.ChessInitData.addText(frame, msg, size, r, g, b, a)
  local text = frame:CreateFontString(nil, "OVERLAY")
  text:SetFont(STANDARD_TEXT_FONT, size or 14)
  text:SetTextColor(r or 1, g or 1, b or 1, a or 1)
  text:SetText(msg or "")
  return text
end

-- Frame edge definition used in several places.
_G.ChessInitData.edge =
 {
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border.blp", 
  edgeSize = 16, 
  insets =
   {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4
   }
 }
