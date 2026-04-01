--[[
    KOPUSHUB v3.0 - Blox Fruits Ultimate Script
    - Havada uçuş + saldırı (ölmezsin)
    - Kill Aura düzeltildi
    - Auto Quest seviyeye göre çalışır
    - Melee otomatik equip
    - Çakışma sorunu çözüldü
    - Kaliteli GUI
--]]

-- ==================== BAŞLANGIÇ ====================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

-- ==================== AYARLAR ====================
local Settings = {
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    Flight = false,
    FarmMode = "Fly", -- Fly, Ground
    AttackRange = 20,
    AttackSpeed = 0.25,
    SafeHeight = 30, -- Uçuş yüksekliği
}

-- ==================== SEVİYE SİSTEMİ ====================
local LevelData = {
    {Min = 1, Max = 30, NPC = "Bandit", QuestGiver = "Bandit Quest Giver", Location = "Pirate Village", Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", QuestGiver = "Monkey Quest Giver", Location = "Jungle", Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Viking", QuestGiver = "Viking Quest Giver", Location = "Desert", Pos = Vector3.new(1200, 5, 1400)},
    {Min = 90, Max = 120, NPC = "Pirate", QuestGiver = "Pirate Quest Giver", Location = "Desert", Pos = Vector3.new(1100, 5, 1300)},
    {Min = 120, Max = 150, NPC = "Brute", QuestGiver = "Brute Quest Giver", Location = "Marine Fortress", Pos = Vector3.new(-2500, 10, -500)},
    {Min = 150, Max = 200, NPC = "Desert Soldier", QuestGiver = "Desert Soldier Quest Giver", Location = "Desert", Pos = Vector3.new(950, 5, 1200)},
    {Min = 200, Max = 250, NPC = "Snow Bandit", QuestGiver = "Snow Bandit Quest Giver", Location = "Snow Mountain", Pos = Vector3.new(-500, 80, -1300)},
    {Min = 250, Max = 300, NPC = "Chief Petty Officer", QuestGiver = "Chief Petty Officer Quest Giver", Location = "Marine Fortress", Pos = Vector3.new(-2400, 10, -600)},
    {Min = 300, Max = 350, NPC = "Sea Soldier", QuestGiver = "Sea Soldier Quest Giver", Location = "Frozen Village", Pos = Vector3.new(1100, 20, -1800)},
    {Min = 350, Max = 400, NPC = "Magma Ninja", QuestGiver = "Magma Ninja Quest Giver", Location = "Magma Village", Pos = Vector3.new(-500, 70, 1200)},
    {Min = 400, Max = 450, NPC = "Ship Deckhand", QuestGiver = "Ship Deckhand Quest Giver", Location = "Pirate Village", Pos = Vector3.new(-1100, 15, 500)},
    {Min = 450, Max = 500, NPC = "Prisoner", QuestGiver = "Prisoner Quest Giver", Location = "Prison", Pos = Vector3.new(4500, 10, -800)},
    {Min = 500, Max = 550, NPC = "Dangerous Prisoner", QuestGiver = "Dangerous Prisoner Quest Giver", Location = "Prison", Pos = Vector3.new(4700, 10, -900)},
    {Min = 550, Max = 600, NPC = "Military Soldier", QuestGiver = "Military Soldier Quest Giver", Location = "Marine Base", Pos = Vector3.new(-2700, 20, 2000)},
    {Min = 600, Max = 650, NPC = "Military Spy", QuestGiver = "Military Spy Quest Giver", Location = "Marine Base", Pos = Vector3.new(-2800, 20, 2100)},
    {Min = 650, Max = 700, NPC = "Diamond", QuestGiver = "Diamond Quest Giver", Location = "Green Zone", Pos = Vector3.new(-1800, 25, 2800)},
    {Min = 700, Max = 750, NPC = "Zombie", QuestGiver = "Zombie Quest Giver", Location = "Graveyard", Pos = Vector3.new(-150, 20, -500)},
    {Min = 750, Max = 800, NPC = "Vampire", QuestGiver = "Vampire Quest Giver", Location = "Graveyard", Pos = Vector3.new(-200, 20, -550)},
    {Min = 800, Max = 850, NPC = "Snow Trooper", QuestGiver = "Snow Trooper Quest Giver", Location = "Snow Mountain", Pos = Vector3.new(-600, 80, -1450)},
    {Min = 850, Max = 900, NPC = "Winter Warrior", QuestGiver = "Winter Warrior Quest Giver", Location = "Snow Mountain", Pos = Vector3.new(-650, 85, -1500)},
    {Min = 900, Max = 950, NPC = "Lab Subordinate", QuestGiver = "Lab Subordinate Quest Giver", Location = "Factory", Pos = Vector3.new(-100, 30, -100)},
    {Min = 950, Max = 1000, NPC = "Horned Warrior", QuestGiver = "Horned Warrior Quest Giver", Location = "Factory", Pos = Vector3.new(-150, 30, -150)},
    {Min = 1000, Max = 1100, NPC = "God's Guard", QuestGiver = "God's Guard Quest Giver", Location = "Sky Islands", Pos = Vector3.new(-3000, 300, -3000)},
    {Min = 1100, Max = 1200, NPC = "Paladin", QuestGiver = "Paladin Quest Giver", Location = "Sky Islands", Pos = Vector3.new(-3200, 300, -3200)},
    {Min = 1200, Max = 1300, NPC = "Conjured Coconut", QuestGiver = "Conjured Coconut Quest Giver", Location = "Cake Land", Pos = Vector3.new(-1800, 100, 1500)},
    {Min = 1300, Max = 1400, NPC = "Infantry Soldier", QuestGiver = "Infantry Soldier Quest Giver", Location = "Cake Land", Pos = Vector3.new(-1900, 100, 1600)},
    {Min = 1400, Max = 1500, NPC = "Archer", QuestGiver = "Archer Quest Giver", Location = "Cake Land", Pos = Vector3.new(-2000, 100, 1700)},
    {Min = 1500, Max = 1600, NPC = "Pistol Billionaire", QuestGiver = "Pistol Billionaire Quest Giver", Location = "Port Town", Pos = Vector3.new(2800, 20, -800)},
    {Min = 1600, Max = 1700, NPC = "Cannon Billionaire", QuestGiver = "Cannon Billionaire Quest Giver", Location = "Port Town", Pos = Vector3.new(2900, 20, -900)},
    {Min = 1700, Max = 1800, NPC = "Electric God", QuestGiver = "Electric God Quest Giver", Location = "Great Tree", Pos = Vector3.new(3500, 200, -2000)},
    {Min = 1800, Max = 1900, NPC = "Thunder God", QuestGiver = "Thunder God Quest Giver", Location = "Great Tree", Pos = Vector3.new(3600, 200, -2100)},
    {Min = 1900, Max = 2000, NPC = "Dragon Crew Warrior", QuestGiver = "Dragon Crew Warrior Quest Giver", Location = "Hydra Island", Pos = Vector3.new(5000, 50, -3000)},
    {Min = 2000, Max = 2100, NPC = "Dragon Crew Archer", QuestGiver = "Dragon Crew Archer Quest Giver", Location = "Hydra Island", Pos = Vector3.new(5100, 50, -3100)},
    {Min = 2100, Max = 2200, NPC = "Female Pirate", QuestGiver = "Female Pirate Quest Giver", Location = "Port Town", Pos = Vector3.new(2700, 20, -700)},
    {Min = 2200, Max = 2300, NPC = "Giant Pirate", QuestGiver = "Giant Pirate Quest Giver", Location = "Port Town", Pos = Vector3.new(2600, 20, -600)},
    {Min = 2300, Max = 2400, NPC = "Marine Captain", QuestGiver = "Marine Captain Quest Giver", Location = "Marine Base", Pos = Vector3.new(-2900, 20, 2200)},
    {Min = 2400, Max = 2500, NPC = "Marine Commodore", QuestGiver = "Marine Commodore Quest Giver", Location = "Marine Base", Pos = Vector3.new(-3000, 20, 2300)},
}

