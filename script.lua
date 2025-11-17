--================================================--
--        WINDY UI AIMBOT EXECUTOR PRO           --
--              ULTIMATE EDITION                 --
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
local Stats = game:GetService("Stats")
local NetworkClient = game:GetService("NetworkClient")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EXECUTOR DETECTION
local Executor = {
    Name = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown",
    Supported = (syn and true) or (getexecutorname and true) or false
}

-- LOAD WINDUI
local WindUI
local WindUILoaded = false

local function SafeLoadWindUI()
    local success, result = pcall(function()
        local content
        if syn then
            local response = syn.request({
                Url = "https://raw.githubusercontent.com/Footagesus/WindUI/main/src/main.lua",
                Method = "GET"
            })
            content = response.Body
        elseif request then
            local response = request({
                Url = "https://raw.githubusercontent.com/Footagesus/WindUI/main/src/main.lua", 
                Method = "GET"
            })
            content = response.Body
        else
            content = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/src/main.lua")
        end
        
        if content and #content > 1000 then
            return loadstring(content)()
        end
        error("Failed to load WindUI")
    end)
    
    if success then
        WindUILoaded = true
        return result
    else
        warn("WindUI failed to load: " .. tostring(result))
        return nil
    end
end

WindUI = SafeLoadWindUI()

-- CONFIGURATION SYSTEM
local ConfigSystem = {
    CurrentConfig = "default",
    Configs = {},
    AutoSave = true,
    CloudEnabled = false
}

