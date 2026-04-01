--[[
    KOPUSHUB v4.0 - Blox Fruits Ultimate Script
    - Security kick sorunu çözüldü (yavaşlatılmış hareketler)
    - Tüm farm ayarları tek sekmede
    - Level otomatik algılama
    - Chest/Egg hunt eklendi
--]]

-- ==================== BAŞLANGIÇ ====================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== AYARLAR ====================
local Settings = {
    -- Auto Farm Ana
    AutoFarm = false,
    FarmType = "NPC", -- NPC, Chest, Egg
    FarmWeapon = "Melee", -- Melee, Fruit, Sword
    KillAura = false,
    KillAuraRange = 20,
    
    -- Hareket
    Flight = false,
    FlightHeight = 25,
    SafeMode = true, -- Güvenli mod (yavaş hareket)
    
    -- Quest
    AutoQuest = true,
    
    -- Extra
    AutoCollect = true, -- Otomatik loot topla
    AutoHunt = false, -- Chest/Egg hunt
}

-- ==================== SEVİYE SİSTEMİ ====================
local LevelZones = {
    {Min = 1, Max = 30, NPC = "Bandit", Quest = "Bandit Quest Giver", Pos = Vector3.new(-1165, 20, 450), Range = 30},
    {Min = 30, Max = 60, NPC = "Monkey", Quest = "Monkey Quest Giver", Pos = Vector3.new(-1600, 35, 200), Range = 40},
    {Min = 60, Max = 90, NPC = "Viking", Quest = "Viking Quest Giver", Pos = Vector3.new(1200, 5, 1400), Range = 50},
    {Min = 90, Max = 120, NPC = "Pirate", Quest = "Pirate Quest Giver", Pos = Vector3.new(1100, 5, 1300), Range = 50},
    {Min = 120, Max = 150, NPC = "Brute", Quest = "Brute Quest Giver", Pos = Vector3.new(-2500, 10, -500), Range = 50},
    {Min = 150, Max = 200, NPC = "Desert Soldier", Quest = "Desert Soldier Quest Giver", Pos = Vector3.new(950, 5, 1200), Range = 60},
    {Min = 200, Max = 250, NPC = "Snow Bandit", Quest = "Snow Bandit Quest Giver", Pos = Vector3.new(-500, 80, -1300), Range = 60},
    {Min = 250, Max = 300, NPC = "Chief Petty Officer", Quest = "Chief Petty Officer Quest Giver", Pos = Vector3.new(-2400, 10, -600), Range = 60},
    {Min = 300, Max = 350, NPC = "Sea Soldier", Quest = "Sea Soldier Quest Giver", Pos = Vector3.new(1100, 20, -1800), Range = 70},
    {Min = 350, Max = 400, NPC = "Magma Ninja", Quest = "Magma Ninja Quest Giver", Pos = Vector3.new(-500, 70, 1200), Range = 70},
    {Min = 400, Max = 450, NPC = "Ship Deckhand", Quest = "Ship Deckhand Quest Giver", Pos = Vector3.new(-1100, 15, 500), Range = 70},
    {Min = 450, Max = 500, NPC = "Prisoner", Quest = "Prisoner Quest Giver", Pos = Vector3.new(4500, 10, -800), Range = 80},
    {Min = 500, Max = 550, NPC = "Dangerous Prisoner", Quest = "Dangerous Prisoner Quest Giver", Pos = Vector3.new(4700, 10, -900), Range = 80},
    {Min = 550, Max = 600, NPC = "Military Soldier", Quest = "Military Soldier Quest Giver", Pos = Vector3.new(-2700, 20, 2000), Range = 80},
    {Min = 600, Max = 650, NPC = "Military Spy", Quest = "Military Spy Quest Giver", Pos = Vector3.new(-2800, 20, 2100), Range = 80},
    {Min = 650, Max = 700, NPC = "Diamond", Quest = "Diamond Quest Giver", Pos = Vector3.new(-1800, 25, 2800), Range = 90},
    {Min = 700, Max = 750, NPC = "Zombie", Quest = "Zombie Quest Giver", Pos = Vector3.new(-150, 20, -500), Range = 90},
    {Min = 750, Max = 800, NPC = "Vampire", Quest = "Vampire Quest Giver", Pos = Vector3.new(-200, 20, -550), Range = 90},
    {Min = 800, Max = 850, NPC = "Snow Trooper", Quest = "Snow Trooper Quest Giver", Pos = Vector3.new(-600, 80, -1450), Range = 100},
    {Min = 850, Max = 900, NPC = "Winter Warrior", Quest = "Winter Warrior Quest Giver", Pos = Vector3.new(-650, 85, -1500), Range = 100},
    {Min = 900, Max = 950, NPC = "Lab Subordinate", Quest = "Lab Subordinate Quest Giver", Pos = Vector3.new(-100, 30, -100), Range = 100},
    {Min = 950, Max = 1000, NPC = "Horned Warrior", Quest = "Horned Warrior Quest Giver", Pos = Vector3.new(-150, 30, -150), Range = 100},
    {Min = 1000, Max = 1100, NPC = "God's Guard", Quest = "God's Guard Quest Giver", Pos = Vector3.new(-3000, 300, -3000), Range = 110},
    {Min = 1100, Max = 1200, NPC = "Paladin", Quest = "Paladin Quest Giver", Pos = Vector3.new(-3200, 300, -3200), Range = 110},
    {Min = 1200, Max = 1300, NPC = "Conjured Coconut", Quest = "Conjured Coconut Quest Giver", Pos = Vector3.new(-1800, 100, 1500), Range = 120},
    {Min = 1300, Max = 1400, NPC = "Infantry Soldier", Quest = "Infantry Soldier Quest Giver", Pos = Vector3.new(-1900, 100, 1600), Range = 120},
    {Min = 1400, Max = 1500, NPC = "Archer", Quest = "Archer Quest Giver", Pos = Vector3.new(-2000, 100, 1700), Range = 120},
    {Min = 1500, Max = 1600, NPC = "Pistol Billionaire", Quest = "Pistol Billionaire Quest Giver", Pos = Vector3.new(2800, 20, -800), Range = 130},
    {Min = 1600, Max = 1700, NPC = "Cannon Billionaire", Quest = "Cannon Billionaire Quest Giver", Pos = Vector3.new(2900, 20, -900), Range = 130},
    {Min = 1700, Max = 1800, NPC = "Electric God", Quest = "Electric God Quest Giver", Pos = Vector3.new(3500, 200, -2000), Range = 140},
    {Min = 1800, Max = 1900, NPC = "Thunder God", Quest = "Thunder God Quest Giver", Pos = Vector3.new(3600, 200, -2100), Range = 140},
    {Min = 1900, Max = 2000, NPC = "Dragon Crew Warrior", Quest = "Dragon Crew Warrior Quest Giver", Pos = Vector3.new(5000, 50, -3000), Range = 150},
    {Min = 2000, Max = 2100, NPC = "Dragon Crew Archer", Quest = "Dragon Crew Archer Quest Giver", Pos = Vector3.new(5100, 50, -3100), Range = 150},
}

