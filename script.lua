--====================================================--
--                     .binh Hub                     --
--                FULL SCRIPT (Parts 1-7)            --
--   ESP | AIMBOT | MOVEMENT | TELEPORT | RADAR      --
-- PERFORMANCE | THEME | CONFIG | WINDUI INTEGRATION --
--====================================================--

-- ======================== --
--        SERVICES          --
-- ======================== --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local GameSettings = UserSettings():GetService("UserGameSettings")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======================== --
--        CONFIG & THEME    --
-- ======================== --
local CONFIG_FILE = "binh_hub_config.json"

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

local defaultConfig = {
    -- ESP
    ESPEnabled = false,
    ESPTeamCheck = false,
    ESPWallCheck = false,
    ESPDistance = 200,

    -- Aimbot
    AimEnabled = false,
    AimTeamCheck = false,
    AimWallCheck = false,
    AimDistance = 200,
    SmoothStrength = 0.25,
    AimFOV = 100,
    ShowAimFOV = false,
    -- AimKey saved as {kind="UserInputType"/"KeyCode", name="MouseButton2"/"Q"}
    AimKey = {kind = "UserInputType", name = "MouseButton2"},

    -- Movement
    FlyEnabled = false,
    NoclipEnabled = false,
    AntiFlingEnabled = false,
    FlySpeed = 50,
    WalkSpeed = 16,

    -- Teleport
    TeleportEnabled = false,
    SavePositionsEnabled = false,
    SavedPositions = {}, -- map slot-> {x,y,z}

    -- Radar
    RadarEnabled = false,
    ShowEnemyFOV = false,
    SoundVisualization = false,
    ObjectiveTracker = false,

    -- Performance
    PerformanceEnabled = false,
    AutoFPSBoost = false,
    MemoryCleaner = false,
    RenderDistanceManager = false,

    -- UI
    CurrentTheme = "Default"
}

local Config = {}
for k,v in pairs(defaultConfig) do Config[k] = v end

-- ======================== --
--   Helpers: serialize     --
-- ======================== --
local function vec3ToTable(v)
    return {x = v.X, y = v.Y, z = v.Z}
end
local function tableToVec3(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function saveConfig()
    local s = {}
    for k,v in pairs(Config) do
        if k == "AimKey" then
            s[k] = v
        elseif k == "SavedPositions" then
            local out = {}
            for slot, pos in pairs(v) do
                out[slot] = vec3ToTable(pos)
            end
            s[k] = out
        else
            s[k] = v
        end
    end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(s))
    end)
    print("[.binh Hub] Config saved.")
end

local function loadConfig()
    if not isfile(CONFIG_FILE) then
        print("[.binh Hub] No config file found; using defaults.")
        return
    end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if not ok or type(data) ~= "table" then
        print("[.binh Hub] Failed to load config; using defaults.")
        return
    end

    for k,v in pairs(data) do
        if k == "SavedPositions" and type(v) == "table" then
            local out = {}
            for slot, posT in pairs(v) do
                if type(posT) == "table" and posT.x then
                    out[slot] = tableToVec3(posT)
                end
            end
            Config.SavedPositions = out
        elseif k == "AimKey" and type(v) == "table" and v.kind and v.name then
            Config.AimKey = v
        else
            Config[k] = v
        end
    end
    print("[.binh Hub] Config loaded.")
end

loadConfig()

-- ======================== --
--        THEME HELPERS    --
-- ======================== --
local function applyTheme(themeName)
    if not Themes[themeName] then themeName = "Default" end
    Config.CurrentTheme = themeName
    -- Update drawing objects' colors dynamically elsewhere where used
    print("[.binh Hub] Applied theme:", themeName)
end

-- ======================== --
--          WINDUI         --
-- (load safely, fallback to raw fetch)
-- ======================== --
local WindUI
do
    local ok, module = pcall(function() return require("./src/Init") end)
    if ok then
        WindUI = module
    else
        local ok2, res = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua", true))()
        end)
        if ok2 then WindUI = res else WindUI = nil end
    end
end

-- ======================== --
--         DRAWING         --
-- ======================== --
local Drawing = Drawing or (function() error("Drawing API not available") end)

-- clean up function for Drawing tables
local function removeDrawingSet(set)
    if not set then return end
    for _, obj in pairs(set) do
        pcall(function() obj:Remove() end)
    end
end

-- ======================== --
--          ESP            --
-- ======================== --
local ESP = {Objects = {}}

