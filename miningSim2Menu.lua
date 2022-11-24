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

local Gamble = Window:NewTab("Crates an Eggs")

local Crates = Gamble:NewSection("Crates")
Crates:NewButton("Open all", "Opens all crates in inventory", function() 
    local crates = v8("Crates")
    for i=1,100 do
        for c in pairs(crates) do
            game:GetService("ReplicatedStorage").Events.OpenCrate:FireServer(c)
            wait(0.01)
        end
    end
end)

local Eggs = Gamble:NewSection("Eggs")
Eggs:NewToggle("Fast Open selected egg", "Sends events so that it is fast", function(state)
    if state then
        local selected = getgenv().selectedEgg
        if not selected then return end
        getgenv().autoEggs = true
        while getgenv().autoEggs do
            game:GetService("ReplicatedStorage").Events.OpenEgg:FireServer(selected, true, true)
            wait(0.5)
        end
    else
        getgenv().autoEggs = false
    end
end)

local object = {}
local eggsNum = 0
for i in pairs(v8("Eggs")) do object[eggsNum]=i eggsNum=eggsNum+1 end

local eggDrop = Eggs:NewDropdown("Egg to open", "Selected egg to be opened by fast open", object, function(selected) 
    getgenv().selectedEgg = selected
end)