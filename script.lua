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
screenGui.Name = "AdminPanelPro"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 500)
frame.Position = UDim2.new(0, 30, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0,0)
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

-- Shadow effect
local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.fromRGB(100,100,100)
uistroke.Thickness = 2
uistroke.Parent = frame

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20))
})
gradient.Rotation = 45
gradient.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Admin Panel Pro"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

-- ===== Helper Functions =====
local function createToggle(text, y, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,40)
    container.Position = UDim2.new(0,10,0,y)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0,50,0,25)
    toggle.Position = UDim2.new(0.75,0,0.5,-12)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(120,120,120)
    toggle.BorderSizePixel = 0
    toggle.AnchorPoint = Vector2.new(0,0)
    toggle.Parent = container

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,20,0,20)
    circle.Position = default and UDim2.new(1,-20,0.5,-10) or UDim2.new(0,0,0.5,-10)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BorderSizePixel = 0
    circle.AnchorPoint = Vector2.new(0,0)
    circle.Parent = toggle
    circle.Name = "Circle"

    local toggleValue = default

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleValue = not toggleValue
            local targetColor = toggleValue and Color3.fromRGB(0,200,0) or Color3.fromRGB(120,120,120)
            local circlePos = toggleValue and UDim2.new(1,-20,0.5,-10) or UDim2.new(0,0,0.5,-10)
            TweenService:Create(toggle,TweenInfo.new(0.2),{BackgroundColor3=targetColor}):Play()
            TweenService:Create(circle,TweenInfo.new(0.2),{Position=circlePos}):Play()
        end
    end)

    return container, function() return toggleValue end
end

local function createSlider(text, y, min,max,default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,40)
    container.Position = UDim2.new(0,10,0,y)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text.." ("..default..")"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.45,0,0,8)
    bar.Position = UDim2.new(0.5,0,0.5,-4)
    bar.BackgroundColor3 = Color3.fromRGB(100,100,100)
    bar.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,0)
    fill.Parent = bar

    local value = default
    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            value = math.floor(min + relative*(max-min))
            fill.Size = UDim2.new(relative,0,1,0)
            label.Text = text.." ("..value..")"
        end
    end)

    return container, function() return value end
end

-- ===== Create Toggles =====
local y = 70
local espToggle, getESP = createToggle("ESP",y,true); y = y + 50
local teamCheckESPToggle, getTeamESP = createToggle("TeamCheck ESP",y,true); y = y + 50
local aimToggle, getAim = createToggle("AIM",y,true); y = y + 50
local teamCheckAimToggle, getTeamAim = createToggle("TeamCheck AIM",y,true); y = y + 50
local wallCheckToggle, getWallCheck = createToggle("WallCheck",y,true); y = y + 50
local flyToggle, getFly = createToggle("FLY",y,false); y = y + 50
local noclipToggle, getNoclip = createToggle("Noclip",y,false); y = y + 50

-- ===== Slider =====
local aimDistanceSlider, getAimDistance = createSlider("Aim Distance",y,50,500,200); y = y + 60

-- ===== Flags =====
local espEnabled = true
local aimEnabled = true
local flyEnabled = false
local noclipEnabled = false
local teamCheckESP = true
local teamCheckAim = true
local wallCheck = true
local aimStrength = 0.25
local aimDistance = 200

-- ===== Functions =====
local function updateFlags()
    espEnabled = getESP()
    aimEnabled = getAim()
    flyEnabled = getFly()
    noclipEnabled = getNoclip()
    teamCheckESP = getTeamESP()
    teamCheckAim = getTeamAim()
    wallCheck = getWallCheck()
    aimDistance = getAimDistance()
end

-- ===== Wall Check =====
local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(origin,direction,rayParams)
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
    updateFlags()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            if espEnabled then addESP(plr.Character,plr)
            else removeESP(plr.Character) end
        end
    end
end

-- ===== RenderStepped Loop =====
RunService.RenderStepped:Connect(function()
    updateFlags()

    -- ESP
    if espEnabled then updateESP() end

    -- Aim
    if aimEnabled then
        local nearestHead = nil
        local nearestDist = math.huge
        for _,plr in pairs(Players:GetPlayers()) do
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
            local cf = Camera.CFrame
            local targetCF = CFrame.new(cf.Position, nearestHead.Position)
            Camera.CFrame = cf:Lerp(targetCF, aimStrength)
        end
    end

    -- Fly
    if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
        if dir.Magnitude > 0 then
            root.BV.Velocity = dir.Unit * 50
        else
            root.BV.Velocity = Vector3.new(0,0,0)
        end
    elseif player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("BV") then
        player.Character.HumanoidRootPart.BV:Destroy()
    end

    -- Noclip
    if noclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
