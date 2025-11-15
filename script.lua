-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

-- Variables
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Main Settings
local Settings = {
    ESP = {
        Enabled = true,
        ShowTeam = false,
        ShowBoxes = true,
        ShowTracers = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        MaxDistance = 500,
        BoxColor = Color3.new(1, 1, 1),
        TracerColor = Color3.new(1, 1, 1),
        NameColor = Color3.new(1, 1, 1),
        TeamColor = true
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
    Misc = {
        PanicKey = Enum.KeyCode.Delete,
        UIStyle = "Dark",
        RainbowMode = false,
        AutoUpdate = true
    }
}

-- Store drawing objects and data
local Drawings = {
    DirectionLine = nil,
    FOVCircle = nil,
    Crosshair = nil,
    Watermark = nil,
    HitMarker = nil,
    ESPs = {},
    UI = nil
}

local Data = {
    Connections = {},
    RainbowHue = 0,
    Target = nil,
    HitTime = 0
}

-- Windy UI Library
local WindyUI = {}
WindyUI.__index = WindyUI

function WindyUI:CreateWindow(title, size)
    local Window = {}
    setmetatable(Window, WindyUI)
    
    -- Create main GUI
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = "WindyUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
    Window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Window.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main container
    Window.MainFrame = Instance.new("Frame")
    Window.MainFrame.Size = size or UDim2.new(0, 450, 0, 550)
    Window.MainFrame.Position = UDim2.new(0, 20, 0, 20)
    Window.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.MainFrame.BorderSizePixel = 0
    Window.MainFrame.ClipsDescendants = true
    Window.MainFrame.Parent = Window.ScreenGui
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Window.MainFrame
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = Window.MainFrame
    Shadow.ZIndex = -1
    
    -- Title bar
    Window.TitleBar = Instance.new("Frame")
    Window.TitleBar.Name = "TitleBar"
    Window.TitleBar.Size = UDim2.new(1, 0, 0, 45)
    Window.TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Window.TitleBar.BorderSizePixel = 0
    Window.TitleBar.Parent = Window.MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Window.TitleBar
    
    -- Title
    Window.TitleLabel = Instance.new("TextLabel")
    Window.TitleLabel.Name = "TitleLabel"
    Window.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    Window.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    Window.TitleLabel.BackgroundTransparency = 1
    Window.TitleLabel.Text = title or "Windy UI"
    Window.TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    Window.TitleLabel.TextSize = 20
    Window.TitleLabel.Font = Enum.Font.GothamBold
    Window.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    Window.TitleLabel.Parent = Window.TitleBar
    
    -- Close button
    Window.CloseButton = Instance.new("TextButton")
    Window.CloseButton.Name = "CloseButton"
    Window.CloseButton.Size = UDim2.new(0, 80, 0, 30)
    Window.CloseButton.Position = UDim2.new(1, -90, 0, 7)
    Window.CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    Window.CloseButton.BorderSizePixel = 0
    Window.CloseButton.Text = "CLOSE"
    Window.CloseButton.TextColor3 = Color3.new(1, 1, 1)
    Window.CloseButton.TextSize = 12
    Window.CloseButton.Font = Enum.Font.GothamBold
    Window.CloseButton.Parent = Window.TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = Window.CloseButton
    
    -- Tab container
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(1, -20, 0, 40)
    Window.TabContainer.Position = UDim2.new(0, 10, 0, 55)
    Window.TabContainer.BackgroundTransparency = 1
    Window.TabContainer.Parent = Window.MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = Window.TabContainer
    
    -- Content container
    Window.ContentFrame = Instance.new("Frame")
    Window.ContentFrame.Name = "ContentFrame"
    Window.ContentFrame.Size = UDim2.new(1, -20, 1, -120)
    Window.ContentFrame.Position = UDim2.new(0, 10, 0, 105)
    Window.ContentFrame.BackgroundTransparency = 1
    Window.ContentFrame.Parent = Window.MainFrame
    
    -- Make draggable
    Window:Draggable()
    
    -- Close functionality
    Window.CloseButton.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    return Window
end

function WindyUI:CreateTab(name)
    local Tab = {}
    
    -- Tab button
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Name = name .. "Tab"
    Tab.Button.Size = UDim2.new(0, 100, 1, 0)
    Tab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Text = name
    Tab.Button.TextColor3 = Color3.new(1, 1, 1)
    Tab.Button.TextSize = 14
    Tab.Button.Font = Enum.Font.GothamSemibold
    Tab.Button.Parent = self.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = Tab.Button
    
    -- Tab content
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Name = name .. "Content"
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    Tab.Content.Position = UDim2.new(0, 0, 0, 0)
    Tab.Content.BackgroundTransparency = 1
    Tab.Content.BorderSizePixel = 0
    Tab.Content.ScrollBarThickness = 3
    Tab.Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    Tab.Content.Visible = false
    Tab.Content.Parent = self.ContentFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = Tab.Content
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 5)
    ContentPadding.PaddingRight = UDim.new(0, 5)
    ContentPadding.Parent = Tab.Content
    
    -- Tab click event
    Tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(Tab)
    end)
    
    self.Tabs[name] = Tab
    
    -- Set as first tab if none selected
    if not self.CurrentTab then
        self:SwitchTab(Tab)
    end
    
    return Tab