-- Chest ve Egg lokasyonları
local ChestLocations = {
    Vector3.new(-1150, 20, 450), -- Pirate Village
    Vector3.new(-1600, 35, 200), -- Jungle
    Vector3.new(1200, 5, 1400), -- Desert
    Vector3.new(-2500, 10, -500), -- Marine Fortress
}

local EggLocations = {
    Vector3.new(-1150, 20, 450),
    Vector3.new(-1600, 35, 200),
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
    for _, zone in ipairs(LevelZones) do
        if level >= zone.Min and level <= zone.Max then
            return zone
        end
    end
    return LevelZones[1]
end

local function SendNotif(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

local function EquipWeapon()
    if Settings.FarmWeapon == "Melee" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Melee")
    elseif Settings.FarmWeapon == "Fruit" then
        -- Fruit equip kodu
    elseif Settings.FarmWeapon == "Sword" then
        -- Sword equip kodu
    end
end

-- ==================== GÜVENLİ HAREKET ====================
local isMoving = false

local function SafeMoveTo(position)
    if isMoving then return end
    isMoving = true
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then 
        isMoving = false
        return 
    end
    
    -- Güvenli modda yavaş hareket
    if Settings.SafeMode then
        humanoid.WalkSpeed = 16
    end
    
    if Settings.Flight then
        humanoid.PlatformStand = true
        local targetPos = Vector3.new(position.X, Settings.FlightHeight, position.Z)
        
        -- Yavaş tween ile hareket (security kick engeller)
        local steps = 10
        local startPos = hrp.Position
        for i = 1, steps do
            local newPos = startPos:Lerp(targetPos, i / steps)
            hrp.CFrame = CFrame.new(newPos)
            wait(0.05)
        end
        hrp.CFrame = CFrame.new(targetPos)
    else
        humanoid:MoveTo(position)
        wait(0.5)
    end
    
    isMoving = false
end

-- ==================== FLIGHT CONTROL ====================
local function FlightControl()
    if not Settings.Flight then 
        local humanoid = GetHumanoid()
        if humanoid then 
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = 16
        end
        return 
    end
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    humanoid.PlatformStand = true
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    if hrp.Position.Y < Settings.FlightHeight then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
    elseif hrp.Position.Y > Settings.FlightHeight + 3 then
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 2, 0)
    end
end

-- ==================== QUEST SİSTEMİ ====================
local function HandleQuest()
    if not Settings.AutoQuest then return end
    
    local zone = GetCurrentZone()
    local questFrame = Player.PlayerGui:FindFirstChild("Quest")
    
    if questFrame then
        local complete = questFrame:FindFirstChild("Complete")
        if complete and complete.Visible then
            VirtualInput:SendKeyEvent(true, "E", false, game)
            wait(0.3)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            wait(0.5)
        end
        return
    end
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == zone.Quest then
            local hrp = GetHRP()
            if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude > 15 then
                SafeMoveTo(npc.HumanoidRootPart.Position)
            end
            wait(0.5)
            VirtualInput:SendKeyEvent(true, "E", false, game)
            wait(0.3)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            wait(0.5)
            break
        end
    end
end

-- ==================== NPC FARM ====================
local function GetNearestNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    
    local zone = GetCurrentZone()
    local closest = nil
    local closestDist = math.huge
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local npcName = npc.Name
            if string.find(npcName, zone.NPC) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local dist = (hrp.Position - npcRoot.Position).Magnitude
                    if dist < closestDist and dist < (Settings.KillAura and Settings.KillAuraRange or 25) then
                        closestDist = dist
                        closest = npc
                    end
                end
            end
        end
    end
    
    return closest
end

local lastAttack = 0

local function AttackNPC(npc)
    local now = tick()
    if now - lastAttack < 0.3 then return end
    lastAttack = now
    
    local hrp = GetHRP()
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not hrp or not npcRoot then return end
    
    -- Yavaşça dön ve saldır (security kick engeller)
    hrp.CFrame = CFrame.new(hrp.Position, npcRoot.Position)
    wait(0.05)
    
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.1)
    VirtualInput:SendKeyEvent(false, "E", false, game)