local function createESPForPlayer(plr)
    if ESP.Objects[plr] then return end
    local set = {}
    set.Box = Drawing.new("Square")
    set.Name = Drawing.new("Text")
    set.Distance = Drawing.new("Text")
    set.Tracer = Drawing.new("Line")

    set.Box.Thickness = 2
    set.Box.Filled = false
    set.Box.Color = Themes[Config.CurrentTheme].Primary

    set.Name.Size = 13
    set.Name.Outline = true
    set.Name.Color = Themes[Config.CurrentTheme].Text
    set.Name.Center = true

    set.Distance.Size = 13
    set.Distance.Outline = true
    set.Distance.Color = Themes[Config.CurrentTheme].Text
    set.Distance.Center = true

    set.Tracer.Thickness = 2
    set.Tracer.Color = Themes[Config.CurrentTheme].Primary

    ESP.Objects[plr] = set
end

local function removeESPForPlayer(plr)
    if ESP.Objects[plr] then
        removeDrawingSet(ESP.Objects[plr])
        ESP.Objects[plr] = nil
    end
end

local function updateESP()
    if not Config.ESPEnabled then
        for p in pairs(ESP.Objects) do removeESPForPlayer(p) end
        return
    end

    for _, target in pairs(Players:GetPlayers()) do
        if target == LocalPlayer then continue end
        if not target.Character then removeESPForPlayer(target) continue end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then removeESPForPlayer(target) continue end

        if Config.ESPTeamCheck and target.Team == LocalPlayer.Team then removeESPForPlayer(target) continue end

        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or math.huge
        if distance > Config.ESPDistance then removeESPForPlayer(target) continue end

        if Config.ESPWallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local ray = Workspace:Raycast(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position), rayParams)
            if ray and ray.Instance and not ray.Instance:IsDescendantOf(target.Character) then
                removeESPForPlayer(target)
                continue
            end
        end

        createESPForPlayer(target)
        local set = ESP.Objects[target]

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local boxW = math.clamp(2000 / pos.Z, 20, 300)
            local boxH = math.clamp(3000 / pos.Z, 40, 500)

            set.Box.Size = Vector2.new(boxW, boxH)
            set.Box.Position = Vector2.new(pos.X - boxW/2, pos.Y - boxH/2)
            set.Box.Visible = true

            set.Name.Text = target.Name
            set.Name.Position = Vector2.new(pos.X, pos.Y - boxH/2 - 12)
            set.Name.Visible = true

            set.Distance.Text = string.format("[%dm]", math.floor(distance))
            set.Distance.Position = Vector2.new(pos.X, pos.Y + boxH/2 + 6)
            set.Distance.Visible = true

            set.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            set.Tracer.To = Vector2.new(pos.X, pos.Y + boxH/2)
            set.Tracer.Visible = true
        else
            for _, d in pairs(set) do d.Visible = false end
        end
    end
end

-- cleanup on player leaving
Players.PlayerRemoving:Connect(function(plr) removeESPForPlayer(plr) end)

-- ======================== --
--         AIMBOT           --
-- ======================== --
local AimFOVCircle = nil
local waitingForAimKey = false

local function createAimFOVCircle()
    if AimFOVCircle then
        pcall(function() AimFOVCircle:Remove() end)
        AimFOVCircle = nil
    end
    if Config.ShowAimFOV and Config.AimEnabled then
        AimFOVCircle = Drawing.new("Circle")
        AimFOVCircle.Visible = true
        AimFOVCircle.Thickness = 2
        AimFOVCircle.Color = Themes[Config.CurrentTheme].Primary
        AimFOVCircle.Filled = false
        AimFOVCircle.Transparency = 1
        AimFOVCircle.Radius = Config.AimFOV
        AimFOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

local function updateAimFOVCircle()
    if AimFOVCircle then
        AimFOVCircle.Radius = Config.AimFOV
        AimFOVCircle.Color = Themes[Config.CurrentTheme].Primary
        AimFOVCircle.Visible = Config.ShowAimFOV and Config.AimEnabled
        -- center it on screen center
        AimFOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    else
        if Config.ShowAimFOV and Config.AimEnabled then createAimFOVCircle() end
    end
end