end

function WindyUI:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        self.CurrentTab.Content.Visible = false
    end
    
    self.CurrentTab = tab
    tab.Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    tab.Content.Visible = true
end

function WindyUI:CreateSection(tab, title)
    local Section = {}
    
    Section.Frame = Instance.new("Frame")
    Section.Frame.Size = UDim2.new(1, 0, 0, 40)
    Section.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Section.Frame.BorderSizePixel = 0
    Section.Frame.Parent = tab.Content
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section.Frame
    
    Section.Title = Instance.new("TextLabel")
    Section.Title.Size = UDim2.new(1, -20, 1, 0)
    Section.Title.Position = UDim2.new(0, 10, 0, 0)
    Section.Title.BackgroundTransparency = 1
    Section.Title.Text = title
    Section.Title.TextColor3 = Color3.new(1, 1, 1)
    Section.Title.TextSize = 16
    Section.Title.Font = Enum.Font.GothamSemibold
    Section.Title.TextXAlignment = Enum.TextXAlignment.Left
    Section.Title.Parent = Section.Frame
    
    Section.Content = Instance.new("Frame")
    Section.Content.Size = UDim2.new(1, -20, 0, 0)
    Section.Content.Position = UDim2.new(0, 10, 0, 40)
    Section.Content.BackgroundTransparency = 1
    Section.Content.Parent = Section.Frame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = Section.Content
    
    return Section
end

function WindyUI:CreateToggle(section, text, defaultValue, callback)
    local Toggle = {}
    
    Toggle.Frame = Instance.new("Frame")
    Toggle.Frame.Size = UDim2.new(1, 0, 0, 30)
    Toggle.Frame.BackgroundTransparency = 1
    Toggle.Frame.Parent = section.Content
    
    Toggle.Label = Instance.new("TextLabel")
    Toggle.Label.Size = UDim2.new(0.7, 0, 1, 0)
    Toggle.Label.BackgroundTransparency = 1
    Toggle.Label.Text = text
    Toggle.Label.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Label.TextSize = 14
    Toggle.Label.Font = Enum.Font.Gotham
    Toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
    Toggle.Label.Parent = Toggle.Frame
    
    Toggle.Button = Instance.new("TextButton")
    Toggle.Button.Size = UDim2.new(0, 50, 0, 25)
    Toggle.Button.Position = UDim2.new(1, -50, 0, 2)
    Toggle.Button.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    Toggle.Button.BorderSizePixel = 0
    Toggle.Button.Text = ""
    Toggle.Button.Parent = Toggle.Frame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = Toggle.Button
    
    Toggle.Knob = Instance.new("Frame")
    Toggle.Knob.Size = UDim2.new(0, 21, 0, 21)
    Toggle.Knob.Position = UDim2.new(0, defaultValue and 29 or 2, 0, 2)
    Toggle.Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Toggle.Knob.BorderSizePixel = 0
    Toggle.Knob.Parent = Toggle.Button
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(0, 10)
    KnobCorner.Parent = Toggle.Knob
    
    Toggle.Value = defaultValue
    
    Toggle.Button.MouseButton1Click:Connect(function()
        Toggle.Value = not Toggle.Value
        local newPos = Toggle.Value and 29 or 2
        local newColor = Toggle.Value and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = TweenService:Create(Toggle.Knob, tweenInfo, {Position = UDim2.new(0, newPos, 0, 2)})
        local tween2 = TweenService:Create(Toggle.Button, tweenInfo, {BackgroundColor3 = newColor})
        
        tween1:Play()
        tween2:Play()
        
        if callback then
            callback(Toggle.Value)
        end
    end)
    
    return Toggle
