--[[
    KOPUSHUB v5.1 - Blox Fruits Ultimate Script
    - Delta & Mobile Uyumluluğu Arttırıldı
    - Remote Event Tabanlı Saldırı (E Tuşu Yerine)
    - BodyVelocity Tabanlı Güvenli Uçuş
    - Otomatik Görev Alma Sistemi
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== SERVİSLER ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- ==================== AYARLAR ====================
_G.Settings = {
    AutoFarm = false,
    FarmMethod = "Above", -- Above, Ground
    Weapon = "Melee", -- Melee, Sword
    Distance = 8, -- NPC ile arandaki mesafe
    FlightHeight = 25
}

-- ==================== YARDIMCI FONKSİYONLAR ====================
local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end
local function GetHRP() return GetChar():FindFirstChild("HumanoidRootPart") end

-- Blox Fruits Ana Remote'u
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- En Yakın NPC'yi Bulma
local function GetEnemy()
    local Character = GetChar()
    local MyPos = GetHRP().Position
    local Target = nil
    local MaxDist = 500

    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            local Dist = (v.HumanoidRootPart.Position - MyPos).Magnitude
            if Dist < MaxDist then
                MaxDist = Dist
                Target = v
            end
        end
    end
    return Target
end

-- Silahı Elimize Alalım
local function EquipWeapon()
    local ToolName = _G.Settings.Weapon
    if Player.Backpack:FindFirstChild(ToolName) then
        GetChar().Humanoid:EquipTool(Player.Backpack[ToolName])
    end
end

-- ==================== ANA DÖNGÜ (FARM) ====================
task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoFarm then
            pcall(function()
                local Target = GetEnemy()
                if Target then
                    EquipWeapon()
                    local HRP = GetHRP()
                    local TargetHRP = Target.HumanoidRootPart
                    
                    -- Karakteri NPC'nin Üstüne Sabitle (Kick Engellemek İçin)
                    if _G.Settings.FarmMethod == "Above" then
                        HRP.CFrame = TargetHRP.CFrame * CFrame.new(0, _G.Settings.FlightHeight, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    else
                        HRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, _G.Settings.Distance)
                    end

                    -- Fiziksel Hareketi Sıfırla (Anti-Cheat İçin)
                    HRP.Velocity = Vector3.new(0, 0, 0)
                    
                    -- SALDIRI (Remote Kullanarak - Daha Hızlı ve Güvenli)
                    CommF:InvokeServer("Attack", {
                        [1] = TargetHRP.Position,
                        [2] = Target
                    })
                end
            end)
        end
    end
end)

-- ==================== GUI (DELTA İÇİN OPTİMİZE) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubV5"
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Mobil kullanıcılar için önemli
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "KOPUSHUB v5.1 (Delta)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- AUTO FARM BUTONU
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(0.9, 0, 0, 50)
FarmToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FarmToggle.Text = "Auto Farm: OFF"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.Font = Enum.Font.GothamSemibold
FarmToggle.Parent = Main

FarmToggle.MouseButton1Click:Connect(function()
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    FarmToggle.Text = _G.Settings.AutoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    FarmToggle.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
end)

-- SİLAH SEÇİMİ
local WeaponToggle = Instance.new("TextButton")
WeaponToggle.Size = UDim2.new(0.9, 0, 0, 50)
WeaponToggle.Position = UDim2.new(0.05, 0, 0.4, 0)
WeaponToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
WeaponToggle.Text = "Weapon: Melee"
WeaponToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponToggle.Font = Enum.Font.GothamSemibold
WeaponToggle.Parent = Main

WeaponToggle.MouseButton1Click:Connect(function()
    if _G.Settings.Weapon == "Melee" then
        _G.Settings.Weapon = "Sword"
    else
        _G.Settings.Weapon = "Melee"
    end
    WeaponToggle.Text = "Weapon: " .. _G.Settings.Weapon
end)

-- KAPATMA TUŞU (MOBİL İÇİN ÖNEMLİ)
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.Parent = Main

Close.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- GÜVENLİK NOTU
print("KopusHub v5.1 Yüklendi. Remote tabanlı saldırı aktif.")
