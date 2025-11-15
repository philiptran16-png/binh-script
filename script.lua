-- Tạo một bảng để quản lý các thông số liên quan đến line
local LineSettings = {
    Color = Color3.new(1, 0, 0),
    Thickness = 2,
    Visible = true,
}

-- Tạo một hàm để cập nhật vị trí và màu sắc của line
local function updateLine()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách line
    local linePosition = Camera.CFrame.Position + lookVector * distance
    local lineDirection = lookVector
    local lineColor = LineSettings.Color
    local lineThickness = LineSettings.Thickness
    local lineVisible = LineSettings.Visible

    if lineVisible then
        local line = Drawing.new("Line")
            .Color = lineColor
            .Thickness = lineThickness
            .From = Camera.CFrame.Position
            .To = linePosition
            .Visible = true
        return line
    end
end

-- Tạo một hàm để cập nhật FOV quanh chuột
local function updateFOV()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateTarget()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateTargetPath()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị đường đi của mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    local path = Drawing.new("Line")
                        .Color = Color3.new(1, 0, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật FOV quanh chuột
local function updateFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line:Remove()
                    end
                    line = Drawing.new("Line")
                        .Color = Color3.new(0, 1, 0)
                        .Thickness = 2
                        .From = Camera.CFrame.Position
                        .To = target.Position
                        .Visible = true
                    end
                end
            end
        end
    end
end

-- Tạo một hàm để cập nhật đường đi của mục tiêu
local function updateAimFOVCircle()
    local lookVector = Camera.CFrame.LookVector
    local distance = 100 -- khoảng cách FOV
    local fov = math.acos(1 - (distance / math.huge))
    Camera.FieldOfView = fov
end

-- Tạo một hàm để cập nhật mục tiêu dựa trên khoảng cách
local function updateEsp()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local target = humanoid.Parent
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < 100 then
                    -- Hiển thị mục tiêu
                    local line = updateLine()
                    if line then
                        line

