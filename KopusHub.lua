-- KOPUSHUB AI v1.0 - ÇALIŞAN VERSİYON
-- Yapay Zeka Destekli Blox Fruits Script

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== AYARLAR ====================
local Settings = {
    AutoFarm = false,
    FarmMethod = "Above",
    FarmWeapon = "Melee",
    FlightHeight = 25,
    KillAura = false,
    KillAuraRange = 18,
    AttackSpeed = 0.4,
    AutoQuest = true,
    AI_Enabled = true,
    FruitSniper = true,
}

-- ==================== SEVİYE ZONLARI ====================
local LevelZones = {
    {Min = 1, Max = 30, NPC = "Bandit", XP = 25, Quest = "Bandit Quest Giver", Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", XP = 50, Quest = "Monkey Quest Giver", Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Viking", XP = 80, Quest = "Viking Quest Giver", Pos = Vector3.new(1200, 5, 1400)},
    {Min = 90, Max = 120, NPC = "Pirate", XP = 120, Quest = "Pirate Quest Giver", Pos = Vector3.new(1100, 5, 1300)},
    {Min = 120, Max = 150, NPC = "Brute", XP = 180, Quest = "Brute Quest Giver", Pos = Vector3.new(-2500, 10, -500)},
}

-- ==================== YARDIMCI FONKSİYONLAR ====================
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
    
    humanoid.WalkSpeed = 14
    
    if Settings.FarmMethod == "Above" then
        humanoid.PlatformStand = true
        local targetPos = Vector3.new(position.X, Settings.FlightHeight, position.Z)
        
        local steps = 12
        local startPos = hrp.Position
        for i = 1, steps do
            local newPos = startPos:Lerp(targetPos, i / steps)
            hrp.CFrame = CFrame.new(newPos)
            task.wait(0.04)
        end
    else
        humanoid:MoveTo(position)
        task.wait(0.8)
    end
    
    isMoving = false
end

-- ==================== UÇUŞ KONTROL ====================
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
    
    local currentY = hrp.Position.Y
    local targetY = Settings.FlightHeight
    
    if currentY < targetY - 1.5 then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 1.2, 0)
    elseif currentY > targetY + 1.5 then
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 1.2, 0)
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
            task.wait(0.3)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            task.wait(0.5)
        end
        return
    end
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == zone.Quest then
            local hrp = GetHRP()
            if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude > 15 then
                SafeMoveTo(npc.HumanoidRootPart.Position)
            end
            task.wait(0.5)
            VirtualInput:SendKeyEvent(true, "E", false, game)
            task.wait(0.3)
            VirtualInput:SendKeyEvent(false, "E", false, game)
            task.wait(0.5)
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
    local range = Settings.KillAura and Settings.KillAuraRange or 22
    
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

-- ==================== SALDIRI ====================
local lastAttack = 0

local function AttackNPC(npc)
    local now = tick()
    if now - lastAttack < Settings.AttackSpeed then return end
    lastAttack = now
    
    local hrp = GetHRP()
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not hrp or not npcRoot then return end
    
    hrp.CFrame = CFrame.new(hrp.Position, npcRoot.Position)
    task.wait(0.08)
    
    VirtualInput:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VirtualInput:SendKeyEvent(false, "E", false, game)
end

-- ==================== FRUIT SNIPER ====================
local function FruitSniper()
    if not Settings.FruitSniper then return end
    
    spawn(function()
        while task.wait(5) do
            if not Settings.FruitSniper then break end
            
            local args = {[1] = "GetFruits"}
            local success, fruits = pcall(function()
                return ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            end)
            
            if success and fruits then
                local rareFruits = {"Leopard", "Dragon", "Spirit", "Venom", "Dough", "Buddha"}
                for _, fruit in pairs(fruits) do
                    for _, rare in pairs(rareFruits) do
                        if fruit.Name == rare and fruit.InStock then
                            local buyArgs = {[1] = "BuyFruit", [2] = fruit.Name}
                            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(buyArgs))
                            SendNotif("FRUIT SNIPER", rare .. " satın alındı! 🎉")
                        end
                    end
                end
            end
        end
    end)
end

-- ==================== ANA DÖNGÜ ====================
spawn(function()
    while task.wait(0.2) do
        if not Settings.AutoFarm then
            task.wait(1)
            continue
        end
        
        local humanoid = GetHumanoid()
        if not humanoid or humanoid.Health <= 0 then
            task.wait(3)
            continue
        end
        
        if Settings.AutoQuest then
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
                    local hrp = GetHRP()
                    if hrp and (hrp.Position - npcRoot.Position).Magnitude > 8 then
                        SafeMoveTo(npcRoot.Position)
                    end
                end
                AttackNPC(target)
            end
        else
            local zone = GetCurrentZone()
            local hrp = GetHRP()
            if hrp and zone and (hrp.Position - zone.Pos).Magnitude > 50 then
                SafeMoveTo(zone.Pos)
            end
            task.wait(0.5)
        end
    end
end)

-- Uçuş döngüsü
spawn(function()
    while task.wait(0.08) do
        FlightControl()
    end
end)

-- Fruit Sniper başlat
FruitSniper()

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🤖 KOPUSHUB AI"
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
LevelText.TextColor3 = Color3.fromRGB(255, 255, 255)
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
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 3
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- GUI Bileşenleri
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.96, 0, 0, 32)
    section.Position = UDim2.new(0.02, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    section.Text = title
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
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
    end)
    
    container.Parent = Content
    return container
end

local function AddDropdown(text, options, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 50)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
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
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
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
        dropdownList.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
        dropdownList.BorderSizePixel = 0
        dropdownList.Parent = container
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 6)
        listCorner.Parent = dropdownList
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 38)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 38)
            optBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 50)
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
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
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
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 14)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
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
AddSection("🤖 AI SETTINGS")
AddToggle("AI Assistant", function() return Settings.AI_Enabled end, function(v) Settings.AI_Enabled = v end)
AddToggle("Fruit Sniper", function() return Settings.FruitSniper end, function(v) Settings.FruitSniper = v end)

AddSection("⚙️ AUTO FARM")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddDropdown("Farm Method", {"Above", "Ground"}, function() return Settings.FarmMethod end, function(v) Settings.FarmMethod = v end)
AddDropdown("Weapon", {"Melee", "Sword"}, function() return Settings.FarmWeapon end, function(v) Settings.FarmWeapon = v end)

AddSection("🌀 MOVEMENT")
AddSlider("Flight Height", 15, 40, function() return Settings.FlightHeight end, function(v) Settings.FlightHeight = v end)

AddSection("⚔️ COMBAT")
AddToggle("Kill Aura", function() return Settings.KillAura end, function(v) Settings.KillAura = v end)
AddSlider("Kill Aura Range", 10, 25, function() return Settings.KillAuraRange end, function(v) Settings.KillAuraRange = v end)
AddSlider("Attack Speed", 2, 8, function() return math.floor(Settings.AttackSpeed * 10) end, function(v) Settings.AttackSpeed = v / 10 end)

AddSection("📋 QUEST")
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)

-- Canvas güncelle
Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)

-- Level güncelleme
spawn(function()
    while task.wait(1) do
        LevelText.Text = "Lv." .. GetLevel()
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

SendNotif("KopusHub AI", "Script yüklendi! Insert ile GUI acilir.")
print("========================================")
print("🤖 KOPUSHUB AI v1.0 CALISIYOR!")
print("✅ Auto Farm + Ucus Aktif")
print("✅ Fruit Sniper Aktif")
print("📌 Insert tusu ile GUI acilir")
print("========================================")