end

function WindyUI:CreateSlider(section, text, minValue, maxValue, defaultValue, callback)
    local Slider = {}
    
    Slider.Frame = Instance.new("Frame")
    Slider.Frame.Size = UDim2.new(1, 0, 0, 60)
    Slider.Frame.BackgroundTransparency = 1
    Slider.Frame.Parent = section.Content
    
    Slider.Label = Instance.new("TextLabel")
    Slider.Label.Size = UDim2.new(1, 0, 0, 20)
    Slider.Label.BackgroundTransparency = 1
    Slider.Label.Text = text .. ": " .. defaultValue
    Slider.Label.TextColor3 = Color3.new(1, 1, 1)
    Slider.Label.TextSize = 14
    Slider.Label.Font = Enum.Font.Gotham
    Slider.Label.TextXAlignment = Enum.TextXAlignment.Left
    Slider.Label.Parent = Slider.Frame
    
    Slider.Background = Instance.new("Frame")
    Slider.Background.Size = UDim2.new(1, 0, 0, 20)
    Slider.Background.Position = UDim2.new(0, 0, 0, 25)
    Slider.Background.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Slider.Background.BorderSizePixel = 0
    Slider.Background.Parent = Slider.Frame
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 10)
    BackgroundCorner.Parent = Slider.Background
    
    Slider.Fill = Instance.new("Frame")
    Slider.Fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    Slider.Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Slider.Fill.BorderSizePixel = 0
    Slider.Fill.Parent = Slider.Background
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = Slider.Fill
    
    Slider.Button = Instance.new("TextButton")
    Slider.Button.Size = UDim2.new(0, 20, 0, 20)
    Slider.Button.Position = UDim2.new(Slider.Fill.Size.X.Scale, -10, 0, 0)
    Slider.Button.BackgroundColor3 = Color3.new(1, 1, 1)
    Slider.Button.BorderSizePixel = 0
    Slider.Button.Text = ""
    Slider.Button.Parent = Slider.Background
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = Slider.Button
    
    Slider.Value = defaultValue
    Slider.Min = minValue
    Slider.Max = maxValue
    
    local function updateSlider(input)
        local relativeX = (input.Position.X - Slider.Background.AbsolutePosition.X) / Slider.Background.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        local value = minValue + (maxValue - minValue) * relativeX
        value = math.floor(value)
        
        Slider.Fill.Size = UDim2.new(relativeX, 0, 1, 0)
        Slider.Button.Position = UDim2.new(relativeX, -10, 0, 0)
        Slider.Label.Text = text .. ": " .. value
        Slider.Value = value
        
        if callback then
            callback(value)
        end
    end
    
    local dragging = false
    
    Slider.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    Slider.Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    Slider.Background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    return Slider
end

