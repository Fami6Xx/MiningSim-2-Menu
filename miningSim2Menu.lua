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
    if state then
        if getgenv().useDebug then print("Booting AutoMine up") end
        getgenv().autoMineToggled = true
        if not getgenv().waitBetweenMining then getgenv().waitBetweenMining = 0.15 end
        if not getgenv().mineSearchRadius then getgenv().mineSearchRadius = 5 end
        local getBackpackStatus = v8("GetBackpackStatus")
        local getWorld = v8("GetWorld");
        local chunkUtil = v8("ChunkUtil");
        local constants = v8("Constants")
        local blocks = v8("Blocks")
        
        local rayCastParams = RaycastParams.new();
        rayCastParams.CollisionGroup = constants.CollisionGroups.MineRaycast;
        
        local lp = game.Players.LocalPlayer
        local startWorld = getWorld.fromPlayer(lp)
        
        local neighbours = false
        
        -- Mining
        function handleMine(position, root, checkBlock)
            local rayDirection = position - root
            local rayCastResult = game:GetService("Workspace"):Raycast(root, rayDirection, rayCastParams)
            
            if getgenv().useDebug and neighbours then print("NEIGHBOURS - CALLED - RCR -", rayCastResult) end
            if getgenv().useDebug and neighbours and not rayCastResult then print("NEIGHBOURS - CALLED - RD -", rayDirection) end
            
            if not rayCastResult then return end
            
            if getgenv().useDebug and neighbours then rayCastResult.Instance.Color = Color3.fromRGB(150, 25, 55) end
            
            if checkBlock and blocks[rayCastResult.Instance.Name].Type == "Block" then return end
            local pos = chunkUtil.worldToCell(rayCastResult.Position - rayCastResult.Normal)
            game:GetService("ReplicatedStorage").Events.MineBlock:FireServer(Vector3.new(pos.x, pos.y, pos.z))
            
            if not (blocks[rayCastResult.Instance.Name].Type == "Block") then
                wait(getgenv().waitBetweenMining)
                if getgenv().useDebug then print("HANDLEMINE - CALLING NEIGHBOURS") end
                local nextPos = rayCastResult.Position - rayCastResult.Normal
                neighbours = true
                handleMine(Vector3.new(nextPos.x + getgenv().mineSearchRadius, nextPos.y, nextPos.z), nextPos, true)
                neighbours = true
                handleMine(Vector3.new(nextPos.x - getgenv().mineSearchRadius, nextPos.y, nextPos.z), nextPos, true)
                neighbours = true
                handleMine(Vector3.new(nextPos.x, nextPos.y + getgenv().mineSearchRadius, nextPos.z), nextPos, true)
                neighbours = true
                handleMine(Vector3.new(nextPos.x, nextPos.y - getgenv().mineSearchRadius, nextPos.z), nextPos, true)
                neighbours = true
                handleMine(Vector3.new(nextPos.x, nextPos.y, nextPos.z + getgenv().mineSearchRadius), nextPos, true)
                neighbours = true
                handleMine(Vector3.new(nextPos.x, nextPos.y, nextPos.z - getgenv().mineSearchRadius), nextPos, true)
                neighbours = false
                if getgenv().useDebug then print("HANDLEMINE - NEIGHBOURS CALLED") end
            end
        end

        -- Teleport
        function bypass_teleport(v)
            local tween_s = game:GetService('TweenService')
            local tweeninfo = TweenInfo.new(1,Enum.EasingStyle.Linear)
            
            if lp.Character and 
            lp.Character:FindFirstChild('HumanoidRootPart') then
                local cf = CFrame.new(v)
                local a = tween_s:Create(lp.Character.HumanoidRootPart,tweeninfo,{CFrame=cf})
                
                a:Play()
                a.Completed:Wait()
            end
        end
        
        if getgenv().useDebug then print("Booted, starting Loop") end
        while getgenv().autoMineToggled do
            wait(getgenv().waitBetweenMining * 10)
            
            while not getBackpackStatus().Full do
                if not getgenv().autoMineToggled then break end
                local lpPos = lp.Character.HumanoidRootPart.Position;
                handleMine(Vector3.new(lpPos.x - getgenv().mineSearchRadius, lpPos.y, lpPos.z), lp.Character.HumanoidRootPart.Position, true)
                handleMine(Vector3.new(lpPos.x + getgenv().mineSearchRadius, lpPos.y, lpPos.z), lp.Character.HumanoidRootPart.Position, true)
                handleMine(Vector3.new(lpPos.x, lpPos.y, lpPos.z - getgenv().mineSearchRadius), lp.Character.HumanoidRootPart.Position, true)
                handleMine(Vector3.new(lpPos.x, lpPos.y, lpPos.z + getgenv().mineSearchRadius), lp.Character.HumanoidRootPart.Position, true)
                wait(getgenv().waitBetweenMining)
                handleMine(Vector3.new(lpPos.x, lpPos.y - getgenv().mineSearchRadius, lpPos.z), lp.Character.HumanoidRootPart.Position, false)
            end
            if not getgenv().autoMineToggled then break end
            local position = lp.Character.HumanoidRootPart.Position
            
            game:GetService("ReplicatedStorage").Events.Teleport:FireServer(v8("GetSellTeleport")(lp))
            wait(getgenv().waitBetweenMining * 2)
            game:GetService("ReplicatedStorage").Events.QuickSell:FireServer()
            wait(getgenv().waitBetweenMining * 2)
            bypass_teleport(position)
        end
    else
        getgenv().autoMineToggled = false
        if getgenv().useDebug then print("Turning automine off") end
    end
end)
AutoMine:NewSlider("Mining pause", "Time between mining in ms (150ms is suggested)", 1000, 0, function(s)
    getgenv().waitBetweenMining = s / 1000
end)
AutoMine:NewSlider("Search radius", "Radius in which algorithm will search for ores (5)", 10, 1, function(s)
    getgenv().mineSearchRadius = s
end)