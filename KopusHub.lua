-- KOPUSHUB AI v1.0 - FULL CONTENT FIX
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ==================== AYARLAR ====================
local Settings = {
    AutoFarm = false,
    FarmMethod = "Above",
    FlightHeight = 25,
    AutoQuest = true,
    FruitSniper = true,
}

-- ==================== GUI ANA YAPI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- YANDAKİ "K" BUTONU (MOBİL İÇİN)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- ANA ÇERÇEVE
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 450)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.Visible = false -- K'ye basınca açılacak
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- BAŞLIK
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
Title.Text = "🤖 KOPUSHUB AI v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

-- İÇERİK ALANI (TÜM BUTONLAR BURAYA GELECEK)
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 0) -- Otomatik güncellenecek
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==================== GUI FONKSİYONLARI (FIXED) ====================
local function AddSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(0.95, 0, 0, 35)
    section.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
    section.Text = "  " .. title
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = Content -- Content içine ekleniyor
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
end

local function AddToggle(text, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(40, 40, 50)
    btn.Text = text .. (getter() and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = Content -- Content içine ekleniyor
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        local v = not getter()
        setter(v)
        btn.BackgroundColor3 = v and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(40, 40, 50)
        btn.Text = text .. (v and " [ON]" or " [OFF]")
    end)
end

-- ==================== BUTONLARI OLUŞTUR ====================
AddSection("🤖 ANA KONTROLLER")
AddToggle("Auto Farm", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)
AddToggle("Fruit Sniper", function() return Settings.FruitSniper end, function(v) Settings.FruitSniper = v end)

AddSection("⚙️ AYARLAR")
AddToggle("Auto Quest", function() return Settings.AutoQuest end, function(v) Settings.AutoQuest = v end)

-- Kaydırma alanını buton sayısına göre güncelle
Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

-- AÇ/KAPAT MANTIĞI
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "KopusHUB", Text = "Yüklendi! K'ye bas."})
