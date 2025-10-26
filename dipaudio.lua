--[[
██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗███████╗
██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██║   ██║██╔════╝
███████║██║   ██║██║   ██║█████╔╝ ██║   ██║███████╗
██╔══██║██║   ██║██║   ██║██╔═██╗ ██║   ██║╚════██║
██║  ██║╚██████╔╝╚██████╔╝██║  ██╗╚██████╔╝███████║
╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
HOOKVZ (public audio script)
]]--
local locals={}
locals.remote_url="https://www.dropbox.com/scl/fi/pycr545pw2riqn6minjs6/onyx.mp3?rlkey=5rd6zyyuiny28rld8vv8tr85p&st=z939qz02&dl=1"
locals.local_filename="onyx.mp3"
locals.http_request_fn=(syn and syn.request)or(http and http.request)or request or http_request or(function(opts)error("no http request function")end)
locals.writefile_fn=writefile or write_file or(syn and syn.io.write_file)
locals.isfile_fn=isfile or is_file or(syn and syn.io.is_file)
locals.getsynasset_fn=getsynasset or getcustomasset
locals.can_http=function()return type(locals.http_request_fn)=="function"end
locals.can_writefile=function()return type(locals.writefile_fn)=="function"end
locals.can_getsynth=function()return type(locals.getsynasset_fn)=="function"end
locals.download_binary=function(url)
if not locals.can_http()then return nil,"no http request function"end
local ok,res=pcall(function()
if syn and syn.request then return syn.request({Url=url,Method="GET"})
elseif http and http.request then return http.request({url=url,method="GET"})
elseif request then return request({Url=url,Method="GET"})
else return locals.http_request_fn({Url=url,Method="GET"})end
end)
if not ok then return nil,"http request failed: "..tostring(res)end
local body=nil
if type(res)=="table"then
body=res.Body or res.body or res[1]
local code=res.StatusCode or res.status or res.Status
if code and tonumber(code)>=400 then return nil,"http status "..tostring(code)end
elseif type(res)=="string"then body=res end
if not body then return nil,"no http response body"end
return body
end
locals.save_to_workspace=function(name,data)
if not locals.can_writefile()then return false,"no writefile"end
local ok,err=pcall(function()locals.writefile_fn(name,data)end)
if not ok then return false,"writefile failed: "..tostring(err)end
return true
end
locals.file_exists=function(name)
if locals.isfile_fn then
local ok,res=pcall(function()return locals.isfile_fn(name)end)
if ok and res then return true end
end
return false
end
locals.convert_to_asset=function(name)
if not locals.can_getsynth()then return nil,"no getsynasset"end
local ok,res=pcall(function()return locals.getsynasset_fn(name)end)
if ok and res then return res end
return nil,"getsynasset failed"
end
locals.asset_token=nil
if locals.file_exists(locals.local_filename)and locals.can_getsynth()then
local ok,token_or_err=pcall(function()return locals.getsynasset_fn(locals.local_filename)end)
if ok and token_or_err then
locals.asset_token=token_or_err
print("[audio] found file -> "..locals.local_filename)
else
warn("[audio] file exists but getsynasset failed: "..tostring(token_or_err))
end
end
if not locals.asset_token then
print("[audio] downloading from: "..tostring(locals.remote_url))
local body,err=locals.download_binary(locals.remote_url)
if not body then error("[audio] download failed: "..tostring(err))end
if not locals.can_writefile()then error("[audio] no writefile, place file manually")end
local ok,serr=locals.save_to_workspace(locals.local_filename,body)
if not ok then error("[audio] save failed: "..tostring(serr))end
print("[audio] saved as: "..locals.local_filename)
if locals.can_getsynth()then
local token,terr=locals.convert_to_asset(locals.local_filename)
if token then
locals.asset_token=token
print("[audio] converted to asset")
else
warn("[audio] convert failed: "..tostring(terr))
end
else
error("[audio] no getsynasset, can't play file")
end
end
if not locals.asset_token then error("[audio] no playable asset")end
locals.created_sound=nil
local ok,err=pcall(function()
local s=Instance.new("Sound")
s.Name="executor_download_loop_audio"
s.SoundId=locals.asset_token
s.Looped=true
s.Volume=1
s.Parent=game:GetService("SoundService")or locals.Workspace
s:Play()
locals.created_sound=s
end)
if not ok then error("[audio] failed to play sound: "..tostring(err))end
getgenv().stop_executor_loop_audio=function()
pcall(function()
if locals.created_sound then
if locals.created_sound.Playing then locals.created_sound:Stop()end
locals.created_sound:Destroy()
locals.created_sound=nil
print("[audio] stopped and destroyed")
end
end)
end
print("[audio] playing loop. call stop_executor_loop_audio() to stop.")
