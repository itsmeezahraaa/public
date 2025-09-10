-- Script: TimeSystem.lua
-- Taruh di StarterPlayer > StarterPlayerScripts

-- Buat ScreenGui + TextLabel untuk jam
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimeGui"
screenGui.Parent = playerGui

local clockLabel = Instance.new("TextLabel")
clockLabel.Size = UDim2.new(0, 200, 0, 50)
clockLabel.Position = UDim2.new(1, -210, 1, -60) -- pojok kanan bawah
clockLabel.BackgroundTransparency = 0.3
clockLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
clockLabel.BorderSizePixel = 0
clockLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
clockLabel.Font = Enum.Font.GothamBold
clockLabel.TextSize = 28
clockLabel.TextStrokeTransparency = 0.5
clockLabel.Text = "00:00"
clockLabel.Parent = screenGui

-- Buat efek rounded corner modern
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = clockLabel

-- Buat shadow biar keren
local shadow = Instance.new("TextLabel")
shadow.Size = clockLabel.Size
shadow.Position = UDim2.new(0, 2, 0, 2)
shadow.BackgroundTransparency = 1
shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
shadow.Font = clockLabel.Font
shadow.TextSize = clockLabel.TextSize
shadow.TextTransparency = 0.6
shadow.Text = clockLabel.Text
shadow.ZIndex = clockLabel.ZIndex - 1
shadow.Parent = clockLabel

-- Sistem waktu Roblox
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local minutesPerRealSecond = 60 -- 1 detik nyata = 1 menit Roblox
local robloxMinutes = 6 * 60 -- start jam 06:00 pagi

RunService.Heartbeat:Connect(function(dt)
    robloxMinutes = robloxMinutes + (minutesPerRealSecond * dt)
    if robloxMinutes >= 24 * 60 then
        robloxMinutes = robloxMinutes - 24 * 60
    end

    -- Konversi menit ke jam:menit
    local hours = math.floor(robloxMinutes / 60)
    local minutes = math.floor(robloxMinutes % 60)

    -- Update Lighting (day/night)
    Lighting.ClockTime = hours + minutes / 60

    -- Format jam ke GUI
    local timeText = string.format("%02d:%02d", hours, minutes)
    clockLabel.Text = timeText
    shadow.Text = timeText
end)
