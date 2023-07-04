local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary, funcs = engoware.entity, engoware.GuiLibrary, engoware.funcs
local mouse = lplr:GetMouse()
local workspace = game.Workspace
local remotes, modules = {}, {}
local Hitboxes = {}
local whitelist = {};
local shalib = loadstring(funcs:require("lib/sha.lua"))()
local cam = game.Workspace.Camera
local origC0 = game.ReplicatedStorage.Assets.Viewmodel.RightHand.RightWrist.C0

------
do 
    local AddSpeed = 0
    local LinearVelocity, BodyVelocity
    local SpeedValue, SpeedOptions, SpeedMode = {}, {}, {}
    local Speed = {}; Speed = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "Speed",
        Function = function(callback) 
            if callback then

                funcs:bindToHeartbeat("SpeedBackgroundTasks", function(dt) 
                    if not entity.isAlive then 
                        return
                    end

                    if SpeedOptions.Values.bhop.Enabled then 
                        local State = entity.character.Humanoid:GetState()
                        local MoveDirection = entity.character.Humanoid.MoveDirection
                        if State == Enum.HumanoidStateType.Running and MoveDirection ~= Vector3.zero then 
                            entity.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end

                    if SpeedOptions.Values.pulse.Enabled then 
                        if AddSpeed > (SpeedValue.Value * 1.5) then
                            AddSpeed = -(SpeedValue.Value * 1.5)
                        else
                            AddSpeed = AddSpeed + 1
                        end
                    end
                end)

                funcs:bindToHeartbeat("Speed", function(dt) 
                    if not entity.isAlive then 
                        return
                    end

                    local Speed = SpeedValue.Value + AddSpeed
                    local Humanoid = entity.character.Humanoid
                    local RootPart = entity.character.HumanoidRootPart
                    local MoveDirection = Humanoid.MoveDirection
                    local Velocity = RootPart.Velocity
                    local X, Z = MoveDirection.X * Speed, MoveDirection.Z * Speed

                    if SpeedMode.Value == 'velocity' then 
                        RootPart.Velocity = Vector3.new(X, Velocity.Y, Z)
                    elseif SpeedMode.Value == 'cframe' then
                        local Factor = Speed - Humanoid.WalkSpeed
                        local MoveDirection = (MoveDirection * Factor) * dt
                        local NewCFrame = RootPart.CFrame + Vector3.new(MoveDirection.X, 0, MoveDirection.Z)

                        RootPart.CFrame =  NewCFrame
                    elseif SpeedMode.Value == 'linearvelocity' then
                        LinearVelocity = entity.character.HumanoidRootPart:FindFirstChildOfClass("LinearVelocity") or Instance.new("LinearVelocity", entity.character.HumanoidRootPart)
                        LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
                        LinearVelocity.Attachment0 = entity.character.HumanoidRootPart:FindFirstChildOfClass("Attachment")
                        LinearVelocity.MaxForce = 9e9
                        LinearVelocity.LineDirection = MoveDirection
                        LinearVelocity.LineVelocity = (MoveDirection.X ~= 0 and MoveDirection.Z) and Speed or 0
                    elseif SpeedMode.Value == 'assemblylinearvelocity' then
                        RootPart.AssemblyLinearVelocity = Vector3.new(X, Velocity.Y, Z)
                    elseif SpeedMode.Value == 'bodyvelocity' then
                        BodyVelocity = entity.character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity", entity.character.HumanoidRootPart)
                        BodyVelocity.Velocity = Vector3.new(X, 0, Z)
                        BodyVelocity.MaxForce = Vector3.new(9e9, 0, 9e9)
                    end
                end)

            else
                AddSpeed = 0
                funcs:unbindFromHeartbeat("SpeedBackgroundTasks")
                funcs:unbindFromHeartbeat("Speed")
                if LinearVelocity then 
                    LinearVelocity:Destroy()
                    LinearVelocity = nil
                end
                if BodyVelocity then 
                    BodyVelocity:Destroy()
                    BodyVelocity = nil
                end
            end
        end
    })
    SpeedMode = Speed.CreateDropdown({
        Name = "mode",
        List = {"cframe", "velocity", "linearvelocity", "assemblylinearvelocity", "bodyvelocity"},
        Default = "cframe",
        Function = function(value) 
            if Speed.Enabled then 
                Speed.Toggle()
                Speed.Toggle()
            end
        end
    })
    SpeedOptions = Speed.CreateMultiDropdown({
        Name = "options",
        List = {"bhop", "pulse"},
        --Default = {""},
        Function = function(value) 
            if Speed.Enabled then 
                Speed.Toggle()
                Speed.Toggle()
            end
        end
    })
    SpeedValue = Speed.CreateSlider({
        Name = "value",
        Min = 0,
        Max = 100,
        Default = 20,
        Round = 1,
        Function = function(value) 
            if Speed.Enabled then 
                Speed.Toggle()
                Speed.Toggle()
            end
        end
    })
