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

local Maid
if not shared.Maid then
    Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Maid.luau"))()
    shared.Maid = Maid
    
    Success += 1
else
    Maid = shared.Maid
end

local Scheuler
if not shared.Scheduler then
    Scheduler = loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Scheduler.luau"))()
    shared.Scheduler = Scheduler

    Success += 1
else
    Scheduler = shared.Scheduler    
end

local InputManager
if not shared.InputManager then
    InputManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Set1/InputManager.luau"))()
    shared.InputManager = InputManager

    Success += 1
else
    InputManager = shared.InputManager
end
  

DebugService:Info(tostring(Success) .. " MODULES LOADED")

shared.Loaded = true
