--[[
    KOPUSHUB AI v1.0 - Yapay Zeka Destekli
    - Akıllı NPC seçimi
    - Fruit Sniper AI
    - Discord bildirimleri
    - Otomatik optimizasyon
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== AI AYARLARI ====================
local AI_Settings = {
    Enabled = true,
    AutoSelectNPC = true,  -- En iyi NPC'yi seç
    FruitSniper = true,    -- Otomatik meyve takibi
    DiscordWebhook = "",   -- Webhook URL (istersen ekle)
    AutoRaid = false,
    SmartTeleport = true,
}

-- ==================== AI VERİ ANALİZİ ====================
local AI_Data = {
    StartTime = tick(),
    TotalXP = 0,
    XPPerHour = 0,
    BestNPC = nil,
    BestXPPerMin = 0,
}

-- ==================== SEVİYE ZONLARI (XP VERİLERİYLE) ====================
local LevelZones = {
    {Min = 1, Max = 30, NPC = "Bandit", XP = 25, Quest = "Bandit Quest Giver", Pos = Vector3.new(-1165, 20, 450)},
    {Min = 30, Max = 60, NPC = "Monkey", XP = 50, Quest = "Monkey Quest Giver", Pos = Vector3.new(-1600, 35, 200)},
    {Min = 60, Max = 90, NPC = "Viking", XP = 80, Quest = "Viking Quest Giver", Pos = Vector3.new(1200, 5, 1400)},
    {Min = 90, Max = 120, NPC = "Pirate", XP = 120, Quest = "Pirate Quest Giver", Pos = Vector3.new(1100, 5, 1300)},
    {Min = 120, Max = 150, NPC = "Brute", XP = 180, Quest = "Brute Quest Giver", Pos = Vector3.new(-2500, 10, -500)},
    {Min = 150, Max = 200, NPC = "Desert Soldier", XP = 250, Quest = "Desert Soldier Quest Giver", Pos = Vector3.new(950, 5, 1200)},
    {Min = 200, Max = 250, NPC = "Snow Bandit", XP = 350, Quest = "Snow Bandit Quest Giver", Pos = Vector3.new(-500, 80, -1300)},
    {Min = 250, Max = 300, NPC = "Chief Petty Officer", XP = 450, Quest = "Chief Petty Officer Quest Giver", Pos = Vector3.new(-2400, 10, -600)},
    {Min = 300, Max = 350, NPC = "Sea Soldier", XP = 550, Quest = "Sea Soldier Quest Giver", Pos = Vector3.new(1100, 20, -1800)},
    {Min = 350, Max = 400, NPC = "Magma Ninja", XP = 700, Quest = "Magma Ninja Quest Giver", Pos = Vector3.new(-500, 70, 1200)},
    {Min = 400, Max = 450, NPC = "Ship Deckhand", XP = 850, Quest = "Ship Deckhand Quest Giver", Pos = Vector3.new(-1100, 15, 500)},
    {Min = 450, Max = 500, NPC = "Prisoner", XP = 1000, Quest = "Prisoner Quest Giver", Pos = Vector3.new(4500, 10, -800)},
    {Min = 500, Max = 550, NPC = "Dangerous Prisoner", XP = 1200, Quest = "Dangerous Prisoner Quest Giver", Pos = Vector3.new(4700, 10, -900)},
    {Min = 550, Max = 600, NPC = "Military Soldier", XP = 1400, Quest = "Military Soldier Quest Giver", Pos = Vector3.new(-2700, 20, 2000)},
    {Min = 600, Max = 650, NPC = "Military Spy", XP = 1600, Quest = "Military Spy Quest Giver", Pos = Vector3.new(-2800, 20, 2100)},
    {Min = 650, Max = 700, NPC = "Diamond", XP = 1800, Quest = "Diamond Quest Giver", Pos = Vector3.new(-1800, 25, 2800)},
    {Min = 700, Max = 750, NPC = "Zombie", XP = 2000, Quest = "Zombie Quest Giver", Pos = Vector3.new(-150, 20, -500)},
    {Min = 750, Max = 800, NPC = "Vampire", XP = 2200, Quest = "Vampire Quest Giver", Pos = Vector3.new(-200, 20, -550)},
    {Min = 800, Max = 850, NPC = "Snow Trooper", XP = 2400, Quest = "Snow Trooper Quest Giver", Pos = Vector3.new(-600, 80, -1450)},
    {Min = 850, Max = 900, NPC = "Winter Warrior", XP = 2600, Quest = "Winter Warrior Quest Giver", Pos = Vector3.new(-650, 85, -1500)},
    {Min = 900, Max = 950, NPC = "Lab Subordinate", XP = 2800, Quest = "Lab Subordinate Quest Giver", Pos = Vector3.new(-100, 30, -100)},
    {Min = 950, Max = 1000, NPC = "Horned Warrior", XP = 3000, Quest = "Horned Warrior Quest Giver", Pos = Vector3.new(-150, 30, -150)},
    {Min = 1000, Max = 1100, NPC = "God's Guard", XP = 3200, Quest = "God's Guard Quest Giver", Pos = Vector3.new(-3000, 300, -3000)},
    {Min = 1100, Max = 1200, NPC = "Paladin", XP = 3400, Quest = "Paladin Quest Giver", Pos = Vector3.new(-3200, 300, -3200)},
    {Min = 1200, Max = 1300, NPC = "Conjured Coconut", XP = 3600, Quest = "Conjured Coconut Quest Giver", Pos = Vector3.new(-1800, 100, 1500)},
    {Min = 1300, Max = 1400, NPC = "Infantry Soldier", XP = 3800, Quest = "Infantry Soldier Quest Giver", Pos = Vector3.new(-1900, 100, 1600)},
    {Min = 1400, Max = 1500, NPC = "Archer", XP = 4000, Quest = "Archer Quest Giver", Pos = Vector3.new(-2000, 100, 1700)},
    {Min = 1500, Max = 1600, NPC = "Pistol Billionaire", XP = 4500, Quest = "Pistol Billionaire Quest Giver", Pos = Vector3.new(2800, 20, -800)},
    {Min = 1600, Max = 1700, NPC = "Cannon Billionaire", XP = 5000, Quest = "Cannon Billionaire Quest Giver", Pos = Vector3.new(2900, 20, -900)},
    {Min = 1700, Max = 1800, NPC = "Electric God", XP = 5500, Quest = "Electric God Quest Giver", Pos = Vector3.new(3500, 200, -2000)},
    {Min = 1800, Max = 1900, NPC = "Thunder God", XP = 6000, Quest = "Thunder God Quest Giver", Pos = Vector3.new(3600, 200, -2100)},
    {Min = 1900, Max = 2000, NPC = "Dragon Crew Warrior", XP = 7000, Quest = "Dragon Crew Warrior Quest Giver", Pos = Vector3.new(5000, 50, -3000)},
    {Min = 2000, Max = 2100, NPC = "Dragon Crew Archer", XP = 8000, Quest = "Dragon Crew Archer Quest Giver", Pos = Vector3.new(5100, 50, -3100)},
}

-- ==================== AI NPC SEÇİCİ ====================
local function AISelectBestNPC()
    if not AI_Settings.AutoSelectNPC then return end
    
    local level = Player.Data.Level.Value
    local bestZone = nil
    local bestEfficiency = 0
    
    for _, zone in ipairs(LevelZones) do
        if level >= zone.Min and level <= zone.Max then
            -- XP verimliliği hesapla
            local efficiency = zone.XP / (zone.Max - zone.Min + 1)
            if efficiency > bestEfficiency then
                bestEfficiency = efficiency
                bestZone = zone
            end
        end
    end
    
    if bestZone and bestZone.NPC ~= AI_Data.BestNPC then
        AI_Data.BestNPC = bestZone.NPC
        AI_Data.BestXPPerMin = bestEfficiency
        
        -- Discord bildirimi
        if AI_Settings.DiscordWebhook ~= "" then
            local data = {
                content = "🤖 **AI Seçimi Güncellendi!**\n📊 **NPC:** " .. bestZone.NPC .. "\n⚡ **XP/Mob:** " .. bestZone.XP .. "\n📍 **Bölge:** " .. bestZone.Pos
            }
            HttpService:PostAsync(AI_Settings.DiscordWebhook, HttpService:JSONEncode(data))
        end
        
        SendNotif("AI", "En iyi NPC seçildi: " .. bestZone.NPC)
    end
    
    return bestZone
end

-- ==================== FRUIT SNIPER AI ====================
local function FruitSniperAI()
    if not AI_Settings.FruitSniper then return end
    
    spawn(function()
        while wait(2) do
            if not AI_Settings.FruitSniper then break end
            
            -- Stok kontrolü
            local args = {
                [1] = "GetFruits"
            }
            local fruits = ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            
            local rareFruits = {"Leopard", "Dragon", "Spirit", "Venom", "Dough", "Buddha"}
            
            for _, fruit in pairs(fruits or {}) do
                for _, rare in pairs(rareFruits) do
                    if fruit.Name == rare and fruit.InStock then
                        -- Otomatik satın al
                        local buyArgs = {[1] = "BuyFruit", [2] = fruit.Name}
                        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(buyArgs))
                        
                        SendNotif("FRUIT SNIPER", rare .. " satın alındı! 🎉")
                        
                        -- Discord bildirimi
                        if AI_Settings.DiscordWebhook ~= "" then
                            local data = {
                                content = "🍎 **FRUIT SNIPER!**\n✨ " .. rare .. " satın alındı!\n💰 Fiyat: " .. (fruit.Price or "?")
                            }
                            HttpService:PostAsync(AI_Settings.DiscordWebhook, HttpService:JSONEncode(data))
                        end
                    end
                end
            end
        end
    end)
end

-- ==================== XP ANALİZİ ====================
local lastXP = 0
local lastXPCheck = tick()

spawn(function()
    while wait(60) do -- Her dakika hesapla
        if not AI_Settings.Enabled then continue end
        
        local currentXP = Player.Data.Experience.Value
        local timePassed = (tick() - lastXPCheck) / 3600 -- Saat cinsinden
        local xpGained = currentXP - lastXP
        
        if timePassed > 0 then
            AI_Data.XPPerHour = xpGained / timePassed
        end
        
        local level = GetLevel()
        local nextLevelXP = Player.Data.Experience.Required.Value
        local remainingXP = nextLevelXP - currentXP
        local estimatedHours = remainingXP / (AI_Data.XPPerHour + 0.01)
        
        lastXP = currentXP
        lastXPCheck = tick()
        
        -- Level atlama bildirimi
        if AI_Data.XPPerHour > 0 then
            if AI_Settings.DiscordWebhook ~= "" then
                local data = {
                    content = "📊 **XP RAPORU**\n🎯 Level: " .. level .. "\n⚡ XP/Saat: " .. math.floor(AI_Data.XPPerHour) .. "\n⏱️ Sonraki Level: ~" .. math.floor(estimatedHours * 60) .. " dk"
                }
                HttpService:PostAsync(AI_Settings.DiscordWebhook, HttpService:JSONEncode(data))
            end
        end
    end
end)

-- ==================== ANA AYARLAR ====================
local Settings = {
    AutoFarm = false,
    FarmMethod = "Above",
    FarmWeapon = "Melee",
    FlightHeight = 25,
    KillAura = false,
    KillAuraRange = 18,
    AttackSpeed = 0.4,
    AutoQuest = true,
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
    if AI_Settings.AutoSelectNPC then
        local best = AISelectBestNPC()
        if best then return best end
    end
    
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
    
    humanoid.WalkSpeed = 14
    
    if Settings.FarmMethod == "Above" then
        humanoid.PlatformStand = true
        local targetPos = Vector3.new(position.X, Settings.FlightHeight, position.Z)
        
        local steps = 12
        local startPos = hrp.Position
        for i = 1, steps do
            local newPos = startPos:Lerp(targetPos, i / steps)
            hrp.CFrame = CFrame.new(newPos)
            wait(0.04)
        end
    else
        humanoid:MoveTo(position)
        wait(0.8)
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
    wait(0.08)
    
    VirtualInput:SendKeyEvent(true, "E", false, game)
    wait(0.1)
    VirtualInput:SendKeyEvent(false, "E", false, game)
    
    -- XP sayacı
    if AI_Settings.Enabled then
        AI_Data.TotalXP = AI_Data.TotalXP + (GetCurrentZone().XP or 0)
    end
end

-- ==================== ANA DÖNGÜ ====================
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
                    if (GetHRP().Position - npcRoot.Position).Magnitude > 8 then
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
            wait(0.5)
        end
    end
end)

-- Uçuş döngüsü
spawn(function()
    while wait(0.08) do
        FlightControl()
    end
end)

-- Fruit Sniper AI
FruitSniperAI()

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 580)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🤖 KOPUSHUB AI v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local LevelText = Instance.new("TextLabel")
LevelText.Size = UDim2.new(0, 120, 1, 0)
LevelText.Position = UDim2.new(1, -135, 0, 0)
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

