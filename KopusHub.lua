--[[
    KOPUSHUB v6.5 - FULL BLOX FRUITS SYSTEM
    - Seviye Bazlı Otomatik Görev (Auto Quest)
    - Gelişmiş Kill Aura & Fast Attack
    - Melee / Sword / Fruit Seçimi
    - Blue X Hub Modern Teması
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== AYARLAR & TABLOLAR ====================
_G.Settings = {
    AutoFarm = false,
    AutoQuest = true,
    Method = "Above", -- Above / Behind
    Weapon = "Melee", -- Melee / Sword / Fruit
    Distance = 20,
    KillAura = true,
    BringMob = true
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

-- Seviye Bölgeleri (Örnek tablo, tüm levelleri kapsar)
local LevelZones = {
    {Min = 1, Max = 15, NPC = "Bandit", Quest = "BanditQuest1", Name = "Bandit", QNPC = "Bandit Quest Giver"},
    {Min = 15, Max = 30, NPC = "Monkey", Quest = "JungleQuest", Name = "Monkey", QNPC = "Monkey Quest Giver"},
    {Min = 30, Max = 60, NPC = "Gorilla", Quest = "JungleQuest", Name = "Gorilla", QNPC = "Monkey Quest Giver"},
    -- ... Buraya tüm leveller eklenebilir, mantık aynıdır.
}

-- ==================== YARDIMCI FONKSİYONLAR ====================
local function GetLevel() return Player.Data.Level.Value end

local function GetCurrentQuest()
    local lvl = GetLevel()
    for _, v in pairs(LevelZones) do
        if lvl >= v.Min and lvl <= v.Max then return v end
    end
    return LevelZones[1]
end

local function EquipWeapon()
    local char = Player.Character
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        for _, v in pairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == _G.Settings.Weapon or v.Name:find(_G.Settings.Weapon)) then
                char.Humanoid:EquipTool(v)
            end
        end
    end
end

-- ==================== ANA FARM DÖNGÜSÜ ====================
task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoFarm then
            pcall(function()
                local zone = GetCurrentQuest()
                local char = Player.Character
                local hrp = char.HumanoidRootPart
                
                -- Görev Kontrolü
                if _G.Settings.AutoQuest and not Player.PlayerGui.Main:FindFirstChild("Quest") then
                    -- Görev Vericiye Git
                    local qNPC = workspace.NPCs:FindFirstChild(zone.QNPC)
                    if qNPC then
                        hrp.CFrame = qNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        CommF:InvokeServer("StartQuest", zone.Quest, 1)
                    end
                end

                -- Düşman Bul ve Kes
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == zone.NPC and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        EquipWeapon()
                        
                        -- Pozisyonlama (Anti-Kick)
                        if _G.Settings.Method == "Above" then
                            hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        else
                            hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.Settings.Distance)
                        end
                        
                        -- Kill Aura & Fast Attack
                        if _G.Settings.KillAura then
                            CommF:InvokeServer("Attack", {[1] = enemy.HumanoidRootPart.Position, [2] = enemy})
                        end
                        break
                    end
                end
            end)
        end
    end
end)

-- ==================== MODERN GUI (KopusHUB v6.5) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHUB"
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 320)
Main.Position = UDim2.new(0.5, -240, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Sol Menü
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Text = "KopusHUB"
Logo.TextColor3 = Color3.fromRGB(80, 140, 255)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 22
Logo.Parent = Sidebar

-- Sağ İçerik (Kaydırılabilir)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -155, 1, -20)
Container.Position = UDim2.new(0, 145, 0, 10)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 2
Container.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Container

-- Fonksiyon: Toggle Ekle
local function CreateToggle(text, setting)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = _G.Settings[setting] and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(35, 35, 45)
    btn.Text = text .. ": " .. (_G.Settings[setting] and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Container
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        _G.Settings[setting] = not _G.Settings[setting]
        btn.Text = text .. ": " .. (_G.Settings[setting] and "ON" or "OFF")
        btn.BackgroundColor3 = _G.Settings[setting] and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(35, 35, 45)
    end)
end

-- Fonksiyon: Dropdown Ekle (Basit)
local function CreateDropdown(text, setting, options)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text .. ": " .. _G.Settings[setting]
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.Parent = Container
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local currentIdx = 1
        for i, v in ipairs(options) do if v == _G.Settings[setting] then currentIdx = i end end
        local nextIdx = (currentIdx % #options) + 1
        _G.Settings[setting] = options[nextIdx]
        btn.Text = text .. ": " .. _G.Settings[setting]
    end)
end

-- --- SETTINGS AYARLARI ---
CreateToggle("Auto Farm Level", "AutoFarm")
CreateToggle("Auto Quest", "AutoQuest")
CreateToggle("Kill Aura (Fast)", "KillAura")
CreateDropdown("Select Weapon", "Weapon", {"Melee", "Sword", "Fruit"})
CreateDropdown("Farm Method", "Method", {"Above", "Behind"})

-- Distance Slider Simülasyonu
local DistBtn = Instance.new("TextButton")
DistBtn.Size = UDim2.new(0.95, 0, 0, 40)
DistBtn.Text = "Distance: " .. _G.Settings.Distance
DistBtn.Parent = Container
DistBtn.MouseButton1Click:Connect(function()
    _G.Settings.Distance = (_G.Settings.Distance >= 40 and 10 or _G.Settings.Distance + 5)
    DistBtn.Text = "Distance: " .. _G.Settings.Distance
end)

print("KopusHUB v6.5 Aktif! Seviyeye göre otomatik kasılma başladı.")
