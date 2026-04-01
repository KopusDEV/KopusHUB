--[[
    ██╗  ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗
    ██║ ██╔╝██╔═══██╗██╔══██╗██║   ██║██╔════╝
    █████╔╝ ██║   ██║██████╔╝██║   ██║███████╗
    ██╔═██╗ ██║   ██║██╔═══╝ ██║   ██║╚════██║
    ██║  ██╗╚██████╔╝██║     ╚██████╔╝███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚═╝      ╚═════╝ ╚══════╝
    
    KopusHub - Blox Fruits Ultimate Script
    Version: 2.0
    Platform: Delta Mobile / MuMu Player
    Developer: Custom Script
--]]

-- ==================== BAŞLANGIÇ KONTROLLERİ ====================
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "KopusHub",
        Text = "Lütfen Blox Fruits oyununa girin!",
        Duration = 5
    })
    return
end

-- ==================== DEĞİŞKENLER ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

-- ==================== AYARLAR ====================
local Settings = {
    -- Auto Farm
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    Flight = false,
    
    -- Farm Ayarları
    FarmMode = "Normal", -- Normal, Aggressive, Safe
    FarmWeapon = "Melee", -- Melee, Fruit, Sword
    FarmTarget = "Nearest", -- Nearest, Bandit, Monkey, Viking, Pirate, Brute...
    AttackRange = 15,
    AttackSpeed = 0.3,
    
    -- Güvenlik
    SafeHealthPercent = 30,
    TeleportToSafePoint = true,
    SafePointPosition = Vector3.new(0, 100, 0),
    
    -- Görsel
    ShowESP = false,
    ShowFPS = false,
    Theme = "Dark", -- Dark, Light, Red, Blue
    
    -- Diğer
    AntiAFK = false,
    AutoRedeemCode = false,
    AutoCollectFruits = false
}