end


do 
    local Fly = {}
    local FlyMode = {}
    local FlyValue = {}
    local FlyVertical = {}
    local FlyVerticalValue = {}
    local LinearVelocity, AlignPosition
    Fly = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "fly",
        Function = function(callback) 
            if callback then 
                funcs:bindToHeartbeat("Fly", function(dt) 
                    if not entity.isAlive then 
                        return
                    end

                    local Speed = FlyValue.Value
                    local Humanoid = entity.character.Humanoid
                    local RootPart = entity.character.HumanoidRootPart
                    local MoveDirection = Humanoid.MoveDirection
                    local Velocity = RootPart.Velocity
                    local X, Z = MoveDirection.X * Speed, MoveDirection.Z * Speed
                    local FlyVDirection = 0
                    if FlyVertical.Enabled then
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then 
                            FlyVDirection = FlyVerticalValue.Value
                        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                            FlyVDirection = -FlyVerticalValue.Value
                        end
                    end

                    if FlyMode.Value == 'velocity' then 
                        RootPart.Velocity = Vector3.new(X, FlyVDirection, Z)
                    elseif FlyMode.Value == 'cframe' then
                        local Factor = Speed - Humanoid.WalkSpeed
                        local MoveDirection = (MoveDirection * Factor) * dt
                        local NewCFrame = RootPart.CFrame + Vector3.new(MoveDirection.X, FlyVDirection * dt, MoveDirection.Z)

                        RootPart.Velocity = Vector3.new(Velocity.X, 0, Velocity.Y)
                        RootPart.CFrame =  NewCFrame
                    elseif FlyMode.Value == 'linearvelocity' then
                        LinearVelocity = entity.character.HumanoidRootPart:FindFirstChildOfClass("LinearVelocity") or Instance.new("LinearVelocity", entity.character.HumanoidRootPart)
                        LinearVelocity.Attachment0 = entity.character.HumanoidRootPart:FindFirstChildOfClass("Attachment")
                        LinearVelocity.MaxForce = 9e9
                        LinearVelocity.VectorVelocity = Vector3.new(X, FlyVDirection, Z)
                    elseif FlyMode.Value == 'assemblylinearvelocity' then
                        RootPart.AssemblyLinearVelocity = Vector3.new(X, FlyVDirection, Z)
                    end
                end)
            else
                funcs:unbindFromHeartbeat("Fly")
                if LinearVelocity then 
                    LinearVelocity:Destroy()
                    LinearVelocity = nil
                end
                if AlignPosition then
                    AlignPosition:Destroy()
                    AlignPosition = nil
                end

            end
        end,
    })
    FlyMode = Fly.CreateDropdown({
        Name = "mode",
        List = {"cframe", "velocity", "linearvelocity", "assemblylinearvelocity"},
        Default = "cframe",
        Function = function(value) 
            if Fly.Enabled then 
                Fly.Toggle()
                Fly.Toggle()
            end
        end
    })
    FlyValue = Fly.CreateSlider({
        Name = "value",
        Min = 0,
        Max = 100,
        Default = 20,
        Round = 1,
        Function = function(value) 
            if Fly.Enabled then 
                Fly.Toggle()
                Fly.Toggle()
            end
        end
    })
    FlyVertical = Fly.CreateToggle({
        Name = "vertical",
        Default = true,
        Function = function(value) 
            if Fly.Enabled then 
                Fly.Toggle()
                Fly.Toggle()
            end
        end
    })
    FlyVerticalValue = Fly.CreateSlider({
        Name = "vertical value",
        Min = 0,
        Max = 100,
        Default = 20,
        Round = 1,
        Function = function(value) 
            if Fly.Enabled then 
                Fly.Toggle()
                Fly.Toggle()
            end
        end
    })
end





local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
local itemtablefunc = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta
local itemstuff = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1)
local itemtable = debug.getupvalue(itemtablefunc, 1)
local itemmeta = require(game:GetService("ReplicatedStorage").TS.item["item-meta"])
 
local KnockbackTable = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)

local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
  
do 
    local killaurarange = 22

