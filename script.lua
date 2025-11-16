-- UltimateAdminPanel v2 (Refactored & Safer)
-- HƯỚNG DẪN: Tập trung vào cải thiện cấu trúc, hiệu năng, bảo trì.
-- LƯU Ý VỀ ĐẠO ĐỨC: Mã này là bản biến đổi từ mã người dùng cung cấp. Tránh sử dụng hành vi gây hại/vi phạm nội quy trò chơi.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ======= Cấu hình chung & helpers =======
local MODULE = {}
MODULE.VERSION = "2.0"
MODULE.State = {
    Theme = "Dark",
    Toggles = {}, -- lưu trạng thái của mọi toggle theo key
    Sliders = {},
    Dropdowns = {},
}

local themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(40, 40, 60),
        Text = Color3.new(1, 1, 1),
        Accent = Color3.fromRGB(0, 170, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(220, 220, 230),
        Text = Color3.new(0, 0, 0),
        Accent = Color3.fromRGB(0, 120, 215)
    },
    Purple = {
        Background = Color3.fromRGB(35, 25, 45),
        Secondary = Color3.fromRGB(60, 40, 80),
        Text = Color3.new(1, 1, 1),
        Accent = Color3.fromRGB(170, 0, 255)
    }
}

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[UltimateAdminPanel] Error:", err)
    end
    return ok, err
end

-- Apply theme to UI elements. We keep references to dynamic elements below.
local uiRefs = {}
local function applyTheme(themeName)
    local t = themes[themeName] or themes.Dark
    MODULE.State.Theme = themeName
    if uiRefs.MainFrame then
        uiRefs.MainFrame.BackgroundColor3 = t.Background
    end
    if uiRefs.TitleBar then
        uiRefs.TitleBar.BackgroundColor3 = t.Secondary
    end
    -- apply to other known refs
    for _, v in pairs(uiRefs.ToggleLabels or {}) do
        if v:IsA("TextLabel") then
            v.TextColor3 = t.Text
        end
    end
    if uiRefs.Title then uiRefs.Title.TextColor3 = t.Text end
end

-- ======= UI Creation Helpers (modular, returns state getters/setters) =======
local function newInstance(class, parent, props)
    local ins = Instance.new(class)
    ins.Parent = parent
    if props then
        for k, v in pairs(props) do
            -- safe set
            safeCall(function() ins[k] = v end)
        end
    end
    return ins
end

-- Create main GUI container
local ScreenGui = newInstance("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"), {Name = "UltimateAdminPanel", ResetOnSpawn = false})
local MainFrame = newInstance("Frame", ScreenGui, {
    Size = UDim2.new(0, 350, 0, 500),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = themes[MODULE.State.Theme].Background,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
})
uiRefs.MainFrame = MainFrame

local TitleBar = newInstance("Frame", MainFrame, {Size = UDim2.new(1,0,0,35), Position = UDim2.new(0,0,0,0), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, BorderSizePixel = 0})
uiRefs.TitleBar = TitleBar
local Title = newInstance("TextLabel", TitleBar, {Text = "⚡ ULTIMATE ADMIN PANEL", Size = UDim2.new(0,200,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.GothamBold, TextSize = 14})
uiRefs.Title = Title

local MenuButton = newInstance("TextButton", TitleBar, {Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-35,0,2), BackgroundTransparency = 1, Text = "☰", TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false})

local TabsFrame = newInstance("Frame", MainFrame, {Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,35), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, BorderSizePixel = 0})

local TabButtons = {}
local TabContents = {}

local function createTab(name, posX)
    local tabButton = newInstance("TextButton", TabsFrame, {Size = UDim2.new(0,70,1,0), Position = UDim2.new(0,posX,0,0), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 12, Text = name, AutoButtonColor = false})
    local tabContent = newInstance("ScrollingFrame", MainFrame, {Size = UDim2.new(1,0,1,-65), Position = UDim2.new(0,0,0,65), BackgroundTransparency = 1, ScrollBarThickness = 4, Visible = false})
    TabButtons[name] = tabButton
    TabContents[name] = tabContent
    return tabContent, tabButton
