local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Maid = shared.Maid

local InputManager = {}
InputManager.__index = InputManager

InputManager.Inputs = {}
InputManager.MouseInputs = {}
InputManager.Maid = Maid.new()

function InputManager.new(Keycode, callback)
    local self = setmetatable({}, InputManager)
    
    self.Keycode = Keycode
    self.Callback = callback
    self.Active = true
    self.Type = "Key"
    
    InputManager.Maid:GiveTask(self)
    
    table.insert(InputManager.Inputs, self)
    
    return self
end

function InputManager.MouseClick(callback, button)
    local self = setmetatable({}, InputManager)
    
    self.Button = button or Enum.UserInputType.MouseButton1
    self.Callback = callback
    self.Active = true
    self.Type = "Mouse"
    
    InputManager.Maid:GiveTask(self)
    
    table.insert(InputManager.MouseInputs, self)
    
    return self
end

InputManager.MouseButton = {
    Left = Enum.UserInputType.MouseButton1,
    Right = Enum.UserInputType.MouseButton2,
    Middle = Enum.UserInputType.MouseButton3
}

function InputManager:Bind()
    self.Active = true
    return self
end

function InputManager:Unbind()
    self.Active = false
    return self
end

function InputManager:Toggle()
    self.Active = not self.Active
    return self
end

function InputManager:Destroy()
    if self.Type == "Key" then
        for i, input in ipairs(InputManager.Inputs) do
            if input == self then
                table.remove(InputManager.Inputs, i)
                break
            end
        end
    elseif self.Type == "Mouse" then
        for i, input in ipairs(InputManager.MouseInputs) do
            if input == self then
                table.remove(InputManager.MouseInputs, i)
                break
            end
        end
    end
    self.Active = false
end

function InputManager:Exit()
    InputManager.Maid:Destroy()
    table.clear(InputManager.Inputs)
    table.clear(InputManager.MouseInputs)
    InputManager.Maid = Maid.new()

    InputManager.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for _, binding in ipairs(InputManager.Inputs) do
            if binding.Active and input.KeyCode == binding.Keycode then
                binding.Callback()
            end
        end
    end))
    
    InputManager.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for _, binding in ipairs(InputManager.MouseInputs) do
            if binding.Active and input.UserInputType == binding.Button then
                binding.Callback()
            end
        end
    end))
end

InputManager.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, binding in ipairs(InputManager.Inputs) do
        if binding.Active and input.KeyCode == binding.Keycode then
            binding.Callback()
        end
    end
end))

InputManager.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, binding in ipairs(InputManager.MouseInputs) do
        if binding.Active and input.UserInputType == binding.Button then
            binding.Callback()
        end
    end
end))

return InputManager
