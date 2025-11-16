-- Aimbot + ESP - Fixed version (PC + PE separated)
-- Ghi chú: Chỉ dùng cho mục đích học tập.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer then
    warn("Không thể tìm thấy LocalPlayer")
    return
end

-- ===== Load WindUI safely =====
local WindUI
do
    local ok, lib = pcall(function()
        local src = game:HttpGet or function() error("HttpGet not available") end
        local s = src("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua")
        return loadstring(s)()
    end)
    if not ok then
        warn("Không thể tải WindUI, đang dừng script. Lỗi: "..tostring(lib))
        return
    end
    WindUI = lib
end

-- ===== Configs =====
local AimbotConfig = {
    Mode = "PC", -- "PC" or "PE" (mobile). Chuyển ở UI
    Enabled = false,
    TeamCheck = true,
    Smoothness = 2,
    FOV = 80,
    AimPart = "Head",
    UseKeybind = false,
    Keybind = Enum.KeyCode.Q,
    UseMouse = true, -- PC mode: sử dụng chuột
    HoldToAim = true,
    SilentAim = false,
    Prediction = 0.14,
    AimStyle = "NormalAim" -- "NormalAim" or "SilentAim_Raycast"
}

local ESPConfig = {
    Enabled = false,
    ShowBoxes = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamCheck = true,
    MaxDistance = 500,
    BoxColor = Color3.fromRGB(255,0,0),
    TextColor = Color3.fromRGB(255,255,255)
}

local PlayerConfig = {
    SpeedHack = false,
    SpeedMultiplier = 2,
    JumpPower = false,
    JumpMultiplier = 2,
    Noclip = false,
    InfiniteJump = false
}

-- ===== Globals =====
local CurrentTarget = nil
local FOVCircle = nil
local IsAiming = false
local ESPObjects = {}
local Connections = {}
local DrawingAvailable = false

-- ===== Drawing fallback check =====
do
    local ok, drawing = pcall(function() return Drawing end)
    if ok and drawing then
        -- try create simple object to ensure allowed
        local ok2, obj = pcall(function() return Drawing.new("Circle") end)
        if ok2 then
            pcall(function() obj:Remove() end)
            DrawingAvailable = true
        else
            DrawingAvailable = false
        end
    else
        DrawingAvailable = false
    end
end

-- ===== WindUI Window & Tabs =====
local Window = WindUI:CreateWindow({
    Title = "Aimbot GUI - Fixed (PC & PE)",
    Center = true,
    Size = UDim2.new(0,460,0,520)
})
local MainTab = Window:CreateTab("Aimbot")
local ESPTab = Window:CreateTab("ESP")
local PlayerTab = Window:CreateTab("Player")
local SettingsTab = Window:CreateTab("Settings")

-- ===== Helper funcs =====
local function SafeTeamCheck(p1, p2)
    -- tránh nil team crash
    if not p1 or not p2 then return false end
    if not p1.Team or not p2.Team then return false end
    return p1.Team == p2.Team
end

local function GetMouseEnum(btnName)
    -- btnName "LeftButton" or "RightButton"
    if btnName == "LeftButton" then
        return Enum.UserInputType.MouseButton1
    elseif btnName == "RightButton" then
        return Enum.UserInputType.MouseButton2
    else
        return nil
    end
end

-- ===== UI: Aimbot tab =====
local AimbotSection = MainTab:CreateSection("Aimbot")
AimbotSection:CreateToggle("Bật Aimbot", AimbotConfig.Enabled, function(val) AimbotConfig.Enabled = val end)
AimbotSection:CreateDropdown("Chế Độ (PC/PE)", {"PC","PE"}, function(val) AimbotConfig.Mode = val end)
AimbotSection:CreateToggle("Kiểm Tra Team", AimbotConfig.TeamCheck, function(v) AimbotConfig.TeamCheck = v end)
AimbotSection:CreateDropdown("Aim Part", {"Head","Torso","HumanoidRootPart"}, function(v) AimbotConfig.AimPart = v end)
AimbotSection:CreateSlider("FOV", 10, 300, AimbotConfig.FOV, function(v) AimbotConfig.FOV = v end)
AimbotSection:CreateSlider("Smoothness", 1, 20, AimbotConfig.Smoothness, function(v) AimbotConfig.Smoothness = v end)
AimbotSection:CreateToggle("Silent Aim", AimbotConfig.SilentAim, function(v) AimbotConfig.SilentAim = v end)
AimbotSection:CreateDropdown("Aim Style", {"NormalAim","SilentAim_Raycast"}, function(v) AimbotConfig.AimStyle = v end)

