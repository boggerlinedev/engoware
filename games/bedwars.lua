local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary, funcs = engoware.entity, engoware.GuiLibrary, engoware.funcs
local mouse = lplr:GetMouse()
local remotes, modules = {}, {}
local Hitboxes = {}
local whitelist = {};
local shalib = loadstring(funcs:require("lib/sha.lua"))()






do 
    local NoFall = {}; NoFall = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "nofall",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat 
                        remotes.FallRemote:FireServer()
                        task.wait(5)
                    until not NoFall.Enabled
                end)()
            end
        end,
    })
end



--[[do 
    local NoRender = {}; NoRender = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "norender",
        Function = function(callback) 
            if callback then 
                
            end
        end,
    })
end]]
