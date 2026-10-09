task.wait(2)

if game.PlaceId == 87061591699718 then

    local Client = game.Players.LocalPlayer
    local PlayerGui = Client.PlayerGui

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.createparty
    Event:FireServer()

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.setdungeon
    Event:FireServer(
        "The Amphitheatre"
    )

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.setmodifier
    Event:FireServer(
        "Nightmare"
    )

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.setmodifier
    Event:FireServer(
        "Eclipsed"
    )

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.setmodifier
    Event:FireServer(
        "FriendlyFire"
    )

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.setmodifier
    Event:FireServer(
        "Hardcore"
    )

    task.wait()

    local Event = game:GetService("ReplicatedStorage").Package.Remotes.tptodungeon
    Event:FireServer()
end

if game.PlaceId == 73462038693506 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Set1/Setup.luau"))()
    repeat task.wait() until shared.Loaded == true

    local Players = game:GetService("Players")
    local Client = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local InputManager = shared.InputManager
    local DebugService = shared.DebugService
    local Scheduler = shared.Scheduler
    local Maid = shared.Maid
    local Auto = true

    local function Hit(enemy)
        local Event = game:GetService("Players").LocalPlayer.Character["Bluesteel Spearaxe"].Server.Use
        Event:FireServer(
            "MouseButton1",
            true,
            enemy.HumanoidRootPart.CFrame
        )

        local Event = game:GetService("Players").LocalPlayer.Character["Bluesteel Spearaxe"].Server.Use
        Event:FireServer(
            "MouseButton1",
            false,
            enemy.HumanoidRootPart.CFrame
        )
    end

    local Targets = {}
    local CurrentTarget = nil

    local NewMaid = Maid.new()

    local Targets = {}
    local TargetScheduler = Scheduler.new(0.05)

    TargetScheduler:Tick(function()
        for _, Enemy in ipairs(workspace.Enemies:GetChildren()) do
            if not table.find(Targets, Enemy) then
                table.insert(Targets, Enemy)
            end
        end

        for i = #Targets, 1, -1 do
            local Enemy = Targets[i]

            if not Enemy:IsDescendantOf(workspace.Enemies) then
                table.remove(Targets, i)

                if Enemy == CurrentTarget then
                    CurrentTarget = nil
                end
            end
        end
    end)

    local NewScheduler = Scheduler.new(0.05)

    NewScheduler:Tick(function()
        if not Auto then
            return
        end

        if not CurrentTarget or not CurrentTarget:IsDescendantOf(workspace.Enemies) then
            CurrentTarget = Targets[1]
        end

        if not CurrentTarget then
            return
        end

        local Humanoid = CurrentTarget:FindFirstChildOfClass("Humanoid")

        if Humanoid and Humanoid.Health <= 0 then
            local Index = table.find(Targets, CurrentTarget)

            if Index then
                table.remove(Targets, Index)
            end

            CurrentTarget = nil
            return
        end

        local targetPivot = CurrentTarget:GetPivot()
        local targetRoot = CurrentTarget.HumanoidRootPart

        local position = (targetPivot * CFrame.new(0, -9, 0)).Position

        Client.Character:PivotTo(
            CFrame.lookAt(position, targetRoot.Position)
        )

        local root = Client.Character.HumanoidRootPart
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        Hit(CurrentTarget)
    end)

    NewMaid:GiveTask(TargetScheduler)
    NewMaid:GiveTask(NewScheduler)

    local Toggle = InputManager.new(Enum.KeyCode.R, function()
        Auto = not Auto
        workspace.Gravity = Auto and 0 or 196.2
        print(Auto)
    end)

    local ExitKeybind = InputManager.new(Enum.KeyCode.P, function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            InputManager:Exit()
            NewMaid:DoCleaning()
            DebugService:Debug("Exited Runtime")
        end
    end)

    NewScheduler:Start()
    TargetScheduler:Start()

    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.StartGUI.FlexHolder.PlayButton.MouseButton1Down)
    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.StartGUI.FlexHolder.PlayButton.MouseButton1Up)

    DebugService:Debug("Started Runtime")

    game:GetService("Players").LocalPlayer.PlayerGui.Victory.FlexHolder.ItemContainer.PlayButton:GetPropertyChangedSignal("Visible"):Connect(function()
        if game:GetService("Players").LocalPlayer.PlayerGui.Victory.FlexHolder.ItemContainer.PlayButton.Visible then
            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.Victory.FlexHolder.ItemContainer.PlayButton.MouseButton1Down)
            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.Victory.FlexHolder.ItemContainer.PlayButton.MouseButton1Up)
        end
    end)
end

queueonteleport([[

    loadstring(game:HttpGet("https://raw.githubusercontent.com/cy5n03t2ct4y3jc0tn8y5/Modules/refs/heads/main/Scr1.luau"))()

]])