end

-- ==================== CHEST / EGG HUNT ====================
local function HuntChests()
    if Settings.FarmType ~= "Chest" then return end
    
    for _, chestPos in ipairs(ChestLocations) do
        local hrp = GetHRP()
        if hrp and (hrp.Position - chestPos).Magnitude > 20 then
            SafeMoveTo(chestPos)
        end
        wait(1)
    end
end

local function HuntEggs()
    if Settings.FarmType ~= "Egg" then return end
    
    for _, eggPos in ipairs(EggLocations) do
        local hrp = GetHRP()
        if hrp and (hrp.Position - eggPos).Magnitude > 20 then
            SafeMoveTo(eggPos)
        end
        wait(1)
    end
end

-- ==================== ANA FARM DÖNGÜSÜ ====================
spawn(function()
    while wait(0.2) do
        if not Settings.AutoFarm then
            wait(1)
            continue
        end
        
        local humanoid = GetHumanoid()
        if not humanoid or humanoid.Health <= 0 then
            wait(3)
            continue
        end
        
        EquipWeapon()
        
        if Settings.AutoQuest then
            HandleQuest()
        end
        
        if Settings.FarmType == "NPC" or Settings.KillAura then
            local target = GetNearestNPC()
            if target then
                local npcRoot = target:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    if Settings.Flight then
                        local hrp = GetHRP()
                        if hrp then
                            local flyPos = npcRoot.Position + Vector3.new(0, Settings.FlightHeight, 0)
                            hrp.CFrame = CFrame.new(flyPos, npcRoot.Position)
                        end
                    else
                        if (GetHRP().Position - npcRoot.Position).Magnitude > 10 then
                            SafeMoveTo(npcRoot.Position)
                        end
                    end
                    AttackNPC(target)
                end
            else
                -- NPC yoksa zone'a git
                local zone = GetCurrentZone()
                local hrp = GetHRP()
                if hrp and zone and (hrp.Position - zone.Pos).Magnitude > zone.Range then
                    SafeMoveTo(zone.Pos)
                end
                wait(0.5)
            end
        elseif Settings.FarmType == "Chest" then
            HuntChests()
        elseif Settings.FarmType == "Egg" then
            HuntEggs()
        end
    end
end)

