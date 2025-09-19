-- open src now

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local targetName = getgenv("usernametarget")
local toolName = getgenv("tooltarget")
if not targetName then warn("Please set getgenv('usernametarget')") return end
if not toolName then warn("Please set getgenv('tooltarget')") return end
local orbitRadius = 15
local orbitSpeed = 0.8
local verticalAmplitude = 5
local verticalSpeed = 2
local freezePosition = Vector3.new(-168.20, 451.96, -1059.95)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local backpack = localPlayer:WaitForChild("Backpack")
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local stopScript = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if input.KeyCode == Enum.KeyCode.J then
stopScript = true
print("Script stopped manually.")
end
end)
local targetPlayer = Players:FindFirstChild(targetName)
if not targetPlayer then
warn("Target not found!")
return
end
local angle = 0
local verticalAngle = 0
local function equipTool()
local tool = character:FindFirstChild(toolName) or backpack:FindFirstChild(toolName)
if tool then
tool.Parent = character
humanoid:EquipTool(tool)
return tool:FindFirstChild("Handle")
end
warn(toolName.." not found!")
return nil
end
local handle = equipTool()
if not handle then return end
local function resetOrbitPhase()
angle = 0
verticalAngle = 0
end
local function teleportAndFreeze(position)
root.Anchored = false
root.CFrame = CFrame.new(position)
task.wait(0.05)
root.Anchored = true
end
local function updateTargetReferences()
targetPlayer = Players:FindFirstChild(targetName)
if targetPlayer and targetPlayer.Character then
targetChar = targetPlayer.Character
targetBodyEffects = targetChar:WaitForChild("BodyEffects")
targetKO = targetBodyEffects:WaitForChild("K.O")
targetDead = targetBodyEffects:WaitForChild("Dead")
targetRoot = targetChar:WaitForChild("HumanoidRootPart")
targetHead = targetChar:WaitForChild("Head")
targetLeftLowerArm = targetChar:WaitForChild("LeftLowerArmFake")
end
end
local function orbitAndShoot()
angle = angle + orbitSpeed
verticalAngle = verticalAngle + verticalSpeed * 0.01
local offset = Vector3.new(math.cos(angle) * orbitRadius, math.sin(verticalAngle) * verticalAmplitude, math.sin(angle) * orbitRadius)
if targetRoot then
local desiredPosition = targetRoot.Position + offset
root.CFrame = CFrame.new(desiredPosition, targetRoot.Position)
end
if not character:FindFirstChild(toolName) then
handle = equipTool()
end
if ReplicatedStorage:FindFirstChild("MainEvent") and targetRoot and targetHead then
ReplicatedStorage.MainEvent:FireServer("ShootGun", handle, targetRoot.Position, targetHead.Position, targetHead, Vector3.new(0,0,-1))
end
end
local function stompLoop()
if not (targetKO and targetDead and targetLeftLowerArm) then return end
while targetKO.Value == true and targetDead.Value == false and not stopScript do
root.CFrame = CFrame.new(targetLeftLowerArm.Position + Vector3.new(0,5,0))
if ReplicatedStorage:FindFirstChild("MainEvent") then
ReplicatedStorage.MainEvent:FireServer("Stomp")
end
RunService.RenderStepped:Wait()
end
end
task.spawn(function()
while not stopScript do
updateTargetReferences()
if not targetChar or not targetRoot then
RunService.RenderStepped:Wait()
continue
end
if targetDead.Value == true then
teleportAndFreeze(freezePosition)
repeat
updateTargetReferences()
RunService.RenderStepped:Wait()
until targetDead.Value == false and not (targetChar:FindFirstChildOfClass("ForceField")) or stopScript
resetOrbitPhase()
root.Anchored = false
end
if stopScript then break end
while targetChar:FindFirstChildOfClass("ForceField") and not stopScript do
RunService.RenderStepped:Wait()
end
if targetDead.Value == false and not stopScript then
orbitAndShoot()
if targetKO.Value == true then
stompLoop()
end
end
RunService.RenderStepped:Wait()
end
end)
