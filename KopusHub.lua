if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- AYARLAR
local Settings = {
    AutoFarm = false,
    Height = 10,
    AttackDelay = 0.2
}

-- LEVEL ALMA
local function GetLevel()
    local data = player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 1
end

-- SEA + QUEST TABLOSU (GENİŞLETİLEBİLİR)
local Quests = {
    -- 1. SEA
    {Min=1, Max=30, NPC="Bandit"},
    {Min=30, Max=60, NPC="Monkey"},
    {Min=60, Max=100, NPC="Pirate"},
    {Min=100, Max=150, NPC="Brute"},
    {Min=150, Max=200, NPC="Desert Bandit"},
    
    -- 2. SEA (örnek)
    {Min=700, Max=775, NPC="Raider"},
    {Min=775, Max=850, NPC="Mercenary"},
    
    -- 3. SEA (örnek)
    {Min=1500, Max=1575, NPC="Pirate Millionaire"},
    {Min=1575, Max=1650, NPC="Pistol Billionaire"},
}

-- LEVEL’A GÖRE NPC SEÇ
local function GetQuestData()
    local lvl = GetLevel()
    for _,q in pairs(Quests) do
        if lvl >= q.Min and lvl <= q.Max then
            return q
        end
    end
    return Quests[#Quests]
end

-- CHARACTER
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetRoot()
    return GetChar():FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    return GetChar():FindFirstChild("Humanoid")
end

-- EN YAKIN NPC
local function GetNearest()
    local root = GetRoot()
    if not root then return nil end

    local quest = GetQuestData()
    local closest, dist = nil, math.huge

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _,v in pairs(enemies:GetChildren()) do
        if v.Name:find(quest.NPC) then
            local hum = v:FindFirstChild("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                local d = (root.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end

    return closest
end

-- HAREKET
local function MoveAbove(target)
    local root = GetRoot()
    if not root then return end

    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Height, 0)
end

-- SALDIRI
local function Attack()
    local char = GetChar()
    local tool = char:FindFirstChildOfClass("Tool")

    if not tool then
        local bpTool = player.Backpack:FindFirstChildOfClass("Tool")
        if bpTool then
            GetHum():EquipTool(bpTool)
        end
        return
    end

    tool:Activate()
end

-- ANA LOOP
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoFarm then
            local target = GetNearest()

            if target then
                MoveAbove(target)
                Attack()
                task.wait(Settings.AttackDelay)
            end
        end
    end
end)

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
local btn = Instance.new("TextButton", gui)

btn.Size = UDim2.new(0,150,0,50)
btn.Position = UDim2.new(0,20,0,20)
btn.Text = "Auto Farm: OFF"

btn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    btn.Text = Settings.AutoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
end)