function WindyUI:CreateDropdown(section, text, options, defaultValue, callback)
    local Dropdown = {}
    
    Dropdown.Frame = Instance.new("Frame")
    Dropdown.Frame.Size = UDim2.new(1, 0, 0, 30)
    Dropdown.Frame.BackgroundTransparency = 1
    Dropdown.Frame.Parent = section.Content
    
    Dropdown.Label = Instance.new("TextLabel")
    Dropdown.Label.Size = UDim2.new(0.4, 0, 1, 0)
    Dropdown.Label.BackgroundTransparency = 1
    Dropdown.Label.Text = text
    Dropdown.Label.TextColor3 = Color3.new(1, 1, 1)
    Dropdown.Label.TextSize = 14
    Dropdown.Label.Font = Enum.Font.Gotham
    Dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
    Dropdown.Label.Parent = Dropdown.Frame
    
    Dropdown.Button = Instance.new("TextButton")
    Dropdown.Button.Size = UDim2.new(0.55, 0, 1, 0)
    Dropdown.Button.Position = UDim2.new(0.4, 0, 0, 0)
    Dropdown.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Dropdown.Button.BorderSizePixel = 0
    Dropdown.Button.Text = defaultValue or "Select..."
    Dropdown.Button.TextColor3 = Color3.new(1, 1, 1)
    Dropdown.Button.TextSize = 14
    Dropdown.Button.Font = Enum.Font.Gotham
    Dropdown.Button.Parent = Dropdown.Frame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Dropdown.Button
    
    Dropdown.Options = options
    Dropdown.Value = defaultValue
    
    Dropdown.Button.MouseButton1Click:Connect(function()
        -- Create dropdown list
        local DropdownList = Instance.new("Frame")
        DropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
        DropdownList.Position = UDim2.new(0, 0, 1, 5)
        DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        DropdownList.BorderSizePixel = 0
        DropdownList.Parent = Dropdown.Button
        
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 6)
        ListCorner.Parent = DropdownList
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
            OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            OptionButton.BorderSizePixel = 0
            OptionButton.Text = option
            OptionButton.TextColor3 = Color3.new(1, 1, 1)
            OptionButton.TextSize = 14
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.Parent = DropdownList
            
            OptionButton.MouseButton1Click:Connect(function()
                Dropdown.Value = option
                Dropdown.Button.Text = option
                DropdownList:Destroy()
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        -- Close dropdown when clicking elsewhere
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not DropdownList:IsDescendantOf(workspace) then
                    connection:Disconnect()
                else
                    local mousePos = UserInputService:GetMouseLocation()
                    local buttonPos = Dropdown.Button.AbsolutePosition
                    local buttonSize = Dropdown.Button.AbsoluteSize
                    local listPos = DropdownList.AbsolutePosition
                    local listSize = DropdownList.AbsoluteSize
                    
                    if not (mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                           mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y + listSize.Y) then
                        DropdownList:Destroy()
                        connection:Disconnect()
                    end
                end
            end
        end)
    end)
    
    return Dropdown
end

function WindyUI:CreateButton(section, text, callback)
    local Button = {}
    
    Button.Frame = Instance.new("TextButton")
    Button.Frame.Size = UDim2.new(1, 0, 0, 35)
    Button.Frame.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Button.Frame.BorderSizePixel = 0
    Button.Frame.Text = text
    Button.Frame.TextColor3 = Color3.new(1, 1, 1)
    Button.Frame.TextSize = 14
    Button.Frame.Font = Enum.Font.GothamSemibold
    Button.Frame.Parent = section.Content
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button.Frame
    
    Button.Frame.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return Button
end

function WindyUI:CreateLabel(section, text, size)
    local Label = {}
    
    Label.Frame = Instance.new("TextLabel")
    Label.Frame.Size = UDim2.new(1, 0, 0, size or 20)
    Label.Frame.BackgroundTransparency = 1
    Label.Frame.Text = text
    Label.Frame.TextColor3 = Color3.new(1, 1, 1)
    Label.Frame.TextSize = size or 14
    Label.Frame.Font = Enum.Font.Gotham
    Label.Frame.TextXAlignment = Enum.TextXAlignment.Left
    Label.Frame.Parent = section.Content
    
    return Label
end

function WindyUI:Draggable()
    local dragging = false
    local dragInput, dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function WindyUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ESP Functions
local function createDirectionLine()
    if Drawings.DirectionLine then
        Drawings.DirectionLine:Remove()
    end
    
    Drawings.DirectionLine = Drawing.new("Line")
    Drawings.DirectionLine.Color = Settings.ESP.BoxColor
    Drawings.DirectionLine.Thickness = 2
    Drawings.DirectionLine.Visible = Settings.Visuals.DirectionLine
