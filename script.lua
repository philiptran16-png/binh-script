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
    Default = {Primary = Color3.fromHex("#30FF6A"), Secondary = Color3.fromHex("#e7ff2f"), Background = Color3.fromHex("#1a1a1a"), Text = Color3.fromHex("#ffffff")},
    Dark = {Primary = Color3.fromHex("#FF6B35"), Secondary = Color3.fromHex("#FFE66D"), Background = Color3.fromHex("#0a0a0a"), Text = Color3.fromHex("#f0f0f0")},
    Blue = {Primary = Color3.fromHex("#4A90E2"), Secondary = Color3.fromHex("#7ED321"), Background = Color3.fromHex("#0f1f33"), Text = Color3.fromHex("#e6f7ff")},
    Pink = {Primary = Color3.fromHex("#FF6B9D"), Secondary = Color3.fromHex("#FFE74C"), Background = Color3.fromHex("#2d1a2d"), Text = Color3.fromHex("#fff0f5")}
}

local defaultConfig = {
    ESPEnabled = false,
    ESPTeamCheck = false,
    ESPWallCheck = false,
    ESPDistance = 200,
    LineESPEnabled = true,
    AimEnabled = false,
    AimTeamCheck = false,
    AimWallCheck = false,
    AimDistance = 200,
    SmoothStrength = 0.25,
    AimFOV = 100,
    ShowAimFOV = false,
    AimKey = {kind = "UserInputType", name = "MouseButton2"},
    FlyEnabled = false,
    NoclipEnabled = false,
    AntiFlingEnabled = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    TeleportEnabled = false,
    SavePositionsEnabled = false,
    SavedPositions = {},
    RadarEnabled = false,
    ShowEnemyFOV = false,
    SoundVisualization = false,
    ObjectiveTracker = false,
    PerformanceEnabled = false,
    AutoFPSBoost = false,
    MemoryCleaner = false,
    RenderDistanceManager = false,
    CurrentTheme = "Default"
}

local Config = {}
for k,v in pairs(defaultConfig) do Config[k] = v end

-- ======================== --
--        HELPERS          --
-- ======================== --
local function vec3ToTable(v) return {x=v.X, y=v.Y, z=v.Z} end
local function tableToVec3(t) return Vector3.new(t.x,t.y,t.z) end

local function saveConfig()
    local s = {}
    for k,v in pairs(Config) do
        if k == "AimKey" then s[k] = v
        elseif k == "SavedPositions" then
            local out = {}
            for slot,pos in pairs(v) do out[slot] = vec3ToTable(pos) end
            s[k] = out
        else s[k] = v end
    end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(s)) end)
    print("[.binh Hub] Config saved.")
end

local function loadConfig()
    if not isfile(CONFIG_FILE) then print("[.binh Hub] No config file found; using defaults.") return end
    local ok,data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if not ok or type(data)~="table" then print("[.binh Hub] Failed to load config; using defaults.") return end
    for k,v in pairs(data) do
        if k=="SavedPositions" and type(v)=="table" then
            local out = {}
            for slot,posT in pairs(v) do if type(posT)=="table" and posT.x then out[slot]=tableToVec3(posT) end end
            Config.SavedPositions = out
        elseif k=="AimKey" and type(v)=="table" and v.kind and v.name then Config.AimKey=v
        else Config[k]=v end
    end
    print("[.binh Hub] Config loaded.")
end

loadConfig()

local function applyTheme(themeName)
    if not Themes[themeName] then themeName="Default" end
    Config.CurrentTheme=themeName
end

-- ======================== --
--         DRAWING         --
-- ======================== --
local Drawing = Drawing or (function() error("Drawing API not available") end)
local function removeDrawingSet(set) if not set then return end for _,obj in pairs(set) do pcall(function() obj:Remove() end) end end

