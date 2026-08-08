local DebugService = {}

local config = {
    Enabled = true,
    Level = 3, -- 0=Errors, 1=Warnings, 2=Info, 3=Debug
}

local Levels = {
    Error = 0,
    Warn = 1,
    Info = 2,
    Debug = 3,
}

function DebugService:Log(...)
    if not config.Enabled then return end
    
    local message = table.concat({...}, " ")
    warn("DebugService : " .. message)
end

function DebugService:Error(...)
    if not config.Enabled or config.Level < Levels.Error then return end
    local message = table.concat({...}, " ")
    warn("🔴 ERROR : " .. message)
end

function DebugService:Warn(...)
    if not config.Enabled or config.Level < Levels.Warn then return end
    local message = table.concat({...}, " ")
    warn("🟡 WARN  : " .. message)
end

function DebugService:Info(...)
    if not config.Enabled or config.Level < Levels.Info then return end
    local message = table.concat({...}, " ")
    print("🔵 INFO  : " .. message)
end

function DebugService:Debug(...)
    if not config.Enabled or config.Level < Levels.Debug then return end
    local message = table.concat({...}, " ")
    print("🟢 DEBUG : " .. message)
end

function DebugService:SetLevel(level)
    if type(level) == "string" then
        local map = {
            error = 0,
            warn = 1,
            info = 2,
            debug = 3,
        }
        config.Level = map[level:lower()] or 3
    else
        config.Level = level
    end
end

function DebugService:Enable()
    config.Enabled = true
end

function DebugService:Disable()
    config.Enabled = false
end

function DebugService:Toggle()
    config.Enabled = not config.Enabled
end

function DebugService:Inspect(value, name)
    name = name or "Value"
    
    if type(value) == "table" then
        self:Debug(string.format("%s = {", name))
        for key, val in pairs(value) do
            self:Debug(string.format("  [%s] = %s", tostring(key), tostring(val)))
        end
        self:Debug("}")
    else
        self:Debug(string.format("%s = %s", name, tostring(value)))
    end
end

function DebugService:Time(fn, ...)
    local start = os.clock()
    local results = {fn(...)}
    local elapsed = os.clock() - start
    self:Debug(string.format("⏱️  Took %.4f seconds", elapsed))
    return table.unpack(results)
end

function DebugService:Trace(fn, name)
    name = name or "Anonymous"
    return function(...)
        self:Debug(string.format("➡️  Entering %s", name))
        local args = {...}
        if #args > 0 then
            self:Debug(string.format("   Args: %s", table.concat(args, ", ")))
        end
        
        local results = {fn(...)}
        
        if #results > 0 then
            self:Debug(string.format("   Returns: %s", table.concat(results, ", ")))
        end
        self:Debug(string.format("⬅️  Exiting %s", name))
        
        return table.unpack(results)
    end
end

return DebugService
