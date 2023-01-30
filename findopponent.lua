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

local search_frame = CreateFrame("Frame", nil, UIParent)

local LFG_CHANNEL = "chess"

search_frame:Hide()

search_frame:SetMovable(true)
search_frame:EnableMouse(true)
search_frame:SetScript("OnMouseDown", search_frame.StartMoving)
search_frame:SetScript("OnMouseUp", search_frame.StopMovingOrSizing)
search_frame:SetPoint("CENTER")
search_frame:SetHeight(20)
search_frame:SetWidth(150)
search_frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }})
search_frame:SetBackdropColor(.3, .3, .3, .5)

local message = _G.ChessInitData.addText(search_frame, "", 12)
message:SetPoint("BOTTOMLEFT", 22, 4)
message:SetPoint("TOPRIGHT", -24, -4)
message:SetJustifyH("LEFT")

local tex = _G.ChessInitData.newTexture(search_frame, "fk.tga", "OVERLAY")
tex:SetPoint("BOTTOMLEFT", 4, 3)
tex:SetPoint("TOPRIGHT", search_frame, "BOTTOMLEFT", 20, 19)

local delay = 0
local anim_frame = 1

local target = ""
local text_anim = {"   ", ".  ", ".. ", "...", " ..", "  ."}

local ask_timeout = 0
local status = "inactive"

local found_callback = nil

local requested_games = {}
local requested_callback = nil

message:SetText("")

local function onUpdate(_, delta)
  delay = delay + delta
  if delay > 1/4 then
    delay = delay - 1/4
    anim_frame = anim_frame + 1
    local text = text_anim[anim_frame]
    if not text then
      anim_frame, text = 1, text_anim[1]
    end
    
    if status == "asking" then
      ask_timeout = ask_timeout - 1/4
      if ask_timeout < 0 then
        -- They took too long to answer, so return to searching.
        delay = -5
        message:SetText("No response.")
        JoinTemporaryChannel(LFG_CHANNEL)
        status = "searching"
      else
        message:SetFormattedText("Asking %s%s", target, text)
      end
    else
      message:SetFormattedText("Searching%s", text)
    end
  end
end

local events = {}
local peer_cmd = {}

local function requestPeerGame(peer, callback)
  local mydata = Chess_Scores["$P"]
  if mydata and mydata.score > 0 and mydata.score < 3000 then
    SendAddonMessage("SChs", "s:"..math.floor(mydata.score+.5).."|j", "WHISPER", peer)
  else
    SendAddonMessage("SChs", "j", "WHISPER", peer)
  end
  
  requested_games[peer] = true
  requested_callback = callback or requested_callback
end

local function acceptPeerGame(peer)
  local mydata = Chess_Scores["$P"]
  if mydata and mydata.score > 0 and mydata.score < 3000 then
    SendAddonMessage("SChs", "s:"..math.floor(mydata.score+.5).."|a", "WHISPER", peer)
  else
    SendAddonMessage("SChs", "a", "WHISPER", peer)
  end
end

function events.CHAT_MSG_CHANNEL_JOIN(_, player, _, _, _, _, _, _, name)
  if name == LFG_CHANNEL then
    target = player
    status = "asking"
    ask_timeout = 20
    
    LeaveChannelByName(LFG_CHANNEL)
    
    local mydata = Chess_Scores["$P"]
    if mydata and mydata.score > 0 and mydata.score < 3000 then
      SendAddonMessage("SChs", "s:"..math.floor(mydata.score+.5).."|j", "WHISPER", player)
    else
      SendAddonMessage("SChs", "j", "WHISPER", player)
    end
  end
end

function events.CHAT_MSG_ADDON(prefix, msg, dist, peer)
  if prefix == "SChs" and dist == "WHISPER" then
    for command in string.gmatch(msg, "[^|]+") do
      local func, data = command:match("^([^:]*):?(.*)")
      func = peer_cmd[func]
      if func then
        func(peer, strsplit(":", data))
      end
    end
  end
end

function peer_cmd.s(peer, score) -- Telling us their score.
  -- Yes, we accept their scores on blind faith.
  -- Yes, they can lie about it.
  -- What do you expect me to do about it?
  
  score = tonumber(score)
  
  if score and score > 0 and score < 3000 then
    local data = Chess_Scores[peer]
    if not data then
      data = {score=score, win=0, lose=0, draw=0}
      Chess_Scores[peer] = data
    else
      data.score = score
    end
  end
end

function peer_cmd.j(peer) -- Request to join a game.
  if status == "searching" then
    status = "inactive"
    LeaveChannelByName(LFG_CHANNEL)
    search_frame:Hide()
    
    found_callback(peer)
    
    acceptPeerGame(peer)
  else
    DEFAULT_CHAT_FRAME:AddMessage(("%s has requested |Hchess:%s|h|cFFC0FFB9a chess game|r|h with you."):format(peer, peer), 1, 1, 0)
    PlaySoundFile("Sound\\Interface\\iTellMessage.wav")
  end
end

function peer_cmd.a(peer) -- Accepting our request to start a game.
  if status == "asking" and target == peer then
    status = "inactive"
    search_frame:Hide()
    found_callback(peer)
  end
  
  if requested_games[peer] then
    requested_games[peer] = nil
    requested_callback(peer)
  end
end

local function onEvent(_, event, ...)
  events[event](...)
end

search_frame:SetScript("OnEvent", onEvent)
search_frame:SetScript("OnUpdate", onUpdate)

for key in pairs(events) do 
  search_frame:RegisterEvent(key)
end

local function startOpponentSearch(callback)
  found_callback = assert(callback)
  if status == "inactive" then
    status = "searching"
    delay = 1
    JoinTemporaryChannel(LFG_CHANNEL)
    search_frame:Show()
  end
end

local function stopOpponentSearch()
  if status == "searching" then
    LeaveChannelByName(LFG_CHANNEL)
  end
  
  if status ~= "inactive" then
    status = "inactive"
    search_frame:Hide()
  end
end

_G.ChessInitData.startOpponentSearch = startOpponentSearch
local close = _G.ChessInitData.closeButton(search_frame, stopOpponentSearch, 20, 20, 0, 0)

_G.ChessInitData.requestPeerGame = requestPeerGame
_G.ChessInitData.acceptPeerGame = acceptPeerGame