end

local function createFOVCircle()
    if Drawings.FOVCircle then
        Drawings.FOVCircle:Remove()
    end
    
    Drawings.FOVCircle = Drawing.new("Circle")
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Thickness = 2
    Drawings.FOVCircle.NumSides = 32
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Filled = false
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function createCrosshair()
    if Drawings.Crosshair then
        Drawings.Crosshair:Remove()
    end
    
    Drawings.Crosshair = Drawing.new("Line")
    Drawings.Crosshair.Visible = Settings.Visuals.Crosshair
    Drawings.Crosshair.Color = Color3.new(1, 1, 1)
    Drawings.Crosshair.Thickness = 1
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
end

local function createWatermark()
    if Drawings.Watermark then
        Drawings.Watermark:Remove()
    end
    
    Drawings.Watermark = Drawing.new("Text")
    Drawings.Watermark.Visible = Settings.Visuals.Watermark
    Drawings.Watermark.Color = Color3.new(1, 1, 1)
    Drawings.Watermark.Size = 16
    Drawings.Watermark.Font = 2
    Drawings.Watermark.Text = "Windy ESP | FPS: 60 | Ping: 0ms"
    Drawings.Watermark.Position = Vector2.new(10, 10)
end

local function updateDirectionLine()
    if not Drawings.DirectionLine or not Settings.Visuals.DirectionLine then
        if Drawings.DirectionLine then
            Drawings.DirectionLine.Visible = false
        end
        return
    end
    
    local lookVector = Camera.CFrame.LookVector
    local startPos = Camera.CFrame.Position
    local endPos = startPos + lookVector * Settings.ESP.MaxDistance
    
    local startVector, startVisible = Camera:WorldToViewportPoint(startPos)
    local endVector, endVisible = Camera:WorldToViewportPoint(endPos)
    
    if startVisible and endVisible then
        Drawings.DirectionLine.From = Vector2.new(startVector.X, startVector.Y)
        Drawings.DirectionLine.To = Vector2.new(endVector.X, endVector.Y)
        Drawings.DirectionLine.Visible = true
        Drawings.DirectionLine.Color = Settings.ESP.BoxColor
    else
        Drawings.DirectionLine.Visible = false
    end
end

local function updateFOVCircle()
    if not Drawings.FOVCircle or not Settings.Visuals.FOVCircle then
        if Drawings.FOVCircle then
            Drawings.FOVCircle.Visible = false
        end
        return
    end
    
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle
    Drawings.FOVCircle.Color = Settings.ESP.BoxColor
    Drawings.FOVCircle.Radius = Settings.Aimbot.FOV
    Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function updateCrosshair()
    if not Drawings.Crosshair or not Settings.Visuals.Crosshair then
        if Drawings.Crosshair then
            Drawings.Crosshair.Visible = false
        end
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Drawings.Crosshair.From = Vector2.new(center.X - 8, center.Y)
    Drawings.Crosshair.To = Vector2.new(center.X + 8, center.Y)
    Drawings.Crosshair.Visible = true
end