-- Keybind & Mouse options (PC)
local KeybindSection = MainTab:CreateSection("Input")
KeybindSection:CreateToggle("Dùng Keybind", AimbotConfig.UseKeybind, function(v) AimbotConfig.UseKeybind = v end)
local keyOptions = {"Q","E","R","F","X","C","V","LeftShift","RightShift"}
KeybindSection:CreateDropdown("Keybind", keyOptions, function(val) 
    local mapped = val
    if mapped == "LeftShift" then mapped = "LeftShift" end
    AimbotConfig.Keybind = Enum.KeyCode[val] or Enum.KeyCode.Q
end)
KeybindSection:CreateToggle("Dùng Chuột (PC)", AimbotConfig.UseMouse, function(v) AimbotConfig.UseMouse = v end)
KeybindSection:CreateToggle("Hold To Aim", AimbotConfig.HoldToAim, function(v) AimbotConfig.HoldToAim = v end)

-- ===== UI: ESP tab =====
local ESPMain = ESPTab:CreateSection("ESP")
ESPMain:CreateToggle("Bật ESP", ESPConfig.Enabled, function(v) 
    ESPConfig.Enabled = v
    if v then InitializeESP() else ClearESP() end
end)
ESPMain:CreateToggle("Hiển Thị Box", ESPConfig.ShowBoxes, function(v) ESPConfig.ShowBoxes = v end)
ESPMain:CreateToggle("Hiển Thị Tên", ESPConfig.ShowNames, function(v) ESPConfig.ShowNames = v end)
ESPMain:CreateSlider("Max Distance", 100, 2000, ESPConfig.MaxDistance, function(v) ESPConfig.MaxDistance = v end)

-- ===== UI: Player tab =====
local MovementSection = PlayerTab:CreateSection("Player")
MovementSection:CreateToggle("Speed Hack", PlayerConfig.SpeedHack, function(v) PlayerConfig.SpeedHack = v UpdateSpeedHack() end)
MovementSection:CreateSlider("Speed Multiplier", 1, 10, PlayerConfig.SpeedMultiplier, function(v) PlayerConfig.SpeedMultiplier = v UpdateSpeedHack() end)
MovementSection:CreateToggle("Infinite Jump", PlayerConfig.InfiniteJump, function(v) PlayerConfig.InfiniteJump = v SetupInfiniteJump() end)

-- ===== UI: Settings =====
local Visuals = SettingsTab:CreateSection("Visual")
Visuals:CreateToggle("Hiển Thị FOV Circle", false, function(v) if FOVCircle then FOVCircle.Visible = v end end)

SettingsTab:CreateSection("Utilities"):CreateButton("Reset Settings", function()
    -- đơn giản reset
    AimbotConfig.Enabled = false
    AimbotConfig.TeamCheck = true
    AimbotConfig.Smoothness = 2
    AimbotConfig.FOV = 80
    AimbotConfig.AimPart = "Head"
    AimbotConfig.UseKeybind = false
    AimbotConfig.UseMouse = true
    AimbotConfig.HoldToAim = true
    ESPConfig.Enabled = false
    ClearESP()
end)

