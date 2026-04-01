--[[
    KOPUSHUB v9.0 - AI DRIVEN LOGIC
    - AI Karar Mekanizması (Seviye, Envanter ve NPC Analizi)
    - Çift Sekmeli Modern GUI (Farming & Farm Settings)
    - Entegre Kill Aura & Auto Quest (Ayrı değil, Farm'ın içinde)
    - Otomatik Seviye/Bölge Tanıma
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== AI BEYİN (LOGIC ENGINE) ====================
_G.Settings = {
    AutoFarm = false,
    AutoChest = false,
    Weapon = "Melee", -- AI bunu envantere göre güncelleyebilir
    Method = "Above",
    Distance = 20,
    FlySpeed = 15
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

-- AI Karar Tablosu (Leveline göre nereye gideceğini "bilir")
local KopusAI = {
    AnalyzeLevel = function()
        local lvl = Player.Data.Level.Value
        if lvl < 15 then return "Bandit", "BanditQuest1", "Bandit Quest Giver", 1
        elseif lvl < 30 then return "Monkey", "JungleQuest", "Monkey Quest Giver", 1
        elseif lvl < 60 then return "Gorilla", "JungleQuest", "Monkey Quest Giver", 2
        elseif lvl < 120 then return "Pirate", "BugyQuest", "Bugy Quest Giver", 1
        -- AI Mantığı: Buraya tüm levelleri ekleyebilirsin
        else return "Snowman", "SnowQuest", "Snow Quest Giver", 1 end
    end,
    
    ScanInventory = function()
        -- AI envanterini tarar, eğer seçtiğin silah yoksa en iyisini bulur
        local chosen = _G.Settings.Weapon
        if not Player.Backpack:FindFirstChild(chosen) and not Player.Character:FindFirstChild(chosen) then
            if Player.Backpack:FindFirstChild("Combat") then return "Combat" end
        end
        return chosen
    end
}

-- ==================== ANA FONKSİYONLAR ====================
local function EquipAIWeapon()
    local weaponName = KopusAI.ScanInventory()
    local tool = Player.Backpack:FindFirstChild(weaponName) or Player.Character:FindFirstChild(weaponName)
    if tool then Player.Character.Humanoid:EquipTool(tool) end
end

-- ==================== ANA DÖNGÜ (ZEKA BURADA) ====================
task.spawn(function()
    while task.wait() do
        if _G.Settings.AutoFarm then
            pcall(function()
                local npcName, questName, questNPC, questIdx = KopusAI.AnalyzeLevel()
                local hrp = Player.Character.HumanoidRootPart
                
                -- 1. AI KARARI: GÖREV ALMALI MIYIM?
                if not Player.PlayerGui.Main:FindFirstChild("Quest") then
                    local qNPC = workspace.NPCs:FindFirstChild(questNPC)
                    if qNPC then
                        hrp.CFrame = qNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        task.wait(0.3)
                        CommF:InvokeServer("StartQuest", questName, questIdx)
                    end
                end

                -- 2. AI KARARI: HANGİ NPC'YE SALDIRMALIYIM? (Kill Aura & Farm)
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == npcName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        EquipAIWeapon()
                        
                        -- Akıllı Pozisyonlama
                        if _G.Settings.Method == "Above" then
                            hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        else
                            hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.Settings.Distance)
                        end
                        hrp.Velocity = Vector3.new(0, 0, 0)

                        -- SALDIRI (Fast Attack Remote)
                        CommF:InvokeServer("Attack", {[1] = enemy.HumanoidRootPart.Position, [2] = enemy})
                        break
                    end
                end
            end)
        end
    end
end)

-- ==================== GUI TASARIMI (BLUE X STİLİ) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHUB_V9"
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 320)
Main.Position = UDim2.new(0.5, -240, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.Parent = Main

-- Yan Menü
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Sidebar.Parent = Main

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Text = "KopusHUB AI"
Logo.TextColor3 = Color3.fromRGB(70, 130, 255)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 20
Logo.Parent = Sidebar

-- İçerik Panelleri
local FarmingPanel = Instance.new("ScrollingFrame")
FarmingPanel.Size = UDim2.new(1, -150, 1, -20)
FarmingPanel.Position = UDim2.new(0, 145, 0, 10)
FarmingPanel.BackgroundTransparency = 1
FarmingPanel.CanvasSize = UDim2.new(0, 0, 1.5, 0)
FarmingPanel.Parent = Main

local SettingsPanel = FarmingPanel:Clone()
SettingsPanel.Visible = false
SettingsPanel.Parent = Main

-- Tab Değiştirme
local function AddTab(name, pos, panel)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.Parent = Sidebar
    btn.MouseButton1Click:Connect(function()
        FarmingPanel.Visible = false
        SettingsPanel.Visible = false
        panel.Visible = true
    end)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
end

AddTab("Farming", 60, FarmingPanel)
AddTab("Farm Settings", 100, SettingsPanel)

local Layout1 = Instance.new("UIListLayout")
Layout1.Padding = UDim.new(0, 8)
Layout1.Parent = FarmingPanel
local Layout2 = Layout1:Clone()
Layout2.Parent = SettingsPanel

-- --- ELEMANLAR ---
local function CreateToggle(parent, text, setting)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0.95, 0, 0, 45)
    t.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    t.Text = text .. ": OFF"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.Parent = parent
    t.MouseButton1Click:Connect(function()
        _G.Settings[setting] = not _G.Settings[setting]
        t.Text = text .. ": " .. (_G.Settings[setting] and "ON" or "OFF")
        t.BackgroundColor3 = _G.Settings[setting] and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(35, 35, 45)
    end)
end

-- Farming Sekmesi (Her şey burada kilitli)
CreateToggle(FarmingPanel, "AI Auto Farm", "AutoFarm")
CreateToggle(FarmingPanel, "Auto Chest", "AutoChest")

-- Settings Sekmesi
local function CreateDropdown(parent, text, setting, options)
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

CreateDropdown(SettingsPanel, "Weapon", "Weapon", {"Melee", "Sword", "Fruit"})
CreateDropdown(SettingsPanel, "Method", "Method", {"Above", "Behind"})

-- Fly Speed Slider (Butonlu)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.95, 0, 0, 40)
SpeedBtn.Text = "Fly Speed: " .. _G.Settings.FlySpeed
SpeedBtn.Parent = SettingsPanel
SpeedBtn.MouseButton1Click:Connect(function()
    _G.Settings.FlySpeed = (_G.Settings.FlySpeed >= 30 and 5 or _G.Settings.FlySpeed + 5)
    SpeedBtn.Text = "Fly Speed: " .. _G.Settings.FlySpeed
end)

print("KopusHUB v9.0 AI Aktif!")
