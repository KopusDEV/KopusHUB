-- KOPUSHUB AI v1.0 - FULL VERSION (NO KEY REQUIRED)
-- Yapay Zeka Destekli Blox Fruits Script (Hataları Giderilmiş Tam Sürüm)

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
    return LevelZones[#LevelZones]
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
    if hrp then
        hrp.CFrame = CFrame.new(position.X, position.Y + Settings.FlightHeight, position.Z)
    end
    task.wait(0.1)
    isMoving = false
end

-- ==================== UÇUŞ KONTROL ====================
local function FlightControl()
    local hrp = GetHRP()
    local humanoid = GetHumanoid()
    if not hrp or not humanoid then return end
    
    if Settings.AutoFarm and Settings.FarmMethod == "Above" then
        humanoid.PlatformStand = true
        if not hrp:FindFirstChild("KopusFloat") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "KopusFloat"
            bv.Velocity = Vector3.new(0,0,0)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = hrp
        end
    else
        humanoid.PlatformStand = false
        if hrp:FindFirstChild("KopusFloat") then hrp.KopusFloat:Destroy() end
    end
end

-- ==================== QUEST & SALDIRI (DETAYLI FIX) ====================
local function HandleQuest()
    if not Settings.AutoQuest then return end
    local zone = GetCurrentZone()
    local questFrame = Player.PlayerGui:FindFirstChild("Quest")
    
    if questFrame and questFrame.Visible then return end
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == zone.Quest then
            local hrp = GetHRP()
            if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude < 15 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", zone.Quest, 1)
            else
                SafeMoveTo(npc.HumanoidRootPart.Position)
            end
            break
        end
    end
end

local function GetNearestNPC()
    local hrp = GetHRP()
    if not hrp then return nil end
    local zone = GetCurrentZone()
    local closest = nil
    local closestDist = math.huge
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        if string.find(npc.Name, zone.NPC) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
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
    return closest
end

-- ==================== ANA DÖNGÜLER ====================
spawn(function()
    while task.wait(0.1) do
        if Settings.AutoFarm then
            HandleQuest()
            local target = GetNearestNPC()
            if target then
                local hrp = GetHRP()
                local targetPos = target.HumanoidRootPart.Position
                hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + Settings.FlightHeight, targetPos.Z)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", target)
                VirtualInput:SendKeyEvent(true, "Click", false, game)
            end
        end
    end
end)

spawn(function()
    while task.wait(0.05) do FlightControl() end
end)

-- ==================== GUI (DETAYLI TASARIM) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true -- DİREKT AÇIK

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- BAŞLIK
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🤖 KOPUSHUB AI v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = TitleBar

-- İÇERİK (SCROLLING)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Content

-- KÜTÜPHANE FONKSİYONLARI (SECTION, TOGGLE, SLIDER)
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.9, 0, 0, 30)
    section.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    section.Text = title
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.Font = Enum.Font.GothamBold
    section.Parent = Content
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
end

local function AddToggle(text, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(40, 40, 50)
    btn.Text = text .. (getter() and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        local v = not getter()
        setter(v)
        btn.BackgroundColor3 = v and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(40, 40, 50)
        btn.Text = text .. (v and " [ON]" or " [OFF]")
    end)
end

-- GUI OLUŞTURMA
AddSection("🤖 AI CONTROL")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddToggle("Fruit Sniper", function() return Settings.FruitSniper end, function(v) Settings.FruitSniper = v end)

AddSection("⚙️ SETTINGS")
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)

Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

SendNotif("KopusHub AI", "Sistem Aktif! Menü Açıldı.")
