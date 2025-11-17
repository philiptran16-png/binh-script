--================================================--
--        WINDY UI AIMBOT - COMPLETE FIX         --
--================================================--

-- SERVICES (SAFE GET)
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local Players = GetService("Players")
local RunService = GetService("RunService")
local UIS = GetService("UserInputService")
local Lighting = GetService("Lighting")

if not Players or not RunService then
    warn("Essential services not available!")
    return
end

-- WAIT FOR LOCALPLAYER
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    wait(1)
    LocalPlayer = Players.LocalPlayer
end

-- SAFER GUI PARENT: Use PlayerGui instead of CoreGui
local PlayerGui = nil
pcall(function()
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
end)
if not PlayerGui then
    warn("PlayerGui not available, using CoreGui as fallback")
    PlayerGui = GetService("CoreGui")
end

local Camera = workspace.CurrentCamera
while not Camera do
    wait(1)
    Camera = workspace.CurrentCamera
end

-- EXECUTOR DETECTION (ULTRA SAFE)
local Executor = {
    Name = "Unknown",
    Supported = false
}

pcall(function()
    if type(identifyexecutor) == "function" then
        Executor.Name = identifyexecutor() or "Unknown"
        Executor.Supported = true
    elseif type(getexecutorname) == "function" then
        Executor.Name = getexecutorname() or "Unknown" 
        Executor.Supported = true
    elseif syn and type(syn.request) == "function" then
        Executor.Name = "Synapse X"
        Executor.Supported = true
    end
end)

warn("Executor: " .. Executor.Name)

-- CONFIGURATION
local Settings = {
    Enabled = false,
    KeyToggle = Enum.KeyCode.E,
    SmoothAmount = 0.2,
    FOVRadius = 150,
    AimPart = "Head",
    TeamCheck = true,
    AimMode = "Hold",
    
    ESPEnabled = false,
    BoxESP = false,
    Tracers = false,
    MaxDistance = 500
}

local PlayerSettings = {
    Speed = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    NoClip = false
}

-- STATE MANAGEMENT
local aimbotEnabled = false
local currentTarget = nil
local drawingObjects = {}
local connections = {}
local ESPObjects = {}
local isRunning = true
local lastESPCheck = 0
local ESP_UPDATE_RATE = 0.1 -- 10 FPS for ESP

-- SAFE DRAWING INIT
local fovCircle, targetCircle = nil, nil
if Drawing then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Radius = Settings.FOVRadius
        fovCircle.Color = Color3.new(0, 1, 0)
        fovCircle.Thickness = 2
        fovCircle.Filled = false
        fovCircle.Visible = true
        
        targetCircle = Drawing.new("Circle") 
        targetCircle.Radius = 8
        targetCircle.Color = Color3.new(1, 0, 0)
        targetCircle.Thickness = 3
        targetCircle.Filled = false
        targetCircle.Visible = false
        
        table.insert(drawingObjects, fovCircle)
        table.insert(drawingObjects, targetCircle)
    end)
else
    warn("Drawing library not available!")
end