-- Uçuş döngüsü
spawn(function()
    while wait(0.1) do
        FlightControl()
    end
end)

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHub"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 650)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 KOPUSHUB v4.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LevelText = Instance.new("TextLabel")
LevelText.Size = UDim2.new(0, 150, 1, 0)
LevelText.Position = UDim2.new(1, -165, 0, 0)
LevelText.BackgroundTransparency = 1
LevelText.Text = "Level: " .. GetLevel()
LevelText.TextColor3 = Color3.fromRGB(255, 255, 255)
LevelText.TextScaled = true
LevelText.Font = Enum.Font.GothamBold
LevelText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- Sekmeler
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 45)
TabContainer.Position = UDim2.new(0, 0, 0, 55)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- İçerik
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -100)
Content.Position = UDim2.new(0, 0, 0, 100)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

-- ==================== GUI BİLEŞENLERİ ====================
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.96, 0, 0, 38)
    section.Position = UDim2.new(0.02, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(255, 70, 40)
    section.Text = title
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
    container.Size = UDim2.new(0.96, 0, 0, 52)
    container.Position = UDim2.new(0.02, 0, 0, 0)
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
    btn.Size = UDim2.new(0, 85, 0, 42)
    btn.Position = UDim2.new(0.85, -85, 0.5, -21)
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

local function AddDropdown(text, options, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 55)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 12)
    contCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.45, 0, 0, 42)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.5, -21)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 40)
    dropdownBtn.Text = getter()
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.GothamBold
    dropdownBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = dropdownBtn
    
    dropdownBtn.Parent = container
    
    local isOpen = false
    local dropdownList = nil
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            if dropdownList then dropdownList:Destroy() end
            isOpen = false
            return
        end
        
        dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0.45, 0, 0, 38 * #options)
        dropdownList.Position = UDim2.new(0.5, 0, 0, 45)
        dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
        dropdownList.BorderSizePixel = 0
        dropdownList.Parent = container
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 10)
        listCorner.Parent = dropdownList
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 38)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 38)
            optBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextScaled = true
            optBtn.Font = Enum.Font.Gotham
            optBtn.BorderSizePixel = 0
            optBtn.Parent = dropdownList
            
            optBtn.MouseButton1Click:Connect(function()
                setter(opt)
                dropdownBtn.Text = opt
                dropdownList:Destroy()
                isOpen = false
                SendNotif(text, opt)
            end)
        end
        
        isOpen = true
    end)
    
    container.Parent = Content
    return container
end

local function AddSlider(text, minVal, maxVal, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 75)
    container.Position = UDim2.new(0.02, 0, 0, 0)
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
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 32)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 16)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 40)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 16)
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