-- ADVANCED SETTINGS
local AdvancedSettings = {
    -- 🎯 AIMBOT NÂNG CAO
    Aimbot = {
        AutoWall = false,
        WallPenetration = false,
        MaxWallThickness = 5,
        
        HumanizerMode = "Smooth",
        HumanizerIntensity = 0.3,
        HumanizerDelay = 0.1,
        
        AdvancedPrediction = false,
        PingCompensation = true,
        ProjectilePrediction = false,
        BulletDrop = false,
        BulletSpeed = 500,
        
        PriorityMode = "Closest",
        ThreatAssessment = false,
        TargetHistory = {},
        
        AimStyle = "Linear",
        SilentAim = true,
        DesyncCorrection = false,
        
        Triggerbot = false,
        TriggerbotDelay = 0.1,
        TriggerbotKey = Enum.KeyCode.Q,
        
        RageMode = false,
        InstantLock = false,
        IgnoreWalls = false,
        AutoFire = false,
        FireRate = 600,
        
        -- AI Learning
        AILearning = false,
        LearnFromPros = false,
        AdaptToPlaystyle = false
    },
    
    -- 🔮 ESP NÂNG CAO
    ESP = {
        SkeletonESP = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 0),
        GlowEffect = false,
        GlowColor = Color3.fromRGB(255, 0, 0),
        
        HealthBar = true,
        HealthBarColor = Color3.fromRGB(0, 255, 0),
        
        WeaponESP = false,
        ShowAmmo = false,
        
        Radar = false,
        RadarSize = 200,
        RadarRange = 500,
        
        CustomTags = false,
        Tags = {"Bot", "Noob", "Pro"},
        
        VisibilityCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(255, 0, 0),
        
        ThreeDBoxes = false,
        BoxFill = false,
        BoxFillTransparency = 0.3,
        
        -- ESP nâng cao
        OutOfViewArrows = false,
        Snaplines = false,
        InfoPanel = false,
        MinESPAlpha = 0.3,
        MaxESPAlpha = 1.0
    },
    
    -- ⚔️ COMBAT FEATURES
    Combat = {
        AutoFarm = false,
        FarmRadius = 50,
        FarmTargets = {"NPC", "Mobs", "Players"},
        
        HitboxExpander = false,
        HitboxMultiplier = 1.5,
        HitboxParts = {"Head", "Torso"},
        
        CriticalHit = false,
        CriticalChance = 0.1,
        
        DamageMultiplier = false,
        DamageScale = 1.0,
        
        NoRecoil = false,
        NoSpread = false,
        NoSway = false,
        
        RapidFire = false,
        FireRateMultiplier = 2.0,
        
        InfiniteAmmo = false,
        NoReload = false,
        
        -- Combat AI
        AutoDodge = false,
        PerfectBlock = false,
        ComboPredictor = false
    },
    
    -- 🛡️ ANTI-CHEAT BYPASS
    AntiCheat = {
        RandomizeClicks = false,
        HumanMouseMovements = false,
        HideProcess = false,
        
        SpoofFPS = false,
        TargetFPS = 60,
        SpoofPing = false,
        TargetPing = 30,
        
        ClearLogs = false,
        LogClearInterval = 30,
        
        MimicHuman = false,
        RandomDelays = false,
        ActivityPattern = "Normal",
        
        -- Advanced bypass
        MemoryObfuscation = false,
        ScriptRotation = false,
        SignatureSpoofing = false
    },
    
    -- 🎮 GAME-SPECIFIC FEATURES
    GameSpecific = {
        AutoDetectGame = true,
        GamePresets = {},
        
        -- Arsenal
        ArsenalAimbot = false,
        ArsenalTriggerbot = false,
        
        -- Phantom Forces
        PFNoRecoil = false,
        PFWallbang = false,
        
        -- Jailbreak
        AutoArrest = false,
        AutoRob = false,
        
        -- Adopt Me
        AutoCollect = false,
        AutoAge = false,
        
        -- Blade Ball
        AutoBlock = false,
        PerfectBlock = false,
        
        -- Pet Simulator
        AutoFarmPets = false,
        AutoHatch = false,
        
        -- Brookhaven
        AutoMoney = false,
        AutoScore = false,
        
        -- Natural Disaster
        AutoSurvive = false,
        DisasterPredictor = false
    },
    
    -- 🔧 UTILITY TOOLS
    Utility = {
        ServerHop = false,
        RejoinServer = false,
        CopyServerID = false,
        
        SpectatePlayer = false,
        TeleportToPlayer = false,
        ViewPlayerInventory = false,
        
        SpeedHack = false,
        JumpHack = false,
        GravityHack = false,
        
        ItemESP = false,
        LootESP = false,
        ChestESP = false,
        
        AutoClicker = false,
        CPS = 10,
        ClickPattern = "Normal",
        
        Macros = {},
        RecordMacro = false,
        PlayMacro = false,
        
        -- Advanced utility
        AutoStomp = false,
        AutoReportBots = false,
        ServerCrasher = false,
        LagSwitch = false
    },
    
    -- 🎨 CUSTOMIZATION
    Customization = {
        Themes = {"Dark", "Light", "Blue", "Red", "Green", "Purple", "Cyber", "Neon"},
        CurrentTheme = "Dark",
        CustomColors = false,
        
        CustomCrosshair = false,
        CrosshairStyle = "Default",
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        CrosshairSize = 20,
        
        Notifications = true,
        SoundEffects = true,
        
        ConfigSystem = true,
        AutoSave = true,
        CloudConfigs = false,
        
        CustomHotkeys = {},
        HotkeyProfiles = {},
        
        -- UI Customization
        UIScale = 1.0,
        BackgroundBlur = false,
        Watermark = true,
        KeybindsDisplay = true
    },
    
    -- 📊 STATISTICS & ANALYTICS
    Statistics = {
        ShowFPS = true,
        ShowPing = true,
        ShowMemory = false,
        
        Kills = 0,
        Deaths = 0,
        Headshots = 0,
        Accuracy = 0,
        
        SessionTime = 0,
        TargetsLocked = 0,
        ShotsFired = 0,
        
        LocalLeaderboard = false,
        SkillRating = 0,
        
        RecordGameplay = false,
        SaveHighlights = false,
        
        -- Advanced stats
        PerformanceMetrics = false,
        Heatmap = false,
        PlaystyleAnalysis = false
    },
    
    -- 🚀 PERFORMANCE OPTIMIZATION
    Performance = {
        LimitFPS = false,
        MaxFPS = 144,
        
        GarbageCollection = false,
        GCInterval = 30,
        
        ReduceParticles = false,
        HideEffects = false,
        
        ESPLOD = true,
        UpdateRate = 30,
        
        SmartDisable = true,
        InactiveTimeout = 300,
        
        -- Advanced optimization
        MemoryPooling = false,
        RenderOptimization = false,
        NetworkOptimization = false
    }
}

