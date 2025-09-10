-- TimeServer.lua
-- LETAK: ServerScriptService (Script)
-- Server-authoritative time system dengan smooth day/night cycle + dynamic skybox

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Config
local START_HOUR = 6            -- jam awal (6 = 06:00)
local MINUTES_PER_REAL_SECOND = 1  -- 1 real second = 1 in-game minute
local DAY_MINUTES = 24 * 60

-- ReplicatedStorage setup
local folder = ReplicatedStorage:FindFirstChild("TimeSystem")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "TimeSystem"
    folder.Parent = ReplicatedStorage
end

local minutesValue = folder:FindFirstChild("Minutes")
if not minutesValue then
    minutesValue = Instance.new("IntValue")
    minutesValue.Name = "Minutes"
    minutesValue.Parent = folder
    minutesValue.Value = START_HOUR * 60
end

-- Internal state
local robloxMinutes = minutesValue.Value % DAY_MINUTES
local accumulator = 0

-- Utility: Lerp Color3
local function lerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

-- Lighting profiles
local profiles = {
    Dawn = {
        Brightness = 2,
        Ambient = Color3.fromRGB(180, 150, 150),
        OutdoorAmbient = Color3.fromRGB(180, 150, 150),
        FogColor = Color3.fromRGB(255, 200, 200),
        FogEnd = 500,
        ExposureCompensation = 0,
        ShadowSoftness = 0.4,
    },
    Day = {
        Brightness = 3,
        Ambient = Color3.fromRGB(200, 200, 200),
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        FogColor = Color3.fromRGB(255, 255, 255),
        FogEnd = 1000,
        ExposureCompensation = 0.2,
        ShadowSoftness = 0.6,
    },
    Dusk = {
        Brightness = 2,
        Ambient = Color3.fromRGB(180, 140, 160),
        OutdoorAmbient = Color3.fromRGB(200, 150, 180),
        FogColor = Color3.fromRGB(200, 150, 180),
        FogEnd = 600,
        ExposureCompensation = -0.1,
        ShadowSoftness = 0.5,
    },
    Night = {
        Brightness = 1,
        Ambient = Color3.fromRGB(100, 100, 130),
        OutdoorAmbient = Color3.fromRGB(80, 80, 100),
        FogColor = Color3.fromRGB(80, 80, 100),
        FogEnd = 400,
        ExposureCompensation = -0.3,
        ShadowSoftness = 0.3,
    }
}

-- Smooth blending
local function blendProfiles(p1, p2, t)
    local result = {}
    for k, v in pairs(p1) do
        if typeof(v) == "number" then
            result[k] = v + (p2[k] - v) * t
        elseif typeof(v) == "Color3" then
            result[k] = lerpColor(v, p2[k], t)
        end
    end
    return result
end

local function applyLightingProfile(profile)
    Lighting.Brightness = profile.Brightness
    Lighting.Ambient = profile.Ambient
    Lighting.OutdoorAmbient = profile.OutdoorAmbient
    Lighting.FogColor = profile.FogColor
    Lighting.FogEnd = profile.FogEnd
    Lighting.ExposureCompensation = profile.ExposureCompensation
    Lighting.ShadowSoftness = profile.ShadowSoftness
end

-- Skybox setup
local sky = Lighting:FindFirstChildOfClass("Sky")
if not sky then
    sky = Instance.new("Sky")
    sky.Name = "DynamicSky"
    sky.Parent = Lighting
end

-- Skybox assets (bisa ganti dengan asset ID favoritmu)
local Skyboxes = {
    Day = {
        SkyboxBk = "rbxassetid://271042516", -- awan siang
        SkyboxDn = "rbxassetid://271077243",
        SkyboxFt = "rbxassetid://271042556",
        SkyboxLf = "rbxassetid://271042310",
        SkyboxRt = "rbxassetid://271042467",
        SkyboxUp = "rbxassetid://271077958",
    },
    Night = {
        SkyboxBk = "rbxassetid://141749403", -- malam berbintang
        SkyboxDn = "rbxassetid://141749414",
        SkyboxFt = "rbxassetid://141749425",
        SkyboxLf = "rbxassetid://141749440",
        SkyboxRt = "rbxassetid://141749449",
        SkyboxUp = "rbxassetid://141749464",
    }
}

local function applySkybox(skyData)
    for k, v in pairs(skyData) do
        sky[k] = v
    end
end

-- Ambil profile lighting + sky berdasarkan jam
local function getProfileForTime(minutes)
    local hours = (minutes / 60) % 24

    if hours >= 5 and hours < 8 then -- dawn
        local t = (hours - 5) / 3
        return blendProfiles(profiles.Dawn, profiles.Day, t), "Day"
    elseif hours >= 8 and hours < 17 then -- day
        return profiles.Day, "Day"
    elseif hours >= 17 and hours < 20 then -- dusk
        local t = (hours - 17) / 3
        return blendProfiles(profiles.Dusk, profiles.Night, t), "Night"
    elseif hours >= 20 or hours < 5 then -- night
        return profiles.Night, "Night"
    else
        return profiles.Day, "Day"
    end
end

-- Initial apply
local profile, skyType = getProfileForTime(robloxMinutes)
applyLightingProfile(profile)
applySkybox(Skyboxes[skyType])

-- Heartbeat loop
RunService.Heartbeat:Connect(function(dt)
    accumulator = accumulator + dt
    if accumulator >= 1 then
        local wholeSeconds = math.floor(accumulator)
        accumulator = accumulator - wholeSeconds

        local minutesToAdd = wholeSeconds * MINUTES_PER_REAL_SECOND
        robloxMinutes = (robloxMinutes + minutesToAdd) % DAY_MINUTES

        minutesValue.Value = robloxMinutes

        local hours = math.floor(robloxMinutes / 60)
        local mins = robloxMinutes % 60
        Lighting.ClockTime = hours + (mins / 60)

        local profile, skyType = getProfileForTime(robloxMinutes)
        applyLightingProfile(profile)
        applySkybox(Skyboxes[skyType])
    end
end)
