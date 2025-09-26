-- no more open src ig 

--[[ example how to use 

getgenv().usertarget = "targetusernameordisplaynamecaseinsensitive"
getgenv().guntool = "[gunname]"

-- here u can add getgenv emote calls but if u dont want emotes u gotta call this like

getgenv().emote = false (or true if u want to activate emote)

-- so now if u want pick random emote u can call it like this (chooseemote cant be called when this is set to true)

getgenv().pickrandomemote = true (or false if u dont want)

-- and now if u want to choose the emote manually u can do this 

getgenv().chooseemote = "hipdance"

here all emotes u can choose

"shake"
"tpose"
"griddy"
"floss
"sturdy"
"ross dance"
"defaultdance"
"gangnamstyle"
"takel"
"bounce"
"whatyouwant"
"hdhheb" = this is HOW DID HE HIT EVERY BEAT aka rambunctious
"aicatance"
"beatdokotonai"
"orangejustice"

keybinds:

j to force stop manually autokill
n to toggle view target (updates everytime)

]]--

-- imagine spending ur time skidding this this is the script btw that runs everything

-- ==== USER CONFIG ==== --
getgenv().guntool        = getgenv().guntool or "[LMG]"
getgenv().usertarget     = getgenv().usertarget or "PlayerNameHere"

-- EMOTE CONFIG
getgenv().emote           = getgenv().emote or false
getgenv().pickrandomemote = getgenv().pickrandomemote or false
getgenv().chooseemote     = getgenv().chooseemote or "hipdance"

-- ==== SERVICES ==== --
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==== VARIABLES ==== --
local orbitRadius       = 14
local orbitSpeed        = 100
local verticalAmplitude = 14
local verticalSpeed     = 100
local waitOrbitRadius   = 350
local waitOrbitSpeed    = 150
local freezePosition    = Vector3.new(-168.20, 451.96, -1059.95)

local localPlayer       = Players.LocalPlayer
local character         = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local backpack          = localPlayer:WaitForChild("Backpack")
local humanoid          = character:WaitForChild("Humanoid")
local root              = character:WaitForChild("HumanoidRootPart")
local camera            = workspace.CurrentCamera

local stopScript        = false
local viewingTarget     = false
local angle             = 0
local verticalAngle     = 0
local waitAngle         = 0

-- ==== EMOTE STORAGE ==== --
local emoteStorage = {}
local function addAnimation(name)
    if not emoteStorage[name] then emoteStorage[name] = {} end
    local obj = {}
    function obj.anim(assetid)
        table.insert(emoteStorage[name], assetid)
        return obj
    end
    return obj
end

-- ADD ALL EMOTES
addAnimation("hipdance").anim("138316142522795")
addAnimation("shake").anim("11710541744")
addAnimation("tpose").anim("11710524200")
addAnimation("griddy").anim("11710529220")
addAnimation("floss").anim("10714340543")
addAnimation("sturdy").anim("11710524717")
addAnimation("ross dance").anim("11710527244")
addAnimation("defaultdance").anim("11710529975")
addAnimation("gangnamstyle").anim("129764254213842")
addAnimation("takel").anim("96962864622354")
addAnimation("bounce").anim("129357062468183")
addAnimation("whatyouwant").anim("115781688996859")
addAnimation("hdhheb").anim("136095999219650")
addAnimation("aicatance").anim("137982048325793")
addAnimation("beatdokotonai").anim("122639636262924")
addAnimation("orangejustice").anim("110146282544198")