local function updateWatermark()
    if not Drawings.Watermark or not Settings.Visuals.Watermark then
        if Drawings.Watermark then
            Drawings.Watermark.Visible = false
        end
        return
    end
    
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    Drawings.Watermark.Text = string.format("Windy ESP | FPS: %d | Players: %d", fps, #Players:GetPlayers())
    Drawings.Watermark.Visible = true
end

local function updateESP()
    -- Clear existing ESP drawings
    for _, esp in pairs(Drawings.ESPs) do
        if esp.Box then esp.Box:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Distance then esp.Distance:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.HealthBar then esp.HealthBar:Remove() end
        if esp.HealthBarOutline then esp.HealthBarOutline:Remove() end
    end
    Drawings.ESPs = {}
    
    if not Settings.ESP.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                -- Team check
                if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                if distance > Settings.ESP.MaxDistance then
                    continue
                end
                
                -- Get player color
                local playerColor = Settings.ESP.BoxColor
                if Settings.ESP.TeamColor then
                    playerColor = player.TeamColor.Color
                end
                
                local espData = {}
                
                -- Box ESP
                if Settings.ESP.ShowBoxes then
                    espData.Box = Drawing.new("Square")
                    espData.Box.Visible = false
                    espData.Box.Color = playerColor
                    espData.Box.Thickness = 2
                    espData.Box.Filled = false
                end
                
                -- Tracer
                if Settings.ESP.ShowTracers then
                    espData.Tracer = Drawing.new("Line")
                    espData.Tracer.Visible = false
                    espData.Tracer.Color = playerColor
                    espData.Tracer.Thickness = 1
                end
                
                -- Name
                if Settings.ESP.ShowNames then
                    espData.Name = Drawing.new("Text")
                    espData.Name.Visible = false
                    espData.Name.Color = Settings.ESP.NameColor
                    espData.Name.Size = 14
                    espData.Name.Font = 2
                    espData.Name.Text = player.Name
                end
                
                -- Distance
                if Settings.ESP.ShowDistance then
                    espData.Distance = Drawing.new("Text")
                    espData.Distance.Visible = false
                    espData.Distance.Color = Settings.ESP.NameColor
                    espData.Distance.Size = 12
                    espData.Distance.Font = 2
                    espData.Distance.Text = string.format("[%d]", distance)
                end
                
                -- Health
                if Settings.ESP.ShowHealth then
                    espData.Health = Drawing.new("Text")
                    espData.Health.Visible = false
                    espData.Health.Color = Color3.new(1, 1, 1)
                    espData.Health.Size = 12
                    espData.Health.Font = 2
                    espData.Health.Text = string.format("%d", humanoid.Health)
                    
                    -- Health bar
                    espData.HealthBarOutline = Drawing.new("Square")
                    espData.HealthBarOutline.Visible = false
                    espData.HealthBarOutline.Color = Color3.new(0, 0, 0)
                    espData.HealthBarOutline.Thickness = 1
                    espData.HealthBarOutline.Filled = false
                    
                    espData.HealthBar = Drawing.new("Square")
                    espData.HealthBar.Visible = false
                    espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                    espData.HealthBar.Thickness = 1
                    espData.HealthBar.Filled = true
                end
                
                Drawings.ESPs[player] = espData
                
                -- Update ESP positions
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
                    local rootPos = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if headVisible then
                        local scaleFactor = 1 / (headPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
                        local width = 4 * scaleFactor
                        local height = 6 * scaleFactor
                        
                        -- Box ESP
                        if espData.Box then
                            espData.Box.Size = Vector2.new(width, height)
                            espData.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - height / 2)
                            espData.Box.Visible = true
                        end
                        
                        -- Tracer
                        if espData.Tracer then
                            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            espData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            espData.Tracer.Visible = true
                        end
                        
                        -- Name
                        if espData.Name then
                            espData.Name.Position = Vector2.new(headPos.X, headPos.Y - height / 2 - 20)
                            espData.Name.Visible = true
                        end
                        
                        -- Distance
                        if espData.Distance then
                            espData.Distance.Position = Vector2.new(headPos.X, headPos.Y - height / 2 - 35)
                            espData.Distance.Visible = true
                        end
                        
                        -- Health
                        if espData.Health then
                            espData.Health.Position = Vector2.new(headPos.X, headPos.Y + height / 2 + 5)
                            espData.Health.Visible = true
                            
                            -- Health bar
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            local barWidth = width
                            local barHeight = 3
                            local barX = headPos.X - width / 2
                            local barY = headPos.Y - height / 2 - 8
                            
                            espData.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
                            espData.HealthBarOutline.Position = Vector2.new(barX, barY)
                            espData.HealthBarOutline.Visible = true
                            
                            espData.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                            espData.HealthBar.Position = Vector2.new(barX, barY)
                            espData.HealthBar.Visible = true
                            espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        end
                    else
                        -- Hide all if not visible
                        for _, drawing in pairs(espData) do
                            if drawing then
                                drawing.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Aimbot Functions
local function updateAimbot()
    if not Settings.Aimbot.Enabled then return end
    
    local closestTarget = nil
    local closestDistance = Settings.Aimbot.FOV
    
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
                    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * Settings.ESP.MaxDistance)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                    if hit and hit:IsDescendantOf(character) == false then
                        continue
                    end
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
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
    
    -- Auto aim when target is found
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
        Data.RainbowHue = (Data.RainbowHue + 0.01) % 1
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
    
    -- Update hit marker
    if Drawings.HitMarker then
        local timeSinceHit = tick() - Data.HitTime
        if timeSinceHit < 0.3 then
            local alpha = 1 - (timeSinceHit / 0.3)
            Drawings.HitMarker.Color = Color3.new(1, 1, 1)
            Drawings.HitMarker.Visible = true
        else
            Drawings.HitMarker.Visible = false
        end
    end
