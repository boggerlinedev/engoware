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



do
    local OldFOV
    local Connection, Connection2
    local FOVValue, FOVMode = {}, {}
    local FOV = {}; FOV = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "fovchanger",
        Function = function(callback, wasKeyDown) 
            if callback then 
                OldFOV = OldFOV or workspace.CurrentCamera.FieldOfView
                if FOVMode.Value == 'zoom' and not wasKeyDown then 
                    FOV.Toggle()
                    return
                end
                workspace.CurrentCamera.FieldOfView = FOVValue.Value
                Connection = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function() 
                    if workspace.CurrentCamera.FieldOfView ~= FOVValue.Value then 
                        workspace.CurrentCamera.FieldOfView = FOVValue.Value
                    end
                end)
                if FOVMode.Value == 'zoom' then
                    Connection2 = game:GetService("UserInputService").InputEnded:Connect(function(input) 
                        if input.KeyCode.Name == FOV.Bind then
                            Connection2:Disconnect()
                            Connection2 = nil
                            FOV.Toggle()
                        end
                    end)
                end
            else
                if Connection then 
                    Connection:Disconnect()
                    Connection = nil
                end
                workspace.CurrentCamera.FieldOfView = OldFOV
            end
        end
    }) 
    FOVMode = FOV.CreateDropdown({
        Name = "mode",
        Default = "set",
        List = {"set", "zoom"},
        Function = function() end
    })
    FOVValue = FOV.CreateSlider({
        Name = "value",
        Min = 10,
        Max = 120,
        Round = 0,
        Default = 90,
        Function = function(value) 
            if FOV.Enabled then
                workspace.CurrentCamera.FieldOfView = value
            end
        end
    })
end




do 
    local Worker = funcs:newWorker()

    local Old = {}
    local Override = {
        GlobalShadows = false,
        Brightness = 1.5,
        --Ambient = Color3.fromRGB(255, 255, 255),
        ClockTime = 12,   
    }
    local Fullbright={}; Fullbright = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "fullbright",
        Function = function(callback) 
            if callback then 
                for i,v in next, Override do 
                    if type(v)=='function' then v() continue end
                    Old[i] = game:GetService("Lighting")[i]
                    game:GetService("Lighting")[i] = v
                    Worker:add(game:GetService("Lighting"):GetPropertyChangedSignal(i):Connect(function() 
                        if game:GetService("Lighting")[i] ~= v then 
                            game:GetService("Lighting")[i] = v
                        end
                    end))
                end
            else
                Worker:clean()
                for i,v in next, Old do 
                    if typeof(v)=='Instance' then v:Destroy() continue end
                    game:GetService("Lighting")[i] = v
                    Old[i] = nil
                end
            end
        end
    })
end



do 
    --   local old = {}
    _G.yes = false
       local Sca = {}; Sca = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
           Name = "Scaffold",
           Function = function(callback) 
               if callback then 
                   print("true")
                   
    _G.yes = true
    
    
    local lplr = game.Players.LocalPlayer
    local BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
    local BlockEngineClientEvents = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents
    local BlockController = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine
    local BlockControllertw = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer
   
    
    
    
    
        local oldpos = Vector3.zero
            local oldpos2 = Vector3.zero
    
            local function getScaffold(vec, diagonaltoggle)
                local realvec = vec3(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
                local newpos = (oldpos - realvec)
                local returedpos = realvec
                if yesz == true then
                    local angle = math.deg(math.atan2(-entity.character.Humanoid.MoveDirection.X, -entity.character.Humanoid.MoveDirection.Z))
                    local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
                    if goingdiagonal and ((newpos.X == 0 and newpos.Z ~= 0) or (newpos.X ~= 0 and newpos.Z == 0)) and diagonaltoggle then
                        return oldpos
                    end
                end
                return realvec
            end
    
            local function getwool()
                local block = nil
                local blocks = {}
                local prefer = math.random(1,2)
                local choosen = "wool_green"
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("InventoryFolder") then
                    for i,v in pairs(game.Players.LocalPlayer.Character.InventoryFolder.Value:GetChildren()) do
                        if string.find(v.Name,"wool") then
                            block = v
                        end
                    end
                    if block then
                        return block.Name,block:GetAttribute("Amount")
                    end
                end
            end
    
            local blocktable = BlockControllertw.new(BlockEngine, getwool())
            local animplaying = false
    
    
            function placeblocks(newpos)
                local placeblocktype = getwool()
                blocktable.blockType = placeblocktype
                task.spawn(function()
                    scaffoldanim:Play()
                    task.wait(.2)
                    stop:Play()
                    task.wait(.2)
                end)
                if BlockController:isAllowedPlacement(lplr, placeblocktype, Vector3.new(math.round(newpos.X / 3 + .5), math.round(newpos.Y / 3), math.round(newpos.Z / 3))) then
                    blocktable:placeBlock(Vector3.new(math.round(newpos.X / 3), math.round(newpos.Y / 3), math.round(newpos.Z / 3)))
                end
            end
    
            local UserInputService = game:GetService("UserInputService")
            function Scaffold_Main()
                local spaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                local Player = game.Players.LocalPlayer
                local HRP = Player.Character.HumanoidRootPart
                local raydown = true
                if spaceHeld then
                    game.Players.LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(game.Players.LocalPlayer.Character.PrimaryPart.Velocity.X,35,game.Players.LocalPlayer.Character.PrimaryPart.Velocity.Z)
                end
                placeblocks(game.Players.LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(0,0,-1) - Vector3.new(0,5,0))
            end
            repeat
                task.wait()
                task.spawn(function()
                    Scaffold_Main()
                end)
            until _G.yes == false 
   
               else
                _G.yes = false
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