-- convert input to AimKey table
local function aimKeyFromInput(input)
    -- if keyboard, use KeyCode
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode and input.KeyCode.Name then
            return {kind = "KeyCode", name = input.KeyCode.Name}
        end
    else
        -- mouse/button types
        local uit = input.UserInputType
        if uit and uit.Name then
            return {kind = "UserInputType", name = uit.Name}
        end
    end
    return Config.AimKey
end

local function setAimKeyFromInput(input)
    local key = aimKeyFromInput(input)
    if key then
        Config.AimKey = key
        print("[.binh Hub] Aim key set to:", key.kind, key.name)
    end
end

local function aimKeyDisplayName()
    if Config.AimKey.kind == "KeyCode" then
        return tostring(Config.AimKey.name)
    else
        return tostring(Config.AimKey.name)
    end
end

local function isAimPressed()
    if Config.AimKey.kind == "KeyCode" then
        local k = Enum.KeyCode[Config.AimKey.name]
        if not k then return false end
        return UserInputService:IsKeyDown(k)
    else
        local u = Enum.UserInputType[Config.AimKey.name]
        if not u then return false end
        -- Mouse buttons check via IsMouseButtonPressed expects Enum.UserInputType values
        if u == Enum.UserInputType.MouseButton1 or u == Enum.UserInputType.MouseButton2 or u == Enum.UserInputType.MouseButton3 then
            return UserInputService:IsMouseButtonPressed(u)
        else
            -- other types fallback to IsKeyDown? unlikely
            return UserInputService:IsKeyDown(Enum.KeyCode[Config.AimKey.name]) or false
        end
    end
end

local function getClosestAimbotTarget()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local best = nil
    local bestDist = Config.AimFOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then continue end
        if Config.AimTeamCheck and plr.Team == LocalPlayer.Team then continue end

        local worldToScreen, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local distFromCenter = (center - Vector2.new(worldToScreen.X, worldToScreen.Y)).Magnitude
        if distFromCenter <= Config.AimFOV and distFromCenter < bestDist then
            -- distance check in world
            local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if worldDist > Config.AimDistance then continue end

            if Config.AimWallCheck then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, plr.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local ray = Workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, rayParams)
                if ray and ray.Instance and not ray.Instance:IsDescendantOf(plr.Character) then
                    continue
                end
            end

            best = hrp
            bestDist = distFromCenter
        end
    end
    return best
end

-- ======================== --
--        MOVEMENT         --
--   Fly, Noclip, AntiFling --
-- ======================== --
local flyConnection = nil
local noclipConnection = nil
local antiFlingConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local function enableFly(flag)
    Config.FlyEnabled = flag
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if not flag then
        if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
        if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
        return
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = root

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
    end

    flyConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local root = LocalPlayer.Character.HumanoidRootPart
        local cam = Workspace.CurrentCamera
        local vel = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel + Vector3.new(0,-1,0) end
        vel = vel.Unit == vel and Vector3.new(0,0,0) or vel
        if vel.Magnitude > 0 then
            bodyVelocity.Velocity = vel.Unit * Config.FlySpeed
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function enableNoclip(flag)
    Config.NoclipEnabled = flag
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if not flag then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function enableAntiFling(flag)
    Config.AntiFlingEnabled = flag
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    if not flag then return end
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0,0,0)
                    part.RotVelocity = Vector3.new(0,0,0)
                    part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    part.AssemblyAngularVelocity = Vector3.new(0,0,0)
                end
            end
        end
    end)
end

-- Ensure movement re-enabled after respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.8)
    if Config.FlyEnabled then enableFly(true) end
    if Config.NoclipEnabled then enableNoclip(true) end
    if Config.AntiFlingEnabled then enableAntiFling(true) end
end)

-- ======================== --
--        TELEPORT         --
--  Save slots / spawn / objective / safe spot
-- ======================== --
local SavedPositions = Config.SavedPositions or {}

local function saveCurrentPosition(slot)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    SavedPositions[slot] = LocalPlayer.Character.HumanoidRootPart.Position
    Config.SavedPositions = SavedPositions
    saveConfig()
    print("[.binh Hub] Saved position slot:", slot)
    return true
end

local function teleportToPosition(pos)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    hrp.CFrame = CFrame.new(pos + Vector3.new(0,2,0))
    return true
end

local function teleportToSaved(slot)
    local p = SavedPositions[slot]
    if p then teleportToPosition(p) print("[.binh Hub] Teleported to slot:", slot) return true end
    print("[.binh Hub] No saved position in slot:", slot)
    return false
end