end

-- Create UI
local function createUI()
    local Window = WindyUI:CreateWindow("Windy ESP v2.0", UDim2.new(0, 500, 0, 600))
    Drawings.UI = Window
    
    -- ESP Tab
    local ESPTab = Window:CreateTab("ESP")
    local ESPMain = Window:CreateSection(ESPTab, "ESP Settings")
    
    Window:CreateToggle(ESPMain, "Enable ESP", Settings.ESP.Enabled, function(value)
        Settings.ESP.Enabled = value
    end)
    
    Window:CreateToggle(ESPMain, "Show Boxes", Settings.ESP.ShowBoxes, function(value)
        Settings.ESP.ShowBoxes = value
    end)
    
    Window:CreateToggle(ESPMain, "Show Tracers", Settings.ESP.ShowTracers, function(value)
        Settings.ESP.ShowTracers = value
    end)
    
    Window:CreateToggle(ESPMain, "Show Names", Settings.ESP.ShowNames, function(value)
        Settings.ESP.ShowNames = value
    end)
    
    Window:CreateToggle(ESPMain, "Show Distance", Settings.ESP.ShowDistance, function(value)
        Settings.ESP.ShowDistance = value
    end)
    
    Window:CreateToggle(ESPMain, "Show Health", Settings.ESP.ShowHealth, function(value)
        Settings.ESP.ShowHealth = value
    end)
    
    Window:CreateToggle(ESPMain, "Team Check", Settings.ESP.TeamCheck, function(value)
        Settings.ESP.TeamCheck = value
    end)
    
    Window:CreateToggle(ESPMain, "Team Colors", Settings.ESP.TeamColor, function(value)
        Settings.ESP.TeamColor = value
    end)
    
    Window:CreateSlider(ESPMain, "Max Distance", 50, 1000, Settings.ESP.MaxDistance, function(value)
        Settings.ESP.MaxDistance = value
    end)
    
    -- Aimbot Tab
    local AimbotTab = Window:CreateTab("Aimbot")
    local AimbotMain = Window:CreateSection(AimbotTab, "Aimbot Settings")
    
    Window:CreateToggle(AimbotMain, "Enable Aimbot", Settings.Aimbot.Enabled, function(value)
        Settings.Aimbot.Enabled = value
    end)
    
    Window:CreateSlider(AimbotMain, "Smoothness", 0, 1, Settings.Aimbot.Smoothness, function(value)
        Settings.Aimbot.Smoothness = value
    end)
    
    Window:CreateSlider(AimbotMain, "FOV Circle", 10, 200, Settings.Aimbot.FOV, function(value)
        Settings.Aimbot.FOV = value
    end)
    
    Window:CreateToggle(AimbotMain, "Visibility Check", Settings.Aimbot.VisibleCheck, function(value)
        Settings.Aimbot.VisibleCheck = value
    end)
    
    Window:CreateToggle(AimbotMain, "Team Check", Settings.Aimbot.TeamCheck, function(value)
        Settings.Aimbot.TeamCheck = value
    end)
    
    Window:CreateDropdown(AimbotMain, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, Settings.Aimbot.TargetPart, function(value)
        Settings.Aimbot.TargetPart = value
    end)
    
    -- Visuals Tab
    local VisualsTab = Window:CreateTab("Visuals")
    local VisualsMain = Window:CreateSection(VisualsTab, "Visual Settings")
    
    Window:CreateToggle(VisualsMain, "Direction Line", Settings.Visuals.DirectionLine, function(value)
        Settings.Visuals.DirectionLine = value
    end)
    
    Window:CreateToggle(VisualsMain, "FOV Circle", Settings.Visuals.FOVCircle, function(value)
        Settings.Visuals.FOVCircle = value
    end)
    
    Window:CreateToggle(VisualsMain, "Crosshair", Settings.Visuals.Crosshair, function(value)
        Settings.Visuals.Crosshair = value
    end)
    
    Window:CreateToggle(VisualsMain, "Watermark", Settings.Visuals.Watermark, function(value)
        Settings.Visuals.Watermark = value
    end)
    
    Window:CreateToggle(VisualsMain, "Hit Marker", Settings.Visuals.HitMarker, function(value)
        Settings.Visuals.HitMarker = value
        if value and not Drawings.HitMarker then
            Drawings.HitMarker = Drawing.new("Line")
            Drawings.HitMarker.Visible = false
            Drawings.HitMarker.Thickness = 2
        end
    end)
    
    -- Misc Tab
    local MiscTab = Window:CreateTab("Misc")
    local MiscMain = Window:CreateSection(MiscTab, "Miscellaneous")
    
    Window:CreateToggle(MiscMain, "Rainbow Mode", Settings.Misc.RainbowMode, function(value)
        Settings.Misc.RainbowMode = value
    end)
    
    Window:CreateButton(MiscMain, "Save Configuration", function()
        print("Configuration saved!")
    end)
    
    Window:CreateButton(MiscMain, "Load Configuration", function()
        print("Configuration loaded!")
    end)
    
    Window:CreateButton(MiscMain, "Reset Settings", function()
        for key, value in pairs(Settings) do
            if type(value) == "table" then
                for k, v in pairs(value) do
                    -- Reset to defaults
                end
            end
        end
        print("Settings reset!")
    end)
    
    Window:CreateLabel(MiscMain, "Panic Key: " .. Settings.Misc.PanicKey.Name, 12)
    Window:CreateLabel(MiscMain, "Windy ESP v2.0 - Made with ❤️", 12)
    
    return Window