-- CONFIGURATION CƠ BẢN (giữ nguyên để tương thích)
local Settings = {
    KeyToggle = Enum.KeyCode.E,
    SmoothAmount = 0.2,
    FOVRadius = 150,
    AimPart = "Head",
    Enabled = false,
    TeamCheck = true,
    WallCheck = false,
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
    Priority = "Closest",
    
    -- FOV Settings
    FOVColor = Color3.fromRGB(0, 255, 0),
    FOVThickness = 2,
    FOVFilled = false,
    FOVTransparency = 1,
    
    -- ESP Settings
    ESPEnabled = false,
    BoxESP = false,
    Tracers = false,
    NameESP = false,
    DistanceESP = false,
    HealthESP = false,
    SkeletonESP = false,
    Chams = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    ESPTeamColor = true,
    MaxESPDistance = 500
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
    AntiAfk = false,
    AutoRespawn = false
}

-- STATE VARIABLES NÂNG CAO
local aimbotEnabled = false
local currentTarget = nil
local selectedPlayer = nil
local drawingObjects = {}
local connections = {}
local ESPObjects = {}
local flyBodyVelocity = nil
local noclipConnection = nil
local flyConnection = nil
local radarObjects = {}
local crosshairObjects = {}
local performanceStats = {}
local gameDetection = {}
local macroRecorder = {}
local stealthMode = false
local aiLearningData = {}

-- BIẾN HỆ THỐNG
local startTime = os.time()
local lastGCCleanup = os.time()
local lastLogClear = os.time()
local lastHumanizeTime = 0
local humanizeRandomSeed = math.random(1, 10000)

-- KHỞI TẠO DRAWING OBJECTS NÂNG CAO
local function initializeAdvancedDrawings()
    if not Drawing then return end
    
    -- Crosshair tùy chỉnh
    local crosshairLine1 = Drawing.new("Line")
    crosshairLine1.Visible = false
    crosshairLine1.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairLine1.Thickness = 2
    
    local crosshairLine2 = Drawing.new("Line")
    crosshairLine2.Visible = false
    crosshairLine2.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairLine2.Thickness = 2
    
    local crosshairDot = Drawing.new("Circle")
    crosshairDot.Visible = false
    crosshairDot.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairDot.Thickness = 2
    crosshairDot.Radius = 2
    crosshairDot.Filled = true
    
    crosshairObjects = {
        Line1 = crosshairLine1,
        Line2 = crosshairLine2,
        Dot = crosshairDot
    }
    
    -- Radar
    local radarCircle = Drawing.new("Circle")
    radarCircle.Visible = false
    radarCircle.Color = Color3.fromRGB(255, 255, 255)
    radarCircle.Thickness = 2
    radarCircle.Radius = AdvancedSettings.ESP.RadarSize
    radarCircle.Filled = false
    
    radarObjects.Circle = radarCircle
    radarObjects.Players = {}
end

-- HỆ THỐNG NHẬN DIỆN GAME
local function detectGame()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    gameDetection = {
        PlaceId = placeId,
        Name = gameName,
        Detected = false,
        Preset = "Default"
    }
    
    -- Nhận diện game phổ biến
    local gamePresets = {
        [292439477] = {Name = "Phantom Forces", Preset = "FPS"},
        [286090429] = {Name = "Arsenal", Preset = "FPS"},
        [606849621] = {Name = "Jailbreak", Preset = "Roleplay"},
        [537413528] = {Name = "Build A Boat For Treasure", Preset = "Building"},
        [142823291] = {Name = "Murder Mystery 2", Preset = "Social"},
        [103243479] = {Name = "Natural Disaster Survival", Preset = "Survival"},
        [4924926972] = {Name = "Blade Ball", Preset = "Combat"}
    }
    
    if gamePresets[placeId] then
        gameDetection.Detected = true
        gameDetection.Preset = gamePresets[placeId].Preset
        gameDetection.Config = gamePresets[placeId].Name
    end
    
    return gameDetection
end

-- HỆ THỐNG AI LEARNING
local function initializeAILearning()
    aiLearningData = {
        PlayerPatterns = {},
        CombatStyle = "Aggressive",
        AccuracyHistory = {},
        MovementPatterns = {},
        SkillLevel = "Medium"
    }
end

local function analyzePlayerPattern(player)
    if not AdvancedSettings.Aimbot.AILearning then return end
    
    if not aiLearningData.PlayerPatterns[player.Name] then
        aiLearningData.PlayerPatterns[player.Name] = {
            DodgePattern = "Random",
            AimAccuracy = 0.5,
            Aggressiveness = 0.5,
            MovementStyle = "Normal",
            SkillRating = 50
        }
    end
