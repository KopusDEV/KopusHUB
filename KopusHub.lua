--[[
    KOPUSHUB v5.0 - Blox Fruits Ultimate Script
    Blue X Hub tarzı GUI
    Her şey Auto Farm'da toplandı
    Güvenli uçuş + yavaş hareket
--]]

-- ==================== BAŞLANGIÇ ====================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== AYARLAR ====================
local Settings = {
    -- Auto Farm
    AutoFarm = false,
    FarmType = "NPC", -- NPC, Chest
    FarmMethod = "Above", -- Above, Ground
    FarmWeapon = "Sword", -- Melee, Sword, Fruit
    
    -- Hareket
    FlightSpeed = 10, -- 5-20 arası
    FlightHeight = 25,
    SafeMode = true,
    
    -- Combat
    KillAura = false,
    KillAuraRange = 18,
    AttackSpeed = 0.35,
    
    -- Quest
    AutoQuest = true,
}

-- ==================== SEVİYE SİSTEMİ ====================
local LevelZones = {
    {Min = 1, Max = 30, NPC = "Bandit", Quest = "Bandit Quest Giver", Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", Quest = "Monkey Quest Giver", Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Viking", Quest = "Viking Quest Giver", Pos = Vector3.new(1200, 5, 1400)},
    {Min = 90, Max = 120, NPC = "Pirate", Quest = "Pirate Quest Giver", Pos = Vector3.new(1100, 5, 1300)},
    {Min = 120, Max = 150, NPC = "Brute", Quest = "Brute Quest Giver", Pos = Vector3.new(-2500, 10, -500)},
    {Min = 150, Max = 200, NPC = "Desert Soldier", Quest = "Desert Soldier Quest Giver", Pos = Vector3.new(950, 5, 1200)},
    {Min = 200, Max = 250, NPC = "Snow Bandit", Quest = "Snow Bandit Quest Giver", Pos = Vector3.new(-500, 80, -1300)},
    {Min = 250, Max = 300, NPC = "Chief Petty Officer", Quest = "Chief Petty Officer Quest Giver", Pos = Vector3.new(-2400, 10, -600)},
    {Min = 300, Max = 350, NPC = "Sea Soldier", Quest = "Sea Soldier Quest Giver", Pos = Vector3.new(1100, 20, -1800)},
    {Min = 350, Max = 400, NPC = "Magma Ninja", Quest = "Magma Ninja Quest Giver", Pos = Vector3.new(-500, 70, 1200)},
    {Min = 400, Max = 450, NPC = "Ship Deckhand", Quest = "Ship Deckhand Quest Giver", Pos = Vector3.new(-1100, 15, 500)},
    {Min = 450, Max = 500, NPC = "Prisoner", Quest = "Prisoner Quest Giver", Pos = Vector3.new(4500, 10, -800)},
    {Min = 500, Max = 550, NPC = "Dangerous Prisoner", Quest = "Dangerous Prisoner Quest Giver", Pos = Vector3.new(4700, 10, -900)},
    {Min = 550, Max = 600, NPC = "Military Soldier", Quest = "Military Soldier Quest Giver", Pos = Vector3.new(-2700, 20, 2000)},
    {Min = 600, Max = 650, NPC = "Military Spy", Quest = "Military Spy Quest Giver", Pos = Vector3.new(-2800, 20, 2100)},
    {Min = 650, Max = 700, NPC = "Diamond", Quest = "Diamond Quest Giver", Pos = Vector3.new(-1800, 25, 2800)},
    {Min = 700, Max = 750, NPC = "Zombie", Quest = "Zombie Quest Giver", Pos = Vector3.new(-150, 20, -500)},
    {Min = 750, Max = 800, NPC = "Vampire", Quest = "Vampire Quest Giver", Pos = Vector3.new(-200, 20, -550)},
    {Min = 800, Max = 850, NPC = "Snow Trooper", Quest = "Snow Trooper Quest Giver", Pos = Vector3.new(-600, 80, -1450)},
    {Min = 850, Max = 900, NPC = "Winter Warrior", Quest = "Winter Warrior Quest Giver", Pos = Vector3.new(-650, 85, -1500)},
    {Min = 900, Max = 950, NPC = "Lab Subordinate", Quest = "Lab Subordinate Quest Giver", Pos = Vector3.new(-100, 30, -100)},
    {Min = 950, Max = 1000, NPC = "Horned Warrior", Quest = "Horned Warrior Quest Giver", Pos = Vector3.new(-150, 30, -150)},
    {Min = 1000, Max = 1100, NPC = "God's Guard", Quest = "God's Guard Quest Giver", Pos = Vector3.new(-3000, 300, -3000)},
    {Min = 1100, Max = 1200, NPC = "Paladin", Quest = "Paladin Quest Giver", Pos = Vector3.new(-3200, 300, -3200)},
    {Min = 1200, Max = 1300, NPC = "Conjured Coconut", Quest = "Conjured Coconut Quest Giver", Pos = Vector3.new(-1800, 100, 1500)},
    {Min = 1300, Max = 1400, NPC = "Infantry Soldier", Quest = "Infantry Soldier Quest Giver", Pos = Vector3.new(-1900, 100, 1600)},
    {Min = 1400, Max = 1500, NPC = "Archer", Quest = "Archer Quest Giver", Pos = Vector3.new(-2000, 100, 1700)},
    {Min = 1500, Max = 1600, NPC = "Pistol Billionaire", Quest = "Pistol Billionaire Quest Giver", Pos = Vector3.new(2800, 20, -800)},
    {Min = 1600, Max = 1700, NPC = "Cannon Billionaire", Quest = "Cannon Billionaire Quest Giver", Pos = Vector3.new(2900, 20, -900)},
    {Min = 1700, Max = 1800, NPC = "Electric God", Quest = "Electric God Quest Giver", Pos = Vector3.new(3500, 200, -2000)},
    {Min = 1800, Max = 1900, NPC = "Thunder God", Quest = "Thunder God Quest Giver", Pos = Vector3.new(3600, 200, -2100)},
    {Min = 1900, Max = 2000, NPC = "Dragon Crew Warrior", Quest = "Dragon Crew Warrior Quest Giver", Pos = Vector3.new(5000, 50, -3000)},
    {Min = 2000, Max = 2100, NPC = "Dragon Crew Archer", Quest = "Dragon Crew Archer Quest Giver", Pos = Vector3.new(5100, 50, -3100)},
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
        Duration = 2
    })
