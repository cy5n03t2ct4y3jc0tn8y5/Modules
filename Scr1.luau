task.wait(6)
clearteleportqueue()

queueonteleport([[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Scr1.luau"))()
]])

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Client = Players.LocalPlayer
local PlaceId = game.PlaceId

local LOBBY_ID = 87061591699718
local DUNGEON_ID = 73462038693506

----------------------------------------------------------------
-- Utility
----------------------------------------------------------------
local function SafeFire(remote, ...)
    if not remote then return false end
    local success, err = pcall(function(...)
        remote:FireServer(...)
    end, ...)
    if not success then
        warn("[SafeFire] Failed:", err)
    end
    return success
end

local function WaitForPath(root, path, timeout)
    timeout = timeout or 10
    local current = root
    for _, name in ipairs(string.split(path, ".")) do
        current = current:WaitForChild(name, timeout)
        if not current then return nil end
    end
    return current
end

----------------------------------------------------------------
-- LOBBY
----------------------------------------------------------------
if PlaceId == LOBBY_ID then
    local Remotes = WaitForPath(ReplicatedStorage, "Package.Remotes", 15)
    if not Remotes then
        warn("[Lobby] Could not find Remotes")
        return
    end

    local function FireRemote(name, ...)
        local remote = Remotes:FindFirstChild(name)
        if remote then
            SafeFire(remote, ...)
            return true
        end
        warn("[Lobby] Missing remote:", name)
        return false
    end

    task.wait(0.5)

    FireRemote("createparty")
    task.wait(0.15)

    FireRemote("setdungeon", "The Amphitheatre")
    task.wait(0.15)

    local modifiers = {"Nightmare", "Eclipsed", "FriendlyFire", "Hardcore"}
    for _, mod in ipairs(modifiers) do
        FireRemote("setmodifier", mod)
        task.wait(0.12)
    end

    task.wait(0.3)
    FireRemote("tptodungeon")
end

----------------------------------------------------------------
-- DUNGEON
----------------------------------------------------------------
if PlaceId ~= LOBBY_ID then
    -- Load framework
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Set1/Setup.luau"))()
    end)
    if not success then
        warn("[Dungeon] Failed to load Setup:", err)
        return
    end

    repeat task.wait() until shared.Loaded == true

    local InputManager = shared.InputManager
    local DebugService = shared.DebugService
    local Scheduler   = shared.Scheduler
    local Maid        = shared.Maid

    local Auto = true
    local CurrentTarget = nil
    local Targets = {}
    local WeaponName = "Bluesteel Spearaxe"

    local NewMaid = Maid.new()

    ----------------------------------------------------------------
    -- Safe Hit
    ----------------------------------------------------------------
    local function GetWeapon()
        local char = Client.Character
        if not char then return nil end
        return char:FindFirstChild(WeaponName)
    end

    local function Hit(enemy)
        local weapon = GetWeapon()
        if not weapon then return end

        local useRemote = weapon:FindFirstChild("Server") and weapon.Server:FindFirstChild("Use")
        if not useRemote then return end

        local root = enemy:FindFirstChild("HumanoidRootPart")
        if not root then return end

        pcall(function()
            useRemote:FireServer("MouseButton1", true, root.CFrame)
            useRemote:FireServer("MouseButton1", false, root.CFrame)
        end)
    end

    ----------------------------------------------------------------
    -- Target Management
    ----------------------------------------------------------------
    local TargetScheduler = Scheduler.new(0.08)

    TargetScheduler:Tick(function()
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end

        -- Add new enemies
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy:IsA("Model") and not table.find(Targets, enemy) then
                table.insert(Targets, enemy)
            end
        end

        -- Remove invalid / dead enemies
        for i = #Targets, 1, -1 do
            local enemy = Targets[i]
            local humanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")

            local isValid = enemy
                and enemy:IsDescendantOf(enemiesFolder)
                and humanoid
                and humanoid.Health > 0

            if not isValid then
                if enemy == CurrentTarget then
                    CurrentTarget = nil
                end
                table.remove(Targets, i)
            end
        end
    end)

    ----------------------------------------------------------------
    -- Combat Loop
    ----------------------------------------------------------------
    local CombatScheduler = Scheduler.new(0.07)

    CombatScheduler:Tick(function()
        if not Auto then return end

        local char = Client.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        -- Pick new target if needed
        if not CurrentTarget or not CurrentTarget:IsDescendantOf(workspace) then
            CurrentTarget = Targets[1]
        end

        if not CurrentTarget then return end

        local humanoid = CurrentTarget:FindFirstChildOfClass("Humanoid")
        local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 or not targetRoot then
            CurrentTarget = nil
            return
        end

        -- Position under the enemy
        local targetPivot = CurrentTarget:GetPivot()
        local position = (targetPivot * CFrame.new(0, -9, 0)).Position

        pcall(function()
            char:PivotTo(CFrame.lookAt(position, targetRoot.Position))

            local root = char.HumanoidRootPart
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)

        Hit(CurrentTarget)
    end)

    NewMaid:GiveTask(TargetScheduler)
    NewMaid:GiveTask(CombatScheduler)

    ----------------------------------------------------------------
    -- Keybinds
    ----------------------------------------------------------------
    InputManager.new(Enum.KeyCode.R, function()
        Auto = not Auto
        workspace.Gravity = Auto and 0 or 196.2
        DebugService:Debug(Auto and "Auto ON" or "Auto OFF")
    end)

    InputManager.new(Enum.KeyCode.P, function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            InputManager:Exit()
            NewMaid:DoCleaning()
            DebugService:Debug("Exited Runtime")
        end
    end)

    ----------------------------------------------------------------
    -- Start
    ----------------------------------------------------------------
    TargetScheduler:Start()
    CombatScheduler:Start()

    -- Auto click Start button
    task.spawn(function()
        local playButton = WaitForPath(Client.PlayerGui, "StartGUI.FlexHolder.PlayButton", 12)
        if playButton then
            pcall(function()
                firesignal(playButton.MouseButton1Down)
                firesignal(playButton.MouseButton1Up)
            end)
        end
    end)

    DebugService:Debug("Started Runtime")

    ----------------------------------------------------------------
    -- Victory → Teleport back to Lobby
    ----------------------------------------------------------------
    task.spawn(function()
        while task.wait(0.4) do
            local victory = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Victory")
            
            if victory and victory.Enabled then
                local button = victory:FindFirstChild("FlexHolder")
                    and victory.FlexHolder:FindFirstChild("ItemContainer")
                    and victory.FlexHolder.ItemContainer:FindFirstChild("PlayButton")

                if button then
                    print("Victory is Enabled → Pressing button")
                    
                    pcall(function()
                        firesignal(button.MouseButton1Click)
                    end)
                    pcall(function()
                        firesignal(button.MouseButton1Down)
                        firesignal(button.MouseButton1Up)
                    end)
                    pcall(function()
                        firesignal(button.Activated)
                    end)
                end
            end
        end
    end)
end