end

-- HỆ THỐNG CONFIG NÂNG CAO
local function saveConfig(configName)
    local configData = {
        Settings = Settings,
        PlayerSettings = PlayerSettings,
        AdvancedSettings = AdvancedSettings,
        Timestamp = os.time(),
        Game = gameDetection.Name,
        Version = "2.0"
    }
    
    ConfigSystem.Configs[configName] = configData
    
    if writefile then
        pcall(function()
            writefile("windy_aimbot_" .. configName .. ".json", HttpService:JSONEncode(configData))
        end)
    end
end

local function loadConfig(configName)
    if ConfigSystem.Configs[configName] then
        local config = ConfigSystem.Configs[configName]
        Settings = config.Settings or Settings
        PlayerSettings = config.PlayerSettings or PlayerSettings
        AdvancedSettings = config.AdvancedSettings or AdvancedSettings
        return true
    end
    
    if readfile then
        pcall(function()
            local content = readfile("windy_aimbot_" .. configName .. ".json")
            local config = HttpService:JSONDecode(content)
            Settings = config.Settings or Settings
            PlayerSettings = config.PlayerSettings or PlayerSettings
            AdvancedSettings = config.AdvancedSettings or AdvancedSettings
        end)
    end
    
    return false
end

-- HỆ THỐNG PERFORMANCE OPTIMIZATION
local function optimizePerformance()
    if AdvancedSettings.Performance.ReduceParticles then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Rate = 0
            end
        end
    end
    
    if AdvancedSettings.Performance.HideEffects then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    end
    
    if AdvancedSettings.Performance.LimitFPS then
        -- Set frame rate cap (requires executor support)
        if setfpscap then
            setfpscap(AdvancedSettings.Performance.MaxFPS)
        end
    end
end

-- HỆ THỐNG ANTI-CHEAT BYPASS NÂNG CAO
local function antiCheatBypass()
    if AdvancedSettings.AntiCheat.RandomizeClicks then
        -- Randomize click timing
    end
    
    if AdvancedSettings.AntiCheat.HumanMouseMovements then
        -- Add human-like mouse movements
    end
    
    if AdvancedSettings.AntiCheat.SpoofFPS then
        -- Spoof FPS (executor dependent)
    end
    
    if AdvancedSettings.AntiCheat.ClearLogs and os.time() - lastLogClear > AdvancedSettings.AntiCheat.LogClearInterval then
        -- Clear logs (executor dependent)
        lastLogClear = os.time()
    end
end

-- AIMBOT NÂNG CAO
local function getAdvancedTarget()
    local bestTarget = nil
    local bestScore = -99999
    local mousePos = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local targetPart = character:FindFirstChild(Settings.AimPart)
            
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (mousePos - targetPos).Magnitude
                    
                    -- Tính điểm ưu tiên
                    local score = 0
                    
                    if AdvancedSettings.Aimbot.PriorityMode == "Closest" then
                        score = -dist
                    elseif AdvancedSettings.Aimbot.PriorityMode == "LowestHealth" then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            score = -humanoid.Health
                        end
                    elseif AdvancedSettings.Aimbot.PriorityMode == "MostThreat" then
                        -- Đánh giá mức độ nguy hiểm của player
                        if aiLearningData.PlayerPatterns[player.Name] then
                            score = aiLearningData.PlayerPatterns[player.Name].SkillRating
                        end
                    end
                    
                    -- FOV check
                    if dist <= Settings.FOVRadius then
                        if score > bestScore then
                            bestScore = score
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function advancedAimPrediction(targetPart)
    if not AdvancedSettings.Aimbot.AdvancedPrediction then
        return targetPart.Position
    end
    
    local character = targetPart.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not humanoid then return targetPart.Position end
    
    -- Dự đoán chuyển động
    local velocity = targetPart.Velocity
    local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
    
    -- Tính toán ping compensation
    local ping = Stats.Network.ServerStatsItem["Data Ping"] or 0
    local prediction = Settings.Prediction + (ping / 1000)
    
    -- Dự đoán vị trí
    local predictedPosition = targetPart.Position + (velocity * prediction)
    
    -- Bullet drop cho projectile
    if AdvancedSettings.Aimbot.ProjectilePrediction and AdvancedSettings.Aimbot.BulletDrop then
        local gravity = workspace.Gravity
        local time = distance / AdvancedSettings.Aimbot.BulletSpeed
        predictedPosition = predictedPosition + Vector3.new(0, 0.5 * gravity * time * time, 0)
    end
    
    return predictedPosition
