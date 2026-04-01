--[[
    KOPUSHUB v7.0 - FINAL STABLE VERSION
    - Remote Event Tabanlı Görev & Saldırı (Kesin Çalışır)
    - Farming & Farm Settings Ayrımı
    - Otomatik Seviye Kontrolü & NPC Kesme
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== SERVİSLER & AYARLAR ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

_G.Settings = {
    -- Farming
    AutoFarm = false,
    AutoChest = false,
    -- Farm Settings
    Weapon = "Melee", -- Melee, Sword, Fruit
    Method = "Above",
    Distance = 20,
    FlySpeed = 15,
    FastAttack = true
}

-- ==================== LEVEL VE GÖREV VERİLERİ ====================
local function GetLevel() return Player.Data.Level.Value end

local function GetQuestData()
    local lvl = GetLevel()
    if lvl >= 1 and lvl < 15 then
        return {Name = "Bandit", QName = "BanditQuest1", QNPC = "Bandit Quest Giver", QIdx = 1}
    elseif lvl >= 15 and lvl < 30 then
        return {Name = "Monkey", QName = "JungleQuest", QNPC = "Monkey Quest Giver", QIdx = 1}
    elseif lvl >= 30 and lvl < 60 then
        return {Name = "Gorilla", QName = "JungleQuest", QNPC = "Monkey Quest Giver", QIdx = 2}
    -- Diğer leveller buraya eklenebilir
    end
    return {Name = "Bandit", QName = "BanditQuest1", QNPC = "Bandit Quest Giver", QIdx = 1}
end

-- ==================== FONKSİYONLAR ====================
local function EquipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.Settings.Weapon) or Player.Character:FindFirstChild(_G.Settings.Weapon)
    if tool then
        Player.Character.Humanoid:EquipTool(tool)
    end
end

-- ==================== ANA DÖNGÜ (AUTO FARM & QUEST) ====================
task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoFarm then
            pcall(function()
                local data = GetQuestData()
                local char = Player.Character
                local hrp = char.HumanoidRootPart

                -- 1. GÖREV ALMA (Remote ile Kesin Çözüm)
                if not Player.PlayerGui.Main:FindFirstChild("Quest") then
                    local qNPC = workspace.NPCs:FindFirstChild(data.QNPC)
                    if qNPC then
                        hrp.CFrame = qNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        task.wait(0.2)
                        CommF:InvokeServer("StartQuest", data.QName, data.QIdx)
                    end
                end

                -- 2. NPC BUL VE SALDIR (Kill Aura Dahil)
                local Target = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == data.Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        Target = v
                        break
                    end
                end

                if Target then
                    EquipWeapon()
                    -- Pozisyonlama
                    if _G.Settings.Method == "Above" then
                        hrp.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    else
                        hrp.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.Settings.Distance)
                    end
                    hrp.Velocity = Vector3.new(0,0,0)

                    -- SALDIRI (Remote Vuruş)
                    if _G.Settings.FastAttack then
                        CommF:InvokeServer("Attack", {[1] = Target.HumanoidRootPart.Position, [2] = Target})
                    end
                end
            end)
        end
    end
end)

-- ==================== MODERN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHUB_V7"
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 320)
Main.Position = UDim2.new(0.5, -230, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

-- Sol Menü
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Parent = Main

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 45)
Logo.Text = "KopusHUB"
Logo.TextColor3 = Color3.fromRGB(85, 135, 255)
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Sidebar

-- SEKMELER (Farming & Farm Settings)
local FarmingContent = Instance.new("ScrollingFrame")
FarmingContent.Size = UDim2.new(1, -140, 1, -20)
FarmingContent.Position = UDim2.new(0, 135, 0, 10)
FarmingContent.BackgroundTransparency = 1
FarmingContent.Visible = true
FarmingContent.Parent = Main

local SettingsContent = FarmingContent:Clone()
SettingsContent.Visible = false
SettingsContent.Parent = Main

local Layout1 = Instance.new("UIListLayout")
Layout1.Padding = UDim.new(0, 5)
Layout1.Parent = FarmingContent

local Layout2 = Layout1:Clone()
Layout2.Parent = SettingsContent

-- Menü Değiştirme Butonları
local function CreateMenuBtn(text, pos, target)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, pos)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = Sidebar
    b.MouseButton1Click:Connect(function()
        FarmingContent.Visible = false
        SettingsContent.Visible = false
        target.Visible = true
    end)
end

CreateMenuBtn("Farming", 60, FarmingContent)
CreateMenuBtn("Farm Settings", 100, SettingsContent)

-- --- SEKMELERİN İÇERİĞİ ---

-- 1. FARMING SEKMESİ
local function AddToggle(parent, text, setting)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0.95, 0, 0, 40)
    t.Text = text .. ": OFF"
    t.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Parent = parent
    t.MouseButton1Click:Connect(function()
        _G.Settings[setting] = not _G.Settings[setting]
        t.Text = text .. ": " .. (_G.Settings[setting] and "ON" or "OFF")
        t.BackgroundColor3 = _G.Settings[setting] and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 50)
    end)
end

AddToggle(FarmingContent, "Auto Farm (Quest + KillAura)", "AutoFarm")
AddToggle(FarmingContent, "Auto Chest Farm", "AutoChest")

-- 2. SETTINGS SEKMESİ
local function AddDropdown(parent, text, setting, options)
    local d = Instance.new("TextButton")
    d.Size = UDim2.new(0.95, 0, 0, 40)
    d.Text = text .. ": " .. _G.Settings[setting]
    d.Parent = parent
    d.MouseButton1Click:Connect(function()
        local idx = 1
        for i,v in ipairs(options) do if v == _G.Settings[setting] then idx = i end end
        _G.Settings[setting] = options[(idx % #options) + 1]
        d.Text = text .. ": " .. _G.Settings[setting]
    end)
end

AddDropdown(SettingsContent, "Weapon", "Weapon", {"Melee", "Sword", "Fruit"})
AddDropdown(SettingsContent, "Method", "Method", {"Above", "Behind"})

-- Hız Ayarı (Basit Slider Mantığı)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.95, 0, 0, 40)
SpeedBtn.Text = "Fly Speed: " .. _G.Settings.FlySpeed
SpeedBtn.Parent = SettingsContent
SpeedBtn.MouseButton1Click:Connect(function()
    _G.Settings.FlySpeed = (_G.Settings.FlySpeed >= 30 and 5 or _G.Settings.FlySpeed + 5)
    SpeedBtn.Text = "Fly Speed: " .. _G.Settings.FlySpeed
end)

print("KopusHUB v7.0 Yüklendi. Farming ve Settings ayrıldı!")
