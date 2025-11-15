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
        ShowTeam = false, -- [GHI CHÚ] Bạn có cài đặt TeamCheck, nhưng không có ShowTeam. Tôi giữ nguyên.
        ShowBoxes = true,
        ShowTracers = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        MaxDistance = 500,
        BoxColor = Color3.new(1, 1, 1),
        TracerColor = Color3.new(1, 1, 1),
        NameColor = Color3.new(1, 1, 1),
        TeamColor = true,
        TeamCheck = true -- [GHI CHÚ] Thêm TeamCheck vào đây từ cài đặt Aimbot để nhất quán
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
        AutoUpdate = true,
        MenuKey = Enum.KeyCode.RightShift -- [BỔ SUNG] Thêm phím để mở/đóng menu
    }
}

-- Store drawing objects and data
local Drawings = {
    DirectionLine = nil,
    FOVCircle = nil,
    Crosshair = nil,
    Crosshair2 = nil, -- [SỬA LỖI] Cần lưu trữ cả đường thứ 2
    Watermark = nil,
    HitMarker = nil,
    ESPs = {} -- { [Player] = { Box, Tracer, Name, ... } }
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
    JumpConnection = nil,
    MainConnection = nil, -- [BỔ SUNG] Để ngắt kết nối khi panic
    InputConnection = nil, -- [BỔ SUNG] Để ngắt kết nối khi panic
    MenuVisible = true,
    WindUIWindow = nil -- [BỔ SUNG] Để tham chiếu đến cửa sổ UI
}

