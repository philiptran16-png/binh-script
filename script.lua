-- Load WindUI
local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    end
end

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GameSettings = UserSettings():GetService("UserGameSettings")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Config mặc định tắt tất cả
local ESPEnabled, ESPTeamCheck, ESPWallCheck, ESPDistance = false, false, false, 200
local AimEnabled, AimTeamCheck, AimWallCheck, AimDistance, SmoothStrength = false, false, false, 200, 0.25
local FlyEnabled, NoclipEnabled, RadarEnabled, AntiFlingEnabled = false, false, false, false

-- New Features Config
local PerformanceEnabled, AutoFPSBoost, MemoryCleaner, NetworkOptimizer, RenderDistanceManager = false, false, false, false, false
local ShowEnemyFOV, PatrolRoutePrediction, SoundVisualization, ObjectiveTracker = false, false, false, false
local CurrentTheme = "Default"
local Themes = {
    Default = {
        Primary = Color3.fromHex("#30FF6A"),
        Secondary = Color3.fromHex("#e7ff2f"),
        Background = Color3.fromHex("#1a1a1a"),
        Text = Color3.fromHex("#ffffff")
    },
    Dark = {
        Primary = Color3.fromHex("#FF6B35"),
        Secondary = Color3.fromHex("#FFE66D"),
        Background = Color3.fromHex("#0a0a0a"),
        Text = Color3.fromHex("#f0f0f0")
    },
    Blue = {
        Primary = Color3.fromHex("#4A90E2"),
        Secondary = Color3.fromHex("#7ED321"),
        Background = Color3.fromHex("#0f1f33"),
        Text = Color3.fromHex("#e6f7ff")
    },
    Pink = {
        Primary = Color3.fromHex("#FF6B9D"),
        Secondary = Color3.fromHex("#FFE74C"),
        Background = Color3.fromHex("#2d1a2d"),
        Text = Color3.fromHex("#fff0f5")
    }
}

local config = {
    ESPEnabled = ESPEnabled,
    ESPTeamCheck = ESPTeamCheck,
    ESPWallCheck = ESPWallCheck,
    ESPDistance = ESPDistance,
    AimEnabled = AimEnabled,
    AimTeamCheck = AimTeamCheck,
    AimWallCheck = AimWallCheck,
    AimDistance = AimDistance,
    SmoothStrength = SmoothStrength,
    FlyEnabled = FlyEnabled,
    NoclipEnabled = NoclipEnabled,
    RadarEnabled = RadarEnabled,
    AntiFlingEnabled = AntiFlingEnabled,
    PerformanceEnabled = PerformanceEnabled,
    AutoFPSBoost = AutoFPSBoost,
    MemoryCleaner = MemoryCleaner,
    NetworkOptimizer = NetworkOptimizer,
    RenderDistanceManager = RenderDistanceManager,
    ShowEnemyFOV = ShowEnemyFOV,
    PatrolRoutePrediction = PatrolRoutePrediction,
    SoundVisualization = SoundVisualization,
    ObjectiveTracker = ObjectiveTracker,
    CurrentTheme = CurrentTheme
}

local CONFIG_FILE = "binh_hub_config.json"

-- Performance Optimizer System
local performanceConnection
local originalSettings = {}

local function saveOriginalSettings()
    originalSettings.GraphicsQualityLevel = GameSettings.SavedQualityLevel.Value
    originalSettings.MasterVolume = GameSettings.MasterVolume
    originalSettings.RenderingDistance = Camera.MaxDistance
end