-- ==================== YARDIMCI FONKSİYONLAR ====================
local function GetChar()
    Character = Player.Character or Player.CharacterAdded:Wait()
    return Character
end

local function GetHRP()
    local char = GetChar()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetChar()
    return char:FindFirstChild("Humanoid")
end

local function GetLevel()
    return Player.Data.Level.Value
end

local function GetCurrentZone()
    local level = GetLevel()
    for _, data in ipairs(LevelData) do
        if level >= data.Min and level <= data.Max then
            return data
        end
    end
    return LevelData[1]
end

-- ==================== MELEE EQUIP ====================
local function EquipMelee()
    local args = {
        [1] = "Melee"
    }
    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
end

-- ==================== UÇUŞ + SALDIRI ====================
local currentTarget = nil
local isAttacking = false

local function MoveToTarget(targetPos)
    local hrp = GetHRP()
    if not hrp then return end
    
    if Settings.Flight then
        -- Havada uçarak git
        local targetCFrame = CFrame.new(targetPos) + Vector3.new(0, Settings.SafeHeight, 0)
        local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    else
        -- Yerde yürü
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid:MoveTo(targetPos)
        end
    end
end

local function Attack(npc)
    if isAttacking then return end
    isAttacking = true
    
    local hrp = GetHRP()
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not hrp or not npcRoot then 
        isAttacking = false
        return 
    end
    
    -- Havada NPC'nin üstünde dur
    if Settings.Flight then
        local flyPos = npcRoot.Position + Vector3.new(0, Settings.SafeHeight, 0)
        hrp.CFrame = CFrame.new(flyPos, npcRoot.Position)
    else
        hrp.CFrame = CFrame.new(hrp.Position, npcRoot.Position)
    end
    
    -- Saldır
    wait(0.05)
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.1)
    VirtualInput:SendKeyEvent(false, "E", false, game)
    
    wait(Settings.AttackSpeed)
    isAttacking = false