-- ==================== NPC VERİTABANI ====================
local NPCDatabase = {
    -- 1. Deniz (Level 1-300)
    {Name = "Bandit", MinLevel = 1, MaxLevel = 30, QuestGiver = "Bandit Quest Giver", Location = "Pirate Village"},
    {Name = "Monkey", MinLevel = 30, MaxLevel = 60, QuestGiver = "Monkey Quest Giver", Location = "Jungle"},
    {Name = "Viking", MinLevel = 60, MaxLevel = 90, QuestGiver = "Viking Quest Giver", Location = "Desert"},
    {Name = "Pirate", MinLevel = 90, MaxLevel = 120, QuestGiver = "Pirate Quest Giver", Location = "Desert"},
    {Name = "Brute", MinLevel = 120, MaxLevel = 150, QuestGiver = "Brute Quest Giver", Location = "Marine Fortress"},
    {Name = "Desert Soldier", MinLevel = 150, MaxLevel = 200, QuestGiver = "Desert Soldier Quest Giver", Location = "Desert"},
    {Name = "Snow Bandit", MinLevel = 200, MaxLevel = 250, QuestGiver = "Snow Bandit Quest Giver", Location = "Snow Mountain"},
    {Name = "Chief Petty Officer", MinLevel = 250, MaxLevel = 300, QuestGiver = "Chief Petty Officer Quest Giver", Location = "Marine Fortress"},
    
    -- 2. Deniz (Level 300-700)
    {Name = "Sea Soldier", MinLevel = 300, MaxLevel = 350, QuestGiver = "Sea Soldier Quest Giver", Location = "Frozen Village"},
    {Name = "Magma Ninja", MinLevel = 350, MaxLevel = 400, QuestGiver = "Magma Ninja Quest Giver", Location = "Magma Village"},
    {Name = "Ship Deckhand", MinLevel = 400, MaxLevel = 450, QuestGiver = "Ship Deckhand Quest Giver", Location = "Pirate Village"},
    {Name = "Prisoner", MinLevel = 450, MaxLevel = 500, QuestGiver = "Prisoner Quest Giver", Location = "Prison"},
    {Name = "Dangerous Prisoner", MinLevel = 500, MaxLevel = 550, QuestGiver = "Dangerous Prisoner Quest Giver", Location = "Prison"},
    {Name = "Military Soldier", MinLevel = 550, MaxLevel = 600, QuestGiver = "Military Soldier Quest Giver", Location = "Marine Base"},
    {Name = "Military Spy", MinLevel = 600, MaxLevel = 650, QuestGiver = "Military Spy Quest Giver", Location = "Marine Base"},
    {Name = "Diamond", MinLevel = 650, MaxLevel = 700, QuestGiver = "Diamond Quest Giver", Location = "Green Zone"},
    
    -- 3. Deniz (Level 700-1500)
    {Name = "Zombie", MinLevel = 700, MaxLevel = 750, QuestGiver = "Zombie Quest Giver", Location = "Graveyard"},
    {Name = "Vampire", MinLevel = 750, MaxLevel = 800, QuestGiver = "Vampire Quest Giver", Location = "Graveyard"},
    {Name = "Snow Trooper", MinLevel = 800, MaxLevel = 850, QuestGiver = "Snow Trooper Quest Giver", Location = "Snow Mountain"},
    {Name = "Winter Warrior", MinLevel = 850, MaxLevel = 900, QuestGiver = "Winter Warrior Quest Giver", Location = "Snow Mountain"},
    {Name = "Lab Subordinate", MinLevel = 900, MaxLevel = 950, QuestGiver = "Lab Subordinate Quest Giver", Location = "Factory"},
    {Name = "Horned Warrior", MinLevel = 950, MaxLevel = 1000, QuestGiver = "Horned Warrior Quest Giver", Location = "Factory"},
    {Name = "God's Guard", MinLevel = 1000, MaxLevel = 1100, QuestGiver = "God's Guard Quest Giver", Location = "Sky Islands"},
    {Name = "Paladin", MinLevel = 1100, MaxLevel = 1200, QuestGiver = "Paladin Quest Giver", Location = "Sky Islands"},
    {Name = "Conjured Coconut", MinLevel = 1200, MaxLevel = 1300, QuestGiver = "Conjured Coconut Quest Giver", Location = "Cake Land"},
    {Name = "Infantry Soldier", MinLevel = 1300, MaxLevel = 1400, QuestGiver = "Infantry Soldier Quest Giver", Location = "Cake Land"},
    {Name = "Archer", MinLevel = 1400, MaxLevel = 1500, QuestGiver = "Archer Quest Giver", Location = "Cake Land"},
    
    -- 3. Deniz (Level 1500+)
    {Name = "Pistol Billionaire", MinLevel = 1500, MaxLevel = 1600, QuestGiver = "Pistol Billionaire Quest Giver", Location = "Port Town"},
    {Name = "Cannon Billionaire", MinLevel = 1600, MaxLevel = 1700, QuestGiver = "Cannon Billionaire Quest Giver", Location = "Port Town"},
    {Name = "Electric God", MinLevel = 1700, MaxLevel = 1800, QuestGiver = "Electric God Quest Giver", Location = "Great Tree"},
    {Name = "Thunder God", MinLevel = 1800, MaxLevel = 1900, QuestGiver = "Thunder God Quest Giver", Location = "Great Tree"},
    {Name = "Dragon Crew Warrior", MinLevel = 1900, MaxLevel = 2000, QuestGiver = "Dragon Crew Warrior Quest Giver", Location = "Hydra Island"},
    {Name = "Dragon Crew Archer", MinLevel = 2000, MaxLevel = 2100, QuestGiver = "Dragon Crew Archer Quest Giver", Location = "Hydra Island"},
    {Name = "Female Pirate", MinLevel = 2100, MaxLevel = 2200, QuestGiver = "Female Pirate Quest Giver", Location = "Port Town"},
    {Name = "Giant Pirate", MinLevel = 2200, MaxLevel = 2300, QuestGiver = "Giant Pirate Quest Giver", Location = "Port Town"},
    {Name = "Marine Captain", MinLevel = 2300, MaxLevel = 2400, QuestGiver = "Marine Captain Quest Giver", Location = "Marine Base"},
    {Name = "Marine Commodore", MinLevel = 2400, MaxLevel = 2500, QuestGiver = "Marine Commodore Quest Giver", Location = "Marine Base"}
}

-- ==================== YARDIMCI FONKSİYONLAR ====================
local function GetCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    return Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChild("Humanoid")
end

local function GetHumanoidRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerLevel()
    return Player.Data.Level.Value
end

local function SendNotification(Title, Text, Duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title,
        Text = Text,
        Duration = Duration or 3
    })
end