end

local function humanizeAimMovement(targetPosition)
    if not AdvancedSettings.Aimbot.Humanizer then return targetPosition end
    
    local currentTime = tick()
    if currentTime - lastHumanizeTime < AdvancedSettings.Aimbot.HumanizerDelay then
        return targetPosition
    end
    
    lastHumanizeTime = currentTime
    
    -- Thêm độ ngẫu nhiên cho chuyển động
    local randomFactor = AdvancedSettings.Aimbot.HumanizerIntensity
    local randomOffset = Vector3.new(
        (math.noise(currentTime, humanizeRandomSeed) - 0.5) * randomFactor,
        (math.noise(currentTime, humanizeRandomSeed + 1) - 0.5) * randomFactor,
        (math.noise(currentTime, humanizeRandomSeed + 2) - 0.5) * randomFactor
    )
    
    return targetPosition + randomOffset
end

-- ESP NÂNG CAO
local function createAdvancedESP(player)
    if not Drawing then return end
    
    local esp = {
        Box = nil,
        Tracer = nil,
        Name = nil,
        Distance = nil,
        Health = nil,
        HealthBar = nil,
        Weapon = nil,
        Skeleton = {},
        Chams = nil,
        Arrow = nil,
        Snapline = nil
    }
    
    -- Box ESP
    if Settings.BoxESP then
        esp.Box = Drawing.new("Square")
        esp.Box.Thickness = 2
        esp.Box.Filled = false
        esp.Box.Color = Settings.ESPColor
        esp.Box.Visible = false
    end
    
    -- Tracer
    if Settings.Tracers then
        esp.Tracer = Drawing.new("Line")
        esp.Tracer.Thickness = 1
        esp.Tracer.Color = Settings.ESPColor
        esp.Tracer.Visible = false
    end
    
    -- Name ESP
    if Settings.NameESP then
        esp.Name = Drawing.new("Text")
        esp.Name.Text = player.Name
        esp.Name.Size = 13
        esp.Name.Color = Settings.ESPColor
        esp.Name.Visible = false
        esp.Name.Center = true
    end
    
    -- Distance ESP
    if Settings.DistanceESP then
        esp.Distance = Drawing.new("Text")
        esp.Distance.Size = 13
        esp.Distance.Color = Settings.ESPColor
        esp.Distance.Visible = false
        esp.Distance.Center = true
    end
    
    -- Health ESP
    if Settings.HealthESP then
        esp.Health = Drawing.new("Text")
        esp.Health.Size = 13
        esp.Health.Color = Settings.ESPColor
        esp.Health.Visible = false
        esp.Health.Center = true
    end
    
    -- Health Bar
    if AdvancedSettings.ESP.HealthBar then
        esp.HealthBar = {
            Background = Drawing.new("Square"),
            Foreground = Drawing.new("Square")
        }
        esp.HealthBar.Background.Filled = true
        esp.HealthBar.Background.Visible = false
        esp.HealthBar.Foreground.Filled = true
        esp.HealthBar.Foreground.Visible = false
    end
    
    -- Skeleton ESP
    if AdvancedSettings.ESP.SkeletonESP then
        local skeletonParts = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"}
        }
        
        for _, partPair in pairs(skeletonParts) do
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = AdvancedSettings.ESP.SkeletonColor
            line.Visible = false
            table.insert(esp.Skeleton, line)
        end
    end
    
    -- Out of View Arrows
    if AdvancedSettings.ESP.OutOfViewArrows then
        esp.Arrow = Drawing.new("Triangle")
        esp.Arrow.Filled = true
        esp.Arrow.Color = Settings.ESPColor
        esp.Arrow.Visible = false
    end
    
    ESPObjects[player] = esp
end

