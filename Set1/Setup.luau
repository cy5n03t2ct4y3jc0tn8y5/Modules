shared.Loaded = false

local Success = 0

local DebugService

if not shared.DebugService then
  DebugService = loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Set1/DebugService.luau"))()
  shared.DebugService = DebugService
  
  Success += 1
else
  DebugService = shared.DebugService
end

DebugService:Info(tostring(Success) .. " MODULES LOADED")

shared.Loaded = true
