-- TimeClient.lua
-- LETAK: StarterGui (LocalScript)
-- Membuat GUI jam yang modern & kecil di pojok kanan bawah.
-- GUI akan dibuat setiap spawn (StarterGui -> PlayerGui), dan mendengarkan ReplicatedStorage value.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- tunggu folder TimeSystem (server mungkin belum buat saat player join)
local timeFolder = ReplicatedStorage:WaitForChild("TimeSystem")
local minutesValue = timeFolder:WaitForChild("Minutes")

-- Hentikan pembuatan duplikat jika sudah ada
local EXISTING = playerGui:FindFirstChild("TimeGui")
if EXISTING then
    EXISTING:Destroy()
end

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimeGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = true -- biar tetap clean saat respawn (LocalScript di StarterGui akan dijalankan lagi)

-- Frame utama (rounded + gradient)
local frame = Instance.new("Frame")
frame.Name = "ClockFrame"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -18, 1, -18) -- pojok kanan bawah (padding 18)
frame.Size = UDim2.new(0, 160, 0, 44)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.fromRGB(18,18,20)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Parent = frame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,22))
}
gradient.Rotation = 90

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.7
stroke.Parent = frame

-- Shadow (subtle)
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://0" -- kosong: gunakan full transparency
shadow.Parent = frame

-- Icon (sun / moon)
local icon = Instance.new("TextLabel")
icon.Name = "Icon"
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.Position = UDim2.new(0, 10, 0.5, 0)
icon.Size = UDim2.new(0, 34, 0, 34)
icon.BackgroundTransparency = 1
icon.Font = Enum.Font.GothamBlack
icon.TextSize = 20
icon.Text = "☀️"
icon.TextScaled = false
icon.Parent = frame

-- Time text
local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.AnchorPoint = Vector2.new(0, 0.5)
timeLabel.Position = UDim2.new(0, 54, 0.5, 0)
timeLabel.Size = UDim2.new(0, 90, 0, 34)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(200, 255, 235)
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 22
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Text = "00:00"
timeLabel.Parent = frame

-- small subtitle (AM/PM atau Day)
local subLabel = Instance.new("TextLabel")
subLabel.Name = "SubLabel"
subLabel.AnchorPoint = Vector2.new(1, 0)
subLabel.Position = UDim2.new(1, -10, 0, 6)
subLabel.Size = UDim2.new(0, 48, 0, 16)
subLabel.BackgroundTransparency = 1
subLabel.TextColor3 = Color3.fromRGB(170,170,170)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 12
subLabel.Text = "Day"
subLabel.Parent = frame

-- Utility function: update GUI from minutes integer
local function updateGUIFromMinutes(totalMinutes)
    local minutes = totalMinutes % 60
    local hours = math.floor(totalMinutes / 60) % 24

    local timeText = string.format("%02d:%02d", hours, minutes)
    -- day/night icon
    local isDay = hours >= 6 and hours < 18

    -- small tween for text change (scale pop)
    timeLabel.Text = timeText
    icon.Text = isDay and "☀️" or "🌙"
    subLabel.Text = isDay and "Day" or "Night"

    -- subtle color change for day/night
    if isDay then
        timeLabel.TextColor3 = Color3.fromRGB(200,255,235)
    else
        timeLabel.TextColor3 = Color3.fromRGB(160,200,255)
    end
end

-- Initial update (in case value already ada)
if minutesValue.Value then
    updateGUIFromMinutes(minutesValue.Value)
end

-- Connect perubahan value (server akan mengubah tiap detik)
minutesValue.Changed:Connect(function(newVal)
    -- safety check
    if typeof(newVal) ~= "number" then return end
    updateGUIFromMinutes(newVal)
end)

-- Pastikan GUI tidak hilang: (LocalScript di StarterGui dijalankan ulang saat respawn).
-- Jika kamu mau GUI tetap persisten antar respawn tanpa recreation, set ResetOnSpawn = false
-- Namun standar Roblox: menaruh LocalScript di StarterGui sudah cukup agar GUI muncul tiap spawn.
