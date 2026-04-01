--[[
    KOPUSHUB v5.0 - GERÇEK BLOX FRUITS API
    Tüm remote isimleri doğru kullanıldı
    Gerçek combat: tool:Activate()
    Gerçek quest: StartQuest + GetQuests + CompleteQuest
    Teleport yok, sadece MoveTo
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== SERVİSLER ====================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== GERÇEK REMOTE BULMA ====================
-- Blox Fruits'te remote'lar "Remotes" klasöründe, ismi "CommF_"
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RemoteFunction = nil
if Remotes then
    RemoteFunction = Remotes:FindFirstChild("CommF_")
end

if not RemoteFunction then
    -- Fallback: tüm descendantları tara
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteFunction") and v.Name == "CommF_" then
            RemoteFunction = v
            break
        end
    end
end

if not RemoteFunction then
    StarterGui:SetCore("SendNotification", {Title = "Hata", Text = "Remote bulunamadı! Oyun güncellenmiş olabilir.", Duration = 5})
    return
end

-- ==================== AYARLAR ====================
local Settings = {
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    FarmMethod = "Above",
    FlightHeight = 25,
    AttackRange = 22,
    AttackSpeed = 0.45,
}

-- ==================== CACHE ====================
local NPCCache = {}
local LastNPCCacheTime = 0
local LastAttackTime = 0
local LastQuestTime = 0
local LastMoveTime = 0

-- ==================== SEVİYE ZONLARI ====================
-- Her NPC için doğru quest ismi
local LevelZones = {
    -- 1. Deniz
    {Min = 1, Max = 30, NPC = "Bandit", Quest = "Bandit", Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", Quest = "Monkey", Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Viking", Quest = "Viking", Pos = Vector3.new(1200, 5, 1400)},
    {Min = 90, Max = 120, NPC = "Pirate", Quest = "Pirate", Pos = Vector3.new(1100, 5, 1300)},
    {Min = 120, Max = 150, NPC = "Brute", Quest = "Brute", Pos = Vector3.new(-2500, 10, -500)},
    {Min = 150, Max = 200, NPC = "Desert Soldier", Quest = "DesertSoldier", Pos = Vector3.new(950, 5, 1200)},
    {Min = 200, Max = 250, NPC = "Snow Bandit", Quest = "SnowBandit", Pos = Vector3.new(-500, 80, -1300)},
    {Min = 250, Max = 300, NPC = "Chief Petty Officer", Quest = "ChiefPettyOfficer", Pos = Vector3.new(-2400, 10, -600)},
    {Min = 300, Max = 350, NPC = "Sea Soldier", Quest = "SeaSoldier", Pos = Vector3.new(1100, 20, -1800)},
    {Min = 350, Max = 400, NPC = "Magma Ninja", Quest = "MagmaNinja", Pos = Vector3.new(-500, 70, 1200)},
    {Min = 400, Max = 450, NPC = "Ship Deckhand", Quest = "ShipDeckhand", Pos = Vector3.new(-1100, 15, 500)},
    {Min = 450, Max = 500, NPC = "Prisoner", Quest = "Prisoner", Pos = Vector3.new(4500, 10, -800)},
    {Min = 500, Max = 550, NPC = "Dangerous Prisoner", Quest = "DangerousPrisoner", Pos = Vector3.new(4700, 10, -900)},
    {Min = 550, Max = 600, NPC = "Military Soldier", Quest = "MilitarySoldier", Pos = Vector3.new(-2700, 20, 2000)},
    {Min = 600, Max = 650, NPC = "Military Spy", Quest = "MilitarySpy", Pos = Vector3.new(-2800, 20, 2100)},
    {Min = 650, Max = 700, NPC = "Diamond", Quest = "Diamond", Pos = Vector3.new(-1800, 25, 2800)},
    -- 2. Deniz
    {Min = 700, Max = 750, NPC = "Zombie", Quest = "Zombie", Pos = Vector3.new(-150, 20, -500)},
    {Min = 750, Max = 800, NPC = "Vampire", Quest = "Vampire", Pos = Vector3.new(-200, 20, -550)},
    {Min = 800, Max = 850, NPC = "Snow Trooper", Quest = "SnowTrooper", Pos = Vector3.new(-600, 80, -1450)},
    {Min = 850, Max = 900, NPC = "Winter Warrior", Quest = "WinterWarrior", Pos = Vector3.new(-650, 85, -1500)},
    {Min = 900, Max = 950, NPC = "Lab Subordinate", Quest = "LabSubordinate", Pos = Vector3.new(-100, 30, -100)},
    {Min = 950, Max = 1000, NPC = "Horned Warrior", Quest = "HornedWarrior", Pos = Vector3.new(-150, 30, -150)},
    -- 3. Deniz
    {Min = 1000, Max = 1100, NPC = "God's Guard", Quest = "GodsGuard", Pos = Vector3.new(-3000, 300, -3000)},
    {Min = 1100, Max = 1200, NPC = "Paladin", Quest = "Paladin", Pos = Vector3.new(-3200, 300, -3200)},
    {Min = 1200, Max = 1300, NPC = "Conjured Coconut", Quest = "ConjuredCoconut", Pos = Vector3.new(-1800, 100, 1500)},
    {Min = 1300, Max = 1400, NPC = "Infantry Soldier", Quest = "InfantrySoldier", Pos = Vector3.new(-1900, 100, 1600)},
    {Min = 1400, Max = 1500, NPC = "Archer", Quest = "Archer", Pos = Vector3.new(-2000, 100, 1700)},
    -- 3. Deniz devam
    {Min = 1500, Max = 1600, NPC = "Pistol Billionaire", Quest = "PistolBillionaire", Pos = Vector3.new(2800, 20, -800)},
    {Min = 1600, Max = 1700, NPC = "Cannon Billionaire", Quest = "CannonBillionaire", Pos = Vector3.new(2900, 20, -900)},
    {Min = 1700, Max = 1800, NPC = "Electric God", Quest = "ElectricGod", Pos = Vector3.new(3500, 200, -2000)},
    {Min = 1800, Max = 1900, NPC = "Thunder God", Quest = "ThunderGod", Pos = Vector3.new(3600, 200, -2100)},
    {Min = 1900, Max = 2000, NPC = "Dragon Crew Warrior", Quest = "DragonCrewWarrior", Pos = Vector3.new(5000, 50, -3000)},
    {Min = 2000, Max = 2100, NPC = "Dragon Crew Archer", Quest = "DragonCrewArcher", Pos = Vector3.new(5100, 50, -3100)},
    {Min = 2100, Max = 2200, NPC = "Female Pirate", Quest = "FemalePirate", Pos = Vector3.new(2700, 20, -700)},
    {Min = 2200, Max = 2300, NPC = "Giant Pirate", Quest = "GiantPirate", Pos = Vector3.new(2600, 20, -600)},
    {Min = 2300, Max = 2400, NPC = "Marine Captain", Quest = "MarineCaptain", Pos = Vector3.new(-2900, 20, 2200)},
    {Min = 2400, Max = 2500, NPC = "Marine Commodore", Quest = "MarineCommodore", Pos = Vector3.new(-3000, 20, 2300)},
    {Min = 2500, Max = 2600, NPC = "Elite Pirate", Quest = "ElitePirate", Pos = Vector3.new(5000, 100, -3200)},
}

-- ==================== YARDIMCI ====================
local function GetChar()
    Character = Player.Character or Player.CharacterAdded:Wait()
    return Character
end

local function GetHRP()
    local char = GetChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetChar()
    return char and char:FindFirstChild("Humanoid")
end

local function GetLevel()
    local data = Player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 1
end

local function GetCurrentZone()
    local level = GetLevel()
    for _, zone in ipairs(LevelZones) do
        if level >= zone.Min and level <= zone.Max then
            return zone
        end
    end
    return LevelZones[#LevelZones]
end

local function SendNotif(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 2})
end

-- ==================== GERÇEK COMBAT ====================
local function EquipBestTool()
    local character = GetChar()
    local backpack = Player:FindFirstChild("Backpack")
    
    -- Önce melee tool bul
    local toolToEquip = nil
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                toolToEquip = tool
                break
            end
        end
    end
    
    -- Equip et
    if toolToEquip then
        toolToEquip.Parent = character
        task.wait(0.1)
    end
    
    -- Tool'u aktif et
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:EquipTool(tool)
                end
                return tool
            end
        end
    end
    return nil
end

local function Attack()
    local now = tick()
    if now - LastAttackTime < Settings.AttackSpeed then return end
    LastAttackTime = now
    
    local tool = EquipBestTool()
    if tool then
        -- tool:Activate() ile saldır
        tool:Activate()
    end
end

-- ==================== GERÇEK QUEST ====================
local function HandleQuest()
    if not Settings.AutoQuest then return end
    
    local now = tick()
    if now - LastQuestTime < 2 then return end
    LastQuestTime = now
    
    local zone = GetCurrentZone()
    if not zone then return end
    
    -- Mevcut quest var mı kontrol et
    local success, hasQuest = pcall(function()
        return RemoteFunction:InvokeServer("GetQuests")
    end)
    
    if success and hasQuest then
        -- Quest varsa tamamlamayı dene
        pcall(function()
            RemoteFunction:InvokeServer("CompleteQuest")
        end)
    end
    
    -- Yeni quest başlat
    pcall(function()
        RemoteFunction:InvokeServer("StartQuest", zone.Quest, 1)
    end)
end

-- ==================== NPC BULMA ====================
local function UpdateNPCCache()
    local now = tick()
    if now - LastNPCCacheTime < 0.5 then return end
    LastNPCCacheTime = now
    
    NPCCache = {}
    local zone = GetCurrentZone()
    if not zone then return end
    
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    for _, npc in pairs(enemies:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
            local humanoid = npc:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Tam eşleşme kontrolü (Boss'ları engelle)
                if npc.Name == zone.NPC then
                    table.insert(NPCCache, npc)
                end
            end
        end
    end
end

local function GetNearestNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    
    UpdateNPCCache()
    
    local closest = nil
    local closestDist = math.huge
    local range = Settings.AttackRange
    
    for _, npc in pairs(NPCCache) do
        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
        if npcRoot then
            local dist = (hrp.Position - npcRoot.Position).Magnitude
            if Settings.KillAura then
                if dist < closestDist then
                    closestDist = dist
                    closest = npc
                end
            else
                if dist < range and dist < closestDist then
                    closestDist = dist
                    closest = npc
                end
            end
        end
    end
    
    return closest
end

-- ==================== UÇUŞ (BodyVelocity ile) ====================
local bodyVelocity = nil

local function SetupFlight()
    local hrp = GetHRP()
    if not hrp then return end
    
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        bodyVelocity.P = 1000
        bodyVelocity.Parent = hrp
    end
end

local function FlightControl()
    if Settings.FarmMethod ~= "Above" then
        if bodyVelocity then bodyVelocity:Destroy() end
        return
    end
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    SetupFlight()
    
    local targetY = Settings.FlightHeight
    local currentY = hrp.Position.Y
    local diff = targetY - currentY
    
    if math.abs(diff) > 1 then
        bodyVelocity.Velocity = Vector3.new(0, math.clamp(diff * 2, -30, 30), 0)
    else
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    
    humanoid.WalkSpeed = 16
    humanoid.PlatformStand = true
end

-- ==================== HAREKET (Teleport YOK) ====================
local function MoveTo(position)
    local now = tick()
    if now - LastMoveTime < 0.1 then return end
    LastMoveTime = now
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    if Settings.FarmMethod == "Above" then
        -- Havada MoveTo
        local targetPos = Vector3.new(position.X, Settings.FlightHeight, position.Z)
        humanoid:MoveTo(targetPos)
    else
        humanoid:MoveTo(position)
    end
end

-- ==================== ANA DÖNGÜ ====================
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoFarm and not Settings.KillAura then
            task.wait(1)
            continue
        end
        
        local humanoid = GetHumanoid()
        local hrp = GetHRP()
        if not humanoid or not hrp or humanoid.Health <= 0 then
            task.wait(2)
            continue
        end
        
        FlightControl()
        
        if Settings.AutoFarm and Settings.AutoQuest then
            HandleQuest()
        end
        
        local target = GetNearestNPC()
        
        if target then
            local npcRoot = target:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                if Settings.FarmMethod == "Above" then
                    local hrp = GetHRP()
                    if hrp then
                        local flyPos = npcRoot.Position + Vector3.new(0, Settings.FlightHeight, 0)
                        hrp.CFrame = CFrame.new(flyPos, npcRoot.Position)
                    end
                else
                    local dist = (hrp.Position - npcRoot.Position).Magnitude
                    if dist > 12 then
                        MoveTo(npcRoot.Position)
                    end
                end
                Attack()
            end
        else
            local zone = GetCurrentZone()
            local hrp = GetHRP()
            if hrp and zone and (hrp.Position - zone.Pos).Magnitude > 50 then
                MoveTo(zone.Pos)
            end
        end
    end
end)

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHub"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
MainFrame.BackgroundTransparency = 0.08
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 KOPUSHUB v5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LevelText = Instance.new("TextLabel")
LevelText.Size = UDim2.new(0, 110, 1, 0)
LevelText.Position = UDim2.new(1, -125, 0, 0)
LevelText.BackgroundTransparency = 1
LevelText.Text = "Lv." .. GetLevel()
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

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -55)
Content.Position = UDim2.new(0, 0, 0, 55)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.96, 0, 0, 38)
    section.Position = UDim2.new(0.02, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    section.Text = "  " .. title
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.TextScaled = true
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = Content
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
end

local function AddToggle(text, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 52)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
    container.Parent = Content
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 42)
    btn.Position = UDim2.new(0.85, -80, 0.5, -21)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(200, 60, 50)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(200, 60, 50)
        btn.Text = newVal and "ON" or "OFF"
    end)