local function applyPerformanceOptimizations()
    if AutoFPSBoost then
        -- Reduce graphics quality
        settings().Rendering.QualityLevel = 1
        GameSettings.SavedQualityLevel.Value = 1
        
        -- Disable expensive effects
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100
        Lighting.Brightness = 2
        
        -- Reduce particles
        for _, effect in pairs(Workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Smoke") then
                effect.Enabled = false
            end
        end
    end
    
    if MemoryCleaner then
        -- Force garbage collection
        game:GetService("GC"):CollectGarbage()
        game:GetService("GC"):RequestGC()
    end
    
    if RenderDistanceManager then
        -- Reduce render distance
        Camera.MaxDistance = 500
        Camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")
    end
end

local function restoreOriginalSettings()
    if originalSettings.GraphicsQualityLevel then
        GameSettings.SavedQualityLevel.Value = originalSettings.GraphicsQualityLevel
    end
    if originalSettings.MasterVolume then
        GameSettings.MasterVolume = originalSettings.MasterVolume
    end
    if originalSettings.RenderingDistance then
        Camera.MaxDistance = originalSettings.RenderingDistance
    end
    
    -- Restore lighting
    Lighting.GlobalShadows = true
    Lighting.Brightness = 1
end

local function togglePerformance()
    if performanceConnection then
        performanceConnection:Disconnect()
        performanceConnection = nil
    end
    
    if PerformanceEnabled then
        saveOriginalSettings()
        performanceConnection = RunService.Heartbeat:Connect(function()
            applyPerformanceOptimizations()
        end)
    else
        restoreOriginalSettings()
    end
end

-- Advanced Radar 2.0 System
local radarFrame, radarConnections = {}, {}
local soundBillboards = {}

local function createAdvancedRadar()
    if radarFrame.main then
        radarFrame.main:Destroy()
        radarFrame = {}
    end
    
    for _, conn in pairs(radarConnections) do
        conn:Disconnect()
    end
    radarConnections = {}
    
    if not RadarEnabled then return end
    
    -- Main radar frame
    radarFrame.main = Instance.new("Frame")
    radarFrame.main.Size = UDim2.new(0, 250, 0, 250)
    radarFrame.main.Position = UDim2.new(0, 10, 0, 10)
    radarFrame.main.BackgroundColor3 = Themes[CurrentTheme].Background
    radarFrame.main.BackgroundTransparency = 0.3
    radarFrame.main.BorderSizePixel = 0
    radarFrame.main.Parent = player.PlayerGui:FindFirstChild("CoreGui") or player.PlayerGui
    
    -- Radar border
    radarFrame.border = Instance.new("Frame")
    radarFrame.border.Size = UDim2.new(1, 0, 1, 0)
    radarFrame.border.BackgroundTransparency = 1
    radarFrame.border.BorderColor3 = Themes[CurrentTheme].Primary
    radarFrame.border.BorderSizePixel = 2
    radarFrame.border.Parent = radarFrame.main
    
    -- Center point (player)
    radarFrame.center = Instance.new("Frame")
    radarFrame.center.Size = UDim2.new(0, 4, 0, 4)
    radarFrame.center.Position = UDim2.new(0.5, -2, 0.5, -2)
    radarFrame.center.BackgroundColor3 = Themes[CurrentTheme].Secondary
    radarFrame.center.BorderSizePixel = 0
    radarFrame.center.Parent = radarFrame.main
    
    -- Direction indicator
    radarFrame.direction = Instance.new("Frame")
    radarFrame.direction.Size = UDim2.new(0, 2, 0, 10)
    radarFrame.direction.Position = UDim2.new(0.5, -1, 0.5, -15)
    radarFrame.direction.BackgroundColor3 = Themes[CurrentTheme].Primary
    radarFrame.direction.BorderSizePixel = 0
    radarFrame.direction.Parent = radarFrame.main
    
    -- Sound visualization container
    radarFrame.sounds = Instance.new("Frame")
    radarFrame.sounds.Size = UDim2.new(1, 0, 1, 0)
    radarFrame.sounds.BackgroundTransparency = 1
    radarFrame.sounds.Parent = radarFrame.main
end

local function updateAdvancedRadar()
    if not RadarEnabled or not radarFrame.main then return end
    
    -- Clear previous blips and sounds
    for _, child in pairs(radarFrame.main:GetChildren()) do
        if child:IsA("Frame") and child ~= radarFrame.border and child ~= radarFrame.center and child ~= radarFrame.direction and child ~= radarFrame.sounds then
            child:Destroy()
        end
    end
    
    for _, billboard in pairs(soundBillboards) do
        billboard:Destroy()
    end
    soundBillboards = {}
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local playerRoot = player.Character.HumanoidRootPart
    local playerCFrame = playerRoot.CFrame
    
    -- Update direction indicator based on camera
    local camera = Workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    local angle = math.atan2(lookVector.X, lookVector.Z)
    radarFrame.direction.Rotation = math.deg(angle)
    
    -- Add player blips
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = target.Character.HumanoidRootPart
            local humanoid = target.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local relativePos = playerCFrame:PointToObjectSpace(root.Position)
                local screenPos = Vector2.new(0.5 + relativePos.X / 100, 0.5 - relativePos.Z / 100)
                
                -- Only show if within radar bounds
                if screenPos.X >= 0 and screenPos.X <= 1 and screenPos.Y >= 0 and screenPos.Y <= 1 then
                    local blip = Instance.new("Frame")
                    blip.Size = UDim2.new(0, 6, 0, 6)
                    blip.Position = UDim2.new(screenPos.X, -3, screenPos.Y, -3)
                    blip.BackgroundColor3 = target.Team == player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    blip.BorderSizePixel = 0
                    blip.Parent = radarFrame.main
                    
                    -- Enemy FOV visualization
                    if ShowEnemyFOV and target.Team ~= player.Team then
                        local fovIndicator = Instance.new("Frame")
                        fovIndicator.Size = UDim2.new(0, 2, 0, 20)
                        fovIndicator.Position = UDim2.new(screenPos.X, -1, screenPos.Y, -20)
                        fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                        fovIndicator.BackgroundTransparency = 0.5
                        fovIndicator.BorderSizePixel = 0
                        fovIndicator.Rotation = 45
                        fovIndicator.Parent = radarFrame.main
                    end
                end
            end
        end
    end
    
    -- Sound visualization
    if SoundVisualization then
        -- Simulate sound detection (in real implementation, you'd hook into sound events)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.AssemblyLinearVelocity.Magnitude > 50 then
                local relativePos = playerCFrame:PointToObjectSpace(part.Position)
                local screenPos = Vector2.new(0.5 + relativePos.X / 100, 0.5 - relativePos.Z / 100)
                
                if screenPos.X >= 0 and screenPos.X <= 1 and screenPos.Y >= 0 and screenPos.Y <= 1 then
                    local soundRing = Instance.new("Frame")
                    soundRing.Size = UDim2.new(0, 8, 0, 8)
                    soundRing.Position = UDim2.new(screenPos.X, -4, screenPos.Y, -4)
                    soundRing.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    soundRing.BackgroundTransparency = 0.7
                    soundRing.BorderSizePixel = 0
                    soundRing.Parent = radarFrame.sounds
                    
                    table.insert(soundBillboards, soundRing)
                end
            end
        end
    end
    
    -- Objective tracking (placeholder - would be game-specific)
    if ObjectiveTracker then
        -- Example: Add objective markers
        local objectives = Workspace:FindFirstChild("Objectives") or Workspace:FindFirstChild("Flags") or Workspace:FindFirstChild("ControlPoints")
        if objectives then
            for _, objective in pairs(objectives:GetChildren()) do
                if objective:IsA("BasePart") then
                    local relativePos = playerCFrame:PointToObjectSpace(objective.Position)
                    local screenPos = Vector2.new(0.5 + relativePos.X / 100, 0.5 - relativePos.Z / 100)
                    
                    if screenPos.X >= 0 and screenPos.X <= 1 and screenPos.Y >= 0 and screenPos.Y <= 1 then
                        local objectiveMarker = Instance.new("Frame")
                        objectiveMarker.Size = UDim2.new(0, 10, 0, 10)
                        objectiveMarker.Position = UDim2.new(screenPos.X, -5, screenPos.Y, -5)
                        objectiveMarker.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                        objectiveMarker.BorderSizePixel = 0
                        objectiveMarker.Parent = radarFrame.main
                    end
                end
            end
        end
    end
end

-- Theme System
local function applyTheme(themeName)
    CurrentTheme = themeName
    local theme = Themes[themeName]
    
    -- Update radar colors if it exists
    if radarFrame.main and radarFrame.border then
        radarFrame.main.BackgroundColor3 = theme.Background
        radarFrame.border.BorderColor3 = theme.Primary
        radarFrame.center.BackgroundColor3 = theme.Secondary
        radarFrame.direction.BackgroundColor3 = theme.Primary
    end
    
    -- Update ESP colors (you would update your ESP drawing colors here)
    -- Update UI colors (WindUI might have its own theming system)
    
    print("[.binh Hub] Applied theme: " .. themeName)
end

-- ESP System (existing but will be enhanced with themes)
local ESP = {
    Objects = {}
}

function ESP:CreateESPPart(player)
    if self.Objects[player] then return end
    
    local drawing = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    drawing.Box.Thickness = 2
    drawing.Box.Filled = false
    drawing.Box.Color = Themes[CurrentTheme].Primary
    
    drawing.Name.Size = 13
    drawing.Name.Outline = true
    drawing.Name.Color = Themes[CurrentTheme].Text
    
    drawing.Distance.Size = 13
    drawing.Distance.Outline = true
    drawing.Distance.Color = Themes[CurrentTheme].Text
    
    drawing.Tracer.Thickness = 2
    drawing.Tracer.Color = Themes[CurrentTheme].Primary
    
    self.Objects[player] = drawing
end

-- Rest of ESP functions remain the same as before...
function ESP:RemoveESPPart(player)
    if self.Objects[player] then
        for _, drawing in pairs(self.Objects[player]) do
            drawing:Remove()
        end
        self.Objects[player] = nil
    end
end

function ESP:Update()
    for player, drawings in pairs(self.Objects) do
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
    end
    
    if not ESPEnabled then return end
    
    for _, target in pairs(Players:GetPlayers()) do
        if target == player then continue end
        if not target.Character then continue end
        
        local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
            self:RemoveESPPart(target)
            continue
        end
        
        if ESPTeamCheck and target.Team == player.Team then
            self:RemoveESPPart(target)
            continue
        end
        
        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        if distance > ESPDistance then
            self:RemoveESPPart(target)
            continue
        end
        
        if ESPWallCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = Workspace:Raycast(Camera.CFrame.Position, (humanoidRootPart.Position - Camera.CFrame.Position).Unit * distance, raycastParams)
            if raycastResult then
                self:RemoveESPPart(target)
                continue
            end
        end
        
        self:CreateESPPart(target)
        local drawings = self.Objects[target]
        
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local boxSize = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
            
            drawings.Box.Size = boxSize
            drawings.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
            drawings.Box.Visible = true
            
            drawings.Name.Text = target.Name
            drawings.Name.Position = Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 15)
            drawings.Name.Visible = true
            
            drawings.Distance.Text = string.format("[%d]", distance)
            drawings.Distance.Position = Vector2.new(vector.X, vector.Y + boxSize.Y / 2 + 5)
            drawings.Distance.Visible = true
            
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(vector.X, vector.Y + boxSize.Y / 2)
            drawings.Tracer.Visible = true
        else
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end
end

-- Aimbot System (existing)
local function getClosestPlayer()
    local closestPlayer, closestDistance = nil, AimDistance
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, target in pairs(Players:GetPlayers()) do
        if target == player then continue end
        if not target.Character then continue end
        
        local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        if AimTeamCheck and target.Team == player.Team then continue end
        
        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        if distance > AimDistance then continue end
        
        if AimWallCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {player.Character, target.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = Workspace:Raycast(Camera.CFrame.Position, (humanoidRootPart.Position - Camera.CFrame.Position).Unit * distance, raycastParams)
            if raycastResult then continue end
        end
        
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local distanceFromMouse = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
            if distanceFromMouse < closestDistance then
                closestPlayer = target
                closestDistance = distanceFromMouse
            end
        end
    end
    
    return closestPlayer
end

-- Movement Systems (existing)
local flyConnection, noclipConnection, antiFlingConnection

local function toggleFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if FlyEnabled and player.Character then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local root = player.Character.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            local velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                velocity = velocity + Vector3.new(0, -1, 0)
            end
            
            bodyVelocity.Velocity = velocity * 50
        end)
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
    end
end

local function toggleNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if NoclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function toggleAntiFling()
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    
    if AntiFlingEnabled then
        antiFlingConnection = RunService.Heartbeat:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    end
end

-- Save / Load Config
local function saveConfig()
    config.ESPEnabled = ESPEnabled
    config.ESPTeamCheck = ESPTeamCheck
    config.ESPWallCheck = ESPWallCheck
    config.ESPDistance = ESPDistance
    config.AimEnabled = AimEnabled
    config.AimTeamCheck = AimTeamCheck
    config.AimWallCheck = AimWallCheck
    config.AimDistance = AimDistance
    config.SmoothStrength = SmoothStrength
    config.FlyEnabled = FlyEnabled
    config.NoclipEnabled = NoclipEnabled
    config.RadarEnabled = RadarEnabled
    config.AntiFlingEnabled = AntiFlingEnabled
    config.PerformanceEnabled = PerformanceEnabled
    config.AutoFPSBoost = AutoFPSBoost
    config.MemoryCleaner = MemoryCleaner
    config.NetworkOptimizer = NetworkOptimizer
    config.RenderDistanceManager = RenderDistanceManager
    config.ShowEnemyFOV = ShowEnemyFOV
    config.PatrolRoutePrediction = PatrolRoutePrediction
    config.SoundVisualization = SoundVisualization
    config.ObjectiveTracker = ObjectiveTracker
    config.CurrentTheme = CurrentTheme

    writefile(CONFIG_FILE, HttpService:JSONEncode(config))
    print("[.binh Hub] Config saved!")
end

local function loadConfig()
    if isfile(CONFIG_FILE) then
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        ESPEnabled = data.ESPEnabled
        ESPTeamCheck = data.ESPTeamCheck
        ESPWallCheck = data.ESPWallCheck
        ESPDistance = data.ESPDistance
        AimEnabled = data.AimEnabled
        AimTeamCheck = data.AimTeamCheck
        AimWallCheck = data.AimWallCheck
        AimDistance = data.AimDistance
        SmoothStrength = data.SmoothStrength
        FlyEnabled = data.FlyEnabled
        NoclipEnabled = data.NoclipEnabled
        RadarEnabled = data.RadarEnabled
        AntiFlingEnabled = data.AntiFlingEnabled
        PerformanceEnabled = data.PerformanceEnabled or false
        AutoFPSBoost = data.AutoFPSBoost or false
        MemoryCleaner = data.MemoryCleaner or false
        NetworkOptimizer = data.NetworkOptimizer or false
        RenderDistanceManager = data.RenderDistanceManager or false
        ShowEnemyFOV = data.ShowEnemyFOV or false
        PatrolRoutePrediction = data.PatrolRoutePrediction or false
        SoundVisualization = data.SoundVisualization or false
        ObjectiveTracker = data.ObjectiveTracker or false
        CurrentTheme = data.CurrentTheme or "Default"
        print("[.binh Hub] Config loaded!")
    else
        print("[.binh Hub] No config file found!")
    end
end

-- Main Loops
RunService.RenderStepped:Connect(function()
    ESP:Update()
    
    if AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local currentCamCF = Camera.CFrame
            local newCamCF = currentCamCF:Lerp(CFrame.lookAt(currentCamCF.Position, targetPos), SmoothStrength)
            Camera.CFrame = newCamCF
        end
    end
end)

-- Radar update loop
RunService.Heartbeat:Connect(function()
    if RadarEnabled then
        if not radarFrame.main then
            createAdvancedRadar()
        end
        updateAdvancedRadar()
    elseif radarFrame.main then
        radarFrame.main:Destroy()
        radarFrame = {}
    end
end)

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = ".binh Hub | WindUI",
    Author = "by .binh",
    Folder = "binh",
    Icon = "https://github.com/philiptran16-png/binh-script/raw/main/Minimalistic_and_elegant_B_logo_monochrome_no_colors_clean_lines_modern_design_geometric.png",
    IconSize = 44,
    NewElements = true,
    OpenButton = {
        Title = "Open .ftgs Hub UI",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Themes[CurrentTheme].Primary, Themes[CurrentTheme].Secondary)
    }
})