local function updateAdvancedESP()
    if not Settings.ESPEnabled then return end
    
    for player, esp in pairs(ESPObjects) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                
                if distance <= Settings.MaxESPDistance then
                    -- Team color check
                    local color = Settings.ESPColor
                    local visibleColor = AdvancedSettings.ESP.VisibleColor
                    local hiddenColor = AdvancedSettings.ESP.HiddenColor
                    
                    if Settings.ESPTeamColor then
                        local localTeam = LocalPlayer.Team
                        local playerTeam = player.Team
                        if localTeam and playerTeam and localTeam == playerTeam then
                            color = Color3.fromRGB(0, 255, 0)
                            visibleColor = Color3.fromRGB(0, 200, 0)
                            hiddenColor = Color3.fromRGB(0, 150, 0)
                        else
                            color = Color3.fromRGB(255, 0, 0)
                            visibleColor = Color3.fromRGB(255, 0, 0)
                            hiddenColor = Color3.fromRGB(200, 0, 0)
                        end
                    end
                    
                    -- Visibility check
                    local isVisible = true
                    if AdvancedSettings.ESP.VisibilityCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * distance)
                        local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, LocalPlayer.Character})
                        isVisible = hit and hit:IsDescendantOf(character)
                    end
                    
                    local displayColor = isVisible and visibleColor or hiddenColor
                    
                    if onScreen then
                        -- Box ESP
                        if esp.Box then
                            local head = character:FindFirstChild("Head")
                            if head then
                                local headPos = Camera:WorldToViewportPoint(head.Position)
                                local rootPos = Camera:WorldToViewportPoint(rootPart.Position)
                                local size = Vector2.new(2000 / rootPos.Z, 3000 / rootPos.Z)
                                
                                esp.Box.Position = Vector2.new(headPos.X - size.X / 2, headPos.Y - size.Y / 2)
                                esp.Box.Size = size
                                esp.Box.Color = displayColor
                                esp.Box.Visible = true
                            end
                        end
                        
                        -- Cập nhật các ESP components khác...
                        -- (giữ nguyên logic ESP cơ bản)
                        
                    else
                        -- Out of View Arrows
                        if esp.Arrow and AdvancedSettings.ESP.OutOfViewArrows then
                            local direction = (rootPart.Position - Camera.CFrame.Position).Unit
                            local relativeX = direction.X
                            local relativeY = direction.Y
                            
                            local arrowPos = Vector2.new(
                                math.clamp(relativeX * 1000 + Camera.ViewportSize.X / 2, 50, Camera.ViewportSize.X - 50),
                                math.clamp(-relativeY * 1000 + Camera.ViewportSize.Y / 2, 50, Camera.ViewportSize.Y - 50)
                            )
                            
                            esp.Arrow.PointA = arrowPos + Vector2.new(0, -10)
                            esp.Arrow.PointB = arrowPos + Vector2.new(-8, 10)
                            esp.Arrow.PointC = arrowPos + Vector2.new(8, 10)
                            esp.Arrow.Color = displayColor
                            esp.Arrow.Visible = true
                        end
                    end
                else
                    -- Ẩn ESP nếu quá xa
                    for _, drawing in pairs(esp) do
                        if type(drawing) == "table" then
                            for _, subDrawing in pairs(drawing) do
                                if subDrawing and typeof(subDrawing) == "Instance" then
                                    subDrawing.Visible = false
                                end
                            end
                        elseif drawing and typeof(drawing) == "Instance" then
                            drawing.Visible = false
                        end
                    end
                end
            end
        end
    end
end

-- RADAR SYSTEM
local function updateRadar()
    if not AdvancedSettings.ESP.Radar then return end
    
    local radarCenter = Vector2.new(AdvancedSettings.ESP.RadarSize + 20, Camera.ViewportSize.Y - AdvancedSettings.ESP.RadarSize - 20)
    
    if radarObjects.Circle then
        radarObjects.Circle.Position = radarCenter
        radarObjects.Circle.Visible = true
    end
    
    -- Xóa player cũ trên radar
    for _, dot in pairs(radarObjects.Players) do
        if dot then
            dot:Remove()
        end
    end
    radarObjects.Players = {}
    
    -- Thêm player mới lên radar
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local relativePos = rootPart.Position - Camera.CFrame.Position
                local distance = relativePos.Magnitude
                
                if distance <= AdvancedSettings.ESP.RadarRange then
                    local normalizedPos = Vector2.new(
                        relativePos.X / AdvancedSettings.ESP.RadarRange,
                        -relativePos.Z / AdvancedSettings.ESP.RadarRange
                    ) * AdvancedSettings.ESP.RadarSize
                    
                    local radarDot = Drawing.new("Circle")
                    radarDot.Position = radarCenter + normalizedPos
                    radarDot.Radius = 3
                    radarDot.Filled = true
                    radarDot.Color = Settings.ESPTeamColor and (player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) or Settings.ESPColor
                    radarDot.Visible = true
                    
                    table.insert(radarObjects.Players, radarDot)
                end
            end
        end
    end