local function teleportToSpawn()
    -- look for spawn locations in Workspace
    local found = nil
    if Workspace:FindFirstChildWhichIsA("SpawnLocation") then
        found = Workspace:FindFirstChildWhichIsA("SpawnLocation")
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") or string.match(string.lower(obj.Name), "spawn") then
                found = obj
                break
            end
        end
    end
    if found and found:IsA("BasePart") then
        teleportToPosition(found.Position)
        print("[.binh Hub] Teleported to spawn.")
        return true
    end
    print("[.binh Hub] Spawn not found.")
    return false
end

local function teleportToObjective()
    local objectives = Workspace:FindFirstChild("Objectives") or Workspace:FindFirstChild("Flags") or Workspace:FindFirstChild("ControlPoints")
    if objectives then
        for _, obj in pairs(objectives:GetChildren()) do
            if obj:IsA("BasePart") then
                teleportToPosition(obj.Position)
                print("[.binh Hub] Teleported to objective.")
                return true
            end
        end
    end
    -- fallback: search for parts with common objective names
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "flag") or string.find(string.lower(obj.Name), "objective") or string.find(string.lower(obj.Name), "point")) then
            teleportToPosition(obj.Position)
            print("[.binh Hub] Teleported to objective (fallback).")
            return true
        end
    end
    print("[.binh Hub] No objective found.")
    return false
end

local function findSafeSpot()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local candidates = {}

    -- search for large parts that can be cover
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Size.Magnitude > 20 then
            local offset = part.CFrame.LookVector * (part.Size.Z/2 + 3)
            local coverPos = part.Position + offset
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local ray = Workspace:Raycast(coverPos + Vector3.new(0,5,0), Vector3.new(0,-10,0), params)
            if ray and ray.Instance then
                table.insert(candidates, coverPos + Vector3.new(0,3,0))
            end
        end
    end

    if #candidates > 0 then
        return candidates[math.random(1,#candidates)]
    else
        return myPos + Vector3.new(math.random(-20,20), 0, math.random(-20,20))
    end
end

local function teleportToSafeSpot()
    local pos = findSafeSpot()
    if pos then
        teleportToPosition(pos)
        print("[.binh Hub] Teleported to safe spot.")
        return true
    end
    print("[.binh Hub] Could not find safe spot.")
    return false
end

-- ======================== --
--         RADAR GUI       --
-- ======================== --
local radarGui = nil
local radarFrame = nil
local radarBlips = {} -- maps player->frame

local function createRadar()
    if radarGui then radarGui:Destroy() radarGui = nil end
    if not Config.RadarEnabled then return end

    radarGui = Instance.new("ScreenGui")
    radarGui.Name = ".binhRadarGui"
    radarGui.Parent = PlayerGui

    radarFrame = Instance.new("Frame")
    radarFrame.Size = UDim2.new(0, 250, 0, 250)
    radarFrame.Position = UDim2.new(0, 10, 0, 10)
    radarFrame.BackgroundColor3 = Themes[Config.CurrentTheme].Background
    radarFrame.BackgroundTransparency = 0.3
    radarFrame.BorderSizePixel = 0
    radarFrame.Parent = radarGui

    local border = Instance.new("UIStroke")
    border.Parent = radarFrame
    border.Color = Themes[Config.CurrentTheme].Primary
    border.Thickness = 2

    local center = Instance.new("Frame")
    center.Size = UDim2.new(0,4,0,4)
    center.Position = UDim2.new(0.5,-2,0.5,-2)
    center.BackgroundColor3 = Themes[Config.CurrentTheme].Secondary
    center.BorderSizePixel = 0
    center.Parent = radarFrame
end

local function destroyRadar()
    if radarGui then radarGui:Destroy() radarGui = nil radarBlips = {} end
end

local function updateRadar()
    if not Config.RadarEnabled then
        destroyRadar()
        return
    end
    if not radarGui then createRadar() end
    if not radarFrame then return end
    -- remove old blips
    for _, f in pairs(radarBlips) do
        if f and f.Parent then f:Destroy() end
    end
    radarBlips = {}

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local cam = Workspace.CurrentCamera
    local range = 150 -- world units mapping to radar
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = plr.Character.HumanoidRootPart
        local rel = hrp.Position - myPos
        if rel.Magnitude > range then continue end

        local x = (rel.X / range) * (radarFrame.AbsoluteSize.X/2) + radarFrame.AbsoluteSize.X/2
        local y = (-rel.Z / range) * (radarFrame.AbsoluteSize.Y/2) + radarFrame.AbsoluteSize.Y/2

        local blip = Instance.new("Frame")
        blip.Size = UDim2.new(0,8,0,8)
        blip.Position = UDim2.new(0, x-4, 0, y-4)
        blip.BackgroundColor3 = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0,200,0) or Color3.fromRGB(255,50,50)
        blip.BorderSizePixel = 0
        blip.Parent = radarFrame
        radarBlips[plr] = blip

        -- optionally show enemy FOV indicator or objective markers etc.
    end
end

-- ======================== --
--      PERFORMANCE        --
-- ======================== --
local perfConnection = nil
local originalSettings = {}

local function saveOriginalSettings()
    pcall(function()
        originalSettings.SavedQualityLevel = GameSettings.SavedQualityLevel.Value
        originalSettings.MasterVolume = GameSettings.MasterVolume
        originalSettings.RenderingDistance = Camera.MaxDistance
        originalSettings.GlobalShadows = Lighting.GlobalShadows
        originalSettings.Brightness = Lighting.Brightness
    end)
end

local function applyPerformanceMode()
    if Config.AutoFPSBoost then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            GameSettings.SavedQualityLevel.Value = 1
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100
            Lighting.Brightness = 2
            -- disable particle-like effects
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                end
            end
        end)
    end

    if Config.MemoryCleaner then
        pcall(function()
            collectgarbage("collect")
        end)
    end

    if Config.RenderDistanceManager then
        pcall(function()
            Camera.MaxDistance = 500
        end)
    end
