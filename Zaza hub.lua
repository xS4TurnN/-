-- Zaza Hub | Area 51 (v2.1 - Исправленная)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZazaHub_Area51"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 450)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Zaza Hub | Area 51"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 410)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Свернуть"
ToggleBtn.Parent = MainFrame

-- ============================
-- НАСТРОЙКИ
-- ============================
local Settings = {
    Aimbot = false,
    EspMonsters = false,
    EspPlayers = false,
    Speed = false,
    SpeedValue = 16,
    EspWeapons = false
}

local function CreateToggle(name, yPos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 320, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = name .. ": ВЫКЛ"
    Btn.Parent = MainFrame

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = name .. (active and ": ВКЛ" or ": ВЫКЛ")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(20, 20, 20)
        callback(active)
    end)
end

CreateToggle("Aimbot (90x90)", 50, function(v) Settings.Aimbot = v end)
CreateToggle("ESP Монстры", 90, function(v) Settings.EspMonsters = v end)
CreateToggle("ESP Игроки", 130, function(v) Settings.EspPlayers = v end)
CreateToggle("ESP Оружие", 250, function(v) Settings.EspWeapons = v end)

-- Слайдер скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 320, 0, 25)
SpeedLabel.Position = UDim2.new(0, 10, 0, 175)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Text = "Скорость: 16"
SpeedLabel.Parent = MainFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(0, 320, 0, 30)
SpeedSlider.Position = UDim2.new(0, 10, 0, 205)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.Text = "Изменить скорость"
SpeedSlider.Parent = MainFrame

local speedSteps = {16, 30, 50, 70, 100}
local currentStep = 1
SpeedSlider.MouseButton1Click:Connect(function()
    currentStep = currentStep + 1
    if currentStep > #speedSteps then currentStep = 1 end
    Settings.SpeedValue = speedSteps[currentStep]
    SpeedLabel.Text = "Скорость: " .. Settings.SpeedValue
    SpeedSlider.Text = "Скорость: " .. Settings.SpeedValue
end)

-- ============================
-- ЛОГИКА (РАБОТАЮЩАЯ)
-- ============================

-- Аимбот
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, 90, 0, 90)
FOVCircle.Position = UDim2.new(0.5, -45, 0.5, -45)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 2
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.Parent = ScreenGui

game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Aimbot then
        local Camera = workspace.CurrentCamera
        local Target = nil
        -- Ищем монстров в workspace (у них есть Humanoid)
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local HRP = obj.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                if OnScreen and math.abs(ScreenPos.X - FOVCircle.AbsolutePosition.X - 45) < 45 and math.abs(ScreenPos.Y - FOVCircle.AbsolutePosition.Y - 45) < 45 then
                    Target = HRP
                    break
                end
            end
        end
        if Target then
            local PHRP = game.Players.LocalPlayer.Character.HumanoidRootPart
            PHRP.CFrame = CFrame.lookAt(PHRP.Position, Target.Position)
        end
    end
end)

-- ESP
local ESPFolder = Instance.new("Folder", ScreenGui)

game:GetService("RunService").RenderStepped:Connect(function()
    -- Очищаем старые
    ESPFolder:ClearAllChildren()

    if Settings.EspMonsters or Settings.EspPlayers or Settings.EspWeapons then
        local Camera = workspace.CurrentCamera
        for _, obj in pairs(workspace:GetChildren()) do
            local isMonster = obj:FindFirstChildOfClass("Humanoid") and not game.Players:GetPlayerFromCharacter(obj)
            local isPlayer = game.Players:GetPlayerFromCharacter(obj)

            -- ESP для монстров и игроков
            if (Settings.EspMonsters and isMonster) or (Settings.EspPlayers and isPlayer) then
                local HRP = obj:FindFirstChild("HumanoidRootPart")
                if HRP then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                    if OnScreen then
                        -- Бокс
                        local Box = Instance.new("Frame", ESPFolder)
                        Box.Size = UDim2.new(0, 50, 0, 70)
                        Box.Position = UDim2.new(0, ScreenPos.X - 25, 0, ScreenPos.Y - 50)
                        Box.BackgroundTransparency = 1
                        Box.BorderSizePixel = 2
                        Box.BorderColor3 = Color3.fromRGB(255, 255, 255)

                        -- Линия от бокса к низу
                        local Line = Instance.new("Frame", ESPFolder)
                        Line.Size = UDim2.new(0, 2, 0, ScreenPos.Y - Box.AbsolutePosition.Y)
                        Line.Position = UDim2.new(0, ScreenPos.X, 0, Box.AbsolutePosition.Y + Box.AbsoluteSize.Y)
                        Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end

            -- ESP для оружия (Tool)
            if Settings.EspWeapons and obj:IsA("Tool") then
                local Handle = obj:FindFirstChild("Handle")
                if Handle then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Handle.Position)
                    if OnScreen then
                        local Label = Instance.new("TextLabel", ESPFolder)
                        Label.Text = obj.Name
                        Label.Size = UDim2.new(0, 100, 0, 20)
                        Label.Position = UDim2.new(0, ScreenPos.X - 50, 0, ScreenPos.Y - 20)
                        Label.BackgroundTransparency = 1
                        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end
end)

-- Скорость
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Speed then
        local Character = game.Players.LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = Settings.SpeedValue
            end
        end
    end
end)

-- ============================
-- СВОРАЧИВАНИЕ МЕНЮ
-- ============================
local minimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 340, 0, 40)
        ToggleBtn.Position = UDim2.new(0, 10, 0, 5)
        ToggleBtn.Text = "Развернуть"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= ToggleBtn then
                child.Visible = false
            end
        end
    else
        MainFrame.Size = UDim2.new(0, 340, 0, 450)
        ToggleBtn.Position = UDim2.new(0, 10, 0, 410)
        ToggleBtn.Text = "Свернуть"
        for _, child in pairs(MainFrame:GetChildren()) do
            child.Visible = true
        end
    end
end)