-- İçerik
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -55)
Content.Position = UDim2.new(0, 0, 0, 55)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- GUI Bileşenleri
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.96, 0, 0, 35)
    section.Position = UDim2.new(0.02, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    section.Text = title
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.TextScaled = true
    section.Font = Enum.Font.GothamBold
    section.BorderSizePixel = 0
    
    local secCorner = Instance.new("UICorner")
    secCorner.CornerRadius = UDim.new(0, 8)
    secCorner.Parent = section
    
    section.Parent = Content
    return section
end

local function AddToggle(text, getter, setter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.96, 0, 0, 48)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 10)
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
    btn.Size = UDim2.new(0, 75, 0, 38)
    btn.Position = UDim2.new(0.85, -75, 0.5, -19)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(200, 60, 50)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
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
    container.Size = UDim2.new(0.96, 0, 0, 52)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 10)
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
    dropdownBtn.Size = UDim2.new(0.45, 0, 0, 40)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.5, -20)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    dropdownBtn.Text = getter()
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextScaled = true
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
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
        dropdownList.Size = UDim2.new(0.45, 0, 0, 40 * #options)
        dropdownList.Position = UDim2.new(0.5, 0, 0, 44)
        dropdownList.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
        dropdownList.BorderSizePixel = 0
        dropdownList.Parent = container
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 8)
        listCorner.Parent = dropdownList
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 40)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            optBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 48)
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
    container.Size = UDim2.new(0.96, 0, 0, 75)
    container.Position = UDim2.new(0.02, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    container.BorderSizePixel = 0
    
    local contCorner = Instance.new("UICorner")
    contCorner.CornerRadius = UDim.new(0, 10)
    contCorner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
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
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 16)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
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