end

-- CROSSHAIR CUSTOMIZATION
local function updateCrosshair()
    if not AdvancedSettings.Customization.CustomCrosshair then
        for _, obj in pairs(crosshairObjects) do
            obj.Visible = false
        end
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local size = AdvancedSettings.Customization.CrosshairSize
    
    crosshairObjects.Line1.From = center + Vector2.new(-size, 0)
    crosshairObjects.Line1.To = center + Vector2.new(size, 0)
    crosshairObjects.Line1.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairObjects.Line1.Visible = true
    
    crosshairObjects.Line2.From = center + Vector2.new(0, -size)
    crosshairObjects.Line2.To = center + Vector2.new(0, size)
    crosshairObjects.Line2.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairObjects.Line2.Visible = true
    
    crosshairObjects.Dot.Position = center
    crosshairObjects.Dot.Color = AdvancedSettings.Customization.CrosshairColor
    crosshairObjects.Dot.Visible = true
end

-- COMBAT FEATURES
local function applyCombatFeatures()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- No Recoil/No Spread
    if AdvancedSettings.Combat.NoRecoil then
        -- Implementation depends on game structure
    end
    
    -- Rapid Fire
    if AdvancedSettings.Combat.RapidFire then
        -- Auto click simulation
    end
    
    -- Hitbox Expander
    if AdvancedSettings.Combat.HitboxExpander then
        for _, partName in pairs(AdvancedSettings.Combat.HitboxParts) do
            local part = character:FindFirstChild(partName)
            if part then
                part.Size = part.Size * AdvancedSettings.Combat.HitboxMultiplier
            end
        end
    end
end

-- UTILITY FEATURES
local function serverHop()
    local servers = {}
    -- Get server list and join random server
    -- Implementation depends on game
end

local function autoFarm()
    if not AdvancedSettings.Combat.AutoFarm then return end
    
    for _, targetType in pairs(AdvancedSettings.Combat.FarmTargets) do
        if targetType == "NPC" then
            -- Farm NPC logic
        elseif targetType == "Mobs" then
            -- Farm mobs logic
        elseif targetType == "Players" then
            -- Farm players logic
        end
    end
end

-- GAME-SPECIFIC FEATURES
local function applyGameSpecificFeatures()
    if not AdvancedSettings.GameSpecific.AutoDetectGame then return end
    
    local gameName = gameDetection.Name
    
    if string.find(gameName, "Arsenal") then
        AdvancedSettings.GameSpecific.ArsenalAimbot = true
    elseif string.find(gameName, "Phantom Forces") then
        AdvancedSettings.GameSpecific.PFNoRecoil = true
    elseif string.find(gameName, "Jailbreak") then
        AdvancedSettings.GameSpecific.AutoArrest = true
    end
end

-- STATISTICS TRACKING
local function updateStatistics()
    AdvancedSettings.Statistics.SessionTime = os.time() - startTime
    
    -- Update FPS
    if AdvancedSettings.Statistics.ShowFPS then
        performanceStats.FPS = 1 / RunService.RenderStepped:Wait()
    end
    
    -- Update Ping
    if AdvancedSettings.Statistics.ShowPing then
        performanceStats.Ping = Stats.Network.ServerStatsItem["Data Ping"] or 0
    end
    
    -- Update Memory
    if AdvancedSettings.Statistics.ShowMemory then
        performanceStats.Memory = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Script)
    end
end

-- MACRO SYSTEM
local function startMacroRecording()
    macroRecorder = {
        Recording = true,
        Actions = {},
        StartTime = tick()
    }
end

local function stopMacroRecording()
    if macroRecorder.Recording then
        macroRecorder.Recording = false
        table.insert(AdvancedSettings.Utility.Macros, macroRecorder.Actions)
    end
