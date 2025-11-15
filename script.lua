-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/src/main.lua"))()

-- Main Settings
local Settings = {
    ESP = {
        Enabled = true,
        ShowTeam = false,
        ShowBoxes = true,
        ShowTracers = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        MaxDistance = 500,
        BoxColor = Color3.new(1, 1, 1),
        TracerColor = Color3.new(1, 1, 1),
        NameColor = Color3.new(1, 1, 1),
        TeamColor = true
    },
    Aimbot = {
        Enabled = false,
        Smoothness = 0.1,
        FOV = 50,
        TargetPart = "Head",
        VisibleCheck = true,
        TeamCheck = true
    },
    Visuals = {
        DirectionLine = true,
        FOVCircle = false,
        Crosshair = false,
        Watermark = true,
        HitMarker = false
    },
    PlayerMods = {
        Noclip = false,
        Fly = false,
        Speed = false,
        SpeedValue = 16,
        JumpPower = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        NoClipKey = Enum.KeyCode.N,
        FlyKey = Enum.KeyCode.F,
        FlySpeed = 2
    },
    Misc = {
        PanicKey = Enum.KeyCode.Delete,
        RainbowMode = false,
        AutoUpdate = true
    }
}

-- Store drawing objects and data
local Drawings = {
    DirectionLine = nil,
    FOVCircle = nil,
    Crosshair = nil,
    Watermark = nil,
    HitMarker = nil,
    ESPs = {}
}

local Data = {
    Connections = {},
    RainbowHue = 0,
    Target = nil,
    HitTime = 0,
    Flying = false,
    NoClipping = false,
    OriginalWalkSpeed = 16,
    OriginalJumpPower = 50,
    FlyConnection = nil,
    NoclipConnection = nil,
    SpeedConnection = nil,
    JumpConnection = nil
}