-- ESP Tab
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
ESPTab:Toggle({Title = "Enable ESP", Desc = "Hiển thị người chơi", Default = ESPEnabled, Callback = function(state) 
    ESPEnabled = state 
    if not state then
        for player in pairs(ESP.Objects) do
            ESP:RemoveESPPart(player)
        end
    end
end})
ESPTab:Toggle({Title = "Team Check ESP", Desc = "Chỉ hiện người khác team", Default = ESPTeamCheck, Callback = function(state) ESPTeamCheck = state end})
ESPTab:Toggle({Title = "Wall Check", Desc = "Ẩn người chơi bị che khuất", Default = ESPWallCheck, Callback = function(state) ESPWallCheck = state end})
ESPTab:Slider({Title = "ESP Distance", Min = 50, Max = 500, Default = ESPDistance, Callback = function(value) ESPDistance = value end})

-- Aimbot Tab
local AimTab = Window:Tab({Title = "Aimbot", Icon = "target"})
AimTab:Toggle({Title = "Enable AIM", Desc = "Aim vào đầu đối thủ", Default = AimEnabled, Callback = function(state) AimEnabled = state end})
AimTab:Toggle({Title = "Team Check AIM", Desc = "Chỉ aim người khác team", Default = AimTeamCheck, Callback = function(state) AimTeamCheck = state end})
AimTab:Toggle({Title = "Wall Check", Desc = "Không aim nếu đối thủ bị che khuất", Default = AimWallCheck, Callback = function(state) AimWallCheck = state end})
AimTab:Slider({Title = "Aim Distance", Min = 50, Max = 500, Default = AimDistance, Callback = function(value) AimDistance = value end})
AimTab:Slider({Title = "Smooth Strength", Min = 0.05, Max = 1, Default = SmoothStrength, Step = 0.01, Callback = function(value) SmoothStrength = value end})

