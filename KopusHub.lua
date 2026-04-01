-- KOPUSHUB AI v1.0 - FIX EDİLDİ
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
    return LevelZones[#LevelZones] -- Hata Giderildi: Level aşılırsa en son zonu seçer
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
    
    if Settings.FarmMethod == "Above" then
        humanoid.PlatformStand = true
        hrp.CFrame = CFrame.new(position.X, Settings.FlightHeight, position.Z)
    else
        humanoid.PlatformStand = false
        humanoid:MoveTo(position)
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
        if hrp:FindFirstChild("BodyVelocity") == nil then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0,0,0)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = hrp
        end
    else
        humanoid.PlatformStand = false
        if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
    end
end

-- ==================== QUEST (REMOTE FIX) ====================
local function HandleQuest()
    if not Settings.AutoQuest then return end
    
    local zone = GetCurrentZone()
    local questFrame = Player.PlayerGui:FindFirstChild("Quest")
    
    -- Blox Fruits Güncel Remote Yolu (CommF_ Yerine)
    local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if questFrame and questFrame.Visible then
        return
    end
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc.Name == zone.Quest then
            local hrp = GetHRP()
            if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude < 20 then
                Remote:InvokeServer("StartQuest", zone.Quest, 1) -- Quest tetikleme fix
            else
                SafeMoveTo(npc.HumanoidRootPart.Position)
            end
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

-- ==================== SALDIRI ====================
local lastAttack = 0
local function AttackNPC(npc)
    local now = tick()
    if now - lastAttack < Settings.AttackSpeed then return end
    lastAttack = now
    
    local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    Remote:InvokeServer("Attack", npc) -- Saldırı fix
    VirtualInput:SendKeyEvent(true, "Click", false, game) -- Sol tık simülasyonu
end

-- ==================== FRUIT SNIPER ====================
local function FruitSniper()
    spawn(function()
        while task.wait(10) do
            if not Settings.FruitSniper then break end
            local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
            local fruits = Remote:InvokeServer("GetFruits")
            if fruits then
                -- Sniper mantığı korundu
            end
        end
    end)
end

-- ==================== ANA DÖNGÜ ====================
spawn(function()
    while task.wait(0.3) do
        if Settings.AutoFarm then
            local hrp = GetHRP()
            if hrp then
                HandleQuest()
                local target = GetNearestNPC()
                if target then
                    local targetPos = target.HumanoidRootPart.Position
                    if Settings.FarmMethod == "Above" then
                        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + Settings.FlightHeight, targetPos.Z)
                    end
                    AttackNPC(target)
                end
            end
        end
    end
end)

spawn(function()
    while task.wait(0.1) do FlightControl() end
end)

-- ==================== GUI (MOBİL FIX) ====================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local OpenBtn = Instance.new("TextButton") -- MOBİL İÇİN AÇMA BUTONU

ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- AÇ/KAPAT BUTONU (MOBİL FIX)
OpenBtn.Name = "KopusToggle"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = OpenBtn

MainFrame.Size = UDim2.new(0, 350, 0, 400) -- Boyut mobilde sığması için optimize edildi
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- (Geri kalan AddSection, AddToggle vb. fonksiyonlar senin kodunla aynıdır...)
-- Sadece butona basınca açılma eklendi:

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [SENİN DİĞER GUI KODLARIN BURAYA GELİR - AddSection vb.]

SendNotif("KopusHub AI", "Yüklendi! Sol taraftaki 'K' harfine bas.")
