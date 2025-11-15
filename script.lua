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
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Config mặc định tắt tất cả
local ESPEnabled, ESPTeamCheck, ESPWallCheck, ESPDistance = false, false, false, 200
local AimEnabled, AimTeamCheck, AimWallCheck, AimDistance, SmoothStrength = false, false, false, 200, 0.25
local FlyEnabled, NoclipEnabled, RadarEnabled, AntiFlingEnabled = false, false, false, false

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

-- ESP System
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
    drawing.Box.Color = Color3.fromRGB(255, 0, 0)
    
    drawing.Name.Size = 13
    drawing.Name.Outline = true
    drawing.Name.Color = Color3.fromRGB(255, 255, 255)
    
    drawing.Distance.Size = 13
    drawing.Distance.Outline = true
    drawing.Distance.Color = Color3.fromRGB(255, 255, 255)
    
    drawing.Tracer.Thickness = 2
    drawing.Tracer.Color = Color3.fromRGB(255, 0, 0)
    
    self.Objects[player] = drawing
end

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
        
        -- Team check
        if ESPTeamCheck and target.Team == player.Team then
            self:RemoveESPPart(target)
            continue
        end
        
        -- Distance check
        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        if distance > ESPDistance then
            self:RemoveESPPart(target)
            continue
        end
        
        -- Wall check
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
            
            -- Box
            drawings.Box.Size = boxSize
            drawings.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
            drawings.Box.Visible = true
            
            -- Name
            drawings.Name.Text = target.Name
            drawings.Name.Position = Vector2.new(vector.X, vector.Y - boxSize.Y / 2 - 15)
            drawings.Name.Visible = true
            
            -- Distance
            drawings.Distance.Text = string.format("[%d]", distance)
            drawings.Distance.Position = Vector2.new(vector.X, vector.Y + boxSize.Y / 2 + 5)
            drawings.Distance.Visible = true
            
            -- Tracer
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

-- Aimbot System
local function getClosestPlayer()
    local closestPlayer, closestDistance = nil, AimDistance
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, target in pairs(Players:GetPlayers()) do
        if target == player then continue end
        if not target.Character then continue end
        
        local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        -- Team check
        if AimTeamCheck and target.Team == player.Team then continue end
        
        -- Distance check
        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        if distance > AimDistance then continue end
        
        -- Wall check
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

-- Movement Systems
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

-- Radar System
local radarFrame
local function toggleRadar()
    if RadarEnabled and not radarFrame then
        radarFrame = Instance.new("Frame")
        radarFrame.Size = UDim2.new(0, 200, 0, 200)
        radarFrame.Position = UDim2.new(0, 10, 0, 10)
        radarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        radarFrame.BackgroundTransparency = 0.3
        radarFrame.BorderSizePixel = 0
        radarFrame.Parent = player.PlayerGui:FindFirstChild("CoreGui") or player.PlayerGui
        
        -- Radar update connection
        RunService.Heartbeat:Connect(function()
            if not RadarEnabled or not radarFrame then return end
            
            -- Clear previous blips
            for _, child in pairs(radarFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            -- Add new blips
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local root = target.Character.HumanoidRootPart
                    local relativePos = player.Character.HumanoidRootPart.CFrame:PointToObjectSpace(root.Position)
                    
                    local blip = Instance.new("Frame")
                    blip.Size = UDim2.new(0, 6, 0, 6)
                    blip.Position = UDim2.new(0.5 + relativePos.X / 100, 0, 0.5 - relativePos.Z / 100, 0)
                    blip.BackgroundColor3 = target.Team == player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    blip.BorderSizePixel = 0
                    blip.Parent = radarFrame
                end
            end
        end)
    elseif not RadarEnabled and radarFrame then
        radarFrame:Destroy()
        radarFrame = nil
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
    toggleRadar()
end})

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
SettingsTab:Button({Title = "Save Config", Desc = "Lưu lại cấu hình hiện tại", Callback = saveConfig})
SettingsTab:Button({Title = "Load Config", Desc = "Tải cấu hình đã lưu", Callback = loadConfig})

-- Character added event
player.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    if FlyEnabled then toggleFly() end
    if NoclipEnabled then toggleNoclip() end
    if AntiFlingEnabled then toggleAntiFling() end
end)

print("[.binh Hub] Loaded successfully!")
