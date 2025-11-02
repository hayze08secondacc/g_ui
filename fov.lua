getgenv().autofovenabled = true
getgenv().fovvalue = 90

local fuckassplrs=game:GetService("Players")
local goddamnrun=game:GetService("RunService")
local shitcam=workspace.CurrentCamera

goddamnrun.Heartbeat:Connect(function()
 if getgenv().autofovenabled and shitcam.FieldOfView~=getgenv().fovvalue then
  shitcam.FieldOfView=math.clamp(getgenv().fovvalue,70,120)
 end
end)