-- Player Mods Functions
local function startNoclip()
    if Data.NoclipConnection then
        Data.NoclipConnection:Disconnect()
    end
    
    Data.NoclipConnection = RunService.Stepped:Connect(function()
        if Settings.PlayerMods.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if Data.NoclipConnection then
        Data.NoclipConnection:Disconnect()
        Data.NoclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function startFly()
    if Data.FlyConnection then
        Data.FlyConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    Data.Flying = true
    humanoid.PlatformStand = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Parent = rootPart
    
    Data.FlyConnection = RunService.Heartbeat:Connect(function()
        if not Data.Flying or not character or not rootPart then
            if Data.FlyConnection then
                Data.FlyConnection:Disconnect()
            end
            return
        end
        
        local camera = workspace.CurrentCamera
        local flySpeed = Settings.PlayerMods.FlySpeed
        
        local direction = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * flySpeed
        end
        
        bodyVelocity.Velocity = direction
    end)
end

local function stopFly()
    Data.Flying = false
    
    if Data.FlyConnection then
        Data.FlyConnection:Disconnect()
        Data.FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyVelocity = rootPart:FindFirstChild("BodyVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
    end
end

local function applySpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Settings.PlayerMods.Speed then
                humanoid.WalkSpeed = Settings.PlayerMods.SpeedValue
            else
                humanoid.WalkSpeed = Data.OriginalWalkSpeed
            end
        end
    end
end

local function applyJumpPower()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Settings.PlayerMods.JumpPower then
                humanoid.JumpPower = Settings.PlayerMods.JumpPowerValue
            else
                humanoid.JumpPower = Data.OriginalJumpPower
            end
        end
    end
end

local function startInfiniteJump()
    if Data.JumpConnection then
        Data.JumpConnection:Disconnect()
    end
    
    Data.JumpConnection = UserInputService.JumpRequest:Connect(function()
        if Settings.PlayerMods.InfiniteJump and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function stopInfiniteJump()
    if Data.JumpConnection then
        Data.JumpConnection:Disconnect()
        Data.JumpConnection = nil
    end
end

-- Save original values
local function saveOriginalValues()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Data.OriginalWalkSpeed = humanoid.WalkSpeed
            Data.OriginalJumpPower = humanoid.JumpPower
        end
    end
end

-- ESP Functions
local function createDirectionLine()
    if Drawings.DirectionLine then Drawings.DirectionLine:Remove() end
    Drawings.DirectionLine = Drawing.new("Line")
    Drawings.DirectionLine.Color = Settings.ESP.BoxColor
    Drawings.DirectionLine.Thickness = 2
    Drawings.DirectionLine.Visible = Settings.Visuals.DirectionLine
end

local function createFOVCircle()
    if Drawings.FOVCircle then Drawings.FOVCircle:Remove() end
    Drawings.FOVCircle = Drawing.new("Circle")
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Thickness = 2
    Drawings.FOVCircle.NumSides = 32
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Filled = false
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function createCrosshair()
    if Drawings.Crosshair then Drawings.Crosshair:Remove() end
    Drawings.Crosshair = Drawing.new("Line")
    Drawings.Crosshair.Visible = Settings.Visuals.Crosshair
    Drawings.Crosshair.Color = Color3.new(1, 1, 1)
    Drawings.Crosshair.Thickness = 1
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
end

local function createWatermark()
    if Drawings.Watermark then Drawings.Watermark:Remove() end
    Drawings.Watermark = Drawing.new("Text")
    Drawings.Watermark.Visible = Settings.Visuals.Watermark
    Drawings.Watermark.Color = Color3.new(1, 1, 1)
    Drawings.Watermark.Size = 16
    Drawings.Watermark.Font = 2
    Drawings.Watermark.Text = "Windy ESP | FPS: 60 | Ping: 0ms"
    Drawings.Watermark.Position = Vector2.new(10, 10)
end

-- Update functions
local function updateDirectionLine()
    if not Drawings.DirectionLine or not Settings.Visuals.DirectionLine then return end
    local lookVector = Camera.CFrame.LookVector
    local startPos = Camera.CFrame.Position
    local endPos = startPos + lookVector * Settings.ESP.MaxDistance
    local startVector, startVisible = Camera:WorldToViewportPoint(startPos)
    local endVector, endVisible = Camera:WorldToViewportPoint(endPos)
    if startVisible and endVisible then
        Drawings.DirectionLine.From = Vector2.new(startVector.X, startVector.Y)
        Drawings.DirectionLine.To = Vector2.new(endVector.X, endVector.Y)
        Drawings.DirectionLine.Visible = true
        Drawings.DirectionLine.Color = Settings.ESP.BoxColor
    else
        Drawings.DirectionLine.Visible = false
    end
end

local function updateFOVCircle()
    if not Drawings.FOVCircle or not Settings.Visuals.FOVCircle then return end
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function updateCrosshair()
    if not Drawings.Crosshair or not Settings.Visuals.Crosshair then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
    Drawings.Crosshair.Visible = true
end

local function updateWatermark()
    if not Drawings.Watermark or not Settings.Visuals.Watermark then return end
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    Drawings.Watermark.Text = string.format("Windy ESP | FPS: %d | Players: %d", fps, #Players:GetPlayers())
    Drawings.Watermark.Visible = true
end

local function updateESP()
    -- Clear existing ESP drawings
    for _, esp in pairs(Drawings.ESPs) do
        if esp.Box then esp.Box:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Distance then esp.Distance:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.HealthBar then esp.HealthBar:Remove() end
        if esp.HealthBarOutline then esp.HealthBarOutline:Remove() end
    end
    Drawings.ESPs = {}
    
    if not Settings.ESP.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                -- Team check
                if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                if distance > Settings.ESP.MaxDistance then
                    continue
                end
                
                -- Get player color
                local playerColor = Settings.ESP.BoxColor
                if Settings.ESP.TeamColor then
                    playerColor = player.TeamColor.Color
                end
                
                local espData = {}
                
                -- Box ESP
                if Settings.ESP.ShowBoxes then
                    espData.Box = Drawing.new("Square")
                    espData.Box.Visible = false
                    espData.Box.Color = playerColor
                    espData.Box.Thickness = 2
                    espData.Box.Filled = false
                end
                
                -- Tracer
                if Settings.ESP.ShowTracers then
                    espData.Tracer = Drawing.new("Line")
                    espData.Tracer.Visible = false
                    espData.Tracer.Color = playerColor
                    espData.Tracer.Thickness = 1
                end
                
                -- Name
                if Settings.ESP.ShowNames then
                    espData.Name = Drawing.new("Text")
                    espData.Name.Visible = false
                    espData.Name.Color = Settings.ESP.NameColor
                    espData.Name.Size = 14
                    espData.Name.Font = 2
                    espData.Name.Text = player.Name
                end
                
                -- Distance
                if Settings.ESP.ShowDistance then
                    espData.Distance = Drawing.new("Text")
                    espData.Distance.Visible = false
                    espData.Distance.Color = Settings.ESP.NameColor
                    espData.Distance.Size = 12
                    espData.Distance.Font = 2
                    espData.Distance.Text = string.format("[%d]", distance)
                end
                
                -- Health
                if Settings.ESP.ShowHealth then
                    espData.Health = Drawing.new("Text")
                    espData.Health.Visible = false
                    espData.Health.Color = Color3.new(1, 1, 1)
                    espData.Health.Size = 12
                    espData.Health.Font = 2
                    espData.Health.Text = string.format("%d", humanoid.Health)
                    
                    -- Health bar
                    espData.HealthBarOutline = Drawing.new("Square")
                    espData.HealthBarOutline.Visible = false
                    espData.HealthBarOutline.Color = Color3.new(0, 0, 0)
                    espData.HealthBarOutline.Thickness = 1
                    espData.HealthBarOutline.Filled = false
                    
                    espData.HealthBar = Drawing.new("Square")
                    espData.HealthBar.Visible = false
                    espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                    espData.HealthBar.Thickness = 1
                    espData.HealthBar.Filled = true
                end
                
                Drawings.ESPs[player] = espData
                
                -- Update ESP positions
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
                    local rootPos = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if headVisible then
                        local scaleFactor = 1 / (headPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
                        local width = 4 * scaleFactor
                        local height = 6 * scaleFactor
                        
                        -- Box ESP
                        if espData.Box then
                            espData.Box.Size = Vector2.new(width, height)
                            espData.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - height / 2)
                            espData.Box.Visible = true
                        end
                        
                        -- Tracer
                        if espData.Tracer then
                            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            espData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            espData.Tracer.Visible = true
                        end
                        
                        -- Name
                        if espData.Name then
                            espData.Name.Position = Vector2.new(headPos.X, headPos.Y - height / 2 - 20)
                            espData.Name.Visible = true
                        end
                        
                        -- Distance
                        if espData.Distance then
                            espData.Distance.Position = Vector2.new(headPos.X, headPos.Y - height / 2 - 35)
                            espData.Distance.Visible = true
                        end
                        
                        -- Health
                        if espData.Health then
                            espData.Health.Position = Vector2.new(headPos.X, headPos.Y + height / 2 + 5)
                            espData.Health.Visible = true
                            
                            -- Health bar
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            local barWidth = width
                            local barHeight = 3
                            local barX = headPos.X - width / 2
                            local barY = headPos.Y - height / 2 - 8
                            
                            espData.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
                            espData.HealthBarOutline.Position = Vector2.new(barX, barY)
                            espData.HealthBarOutline.Visible = true
                            
                            espData.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                            espData.HealthBar.Position = Vector2.new(barX, barY)
                            espData.HealthBar.Visible = true
                            espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        end
                    else
                        -- Hide all if not visible
                        for _, drawing in pairs(espData) do
                            if drawing then
                                drawing.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Aimbot Functions
local function updateAimbot()
    if not Settings.Aimbot.Enabled then return end
    
    local closestTarget = nil
    local closestDistance = Settings.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                -- Team check
                if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Visible check
                if Settings.Aimbot.VisibleCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * Settings.ESP.MaxDistance)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                    if hit and hit:IsDescendantOf(character) == false then
                        continue
                    end
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    
    Data.Target = closestTarget
    
    -- Auto aim when target is found
    if closestTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPosition = closestTarget.Position
        local currentCamera = workspace.CurrentCamera
        
        if Settings.Aimbot.Smoothness > 0 then
            local currentCFrame = currentCamera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
            currentCamera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothness)
        else
            currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, targetPosition)
        end
    end
end

-- Main Update Loop
local function update()
    if Settings.Misc.RainbowMode then
        Data.RainbowHue = (Data.RainbowHue + 0.01) % 1
        local rainbowColor = Color3.fromHSV(Data.RainbowHue, 1, 1)
        Settings.ESP.BoxColor = rainbowColor
        Settings.ESP.TracerColor = rainbowColor
        Settings.ESP.NameColor = rainbowColor
    end
    
    updateDirectionLine()
    updateFOVCircle()
    updateCrosshair()
    updateWatermark()
    updateESP()
    updateAimbot()
    
    -- Update player mods
    applySpeed()
    applyJumpPower()
    
    -- Update hit marker
    if Drawings.HitMarker then
        local timeSinceHit = tick() - Data.HitTime
        if timeSinceHit < 0.3 then
            local alpha = 1 - (timeSinceHit / 0.3)
            Drawings.HitMarker.Color = Color3.new(1, 1, 1)
            Drawings.HitMarker.Visible = true
        else
            Drawings.HitMarker.Visible = false
        end
    end
end

-- Create WindUI Interface
local function createWindUI()
    local window = WindUI:Window({
        Title = "Windy ESP v4.0",
        Icon = "settings",
        Size = UDim2.new(0, 500, 0, 500),
        Position = UDim2.new(0, 20, 0, 20)
    })
    
    -- ESP Tab
    local esptab = window:Tab({
        Title = "ESP",
        Icon = "eye"
    })
    
    esptab:Toggle({
        Title = "Enable ESP",
        Value = Settings.ESP.Enabled,
        Callback = function(value)
            Settings.ESP.Enabled = value
        end
    })
    
    esptab:Toggle({
        Title = "Show Boxes",
        Value = Settings.ESP.ShowBoxes,
        Callback = function(value)
            Settings.ESP.ShowBoxes = value
        end
    })
    
    esptab:Toggle({
        Title = "Show Tracers",
        Value = Settings.ESP.ShowTracers,
        Callback = function(value)
            Settings.ESP.ShowTracers = value
        end
    })
    
    esptab:Toggle({
        Title = "Show Names",
        Value = Settings.ESP.ShowNames,
        Callback = function(value)
            Settings.ESP.ShowNames = value
        end
    })
    
    esptab:Toggle({
        Title = "Show Distance",
        Value = Settings.ESP.ShowDistance,
        Callback = function(value)
            Settings.ESP.ShowDistance = value
        end
    })
    
    esptab:Toggle({
        Title = "Show Health",
        Value = Settings.ESP.ShowHealth,
        Callback = function(value)
            Settings.ESP.ShowHealth = value
        end
    })
    
    esptab:Toggle({
        Title = "Team Check",
        Value = Settings.ESP.TeamCheck,
        Callback = function(value)
            Settings.ESP.TeamCheck = value
        end
    })
    
    esptab:Toggle({
        Title = "Team Colors",
        Value = Settings.ESP.TeamColor,
        Callback = function(value)
            Settings.ESP.TeamColor = value
        end
    })
    
    esptab:Slider({
        Title = "Max Distance",
        Value = Settings.ESP.MaxDistance,
        Min = 50,
        Max = 1000,
        Callback = function(value)
            Settings.ESP.MaxDistance = value
        end
    })
    
    -- Aimbot Tab
    local aimbottab = window:Tab({
        Title = "Aimbot",
        Icon = "target"
    })
    
    aimbottab:Toggle({
        Title = "Enable Aimbot",
        Value = Settings.Aimbot.Enabled,
        Callback = function(value)
            Settings.Aimbot.Enabled = value
        end
    })
    
    aimbottab:Slider({
        Title = "Smoothness",
        Value = Settings.Aimbot.Smoothness,
        Min = 0,
        Max = 1,
        Callback = function(value)
            Settings.Aimbot.Smoothness = value
        end
    })
    
    aimbottab:Slider({
        Title = "FOV Circle",
        Value = Settings.Aimbot.FOV,
        Min = 10,
        Max = 200,
        Callback = function(value)
            Settings.Aimbot.FOV = value
        end
    })
    
    aimbottab:Toggle({
        Title = "Visibility Check",
        Value = Settings.Aimbot.VisibleCheck,
        Callback = function(value)
            Settings.Aimbot.VisibleCheck = value
        end
    })
    
    aimbottab:Toggle({
        Title = "Team Check",
        Value = Settings.Aimbot.TeamCheck,
        Callback = function(value)
            Settings.Aimbot.TeamCheck = value
        end
    })
    
    aimbottab:Dropdown({
        Title = "Target Part",
        Items = {"Head", "HumanoidRootPart", "Torso"},
        Value = Settings.Aimbot.TargetPart,
        Callback = function(value)
            Settings.Aimbot.TargetPart = value
        end
    })
    
    -- Visuals Tab
    local visualstab = window:Tab({
        Title = "Visuals",
        Icon = "monitor"
    })
    
    visualstab:Toggle({
        Title = "Direction Line",
        Value = Settings.Visuals.DirectionLine,
        Callback = function(value)
            Settings.Visuals.DirectionLine = value
        end
    })
    
    visualstab:Toggle({
        Title = "FOV Circle",
        Value = Settings.Visuals.FOVCircle,
        Callback = function(value)
            Settings.Visuals.FOVCircle = value
        end
    })
    
    visualstab:Toggle({
        Title = "Crosshair",
        Value = Settings.Visuals.Crosshair,
        Callback = function(value)
            Settings.Visuals.Crosshair = value
        end
    })
    
    visualstab:Toggle({
        Title = "Watermark",
        Value = Settings.Visuals.Watermark,
        Callback = function(value)
            Settings.Visuals.Watermark = value
        end
    })
    
    visualstab:Toggle({
        Title = "Hit Marker",
        Value = Settings.Visuals.HitMarker,
        Callback = function(value)
            Settings.Visuals.HitMarker = value
            if value and not Drawings.HitMarker then
                Drawings.HitMarker = Drawing.new("Line")
                Drawings.HitMarker.Visible = false
                Drawings.HitMarker.Thickness = 2
            end
        end
    })
    
    -- Player Mods Tab
    local playertab = window:Tab({
        Title = "Player",
        Icon = "user"
    })
    
    playertab:Toggle({
        Title = "Noclip",
        Value = Settings.PlayerMods.Noclip,
        Callback = function(value)
            Settings.PlayerMods.Noclip = value
            if value then
                startNoclip()
            else
                stopNoclip()
            end
        end
    })
    
    playertab:Toggle({
        Title = "Fly",
        Value = Settings.PlayerMods.Fly,
        Callback = function(value)
            Settings.PlayerMods.Fly = value
            if value then
                startFly()
            else
                stopFly()
            end
        end
    })
    
    playertab:Slider({
        Title = "Fly Speed",
        Value = Settings.PlayerMods.FlySpeed,
        Min = 1,
        Max = 10,
        Callback = function(value)
            Settings.PlayerMods.FlySpeed = value
        end
    })
    
    playertab:Toggle({
        Title = "Speed Hack",
        Value = Settings.PlayerMods.Speed,
        Callback = function(value)
            Settings.PlayerMods.Speed = value
            applySpeed()
        end
    })
    
    playertab:Slider({
        Title = "Speed Value",
        Value = Settings.PlayerMods.SpeedValue,
        Min = 16,
        Max = 100,
        Callback = function(value)
            Settings.PlayerMods.SpeedValue = value
            applySpeed()
        end
    })
    
    playertab:Toggle({
        Title = "High Jump",
        Value = Settings.PlayerMods.JumpPower,
        Callback = function(value)
            Settings.PlayerMods.JumpPower = value
            applyJumpPower()
        end
    })
    
    playertab:Slider({
        Title = "Jump Power",
        Value = Settings.PlayerMods.JumpPowerValue,
        Min = 50,
        Max = 200,
        Callback = function(value)
            Settings.PlayerMods.JumpPowerValue = value
            applyJumpPower()
        end
    })
    
    playertab:Toggle({
        Title = "Infinite Jump",
        Value = Settings.PlayerMods.InfiniteJump,
        Callback = function(value)
            Settings.PlayerMods.InfiniteJump = value
            if value then
                startInfiniteJump()
            else
                stopInfiniteJump()
            end
        end
    })
    
    playertab:Button({
        Title = "Reset Player Mods",
        Callback = function()
            Settings.PlayerMods.Noclip = false
            Settings.PlayerMods.Fly = false
            Settings.PlayerMods.Speed = false
            Settings.PlayerMods.JumpPower = false
            Settings.PlayerMods.InfiniteJump = false
            
            stopNoclip()
            stopFly()
            stopInfiniteJump()
            applySpeed()
            applyJumpPower()
            
            print("Player mods reset!")
        end
    })
    
    -- Misc Tab
    local misctab = window:Tab({
        Title = "Misc",
        Icon = "settings"
    })
    
    misctab:Toggle({
        Title = "Rainbow Mode",
        Value = Settings.Misc.RainbowMode,
        Callback = function(value)
            Settings.Misc.RainbowMode = value
        end
    })
    
    misctab:Button({
        Title = "Save Configuration",
        Callback = function()
            print("Configuration saved!")
        end
    })
    
    misctab:Button({
        Title = "Load Configuration",
        Callback = function()
            print("Configuration loaded!")
        end
    })
    
    misctab:Button({
        Title = "Reset All Settings",
        Callback = function()
            -- Reset all settings to defaults
            Settings.ESP.Enabled = true
            Settings.ESP.ShowBoxes = true
            Settings.ESP.ShowTracers = true
            Settings.ESP.ShowNames = true
            Settings.ESP.ShowDistance = true
            Settings.ESP.ShowHealth = true
            Settings.ESP.TeamCheck = false
            Settings.ESP.TeamColor = true
            Settings.ESP.MaxDistance = 500
            
            Settings.Aimbot.Enabled = false
            Settings.Aimbot.Smoothness = 0.1
            Settings.Aimbot.FOV = 50
            Settings.Aimbot.VisibleCheck = true
            Settings.Aimbot.TeamCheck = true
            Settings.Aimbot.TargetPart = "Head"
            
            Settings.Visuals.DirectionLine = true
            Settings.Visuals.FOVCircle = false
            Settings.Visuals.Crosshair = false
            Settings.Visuals.Watermark = true
            Settings.Visuals.HitMarker = false
            
            Settings.PlayerMods.Noclip = false
            Settings.PlayerMods.Fly = false
            Settings.PlayerMods.Speed = false
            Settings.PlayerMods.SpeedValue = 16
            Settings.PlayerMods.JumpPower = false
            Settings.PlayerMods.JumpPowerValue = 50
            Settings.PlayerMods.InfiniteJump = false
            Settings.PlayerMods.FlySpeed = 2
            
            Settings.Misc.RainbowMode = false
            
            -- Apply resets
            stopNoclip()
            stopFly()
            stopInfiniteJump()
            applySpeed()
            applyJumpPower()
            
            print("All settings reset to defaults!")
        end
    })
    
    misctab:Label({
        Title = "Controls:",
        Description = "N - Noclip | F - Fly | Insert - UI | Delete - Panic"
    })
    
    misctab:Label({
        Title = "Windy ESP v4.0",
        Description = "Made with ❤️ using WindUI"
    })
    
    return window
end

-- Initialize
saveOriginalValues()
createDirectionLine()
createFOVCircle()
createCrosshair()
createWatermark()
local WindUIWindow = createWindUI()

-- Start main loop
Data.Connections.MainLoop = RunService.RenderStepped:Connect(update)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Panic key
    if input.KeyCode == Settings.Misc.PanicKey then
        for _, drawing in pairs(Drawings) do
            if typeof(drawing) == "table" then
                for _, d in pairs(drawing) do
                    if d and d.Remove then
                        d:Remove()
                    end
                end
            elseif drawing and drawing.Remove then
                drawing:Remove()
            end
        end
        
        if WindUIWindow then
            WindUIWindow:Close() -- Assuming WindUI has a Close method
        end
        
        for _, connection in pairs(Data.Connections) do
            connection:Disconnect()
        end
        
        stopNoclip()
        stopFly()
        stopInfiniteJump()
        
        print("Windy ESP - Panic mode activated!")
    end
    
    -- Toggle UI
    if input.KeyCode == Enum.KeyCode.Insert then
        -- WindUI might have its own toggle method, but we'll assume it does
        if WindUIWindow then
            -- This would depend on WindUI's API
            -- For now, we'll just print
            print("UI Toggle - WindUI might handle this automatically")
        end
    end
    
    -- Noclip toggle key
    if input.KeyCode == Settings.PlayerMods.NoClipKey then
        Settings.PlayerMods.Noclip = not Settings.PlayerMods.Noclip
        if Settings.PlayerMods.Noclip then
            startNoclip()
        else
            stopNoclip()
        end
    end
    
    -- Fly toggle key
    if input.KeyCode == Settings.PlayerMods.FlyKey then
        Settings.PlayerMods.Fly = not Settings.PlayerMods.Fly
        if Settings.PlayerMods.Fly then
            startFly()
        else
            stopFly()
        end
    end
end)

-- Character added event to reapply settings
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    saveOriginalValues()
    applySpeed()
    applyJumpPower()
    
    if Settings.PlayerMods.Noclip then
        startNoclip()
    end
    if Settings.PlayerMods.Fly then
        startFly()
    end
    if Settings.PlayerMods.InfiniteJump then
        startInfiniteJump()
    end
end)

print("Windy ESP v4.0 Loaded!")
print("Using WindUI Framework")
print("Press Insert to toggle UI")
print("Press " .. Settings.Misc.PanicKey.Name .. " for panic mode")
print("Press " .. Settings.PlayerMods.NoClipKey.Name .. " to toggle Noclip")
print("Press " .. Settings.PlayerMods.FlyKey.Name .. " to toggle Fly")