end

local function restoreOriginalSettings()
    pcall(function()
        if originalSettings.SavedQualityLevel then GameSettings.SavedQualityLevel.Value = originalSettings.SavedQualityLevel end
        if originalSettings.MasterVolume then GameSettings.MasterVolume = originalSettings.MasterVolume end
        if originalSettings.RenderingDistance then Camera.MaxDistance = originalSettings.RenderingDistance end
        if originalSettings.GlobalShadows ~= nil then Lighting.GlobalShadows = originalSettings.GlobalShadows end
        if originalSettings.Brightness then Lighting.Brightness = originalSettings.Brightness end
    end)
end

local function togglePerformance(flag)
    Config.PerformanceEnabled = flag
    if perfConnection then perfConnection:Disconnect() perfConnection = nil end
    if flag then
        saveOriginalSettings()
        perfConnection = RunService.Heartbeat:Connect(function()
            applyPerformanceMode()
        end)
    else
        restoreOriginalSettings()
    end
end

-- ======================== --
--        INPUTS            --
-- Aim key binding and generic input handling
-- ======================== --
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- If waiting for key bind
    if waitingForAimKey then
        setAimKeyFromInput(input)
        waitingForAimKey = false
        saveConfig()
    end
end)

-- convenient toggle on a hotkey (optional)
-- Example: press RightBracket to toggle UI or features (customize if desired)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightBracket then
        -- toggle ESP quick (example)
        Config.ESPEnabled = not Config.ESPEnabled
    end
end)

-- ======================== --
--      MAIN LOOPS         --
-- ======================== --
RunService.RenderStepped:Connect(function()
    -- update ESP drawings and aim circle each frame
    pcall(updateESP)
    pcall(updateAimFOVCircle)

    -- aim behavior
    if Config.AimEnabled and isAimPressed() then
        local targetHRP = getClosestAimbotTarget()
        if targetHRP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local camCF = Camera.CFrame
            local lookAt = CFrame.lookAt(camCF.Position, targetHRP.Position)
            local newCF = camCF:Lerp(lookAt, Config.SmoothStrength)
            Camera.CFrame = newCF
        end
    end
end)

-- radar updating on heartbeat (less frequent)
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.RadarEnabled then updateRadar() end
        -- auto-perf memory cleaner occasionally
        if Config.MemoryCleaner and tick() % 5 < 0.05 then
            collectgarbage("collect")
        end
    end)
end)

