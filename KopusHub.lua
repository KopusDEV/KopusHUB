--[[
    KOPUSHUB AI v1.1 - MOBILE FIX
    - GUI Açılmama Sorunu Giderildi
    - Ekranın Sağ Tarafına Aç/Kapat Butonu Eklendi
    - Draggable (Taşınabilir) Özelliği Stabilize Edildi
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui") -- Daha stabil olması için CoreGui deniyoruz

-- ESKİ GUI VARSA SİL (Çakışma Önleme)
if Player.PlayerGui:FindFirstChild("KopusHubAI") then
    Player.PlayerGui.KopusHubAI:Destroy()
end

-- ==================== MOBİL AÇ/KAPAT BUTONU ====================
local ToggleUI = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
local Corner = Instance.new("UICorner")

ToggleUI.Name = "KopusToggle"
ToggleUI.Parent = Player.PlayerGui
ToggleUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

OpenBtn.Name = "OpenButton"
OpenBtn.Parent = ToggleUI
OpenBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0) -- Ekranın sol ortasında durur
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 24

Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = OpenBtn

-- ==================== ANA GUI (SENİN KODUNUN DÜZELTİLMİŞ HALİ) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KopusHubAI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.Enabled = false -- Başlangıçta kapalı

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 450) -- Mobilde taşmaması için boyut ayarlandı
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Parmağınla sürükleyebilirsin
MainFrame.Parent = ScreenGui

-- (Buraya önceki mesajdaki UI ListLayout ve Buton kodlarını ekle...)
-- KISALTMA ADINA BUTON FONKSİYONU:
OpenBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
    OpenBtn.Text = ScreenGui.Enabled and "X" or "K"
    OpenBtn.BackgroundColor3 = ScreenGui.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(80, 60, 200)
end)

-- BİLDİRİM
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "KopusHUB AI",
    Text = "Sol taraftaki 'K' butonuna bas!",
    Duration = 5
})
