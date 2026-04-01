--[[
    KOPUSHUB v6.0 - ULTIMATE BLOX FRUITS SCRIPT
    Blue X Hub Design Concept
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== SERVİSLER & DEĞİŞKENLER ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

_G.Settings = {
    AutoFarm = false,
    FarmMethod = "Above", 
    Weapon = "Melee",
    Distance = 17,
    FlightSpeed = 10,
    BringMob = true,
    FastAttack = true
}

-- ==================== FARM MANTIĞI ====================
local function GetEnemy()
    local Target = nil
    local MaxDist = 500
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local Dist = (v.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if Dist < MaxDist then
                MaxDist = Dist
                Target = v
            end
        end
    end
    return Target
end

task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoFarm then
            pcall(function()
                local Target = GetEnemy()
                if Target then
                    local HRP = Player.Character.HumanoidRootPart
                    -- Silah Kuşan
                    if Player.Backpack:FindFirstChild(_G.Settings.Weapon) then
                        Player.Character.Humanoid:EquipTool(Player.Backpack[_G.Settings.Weapon])
                    end
                    
                    -- Pozisyon Ayarı (Above / Behind)
                    if _G.Settings.FarmMethod == "Above" then
                        HRP.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    else
                        HRP.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.Settings.Distance)
                    end
                    
                    -- Saldırı
                    CommF:InvokeServer("Attack", {[1] = Target.HumanoidRootPart.Position, [2] = Target})
                end
            end)
        end
    end
end)

-- ==================== MODERN GUI (BLUE X STYLE) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHUB_V6"
ScreenGui.Parent = Player.PlayerGui

-- Ana Panel
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Active = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

-- Sol Menü (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 40)
Logo.Text = "KopusHUB"
Logo.TextColor3 = Color3.fromRGB(100, 150, 255)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 18
Logo.Parent = Sidebar

-- Butonlar (Sidebar)
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.9, 0, 0, 35)
FarmBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
FarmBtn.Text = "Setting Farm"
FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.Gotham
FarmBtn.Parent = Sidebar

-- Sağ İçerik Alanı
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -20)
Content.Position = UDim2.new(0, 135, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Setting Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Content

-- AYARLAR: Distance Farm (Slider)
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, 0, 0, 20)
DistLabel.Position = UDim2.new(0, 0, 0, 40)
DistLabel.Text = "Distance Farm: " .. _G.Settings.Distance
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistLabel.BackgroundTransparency = 1
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = Content

-- Auto Farm Toggle (Görseldeki Mavi Switch Tarzı)
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(0.9, 0, 0, 40)
FarmToggle.Position = UDim2.new(0, 0, 0, 70)
FarmToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FarmToggle.Text = "Auto Farm: OFF"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.Parent = Content

FarmToggle.MouseButton1Click:Connect(function()
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    FarmToggle.Text = _G.Settings.AutoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    FarmToggle.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(60, 80, 200) or Color3.fromRGB(35, 35, 45)
end)

-- Method Dropdown (Basitleştirilmiş)
local MethodBtn = Instance.new("TextButton")
MethodBtn.Size = UDim2.new(0.9, 0, 0, 40)
MethodBtn.Position = UDim2.new(0, 0, 0, 120)
MethodBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MethodBtn.Text = "Method: Above"
MethodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MethodBtn.Parent = Content

MethodBtn.MouseButton1Click:Connect(function()
    _G.Settings.FarmMethod = (_G.Settings.FarmMethod == "Above" and "Behind" or "Above")
    MethodBtn.Text = "Method: " .. _G.Settings.FarmMethod
end)

-- Kapatma Butonu
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("KopusHUB v6.0 Başarıyla Yüklendi!")
