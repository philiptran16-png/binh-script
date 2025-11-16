-- Aimbot Script với WindUI GUI - Fixed Version
-- Lưu ý: Chỉ sử dụng cho mục đích giáo dục

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Kiểm tra an toàn trước khi load
if not LocalPlayer then
    warn("Không thể tìm thấy LocalPlayer")
    return
end

-- Tải WindUI Library với error handling
local WindUI, WindUIError = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()
end)

if not WindUI or WindUIError then
    warn("Không thể tải WindUI: " .. tostring(WindUIError))
    return
end

-- Cấu hình Aimbot
local AimbotConfig = {
    Enabled = false,
    TeamCheck = true,
    Smoothness = 2,
    FOV = 80,
    AimPart = "Head",
    UseKeybind = false,
    Keybind = Enum.KeyCode.Q,
    UseMouse = false,
    MouseButton = "RightButton",
    HoldToAim = true,
    SilentAim = false,
    Prediction = 0.14
}

-- Cấu hình ESP
local ESPConfig = {
    Enabled = false,
    ShowBoxes = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracers = false,
    TeamCheck = true,
    MaxDistance = 500,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    TeamColor = true
}

-- Cấu hình Player
local PlayerConfig = {
    SpeedHack = false,
    SpeedMultiplier = 2,
    JumpPower = false,
    JumpMultiplier = 2,
    Noclip = false,
    Fly = false,
    FlySpeed = 2,
    InfiniteJump = false
}

-- Biến toàn cục
local CurrentTarget = nil
local FOVCircle = nil
local IsAiming = false
local ESPObjects = {}
local Connections = {}

-- Tạo GUI với WindUI
local Window = WindUI:CreateWindow({
    Title = "Aimbot GUI - Fixed",
    Center = true,
    Size = UDim2.new(0, 450, 0, 500)
})

-- Tạo các tab
local MainTab = Window:CreateTab("Aimbot")
local ESPTab = Window:CreateTab("ESP")
local PlayerTab = Window:CreateTab("Player")
local SettingsTab = Window:CreateTab("Settings")

-- =============================================
-- AIMBOT TAB
-- =============================================
local AimbotSection = MainTab:CreateSection("Cấu Hình Aimbot")

local EnabledToggle = AimbotSection:CreateToggle("Bật Aimbot", AimbotConfig.Enabled, function(Value)
    AimbotConfig.Enabled = Value
end)

local AimPartDropdown = AimbotSection:CreateDropdown("Vị Trí Aim", {"Head", "Torso", "HumanoidRootPart"}, function(Value)
    AimbotConfig.AimPart = Value
end)

local FOVSlider = AimbotSection:CreateSlider("FOV", 10, 200, AimbotConfig.FOV, function(Value)
    AimbotConfig.FOV = Value
end)

local SmoothSlider = AimbotSection:CreateSlider("Độ Mượt", 1, 10, AimbotConfig.Smoothness, function(Value)
    AimbotConfig.Smoothness = Value
end)

local TeamCheckToggle = AimbotSection:CreateToggle("Kiểm Tra Team", AimbotConfig.TeamCheck, function(Value)
    AimbotConfig.TeamCheck = Value
end)

-- Section Keybind
local KeybindSection = MainTab:CreateSection("Cài Đặt Keybind")

local UseKeybindToggle = KeybindSection:CreateToggle("Dùng Keybind", AimbotConfig.UseKeybind, function(Value)
    AimbotConfig.UseKeybind = Value
end)

local KeybindOptions = {"Q", "E", "R", "F", "X", "C", "V", "LeftShift", "RightShift"}
local KeybindDropdown = KeybindSection:CreateDropdown("Keybind", KeybindOptions, function(Value)
    AimbotConfig.Keybind = Enum.KeyCode[Value]
end)

local UseMouseToggle = KeybindSection:CreateToggle("Dùng Chuột", AimbotConfig.UseMouse, function(Value)
    AimbotConfig.UseMouse = Value
end)

local MouseDropdown = KeybindSection:CreateDropdown("Nút Chuột", {"LeftButton", "RightButton"}, function(Value)
    AimbotConfig.MouseButton = Value
end)

local HoldToggleToggle = KeybindSection:CreateToggle("Giữ Để Aim", AimbotConfig.HoldToAim, function(Value)
    AimbotConfig.HoldToAim = Value
end)

-- =============================================
-- ESP TAB
-- =============================================
local ESPMainSection = ESPTab:CreateSection("Cài Đặt ESP")

local ESPEnabledToggle = ESPMainSection:CreateToggle("Bật ESP", ESPConfig.Enabled, function(Value)
    ESPConfig.Enabled = Value
    if Value then
        InitializeESP()
    else
        ClearESP()
    end
end)

