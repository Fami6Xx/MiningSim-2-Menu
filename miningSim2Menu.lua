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

--TELEPORTING
local Teleport = Window:NewTab("Teleport")
local TelSec = Teleport:NewSection("World an Checkpoint")

local worlds = {}
local worldsNum = 1
for i in pairs(v8("Worlds")) do worlds[worldsNum]=i worldsNum=worldsNum+1 end
TelSec:NewDropdown("World to Teleport", "Select world to teleport", worlds, function(selected)
    getgenv().selectedWorld = selected
    getgenv().selectedCheckpoint = nil

    generateCheckpoints(selected)
end)

local checkpointDropdown = TelSec:NewDropdown("Checkpoint to Teleport", "Select checkpoint, not required", {}, function(selected)
    getgenv().selectedCheckpoint = selected
end)

function generateCheckpoints(world)
    local checkpoints = {}
    local checkpointsNum = 1
    for i in pairs(v8("Worlds")[world].Layers) do
        if v8("Worlds")[world].Layers[i].Checkpoint then
            checkpoints[checkpointsNum] = v8("Worlds")[world].Layers[i].Checkpoint.Name
            checkpointsNum = checkpointsNum + 1
        end
    end
    checkpointDropdown:Refresh(checkpoints)
end

TelSec:NewButton("Teleport!", "Teleports to selected world and checkpoint", function()
    if not getgenv().selectedWorld then return end
    if not getgenv().selectedCheckpoint then
        game:GetService("ReplicatedStorage").Events.Teleport:FireServer(getgenv().selectedWorld)
    else
        game:GetService("ReplicatedStorage").Events.Teleport:FireServer(getgenv().selectedCheckpoint)
    end
end)

-- MINING
local Mining = Window:NewTab("Mining")

local AutoMine = Mining:NewSection("AutoMine")
AutoMine:NewToggle("AutoMine", "Automines below you", function(state)
 -- Autmining
end)
AutoMine:NewSlider("Mining pause", "Time between mining in ms (150ms is suggested)", 1000, 0, function(s)
    getgenv().waitBetweenMining = s / 1000
end)
AutoMine:NewSlider("Search radius", "Radius in which algorithm will search for ores (5)", 10, 1, function(s)
    getgenv().mineSearchRadius = s
end)