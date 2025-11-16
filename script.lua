--================================================--
--           WINDY UI AIMBOT EXECUTOR             --
--================================================--

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("CoreGui")

-- SETTINGS
local KeyToggle = Enum.KeyCode.E -- key toggle
local SmoothAmount = 0.2 -- càng thấp càng nhanh
local FOVRadius = 150 -- pixels
local AimPart = "Head" -- Head / Torso

-- STATE
local aimbotEnabled = false

--------------------------------------------------------
-- CREATE WINDY UI
--------------------------------------------------------
local WindyUI = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
WindyUI.Name = "WindyAimbotHub"

local mainFrame = Instance.new("Frame", WindyUI)
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
mainFrame.BackgroundTransparency = 0.15
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 2
stroke.Transparency = 0.5
local gradient = Instance.new("UIGradient", mainFrame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60,60,60))
}

-- BUTTON
local function newButton(text, posY)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0.5, -100, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

local toggleBtn = newButton("Toggle Aimbot", 20)

-- FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = FOVRadius
fovCircle.Color = Color3.fromRGB(0,255,0)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = true

--------------------------------------------------------
-- AIMBOT FUNCTIONS
--------------------------------------------------------

local function getClosestPlayer()
    local closest = nil
    local shortestDist = FOVRadius

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(AimPart) then
            local part = plr.Character[AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (mousePos - targetPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = part
                end
            end
        end
    end

    return closest
end

toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == KeyToggle then
        aimbotEnabled = not aimbotEnabled
    end
end)

RunService.RenderStepped:Connect(function()
    -- update fov circle
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    fovCircle.Radius = FOVRadius

    if aimbotEnabled then
        local target = getClosestPlayer()
        if target then
            local camPos = Camera.CFrame.Position
            local targetPos = target.Position
            -- smooth aim
            local newCF = CFrame.new(camPos, camPos:Lerp(targetPos, SmoothAmount))
            Camera.CFrame = CFrame.new(camPos, targetPos)
        end
    end
end)