end

local function EquipWeapon()
    if Settings.FarmWeapon == "Melee" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Melee")
    elseif Settings.FarmWeapon == "Sword" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Sword")
    end
end

-- ==================== GÜVENLİ HAREKET (ÇOK YAVAŞ) ====================
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
    
    -- Çok yavaş hareket (security kick engeller)
    humanoid.WalkSpeed = 14
    
    if Settings.FarmMethod == "Above" then
        -- Havadan yavaşça git
        humanoid.PlatformStand = true
        local targetPos = Vector3.new(position.X, Settings.FlightHeight, position.Z)
        
        -- Adım adım yavaş hareket
        local steps = 15
        local startPos = hrp.Position
        for i = 1, steps do
            local newPos = startPos:Lerp(targetPos, i / steps)
            hrp.CFrame = CFrame.new(newPos)
            wait(0.03)
        end
    else
        -- Yerde yürü
        humanoid:MoveTo(position)
        wait(0.8)
    end
    
    isMoving = false
end

-- ==================== UÇUŞ KONTROL (STABİL) ====================
local function FlightControl()
    if Settings.FarmMethod ~= "Above" then
        local humanoid = GetHumanoid()
        if humanoid then 
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = 14
        end
        return 
    end
    
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    humanoid.PlatformStand = true
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    -- Yavaş yükseklik ayarı
    local currentY = hrp.Position.Y
    local targetY = Settings.FlightHeight
    
    if currentY < targetY - 1 then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
    elseif currentY > targetY + 1 then
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 1, 0)
    end