end

-- Initialize
createDirectionLine()
createFOVCircle()
createCrosshair()
createWatermark()
createUI()

-- Start main loop
Data.Connections.MainLoop = RunService.RenderStepped:Connect(update)

-- Panic key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Settings.Misc.PanicKey then
        -- Clean up everything
        for _, drawing in pairs(Drawings) do
            if typeof(drawing) == "table" then
                for _, d in pairs(drawing) do
                    if d and d.Remove then
                        d:Remove()
                    end
                end
            elseif drawing and drawing.Remove then
                drawing:Remove()
            end
        end
        
        if Drawings.UI then
            Drawings.UI:Destroy()
        end
        
        for _, connection in pairs(Data.Connections) do
            connection:Disconnect()
        end
        
        print("Windy ESP - Panic mode activated!")
    end
    
    -- Toggle UI with Insert key
    if input.KeyCode == Enum.KeyCode.Insert then
        if Drawings.UI and Drawings.UI.MainFrame then
            Drawings.UI.MainFrame.Visible = not Drawings.UI.MainFrame.Visible
        end
    end
end)

-- Hit detection (simulated)
local function onHit(hit)
    if Settings.Visuals.HitMarker and hit and hit.Parent then
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Data.HitTime = tick()
        end
    end
end

-- Simulate hits for demonstration
game:GetService("RunService").Heartbeat:Connect(function()
    if Data.Target and math.random(1, 100) == 1 then -- Simulate occasional hits
        onHit(Data.Target)
    end
end)

print("Windy ESP v2.0 Loaded!")
print("Press Insert to toggle UI")
print("Press " .. Settings.Misc.PanicKey.Name .. " for panic mode")