-- PLAYER VALIDATION
local function isValidPlayer(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    return true
end

-- ESP CREATION FUNCTION
local function createESP(player)
    if not Drawing or not Settings.ESPEnabled then return end
    
    -- Don't create ESP for local player
    if player == LocalPlayer then return end
    
    local esp = {
        Box = nil,
        Tracer = nil
    }
    
    pcall(function()
        if Settings.BoxESP then
            esp.Box = Drawing.new("Square")
            esp.Box.Thickness = 2
            esp.Box.Filled = false
            esp.Box.Color = Color3.new(1, 1, 1)
            esp.Box.Visible = false
        end
        
        if Settings.Tracers then
            esp.Tracer = Drawing.new("Line")
            esp.Tracer.Thickness = 1
            esp.Tracer.Color = Color3.new(1, 1, 1)
            esp.Tracer.Visible = false
        end
    end)
    
    ESPObjects[player] = esp
end

-- CLEAR ESP FUNCTION (WAS MISSING)
local function clearESP()
    for player, esp in pairs(ESPObjects) do
        for _, drawing in pairs(esp) do
            if drawing and drawing.Remove then
                pcall(function() 
                    drawing.Visible = false
                    drawing:Remove() 
                end)
            end
        end
    end
    ESPObjects = {}
end

-- INITIALIZE ESP FOR EXISTING PLAYERS
local function initializeESP()
    clearESP() -- Clear existing ESP first
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
end

-- IMPROVED FOV/TARGET SELECTION LOGIC
local function getBestTarget()
    local bestTarget = nil
    local shortestDistance = Settings.FOVRadius -- Enforce maximum FOV radius
    local mousePosition = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if isValidPlayer(player) then
            -- Team check with goto (Lua doesn't have continue)
            if Settings.TeamCheck and LocalPlayer.Team and player.Team then
                if LocalPlayer.Team == player.Team then
                    goto continue
                end
            end
            
            local character = player.Character
            local targetPart = character:FindFirstChild(Settings.AimPart) or 
                             character:FindFirstChild("Head") or 
                             character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local targetPos = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distance = (mousePosition - targetPos).Magnitude
                    
                    -- Enforce FOV radius and select closest target
                    if distance <= shortestDistance and distance <= Settings.FOVRadius then
                        shortestDistance = distance
                        bestTarget = targetPart
                    end
                end
            end
            
            ::continue::
        end
    end
    
    return bestTarget
end

-- AIMBOT FUNCTION
local function aimAtTarget(targetPart)
    if not targetPart or not Camera then return end
    
    local cameraPosition = Camera.CFrame.Position
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(cameraPosition, targetPart.Position)
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.SmoothAmount)
end

-- OPTIMIZED ESP SYSTEM
local function cleanupDeadESP()
    for player, esp in pairs(ESPObjects) do
        if not Players:FindFirstChild(player.Name) then
            -- Player left the game, cleanup ESP
            for _, drawing in pairs(esp) do
                if drawing and drawing.Remove then
                    pcall(function() 
                        drawing.Visible = false
                        drawing:Remove() 
                    end)
                end
            end
            ESPObjects[player] = nil
        end
    end
end

local function updateESP()
    if not Settings.ESPEnabled then return end
    
    -- Rate limiting for performance
    local currentTime = tick()
    if currentTime - lastESPCheck < ESP_UPDATE_RATE then
        return
    end
    lastESPCheck = currentTime
    
    -- Clean dead ESP first
    cleanupDeadESP()
    
    for player, esp in pairs(ESPObjects) do
        if isValidPlayer(player) then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                
                if onScreen and distance <= Settings.MaxDistance then
                    -- Box ESP with defensive checks
                    if esp.Box and Settings.BoxESP then
                        pcall(function()
                            local head = character:FindFirstChild("Head")
                            if head and Camera then
                                local headPosition = Camera:WorldToViewportPoint(head.Position)
                                local size = Vector2.new(
                                    2000 / math.max(screenPosition.Z, 0.1), 
                                    3000 / math.max(screenPosition.Z, 0.1)
                                )
                                
                                esp.Box.Position = Vector2.new(headPosition.X - size.X/2, headPosition.Y - size.Y/2)
                                esp.Box.Size = size
                                esp.Box.Visible = true
                            end
                        end)
                    end
                    
                    -- Tracer with defensive checks
                    if esp.Tracer and Settings.Tracers then
                        pcall(function()
                            if Camera then
                                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                esp.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                                esp.Tracer.Visible = true
                            end
                        end)
                    end
                else
                    -- Hide off-screen ESP
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Tracer then esp.Tracer.Visible = false end
                end
            else
                -- Hide if no root part
                if esp.Box then esp.Box.Visible = false end
                if esp.Tracer then esp.Tracer.Visible = false end
            end
        else
            -- Hide invalid player ESP
            if esp.Box then esp.Box.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
        end
    end
end

-- MOVEMENT SYSTEMS
local flyConnection = nil
local flyBodyVelocity = nil

local function toggleFly(enabled)
    -- Cleanup existing
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyVelocity then
        pcall(function() flyBodyVelocity:Destroy() end)
        flyBodyVelocity = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character.Parent then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and Camera then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBodyVelocity.Parent = humanoidRootPart
                
                flyConnection = RunService.Heartbeat:Connect(function()
                    if not isRunning or not character.Parent or not flyBodyVelocity or not Camera then
                        toggleFly(false)
                        return
                    end
                    
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
                end)
            end
        end
    end
end

-- PLAYER MANAGEMENT
connections.playerAdded = Players.PlayerAdded:Connect(function(player)
    wait(1) -- Wait for player to fully load
    if Settings.ESPEnabled and player ~= LocalPlayer then
        createESP(player)
    end
end)

connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            if drawing then
                pcall(function() 
                    drawing.Visible = false
                    drawing:Remove() 
                end)
            end
        end
        ESPObjects[player] = nil
    end
end)

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
connections.mainLoop = RunService.Heartbeat:Connect(function()
    if not isRunning then return end
    
    -- FOV Circle update with defensive checks
    if fovCircle then
        pcall(function()
            local mousePos = UIS:GetMouseLocation()
            fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        end)
    end
    
    -- ESP update (rate limited)
    updateESP()
    
    -- Aimbot logic (gated by Settings.Enabled and aimbotEnabled)
    if aimbotEnabled and Settings.Enabled then
        currentTarget = getBestTarget()
        
        if currentTarget then
            -- Update target indicator with defensive checks
            if targetCircle then
                pcall(function()
                    local screenPos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
                    if onScreen then
                        targetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                        targetCircle.Visible = true
                    else
                        targetCircle.Visible = false
                    end
                end)
            end
            
            aimAtTarget(currentTarget)
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

-- SIMPLE UI CREATION WITH SAFER PARENT
local function CreateSimpleUI()
    local SimpleUI = Instance.new("ScreenGui")
    SimpleUI.Name = "WindyAimbot_" .. tostring(math.random(1, 10000))
    
    -- Use PlayerGui instead of CoreGui for better compatibility
    pcall(function()
        SimpleUI.Parent = PlayerGui
    end)
    
    -- Fallback if PlayerGui failed
    if not SimpleUI.Parent then
        warn("Failed to parent to PlayerGui, using CoreGui fallback")
        SimpleUI.Parent = GetService("CoreGui")
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
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
    
    local yPosition = 0.1
    
    local function createToggle(text, settingTable, settingKey, callback)
        local button = Instance.new("TextButton")
        button.Text = text .. ": OFF"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Size = UDim2.new(0.8, 0, 0, 35)
        button.Position = UDim2.new(0.1, 0, yPosition, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        button.Parent = MainFrame
        
        button.MouseButton1Click:Connect(function()
            settingTable[settingKey] = not settingTable[settingKey]
            button.Text = text .. ": " .. (settingTable[settingKey] and "ON" or "OFF")
            button.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 70)
            if callback then
                callback(settingTable[settingKey])
            end
        end)
        
        yPosition = yPosition + 0.1
        return button
    end
    
    -- Create toggles
    createToggle("Aimbot", Settings, "Enabled")
    createToggle("ESP", Settings, "ESPEnabled", function(value)
        if value then
            initializeESP()
        else
            clearESP() -- Use the proper clearESP function
        end
    end)
    createToggle("Box ESP", Settings, "BoxESP", function(value)
        if Settings.ESPEnabled then
            clearESP()
            initializeESP()
        end
    end)
    createToggle("Tracers", Settings, "Tracers", function(value)
        if Settings.ESPEnabled then
            clearESP()
            initializeESP()
        end
    end)
    createToggle("Fly", PlayerSettings, "FlyEnabled", toggleFly)
    
    -- Unload button
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Text = "UNLOAD (END)"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadBtn.TextSize = 14
    unloadBtn.Size = UDim2.new(0.8, 0, 0, 35)
    unloadBtn.Position = UDim2.new(0.1, 0, 0.85, 0)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    unloadBtn.Parent = MainFrame
    
    unloadBtn.MouseButton1Click:Connect(function()
        isRunning = false
        cleanup()
        pcall(function() SimpleUI:Destroy() end)
    end)
    
    return SimpleUI
end

-- Initialize ESP if enabled
if Settings.ESPEnabled then
    initializeESP()
end

-- Create UI
local SimpleUI = CreateSimpleUI()

-- COMPREHENSIVE CLEANUP FUNCTION
local function cleanup()
    isRunning = false
    
    warn("Starting cleanup process...")
    
    -- Disconnect all connections
    for name, connection in pairs(connections) do
        if connection then
            pcall(function() 
                connection:Disconnect() 
            end)
        end
    end
    connections = {}
    
    -- Cleanup fly system
    toggleFly(false)
    
    -- Cleanup drawings
    for _, drawing in pairs(drawingObjects) do
        if drawing and drawing.Remove then
            pcall(function() 
                drawing.Visible = false
                drawing:Remove() 
            end)
        end
    end
    drawingObjects = {}
    
    -- Cleanup ESP objects
    clearESP()
    
    -- Reset player movement
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = 16
            end)
        end
    end
    
    -- Cleanup UI
    if SimpleUI then
        pcall(function() 
            SimpleUI:Destroy() 
        end)
    end
    
    warn("Windy Aimbot - Cleaned up successfully!")
end

-- UNLOAD BIND
connections.unloadInput = UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.End then
        cleanup()
    end
end)

-- AUTO-CLEANUP ON PLAYER LEAVE
connections.playerRemovingMain = Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

warn("Windy Aimbot - COMPLETE FIXED Version Loaded!")
warn("Executor: " .. Executor.Name)
warn("Press END to unload")
warn("GUI Parent: " .. tostring(SimpleUI and SimpleUI.Parent and SimpleUI.Parent.ClassName or "None"))
