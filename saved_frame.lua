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

local mousePosition = _G.ChessInitData.mousePosition
local addText = _G.ChessInitData.addText
local addClose = _G.ChessInitData.closeButton

local special_names = _G.ChessInitData.special_names

local frame = CreateFrame("Frame", nil, UIParent)
_G.ChessInitData.saved_frame = frame

frame:Hide()
frame:SetPoint("CENTER")
frame:SetWidth(400)
frame:SetHeight(250)
frame:SetBackdrop(_G.ChessInitData.edge)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetToplevel(true)
frame:SetMinResize(140, 80)
frame:EnableMouse(true)

local titlebg = _G.ChessInitData.newTexture(frame, "title.tga", "BACKGROUND")
titlebg:SetVertexColor(.5, .7, 1)
titlebg:SetPoint("TOPLEFT", 4, -4)
titlebg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, -24)

local text = _G.ChessInitData.addText(frame, "Past Games", 14, 0, 0, 0)
text:SetPoint("BOTTOMLEFT", titlebg)
text:SetPoint("TOPRIGHT", titlebg)

local empty_text = _G.ChessInitData.addText(frame, "No Games To Display", 26, 1, 1, 1)
empty_text:SetPoint("BOTTOMLEFT", 4, 4)
empty_text:SetPoint("TOPRIGHT", -4, -24)
empty_text:Hide()

addClose(frame)

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetTexture(0, 0, 0, .5)
bg:SetPoint("BOTTOMLEFT", 4, 4)
bg:SetPoint("TOPRIGHT", -4, -24)

local scroll = CreateFrame("ScrollFrame", "Chess_SavedGameScroller", frame, "FauxScrollFrameTemplate")
scroll:SetPoint("TOPRIGHT", -28, -25)
scroll:SetPoint("BOTTOMLEFT", 6, 6)



local function onEnter(self)
  self.bg:SetAlpha(.8)
end

local function onLeave(self)
  self.bg:SetAlpha(.3)
end

local function onClick(self)
  -- frame:Hide()
  frame.loadGame(self.game)
end

local scrollUpdate

local function deleteSave(self)
  local to_del = self:GetParent().game
  for i,game in pairs(Chess_Games) do
    if to_del == game then
      table.remove(Chess_Games, i)
    end
  end
  
  scrollUpdate()
end

local frames = {}

local function count(n, what, whatp)
  if n == 1 then
    return n.." "..what
  else
    return n.." "..(whatp or what.."s")
  end
end

scrollUpdate = function()
  local num = #Chess_Games
  
  local display = math.floor(scroll:GetHeight()/16)
  FauxScrollFrame_Update(scroll, num, display, 16)
  local offset = FauxScrollFrame_GetOffset(scroll)
  
  local parent = frame
  
  if num == 0 then
    scroll:Hide()
    empty_text:Show()
  else
    empty_text:Hide()
    local has_scroll = scroll:IsVisible()
    
    for i = 1,display do
      local index = i+offset
      local frame = frames[i]
      local game = Chess_Games[num+1-index]
      
      if game then
        if not frame then
          frame = CreateFrame("Frame", nil, parent)
          frame.text = addText(frame, "", 14, .7, .7, .7)
          frame.text:SetFont("Fonts\\ARIALN.TTF", 14)
          frame.text:SetAllPoints()
          frame.text:SetJustifyH("LEFT")
          frame.bg = frame:CreateTexture(nil, "BACKGROUND")
          frame.bg:SetAllPoints()
          frame.bg:SetAlpha(.3)
          frame:EnableMouse(true)
          frame:SetScript("OnEnter", onEnter)
          frame:SetScript("OnLeave", onLeave)
          frame:SetScript("OnMouseUp", onClick)
          addClose(frame, deleteSave, 16, 16, 0, 0)
          frames[i] = frame
        end
        
        frame.game = game
        
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", scroll, 0, 16-i*16)
        frame:SetPoint("BOTTOMRIGHT", scroll, "TOPRIGHT", has_scroll and 5 or 24, -i*16)
        
        local white, black, when, moves, outcome = game:match("^(.-) (.-) (.-) (.-) ([^ ]+)$")
        
        moves = select(2, moves:gsub("[^ ]+ ?", ""))
        
        white = white:gsub("^%$(.*)", special_names)
        black = black:gsub("^%$(.*)", special_names)
        
        local fmt = "%s - %s vs %s - |cffffffff%d|r moves"
        
        if outcome == "1-0" then
          fmt = "%s - |cffffff80%s|r vs %s - |cffffffff%d|r moves"
        elseif outcome == "0-1" then
          fmt = "%s - %s vs |cffffff80%s - |cffffffff%d|r moves"
        end
        
        local now = time()
        when = tonumber(when, 16)
        
        local delta = now - when
        
        if delta < 0 then
          when = "once upon a temporal paradox"
        elseif delta < 518400 then
          local seconds = delta%60
          local minutes = math.floor(delta/60)%60
          local hours = math.floor(delta/3600)%24
          local when_day = date("%A", when)
          local today = date("%A", now)
          local yesterday = date("%A", now-86400)
          
          if delta < 60 then
            when = count(seconds, "second").." ago"
          elseif delta < 3600 then
            if seconds == 0 then
              when = count(minutes, "minute").." ago"
            else
              when = count(minutes, "minute")..", "..count(seconds, "second").." ago"
            end
          elseif delta < 43200 then
            if minutes == 0 then
              when = count(hours, "hour").." ago"
            else
              when = count(hours, "hour")..", "..count(minutes, "minute").." ago"
            end
          elseif when_day == today then
            when = "Today at "..date("%I:%M %p", when)
          elseif when_day == yesterday then
            when = "Yesterday at "..date("%I:%M %p", when)
          else
            when = when_day.." at "..date("%I:%M %p", when)
          end
        else
          print(delta)
          when = date("%B %d, %Y, at %I:%M %p", when)
        end
        
        frame.text:SetFormattedText(fmt, when, white, black, moves)
        
        if index%2 == 0 then
          frame.bg:SetTexture(0, .2, .4)
        else
          frame.bg:SetTexture(0, .15, .3)
        end
        
        frame:Show()
      elseif frame then
        frame:Hide()
      end
    end
  end
  
  for i = display+1, #frames do
    frames[i]:Hide()
  end
end

scroll:SetScript("OnVerticalScroll", function(self, arg) FauxScrollFrame_OnVerticalScroll(self, arg, 16, scrollUpdate) end)
scroll:SetScript("OnShow", scrollUpdate)

local delay = 0

local function onUpdate(self, delta)
  delay = delay + delta
  if delay > .3 then
    delay = 0
    scrollUpdate()
  end
end

frame:SetScript("OnMouseDown", function (self, btn)
  if btn == "LeftButton" then
    local w, h = self:GetWidth(), self:GetHeight()
    local x, y = mousePosition(self)
    
    local anchor = ""
    
    if y <= 8 then anchor = "Bottom"
    elseif y >= h-8 then anchor = "Top" end
    
    if x <= 8 then anchor = anchor .. "Left"
    elseif x >= w-8 then anchor = anchor .. "Right" end
    
    if anchor == "" then
      self:StartMoving()
    else
      self:StartSizing(anchor)
      self:SetScript("OnUpdate", onUpdate)
    end
  end
end)

frame:SetScript("OnMouseUp", function (self)
  self:StopMovingOrSizing()
  self:SetScript("OnUpdate", nil)
  scrollUpdate()
end)