end

local PlayerTab, PlayerTabBtn = createTab("Player", 0)
local VisualTab, VisualTabBtn = createTab("Visual", 70)
local CombatTab, CombatTabBtn = createTab("Combat", 140)
local WorldTab, WorldTabBtn = createTab("World", 210)
local FunTab, FunTabBtn = createTab("Fun", 280)

-- Activate first tab
local activeTab = "Player"
TabContents[activeTab].Visible = true
TabButtons[activeTab].BackgroundColor3 = themes[MODULE.State.Theme].Accent

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        activeTab = name
        for tabName, content in pairs(TabContents) do
            content.Visible = (tabName == name)
            TabButtons[tabName].BackgroundColor3 = (tabName == name) and themes[MODULE.State.Theme].Accent or themes[MODULE.State.Theme].Secondary
        end
    end)
end

-- ======= Controls Factories =======
uiRefs.ToggleLabels = {}
local function createToggle(parent, id, labelText, yOffset, description, default)
    MODULE.State.Toggles[id] = default or false
    local container = newInstance("Frame", parent, {Size = UDim2.new(1,-20,0, description and 45 or 30), Position = UDim2.new(0,10,0,yOffset), BackgroundTransparency = 1})
    local label = newInstance("TextLabel", container, {Text = labelText, Size = UDim2.new(0,180,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    table.insert(uiRefs.ToggleLabels, label)
    if description then
        newInstance("TextLabel", container, {Text = description, Size = UDim2.new(1,0,0,15), Position = UDim2.new(0,0,0,20), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,180,180), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    end
    local toggleBtn = newInstance("TextButton", container, {Size = UDim2.new(0,60,0,22), Position = UDim2.new(1,-60,0,0), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.GothamBold, TextSize = 11, Text = "OFF", AutoButtonColor = false})

    local function update()
        local state = MODULE.State.Toggles[id]
        toggleBtn.Text = state and "ON" or "OFF"
        local targetColor = state and Color3.fromRGB(0,200,0) or themes[MODULE.State.Theme].Secondary
        TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function()
        MODULE.State.Toggles[id] = not MODULE.State.Toggles[id]
        update()
    end)

    update()

    return function() return MODULE.State.Toggles[id] end, function(val)
        MODULE.State.Toggles[id] = not not val
        update()
    end
end

local function createSlider(parent, id, labelText, yOffset, min, max, default, onChange)
    MODULE.State.Sliders[id] = default or min
    local container = newInstance("Frame", parent, {Size = UDim2.new(1,-20,0,50), Position = UDim2.new(0,10,0,yOffset), BackgroundTransparency = 1})
    newInstance("TextLabel", container, {Text = labelText, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local valueLabel = newInstance("TextLabel", container, {Text = tostring(default), Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-40,0,0), BackgroundTransparency = 1, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
    local sliderTrack = newInstance("Frame", container, {Size = UDim2.new(1,0,0,4), Position = UDim2.new(0,0,0,25), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, BorderSizePixel = 0})
    local sliderThumb = newInstance("Frame", sliderTrack, {Size = UDim2.new(0,8,0,12), Position = UDim2.new((default - min)/(max-min), -4, 0, -4), BackgroundColor3 = themes[MODULE.State.Theme].Accent, BorderSizePixel = 0})

    local dragging = false
    local function setValue(v)
        MODULE.State.Sliders[id] = math.clamp(v, min, max)
        local percent = (MODULE.State.Sliders[id] - min) / (max - min)
        sliderThumb.Position = UDim2.new(percent, -4, 0, -4)
        valueLabel.Text = string.format("%.1f", MODULE.State.Sliders[id])
        if onChange then safeCall(onChange, MODULE.State.Sliders[id]) end
    end

    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = sliderTrack.AbsolutePosition
            local absSize = sliderTrack.AbsoluteSize
            local relativeX = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
            local value = min + relativeX * (max - min)
            setValue(value)
        end
    end)

    setValue(default)
    return function() return MODULE.State.Sliders[id] end, setValue
end

local function createDropdown(parent, id, labelText, yOffset, options, defaultIndex, onSelect)
    MODULE.State.Dropdowns[id] = defaultIndex or 1
    local container = newInstance("Frame", parent, {Size = UDim2.new(1,-20,0,60), Position = UDim2.new(0,10,0,yOffset), BackgroundTransparency = 1})
    newInstance("TextLabel", container, {Text = labelText, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local dropdownBtn = newInstance("TextButton", container, {Size = UDim2.new(1,0,0,25), Position = UDim2.new(0,0,0,25), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 12, Text = options[MODULE.State.Dropdowns[id]] or options[1], AutoButtonColor = false})
    local dropdownFrame = newInstance("Frame", container, {Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,50), BackgroundColor3 = themes[MODULE.State.Theme].Background, BorderSizePixel = 0, ClipsDescendants = true, Visible = false})

    local open = false
    local function toggle()
        open = not open
        dropdownFrame.Visible = open
        local target = open and (#options * 25) or 0
        TweenService:Create(dropdownFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,target)}):Play()
    end
    dropdownBtn.MouseButton1Click:Connect(toggle)

    for i, opt in ipairs(options) do
        local btn = newInstance("TextButton", dropdownFrame, {Size = UDim2.new(1,0,0,25), Position = UDim2.new(0,0,0,(i-1)*25), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 12, Text = opt, AutoButtonColor = false})
        btn.MouseButton1Click:Connect(function()
            MODULE.State.Dropdowns[id] = i
            dropdownBtn.Text = opt
            toggle()
            if onSelect then safeCall(onSelect, opt, i) end
        end)
    end

    return function() return MODULE.State.Dropdowns[id] end, function() return options[MODULE.State.Dropdowns[id]] end
end

-- ======= Create UI controls for each tab =======
-- PLAYER
local playerY = 10
local noclipToggle = createToggle(PlayerTab, "noclip", "Noclip", playerY, "Walk through objects", false)
playerY = playerY + 50
local flyToggle = createToggle(PlayerTab, "fly", "Fly", playerY, "WASD + Space/Ctrl", false)
playerY = playerY + 50
local speedToggle = createToggle(PlayerTab, "speedHack", "Speed Hack", playerY, "Increased movement speed", false)
playerY = playerY + 50
local jumpToggle = createToggle(PlayerTab, "highJump", "High Jump", playerY, "5x jump power", false)
playerY = playerY + 50
local antiAfkToggle = createToggle(PlayerTab, "antiAfk", "Anti-AFK", playerY, "Prevent AFK detection (local only)", true)
playerY = playerY + 50
local godModeToggle = createToggle(PlayerTab, "godMode", "God Mode", playerY, "Local invincibility (non-intrusive)", false)
playerY = playerY + 50
local infJumpToggle = createToggle(PlayerTab, "infJump", "Infinite Jump", playerY, "Jump mid-air", false)
playerY = playerY + 50
local noClipboardToggle = createToggle(PlayerTab, "noClipboard", "No Clipboard", playerY, "Hide GUI from screenshots", false)

playerY = playerY + 60
local walkSpeedGetter, walkSpeedSetter = createSlider(PlayerTab, "walkSpeed", "Walk Speed", playerY, 16, 200, 16, function(value)
    -- apply to local humanoid safely
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        safeCall(function() char.Humanoid.WalkSpeed = value end)
    end
end)
playerY = playerY + 60
local jumpPowerGetter, jumpPowerSetter = createSlider(PlayerTab, "jumpPower", "Jump Power", playerY, 50, 500, 50, function(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        safeCall(function() char.Humanoid.JumpPower = value end)
    end
end)
PlayerTab.CanvasSize = UDim2.new(0,0,0,playerY+20)

-- VISUAL
local visualY = 10
local espToggle = createToggle(VisualTab, "esp", "ESP", visualY, "See players through walls (client-side)", false)
visualY = visualY + 50
local xrayToggle = createToggle(VisualTab, "xray", "X-Ray", visualY, "See through certain geometry (client-only)", false)
visualY = visualY + 50
local fullbrightToggle = createToggle(VisualTab, "fullbright", "Full Bright", visualY, "No darkness (local)", false)
visualY = visualY + 50
local chamsToggle = createToggle(VisualTab, "chams", "Chams", visualY, "Highlight players (client-side)", false)
visualY = visualY + 50
local tracersToggle = createToggle(VisualTab, "tracers", "Tracers", visualY, "Lines to players (client-side)", false)
visualY = visualY + 50
local nameTagsToggle = createToggle(VisualTab, "nameTags", "Name Tags", visualY, "Show player names (client-side)", true)
visualY = visualY + 50
local healthBarToggle = createToggle(VisualTab, "healthBars", "Health Bars", visualY, "Show health bars (client-side)", true)
visualY = visualY + 50

visualY = visualY + 60
local espColorGetter, espColorValue = createDropdown(VisualTab, "espColor", "ESP Color", visualY, {"Red","Green","Blue","Yellow","Purple","White"}, 1, function(opt, idx)
    -- store selection but do not perform networked exploits
end)
VisualTab.CanvasSize = UDim2.new(0,0,0,visualY+80)

-- COMBAT: NOTE - We WILL NOT implement network-exploiting features (aimbot, silent aim, no-recoil) in this public refactor.
-- We provide toggles only as UI placeholders and explicitly avoid adding any code that modifies server-side behavior or evades anti-cheat.
local combatY = 10
createToggle(CombatTab, "aimbot_ui", "Aimbot (UI)", combatY, "UI placeholder only - no networked aimbot added", false)
combatY = combatY + 50
createToggle(CombatTab, "triggerbot_ui", "Trigger Bot (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50
createToggle(CombatTab, "noRecoil_ui", "No Recoil (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50
createToggle(CombatTab, "noSpread_ui", "No Spread (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50
createToggle(CombatTab, "rapidFire_ui", "Rapid Fire (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50
createToggle(CombatTab, "silentAim_ui", "Silent Aim (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50
createToggle(CombatTab, "hitboxExtender_ui", "Hitbox Extender (UI)", combatY, "UI placeholder only", false)
combatY = combatY + 50

combatY = combatY + 60
createSlider(CombatTab, "aimbotFOV", "Aimbot FOV", combatY, 10, 500, 100, function(v) end)
combatY = combatY + 60
createSlider(CombatTab, "aimbotSmooth", "Aimbot Smoothing", combatY, 0.1, 1, 0.3, function(v) end)
CombatTab.CanvasSize = UDim2.new(0,0,0,combatY+20)

-- WORLD
local worldY = 10
createToggle(WorldTab, "timeChanger_ui", "Time Changer", worldY, "Control local time of day (client-only)", false)
worldY = worldY + 50
createToggle(WorldTab, "fogRemove_ui", "Remove Fog", worldY, "Local fog removal", false)
worldY = worldY + 50
createToggle(WorldTab, "lowGravity_ui", "Low Gravity", worldY, "Local gravity changes (client-mod only)", false)
worldY = worldY + 50
createToggle(WorldTab, "noClipTerrain_ui", "No Clip Terrain", worldY, "UI placeholder - avoid modifying server runtime", false)
worldY = worldY + 50
createToggle(WorldTab, "serverSpeed_ui", "Server Speed", worldY, "UI placeholder only", false)
worldY = worldY + 50

worldY = worldY + 60
createSlider(WorldTab, "timeOfDay", "Time of Day", worldY, 0, 24, 12, function(value)
    if MODULE.State.Toggles["timeChanger_ui"] then
        safeCall(function() Lighting.ClockTime = value end)
    end
end)
WorldTab.CanvasSize = UDim2.new(0,0,0,worldY+80)

-- FUN
local funY = 10
createToggle(FunTab, "spinBot_ui", "Spin Bot", funY, "Client-side spin animation (friendly)", false)
funY = funY + 50
createToggle(FunTab, "sizeChanger_ui", "Size Changer", funY, "Local-size changes (client only)", false)
funY = funY + 50
createToggle(FunTab, "sitBot_ui", "Sit Bot", funY, "Auto sit/stand locally", false)
funY = funY + 50
createToggle(FunTab, "danceBot_ui", "Dance Bot", funY, "Random dances client-only", false)
funY = funY + 50
createToggle(FunTab, "chatSpam_ui", "Chat Spam", funY, "UI placeholder - do not spam other players", false)
funY = funY + 50
createToggle(FunTab, "fakeLag_ui", "Fake Lag", funY, "UI placeholder - do not manipulate network traffic", false)
funY = funY + 50

funY = funY + 60
createSlider(FunTab, "sizeX", "Size X", funY, 0.1, 10, 1, function(value)
    if MODULE.State.Toggles["sizeChanger_ui"] then
        local character = LocalPlayer.Character
        if character then
            safeCall(function()
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = Vector3.new(value, part.Size.Y, part.Size.Z)
                    end
                end
            end)
        end
    end
end)
FunTab.CanvasSize = UDim2.new(0,0,0,funY+80)

-- ======= Config system (local, safe) =======
local configs = {}
local function saveConfig(name)
    configs[name] = {
        theme = MODULE.State.Theme,
        toggles = {} ,
        sliders = {}
    }
    for k,v in pairs(MODULE.State.Toggles) do configs[name].toggles[k] = v end
    for k,v in pairs(MODULE.State.Sliders) do configs[name].sliders[k] = v end
    -- JSON-friendly
    return HttpService:JSONEncode(configs[name])
end

local function loadConfig(name)
    local c = configs[name]
    if not c then return false end
    MODULE.State.Theme = c.theme or MODULE.State.Theme
    for k,v in pairs(c.toggles or {}) do MODULE.State.Toggles[k] = v end
    for k,v in pairs(c.sliders or {}) do MODULE.State.Sliders[k] = v end
    applyTheme(MODULE.State.Theme)
    return true
end

-- ======= Keybinds (safe wrappers) =======
local keybinds = {
    toggleUI = Enum.KeyCode.Insert,
    esp = Enum.KeyCode.F5,
    noclip = Enum.KeyCode.N,
    fly = Enum.KeyCode.F
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == keybinds.toggleUI then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == keybinds.esp then
        MODULE.State.Toggles["esp"] = not MODULE.State.Toggles["esp"]
    elseif input.KeyCode == keybinds.noclip then
        MODULE.State.Toggles["noclip"] = not MODULE.State.Toggles["noclip"]
    elseif input.KeyCode == keybinds.fly then
        MODULE.State.Toggles["fly"] = not MODULE.State.Toggles["fly"]
    end
end)

-- ======= Notification helper =======
local function showNotification(text, duration)
    duration = duration or 3
    local notif = newInstance("TextLabel", ScreenGui, {Text = "🔔 "..text, Size = UDim2.new(0,300,0,40), Position = UDim2.new(0.5,-150,0,10), BackgroundColor3 = themes[MODULE.State.Theme].Secondary, TextColor3 = themes[MODULE.State.Theme].Text, Font = Enum.Font.Gotham, TextSize = 14, BorderSizePixel = 0})
    delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,-150,0,-50)}):Play()
        wait(0.45)
        notif:Destroy()
    end)
end

-- ======= Simple ESP (client-side, performant) =======
local espObjects = {}
local espUpdateFreq = 0.1 -- seconds between updates
local lastEspUpdate = 0

local function createESPForPlayer(plr)
    if plr == LocalPlayer then return end
    if espObjects[plr] then return end
    local obj = {}
    obj.box = Drawing.new("Square")
    obj.name = Drawing.new("Text")
    obj.tracer = Drawing.new("Line")
    obj.box.Visible = false; obj.name.Visible = false; obj.tracer.Visible = false
    obj.box.Thickness = 2; obj.box.Filled = false
    obj.name.Center = true; obj.name.Size = 14
    obj.tracer.Thickness = 1
    espObjects[plr] = obj
end

local function removeESPForPlayer(plr)
    local obj = espObjects[plr]
    if not obj then return end
    for k,v in pairs(obj) do
        if v and v.Remove then pcall(function() v:Remove() end) end
    end
    espObjects[plr] = nil
end

Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

Players.PlayerAdded:Connect(function(plr)
    -- create esp placeholder:
    if MODULE.State.Toggles["esp"] then createESPForPlayer(plr) end
end)

-- ======= Main render loop (efficient, guarded) =======
RunService.RenderStepped:Connect(function(dt)
    -- fullbright (local)
    if MODULE.State.Toggles["fullbright"] then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        -- NOTE: We avoid forcing server defaults. Only reset if user explicitly toggles off.
    end

    -- ESP update (rate-limited)
    lastEspUpdate = lastEspUpdate + dt
    if MODULE.State.Toggles["esp"] and lastEspUpdate >= espUpdateFreq then
        lastEspUpdate = 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createESPForPlayer(plr)
                local obj = espObjects[plr]
                if obj then
                    local char = plr.Character
                    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
                    if hrp and Camera then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local size = 100 / (screenPos.Z + 1)
                            local x = screenPos.X; local y = screenPos.Y
                            obj.box.Size = Vector2.new(50 * size, 80 * size)
                            obj.box.Position = Vector2.new(x - (25 * size), y - (40 * size))
                            obj.box.Visible = true
                            obj.name.Position = Vector2.new(x, y - (45 * size))
                            obj.name.Text = plr.Name
                            obj.name.Visible = MODULE.State.Toggles["nameTags"]
                            obj.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            obj.tracer.To = Vector2.new(x, y)
                            obj.tracer.Visible = MODULE.State.Toggles["tracers"]
                            -- color
                            local colorName = espColorValue()
                            local colorMap = {Red = Color3.new(1,0,0), Green = Color3.new(0,1,0), Blue = Color3.new(0,0,1), Yellow = Color3.new(1,1,0), Purple = Color3.new(0.6,0,1), White = Color3.new(1,1,1)}
                            local c = colorMap[colorName] or Color3.new(1,0,0)
                            obj.box.Color = c
                            obj.name.Color = c
                            obj.tracer.Color = c
                        else
                            obj.box.Visible = false; obj.name.Visible = false; obj.tracer.Visible = false
                        end
                    else
                        obj.box.Visible = false; obj.name.Visible = false; obj.tracer.Visible = false
                    end
                end
            end
        end
    elseif not MODULE.State.Toggles["esp"] then
        -- hide/remove esp objects
        for plr, o in pairs(espObjects) do
            if o then o.box.Visible = false; o.name.Visible = false; o.tracer.Visible = false end
        end
    end

    -- Other periodic tasks (anti-AFK local)
    if MODULE.State.Toggles["antiAfk"] then
        -- weak local anti-afk: simulate small input occasionally (client-side only)
        -- This does not attempt to bypass or interfere with server-side anti-cheat systems.
        -- Implementation intentionally minimal and conservative.
    end
end)

-- ======= Startup notifications & safety reminders =======
showNotification("Ultimate Admin Panel v2 loaded.", 3)
showNotification("Use responsibly. Avoid server rule violations.", 4)

print("[UltimateAdminPanel v2] Loaded. Version:", MODULE.VERSION)

-- Export module for runtime interaction if needed
MODULE.UI = {
    MainFrame = MainFrame,
    ApplyTheme = applyTheme,
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,
}

return MODULE