end

-- ==================== QUEST ====================
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

-- ==================== NPC BUL ====================
local function GetNearestNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    
    local zone = GetCurrentZone()
    local closest = nil
    local closestDist = math.huge
    local range = Settings.KillAura and Settings.KillAuraRange or 20
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if string.find(npc.Name, zone.NPC) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local dist = (hrp.Position - npcRoot.Position).Magnitude
                    if dist < closestDist and dist < range then
                        closestDist = dist
                        closest = npc
                    end
                end
            end
        end
    end
    
    return closest
end

-- ==================== SALDIRI (YAVAŞ) ====================
local lastAttack = 0

local function AttackNPC(npc)
    local now = tick()
    if now - lastAttack < Settings.AttackSpeed then return end
    lastAttack = now
    
    local hrp = GetHRP()
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not hrp or not npcRoot then return end
    
    -- Yavaşça dön
    hrp.CFrame = CFrame.new(hrp.Position, npcRoot.Position)
    wait(0.08)
    
    -- Saldır
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.1)
    VirtualInput:SendKeyEvent(false, "E", false, game)
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
        
        if Settings.FarmType == "NPC" then
            local target = GetNearestNPC()
            
            if target then
                local npcRoot = target:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    -- Havada dur
                    if Settings.FarmMethod == "Above" then
                        local hrp = GetHRP()
                        if hrp then
                            local flyPos = npcRoot.Position + Vector3.new(0, Settings.FlightHeight, 0)
                            hrp.CFrame = CFrame.new(flyPos, npcRoot.Position)
                        end
                    else
                        if (GetHRP().Position - npcRoot.Position).Magnitude > 8 then
                            SafeMoveTo(npcRoot.Position)
                        end
                    end
                    
                    AttackNPC(target)
                end
            else
                -- NPC yoksa zone'a git
                local zone = GetCurrentZone()
                local hrp = GetHRP()
                if hrp and zone and (hrp.Position - zone.Pos).Magnitude > 40 then
                    SafeMoveTo(zone.Pos)
                end
                wait(0.5)
            end
        end
    end
end)

-- Uçuş döngüsü
spawn(function()
    while wait(0.08) do
        FlightControl()
    end
end)

-- ==================== GUI (BLUE X STİLİ) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHub"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KOPUSHUB v5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LevelText = Instance.new("TextLabel")
LevelText.Size = UDim2.new(0, 100, 1, 0)
LevelText.Position = UDim2.new(1, -115, 0, 0)
LevelText.BackgroundTransparency = 1
LevelText.Text = "Lv." .. GetLevel()
LevelText.TextColor3 = Color3.fromRGB(200, 200, 200)
LevelText.TextScaled = true
LevelText.Font = Enum.Font.GothamBold
LevelText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

-- İçerik
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 3
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- ==================== GUI BİLEŞENLERİ ====================
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.96, 0, 0, 32)
    section.Position = UDim2.new(0.02, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    section.Text = title
    section.TextColor3 = Color3.fromRGB(255, 200, 100)
    section.TextScaled = true
    section.Font = Enum.Font.GothamBold
    section.BorderSizePixel = 0
    
    local secCorner = Instance.new("UICorner")
    secCorner.CornerRadius = UDim.new(0, 6)
    secCorner.Parent = section
    
    section.Parent = Content
    return section
end

local function AddToggle(text, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 45)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 32, 42)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 8)
    contCorner.Parent = container
    
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
    btn.Size = UDim2.new(0, 70, 0, 35)
    btn.Position = UDim2.new(0.85, -70, 0.5, -17.5)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(200, 60, 50)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(200, 60, 50)
        btn.Text = newVal and "ON" or "OFF"
        if text == "Auto Farm" and newVal then
            SendNotif("KopusHub", "Auto Farm Başlatıldı!")
        end
    end)
    
    container.Parent = Content
    return container