-- Movement Tab
local MoveTab = Window:Tab({Title = "Movement", Icon = "arrow-up-right"})
MoveTab:Toggle({Title = "Fly", Desc = "Bay tự do WSAD + Space + Ctrl", Default = FlyEnabled, Callback = function(state) 
    FlyEnabled = state 
    toggleFly()
end})
MoveTab:Toggle({Title = "Noclip", Desc = "Đi xuyên tường", Default = NoclipEnabled, Callback = function(state) 
    NoclipEnabled = state 
    toggleNoclip()
end})
MoveTab:Toggle({Title = "Anti Fling", Desc = "Chống văng nhân vật bởi lực ngoài", Default = AntiFlingEnabled, Callback = function(state) 
    AntiFlingEnabled = state 
    toggleAntiFling()
end})

-- Radar Tab
local RadarTab = Window:Tab({Title = "Radar", Icon = "map"})
RadarTab:Toggle({Title = "Enable Radar", Desc = "Bật/tắt radar minimap", Default = RadarEnabled, Callback = function(state) 
    RadarEnabled = state 
    if not state and radarFrame.main then
        radarFrame.main:Destroy()
        radarFrame = {}
    end
end})
RadarTab:Toggle({Title = "Enemy FOV", Desc = "Hiển thị tầm nhìn của kẻ địch", Default = ShowEnemyFOV, Callback = function(state) ShowEnemyFOV = state end})
RadarTab:Toggle({Title = "Sound Visualization", Desc = "Hiển thị vị trí âm thanh", Default = SoundVisualization, Callback = function(state) SoundVisualization = state end})
RadarTab:Toggle({Title = "Objective Tracker", Desc = "Theo dõi mục tiêu trò chơi", Default = ObjectiveTracker, Callback = function(state) ObjectiveTracker = state end})

