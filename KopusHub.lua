

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==================== SERVİSLER ====================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local VirtualInput = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()


local Settings = {
    AutoFarm = false,
    AutoQuest = false,
    KillAura = false,
    FarmMethod = "Above",
    FlightHeight = 20,
    AttackRange = 25,
    AttackSpeed = 0.45, 
}


local LastAttack = 0
local LastQuest = 0
local CurrentTool = nil
local BodyVelo = nil


local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end
local function GetHRP() return GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum() return GetChar():FindFirstChild("Humanoid") end

local function GetLevel()
    local data = Player:FindFirstChild("Data")
    return (data and data:FindFirstChild("Level")) and data.Level.Value or 1
end


local function CheckObstacle()
    local hrp = GetHRP()
    if not hrp then return end
    
    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 5)
    local hit = Workspace:FindPartOnRay(ray, GetChar())
    if hit and hit.CanCollide then
        local hum = GetHum()
        if hum then hum.Jump = true end
    end
end


local function SmartEquip()
    local char = GetChar()
    
    if char:FindFirstChildOfClass("Tool") then return char:FindFirstChildOfClass("Tool") end
    
    local bp = Player:FindFirstChild("Backpack")
    if bp then
        local tool = bp:FindFirstChildOfClass("Tool")
        if tool then
            GetHum():EquipTool(tool)
            return tool
        end
    end
    return nil
end

local function SecureAttack()
    if tick() - LastAttack < Settings.AttackSpeed then return end
    
    local tool = SmartEquip()
    if tool then
        tool:Activate()
        LastAttack = tick()
    end
end


local function ClickConfirm()
   
    local gui = Player.PlayerGui:FindFirstChild("DialogueGui")
    if gui and gui.Enabled then
        local container = gui:FindFirstChild("Frame")
        if container then
           
            VirtualInput:SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            VirtualInput:SendKeyEvent(false, "E", false, game)
        end
    end
end

local function HandleQuest()
    if not Settings.AutoQuest or (tick() - LastQuest < 8) then return end
    
   
    if Player.PlayerGui.Main:FindFirstChild("Quest") and Player.PlayerGui.Main.Quest.Visible then return end
    
    local zone = GetCurrentZone() 
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return end
    
    local targetNPC = npcFolder:FindFirstChild(zone.QuestNPC)
    if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
        local dist = (GetHRP().Position - targetNPC.HumanoidRootPart.Position).Magnitude
        if dist < 15 then
            ClickConfirm()
            LastQuest = tick()
        else
            GetHum():MoveTo(targetNPC.HumanoidRootPart.Position)
        end
    end
end


local function ToggleFlight(state, targetY)
    local hrp = GetHRP()
    if not hrp then return end
    
    if state then
        if not BodyVelo or BodyVelo.Parent ~= hrp then
            if BodyVelo then BodyVelo:Destroy() end
            BodyVelo = Instance.new("BodyVelocity")
            BodyVelo.MaxForce = Vector3.new(0, 100000, 0) 
            BodyVelo.Parent = hrp
        end
        
        local diff = targetY - hrp.Position.Y
        BodyVelo.Velocity = Vector3.new(0, diff * 5, 0)
    else
        if BodyVelo then 
            BodyVelo:Destroy() 
            BodyVelo = nil
        end
    end
end


task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoFarm then 
            ToggleFlight(false)
            continue 
        end
        
        local char = GetChar()
        local hrp = GetHRP()
        local hum = GetHum()
        
        if not hrp or not hum or hum.Health <= 0 then continue end
        
        
        CheckObstacle()
        
        
        HandleQuest()
        
        
        local target, dist = GetNearestNPC()
        
        if target and target:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.HumanoidRootPart.Position
            
            if Settings.FarmMethod == "Above" then
               
                local hoverPos = targetPos + Vector3.new(0, Settings.FlightHeight, 0)
                ToggleFlight(true, hoverPos.Y)
                hum:MoveTo(hoverPos)
            else
                ToggleFlight(false)
                hum:MoveTo(targetPos)
            end
            
            
            if dist < Settings.AttackRange then
                SecureAttack()
            end
        end
    end
end)


StarterGui:SetCore("SendNotification", {
    Title = "KopusHub v6.1",
    Text = "Stabilize Modu Aktif!",
    Duration = 5
})