local ShowBoxesToggle = ESPMainSection:CreateToggle("Hiển Thị Box", ESPConfig.ShowBoxes, function(Value)
    ESPConfig.ShowBoxes = Value
end)

local ShowNamesToggle = ESPMainSection:CreateToggle("Hiển Thị Tên", ESPConfig.ShowNames, function(Value)
    ESPConfig.ShowNames = Value
end)

local ShowDistanceToggle = ESPMainSection:CreateToggle("Hiển Thị Khoảng Cách", ESPConfig.ShowDistance, function(Value)
    ESPConfig.ShowDistance = Value
end)

local ShowHealthToggle = ESPMainSection:CreateToggle("Hiển Thị Máu", ESPConfig.ShowHealth, function(Value)
    ESPConfig.ShowHealth = Value
end)

local ESPTeamCheckToggle = ESPMainSection:CreateToggle("Kiểm Tra Team", ESPConfig.TeamCheck, function(Value)
    ESPConfig.TeamCheck = Value
end)

local ESPMaxDistanceSlider = ESPMainSection:CreateSlider("Khoảng Cách Tối Đa", 100, 1000, ESPConfig.MaxDistance, function(Value)
    ESPConfig.MaxDistance = Value
end)

-- =============================================
-- PLAYER TAB
-- =============================================
local MovementSection = PlayerTab:CreateSection("Di Chuyển")

local SpeedHackToggle = MovementSection:CreateToggle("Speed Hack", PlayerConfig.SpeedHack, function(Value)
    PlayerConfig.SpeedHack = Value
    UpdateSpeedHack()
end)

local SpeedSlider = MovementSection:CreateSlider("Tốc Độ", 1, 5, PlayerConfig.SpeedMultiplier, function(Value)
    PlayerConfig.SpeedMultiplier = Value
    UpdateSpeedHack()
end)

local JumpPowerToggle = MovementSection:CreateToggle("Tăng Nhảy", PlayerConfig.JumpPower, function(Value)
    PlayerConfig.JumpPower = Value
    UpdateJumpPower()
end)

local JumpSlider = MovementSection:CreateSlider("Sức Nhảy", 1, 5, PlayerConfig.JumpMultiplier, function(Value)
    PlayerConfig.JumpMultiplier = Value
    UpdateJumpPower()
end)

local InfiniteJumpToggle = MovementSection:CreateToggle("Nhảy Vô Hạn", PlayerConfig.InfiniteJump, function(Value)
    PlayerConfig.InfiniteJump = Value
    SetupInfiniteJump()
end)

local NoclipToggle = MovementSection:CreateToggle("Noclip", PlayerConfig.Noclip, function(Value)
    PlayerConfig.Noclip = Value
    ToggleNoclip(Value)
end)

-- =============================================
-- SETTINGS TAB
-- =============================================
local VisualsSection = SettingsTab:CreateSection("Cài Đặt Giao Diện")

local ShowFOVToggle = VisualsSection:CreateToggle("Hiển Thị FOV Circle", false, function(Value)
    if FOVCircle then
        FOVCircle.Visible = Value
    end
end)

local FOVColorPicker = VisualsSection:CreateColorPicker("Màu FOV", Color3.fromRGB(255, 0, 0), function(Value)
    if FOVCircle then
        FOVCircle.Color = Value
    end
end)

local ResetSection = SettingsTab:CreateSection("Tiện Ích")
local ResetButton = ResetSection:CreateButton("Reset Cài Đặt", function()
    ResetAllSettings()
end)

-- =============================================
-- CORE FUNCTIONS
-- =============================================

-- Hàm tìm người chơi gần nhất
function FindClosestPlayer()
    if not LocalPlayer.Character then return nil end
    
    local closestPlayer = nil
    local shortestDistance = AimbotConfig.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- Kiểm tra team
                if AimbotConfig.TeamCheck then
                    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        continue
                    end
                end
                
                local aimPart = character:FindFirstChild(AimbotConfig.AimPart)
                if aimPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Hàm aim tại target
function AimAtTarget(target)
    if not target or not target.Character then return end
    
    local aimPart = target.Character:FindFirstChild(AimbotConfig.AimPart)
    if not aimPart then return end
    
    local camera = workspace.CurrentCamera
    local targetPosition = aimPart.Position
    
    -- Tính prediction nếu cần
    if AimbotConfig.Prediction > 0 then
        local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            targetPosition = targetPosition + (humanoidRootPart.Velocity * AimbotConfig.Prediction)
        end
    end
    
    local screenPoint = camera:WorldToScreenPoint(targetPosition)
    
    if screenPoint then
        local currentCameraPos = camera.CFrame.Position
        local direction = (targetPosition - currentCameraPos).Unit
        
        -- Tính toán smooth aiming
        local smoothFactor = math.max(1, AimbotConfig.Smoothness)
        local newCFrame = CFrame.new(currentCameraPos, currentCameraPos + direction)
        
        if AimbotConfig.SilentAim then
            -- Silent Aim
            Mouse.Hit = newCFrame
        else
            -- Normal Aim với smoothness
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 1 / smoothFactor)
        end
    end