-- Performance Tab
local PerformanceTab = Window:Tab({Title = "Performance", Icon = "zap"})
PerformanceTab:Toggle({Title = "Performance Mode", Desc = "Kích hoạt tối ưu hóa hiệu suất", Default = PerformanceEnabled, Callback = function(state) 
    PerformanceEnabled = state 
    togglePerformance()
end})
PerformanceTab:Toggle({Title = "Auto FPS Boost", Desc = "Tự động tăng FPS", Default = AutoFPSBoost, Callback = function(state) AutoFPSBoost = state end})
PerformanceTab:Toggle({Title = "Memory Cleaner", Desc = "Dọn dẹp bộ nhớ tự động", Default = MemoryCleaner, Callback = function(state) MemoryCleaner = state end})
PerformanceTab:Toggle({Title = "Render Distance Manager", Desc = "Quản lý khoảng cách hiển thị", Default = RenderDistanceManager, Callback = function(state) RenderDistanceManager = state end})

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
SettingsTab:Button({Title = "Save Config", Desc = "Lưu lại cấu hình hiện tại", Callback = saveConfig})
SettingsTab:Button({Title = "Load Config", Desc = "Tải cấu hình đã lưu", Callback = loadConfig})
SettingsTab:Dropdown({Title = "Theme", List = {"Default", "Dark", "Blue", "Pink"}, Callback = function(theme)
    applyTheme(theme)
end})

-- Character added event
player.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    if FlyEnabled then toggleFly() end
    if NoclipEnabled then toggleNoclip() end
    if AntiFlingEnabled then toggleAntiFling() end
    if PerformanceEnabled then togglePerformance() end
end)

-- Apply default theme on startup
applyTheme(CurrentTheme)
print("[.binh Hub] Loaded successfully with Performance, Advanced Radar, and Theme System!")