end

local function GetNearestNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    
    local zone = GetCurrentZone()
    local targetName = zone.NPC
    
    local closest = nil
    local closestDist = math.huge
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local npcName = npc.Name
            if string.find(npcName, targetName) or targetName == "Nearest" then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local dist = (hrp.Position - npcRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = npc
                    end
                end
            end
        end
    end
    
    return closest
end

-- ==================== QUEST SİSTEMİ (Seviyeye Göre) ====================
local function HandleQuest()
    if not Settings.AutoQuest then return end
    
    local zone = GetCurrentZone()
    local questFrame = Player.PlayerGui:FindFirstChild("Quest")
    
    -- Quest tamamlama
    if questFrame then
        local complete = questFrame:FindFirstChild("Complete")
        if complete and complete.Visible then
            VirtualInput:SendKeyEvent(true, "E", false, game)
            wait(0.2)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            wait(0.5)
        end
        return
    end
    
    -- Quest alma
    local questGiverName = zone.QuestGiver
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == questGiverName then
            local hrp = GetHRP()
            if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude > 10 then
                MoveToTarget(npc.HumanoidRootPart.Position)
            end
            wait(0.3)
            VirtualInput:SendKeyEvent(true, "E", false, game)
            wait(0.2)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            wait(0.5)
            break
        end
    end
end

-- ==================== KARAKTERİ HAVADA TUT ====================
local function FlightControl()
    if not Settings.Flight then 
        local humanoid = GetHumanoid()
        if humanoid then humanoid.PlatformStand = false end
        return 
    end
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    humanoid.PlatformStand = true
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    -- Havada kal
    if hrp.Position.Y < Settings.SafeHeight then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ==================== ANA DÖNGÜ ====================
-- Uçuş döngüsü
spawn(function()
    while wait(0.05) do
        FlightControl()
    end
end)

-- Auto Farm + Kill Aura döngüsü
spawn(function()
    while wait(0.1) do
        if not Settings.AutoFarm and not Settings.KillAura then
            wait(0.5)
            continue
        end
        
        local humanoid = GetHumanoid()
        if not humanoid or humanoid.Health <= 0 then
            wait(2)
            continue
        end
        
        -- Melee equip kontrolü
        EquipMelee()
        
        -- Quest
        if Settings.AutoFarm and Settings.AutoQuest then
            HandleQuest()
        end
        
        -- NPC bul
        local target = GetNearestNPC()
        
        if target then
            currentTarget = target
            local npcRoot = target:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                -- Uçuş ile yaklaş
                if Settings.Flight then
                    local flyPos = npcRoot.Position + Vector3.new(0, Settings.SafeHeight, 0)
                    local hrp = GetHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(flyPos, npcRoot.Position)
                    end
                else
                    MoveToTarget(npcRoot.Position)
                end
                
                -- Saldır
                Attack(target)
            end
        else
            -- NPC yoksa bölgeye git
            local zone = GetCurrentZone()
            if zone and (GetHRP() and (GetHRP().Position - zone.Pos).Magnitude > 50) then
                MoveToTarget(zone.Pos)
            end
            wait(0.5)
        end
    end
end)

-- ==================== GUI (MODERN) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHub"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 20)
Corner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 KOPUSHUB v3.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LevelLabel = Instance.new("TextLabel")
LevelLabel.Size = UDim2.new(0, 150, 1, 0)
LevelLabel.Position = UDim2.new(1, -170, 0, 0)
LevelLabel.BackgroundTransparency = 1
LevelLabel.Text = "Level: " .. GetLevel()
LevelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LevelLabel.TextScaled = true
LevelLabel.Font = Enum.Font.GothamBold
LevelLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 1, 0)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- İçerik
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- GUI Bileşenleri
local function AddSection(text)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.94, 0, 0, 40)
    section.Position = UDim2.new(0.03, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(255, 80, 45)
    section.Text = text
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.TextScaled = true
    section.Font = Enum.Font.GothamBold
    section.BorderSizePixel = 0
    
    local secCorner = Instance.new("UICorner")
    secCorner.CornerRadius = UDim.new(0, 12)
    secCorner.Parent = section
    
    section.Parent = Content
    return section
end

local function AddToggle(text, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 55)
    container.Position = UDim2.new(0.03, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 12)
    contCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 45)
    btn.Position = UDim2.new(0.85, -90, 0.5, -22.5)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
    btn.Text = getter() and "AÇIK" or "KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
        btn.Text = newVal and "AÇIK" or "KAPALI"
    end)
    
    container.Parent = Content
    return container