end

-- Hàm kiểm tra điều kiện aim
function ShouldAim()
    if not AimbotConfig.Enabled then return false end
    
    -- Nếu không sử dụng keybind/mouse, luôn aim khi enabled
    if not AimbotConfig.UseKeybind and not AimbotConfig.UseMouse then
        return true
    end
    
    return IsAiming
end

-- =============================================
-- ESP SYSTEM (Đơn giản hóa)
-- =============================================
function CreateESP(player)
    local esp = {
        player = player,
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        loaded = false
    }
    
    -- Cấu hình box
    esp.box.Visible = false
    esp.box.Color = ESPConfig.BoxColor
    esp.box.Thickness = 2
    esp.box.Filled = false
    
    -- Cấu hình name
    esp.name.Visible = false
    esp.name.Color = ESPConfig.TextColor
    esp.name.Size = 13
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Text = player.Name
    
    esp.loaded = true
    return esp
end

function UpdateESP(esp)
    if not esp.loaded or not esp.player or not esp.player.Character then
        esp.box.Visible = false
        esp.name.Visible = false
        return
    end
    
    local character = esp.player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        esp.box.Visible = false
        esp.name.Visible = false
        return
    end
    
    -- Kiểm tra khoảng cách
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
        and (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude 
        or 9999
    
    if distance > ESPConfig.MaxDistance then
        esp.box.Visible = false
        esp.name.Visible = false
        return
    end
    
    -- Kiểm tra team
    if ESPConfig.TeamCheck and esp.player.Team and LocalPlayer.Team and esp.player.Team == LocalPlayer.Team then
        esp.box.Visible = false
        esp.name.Visible = false
        return
    end
    
    local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    
    if onScreen then
        -- Tính toán kích thước box
        local scaleFactor = 1000 / screenPoint.Z
        local width = 100 / scaleFactor
        local height = 150 / scaleFactor
        
        -- Cập nhật box
        if ESPConfig.ShowBoxes then
            esp.box.Size = Vector2.new(width, height)
            esp.box.Position = Vector2.new(screenPoint.X - width/2, screenPoint.Y - height/2)
            esp.box.Visible = true
            esp.box.Color = ESPConfig.BoxColor
        else
            esp.box.Visible = false
        end
        
        -- Cập nhật name
        if ESPConfig.ShowNames then
            local displayText = esp.player.Name
            if ESPConfig.ShowDistance then
                displayText = displayText .. string.format(" [%d]", distance)
            end
            if ESPConfig.ShowHealth and humanoid then
                displayText = displayText .. string.format(" (%dHP)", humanoid.Health)
            end
            
            esp.name.Text = displayText
            esp.name.Position = Vector2.new(screenPoint.X, screenPoint.Y - height/2 - 20)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end
    else
        esp.box.Visible = false
        esp.name.Visible = false
    end
end

function InitializeESP()
    ClearESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESPObjects[player] = CreateESP(player)
        end
    end
    
    -- Kết nối sự kiện
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESPObjects[player] = CreateESP(player)
    end)
    
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            if ESPObjects[player].box then
                ESPObjects[player].box:Remove()
            end
            if ESPObjects[player].name then
                ESPObjects[player].name:Remove()
            end
            ESPObjects[player] = nil
        end
    end)
end

function ClearESP()
    for player, esp in pairs(ESPObjects) do
        if esp.box then
            esp.box:Remove()
        end
        if esp.name then
            esp.name:Remove()
        end
    end
    ESPObjects = {}
end

-- =============================================
-- PLAYER FUNCTIONS
-- =============================================
function UpdateSpeedHack()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if PlayerConfig.SpeedHack then
                humanoid.WalkSpeed = 16 * PlayerConfig.SpeedMultiplier
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end

function UpdateJumpPower()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if PlayerConfig.JumpPower then
                humanoid.JumpPower = 50 * PlayerConfig.JumpMultiplier
            else
                humanoid.JumpPower = 50
            end
        end
    end
end

function SetupInfiniteJump()
    if PlayerConfig.InfiniteJump then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if PlayerConfig.InfiniteJump and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
            Connections.InfiniteJump = nil
        end
    end
end

function ToggleNoclip(value)
    if value then
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
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
            Connections.Noclip = nil
        end
    end
end

