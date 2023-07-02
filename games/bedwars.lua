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
               print("wat")

            else

                print("fsdefsdfdf")
            end
        end,
    })
end


local KnockbackTable = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)

   
do 
   
   
    local vel 
    local velocity = {}; velocity = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "Velocity",
        Function = function(callback) 
            if callback then 
              
KnockbackTable["kbDirectionStrength"] = vel
KnockbackTable["kbUpwardStrength"] = vel
            else
               
KnockbackTable["kbDirectionStrength"] = 100
KnockbackTable["kbUpwardStrength"] = 100
            end
        end
    })
  
    vel = velocity.CreateSlider({
        Name = "value",
        Min = 0,
        Max = 100,
        Default = 20,
        Round = 1,
        Function = function(value) 
            if velocity.Enabled then 
                velocity.Toggle()
                velocity.Toggle()
            end
        end
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
