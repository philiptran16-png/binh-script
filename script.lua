-- Final Fixed Aimbot Script - Đã sửa mọi lỗi (bản hoàn chỉnh)
local success, err = pcall(function()
    -- Kiểm tra môi trường
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    
    if not LocalPlayer then
        repeat wait() until Players.LocalPlayer
        LocalPlayer = Players.LocalPlayer
    end
    
    local Camera = workspace.CurrentCamera
    
    -- Mouse initialization an toàn
    local Mouse
    pcall(function()
        Mouse = LocalPlayer:GetMouse()
    end)
    if not Mouse then
        Mouse = {Hit = CFrame.new()}
    end

    -- Load WindUI
    local WindUI
    local WindUISuccess, WindUIError = pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua", true))()
    end)
    
    if not WindUISuccess or not WindUI then
        error("Không thể tải WindUI: " .. tostring(WindUIError))
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
        Prediction = 0.14,
        AimbotType = "PC"
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

    -- Biến toàn cục
    local CurrentTarget = nil
    local FOVCircle = nil
    local IsAiming = false
    local ESPObjects = {}
    local Connections = {}
    
    -- DrawingSupported check an toàn
    local DrawingSupported = false
    do
        local ok, obj = pcall(function() return Drawing.new("Square") end)
        if ok and obj then
            pcall(function() obj:Remove() end)
            DrawingSupported = true
        else
            DrawingSupported = false
        end
    end

    -- Tạo GUI với WindUI
    local Window = WindUI:CreateWindow({
        Title = "Aimbot GUI - Ultimate Fixed",
        Center = true,
        Size = UDim2.new(0, 450, 0, 500)
    })

    -- Tạo các tab
    local MainTab = Window:CreateTab("Aimbot")
    local ESPTab = Window:CreateTab("ESP")
    local SettingsTab = Window:CreateTab("Settings")

    -- =============================================
    -- AIMBOT TAB
    -- =============================================
    local AimbotSection = MainTab:CreateSection("Cấu Hình Aimbot")

    local EnabledToggle = AimbotSection:CreateToggle("Bật Aimbot", AimbotConfig.Enabled, function(Value)
        AimbotConfig.Enabled = Value
        if FOVCircle then
            FOVCircle.Visible = Value
        end
    end)

    local AimbotTypeDropdown = AimbotSection:CreateDropdown("Loại Aimbot", {"PC", "PE"}, function(Value)
        AimbotConfig.AimbotType = Value
    end)

    local AimPartDropdown = AimbotSection:CreateDropdown("Vị Trí Aim", {"Head", "Torso", "HumanoidRootPart"}, function(Value)
        AimbotConfig.AimPart = Value
    end)

    local FOVSlider = AimbotSection:CreateSlider("FOV", 10, 200, AimbotConfig.FOV, function(Value)
        AimbotConfig.FOV = Value
        if FOVCircle then
            FOVCircle.Radius = math.clamp(Value, 1, 2000)
        end
    end)

    local SmoothSlider = AimbotSection:CreateSlider("Độ Mượt", 1, 10, AimbotConfig.Smoothness, function(Value)
        AimbotConfig.Smoothness = math.max(1, Value)
    end)

    local TeamCheckToggle = AimbotSection:CreateToggle("Kiểm Tra Team", AimbotConfig.TeamCheck, function(Value)
        AimbotConfig.TeamCheck = Value
    end)

    local SilentAimToggle = AimbotSection:CreateToggle("Silent Aim", AimbotConfig.SilentAim, function(Value)
        AimbotConfig.SilentAim = Value
    end)

    -- Section Keybind
    local KeybindSection = MainTab:CreateSection("Cài Đặt Keybind")

    local UseKeybindToggle = KeybindSection:CreateToggle("Dùng Keybind", AimbotConfig.UseKeybind, function(Value)
        AimbotConfig.UseKeybind = Value
    end)

    local KeybindOptions = {"Q", "E", "R", "F", "X", "C", "V", "LeftShift", "RightShift", "LeftControl", "RightControl"}
    local KeybindDropdown = KeybindSection:CreateDropdown("Keybind", KeybindOptions, function(Value)
        local ok, code = pcall(function() return Enum.KeyCode[Value] end)
        if ok and code then
            AimbotConfig.Keybind = code
        end
    end)

    local UseMouseToggle = KeybindSection:CreateToggle("Dùng Chuột", AimbotConfig.UseMouse, function(Value)
        AimbotConfig.UseMouse = Value
    end)

    local MouseDropdown = KeybindSection:CreateDropdown("Nút Chuột", {"LeftButton", "RightButton", "MiddleButton"}, function(Value)
        AimbotConfig.MouseButton = Value
    end)

    local HoldToAimToggle = KeybindSection:CreateToggle("Giữ Để Aim", AimbotConfig.HoldToAim, function(Value)
        AimbotConfig.HoldToAim = Value
    end)

    -- =============================================
    -- ESP TAB
    -- =============================================
    local ESPMainSection = ESPTab:CreateSection("Cài Đặt ESP")

    local ESPEnabledToggle = ESPMainSection:CreateToggle("Bật ESP", ESPConfig.Enabled, function(Value)
        ESPConfig.Enabled = Value and DrawingSupported
        if Value and DrawingSupported then
            InitializeESP()
        else
            ClearESP()
        end
        if not DrawingSupported then
            warn("Drawing API không được hỗ trợ trên executor này!")
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
    -- SETTINGS TAB
    -- =============================================
    local VisualsSection = SettingsTab:CreateSection("Cài Đặt Hiển Thị")

    local ShowFOVToggle = VisualsSection:CreateToggle("Hiển Thị FOV Circle", false, function(Value)
        if FOVCircle then
            FOVCircle.Visible = Value and AimbotConfig.Enabled
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
    -- CORE FUNCTIONS - ĐÃ SỬA HOÀN CHỈNH
    -- =============================================

    function FindClosestPlayer()
        if not LocalPlayer or not LocalPlayer.Character then return nil end
        
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    if AimbotConfig.TeamCheck then
                        local playerTeam = player and player.Team
                        local localTeam = LocalPlayer and LocalPlayer.Team
                        if playerTeam and localTeam and playerTeam == localTeam then
                            goto continue_player_loop
                        end
                    end
                    
                    local aimPart = character:FindFirstChild(AimbotConfig.AimPart)
                    if aimPart then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                        
                        if onScreen then
                            local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                            
                            if distance <= AimbotConfig.FOV and distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            ::continue_player_loop::
        end
        
        return closestPlayer
    end

    function AimAtTarget(target)
        if not target or not target.Character then return end
        
        local aimPart = target.Character:FindFirstChild(AimbotConfig.AimPart)
        if not aimPart then return end
        
        local camera = workspace.CurrentCamera
        local targetPosition = aimPart.Position
        
        if AimbotConfig.Prediction and AimbotConfig.Prediction > 0 then
            local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                targetPosition = targetPosition + (humanoidRootPart.Velocity * AimbotConfig.Prediction)
            end
        end
        
        local currentCameraPos = camera.CFrame.Position
        
        if (targetPosition - currentCameraPos).Magnitude < 0.1 then
            return
        end
        
        local direction = (targetPosition - currentCameraPos).Unit
        local smoothFactor = math.max(1, AimbotConfig.Smoothness)
        local newCFrame = CFrame.new(currentCameraPos, currentCameraPos + direction)
        
        local mousePos = UserInputService:GetMouseLocation()
        
        if AimbotConfig.SilentAim then
            local ok, _ = pcall(function()
                if Mouse and typeof(Mouse.Hit) == "CFrame" then
                    Mouse.Hit = CFrame.new(targetPosition)
                end
            end)
            if not ok then
                -- Fallback sang normal aim
                if AimbotConfig.AimbotType == "PC" then
                    camera.CFrame = camera.CFrame:Lerp(newCFrame, 1 / smoothFactor)
                else
                    local screenPoint, onScreen = camera:WorldToViewportPoint(targetPosition)
                    if onScreen then
                        pcall(function()
                            if type(mousemoverel) == "function" then
                                mousemoverel(
                                    (screenPoint.X - mousePos.X) / smoothFactor,
                                    (screenPoint.Y - mousePos.Y) / smoothFactor
                                )
                            end
                        end)
                    end
                end
            end
        else
            if AimbotConfig.AimbotType == "PC" then
                camera.CFrame = camera.CFrame:Lerp(newCFrame, 1 / smoothFactor)
            else
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPosition)
                if onScreen then
                    pcall(function()
                        if type(mousemoverel) == "function" then
                            mousemoverel(
                                (screenPoint.X - mousePos.X) / smoothFactor,
                                (screenPoint.Y - mousePos.Y) / smoothFactor
                            )
                        end
                    end)
                end
            end
        end
    end

    function ShouldAim()
        if not AimbotConfig.Enabled then return false end
        
        if not AimbotConfig.UseKeybind and not AimbotConfig.UseMouse then
            return true
        end
        
        return IsAiming
    end

    -- =============================================
    -- ESP SYSTEM
    -- =============================================
    function CreateESP(player)
        if not DrawingSupported then return {loaded = false} end
        
        local esp = {
            player = player,
            box = nil,
            name = nil,
            loaded = false,
            characterConnections = {}
        }
        
        pcall(function()
            esp.box = Drawing.new("Square")
            esp.box.Visible = false
            esp.box.Color = ESPConfig.BoxColor
            esp.box.Thickness = 2
            esp.box.Filled = false
            
            esp.name = Drawing.new("Text")
            esp.name.Visible = false
            esp.name.Color = ESPConfig.TextColor
            esp.name.Size = 13
            esp.name.Center = true
            esp.name.Outline = true
            esp.name.Text = player.Name
            
            esp.loaded = true
        end)
        
        return esp
    end

    function UpdateESP(esp)
        if not esp.loaded or not esp.box or not esp.name then return end
        if not esp.player or not esp.player.Character then
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
        
        local distance = 9999
        if LocalPlayer.Character then
            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localRoot and humanoidRootPart then
                distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
            end
        end
        
        if distance > ESPConfig.MaxDistance then
            esp.box.Visible = false
            esp.name.Visible = false
            return
        end
        
        if ESPConfig.TeamCheck and esp.player.Team and LocalPlayer.Team and esp.player.Team == LocalPlayer.Team then
            esp.box.Visible = false
            esp.name.Visible = false
            return
        end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            local scaleFactor = math.max(0.1, 1000 / (screenPoint.Z > 0 and screenPoint.Z or 0.1))
            local width = 100 / scaleFactor
            local height = 150 / scaleFactor
            
            if ESPConfig.ShowBoxes then
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(screenPoint.X - width/2, screenPoint.Y - height/2)
                esp.box.Visible = true
                
                if ESPConfig.TeamColor and esp.player.Team then
                    esp.box.Color = esp.player.Team.TeamColor.Color
                else
                    esp.box.Color = ESPConfig.BoxColor
                end
            else
                esp.box.Visible = false
            end
            
            if ESPConfig.ShowNames then
                local displayText = esp.player.Name
                if ESPConfig.ShowDistance then
                    displayText = displayText .. string.format(" [%dm]", math.floor(distance))
                end
                if ESPConfig.ShowHealth and humanoid then
                    displayText = displayText .. string.format(" (%dHP)", math.floor(humanoid.Health))
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
                SetupPlayerESP(player)
            end
        end
        
        Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if player == LocalPlayer then return end
            SetupPlayerESP(player)
        end)
        
        Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
            if ESPObjects[player] then
                if ESPObjects[player].characterConnections then
                    for _, conn in pairs(ESPObjects[player].characterConnections) do
                        pcall(function() conn:Disconnect() end)
                    end
                end
                if ESPObjects[player].box then
                    pcall(function() ESPObjects[player].box:Remove() end)
                end
                if ESPObjects[player].name then
                    pcall(function() ESPObjects[player].name:Remove() end)
                end
                ESPObjects[player] = nil
            end
        end)
    end

    function SetupPlayerESP(player)
        ESPObjects[player] = CreateESP(player)
        
        if ESPObjects[player] then
            local charAddedConn = player.CharacterAdded:Connect(function()
                if ESPObjects[player] then
                    pcall(function()
                        if ESPObjects[player].box then ESPObjects[player].box.Visible = false end
                        if ESPObjects[player].name then ESPObjects[player].name.Visible = false end
                    end)
                end
            end)
            
            local charRemovingConn = player.CharacterRemoving:Connect(function()
                if ESPObjects[player] then
                    pcall(function()
                        if ESPObjects[player].box then ESPObjects[player].box.Visible = false end
                        if ESPObjects[player].name then ESPObjects[player].name.Visible = false end
                    end)
                end
            end)
            
            ESPObjects[player].characterConnections = {
                charAddedConn,
                charRemovingConn
            }
        end
    end

    function ClearESP()
        local players = {}
        for player in pairs(ESPObjects) do
            table.insert(players, player)
        end
        
        for _, player in ipairs(players) do
            local esp = ESPObjects[player]
            if esp then
                if esp.characterConnections then
                    for _, conn in pairs(esp.characterConnections) do
                        pcall(function() conn:Disconnect() end)
                    end
                end
                if esp.box then
                    pcall(function() esp.box:Remove() end)
                end
                if esp.name then
                    pcall(function() esp.name:Remove() end)
                end
            end
            ESPObjects[player] = nil
        end
    end

    -- =============================================
    -- INPUT HANDLING
    -- =============================================
    function SetupInputHandling()
        local function getMouseInputType()
            if AimbotConfig.MouseButton == "LeftButton" then
                return Enum.UserInputType.MouseButton1
            elseif AimbotConfig.MouseButton == "RightButton" then
                return Enum.UserInputType.MouseButton2
            elseif AimbotConfig.MouseButton == "MiddleButton" then
                return Enum.UserInputType.MouseButton3
            end
            return Enum.UserInputType.MouseButton2
        end

        Connections.KeybindBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind then
                if AimbotConfig.HoldToAim then
                    IsAiming = true
                else
                    IsAiming = not IsAiming
                end
            end
            
            if AimbotConfig.UseMouse and input.UserInputType == getMouseInputType() then
                if AimbotConfig.HoldToAim then
                    IsAiming = true
                else
                    IsAiming = not IsAiming
                end
            end
        end)
        
        Connections.KeybindEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if AimbotConfig.UseKeybind and input.KeyCode == AimbotConfig.Keybind and AimbotConfig.HoldToAim then
                IsAiming = false
            end
            
            if AimbotConfig.UseMouse and input.UserInputType == getMouseInputType() and AimbotConfig.HoldToAim then
                IsAiming = false
            end
        end)
    end

    -- =============================================
    -- FOV CIRCLE
    -- =============================================
    function CreateFOVCircle()
        if FOVCircle or not DrawingSupported then return end
        
        pcall(function()
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Visible = AimbotConfig.Enabled
            FOVCircle.Radius = math.clamp(AimbotConfig.FOV, 1, 2000)
            FOVCircle.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
        end)
    end

    -- =============================================
    -- CLEANUP SYSTEM
    -- =============================================
    function CleanupConnections()
        local keys = {}
        for name in pairs(Connections) do
            table.insert(keys, name)
        end
        
        for _, name in ipairs(keys) do
            local connection = Connections[name]
            if connection then
                pcall(function() connection:Disconnect() end)
            end
            Connections[name] = nil
        end
        
        for player, esp in pairs(ESPObjects) do
            if esp and esp.characterConnections then
                for _, conn in pairs(esp.characterConnections) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end
        
        if FOVCircle then
            pcall(function() FOVCircle:Remove() end)
            FOVCircle = nil
        end
        
        ClearESP()
        
        if Window and Window.Destroy then
            pcall(function() Window:Destroy() end)
        end
    end

    function SetupSafeCleanup()
        Connections.AncestryChanged = LocalPlayer.AncestryChanged:Connect(function(_, parent)
            if not parent then 
                CleanupConnections()
            end
        end)
        
        if game.BindToClose then
            pcall(function()
                game:BindToClose(function()
                    CleanupConnections()
                end)
            end)
        end
    end

    -- =============================================
    -- RESET FUNCTION
    -- =============================================
    function ResetAllSettings()
        -- Reset Aimbot Config
        AimbotConfig.Enabled = false
        AimbotConfig.TeamCheck = true
        AimbotConfig.Smoothness = 2
        AimbotConfig.FOV = 80
        AimbotConfig.AimPart = "Head"
        AimbotConfig.UseKeybind = false
        AimbotConfig.UseMouse = false
        AimbotConfig.HoldToAim = true
        AimbotConfig.SilentAim = false
        AimbotConfig.AimbotType = "PC"
        
        -- Reset ESP Config
        ESPConfig.Enabled = false
        ESPConfig.ShowBoxes = true
        ESPConfig.ShowNames = true
        ESPConfig.ShowDistance = true
        ESPConfig.ShowHealth = true
        ESPConfig.TeamCheck = true
        ESPConfig.MaxDistance = 500
        
        -- Update UI
        pcall(function()
            EnabledToggle:SetValue(false)
            TeamCheckToggle:SetValue(true)
            SmoothSlider:SetValue(2)
            FOVSlider:SetValue(80)
            AimPartDropdown:SetOption("Head")
            UseKeybindToggle:SetValue(false)
            UseMouseToggle:SetValue(false)
            HoldToAimToggle:SetValue(true)
            SilentAimToggle:SetValue(false)
            AimbotTypeDropdown:SetOption("PC")
            
            ESPEnabledToggle:SetValue(false)
            ShowBoxesToggle:SetValue(true)
            ShowNamesToggle:SetValue(true)
            ShowDistanceToggle:SetValue(true)
            ShowHealthToggle:SetValue(true)
            ESPTeamCheckToggle:SetValue(true)
            ESPMaxDistanceSlider:SetValue(500)
            
            ShowFOVToggle:SetValue(false)
        end)
        
        -- Apply changes
        if FOVCircle then
            FOVCircle.Visible = false
            FOVCircle.Radius = 80
        end
        
        ClearESP()
        IsAiming = false
        CurrentTarget = nil
    end

    -- =============================================
    -- INITIALIZATION
    -- =============================================
    function Initialize()
        CreateFOVCircle()
        SetupInputHandling()
        SetupSafeCleanup()
        
        Connections.RenderStepped = RunService.RenderStepped:Connect(function()
            -- Update FOV Circle
            if FOVCircle then
                local mousePos = UserInputService:GetMouseLocation()
                FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                FOVCircle.Radius = math.clamp(AimbotConfig.FOV, 1, 2000)
                FOVCircle.Visible = AimbotConfig.Enabled and ShowFOVToggle:GetValue()
            end
            
            -- ESP Update
            if ESPConfig.Enabled and DrawingSupported then
                local hasValidPlayers = false
                for _, esp in pairs(ESPObjects) do
                    if esp.loaded and esp.player and esp.player.Character then
                        hasValidPlayers = true
                        pcall(UpdateESP, esp)
                    end
                end
                if not hasValidPlayers then
                    for _, esp in pairs(ESPObjects) do
                        if esp.box then esp.box.Visible = false end
                        if esp.name then esp.name.Visible = false end
                    end
                end
            end
            
            -- Aimbot Logic
            if ShouldAim() then
                CurrentTarget = FindClosestPlayer()
                if CurrentTarget then
                    pcall(AimAtTarget, CurrentTarget)
                end
            else
                CurrentTarget = nil
            end
        end)
        
        Connections.GUIToggle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.F6 then
                pcall(function() Window:Toggle() end)
            end
            
            if input.KeyCode == Enum.KeyCode.F7 then
                AimbotConfig.Enabled = not AimbotConfig.Enabled
                if FOVCircle then
                    FOVCircle.Visible = AimbotConfig.Enabled and ShowFOVToggle:GetValue()
                end
                pcall(function() EnabledToggle:SetValue(AimbotConfig.Enabled) end)
            end
        end)

        print("🎯 Aimbot GUI Ultimate Fixed - Hoàn thiện!")
        print("📋 F6 - Toggle GUI | F7 - Quick Toggle Aimbot")
        print("⚡ Đã sửa tất cả lỗi và tối ưu hiệu năng")
        if not DrawingSupported then
            print("⚠️ Drawing API không khả dụng - ESP sẽ không hoạt động")
        end
    end

    Initialize()
end)

if not success then
    warn("❌ Lỗi khi chạy script: " .. tostring(err))
    warn(debug.traceback(err))
end
