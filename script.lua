--================================================--
--        WINDY UI AIMBOT EXECUTOR PRO           --
--================================================--

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualInput = game:GetService("VirtualInputManager")
local Mouse = LocalPlayer:GetMouse()

-- EXECUTOR DETECTION
local Executor = {
    Name = identifyexecutor and identifyexecutor() or "Unknown",
    Supported = (syn and true) or (getexecutorname and true) or false
}

-- LOAD WINDUI (Executor Safe)
local WindUI
local WindUILoaded = false

local function SafeLoadWindUI()
    local success, result = pcall(function()
        -- Try multiple methods to load WindUI
        local sources = {
            "https://raw.githubusercontent.com/Footagesus/WindUI/main/src/main.lua",
            "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
        }
        
        for _, url in pairs(sources) do
            local content
            if syn then
                content = syn.request({Url = url, Method = "GET"}).Body
            elseif request then
                content = request({Url = url, Method = "GET"}).Body
            else
                content = game:HttpGet(url)
            end
            
            if content and #content > 1000 then
                return loadstring(content)()
            end
        end
        error("Failed to load WindUI from any source")
    end)
    
    if success then
        WindUILoaded = true
        return result
    else
        -- Fallback to simple UI
        warn("WindUI failed to load: " .. tostring(result))
        return nil
    end
end

WindUI = SafeLoadWindUI()

-- CONFIGURATION
local Settings = {
    KeyToggle = Enum.KeyCode.E,
    SmoothAmount = 0.2,
    FOVRadius = 150,
    AimPart = "Head",
    Enabled = false,
    TeamCheck = true,
    WallCheck = false, -- Disabled by default for performance
    Prediction = 0.1,
    AutoShoot = false,
    SilentAim = false,
    Triggerbot = false,
    FOVVisible = true,
    ShowTarget = true,
    MaxDistance = 1000,
    Humanizer = false,
    HumanizerIntensity = 0.3,
    AimMode = "Hold",
    Priority = "Closest"
}

-- PLAYER SETTINGS
local PlayerSettings = {
    Speed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    FlySpeed = 50,
    InfiniteJump = false,
    NoClip = false,
    Xray = false,
    Fullbright = false,
    AntiAfk = false
}

-- STATE VARIABLES
local aimbotEnabled = false
local currentTarget = nil
local selectedPlayer = nil
local drawingObjects = {}
local connections = {}

-- Drawing objects
local fovCircle, targetCircle

-- Initialize Drawing Objects (Executor Safe)
local function initializeDrawings()
    if not Drawing then
        warn("Drawing library not available")
        return nil, nil
    end
    
    local success, result = pcall(function()
        local fov = Drawing.new("Circle")
        fov.Radius = Settings.FOVRadius
        fov.Color = Color3.fromRGB(0, 255, 0)
        fov.Thickness = 2
        fov.Filled = false
        fov.Visible = Settings.FOVVisible
        
        local target = Drawing.new("Circle")
        target.Radius = 10
        target.Color = Color3.fromRGB(255, 0, 0)
        target.Thickness = 3
        target.Filled = false
        target.Visible = false
        
        table.insert(drawingObjects, fov)
        table.insert(drawingObjects, target)
        
        return fov, target
    end)
    
    if success then
        return result
    else
        warn("Failed to initialize drawings: " .. tostring(result))
        return nil, nil
    end
end

-- Create Simple UI if WindUI fails
local function CreateSimpleUI()
    local SimpleUI = Instance.new("ScreenGui")
    SimpleUI.Name = "WindyAimbotSimpleUI"
    SimpleUI.Parent = GuiService
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = SimpleUI
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Text = "Windy Aimbot Pro"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame
    
    -- Simple toggle for aimbot
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Text = "Aimbot: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14
    ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleBtn.Parent = MainFrame
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        ToggleBtn.Text = "Aimbot: " .. (Settings.Enabled and "ON" or "OFF")
        ToggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 70)
    end)
    
    return SimpleUI
end

-- Initialize UI
local Window
if WindUI then
    Window = WindUI:CreateWindow({
        Title = "Windy Aimbot Pro",
        SubTitle = "Executor Optimized",
        Size = UDim2.new(0, 450, 0, 550),
        Theme = "Dark",
        Acrylic = false
    })