-- =============================================
-- INPUT HANDLING
-- =============================================
function SetupInputHandling()
    -- Keybind input
    Connections.KeybindBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind then
            if AimbotConfig.HoldToAim then
                IsAiming = true
            else
                IsAiming = not IsAiming
            end
        end
        
        -- Mouse input
        if AimbotConfig.UseMouse then
            local mouseButton = Enum.UserInputType[("MouseButton" .. AimbotConfig.MouseButton:gsub("Button", ""))]
            if input.UserInputType == mouseButton then
                if AimbotConfig.HoldToAim then
                    IsAiming = true
                else
                    IsAiming = not IsAiming
                end
            end
        end
    end)
    
    Connections.KeybindEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind and AimbotConfig.HoldToAim then
            IsAiming = false
        end
        
        if AimbotConfig.UseMouse and AimbotConfig.HoldToAim then
            local mouseButton = Enum.UserInputType[("MouseButton" .. AimbotConfig.MouseButton:gsub("Button", ""))]
            if input.UserInputType == mouseButton then
                IsAiming = false
            end
        end
    end)
end

-- =============================================
-- FOV CIRCLE
-- =============================================
function CreateFOVCircle()
    if FOVCircle then return end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = AimbotConfig.FOV
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
end

-- =============================================
-- RESET FUNCTIONS
-- =============================================
function ResetAllSettings()
    -- Reset Aimbot
    AimbotConfig.Enabled = false
    AimbotConfig.TeamCheck = true
    AimbotConfig.Smoothness = 2
    AimbotConfig.FOV = 80
    AimbotConfig.AimPart = "Head"
    AimbotConfig.UseKeybind = false
    AimbotConfig.UseMouse = false
    AimbotConfig.HoldToAim = true
    
    -- Reset ESP
    ESPConfig.Enabled = false
    ESPConfig.ShowBoxes = true
    ESPConfig.ShowNames = true
    ESPConfig.ShowDistance = true
    ESPConfig.ShowHealth = true
    ESPConfig.TeamCheck = true
    ESPConfig.MaxDistance = 500
    
    -- Reset Player
    PlayerConfig.SpeedHack = false
    PlayerConfig.SpeedMultiplier = 2
    PlayerConfig.JumpPower = false
    PlayerConfig.JumpMultiplier = 2
    PlayerConfig.Noclip = false
    PlayerConfig.Fly = false
    PlayerConfig.InfiniteJump = false
    
    -- Update UI
    EnabledToggle:SetValue(false)
    TeamCheckToggle:SetValue(true)
    SmoothSlider:SetValue(2)
    FOVSlider:SetValue(80)
    AimPartDropdown:SetOption("Head")
    UseKeybindToggle:SetValue(false)
    UseMouseToggle:SetValue(false)
    HoldToggleToggle:SetValue(true)
    
    ESPEnabledToggle:SetValue(false)
    ShowBoxesToggle:SetValue(true)
    ShowNamesToggle:SetValue(true)
    ShowDistanceToggle:SetValue(true)
    ShowHealthToggle:SetValue(true)
    ESPTeamCheckToggle:SetValue(true)
    ESPMaxDistanceSlider:SetValue(500)
    
    SpeedHackToggle:SetValue(false)
    SpeedSlider:SetValue(2)
    JumpPowerToggle:SetValue(false)
    JumpSlider:SetValue(2)
    InfiniteJumpToggle:SetValue(false)
    NoclipToggle:SetValue(false)
    
    -- Áp dụng changes
    UpdateSpeedHack()
    UpdateJumpPower()
    ToggleNoclip(false)
    ClearESP()
end

-- =============================================
-- INITIALIZATION
-- =============================================
function Initialize()
    -- Tạo FOV circle
    CreateFOVCircle()
    
    -- Thiết lập input handling
    SetupInputHandling()
    
    -- Main loop
    Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        -- Update FOV circle
        if FOVCircle then
            FOVCircle.Radius = AimbotConfig.FOV
            FOVCircle.Position = UserInputService:GetMouseLocation()
        end
        
        -- ESP update
        if ESPConfig.Enabled then
            for _, esp in pairs(ESPObjects) do
                UpdateESP(esp)
            end
        end
        
        -- Aimbot logic
        if ShouldAim() then
            CurrentTarget = FindClosestPlayer()
            if CurrentTarget then
                AimAtTarget(CurrentTarget)
            end
        else
            CurrentTarget = nil
        end
    end)
    
    -- GUI toggle hotkey
    Connections.GUIToggle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F6 then
            Window:Toggle()
        end
        
        -- Quick toggle aimbot
        if input.KeyCode == Enum.KeyCode.F7 then
            AimbotConfig.Enabled = not AimbotConfig.Enabled
            EnabledToggle:SetValue(AimbotConfig.Enabled)
        end
    end)
    
    print("Aimbot GUI Đã Khởi Chạy Thành Công!")
    print("F6 - Ẩn/Hiện GUI | F7 - Bật/Tắt Nhanh Aimbot")
end

-- Bắt đầu khởi chạy
Initialize()