-- ==================== NPC BULMA FONKSİYONU ====================
local function GetTargetNPC()
    local hrp = GetHumanoidRootPart()
    if not hrp then return nil end
    
    local closest = nil
    local closestDistance = math.huge
    local playerLevel = GetPlayerLevel()
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local npcName = npc.Name
            
            -- Hedef kontrolü
            local shouldFarm = false
            
            if Settings.FarmTarget == "Nearest" then
                shouldFarm = true
            else
                for _, data in pairs(NPCDatabase) do
                    if Settings.FarmTarget == data.Name and npcName:find(data.Name) then
                        shouldFarm = true
                        break
                    end
                end
            end
            
            if shouldFarm then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local distance = (hrp.Position - npcRoot.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closest = npc
                    end
                end
            end
        end
    end
    
    return closest, closestDistance
end

-- ==================== HAREKET FONKSİYONU ====================
local function MoveTo(Position)
    local hrp = GetHumanoidRootPart()
    local humanoid = GetHumanoid()
    
    if not hrp or not humanoid then return false end
    
    if Settings.Flight then
        humanoid.PlatformStand = true
        hrp.Velocity = Vector3.new(0, 0, 0)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(Position)})
        tween:Play()
        tween.Completed:Wait()
    else
        humanoid:MoveTo(Position)
        
        local timeout = 0
        while (hrp.Position - Position).Magnitude > 5 and humanoid.Health > 0 and timeout < 50 do
            wait(0.1)
            humanoid:MoveTo(Position)
            timeout = timeout + 1
        end
    end
    
    return true
end

-- ==================== SALDIRI FONKSİYONU ====================
local function AttackNPC(npc)
    local hrp = GetHumanoidRootPart()
    local humanoid = GetHumanoid()
    
    if not hrp or not humanoid or not npc then return false end
    
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not npcRoot then return false end
    
    -- NPC'ye bak
    hrp.CFrame = CFrame.new(hrp.Position, npcRoot.Position)
    
    -- Yaklaş
    local distance = (hrp.Position - npcRoot.Position).Magnitude
    if distance > 5 then
        MoveTo(npcRoot.Position)
    end
    
    -- Saldır
    wait(0.1)
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.05)
    VirtualInput:SendKeyEvent(false, "E", false, game)
    
    return true
end

-- ==================== QUEST FONKSİYONU ====================
local function GetQuestNPC()
    local playerLevel = GetPlayerLevel()
    local targetName = Settings.FarmTarget
    
    for _, data in pairs(NPCDatabase) do
        if targetName == data.Name or Settings.FarmTarget == "Nearest" then
            if playerLevel >= data.MinLevel and playerLevel <= data.MaxLevel then
                for _, npc in pairs(workspace.NPCs:GetChildren()) do
                    if npc.Name == data.QuestGiver then
                        return npc, data
                    end
                end
            end
        end
    end
    
    return nil, nil
end

local function HandleQuest()
    if not Settings.AutoQuest then return end
    
    local questFrame = Player.PlayerGui:FindFirstChild("Quest")
    
    if questFrame then
        -- Quest tamamlama
        local completeButton = questFrame:FindFirstChild("Complete")
        if completeButton and completeButton.Visible then
            VirtualInput:SendKeyEvent(true, "E", false, game)
            wait(0.2)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            wait(0.5)
            SendNotification("KopusHub", "Quest tamamlandı!", 2)
        end
        return
    end
    
    -- Yeni quest al
    local questNPC, npcData = GetQuestNPC()
    if not questNPC then return end
    
    local hrp = GetHumanoidRootPart()
    if hrp and (hrp.Position - questNPC.HumanoidRootPart.Position).Magnitude > 15 then
        MoveTo(questNPC.HumanoidRootPart.Position)
    end
    
    wait(0.3)
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.2)
    VirtualInput:SendKeyEvent(false, "E", false, game)
    wait(0.5)
    
    if npcData then
        SendNotification("KopusHub", "Quest alındı: " .. npcData.Name, 2)
    end
end

-- ==================== UÇUŞ FONKSİYONU ====================
local function FlightControl()
    local humanoid = GetHumanoid()
    local hrp = GetHumanoidRootPart()
    
    if Settings.Flight and humanoid and hrp then
        humanoid.PlatformStand = true
        hrp.Velocity = Vector3.new(0, 0, 0)
        
        if hrp.Position.Y < 20 then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
        end
    elseif humanoid then
        humanoid.PlatformStand = false
    end
end

-- ==================== GÜVENLİK FONKSİYONU ====================
local function CheckHealthSafety()
    local humanoid = GetHumanoid()
    if not humanoid then return end
    
    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
    
    if Settings.FarmMode == "Safe" and healthPercent < Settings.SafeHealthPercent then
        if Settings.TeleportToSafePoint then
            local hrp = GetHumanoidRootPart()
            if hrp then
                hrp.CFrame = CFrame.new(Settings.SafePointPosition)
                wait(3)
                humanoid.Health = humanoid.MaxHealth
                SendNotification("KopusHub", "Güvenli bölgeye ışınlandı!", 2)
            end
        end
        return false
    end
    
    return true
