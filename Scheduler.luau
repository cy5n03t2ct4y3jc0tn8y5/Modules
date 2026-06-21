--[=[
    @class Scheduler
    Schedule tasks to be run in specified intervals

    Example Usage:
    Fires a callback every 5 seconds
    ```lua
    local Scheduler = Stellar.Get("Scheduler")

    local Loop = Scheduler.new(5)

    Loop:Tick(function()
        print("Tick")
    end)

    Loop:Start()
    ```
]=]

local Scheduler = {}
Scheduler.__index = Scheduler

local Stellar = shared.Stellar
local RunService = game:GetService("RunService")

local Maid = Stellar.Get("Maid")
local Signal = Stellar.Get("Signal")

--- Create a new Scheduler object
--- @return Scheduler
function Scheduler.new(LoopTime: number)
	local self = setmetatable({
		_Elapsed = 0,
		LoopTime = LoopTime,
		_Signal = Signal.new("SchedulerSignal"),
		_Maid = Maid.new(),
		_LoopMaid = Maid.new()
	}, Scheduler)

	self._Maid:GiveTask(self._Signal)
	self._Maid:GiveTask(self._LoopMaid)

	return self
end

--- Begin running scheduled tasks
function Scheduler:Start()
	self._LoopMaid:GiveTask(RunService.Heartbeat:Connect(function()
		if tick() - self._Elapsed > self.LoopTime then
			self._Elapsed = tick()
			self._Signal:Fire()
		end
	end))
end

--- Pause scheduler execution
function Scheduler:Pause()
	self._LoopMaid:DoCleaning()
end

--- Connect a callback to scheduler ticks
function Scheduler:Tick(Func: () -> ())
	return self._Signal:Connect(Func)
end

--- Destroy the scheduler and clean up connections
function Scheduler:Destroy()
	self._Maid:DoCleaning()
end

return Scheduler
