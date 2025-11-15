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
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Config mặc định tắt tất cả
local ESPEnabled, ESPTeamCheck, ESPWallCheck, ESPDistance = false, false, false, 200
local AimEnabled, AimTeamCheck, AimWallCheck, AimDistance, SmoothStrength = false, false, false, 200, 0.25
local FlyEnabled, NoclipEnabled, RadarEnabled, AntiFlingEnabled = false, false, false, false, false

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
ESPTab:Toggle({Title = "Enable ESP", Desc = "Hiển thị người chơi", Default = ESPEnabled, Callback = function(state) ESPEnabled = state end})
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
MoveTab:Toggle({Title = "Fly", Desc = "Bay tự do WSAD + Space + Ctrl", Default = FlyEnabled, Callback = function(state) FlyEnabled = state end})
MoveTab:Toggle({Title = "Noclip", Desc = "Đi xuyên tường", Default = NoclipEnabled, Callback = function(state) NoclipEnabled = state end})
MoveTab:Toggle({Title = "Anti Fling", Desc = "Chống văng nhân vật bởi lực ngoài", Default = AntiFlingEnabled, Callback = function(state) AntiFlingEnabled = state end})

-- Radar Tab
local RadarTab = Window:Tab({Title = "Radar", Icon = "map"})
RadarTab:Toggle({Title = "Enable Radar", Desc = "Bật/tắt radar minimap", Default = RadarEnabled, Callback = function(state) RadarEnabled = state end})

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
SettingsTab:Button({Title = "Save Config", Desc = "Lưu lại cấu hình hiện tại", Callback = saveConfig})
SettingsTab:Button({Title = "Load Config", Desc = "Tải cấu hình đã lưu", Callback = loadConfig})