-- ===== FindClosestPlayer (opt) =====
local function GetScreenDistanceToCursor(worldPos)
    local mousePos = UserInputService:GetMouseLocation()
    local screenPoint, onScreen = Camera:WorldToViewportPoint(worldPos)
    if not onScreen then return math.huge, screenPoint end
    return (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude, screenPoint
end

local function FindClosestPlayer()
    if not LocalPlayer.Character then return nil end
    local shortest = AimbotConfig.FOV
    local chosen = nil
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character.Parent then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if AimbotConfig.TeamCheck and SafeTeamCheck(pl, LocalPlayer) then
                    -- same team -> skip
                else
                    local part = pl.Character:FindFirstChild(AimbotConfig.AimPart) or pl.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local dist, screen = GetScreenDistanceToCursor(part.Position)
                        if dist < shortest then
                            shortest = dist
                            chosen = pl
                        end
                    end
                end
            end
        end
    end
    return chosen
end

-- ===== Aiming implementations =====
local function AimAtTarget_PC_Normal(target)
    if not target or not target.Character then return end
    local aimPart = target.Character:FindFirstChild(AimbotConfig.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
    if not aimPart then return end
    local targetPos = aimPart.Position
    if AimbotConfig.Prediction > 0 then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then targetPos = targetPos + hrp.Velocity * AimbotConfig.Prediction end
    end
    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos).Unit
    local newCFrame = CFrame.new(camPos, camPos + dir)
    local smoothFactor = math.clamp(1 / math.max(0.0001, AimbotConfig.Smoothness), 0, 1)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smoothFactor)
end

-- Silent attempt: simulate bullet direction via raycast before shooting
local function AimAtTarget_PC_Silent(target)
    -- This does NOT guarantee working on all executors; it's a best-effort raycast direction helper.
    -- Implementation: compute aim direction and store for use by fire hook (not provided).
    -- Here we will set Mouse.Hit if possible (pcall) else fallback to lerp camera.
    local ok, res = pcall(function()
        local aimPart = target.Character:FindFirstChild(AimbotConfig.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
        if not aimPart then return false end
        local targetPos = aimPart.Position
        if AimbotConfig.Prediction > 0 then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then targetPos = targetPos + hrp.Velocity * AimbotConfig.Prediction end
        end
        local camPos = Camera.CFrame.Position
        local dir = (targetPos - camPos).Unit
        local newCFrame = CFrame.new(camPos, camPos + dir)
        if mouse and mouse.Hit then
            mouse.Hit = newCFrame
            return true
        else
            -- fallback to normal
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, math.clamp(1 / math.max(0.0001, AimbotConfig.Smoothness),0,1))
            return false
        end
    end)
    return ok and res
end

-- Mobile (PE) aim: move camera directly to look at target (touch usage)
local function AimAtTarget_PE(target)
    if not target or not target.Character then return end
    local aimPart = target.Character:FindFirstChild(AimbotConfig.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
    if not aimPart then return end
    local targetPos = aimPart.Position
    if AimbotConfig.Prediction > 0 then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then targetPos = targetPos + hrp.Velocity * AimbotConfig.Prediction end
    end
    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos).Unit
    local newCFrame = CFrame.new(camPos, camPos + dir)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, math.clamp(1 / math.max(0.0001, AimbotConfig.Smoothness),0,1))
end

-- Dispatcher
local function AimAtTarget(target)
    if not target then return end
    if AimbotConfig.Mode == "PE" then
        AimAtTarget_PE(target)
    else
        if AimbotConfig.SilentAim and AimbotConfig.AimStyle == "SilentAim_Raycast" then
            local ok = AimAtTarget_PC_Silent(target)
            if not ok then AimAtTarget_PC_Normal(target) end
        else
            AimAtTarget_PC_Normal(target)
        end
    end
end

-- ===== ShouldAim =====
local function ShouldAim()
    if not AimbotConfig.Enabled then return false end
    if AimbotConfig.Mode == "PE" then
        return true -- on mobile just enable when Enabled (touch behavior can be refined by user)
    end
    if not AimbotConfig.UseKeybind and not AimbotConfig.UseMouse then
        return true
    end
    return IsAiming
end