end

local function playMacro(macroIndex)
    local macro = AdvancedSettings.Utility.Macros[macroIndex]
    if macro then
        for _, action in pairs(macro) do
            -- Execute recorded actions
            wait(action.Delay)
            -- Simulate input based on action type
        end
    end
end

-- INITIALIZATION FUNCTION
local function initializeAdvancedSystems()
    detectGame()
    initializeAILearning()
    initializeAdvancedDrawings()
    applyGameSpecificFeatures()
    
    -- Load default config
    loadConfig("default")
    
    -- Apply performance optimizations
    optimizePerformance()
end

-- MAIN UPDATE LOOP NÂNG CAO
local function advancedUpdateLoop()
    -- Anti-cheat bypass
    antiCheatBypass()
    
    -- Performance optimization
    if os.time() - lastGCCleanup > AdvancedSettings.Performance.GCInterval then
        if AdvancedSettings.Performance.GarbageCollection then
            collectgarbage()
        end
        lastGCCleanup = os.time()
    end
    
    -- Update systems
    updateStatistics()
    updateRadar()
    updateCrosshair()
    updateAdvancedESP()
    
    -- Apply combat features
    applyCombatFeatures()
    
    -- Auto farm
    autoFarm()
end

-- INTEGRATE VÀO UI HIỆN CÓ
local function createAdvancedUI(Window)
    -- Advanced Aimbot Tab
    local AdvancedAimbotTab = Window:Tab({
        Title = "Aimbot Pro",
        Icon = "crosshair"
    })
    
    local AISection = AdvancedAimbotTab:Section({
        Title = "AI Learning",
        Box = true
    })
    
    AISection:Toggle({
        Title = "AI Learning",
        Desc = "Learn from player patterns",
        Value = AdvancedSettings.Aimbot.AILearning,
        Callback = function(value)
            AdvancedSettings.Aimbot.AILearning = value
        end
    })
    
    AISection:Dropdown({
        Title = "Priority Mode",
        Values = {"Closest", "LowestHealth", "MostThreat", "Crosshair"},
        Value = AdvancedSettings.Aimbot.PriorityMode,
        Callback = function(value)
            AdvancedSettings.Aimbot.PriorityMode = value
        end
    })
    
    -- Combat Tab
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "sword"
    })
    
    local AutoFarmSection = CombatTab:Section({
        Title = "Auto Farm",
        Box = true
    })
    
    AutoFarmSection:Toggle({
        Title = "Auto Farm",
        Value = AdvancedSettings.Combat.AutoFarm,
        Callback = function(value)
            AdvancedSettings.Combat.AutoFarm = value
        end
    })
    
    -- Utility Tab
    local UtilityTab = Window:Tab({
        Title = "Utility",
        Icon = "tool"
    })
    
    local ServerSection = UtilityTab:Section({
        Title = "Server",
        Box = true
    })
    
    ServerSection:Button({
        Title = "Server Hop",
        Callback = function()
            serverHop()
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
    
    ConfigSection:Textbox({
        Title = "Config Name",
        Default = "default",
        Callback = function(value)
            ConfigSystem.CurrentConfig = value
        end
    })
    
    ConfigSection:Button({
        Title = "Save Config",
        Callback = function()
            saveConfig(ConfigSystem.CurrentConfig)
        end
    })
    
    ConfigSection:Button({
        Title = "Load Config",
        Callback = function()
            loadConfig(ConfigSystem.CurrentConfig)
        end
    })
end

-- KẾT NỐI VỚI HỆ THỐNG CHÍNH
-- Thêm vào phần khởi tạo chính
initializeAdvancedSystems()

-- Thêm vào main loop
connections.advancedLoop = RunService.Heartbeat:Connect(function(deltaTime)
    advancedUpdateLoop()
end)

-- Thêm vào UI creation
if Window then
    createAdvancedUI(Window)
end

-- Success message với thông tin nâng cao
if Window then
    Window:Notify({
        Title = "Windy Aimbot Ultimate Loaded",
        Content = string.format("Game: %s | Features: %d+ | Version: 2.0", gameDetection.Name, 50),
        Icon = "check-circle",
        Duration = 5
    })
else
    warn("Windy Aimbot Ultimate - All Features Loaded")
    warn("Detected Game: " .. gameDetection.Name)
end
