if not game:IsLoaded() then game.Loaded:Wait() end

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- SETTINGS
local Settings = {
    AutoFarm = false,
    Distance = 20,
    Height = 20,
    AttackDelay = 0.35
}

-- LEVEL ZONE (basitleştirilmiş)
local Zones = {
    {Min = 1, Max = 30, NPC = "Bandit"},
    {Min = 30, Max = 60, NPC = "Monkey"},
    {Min = 60, Max = 100, NPC = "Pirate"},
}

-- CHARACTER
local function GetChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function HRP()
    return GetChar():WaitForChild("HumanoidRootPart")
end

local function Hum()
    return GetChar():WaitForChild("Humanoid")
end

local function GetLevel()
    local data = Player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 1
end

-- ZONE BUL
local function GetZone()
    local lvl = GetLevel()
    for _,z in pairs(Zones) do
        if lvl >= z.Min and lvl <= z.Max then
            return z
        end
    end
    return Zones[#Zones]
end

-- NPC CACHE (performans için)
local NPCFolder = workspace:FindFirstChild("Enemies") or workspace

local function GetNearest()
    local closest, dist = nil, math.huge
    local root = HRP()
    local zone = GetZone()

    for _,v in pairs(NPCFolder:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            if v.Humanoid.Health > 0 and string.find(v.Name, zone.NPC) then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = v
                    end
                end
            end
        end
    end

    return closest
end

-- TOOL ATTACK (gerçek çalışan sistem)
local function Attack()
    local tool = GetChar():FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-- UÇUŞ (daha stabil)
local function Float(target)
    local root = HRP()
    root.Velocity = Vector3.zero
    root.CFrame = CFrame.new(
        target.Position + Vector3.new(0, Settings.Height, 0),
        target.Position
    )
end

-- LOOP (optimize)
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoFarm then continue end

        local target = GetNearest()
        if not target then continue end

        local npcHRP = target:FindFirstChild("HumanoidRootPart")
        if not npcHRP then continue end

        -- üstte dur
        Float(npcHRP)

        -- saldır
        Attack()
        task.wait(Settings.AttackDelay)
    end
end)

-- BASİT GUI (test için)
local gui = Instance.new("ScreenGui", Player.PlayerGui)

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,120,0,50)
btn.Position = UDim2.new(0,20,0,20)
btn.Text = "Auto Farm OFF"

btn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    btn.Text = Settings.AutoFarm and "Auto Farm ON" or "OFF"
end)