-- ===== ESP system with Drawing fallback =====
local function CreateESPObject(player)
    local esp = {player = player}
    if DrawingAvailable then
        esp.box = Drawing.new("Square")
        esp.name = Drawing.new("Text")
        esp.box.Visible = false
        esp.box.Filled = false
        esp.box.Thickness = 2
        esp.box.Color = ESPConfig.BoxColor
        esp.name.Visible = false
        esp.name.Center = true
        esp.name.Outline = true
        esp.name.Size = 13
        esp.name.Color = ESPConfig.TextColor
    else
        -- Fallback: BillboardGui approach
        local holder = Instance.new("BillboardGui")
        holder.Name = "ESP_BB"
        holder.Size = UDim2.new(0,100,0,50)
        holder.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", holder)
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1,0,1,0)
        txt.TextScaled = true
        txt.TextStrokeTransparency = 0
        txt.TextColor3 = ESPConfig.TextColor
        txt.Text = player.Name
        esp.bb = holder
        esp.bbLabel = txt
    end
    return esp
end

local function UpdateESPObject(esp)
    local p = esp.player
    if not p or not p.Character or not p.Character.Parent then
        if esp.box then esp.box.Visible = false end
        if esp.name then esp.name.Visible = false end
        if esp.bb then esp.bb.Parent = nil end
        return
    end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        if esp.box then esp.box.Visible = false end
        if esp.name then esp.name.Visible = false end
        if esp.bb then esp.bb.Parent = nil end
        return
    end

    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and
        (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 9999
    if distance > ESPConfig.MaxDistance then
        if esp.box then esp.box.Visible = false end
        if esp.name then esp.name.Visible = false end
        if esp.bb then esp.bb.Parent = nil end
        return
    end
    if ESPConfig.TeamCheck and SafeTeamCheck(p, LocalPlayer) then
        if esp.box then esp.box.Visible = false end
        if esp.name then esp.name.Visible = false end
        if esp.bb then esp.bb.Parent = nil end
        return
    end

    local screenPoint, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        if esp.box then esp.box.Visible = false end
        if esp.name then esp.name.Visible = false end
        if esp.bb then esp.bb.Parent = nil end
        return
    end

    if DrawingAvailable and esp.box and esp.name then
        local scaleFactor = 1000 / screenPoint.Z
        local width = math.clamp(100/scaleFactor, 10, 200)
        local height = math.clamp(150/scaleFactor, 10, 300)
        if ESPConfig.ShowBoxes then
            esp.box.Size = Vector2.new(width, height)
            esp.box.Position = Vector2.new(screenPoint.X - width/2, screenPoint.Y - height/2)
            esp.box.Visible = true
        else
            esp.box.Visible = false
        end
        if ESPConfig.ShowNames then
            local display = p.Name
            if ESPConfig.ShowDistance then display = display.." ["..tostring(math.floor(distance)).."]" end
            if ESPConfig.ShowHealth and hum then display = display.." ("..tostring(math.floor(hum.Health)).."HP)" end
            esp.name.Text = display
            esp.name.Position = Vector2.new(screenPoint.X, screenPoint.Y - height/2 - 20)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end
    elseif esp.bb then
        esp.bb.Adornee = hrp
        esp.bb.Parent = workspace:FindFirstChildOfClass("WorldModel") or game.CoreGui
        local display = p.Name
        if ESPConfig.ShowDistance then display = display.." ["..tostring(math.floor(distance)).."]" end
        if ESPConfig.ShowHealth and hum then display = display.." ("..tostring(math.floor(hum.Health)).."HP)" end
        esp.bbLabel.Text = display
    end
end

function InitializeESP()
    ClearESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            ESPObjects[p] = CreateESPObject(p)
        end
    end
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then ESPObjects[p] = CreateESPObject(p) end
    end)
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(p)
        if ESPObjects[p] then
            if ESPObjects[p].box then pcall(function() ESPObjects[p].box:Remove() end) end
            if ESPObjects[p].name then pcall(function() ESPObjects[p].name:Remove() end) end
            if ESPObjects[p].bb then pcall(function() ESPObjects[p].bb:Destroy() end) end
            ESPObjects[p] = nil
        end
    end)
end