function getinv(plr)
    local plr = plr or lplr
    local thingy, thingytwo = pcall(function() return InventoryUtil.getInventory(plr) end)
    return (thingy and thingytwo or {
        items = {},
        armor = {},
        hand = nil
    })
end

function getsword()
    local sd
    local higherdamage
    local swordslots
    local swords = getinv().items
    for i, v in pairs(swords) do
        if v.itemType:lower():find("sword") or v.itemType:lower():find("blade") then
            if higherdamage == nil or itemstuff[v.itemType].sword.damage > higherdamage then
                sd = v
                higherdamage = itemstuff[v.itemType].sword.damage
                swordslots = i
            end
        end
    end
    return sd, swordslots
end

 
    local Killaura = {}; Killaura = GuiLibrary.Objects.combatWindow.API.CreateOptionsButton({
        Name = "killaura",
        Function = function(callback) 
            if callback then 
             
                coroutine.wrap(function() 
                 
repeat
    task.wait()
    local playertohit
    for i,v in pairs(game.Players:GetChildren()) do
    if v.TeamColor ~= game.Players.LocalPlayer.TeamColor and v.Name ~= game.Players.LocalPlayer.Name and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character:FindFirstChild("HumanoidRootPart").Position - game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < killaurarange then
    playertohit = v
    local sword = getsword()
    local args = {
        [1] = {
            ["chargedAttack"] = {
                ["chargeRatio"] = 0
            },
            ["entityInstance"] = playertohit.Character,
            ["validate"] = {
            ["targetPosition"] = {
                ["value"] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            },
            ["selfPosition"] = {
                ["value"] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            }
        },
            ["weapon"] = sword.tool
        }
    }
                            
    game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit:FireServer(unpack(args))
                    end
                    end
    until nil
                end)()
               
            else
print("no")
            end
        end
    })

end







do 
  

 
    local vv = {}; vv = GuiLibrary.Objects.combatWindow.API.CreateOptionsButton({
        Name = "No KB",
        Function = function(callback) 
            if callback then 
                            
KnockbackTable["kbDirectionStrength"] = 0
KnockbackTable["kbUpwardStrength"] = 0
               
            else
                             
KnockbackTable["kbDirectionStrength"] = 100
KnockbackTable["kbUpwardStrength"] = 100
            end
        end
    })

end


 
 do 
    local NukerBlocks = {table.unpack(game:GetService("CollectionService"):GetTagged("bed"))}
    game:GetService("CollectionService"):GetInstanceAddedSignal("bed"):Connect(function(bed) 
        NukerBlocks[#NukerBlocks+1] = bed
    end)

    local NukerRange = {}
    local Nuker = {}; Nuker = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "nuker",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat task.wait(1/3)

                        if not entity.isAlive then
                            continue
                        end

                        for i,v in next, NukerBlocks do 
                            if (v.Position - entity.character.HumanoidRootPart.Position).Magnitude <= NukerRange.Value then 
                                if v:GetAttribute("Team" .. lplr:GetAttribute("Team") .. "NoBreak") then
                                    continue
                                end

                                if not modules.BlockEngine:isBlockBreakable({blockPosition = modules.BlockEngine:getBlockPosition(v.Position)}, lplr) then
                                    continue
                                end

                                if not v or not v.Parent then 
                                    continue
                                end
                                
                                local targetBlock, targetNormal

                                if v.Name == 'bed' then 
                                    local otherSide = funcs:getOtherSideBed(v)
                                    local normal1, power1 = funcs:getBestNormal(v.Position)
                                    local normal2, power2 = Enum.NormalId.Bottom, 9999e99999
                                    if otherSide then
                                        normal2, power2 = funcs:getBestNormal(otherSide.Position)
                                    end

                                    if power1 < power2 then 
                                        targetBlock = v
                                        targetNormal = normal1
                                    else
                                        targetBlock = otherSide
                                        targetNormal = normal2
                                    end
                                end

                                targetBlock, targetNormal = funcs:getBacktrackedBlock((targetBlock or v).Position, targetNormal)

                                if not targetBlock then
                                    targetBlock = v 
                                end

                                if not targetNormal then
                                    targetNormal = funcs:getBestNormal(v.Position)
                                end

                                funcs:breakBlock(targetBlock, targetNormal)
                            end
                        end

                    until not Nuker.Enabled
                end)()
            end
        end
    })
    NukerRange = Nuker.CreateSlider({
        Name = "range",
        Default = 29,
        Min = 1,
        Max = 29,
        Round = 1,
        Function = function() end
    })
end






















do 
    local NoFall = {}; NoFall = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "nofall",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat 
                       	Client:Get("GroundHit"):SendToServer()
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