-- ======================== --
--          ESP            --
-- ======================== --
local ESP={Objects={}}
local function createESPForPlayer(plr)
    if ESP.Objects[plr] then return end
    local set={}
    set.Box=Drawing.new("Square")
    set.Name=Drawing.new("Text")
    set.Distance=Drawing.new("Text")
    set.Tracer=Drawing.new("Line")

    set.Box.Thickness=2; set.Box.Filled=false; set.Box.Color=Themes[Config.CurrentTheme].Primary
    set.Name.Size=13; set.Name.Outline=true; set.Name.Color=Themes[Config.CurrentTheme].Text; set.Name.Center=true
    set.Distance.Size=13; set.Distance.Outline=true; set.Distance.Color=Themes[Config.CurrentTheme].Text; set.Distance.Center=true
    set.Tracer.Thickness=2; set.Tracer.Color=Themes[Config.CurrentTheme].Primary

    ESP.Objects[plr]=set
end

local function removeESPForPlayer(plr) if ESP.Objects[plr] then removeDrawingSet(ESP.Objects[plr]); ESP.Objects[plr]=nil end end

local function updateESP()
    if not Config.ESPEnabled then for p in pairs(ESP.Objects) do removeESPForPlayer(p) end return end
    local mousePos = UserInputService:GetMouseLocation()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        if not plr.Character then removeESPForPlayer(plr) continue end
        local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
        local humanoid=plr.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid or humanoid.Health<=0 then removeESPForPlayer(plr) continue end
        if Config.ESPTeamCheck and plr.Team==LocalPlayer.Team then removeESPForPlayer(plr) continue end

        local dist=(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude) or math.huge
        if dist>Config.ESPDistance then removeESPForPlayer(plr) continue end

        createESPForPlayer(plr)
        local set=ESP.Objects[plr]
        local pos,onScreen=Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local boxW=math.clamp(2000/pos.Z,20,300); local boxH=math.clamp(3000/pos.Z,40,500)
            set.Box.Size=Vector2.new(boxW,boxH); set.Box.Position=Vector2.new(pos.X-boxW/2,pos.Y-boxH/2); set.Box.Visible=true
            set.Name.Text=plr.Name; set.Name.Position=Vector2.new(pos.X,pos.Y-boxH/2-12); set.Name.Visible=true
            set.Distance.Text=string.format("[%dm]",math.floor(dist)); set.Distance.Position=Vector2.new(pos.X,pos.Y+boxH/2+6); set.Distance.Visible=true

            if Config.LineESPEnabled then
                set.Tracer.From=mousePos
                set.Tracer.To=Vector2.new(pos.X,pos.Y+boxH/2)
                set.Tracer.Visible=true
            else set.Tracer.Visible=false end
        else for _,d in pairs(set) do d.Visible=false end
        end
    end
end

Players.PlayerRemoving:Connect(removeESPForPlayer)

-- ======================== --
--        AIMBOT           --
-- ======================== --
local AimFOVCircle=nil; local waitingForAimKey=false
local function createAimFOVCircle()
    if AimFOVCircle then pcall(function() AimFOVCircle:Remove() end) AimFOVCircle=nil end
    if Config.ShowAimFOV and Config.AimEnabled then
        AimFOVCircle=Drawing.new("Circle")
        AimFOVCircle.Visible=true; AimFOVCircle.Thickness=2; AimFOVCircle.Color=Themes[Config.CurrentTheme].Primary
        AimFOVCircle.Filled=false; AimFOVCircle.Transparency=1; AimFOVCircle.Radius=Config.AimFOV
        AimFOVCircle.Position=UserInputService:GetMouseLocation()
    end
end

local function updateAimFOVCircle()
    if AimFOVCircle then
        AimFOVCircle.Radius=Config.AimFOV
        AimFOVCircle.Color=Themes[Config.CurrentTheme].Primary
        AimFOVCircle.Visible=Config.ShowAimFOV and Config.AimEnabled
        AimFOVCircle.Position=UserInputService:GetMouseLocation()
    else if Config.ShowAimFOV and Config.AimEnabled then createAimFOVCircle() end end
end

-- Remaining aimbot, movement, teleport, radar, performance, and WindUI code would follow, using the same principles: FOV circle around mouse and tracer lines with their own setting.

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
    pcall(updateAimFOVCircle)
end)