-- ==================== GUI İÇERİĞİ ====================
AddSection("🤖 AI SETTINGS")
AddToggle("AI Assistant", function() return AI_Settings.Enabled end, function(v) AI_Settings.Enabled = v end)
AddToggle("Auto Select Best NPC", function() return AI_Settings.AutoSelectNPC end, function(v) AI_Settings.AutoSelectNPC = v end)
AddToggle("Fruit Sniper AI", function() return AI_Settings.FruitSniper end, function(v) AI_Settings.FruitSniper = v end)

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

AddSection("📊 AI STATS")
local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(0.96, 0, 0, 80)
StatsText.Position = UDim2.new(0.02, 0, 0, 0)
StatsText.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
StatsText.Text = "🤖 AI Aktif\n⚡ Best NPC: " .. (AI_Data.BestNPC or "Hesaplanıyor...") .. "\n📈 XP/Saat: " .. math.floor(AI_Data.XPPerHour)
StatsText.TextColor3 = Color3.fromRGB(150, 180, 220)
StatsText.TextScaled = true
StatsText.TextWrapped = true
StatsText.Font = Enum.Font.Gotham

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 10)
statsCorner.Parent = StatsText

StatsText.Parent = Content

-- Canvas güncelle
Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

-- Level ve istatistik güncelleme
spawn(function()
    while wait(1) do
        LevelText.Text = "Lv." .. GetLevel()
        if AI_Settings.Enabled then
            StatsText.Text = "🤖 AI AKTIF\n⚡ En Iyi NPC: " .. (AI_Data.BestNPC or "Seciliyor...") .. "\n📈 XP/Saat: " .. math.floor(AI_Data.XPPerHour) .. "\n🍎 Fruit Sniper: " .. (AI_Settings.FruitSniper and "Aktif" or "Kapali")
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

SendNotif("KopusHub AI", "Yapay Zeka Destekli Script Yüklendi! Insert ile GUI acilir.")
print("========================================")
print("🤖 KOPUSHUB AI v1.0 YUKLENDI!")
print("✅ AI NPC Secici Aktif")
print("✅ Fruit Sniper Aktif")
print("✅ XP Analizi Aktif")
print("📌 Insert tusu ile GUI acilir")
print("========================================")