else
    CreateSimpleUI()
end

-- AIMBOT FUNCTIONS
local function isEnemy(player)
    if not Settings.TeamCheck then return true end
    
    local localTeam = LocalPlayer.Team
    local targetTeam = player.Team
    
    if not localTeam or not targetTeam then return true end
    return localTeam ~= targetTeam
end

local function getBestTarget()
    local bestTarget = nil
    local shortestDist = Settings.FOVRadius
    local mousePos = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isEnemy(player) then
            local character = player.Character
            local targetPart = character:FindFirstChild(Settings.AimPart)
            
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (mousePos - targetPos).Magnitude
                    
                    if dist <= shortestDist then
                        shortestDist = dist
                        bestTarget = targetPart
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- MOVEMENT FUNCTIONS
local function updateMovement()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = PlayerSettings.Speed
            humanoid.JumpPower = PlayerSettings.JumpPower
        end
    end
end

local flyBodyVelocity
local function toggleFly(enabled)
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBodyVelocity.Parent = humanoidRootPart
                
                connections.fly = RunService.Heartbeat:Connect(function()
                    if character and humanoidRootPart and flyBodyVelocity then
                        local moveDirection = Vector3.new(0, 0, 0)
                        
                        if UIS:IsKeyDown(Enum.KeyCode.W) then
                            moveDirection = moveDirection + Camera.CFrame.LookVector
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then
                            moveDirection = moveDirection - Camera.CFrame.LookVector
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then
                            moveDirection = moveDirection - Camera.CFrame.RightVector
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then
                            moveDirection = moveDirection + Camera.CFrame.RightVector
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                        
                        flyBodyVelocity.Velocity = moveDirection * PlayerSettings.FlySpeed
                    end
                end)
            end
        end
    elseif connections.fly then
        connections.fly:Disconnect()
        connections.fly = nil
    end
end

local function toggleNoclip(enabled)
    if connections.noclip then
        connections.noclip:Disconnect()
        connections.noclip = nil
    end
    
    if enabled then
        connections.noclip = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- VISUAL FUNCTIONS
local function toggleXray(enabled)
    if enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
                obj.LocalTransparencyModifier = 0.5
            end
        end
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end

local function toggleFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end

