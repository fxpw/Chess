-- This is some glue to make the Chess AddOn work outside of World of Warcraft.
-- It is by no means complete, just the bare minimum to get it working.

local env = {}

env._G = env

env.SlashCmdList = {}
function env.UnitName() return "Player" end
function env.UnitFactionGroup() return "Alliance" end
function env.GetLocale() return "enUS" end

local fake_frame = setmetatable({}, {
  __index=function(self) return self end,
  __newindex=function () end,
  __call=function(self) return self end})

function env.CreateFrame()
  return fake_frame
end

function env.print(...)
  print("AddOn:", ...)
end

local to_copy =
 {
  string = true,
  xpcall = true,
  tostring = true,
  unpack  = true,
  setmetatable = true,
  next = true,
  assert = true,
  tonumber = true,
  rawequal = true,
  collectgarbage = true,
  getmetatable = true,
  rawset = true,
  math = true,
  pcall = true,
  table = true,
  type = true,
  coroutine = true,
  select = true,
  pairs = true,
  rawget = true,
  loadstring = true,
  ipairs = true,
  error = true
 }

for key, val in pairs(_G) do
  if to_copy[key] then
    if type(val) == "table" then
      local tbl = {}
      
      for key2, val2 in pairs(val) do
        tbl[key2] = val2
      end
      
      env[key] = tbl
    else
      env[key] = val
    end
  end
end

local toc = assert(io.open("../Chess.toc", "r"))

for line in toc:lines() do
  local filename = line:match("^[%w_]+%.lua$")
  if filename then
    if filename == "chess.lua" then
      -- chess.lua wipes the ChessInitData table, we have to copy what we need from it now.
      assert(env.ChessInitData)
      
      local to_copy = {
        newState = true,
        deleteState = true,
        doMoveNoWeight = true,
        calcScore = true,
        usedTables = true,
        moveToName = true,
        nameToMove = true
      }
      
      for key in pairs(to_copy) do
        _G[key] = assert(env.ChessInitData[key])
      end
    end
    
    print("Loading '"..filename.."'...")
    local func = assert(loadfile("../"..filename))
    setfenv(func, env)
    func()
  end
end

print("Loaded.")

toc:close()
