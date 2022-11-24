local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Mining Simulator 2", "BloodTheme")
local v8 = require(game:GetService("ReplicatedStorage").LoadModule);

-- GENERAL
local General = Window:NewTab("General")

local GeneralSec = General:NewSection("General")
GeneralSec:NewButton("Claim Group Benefits", "Sends a claim group benefits event", function() 
    game:GetService("ReplicatedStorage").Functions.ClaimGroupBenefits:InvokeServer()
end)
GeneralSec:NewButton("Pickup Factory", "Pickups gems from gem factory", function()
    game:GetService("ReplicatedStorage").Events.ClaimFactoryCraft:FireServer(1)
    game:GetService("ReplicatedStorage").Events.ClaimFactoryCraft:FireServer(2)
    game:GetService("ReplicatedStorage").Events.ClaimFactoryCraft:FireServer(3)
end)

local Settings = General:NewSection("Settings")
Settings:NewToggle("Debug", "Used in development", function(state)
    getgenv().useDebug = state
end)
Settings:NewKeybind("Toggle UI", "Toggles UI", Enum.KeyCode.P, function()
	Library:ToggleUI()
end)