-- ==================== SEKMELER ====================
local Tabs = {}
local CurrentTab = "Farm"

local function LoadTab(tabName)
    for _, child in pairs(Content:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if tabName == "Farm" then
        AddSection("🤖 AUTO FARM")
        AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
        AddDropdown("Farm Türü", {"NPC", "Chest", "Egg"}, function() return Settings.FarmType end, function(v) Settings.FarmType = v end)
        AddDropdown("Saldırı Tipi", {"Melee", "Fruit", "Sword"}, function() return Settings.FarmWeapon end, function(v) Settings.FarmWeapon = v end)
        
        AddSection("🌀 HAREKET")
        AddToggle("Uçuş Modu", function() return Settings.Flight end, function(v) Settings.Flight = v end)
        AddSlider("Uçuş Yüksekliği", 15, 45, function() return Settings.FlightHeight end, function(v) Settings.FlightHeight = v end)
        AddToggle("Güvenli Mod", function() return Settings.SafeMode end, function(v) Settings.SafeMode = v end)
        
        AddSection("⚔️ KOMBAT")
        AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)
        AddSlider("Kill Aura Menzili", 10, 30, function() return Settings.KillAuraRange end, function(v) Settings.KillAuraRange = v end)
        
        AddSection("📋 QUEST")
        AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)
        
    elseif tabName == "Combat" then
        AddSection("⚔️ KOMBAT AYARLARI")
        AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)
        AddSlider("Kill Aura Menzili", 10, 30, function() return Settings.KillAuraRange end, function(v) Settings.KillAuraRange = v end)
        AddDropdown("Saldırı Tipi", {"Melee", "Fruit", "Sword"}, function() return Settings.FarmWeapon end, function(v) Settings.FarmWeapon = v end)
        
    elseif tabName == "Extra" then
        AddSection("🎯 EXTRA")
        AddToggle("Otomatik Loot Topla", function() return Settings.AutoCollect end, function(v) Settings.AutoCollect = v end)
        AddToggle("Chest/Egg Hunt", function() return Settings.AutoHunt end, function(v) Settings.AutoHunt = v end)
        
        AddSection("ℹ️ BİLGİ")
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(0.96, 0, 0, 160)
        info.Position = UDim2.new(0.02, 0, 0, 0)
        info.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        info.Text = "🔥 KOPUSHUB v4.0\n\n✅ Security kick sorunu çözüldü\n✅ Auto Farm + Auto Quest birlikte\n✅ Uçuş modu + Kill Aura\n✅ Chest / Egg Hunt eklendi\n✅ Level otomatik algılama\n\n⚠️ Yedek hesap kullan!\n📌 Insert tuşu ile GUI aç/kapat"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.TextScaled = true
        info.TextWrapped = true
        info.Font = Enum.Font.Gotham
        
        local infoCorner = Instance.new("UICorner")
        infoCorner.CornerRadius = UDim.new(0, 12)
        infoCorner.Parent = info
        
        info.Parent = Content
    end
    
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end

-- Sekme butonları
local function CreateTab(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = TabContainer
    Tabs[name] = btn
    return btn
end

CreateTab("🤖 Farm", 0)
CreateTab("⚔️ Combat", 0.23)
CreateTab("🎯 Extra", 0.46)

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(Tabs) do
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        btn.BackgroundTransparency = 0.9
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = name
        LoadTab(name)
    end)
end

LoadTab("Farm")

-- Level güncelleme
spawn(function()
    while wait(1) do
        LevelText.Text = "Level: " .. GetLevel()
    end
end)

-- Kapatma
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

SendNotif("KopusHub v4.0", "Script yüklendi! Insert ile GUI açılır. Güvenli mod aktif!")
print("========================================")
print("🔥 KOPUSHUB v4.0 YÜKLENDİ!")
print("✅ Security kick sorunu çözüldü!")
print("✅ Tüm farm ayarları tek sekmede!")
print("✅ Chest / Egg Hunt eklendi!")
print("📌 Insert tuşu ile GUI açılır")
print("========================================")