end

local function AddSlider(text, minVal, maxVal, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 80)
    container.Position = UDim2.new(0.03, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 12)
    contCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. getter()
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 35)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 18)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 45)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 18)
    fillCorner.Parent = fill
    
    local dragging = false
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local val = minVal + (maxVal - minVal) * percent
            val = math.floor(val)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local val = minVal + (maxVal - minVal) * percent
            val = math.floor(val)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    container.Parent = Content
    return container
end

-- ==================== GUI İÇERİĞİ ====================
AddSection("🤖 AUTO FARM")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)
AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)

AddSection("🌀 HAREKET")
AddToggle("Uçuş Modu (Havada Kal)", function() return Settings.Flight end, function(v) Settings.Flight = v end)
AddSlider("Uçuş Yüksekliği", 15, 50, function() return Settings.SafeHeight end, function(v) Settings.SafeHeight = v end)

AddSection("⚔️ KOMBAT")
AddSlider("Saldırı Mesafesi", 10, 35, function() return Settings.AttackRange end, function(v) Settings.AttackRange = v end)
AddSlider("Saldırı Hızı (saniye)", 0.1, 0.8, function() return Settings.AttackSpeed end, function(v) Settings.AttackSpeed = v end)

AddSection("ℹ️ BİLGİ")
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(0.94, 0, 0, 150)
Info.Position = UDim2.new(0.03, 0, 0, 0)
Info.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
Info.Text = "🔥 KOPUSHUB v3.0\n\n✅ Auto Farm: NPC keser\n✅ Auto Quest: Seviyene göre quest alır\n✅ Kill Aura: Etrafa otomatik saldırı\n✅ Uçuş Modu: Havada kal, ölmezsin!\n✅ Melee otomatik equip\n\n⚠️ Yedek hesap kullan!\n📌 Insert tuşu ile GUI aç/kapat"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextScaled = true
Info.TextWrapped = true
Info.Font = Enum.Font.Gotham

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 12)
infoCorner.Parent = Info

Info.Parent = Content

-- Canvas güncelleme
Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

-- Level güncelleme
spawn(function()
    while wait(1) do
        LevelLabel.Text = "Level: " .. GetLevel()
        local zone = GetCurrentZone()
        if zone and Settings.AutoFarm then
            -- Status güncelleme yapılabilir
        end
    end
end)

-- Kapatma
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Insert tuşu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Başlangıç bildirimi
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "KopusHub v3.0",
    Text = "Script yüklendi! Insert ile GUI açılır. Uçuş modunu açmayı unutma!",
    Duration = 5
})

print("========================================")
print("🔥 KOPUSHUB v3.0 YÜKLENDİ!")
print("✅ Auto Farm + Uçuş + Kill Aura + Auto Quest")
print("✅ Uçuş modu açıkken havada vurursun, ölmezsin!")
print("✅ Melee otomatik equip edilir")
print("📌 Insert tuşu ile GUI açılır")
print("========================================")