-- Player Mods Functions
local function startNoclip()
    if Data.NoclipConnection then
        Data.NoclipConnection:Disconnect()
    end
    
    Data.NoClipping = true
    Data.NoclipConnection = RunService.Stepped:Connect(function()
        if not Settings.PlayerMods.Noclip or not LocalPlayer.Character then return end
        
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    Data.NoClipping = false
    if Data.NoclipConnection then
        Data.NoclipConnection:Disconnect()
        Data.NoclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true -- [GHI CHÚ] Điều này có thể gây lỗi nếu một số bộ phận ban đầu không thể va chạm.
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
    bodyVelocity.Name = "FlyVelocity" -- [BỔ SUNG] Đặt tên để dễ tìm
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- [SỬA LỖI] MaxForce lớn hơn
    bodyVelocity.Parent = rootPart
    
    Data.FlyConnection = RunService.Heartbeat:Connect(function()
        if not Data.Flying or not character or not rootPart or not bodyVelocity.Parent then
            if Data.FlyConnection then
                Data.FlyConnection:Disconnect()
            end
            return
        end
        
        local camera = workspace.CurrentCamera
        local flySpeed = Settings.PlayerMods.FlySpeed * 10 -- [GHI CHÚ] Tăng tốc độ bay cho phù hợp
        
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
            local bodyVelocity = rootPart:FindFirstChild("FlyVelocity")
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
    Drawings.DirectionLine.Visible = Settings.Visuals.DirectionLine and Settings.ESP.Enabled
end

local function createFOVCircle()
    if Drawings.FOVCircle then Drawings.FOVCircle:Remove() end
    Drawings.FOVCircle = Drawing.new("Circle")
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle and Settings.ESP.Enabled
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Thickness = 2
    Drawings.FOVCircle.NumSides = 32
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Filled = false
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function createCrosshair()
    if Drawings.Crosshair then Drawings.Crosshair:Remove() end
    if Drawings.Crosshair2 then Drawings.Crosshair2:Remove() end
    
    Drawings.Crosshair = Drawing.new("Line")
    Drawings.Crosshair.Visible = Settings.Visuals.Crosshair
    Drawings.Crosshair.Color = Color3.new(1, 1, 1)
    Drawings.Crosshair.Thickness = 1
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
    
    local crosshair2 = Drawing.new("Line")
    crosshair2.Visible = Settings.Visuals.Crosshair
    crosshair2.Color = Color3.new(1, 1, 1)
    crosshair2.Thickness = 1
    crosshair2.From = Vector2.new(center.X, center.Y - 8)
    crosshair2.To = Vector2.new(center.X, center.Y + 8)
    
    Drawings.Crosshair2 = crosshair2
end

local function createWatermark()
    if Drawings.Watermark then Drawings.Watermark:Remove() end
    Drawings.Watermark = Drawing.new("Text")
    Drawings.Watermark.Visible = Settings.Visuals.Watermark
    Drawings.Watermark.Color = Color3.new(1, 1, 1)
    Drawings.Watermark.Size = 16
    Drawings.Watermark.Font = 2
    Drawings.Watermark.Text = "Windy ESP | FPS: 60 | Players: 0"
    Drawings.Watermark.Position = Vector2.new(10, 10)
    Drawings.Watermark.Outline = true
end

-- Update functions
local function updateDirectionLine()
    if not Drawings.DirectionLine then return end
    
    local visible = Settings.Visuals.DirectionLine and Settings.ESP.Enabled
    Drawings.DirectionLine.Visible = visible
    
    if not visible then return end
    
    local lookVector = Camera.CFrame.LookVector
    local startPos = Camera.CFrame.Position
    local endPos = startPos + lookVector * Settings.ESP.MaxDistance
    
    local startVector, startVisible = Camera:WorldToViewportPoint(startPos)
    local endVector, endVisible = Camera:WorldToViewportPoint(endPos)
    
    if startVisible and endVisible then
        Drawings.DirectionLine.From = Vector2.new(startVector.X, startVector.Y)
        Drawings.DirectionLine.To = Vector2.new(endVector.X, endVector.Y)
        Drawings.DirectionLine.Color = Settings.ESP.BoxColor
    else
        Drawings.DirectionLine.Visible = false
    end
end

local function updateFOVCircle()
    if not Drawings.FOVCircle then return end
    
    local visible = Settings.Visuals.FOVCircle and Settings.Aimbot.Enabled -- [SỬA LỖI] Liên kết với Aimbot
    Drawings.FOVCircle.Visible = visible
    
    if not visible then return end
    
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function updateCrosshair()
    if not Drawings.Crosshair or not Drawings.Crosshair2 then return end
    
    local visible = Settings.Visuals.Crosshair
    Drawings.Crosshair.Visible = visible
    Drawings.Crosshair2.Visible = visible
    
    if not visible then return end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
    
    Drawings.Crosshair2.From = Vector2.new(center.X, center.Y - 8)
    Drawings.Crosshair2.To = Vector2.new(center.X, center.Y + 8)
end

local function updateWatermark()
    if not Drawings.Watermark then return end
    
    Drawings.Watermark.Visible = Settings.Visuals.Watermark
    if not Settings.Visuals.Watermark then return end
    
    local fps = math.floor(1 / RunService.Heartbeat:Wait()) -- [SỬA LỖI] Dùng Heartbeat
    Drawings.Watermark.Text = string.format("Windy ESP | FPS: %d | Players: %d", fps, #Players:GetPlayers())
end

-- [THAY ĐỔI] Hàm updateESP được viết lại hoàn toàn để cải thiện hiệu năng
local function removePlayerESP(player)
    if Drawings.ESPs[player] then
        for _, drawing in pairs(Drawings.ESPs[player]) do
            drawing:Remove()
        end
        Drawings.ESPs[player] = nil
    end
end

local function createPlayerESP(player)
    local espData = {}
    local playerColor = Settings.ESP.TeamColor and player.TeamColor.Color or Settings.ESP.BoxColor

    if Settings.ESP.ShowBoxes then
        espData.Box = Drawing.new("Square")
        espData.Box.Visible = false
        espData.Box.Color = playerColor
        espData.Box.Thickness = 2
        espData.Box.Filled = false
    end
    
    if Settings.ESP.ShowTracers then
        espData.Tracer = Drawing.new("Line")
        espData.Tracer.Visible = false
        espData.Tracer.Color = playerColor
        espData.Tracer.Thickness = 1
    end
    
    if Settings.ESP.ShowNames then
        espData.Name = Drawing.new("Text")
        espData.Name.Visible = false
        espData.Name.Color = Settings.ESP.NameColor
        espData.Name.Size = 14
        espData.Name.Font = 2
        espData.Name.Text = player.Name
        espData.Name.Outline = true
        espData.Name.Center = true
    end
    
    if Settings.ESP.ShowDistance then
        espData.Distance = Drawing.new("Text")
        espData.Distance.Visible = false
        espData.Distance.Color = Settings.ESP.NameColor
        espData.Distance.Size = 12
        espData.Distance.Font = 2
        espData.Distance.Text = "[0]"
        espData.Distance.Outline = true
        espData.Distance.Center = true
    end
    
    if Settings.ESP.ShowHealth then
        espData.HealthBarOutline = Drawing.new("Square")
        espData.HealthBarOutline.Visible = false
        espData.HealthBarOutline.Color = Color3.new(0, 0, 0)
        espData.HealthBarOutline.Thickness = 1
        espData.HealthBarOutline.Filled = true
        
        espData.HealthBar = Drawing.new("Square")
        espData.HealthBar.Visible = false
        espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        espData.HealthBar.Thickness = 1
        espData.HealthBar.Filled = true
    end
    
    Drawings.ESPs[player] = espData
    return espData
end

local function updateESP()
    if not Settings.ESP.Enabled then
        -- Ẩn tất cả ESP nếu bị tắt
        for player, espData in pairs(Drawings.ESPs) do
            for _, drawing in pairs(espData) do
                drawing.Visible = false
            end
        end
        return
    end

    -- Kiểm tra người chơi hiện có
    for player, espData in pairs(Drawings.ESPs) do
        if not player or not player.Parent or not player:IsDescendantOf(Players) or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            removePlayerESP(player)
        end
    end

    -- Cập nhật người chơi hợp lệ
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                -- Team check
                if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    removePlayerESP(player) -- Xóa nếu họ cùng team
                    continue
                end
                
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                if distance > Settings.ESP.MaxDistance then
                    removePlayerESP(player) -- Xóa nếu quá xa
                    continue
                end
                
                -- Lấy hoặc tạo ESP data
                local espData = Drawings.ESPs[player] or createPlayerESP(player)
                
                -- Tính toán vị trí
                local head = character:FindFirstChild("Head")
                if not head then continue end
                
                local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                
                if headVisible or rootVisible then
                    local playerColor = Settings.ESP.TeamColor and player.TeamColor.Color or Settings.ESP.BoxColor
                    if Settings.Misc.RainbowMode then
                        playerColor = Color3.fromHSV(Data.RainbowHue, 1, 1)
                    end

                    local height = math.abs(rootPos.Y - headPos.Y)
                    local width = height * 0.6
                    local boxX = rootPos.X - width / 2
                    local boxY = headPos.Y
                    
                    -- Box ESP
                    if espData.Box then
                        espData.Box.Size = Vector2.new(width, height)
                        espData.Box.Position = Vector2.new(boxX, boxY)
                        espData.Box.Visible = true
                        espData.Box.Color = playerColor
                    end
                    
                    -- Tracer
                    if espData.Tracer then
                        espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        espData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        espData.Tracer.Visible = true
                        espData.Tracer.Color = playerColor
                    end
                    
                    -- Name
                    if espData.Name then
                        espData.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                        espData.Name.Visible = true
                    end
                    
                    -- Distance
                    if espData.Distance then
                        espData.Distance.Text = string.format("[%d m]", distance)
                        espData.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + 5)
                        espData.Distance.Visible = true
                    end
                    
                    -- Health
                    if espData.HealthBar then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barWidth = 4
                        local barHeight = height
                        local barX = boxX - barWidth - 2
                        local barY = boxY
                        
                        espData.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
                        espData.HealthBarOutline.Position = Vector2.new(barX, barY)
                        espData.HealthBarOutline.Visible = true
                        
                        local healthHeight = barHeight * healthPercent
                        espData.HealthBar.Size = Vector2.new(barWidth, healthHeight)
                        espData.HealthBar.Position = Vector2.new(barX, barY + (barHeight - healthHeight))
                        espData.HealthBar.Visible = true
                        espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    end
                else
                    -- Ẩn nếu ngoài màn hình
                    removePlayerESP(player)
                end
            else
                -- Xóa nếu chết
                removePlayerESP(player)
            end
        end
    end
end
-- [KẾT THÚC THAY ĐỔI]

-- Aimbot Functions
local function updateAimbot()
    if not Settings.Aimbot.Enabled then return end
    
    local closestTarget = nil
    local closestDistance = Settings.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
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
                    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                    if hit and not hit:IsDescendantOf(character) then
                        continue
                    end
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
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
    
    -- Auto aim khi giữ chuột phải
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
        Data.RainbowHue = (Data.RainbowHue + 0.005) % 1 -- [GHI CHÚ] Giảm tốc độ
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
    
    -- Update player mods (chỉ gọi nếu đang bật)
    if Settings.PlayerMods.Speed then applySpeed() end
    if Settings.PlayerMods.JumpPower then applyJumpPower() end
end

-- Create WindUI Interface
local function createWindUI()
    local window = WindUI:CreateWindow({
        Title = "Windy ESP v4.0",
        Icon = "http://www.roblox.com/asset/?id=6035067836", -- Settings icon
        Size = UDim2.new(0, 500, 0, 500),
        Key = Settings.Misc.MenuKey
    })
    Data.WindUIWindow = window -- [BỔ SUNG] Lưu tham chiếu
    
    -- ESP Tab
    local esptab = window:CreateTab({
        Title = "ESP",
        Icon = "http://www.roblox.com/asset/?id=6035067851" -- Eye icon
    })
    
    esptab:CreateToggle({
        Title = "Enable ESP",
        Default = Settings.ESP.Enabled,
        Callback = function(value)
            Settings.ESP.Enabled = value
            if not value then
                -- Xóa tất cả ESP nếu tắt
                for player, espData in pairs(Drawings.ESPs) do
                    removePlayerESP(player)
                end
            end
        end
    })
    
    esptab:CreateToggle({
        Title = "Show Boxes",
        Default = Settings.ESP.ShowBoxes,
        Callback = function(value)
            Settings.ESP.ShowBoxes = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Show Tracers",
        Default = Settings.ESP.ShowTracers,
        Callback = function(value)
            Settings.ESP.ShowTracciers = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Show Names",
        Default = Settings.ESP.ShowNames,
        Callback = function(value)
            Settings.ESP.ShowNames = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Show Distance",
        Default = Settings.ESP.ShowDistance,
        Callback = function(value)
            Settings.ESP.ShowDistance = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Show Health",
        Default = Settings.ESP.ShowHealth,
        Callback = function(value)
            Settings.ESP.ShowHealth = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Team Check",
        Default = Settings.ESP.TeamCheck,
        Callback = function(value)
            Settings.ESP.TeamCheck = value
        end
    })
    
    esptab:CreateToggle({
        Title = "Team Colors",
        Default = Settings.ESP.TeamColor,
        Callback = function(value)
            Settings.ESP.TeamColor = value
        end
    })
    
    esptab:CreateSlider({
        Title = "Max Distance",
        Default = Settings.ESP.MaxDistance,
        Min = 50,
        Max = 1000,
        Callback = function(value)
            Settings.ESP.MaxDistance = value
        end
    })
    
    -- Aimbot Tab
    local aimbottab = window:CreateTab({
        Title = "Aimbot",
        Icon = "http://www.roblox.com/asset/?id=6035067824" -- Target icon
    })
    
    aimbottab:CreateToggle({
        Title = "Enable Aimbot",
        Default = Settings.Aimbot.Enabled,
        Callback = function(value)
            Settings.Aimbot.Enabled = value
        end
    })
    
    aimbottab:CreateSlider({
        Title = "Smoothness",
        Default = Settings.Aimbot.Smoothness,
        Min = 0,
        Max = 1,
        Callback = function(value)
            Settings.Aimbot.Smoothness = value
        end
    })
    
    aimbottab:CreateSlider({
        Title = "FOV (Bán kính)",
        Default = Settings.Aimbot.FOV,
        Min = 10,
        Max = 200,
        Callback = function(value)
            Settings.Aimbot.FOV = value
        end
    })
    
    aimbottab:CreateToggle({
        Title = "Visibility Check",
        Default = Settings.Aimbot.VisibleCheck,
        Callback = function(value)
            Settings.Aimbot.VisibleCheck = value
        end
    })
    
    aimbottab:CreateToggle({
        Title = "Team Check",
        Default = Settings.Aimbot.TeamCheck,
        Callback = function(value)
            Settings.Aimbot.TeamCheck = value
        end
    })
    
    local targetParts = {"Head", "HumanoidRootPart", "Torso"}
    aimbottab:CreateDropdown({
        Title = "Target Part",
        Items = targetParts,
        Default = Settings.Aimbot.TargetPart,
        Callback = function(value)
            Settings.Aimbot.TargetPart = value
        end
    })
    
    -- Visuals Tab
    local visualstab = window:CreateTab({
        Title = "Visuals",
        Icon = "http://www.roblox.com/asset/?id=6035067845" -- Monitor icon
    })
    
    visualstab:CreateToggle({
        Title = "Direction Line",
        Default = Settings.Visuals.DirectionLine,
        Callback = function(value)
            Settings.Visuals.DirectionLine = value
        end
    })
    
    visualstab:CreateToggle({
        Title = "Show FOV Circle",
        Default = Settings.Visuals.FOVCircle,
        Callback = function(value)
            Settings.Visuals.FOVCircle = value
        end
    })
    
    visualstab:CreateToggle({
        Title = "Crosshair",
        Default = Settings.Visuals.Crosshair,
        Callback = function(value)
            Settings.Visuals.Crosshair = value
        end
    })
    
    visualstab:CreateToggle({
        Title = "Watermark",
        Default = Settings.Visuals.Watermark,
        Callback = function(value)
            Settings.Visuals.Watermark = value
        end
    })
    
    visualstab:CreateToggle({
        Title = "Hit Marker",
        Default = Settings.Visuals.HitMarker,
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
    local playertab = window:CreateTab({
        Title = "Player",
        Icon = "http://www.roblox.com/asset/?id=6035067827" -- User icon
    })
    
    playertab:CreateToggle({
        Title = "Noclip",
        Default = Settings.PlayerMods.Noclip,
        Callback = function(value)
            Settings.PlayerMods.Noclip = value
            if value then
                startNoclip()
            else
                stopNoclip()
            end
        end
    })
    
    playertab:CreateToggle({
        Title = "Fly",
        Default = Settings.PlayerMods.Fly,
        Callback = function(value)
            Settings.PlayerMods.Fly = value
            if value then
                startFly()
            else
                stopFly()
            end
        end
    })
    
    playertab:CreateSlider({
        Title = "Fly Speed",
        Default = Settings.PlayerMods.FlySpeed,
        Min = 1,
        Max = 10,
        Callback = function(value)
            Settings.PlayerMods.FlySpeed = value
        end
    })
    
    playertab:CreateToggle({
        Title = "Speed Hack",
        Default = Settings.PlayerMods.Speed,
        Callback = function(value)
            Settings.PlayerMods.Speed = value
            applySpeed()
        end
    })
    
    playertab:CreateSlider({
        Title = "Speed Value",
        Default = Settings.PlayerMods.SpeedValue,
        Min = 16,
        Max = 100,
        Callback = function(value)
            Settings.PlayerMods.SpeedValue = value
            applySpeed()
        end
    })
    
    playertab:CreateToggle({
        Title = "High Jump",
        Default = Settings.PlayerMods.JumpPower,
        Callback = function(value)
            Settings.PlayerMods.JumpPower = value
            applyJumpPower()
        end
    })
    
    playertab:CreateSlider({
        Title = "Jump Power",
        Default = Settings.PlayerMods.JumpPowerValue,
        Min = 50,
        Max = 200,
        Callback = function(value)
            Settings.PlayerMods.JumpPowerValue = value
            applyJumpPower()
        end
    })
    
    playertab:CreateToggle({
        Title = "Infinite Jump",
        Default = Settings.PlayerMods.InfiniteJump,
        Callback = function(value)
            Settings.PlayerMods.InfiniteJump = value
            if value then
                startInfiniteJump()
            else
                stopInfiniteJump()
            end
        end
    })
    
    playertab:CreateButton({
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
            
            -- [BỔ SUNG] Cập nhật UI
            window:Notify("Player mods reset!")
        end
    })

-- [BỔ SUNG] Phần mã bị thiếu của bạn bắt đầu từ đây

    -- Misc Tab
    local misctab = window:CreateTab({
        Title = "Misc",
        Icon = "http://www.roblox.com/asset/?id=6035067836" -- Settings icon
    })
    
    misctab:CreateToggle({
        Title = "Rainbow Mode",
        Default = Settings.Misc.RainbowMode,
        Callback = function(value)
            Settings.Misc.RainbowMode = value
        end
    })
    
    misctab:CreateKeybind({
        Title = "Panic Key",
        Default = Settings.Misc.PanicKey,
        Callback = function(key)
            Settings.Misc.PanicKey = key
        end
    })

    misctab:CreateKeybind({
        Title = "Menu Key",
        Default = Settings.Misc.MenuKey,
        Callback = function(key)
            Settings.Misc.MenuKey = key
            Data.WindUIWindow:SetKey(key)
        end
    })
end

-- [BỔ SUNG] Hàm Panic
local function panic()
    -- Tắt tất cả mod
    Settings.PlayerMods.Noclip = false
    Settings.PlayerMods.Fly = false
    Settings.PlayerMods.Speed = false
    Settings.PlayerMods.JumpPower = false
    Settings.PlayerMods.InfiniteJump = false
    Settings.ESP.Enabled = false
    Settings.Aimbot.Enabled = false

    stopNoclip()
    stopFly()
    stopInfiniteJump()
    applySpeed()
    applyJumpPower()

    -- Ngắt kết nối
    if Data.MainConnection then Data.MainConnection:Disconnect() end
    if Data.InputConnection then Data.InputConnection:Disconnect() end
    
    -- Xóa tất cả Drawings
    for player, espData in pairs(Drawings.ESPs) do
        removePlayerESP(player)
    end
    for name, drawing in pairs(Drawings) do
        if name ~= "ESPs" and drawing and typeof(drawing) == "Instance" then
            drawing:Remove()
        end
    end
    
    -- Xóa UI
    if Data.WindUIWindow then
        Data.WindUIWindow:Destroy()
    end
end

-- [BỔ SUNG] Xử lý phím tắt
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end -- Không chạy nếu đang chat

    -- Panic
    if input.KeyCode == Settings.Misc.PanicKey then
        panic()
    end

    -- Toggle Noclip
    if input.KeyCode == Settings.PlayerMods.NoClipKey then
        Settings.PlayerMods.Noclip = not Settings.PlayerMods.Noclip
        if Settings.PlayerMods.Noclip then
            startNoclip()
        else
            stopNoclip()
        end
        Data.WindUIWindow:Notify(Settings.PlayerMods.Noclip and "Noclip Enabled" or "Noclip Disabled")
    end

    -- Toggle Fly
    if input.KeyCode == Settings.PlayerMods.FlyKey then
        Settings.PlayerMods.Fly = not Settings.PlayerMods.Fly
        if Settings.PlayerMods.Fly then
            startFly()
        else
            stopFly()
        end
        Data.WindUIWindow:Notify(Settings.PlayerMods.Fly and "Fly Enabled" or "Fly Disabled")
    end
end

-- [BỔ SUNG] Hàm khởi tạo
local function init()
    -- Lưu giá trị gốc
    saveOriginalValues()
    LocalPlayer.CharacterAdded:Connect(saveOriginalValues)
    
    -- Tạo các đối tượng vẽ
    createDirectionLine()
    createFOVCircle()
    createCrosshair()
    createWatermark()
    
    -- Tạo UI
    createWindUI()
    
    -- Kết nối vòng lặp chính
    Data.MainConnection = RunService.RenderStepped:Connect(update)
    
    -- Kết nối phím tắt
    Data.InputConnection = UserInputService.InputBegan:Connect(onInputBegan)
end

-- Chạy script
init()

-- [KẾT THÚC BỔ SUNG]