-- ==== EMOTE LOGIC ==== --
local selectedEmoteId
if getgenv().emote then
    if getgenv().pickrandomemote then
        local allAnims = {}
        for _, tbl in pairs(emoteStorage) do
            for _, id in ipairs(tbl) do
                table.insert(allAnims, id)
            end
        end
        if #allAnims > 0 then
            selectedEmoteId = allAnims[math.random(1,#allAnims)]
        end
    else
        local chosenTbl = emoteStorage[getgenv().chooseemote]
        if chosenTbl and #chosenTbl > 0 then
            selectedEmoteId = chosenTbl[1]
        end
    end
end

local hipdanceTrack
if selectedEmoteId then
    local animObj = Instance.new("Animation")
    animObj.AnimationId = "rbxassetid://"..selectedEmoteId
    hipdanceTrack = humanoid:LoadAnimation(animObj)
    hipdanceTrack.Looped = true
    hipdanceTrack:Play()
end

-- ==== TOOL / TARGET LOGIC ==== --
local function findToolCI(name)
    local lname = string.lower(name)
    for _, container in ipairs({character, backpack}) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and string.lower(tool.Name) == lname then
                return tool
            end
        end
    end
    return nil
end

local function findTargetCI(name)
    local lname = string.lower(name)
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(plr.Name), lname, 1, true) or string.find(string.lower(plr.DisplayName), lname, 1, true) then
            return plr
        end
    end
    return nil
end

local targetPlayer = findTargetCI(getgenv().usertarget)
if not targetPlayer then
    warn("Target '".. tostring(getgenv().usertarget) .."' not found!")
    return
end

local function equipTool()
    local tool = findToolCI(getgenv().guntool)
    if tool then
        tool.Parent = character
        humanoid:EquipTool(tool)
        return tool:FindFirstChild("Handle")
    end
    warn(getgenv().guntool .. " not found!")
    return nil
end

local handle = equipTool()
if not handle then return end

-- ==== ORBIT / STOMP ==== --
local function orbitWaitPosition()
    waitAngle += waitOrbitSpeed * RunService.RenderStepped:Wait()
    local offset = Vector3.new(math.cos(waitAngle)*waitOrbitRadius, math.sin(waitAngle*2)*5, math.sin(waitAngle)*waitOrbitRadius)
    root.Anchored = false
    root.CFrame = CFrame.new(freezePosition+offset, freezePosition)
end

local function disableSeats()
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
            seat.Disabled = true
        end
    end
end

local function updateTargetReferences()
    targetPlayer = findTargetCI(getgenv().usertarget)
    if targetPlayer and targetPlayer.Character then
        targetChar = targetPlayer.Character
        targetBodyEffects = targetChar:WaitForChild("BodyEffects")
        targetKO = targetBodyEffects:WaitForChild("K.O")
        targetDead = targetBodyEffects:WaitForChild("Dead")
        targetRoot = targetChar:WaitForChild("HumanoidRootPart")
        targetHead = targetChar:WaitForChild("Head")
        targetStompPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetRoot
    end
end

local function orbitAndShoot()
    if targetChar:FindFirstChildOfClass("ForceField") then
        orbitWaitPosition()
        return
    end
    if hipdanceTrack and not hipdanceTrack.IsPlaying then
        hipdanceTrack:Play()
    end
    angle += orbitSpeed*RunService.RenderStepped:Wait()
    verticalAngle += verticalSpeed*0.01
    local offset = Vector3.new(math.cos(angle)*orbitRadius, math.sin(verticalAngle)*verticalAmplitude, math.sin(angle)*orbitRadius)
    if targetRoot then
        local desiredPosition = targetRoot.Position + offset
        root.Anchored = false
        root.CFrame = CFrame.new(desiredPosition, targetRoot.Position)
    end
    if not character:FindFirstChild(getgenv().guntool) then
        handle = equipTool()
    end
    if ReplicatedStorage:FindFirstChild("MainEvent") and targetRoot and targetHead then
        ReplicatedStorage.MainEvent:FireServer("ShootGun", handle, targetRoot.Position, targetHead.Position, targetHead, Vector3.new(0,0,-1))
    end
end

local function stompLoop()
    if not (targetKO and targetDead and targetStompPart) then return end
    while targetKO.Value == true and targetDead.Value == false and targetStompPart and not stopScript do
        root.Anchored = false
        root.CFrame = CFrame.new(targetStompPart.Position + Vector3.new(0, 2.95, 0))
        if ReplicatedStorage:FindFirstChild("MainEvent") then
            ReplicatedStorage.MainEvent:FireServer("Stomp")
        end
        RunService.RenderStepped:Wait()
    end
end

-- ==== KEYBINDS ==== --
local toggleViewConnection
toggleViewConnection = UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.J then
        stopScript = true
        viewingTarget = false
        camera.CameraSubject = humanoid
        if hipdanceTrack and hipdanceTrack.IsPlaying then hipdanceTrack:Stop() end
        print("Script manually stopped.")
    elseif input.KeyCode == Enum.KeyCode.N then
        viewingTarget = not viewingTarget
        camera.CameraSubject = viewingTarget and (targetRoot or humanoid) or humanoid
    end
end)

-- ==== MAIN LOOP ==== --
task.spawn(function()
    disableSeats()
    while not stopScript do
        updateTargetReferences()
        if not targetChar or not targetRoot then
            orbitWaitPosition()
            continue
        end
        while targetChar:FindFirstChildOfClass("ForceField") and not stopScript do
            orbitWaitPosition()
        end
        if stopScript then break end
        if targetDead.Value == false and targetRoot and targetHead then
            orbitAndShoot()
            if targetKO.Value == true then
                stompLoop()
            end
        else
            if hipdanceTrack and hipdanceTrack.IsPlaying then hipdanceTrack:Stop() end
            orbitWaitPosition()
        end
        RunService.RenderStepped:Wait()
    end
    if hipdanceTrack and hipdanceTrack.IsPlaying then hipdanceTrack:Stop() end
    if toggleViewConnection then toggleViewConnection:Disconnect() end
    camera.CameraSubject = humanoid
end)

-- ==== AUTO RELOAD AMMO ==== --
local player = Players.LocalPlayer
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = player.Character
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo", true)
            if ammo and ammo:IsA("ValueBase") and ammo.Value == 0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                repeat task.wait(0.1) until not ammo or ammo.Value > 0
            end
        end
    end
end)

print("true120")
print("2.8 loaded.")