end

local function AddDropdown(text, options, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 48)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 32, 42)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 8)
    contCorner.Parent = container
    
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
    dropdownBtn.Size = UDim2.new(0.45, 0, 0, 38)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.5, -19)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
    dropdownBtn.Text = getter()
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
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
        dropdownList.Position = UDim2.new(0.5, 0, 0, 42)
        dropdownList.BackgroundColor3 = Color3.fromRGB(20, 26, 36)
        dropdownList.BorderSizePixel = 0
        dropdownList.Parent = container
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 6)
        listCorner.Parent = dropdownList
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 38)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 38)
            optBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 55)
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
            end)
        end
        
        isOpen = true
    end)
    
    container.Parent = Content
    return container
end

local function AddSlider(text, minVal, maxVal, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 70)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 32, 42)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 8)
    contCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 28)
    label.Position = UDim2.new(0.05, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. getter()
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = container
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 28)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 38)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 58, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 14)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 14)
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
AddSection("⚙️ AUTO FARM SETTINGS")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddDropdown("Farm Type", {"NPC", "Chest"}, function() return Settings.FarmType end, function(v) Settings.FarmType = v end)
AddDropdown("Farm Method", {"Above", "Ground"}, function() return Settings.FarmMethod end, function(v) Settings.FarmMethod = v end)
AddDropdown("Select Weapon", {"Melee", "Sword", "Fruit"}, function() return Settings.FarmWeapon end, function(v) Settings.FarmWeapon = v end)

AddSection("🌀 MOVEMENT SETTINGS")
AddSlider("Flight Speed", 5, 20, function() return Settings.FlightSpeed end, function(v) Settings.FlightSpeed = v end)
AddSlider("Flight Height", 15, 40, function() return Settings.FlightHeight end, function(v) Settings.FlightHeight = v end)

AddSection("⚔️ COMBAT SETTINGS")
AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)
AddSlider("Kill Aura Range", 10, 25, function() return Settings.KillAuraRange end, function(v) Settings.KillAuraRange = v end)
AddSlider("Attack Speed", 2, 8, function() return math.floor(Settings.AttackSpeed * 10) end, function(v) Settings.AttackSpeed = v / 10 end)

AddSection("📋 QUEST")
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)

AddSection("ℹ️ STATUS")
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.96, 0, 0, 70)
StatusText.Position = UDim2.new(0.02, 0, 0, 0)
StatusText.BackgroundColor3 = Color3.fromRGB(25, 32, 42)
StatusText.Text = "KOPUSHUB v5.0\n✓ Stable Flight\n✓ Safe Mode ON\n✓ No Kick"
StatusText.TextColor3 = Color3.fromRGB(150, 180, 210)
StatusText.TextScaled = true
StatusText.TextWrapped = true
StatusText.Font = Enum.Font.Gotham

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = StatusText

StatusText.Parent = Content

-- Canvas güncelle
Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)

-- Level güncelleme
spawn(function()
    while wait(1) do
        LevelText.Text = "Lv." .. GetLevel()
        local zone = GetCurrentZone()
        if zone and Settings.AutoFarm then
            StatusText.Text = "KOPUSHUB v5.0\n✓ " .. zone.NPC .. " Farm\n✓ Flight: " .. Settings.FlightHeight .. "m\n✓ No Kick"
        end
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

SendNotif("KopusHub v5.0", "Script yüklendi! Insert ile GUI açılır. Safe Mode aktif!")
print("========================================")
print("🔥 KOPUSHUB v5.0 - BLUE X STYLE")
print("✅ Auto Farm + Flight birleşti!")
print("✅ Çok yavaş hareket - Security kick YOK!")
print("
