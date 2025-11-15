-- LocalScript trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0,0)
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true  -- kéo GUI

-- UI Gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,70)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,35))})
gradient.Rotation = 45
gradient.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Admin Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

-- Section function
local function createButton(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = frame

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90,90,90)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
    end)

    return btn
end

-- ===== Buttons =====
local y = 60
local espButton = createButton("ESP: OFF", y); y = y + 50
local teamCheckESPButton = createButton("TeamCheck ESP: ON", y); y = y + 50
local aimButton = createButton("AIM: OFF", y); y = y + 50
local teamCheckAimButton = createButton("TeamCheck AIM: ON", y); y = y + 50
local wallCheckButton = createButton("WallCheck: ON", y); y = y + 50
local flyButton = createButton("FLY: OFF", y); y = y + 50
local noclipButton = createButton("Noclip: OFF", y)

-- ===== Flags =====
local espEnabled = false
local aimEnabled = false
local flyEnabled = false
local noclipEnabled = false
local teamCheckESP = true
local teamCheckAim = true
local wallCheck = true
local aimStrength = 0.25
local aimDistance = 200

-- ===== Wall Check =====
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(origin, direction, rayParams)
    if ray then
        return ray.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

-- ===== ESP =====
local function addESP(character, plr)
    if character:FindFirstChild("Highlight") then return end
    if teamCheckESP and plr.Team == player.Team then return end
    if wallCheck and not isVisible(character:FindFirstChild("Head")) then return end
    local hl = Instance.new("Highlight")
    hl.Name = "Highlight"
    hl.Parent = character
    hl.FillColor = Color3.fromRGB(0,255,0)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.5
end

local function removeESP(character)
    local hl = character:FindFirstChild("Highlight")
    if hl then hl:Destroy() end
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            if espEnabled then
                addESP(plr.Character, plr)
            else
                removeESP(plr.Character)
            end
        end
    end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    updateESP()
end)

teamCheckESPButton.MouseButton1Click:Connect(function()
    teamCheckESP = not teamCheckESP
    teamCheckESPButton.Text = "TeamCheck ESP: " .. (teamCheckESP and "ON" or "OFF")
    updateESP()
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if espEnabled then addESP(char, plr) end
    end)
end)

player.CharacterAdded:Connect(function(char)
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then addESP(plr.Character, plr) end
        end
    end
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if flyEnabled then startFly() end
end)

-- ===== Smooth Aim =====
aimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimButton.Text = "AIM: " .. (aimEnabled and "ON" or "OFF")
end)

teamCheckAimButton.MouseButton1Click:Connect(function()
    teamCheckAim = not teamCheckAim
    teamCheckAimButton.Text = "TeamCheck AIM: " .. (teamCheckAim and "ON" or "OFF")
end)

wallCheckButton.MouseButton1Click:Connect(function()
    wallCheck = not wallCheck
    wallCheckButton.Text = "WallCheck: " .. (wallCheck and "ON" or "OFF")
end)

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local nearestHead = nil
        local nearestDist = math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                if teamCheckAim and plr.Team == player.Team then continue end
                local head = plr.Character.Head
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if dist > aimDistance then continue end
                if wallCheck and not isVisible(head) then continue end
                if dist < nearestDist then
                    nearestDist = dist
                    nearestHead = head
                end
            end
        end
        if nearestHead then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, nearestHead.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, aimStrength)
        end
    end
end)

-- ===== Fly =====
local flySpeed = 50
local bodyVelocity = nil
local function startFly()
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root
end
local function stopFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end
flyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = "FLY: " .. (flyEnabled and "ON" or "OFF")
    if flyEnabled then startFly() else stopFly() end
end)
RunService.RenderStepped:Connect(function(dt)
    if flyEnabled and bodyVelocity then
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- ===== Noclip =====
local function startNoclip(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end
local function stopNoclip(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end
noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
    local character = player.Character
    if character then
        if noclipEnabled then startNoclip(character) else stopNoclip(character) end
    end
end)