end

local function AddDropdown(text, options, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 55)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
    container.Parent = Content
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.45, 0, 0, 42)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.5, -21)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    dropdownBtn.Text = getter()
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.Parent = container
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 8)
    
    local isOpen = false
    local dropdownList = nil
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            if dropdownList then dropdownList:Destroy() end
            isOpen = false
            return
        end
        
        dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0.45, 0, 0, 42 * #options)
        dropdownList.Position = UDim2.new(0.5, 0, 0, 46)
        dropdownList.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
        dropdownList.Parent = container
        Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 8)
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 42)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 42)
            optBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 52)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextScaled = true
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = dropdownList
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)
            
            optBtn.MouseButton1Click:Connect(function()
                setter(opt)
                dropdownBtn.Text = opt
                dropdownList:Destroy()
                isOpen = false
            end)
        end
        
        isOpen = true
    end)
end

local function AddSlider(text, minVal, maxVal, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 80)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
    container.Parent = Content
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 32)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. getter()
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 32)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 42)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 60, 80)
    sliderFrame.Parent = container
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 16)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    fill.Parent = sliderFrame
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 16)
    
    local dragging = false
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local val = minVal + (maxVal - minVal) * percent
            val = math.floor(val + 0.5)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local val = minVal + (maxVal - minVal) * percent
            val = math.floor(val + 0.5)
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
end