end

-- ==================== ANTI AFK ====================
local function AntiAFK()
    if not Settings.AntiAFK then return end
    
    local vim = VirtualInput
    local animations = {
        function() vim:SendKeyEvent(true, "W", false, game) wait(0.1) vim:SendKeyEvent(false, "W", false, game) end,
        function() vim:SendKeyEvent(true, "A", false, game) wait(0.1) vim:SendKeyEvent(false, "A", false, game) end,
        function() vim:SendKeyEvent(true, "S", false, game) wait(0.1) vim:SendKeyEvent(false, "S", false, game) end,
        function() vim:SendKeyEvent(true, "D", false, game) wait(0.1) vim:SendKeyEvent(false, "D", false, game) end,
        function() vim:SendKeyEvent(true, "Space", false, game) wait(0.1) vim:SendKeyEvent(false, "Space", false, game) end
    }
    
    animations[math.random(1, #animations)]()
end

-- ==================== ANA FARM DÖNGÜSÜ ====================
spawn(function()
    while wait(Settings.AttackSpeed) do
        if not Settings.AutoFarm and not Settings.KillAura then
            wait(0.5)
            continue
        end
        
        local humanoid = GetHumanoid()
        local hrp = GetHumanoidRootPart()
        
        if not humanoid or not hrp or humanoid.Health <= 0 then
            wait(2)
            continue
        end
        
        -- Güvenlik kontrolü
        if not CheckHealthSafety() then
            wait(3)
            continue
        end
        
        -- Quest kontrolü
        if Settings.AutoFarm and Settings.AutoQuest then
            HandleQuest()
        end
        
        -- NPC bul ve saldır
        local targetNPC = GetTargetNPC()
        
        if targetNPC then
            if Settings.FarmMode == "Aggressive" then
                AttackNPC(targetNPC)
            else
                AttackNPC(targetNPC)
            end
        else
            wait(0.5)
        end
    end
end)

-- Uçuş döngüsü
spawn(function()
    while wait(0.1) do
        FlightControl()
    end
end)

-- Anti AFK döngüsü
spawn(function()
    while wait(300) do -- Her 5 dakikada bir
        AntiAFK()
    end
end)

-- Karakter yenileme
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    wait(1)
    SendNotification("KopusHub", "Karakter yenilendi!", 2)
end)

-- ==================== ESP SİSTEMİ ====================
if Settings.ShowESP then
    spawn(function()
        while wait(0.1) do
            if not Settings.ShowESP then break end
            
            for _, npc in pairs(workspace.Enemies:GetChildren()) do
                if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    local esp = npc:FindFirstChild("ESP")
                    if not esp then
                        esp = Instance.new("BillboardGui")
                        esp.Name = "ESP"
                        esp.Size = UDim2.new(0, 100, 0, 30)
                        esp.StudsOffset = Vector3.new(0, 2, 0)
                        esp.AlwaysOnTop = true
                        esp.Parent = npc
                        
                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        frame.BackgroundTransparency = 0.5
                        frame.BorderSizePixel = 0
                        frame.Parent = esp
                        
                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.Text = npc.Name
                        text.TextColor3 = Color3.fromRGB(255, 255, 255)
                        text.TextScaled = true
                        text.Font = Enum.Font.GothamBold
                        text.Parent = frame
                    end
                end
            end
        end
    end)
end

-- ==================== GUI OLUŞTURMA ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHub"
ScreenGui.Parent = Player.PlayerGui

-- Ana Pencere
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 650)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Gölge efekti
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.BorderSizePixel = 0
Shadow.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🔥 KOPUSHUB | BLOX FRUITS"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Level gösterge
local LevelText = Instance.new("TextLabel")
LevelText.Size = UDim2.new(0, 120, 1, 0)
LevelText.Position = UDim2.new(1, -135, 0, 0)
LevelText.BackgroundTransparency = 1
LevelText.Text = "Level: " .. GetPlayerLevel()
LevelText.TextColor3 = Color3.fromRGB(255, 255, 255)
LevelText.TextScaled = true
LevelText.Font = Enum.Font.GothamBold
LevelText.Parent = TitleBar

-- Kapatma butonu
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 45, 1, 0)
CloseButton.Position = UDim2.new(1, -45, 0, 0)
CloseButton.Backgrou
