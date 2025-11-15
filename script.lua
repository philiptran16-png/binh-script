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
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Config
local ESPEnabled, ESPTeamCheck, ESPWallCheck, ESPDistance = true, true, true, 200
local AimEnabled, AimTeamCheck, AimWallCheck, AimDistance, SmoothStrength = true, true, true, 200, 0.25
local FlyEnabled, NoclipEnabled, RadarEnabled, AntiFlingEnabled = false, false, true, true

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
    AntiFlingEnabled = AntiFlingEnabled
}

local CONFIG_FILE = "binh_hub_config.json"

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
        print("[.binh Hub] Config loaded!")
    else
        print("[.binh Hub] No config file found!")
    end
end

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
        Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    }
})

-- ESP Tab
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
ESPTab:Toggle({Title = "Enable ESP", Desc = "Hiển thị người chơi", Default = ESPEnabled, Callback = function(state) ESPEnabled = state end})
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
MoveTab:Toggle({Title = "Fly", Desc = "Bay tự do WSAD + Space + Ctrl", Default = FlyEnabled, Callback = function(state) FlyEnabled = state end})
MoveTab:Toggle({Title = "Noclip", Desc = "Đi xuyên tường", Default = NoclipEnabled, Callback = function(state) NoclipEnabled = state end})
MoveTab:Toggle({Title = "Anti Fling", Desc = "Chống văng nhân vật bởi lực ngoài", Default = AntiFlingEnabled, Callback = function(state) AntiFlingEnabled = state end})

-- Radar Tab
local RadarTab = Window:Tab({Title = "Radar", Icon = "map"})
RadarTab:Toggle({Title = "Enable Radar", Desc = "Bật/tắt radar minimap", Default = RadarEnabled, Callback = function(state) RadarEnabled = state end})

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
SettingsTab:Button({Title = "Save Config", Desc = "Lưu lại cấu hình hiện tại", Callback = saveConfig})
SettingsTab:Button({Title = "Load Config", Desc = "Tải cấu hình đã lưu", Callback = loadConfig})

-- Helper: Check visibility
local function isVisible(part)
    if not part or not part.Parent then return false end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

-- Setup ESP
local function setupESP(plr)
    local function doESP(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        local highlightConn
        highlightConn = RunService.RenderStepped:Connect(function()
            if ESPEnabled and plr ~= player and head then
                if ESPTeamCheck and plr.Team == player.Team then return end
                if ESPWallCheck and not isVisible(head) then return end
                if not char:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Highlight"
                    hl.Parent = char
                    hl.FillColor = Color3.fromRGB(0,255,0)
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.5
                end
            else
                local hl = char:FindFirstChild("Highlight")
                if hl then hl:Destroy() end
            end
        end)
        char.AncestryChanged:Connect(function(_, parent)
            if not parent and highlightConn then highlightConn:Disconnect() highlightConn = nil end
        end)
    end
    if plr.Character then doESP(plr.Character) end
    plr.CharacterAdded:Connect(doESP)
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then setupESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then setupESP(plr) end
end)

-- Radar
local radarGui, radarFrameInstance
local function createRadar()
    if radarGui then radarGui:Destroy() end
    radarGui = Instance.new("ScreenGui")
    radarGui.Name = "binhHubRadar"
    radarGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Name = "RadarFrame"
    frame.Parent = radarGui
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.01,0, 0.75,0)
    frame.Size = UDim2.new(0,160, 0,160)
    frame.AnchorPoint = Vector2.new(0,0)
    frame.ZIndex = 10
    return frame
end

local function updateRadar(radarFrame)
    for _,v in pairs(radarFrame:GetChildren()) do
        if v:IsA("Frame") and v.Name == "Blip" then v:Destroy() end
    end
    local center = Vector2.new(radarFrame.AbsoluteSize.X/2, radarFrame.AbsoluteSize.Y/2)
    local scanRange = 150
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rel = plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position
            if rel.Magnitude <= scanRange then
                local dir = Vector2.new(rel.X, rel.Z) * (radarFrame.AbsoluteSize.X/(2*scanRange))
                local blip = Instance.new("Frame")
                blip.Name = "Blip"
                blip.Parent = radarFrame
                blip.BackgroundColor3 = (plr.Team == player.Team and Color3.fromRGB(0,255,255)) or Color3.fromRGB(255,0,0)
                blip.Size = UDim2.new(0,7,0,7)
                blip.Position = UDim2.new(0, center.X+dir.X-3, 0, center.Y+dir.Y-3)
                blip.BackgroundTransparency = 0
                blip.BorderSizePixel = 0
                blip.ZIndex = 11
            end
        end
    end
    -- Local player
    local plFrame = Instance.new("Frame")
    plFrame.Name = "Blip"
    plFrame.Parent = radarFrame
    plFrame.BackgroundColor3 = Color3.fromRGB(30, 255, 30)
    plFrame.Size = UDim2.new(0,8,0,8)
    plFrame.Position = UDim2.new(0,center.X-4,0,center.Y-4)
    plFrame.BorderSizePixel = 0
    plFrame.BackgroundTransparency = 0
    plFrame.ZIndex = 12
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if AimEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local nearestHead, nearestDist = nil, math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if AimTeamCheck and plr.Team == player.Team then continue end
                if AimWallCheck and not isVisible(head) then continue end
                if dist > AimDistance then continue end
                if dist < nearestDist then nearestDist, nearestHead = dist, head end
            end
        end
        if nearestHead then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, nearestHead.Position), SmoothStrength)
        end
    end

    -- Fly
    if FlyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        if not root:FindFirstChild("BV") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BV"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = root
        end
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        root.BV.Velocity = dir.Magnitude > 0 and dir.Unit * 50 or Vector3.new(0,0,0)
    elseif player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("BV") then
        player.Character.HumanoidRootPart.BV:Destroy()
    end

    -- Noclip
    if NoclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Anti Fling
    if AntiFlingEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
            end
            if part:IsA("BodyVelocity") or part:IsA("BodyAngularVelocity")
              or part:IsA("BodyForce") or part:IsA("BodyThrust")
              or part:IsA("BodyPosition") or part:IsA("BodyGyro") then
                part:Destroy()
            end
        end
    end

    -- Radar
    if RadarEnabled then
        if not radarFrameInstance or not radarFrameInstance.Parent then radarFrameInstance = createRadar() end
        updateRadar(radarFrameInstance)
    elseif radarFrameInstance and radarFrameInstance.Parent then
        radarFrameInstance.Parent = nil
    end
end)
