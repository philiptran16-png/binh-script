local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", PlayerGui)

-- Table to store button information and their corresponding functions
local toggles = {
    {"Devil Fruit Spawn Notifier", UDim2.new(0, 0, 0.1, 0), notifyDevilFruit},
    {"Auto Farm", UDim2.new(0, 0, 0.2, 0), autoFarm},
    {"ESP Fruits / ESP Boss", UDim2.new(0, 0, 0.3, 0), esp},
    {"Bypass Anti Cheat", UDim2.new(0, 0, 0.4, 0), bypassAntiCheat},
    {"Auto Collect Fruit", UDim2.new(0, 0, 0.5, 0), autoCollectFruit},
    {"Auto Server Hop", UDim2.new(0, 0, 0.6, 0), autoServerHop},
}

-- Function to create toggle buttons
local function createToggle(toggle)
    local ToggleFrame = Instance.new("Frame", ScreenGui)
    ToggleFrame.Size = UDim2.new(1, 0, 0.1, 0)
    ToggleFrame.Position = toggle[2]
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

    local ToggleButton = Instance.new("TextButton", ToggleFrame)
    ToggleButton.Size = UDim2.new(0.8, 0, 1, 0)
    ToggleButton.Text = toggle[1]
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    return ToggleButton
end

-- Create buttons and connect their functions
for _, toggle in pairs(toggles) do
    local ToggleButton = createToggle(toggle)
    ToggleButton.MouseButton1Click:Connect(function()
        toggle[3]()
        checkToggle(toggle)
    end)
end

-- Function to check the status of each toggle
local function checkToggle(toggle)
    local isActive = toggle[3]() -- Ensure this function returns a boolean
    print(isActive and "Function is active..." or "Function is inactive...")
end

-- Function to check inventory before collecting fruit
local function checkInventory()
    local inventory = Player.Backpack
    local items = inventory:GetChildren()

    for _, item in pairs(items) do
        if item:IsA("Tool") then
            print("You already have this tool in your inventory!")
            return false
        end
    end

    print("You can collect fruit!")
    return true
end

-- Function to collect fruit
local function collectFruit()
    if checkInventory() then
        print("Collecting fruit...")
        -- Code to collect fruit
    else
        print("Cannot collect fruit!")
    end
end

-- Function to auto collect fruit
local function autoCollectFruit()
    collectFruit()
end

-- Function to notify about devil fruit
local function notifyDevilFruit()
    print("Notify devil fruit...")
    return true -- Ensure it returns a boolean
end

-- Function to auto farm
local function autoFarm()
    print("Auto farm...")
    return true -- Ensure it returns a boolean
end

-- Function for ESP fruits / ESP boss
local function esp()
    print("ESP fruits / ESP boss...")
    return true -- Ensure it returns a boolean
end

-- Function to bypass anti-cheat
local function bypassAntiCheat()
    print("Bypass anti-cheat...")
    return true -- Ensure it returns a boolean
end

-- Function to auto server hop
local function autoServerHop()
    print("Auto server hop...")
    return true -- Ensure it returns a boolean
end
