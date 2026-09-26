local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Client = Players.LocalPlayer
local Maid = shared.Maid
local InputManager = shared.InputManager
local DebugService = shared.DebugService

local Gui = {}

Gui.Maid = Maid.new()

local function Create(type, parent, properties)
    local new = Instance.new(type)
    new.Parent = parent

    for i, property in next, properties do
        new[i] = property
    end

    return new
end

local function CreateGui(title)
    if Client.PlayerGui:FindFirstChild("EntityUI") then
        Client.PlayerGui:FindFirstChild("EntityUI"):Destroy()
    end

    local EntityUI = Create("ScreenGui", Client.PlayerGui, {
        Name = "EntityUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local Health = Create("Frame", EntityUI, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 1,
        Size = UDim2.new(0.260417, 0, 0.0231696, 0),
        Name = "Health",
        Position = UDim2.new(0.135227, 0, 0.930556, 0),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0
    })

    local EntityName = Create("TextLabel", Health, {
        TextTransparency = 0,
        AnchorPoint = Vector2.new(0.5, 1),
        ZIndex = 3,
        TextSize = 16,
        Size = UDim2.new(1, 0, 1, 0),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = title,
        Font = Enum.Font.RobotoMono,
        Name = "EntityName",
        Position = UDim2.new(0.5, 0, 2.1, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })

    local HealthText = Create("TextLabel", Health, {
        TextTransparency = 0,
        AnchorPoint = Vector2.new(0.5, 1),
        ZIndex = 3,
        TextSize = 16,
        Size = UDim2.new(1, 0, 1, 0),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "100/100",
        Font = Enum.Font.RobotoMono,
        Name = "Health",
        Position = UDim2.new(0.5, 0, 2.1, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Right,
        BorderSizePixel = 0
    })

    local Bar = Create("Frame", Health, {
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 2,
        Size = UDim2.new(1, 0, 1, 0),
        Name = "Bar",
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })

    Create("UIStroke", Health, {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 0,
        Name = "UIStroke",
        LineJoinMode = Enum.LineJoinMode.Round,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    local Main = Create("Frame", EntityUI, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 1,
        Size = UDim2.new(0.989583, 0, 0.901348, 0),
        Name = "Main",
        Position = UDim2.new(0.5, 0, 0.459942, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })

    Create("UIListLayout", Main, {
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Name = "UIListLayout",
        Padding = UDim.new(0.008, 0)
    })

    local function UpdateHealth()
        local Character = Client.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if not Humanoid then
            return
        end

        local Value = Humanoid.MaxHealth > 0 and Humanoid.Health / Humanoid.MaxHealth or 0

        HealthText.Text = math.floor(Humanoid.Health) .. "/" .. math.floor(Humanoid.MaxHealth)

        TweenService:Create(Bar, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(Value, 1)
        }):Play()
    end

    local Character = Client.Character or Client.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    Gui.Maid:GiveTask(Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHealth))
    Gui.Maid:GiveTask(Humanoid:GetPropertyChangedSignal("Health"):Connect(UpdateHealth))

    Gui.Maid:GiveTask(Client.CharacterAdded:Connect(function(NewCharacter)
        Humanoid = NewCharacter:WaitForChild("Humanoid")

        Gui.Maid:GiveTask(Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHealth))
        Gui.Maid:GiveTask(Humanoid:GetPropertyChangedSignal("Health"):Connect(UpdateHealth))

        UpdateHealth()
    end))

    UpdateHealth()

    return EntityUI
end

function Gui.new(title)

    local ScreenGui = CreateGui(title)
    local UI = {}

    InputManager.new(Enum.KeyCode.LeftBracket, function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            ScreenGui.Enabled = not ScreenGui.Enabled
            Client.PlayerGui.MainUI.TopFrame.Visible = not Client.PlayerGui.MainUI.TopFrame.Visible
            Client.PlayerGui.Inventory.MainFrame.StatsFrame.Visible = not Client.PlayerGui.Inventory.MainFrame.StatsFrame.Visible
            Client.PlayerGui.Inventory.MainFrame.Weight.Visible = not Client.PlayerGui.Inventory.MainFrame.Weight.Visible
        end
    end)

    Client.PlayerGui.MainUI.TopFrame.Visible = false
    Client.PlayerGui.Inventory.MainFrame.StatsFrame.Visible = false
    Client.PlayerGui.Inventory.MainFrame.Weight.Visible = false

    local ExitKeybind = InputManager.new(Enum.KeyCode.P, function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            InputManager:Exit()
            Gui.Maid:DoCleaning()
            ScreenGui:Destroy()
            DebugService:Debug("Exited Runtime")

        Client.PlayerGui.MainUI.TopFrame.Visible = Client.PlayerGui.Inventory.Enabled
        Client.PlayerGui.Inventory.MainFrame.StatsFrame.Visible = Client.PlayerGui.Inventory.Enabled
        Client.PlayerGui.Inventory.MainFrame.Weight.Visible = Client.PlayerGui.Inventory.Enabled
        end
    end)

    function UI.Button(Key, desc, Callback)
        local Main = ScreenGui:FindFirstChild("Main")

        local Template = Create("Frame", Main, {
            AnchorPoint = Vector2.new(0, 0),
            ZIndex = 1,
            Size = UDim2.new(1, 0, 0.04, 0),
            Name = "Template",
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        })

        local Button = Create("TextLabel", Template, {
            TextTransparency = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 1,
            TextSize = 20,
            Size = UDim2.new(0.02, 0, 1, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = Key,
            Font = Enum.Font.RobotoMono,
            Name = "Button",
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 0.5,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0
        })

        Create("UIStroke", Button, {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 2,
            Transparency = 0,
            Name = "UIStroke",
            LineJoinMode = Enum.LineJoinMode.Round,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        local Desc = Create("TextLabel", Template, {
            TextTransparency = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 1,
            TextSize = 18,
            Size = UDim2.new(0.95, 0, 1, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = " - ".. desc,
            Font = Enum.Font.RobotoMono,
            Name = "Desc",
            Position = UDim2.new(0.025, 0, 0.5, 0),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local Connection = InputManager.new(Enum.KeyCode[Key], Callback)

        Gui.Maid:GiveTask(Connection)

        return Template
    end

    return UI
end

return Gui