-- ======================== --
--      WINDUI BUILD       --
-- ======================== --
if WindUI then
    local Window = WindUI:CreateWindow({
        Title = ".binh Hub | WindUI",
        Author = "by .binh",
        Folder = "binh",
        Icon = "https://github.com/philiptran16-png/binh-script/raw/main/Minimalistic_and_elegant_B_logo_monochrome_no_colors_clean_lines_modern_design_geometric.png",
        IconSize = 44,
        NewElements = true,
        OpenButton = {
            Title = "Open .binh Hub UI",
            CornerRadius = UDim.new(1,0),
            StrokeThickness = 3,
            Enabled = true,
            Draggable = true,
            Color = ColorSequence.new(Themes[Config.CurrentTheme].Primary, Themes[Config.CurrentTheme].Secondary)
        }
    })

    -- ESP Tab
    local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
    ESPTab:Toggle({Title = "Enable ESP", Desc = "Hiển thị người chơi", Default = Config.ESPEnabled, Callback = function(state) Config.ESPEnabled = state saveConfig() end})
    ESPTab:Toggle({Title = "Team Check ESP", Desc = "Chỉ hiện người khác team", Default = Config.ESPTeamCheck, Callback = function(state) Config.ESPTeamCheck = state saveConfig() end})
    ESPTab:Toggle({Title = "Wall Check", Desc = "Ẩn người chơi bị che khuất", Default = Config.ESPWallCheck, Callback = function(state) Config.ESPWallCheck = state saveConfig() end})
    ESPTab:Slider({Title = "ESP Distance", Min = 50, Max = 500, Default = Config.ESPDistance, Callback = function(value) Config.ESPDistance = value saveConfig() end})

    -- Aimbot Tab
    local AimTab = Window:Tab({Title = "Aimbot", Icon = "target"})
    AimTab:Toggle({Title = "Enable AIM", Desc = "Aim vào đầu đối thủ", Default = Config.AimEnabled, Callback = function(state) Config.AimEnabled = state saveConfig() updateAimFOVCircle() end})
    AimTab:Toggle({Title = "Team Check AIM", Desc = "Chỉ aim người khác team", Default = Config.AimTeamCheck, Callback = function(state) Config.AimTeamCheck = state saveConfig() end})
    AimTab:Toggle({Title = "Wall Check", Desc = "Không aim nếu đối thủ bị che khuất", Default = Config.AimWallCheck, Callback = function(state) Config.AimWallCheck = state saveConfig() end})
    AimTab:Slider({Title = "Aim Distance", Min = 50, Max = 500, Default = Config.AimDistance, Callback = function(value) Config.AimDistance = value saveConfig() end})
    AimTab:Slider({Title = "Smooth Strength", Min = 0.01, Max = 1, Step = 0.01, Default = Config.SmoothStrength, Callback = function(value) Config.SmoothStrength = value saveConfig() end})
    AimTab:Slider({Title = "Aim FOV", Min = 50, Max = 300, Default = Config.AimFOV, Callback = function(value) Config.AimFOV = value saveConfig() end})
    AimTab:Toggle({Title = "Show FOV Circle", Desc = "Hiển thị vòng FOV trên màn hình", Default = Config.ShowAimFOV, Callback = function(state) Config.ShowAimFOV = state saveConfig() updateAimFOVCircle() end})
    AimTab:Button({Title = "Aimbot Key: (Press to set)", Desc = "Nhấn để đổi phím aimbot (chuột/ bàn phím)", Callback = function()
        waitingForAimKey = true
        print("[.binh Hub] Press a key or mouse button to bind AimKey...")
    end})

    -- Movement Tab
    local MoveTab = Window:Tab({Title = "Movement", Icon = "arrow-up-right"})
    MoveTab:Toggle({Title = "Fly", Desc = "Bay tự do WSAD + Space + Ctrl", Default = Config.FlyEnabled, Callback = function(state) enableFly(state) saveConfig() end})
    MoveTab:Toggle({Title = "Noclip", Desc = "Đi xuyên tường", Default = Config.NoclipEnabled, Callback = function(state) enableNoclip(state) saveConfig() end})
    MoveTab:Toggle({Title = "Anti Fling", Desc = "Chống văng nhân vật bởi lực ngoài", Default = Config.AntiFlingEnabled, Callback = function(state) enableAntiFling(state) saveConfig() end})
    MoveTab:Slider({Title = "Fly Speed", Min = 10, Max = 250, Default = Config.FlySpeed, Callback = function(v) Config.FlySpeed = v saveConfig() end})

    -- Teleport Tab
    local TeleportTab = Window:Tab({Title = "Teleport", Icon = "navigation"})
    TeleportTab:Toggle({Title = "Enable Teleport", Desc = "Kích hoạt hệ thống dịch chuyển", Default = Config.TeleportEnabled, Callback = function(state) Config.TeleportEnabled = state saveConfig() end})
    TeleportTab:Toggle({Title = "Lưu Vị Trí", Desc = "Cho phép lưu vị trí vào slot", Default = Config.SavePositionsEnabled, Callback = function(state) Config.SavePositionsEnabled = state saveConfig() end})
    TeleportTab:Button({Title = "💾 Lưu Vị Trí 1", Desc = "Lưu vị trí hiện tại vào slot 1", Callback = function() if Config.SavePositionsEnabled then saveCurrentPosition("Position1") else print("[.binh Hub] Enable Save Positions first!") end end})
    TeleportTab:Button({Title = "🚀 Dịch đến Vị Trí 1", Desc = "Dịch đến slot 1", Callback = function() if Config.TeleportEnabled then teleportToSaved("Position1") else print("[.binh Hub] Enable Teleport first!") end end})
    TeleportTab:Button({Title = "🏠 Dịch đến Spawn", Desc = "Dịch đến spawn point", Callback = function() if Config.TeleportEnabled then teleportToSpawn() else print("[.binh Hub] Enable Teleport first!") end end})
    TeleportTab:Button({Title = "🎯 Dịch đến Mục Tiêu", Desc = "Dịch đến objective", Callback = function() if Config.TeleportEnabled then teleportToObjective() else print("[.binh Hub] Enable Teleport first!") end end})
    TeleportTab:Button({Title = "🛡️ Dịch đến Vị Trí An Toàn", Desc = "Dịch đến safe spot", Callback = function() if Config.TeleportEnabled then teleportToSafeSpot() else print("[.binh Hub] Enable Teleport first!") end end})

    -- Radar Tab
    local RadarTab = Window:Tab({Title = "Radar", Icon = "map"})
    RadarTab:Toggle({Title = "Enable Radar", Desc = "Bật/tắt radar minimap", Default = Config.RadarEnabled, Callback = function(state) Config.RadarEnabled = state if state then createRadar() else destroyRadar() end saveConfig() end})
    RadarTab:Toggle({Title = "Enemy FOV", Desc = "Hiển thị tầm nhìn của kẻ địch", Default = Config.ShowEnemyFOV, Callback = function(state) Config.ShowEnemyFOV = state saveConfig() end})
    RadarTab:Toggle({Title = "Sound Visualization", Desc = "Hiển thị vị trí âm thanh", Default = Config.SoundVisualization, Callback = function(state) Config.SoundVisualization = state saveConfig() end})
    RadarTab:Toggle({Title = "Objective Tracker", Desc = "Theo dõi mục tiêu", Default = Config.ObjectiveTracker, Callback = function(state) Config.ObjectiveTracker = state saveConfig() end})

    -- Performance Tab
    local PerformanceTab = Window:Tab({Title = "Performance", Icon = "zap"})
    PerformanceTab:Toggle({Title = "Performance Mode", Desc = "Bật tối ưu hiệu suất", Default = Config.PerformanceEnabled, Callback = function(state) togglePerformance(state) saveConfig() end})
    PerformanceTab:Toggle({Title = "Auto FPS Boost", Desc = "Tự động tăng FPS", Default = Config.AutoFPSBoost, Callback = function(state) Config.AutoFPSBoost = state saveConfig() end})
    PerformanceTab:Toggle({Title = "Memory Cleaner", Desc = "Dọn bộ nhớ", Default = Config.MemoryCleaner, Callback = function(state) Config.MemoryCleaner = state saveConfig() end})
    PerformanceTab:Toggle({Title = "Render Distance Manager", Desc = "Quản lý distance", Default = Config.RenderDistanceManager, Callback = function(state) Config.RenderDistanceManager = state saveConfig() end})

    -- Settings Tab
    local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
    SettingsTab:Button({Title = "Save Config", Desc = "Lưu cấu hình vào file", Callback = function() saveConfig() end})
    SettingsTab:Button({Title = "Load Config", Desc = "Tải cấu hình", Callback = function() loadConfig() end})
    SettingsTab:Dropdown({Title = "Theme", List = {"Default","Dark","Blue","Pink"}, Callback = function(theme) applyTheme(theme) saveConfig() end})
end -- end WindUI

-- finalize initial drawing + radar creation
updateAimFOVCircle()
if Config.RadarEnabled then createRadar() end

print("[.binh Hub] Full script 1-7 loaded. Enjoy!")

