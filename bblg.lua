local plr=game.Players.LocalPlayer local cam=workspace.CurrentCamera
local desiredFOV=350
local function lockFOV() cam.FieldOfView=desiredFOV end
lockFOV()
cam:GetPropertyChangedSignal("FieldOfView"):Connect(function() if cam.FieldOfView~=desiredFOV then cam.FieldOfView=desiredFOV end end)
task.spawn(function() while task.wait(0.1) do if cam.FieldOfView~=desiredFOV then cam.FieldOfView=desiredFOV end end end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/vnausea/absence-mini/refs/heads/main/absencemini.lua"))()