-- CREATE UI IF WINDUI LOADED
if Window then
    -- Main Tab
    local MainTab = Window:Tab({
        Title = "Aimbot",
        Icon = "crosshair"
    })

    local AimbotSection = MainTab:Section({
        Title = "Aimbot Settings",
        Box = true
    })

    AimbotSection:Toggle({
        Title = "Enable Aimbot",
        Value = Settings.Enabled,
        Callback = function(value)
            Settings.Enabled = value
        end
    })

    AimbotSection:Keybind({
        Title = "Aim Key",
        Value = "E",
        Callback = function(key)
            Settings.KeyToggle = Enum.KeyCode[key]
        end
    })

    AimbotSection:Slider({
        Title = "Smoothness",
        Desc = "Lower = Faster Aim",
        Value = {Default = Settings.SmoothAmount * 100, Min = 1, Max = 100},
        Callback = function(value)
            Settings.SmoothAmount = value / 100
        end
    })

    AimbotSection:Slider({
        Title = "FOV Radius",
        Desc = "Detection Range",
        Value = {Default = Settings.FOVRadius, Min = 10, Max = 500},
        Callback = function(value)
            Settings.FOVRadius = value
            if fovCircle then
                fovCircle.Radius = value
            end
        end
    })

    -- Player Tab
    local PlayerTab = Window:Tab({
        Title = "Player",
        Icon = "user"
    })

    local MovementSection = PlayerTab:Section({
        Title = "Movement",
        Box = true
    })

    MovementSection:Slider({
        Title = "WalkSpeed",
        Desc = "Movement Speed",
        Value = {Default = PlayerSettings.Speed, Min = 16, Max = 200},
        Callback = function(value)
            PlayerSettings.Speed = value
            updateMovement()
        end
    })

    MovementSection:Slider({
        Title = "Jump Power",
        Desc = "Jump Height",
        Value = {Default = PlayerSettings.JumpPower, Min = 50, Max = 200},
        Callback = function(value)
            PlayerSettings.JumpPower = value
            updateMovement()
        end
    })

    MovementSection:Toggle({
        Title = "Fly Mode",
        Desc = "Enable Flying",
        Value = PlayerSettings.FlyEnabled,
        Callback = function(value)
            PlayerSettings.FlyEnabled = value
            toggleFly(value)
        end
    })

    MovementSection:Toggle({
        Title = "NoClip",
        Desc = "Walk Through Walls",
        Value = PlayerSettings.NoClip,
        Callback = function(value)
            PlayerSettings.NoClip = value
            toggleNoclip(value)
        end
    })

    local VisualSection = PlayerTab:Section({
        Title = "Visual",
        Box = true
    })

    VisualSection:Toggle({
        Title = "X-Ray",
        Desc = "See Through Walls",
        Value = PlayerSettings.Xray,
        Callback = function(value)
            PlayerSettings.Xray = value
            toggleXray(value)
        end
    })

    VisualSection:Toggle({
        Title = "Fullbright",
        Desc = "Maximum Brightness",
        Value = PlayerSettings.Fullbright,
        Callback = function(value)
            PlayerSettings.Fullbright = value
            toggleFullbright(value)
        end
    })

    -- Config Tab
    local ConfigTab = Window:Tab({
        Title = "Config",
        Icon = "settings"
    })

    local ConfigSection = ConfigTab:Section({
        Title = "Configuration",
        Box = true
    })

    ConfigSection:Button({
        Title = "Unload Script",
        Icon = "power",
        Callback = function()
            -- Cleanup function
            for _, connection in pairs(connections) do
                connection:Disconnect()
            end
            if flyBodyVelocity then
                flyBodyVelocity:Destroy()
            end
            for _, drawing in pairs(drawingObjects) do
                pcall(function() drawing:Remove() end)
            end
            if Window then
                Window:Destroy()
            end
        end
    })
end

-- INPUT HANDLING
connections.inputBegan = UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.KeyToggle then
        if Settings.AimMode == "Toggle" then
            aimbotEnabled = not aimbotEnabled
        elseif Settings.AimMode == "Hold" then
            aimbotEnabled = true
        end
    end
end)

connections.inputEnded = UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.KeyToggle and Settings.AimMode == "Hold" then
        aimbotEnabled = false
        currentTarget = nil
        if targetCircle then
            targetCircle.Visible = false
        end
    end
end)

-- MAIN LOOP
connections.renderStepped = RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if fovCircle then
        local mousePos = UIS:GetMouseLocation()
        fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
    
    -- Aimbot logic
    if aimbotEnabled and Settings.Enabled then
        currentTarget = getBestTarget()
        
        if currentTarget then
            -- Update target indicator
            if targetCircle then
                local screenPos = Camera:WorldToViewportPoint(currentTarget.Position)
                targetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                targetCircle.Visible = true
            end
            
            -- Smooth aiming
            local camPos = Camera.CFrame.Position
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(camPos, currentTarget.Position)
            
            Camera.CFrame = currentCF:Lerp(targetCF, Settings.SmoothAmount)
        else
            if targetCircle then
                targetCircle.Visible = false
            end
        end
    else
        if targetCircle then
            targetCircle.Visible = false
        end
    end
end)

-- INITIALIZATION
fovCircle, targetCircle = initializeDrawings()

-- Auto movement update on respawn
connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    updateMovement()
    if PlayerSettings.FlyEnabled then
        toggleFly(true)
    end
    if PlayerSettings.NoClip then
        toggleNoclip(true)
    end
end)

-- Initial movement setup
updateMovement()

-- Success message
if Window then
    Window:Notify({
        Title = "Windy Aimbot Pro Loaded",
        Content = "Executor optimized version ready!",
        Icon = "rocket",
        Duration = 5
    })
else
    warn("Windy Aimbot Pro - Simple UI Loaded")
end

-- Auto-cleanup on script termination
connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        for _, drawing in pairs(drawingObjects) do
            pcall(function() drawing:Remove() end)
        end
    end
end)
