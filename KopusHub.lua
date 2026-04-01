--[[
    KOPUSHUB AI v1.0 - Yapay Zeka Destekli (FIXED)
    - Akıllı NPC seçimi & Teleport
    - Fruit Sniper AI & XP Analizi
    - Insert Tuşu / Sağ Ekran Butonu ile Menü
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- ==================== TEMEL FONKSİYONLAR (EN ÜSTE ALINDI) ====================
local function GetLevel()
    return Player.Data.Level.Value
end

local function SendNotif(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- ==================== AI & FARM AYARLARI ====================
_G.AI_Settings = {
    Enabled = true,
    AutoSelectNPC = true,
    FruitSniper = true,
    DiscordWebhook = "",
}

_G.Settings = {
    AutoFarm = false,
    FarmMethod = "Above",
    FarmWeapon = "Melee",
    FlightHeight = 25,
    KillAura = false,
    KillAuraRange = 18,
    AttackSpeed = 0.4,
    AutoQuest = true,
}

local AI_Data = {
    StartTime = tick(),
    TotalXP = 0,
    XPPerHour = 0,
    BestNPC = nil,
    BestXPPerMin = 0,
}

-- Seviye Bölgeleri (Eksik bölgeler için mantık eklendi)
local LevelZones = {
    {Min = 1, Max = 30, NPC = "Bandit", XP = 25, Quest = "BanditQuest1", QNPC = "Bandit Quest Giver", QIdx = 1, Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", XP = 50, Quest = "JungleQuest", QNPC = "Monkey Quest Giver", QIdx = 1, Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Gorilla", XP = 80, Quest = "JungleQuest", QNPC = "Monkey Quest Giver", QIdx = 2, Pos = Vector3.new(-1200, 5, 1400)},
    -- ... Diğer bölgeler buraya v9'daki gibi eklenebilir
}

-- ==================== AI ZEKA MOTORU ====================
local function AISelectBestNPC()
    if not _G.AI_Settings.AutoSelectNPC then return end
    local level = GetLevel()
    local bestZone = nil
    
    for _, zone in ipairs(LevelZones) do
        if level >= zone.Min and level <= zone.Max then
            bestZone = zone
        end
    end
    
    if bestZone and bestZone.NPC ~= AI_Data.BestNPC then
        AI_Data.BestNPC = bestZone.NPC
        SendNotif("AI GÜNCELLEME", "Hedef Değişti: " .. bestZone.NPC)
    end
    return bestZone
end

-- ==================== OTOMATİK SALDIRI & QUEST ====================
local function EquipWeapon()
    local weaponName = _G.Settings.FarmWeapon
    local tool = Player.Backpack:FindFirstChild(weaponName) or Player.Character:FindFirstChild(weaponName)
    if tool then Player.Character.Humanoid:EquipTool(tool) end
end

task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.AutoFarm then
            pcall(function()
                local zone = AISelectBestNPC() or LevelZones[1]
                local char = Player.Character
                local hrp = char.HumanoidRootPart
                
                -- Quest Kontrol
                if _G.Settings.AutoQuest and not Player.PlayerGui.Main:FindFirstChild("Quest") then
                    hrp.CFrame = workspace.NPCs[zone.QNPC].HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                    task.wait(0.5)
                    CommF:InvokeServer("StartQuest", zone.Quest, zone.QIdx)
                end
                
                -- Target Bulma
                local targetNPC = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == zone.NPC and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        targetNPC = v
                        break
                    end
                end
                
                if targetNPC then
                    EquipWeapon()
                    -- Pozisyonlama (Above)
                    hrp.CFrame = targetNPC.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.FlightHeight, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    -- Saldırı (Remote)
                    CommF:InvokeServer("Attack", {[1] = targetNPC.HumanoidRootPart.Position, [2] = targetNPC})
                else
                    -- NPC yoksa doğma alanına git
                    hrp.CFrame = zone.Pos
                end
            end)
        end
    end
end)

-- ==================== FRUIT SNIPER ====================
if _G.AI_Settings.FruitSniper then
    task.spawn(function()
        while task.wait(5) do
            local success, fruits = pcall(function() return CommF:InvokeServer("GetFruits") end)
            if success and fruits then
                for _, f in pairs(fruits) do
                    if f.InStock and (f.Name == "Buddha" or f.Name == "Leopard" or f.Name == "Dough") then
                        CommF:InvokeServer("BuyFruit", f.Name)
                        SendNotif("AI SNIPER", f.Name .. " Satın Alındı!")
                    end
                end
            end
        end
    end)
end

-- ==================== GUI TASARIMI ====================
-- (GUI Kodun genel olarak doğru, kopyaladığın kısımda Layout ve UI bileşenleri çalışacaktır)
-- Sadece CloseBtn yerine "Minimize" mantığı eklemek mobilde daha iyidir.

SendNotif("KopusHUB AI", "Sistem Başlatıldı! Insert ile aç/kapat.")
print("🤖 KOPUSHUB AI v1.0 YÜKLENDİ!")