function ClearESP()
    for p, e in pairs(ESPObjects) do
        if e.box then pcall(function() e.box:Remove() end) end
        if e.name then pcall(function() e.name:Remove() end) end
        if e.bb then pcall(function() e.bb:Destroy() end) end
    end
    ESPObjects = {}
end

-- ===== Player functions =====
function UpdateSpeedHack()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if PlayerConfig.SpeedHack then
                hum.WalkSpeed = 16 * (PlayerConfig.SpeedMultiplier or 1)
            else
                hum.WalkSpeed = 16
            end
        end
    end
end

function SetupInfiniteJump()
    if PlayerConfig.InfiniteJump then
        if not Connections.InfiniteJump then
            Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                if PlayerConfig.InfiniteJump and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    else
        if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() Connections.InfiniteJump = nil end
    end
end

function ToggleNoclip(value)
    if value then
        if Connections.Noclip then return end
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
    end
end

-- ===== Input handling (safe) =====
local mouse = nil
pcall(function() mouse = LocalPlayer:GetMouse() end)

function SetupInputHandling()
    -- InputBegan
    if Connections.InputBegan then Connections.InputBegan:Disconnect() Connections.InputBegan = nil end
    Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        -- GUI toggle
        if input.KeyCode == Enum.KeyCode.F6 then Window:Toggle() end
        if input.KeyCode == Enum.KeyCode.F7 then
            AimbotConfig.Enabled = not AimbotConfig.Enabled
            -- no UI binding setter here
        end

        -- Keybind toggle
        if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind then
            if AimbotConfig.HoldToAim then IsAiming = true else IsAiming = not IsAiming end
        end

        -- Mouse input (PC)
        if AimbotConfig.Mode == "PC" and AimbotConfig.UseMouse then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                if AimbotConfig.HoldToAim then IsAiming = true else IsAiming = not IsAiming end
            end
        end

        -- Mobile touch could be captured if needed (placeholder)
    end)

    -- InputEnded
    if Connections.InputEnded then Connections.InputEnded:Disconnect() Connections.InputEnded = nil end
    Connections.InputEnded = UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind and AimbotConfig.HoldToAim then
            IsAiming = false
        end
        if AimbotConfig.Mode == "PC" and AimbotConfig.UseMouse and AimbotConfig.HoldToAim then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                IsAiming = false
            end
        end
    end)
end

-- ===== FOV Circle =====
function CreateFOVCircle()
    if FOVCircle then return end
    if DrawingAvailable then
        local ok, c = pcall(function()
            local circ = Drawing.new("Circle")
            circ.Visible = false
            circ.Radius = AimbotConfig.FOV
            circ.Thickness = 2
            circ.Filled = false
            circ.Transparency = 1
            circ.Color = Color3.fromRGB(255,0,0)
            return circ
        end)
        if ok then FOVCircle = c end
    else
        -- fallback: none (mobile/GUI optional)
        FOVCircle = nil
    end
end

-- ===== Main loop (optimized) =====
function Initialize()
    CreateFOVCircle()
    SetupInputHandling()
    InitializeESP()

    if Connections.RenderStepped then Connections.RenderStepped:Disconnect() Connections.RenderStepped = nil end
    Connections.RenderStepped = RunService.RenderStepped:Connect(function(dt)
        -- update FOV circle position & radius
        if FOVCircle and FOVCircle.Radius then
            FOVCircle.Radius = AimbotConfig.FOV
            local mpos = UserInputService:GetMouseLocation()
            FOVCircle.Position = Vector2.new(mpos.X, mpos.Y)
        end

        -- Update ESP in batches (not heavy ops)
        if ESPConfig.Enabled then
            for _, esp in pairs(ESPObjects) do
                UpdateESPObject(esp)
            end
        end

        -- Aimbot flow
        if ShouldAim() then
            CurrentTarget = FindClosestPlayer()
            if CurrentTarget then
                AimAtTarget(CurrentTarget)
            end
        else
            CurrentTarget = nil
        end
    end)
    print("Aimbot GUI initialized. F6: Toggle GUI | F7: Quick toggle aimbot")
end

-- Start
Initialize()