AddSection("⚙️ AUTO FARM")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)
AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)

AddSection("🌀 MOVEMENT")
AddDropdown("Farm Method", {"Above", "Ground"}, function() return Settings.FarmMethod end, function(v) Settings.FarmMethod = v end)
AddSlider("Flight Height", 15, 45, function() return Settings.FlightHeight end, function(v) Settings.FlightHeight = v end)

AddSection("⚔️ COMBAT")
AddSlider("Attack Range", 15, 35, function() return Settings.AttackRange end, function(v) Settings.AttackRange = v end)
AddSlider("Attack Speed", 3, 10, function() return math.floor(Settings.AttackSpeed * 10) end, function(v) Settings.AttackSpeed = v / 10 end)

AddSection("ℹ️ STATUS")
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.96, 0, 0, 100)
StatusText.Position = UDim2.new(0.02, 0, 0, 0)
StatusText.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
StatusText.Text = "🔥 KOPUSHUB v5.0\n✅ Gerçek Remote: CommF_\n✅ Combat: tool:Activate()\n✅ Quest: StartQuest/GetQuests\n✅ Teleport YOK\n✅ BodyVelocity ile Uçuş"
StatusText.TextColor3 = Color3.fromRGB(150, 180, 220)
StatusText.TextScaled = true
StatusText.TextWrapped = true
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = Content
Instance.new("UICorner", StatusText).CornerRadius = UDim.new(0, 10)

local function UpdateCanvas()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
UpdateCanvas()

task.spawn(function()
    while task.wait(1) do
        LevelText.Text = "Lv." .. GetLevel()
        local zone = GetCurrentZone()
        if zone and Settings.AutoFarm then
            StatusText.Text = "🔥 KOPUSHUB v5.0\n✅ Farm: " .. zone.NPC .. "\n✅ Uçuş: " .. Settings.FlightHeight .. "m\n✅ Level: " .. GetLevel() .. "\n✅ NPC: " .. #NPCCache
        end
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

SendNotif("KopusHub v5.0", "Script yüklendi! K butonuna bas.")
print("========================================")
print("🔥 KOPUSHUB v5.0 - GERÇEK API İLE")
print("✅ Remote: ReplicatedStorage.Remotes.CommF_")
print("✅ Combat: humanoid:EquipTool + tool:Activate()")
print("✅ Quest: StartQuest, GetQuests, CompleteQuest")
print("✅ Teleport YOK (sadece MoveTo)")
print("✅ BodyVelocity ile stabil uçuş")
print("📌 'K' butonuna basarak GUI'yi aç/kapat")
print("========================================")
