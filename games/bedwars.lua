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
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local TweenService = game:GetService("TweenService") 
local char = lplr.Character
 


  local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
  do
      function RunLoops:BindToRenderStep(name, num, func)
          if RunLoops.RenderStepTable[name] == nil then
              RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
          end
      end
  
      function RunLoops:UnbindFromRenderStep(name)
          if RunLoops.RenderStepTable[name] then
              RunLoops.RenderStepTable[name]:Disconnect()
              RunLoops.RenderStepTable[name] = nil
          end
      end
  
      function RunLoops:BindToStepped(name, num, func)
          if RunLoops.StepTable[name] == nil then
              RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
          end
      end
  
      function RunLoops:UnbindFromStepped(name)
          if RunLoops.StepTable[name] then
              RunLoops.StepTable[name]:Disconnect()
              RunLoops.StepTable[name] = nil
          end
      end
  
      function RunLoops:BindToHeartbeat(name, num, func)
          if RunLoops.HeartTable[name] == nil then
              RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
          end
      end
  
      function RunLoops:UnbindFromHeartbeat(name)
          if RunLoops.HeartTable[name] then
              RunLoops.HeartTable[name]:Disconnect()
              RunLoops.HeartTable[name] = nil
          end
      end
  end




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
    until not Killaura.Enabled
                end)()
               
            else
print("no")
            end
        end
    })

end







do 
  

 
    local vv = {}; vv = GuiLibrary.Objects.combatWindow.API.CreateOptionsButton({
        Name = "No Knockback",
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

local BreakingMsg = false
 local Distance = {["Value"] = 30}

    local params = RaycastParams.new()
    params.IgnoreWater = true

    function NukerFunction(part)
        local raycastResult = game:GetService("Workspace"):Raycast(part.Position + Vector3.new(0,24,0),Vector3.new(0,-27,0),params)
        if raycastResult then
            local targetblock = raycastResult.Instance
            for i,v in pairs(targetblock:GetChildren()) do
                if v:IsA("Texture") then
                    v:Destroy()
                end
            end
            targetblock.Color = Color3.fromRGB(255,65,65)
            targetblock.Material = Enum.Material.Neon
        game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@easy-games"):WaitForChild("block-engine"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DamageBlock"):InvokeServer({
                ["blockRef"] = {
                    ["blockPosition"] = Vector3.new(math.round(targetblock.Position.X/3),math.round(targetblock.Position.Y/3),math.round(targetblock.Position.Z/3))
                },
                ["hitPosition"] = Vector3.new(math.round(targetblock.Position.X/3),math.round(targetblock.Position.Y/3),math.round(targetblock.Position.Z/3)),
                ["hitNormal"] = Vector3.new(math.round(targetblock.Position.X/3),math.round(targetblock.Position.Y/3),math.round(targetblock.Position.Z/3))
            })
            if BreakingMsg == false then
                BreakingMsg = true
               -- CreateNotification("Nuker","Breaking Bed..",3)
                spawn(function()
                    task.wait(3)
                    BreakingMsg = false
                end)
            end
        end
    end
    
function GetBeds()
        local beds = {}
        for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
            if string.lower(v.Name) == "bed" and v:FindFirstChild("Covers") ~= nil and v:FindFirstChild("Covers").BrickColor ~= lplr.Team.TeamColor then
                table.insert(beds,v)
            end
        end
        return beds
    end
    local beds = GetBeds()
    

    local NukerRange = {}
    local Nuker = {}; Nuker = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "Bed Banger",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                repeat task.wait()
                for i,v in pairs(beds) do
                     local mag = (v.Position - lplr.Character.PrimaryPart.Position).Magnitude
                                if mag < Distance["Value"] then
                                    NukerFunction(v)
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


do 
    --   local old = {}
   
    
    local lplr = game.Players.LocalPlayer
    local BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
    local BlockEngineClientEvents = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents
    local BlockController = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine
    local BlockControllertw = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer
    local cam = game.Workspace.Camera
    local origC0 = game.ReplicatedStorage.Assets.Viewmodel.RightHand.RightWrist.C0
    
    
    
    
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
       local Sca = {}; Sca = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
           Name = "Scaffoldd",
           Function = function(callback) 
               if callback then 
                   print("true")
                   
    
    
           
            coroutine.wrap(function() 
                repeat 
                    task.wait()
                task.spawn(function()
                    Scaffold_Main()
                end)
                      
                until not Sca.Enabled
            end)()
   
               
               end
           end
       })
   end


 




      
do 
    --   local old = {}
   
local bedwarss = {


    ["KnockbackTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),
  ["sprintTable"] = KnitClient.Controllers.SprintController,
    }
    
       local sss = {}; sss = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
           Name = "Auto Sprint",
           Function = function(callback) 
               if callback then 
                   print("true")
                   
    
    
           
            coroutine.wrap(function() 
                repeat 
                    task.wait()
                   	bedwarss["sprintTable"]:startSprinting()
                      
                until not sss.Enabled
            end)()
   
               
               end
           end
       })
   end



   
do 
    local TracersColorMode, TracersPosition, TracersThickness, TracersFrom, OnlyBehind, TracerTransparency = {}, {}, {}, {}, {}, {}
    local tracers = {}
    local drawings = {}
    local done = {}
    tracers = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "tracers",
        Function = function(callback) 
            if callback then 
                funcs:bindToRenderStepped("Tracers", function(dt) 
                    for _, v in next, drawings do 
                        v.Visible = false
                    end
                    for _, v in next, entity.entityList do 

                        if not funcs:isAlive(v.Player, true) then 
                            continue 
                        end

                        local Position, Visible, Part
                        if TracersPosition.Value == 'root' then
                            Part = v.RootPart
                        elseif TracersPosition.Value == 'head' then
                            Part = v.Head
                        end

                        Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(Part.Position)
                        if OnlyBehind.Enabled and Visible then
                            continue
                        end
                        if not Visible and TracersFrom.Value ~= "bottom" and not (0 < Position.Z) then 
                            local ObjectSpace = workspace.CurrentCamera.CFrame:PointToObjectSpace(Part.Position)
                            local AngledCalculation = (math.atan2(ObjectSpace.Y, ObjectSpace.X) + math.pi)
                            local CalculatedAngle = CFrame.Angles(0, math.rad(89.9), 0):VectorToWorldSpace(-Vector3.zAxis)
                            local Angle = CFrame.Angles(0, 0, AngledCalculation):VectorToWorldSpace(CalculatedAngle)
                            local WorldSpacePoint = workspace.CurrentCamera.CFrame:PointToWorldSpace(Angle)
                            Position = workspace.CurrentCamera:WorldToViewportPoint(WorldSpacePoint)
                            Visible = true
                        else
                            if TracersFrom.Value == "bottom" and not Visible then 
                                continue
                            end
                        end

                        local Tracer
                        if done[v.Player.Name] then
                            Tracer = drawings[v.Player.Name]
                        else
                            done[v.Player.Name] = true
                            Tracer = Drawing.new("Line")
                            drawings[v.Player.Name] = Tracer
                        end
                        
                        if not Tracer then 
                            continue 
                        end

                        local ViewportSize = workspace.CurrentCamera.ViewportSize
                        local From, To = nil, Vector2.new(Position.X, Position.Y)
                        if TracersFrom.Value == 'middle' then
                            From = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
                        elseif TracersFrom.Value == 'bottom' then
                            From = Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                        elseif TracersFrom.Value == 'top' then
                            From = Vector2.new(ViewportSize.X / 2, 0)
                        elseif TracersFrom.Value == 'mouse' then
                            From = UIS:GetMouseLocation()
                        end

                        Tracer.Color = funcs:getColorFromEntity(v, TracersColorMode.Value == 'team', TracersColorMode.Value == 'color theme')
                        Tracer.Thickness = TracersThickness.Value
                        Tracer.Visible = true
                        Tracer.Transparency = TracerTransparency.Value
                        Tracer.From = From
                        Tracer.To = To
                    end
                end)
            else
                funcs:unbindFromRenderStepped("Tracers")
                for i,v in next, drawings do 
                    v:Remove()
                    drawings[i] = nil
                end
                done = {}
            end
        end,
    })
    TracersFrom = tracers.CreateDropdown({
        Name = "from",
        Default = 'middle',
        List = {"middle", "bottom", "top", "mouse"},
        Function = function() end
    })
    TracersPosition = tracers.CreateDropdown({
        Name = "position",
        Default = 'head',
        List = {"head", "root"},
        Function = function() end
    })
    TracersColorMode = tracers.CreateDropdown({
        Name = "color mode",
        Default = 'team',
        List = {"none", "team", "color theme"},
        Function = function() end
    })
    TracersThickness = tracers.CreateSlider({
        Name = "thickness",
        Min = 0.25,
        Max = 10,
        Default = 0.5,
        Round = 1,
        Function = function() end
    })
    TracerTransparency = tracers.CreateSlider({
        Name = "transparency",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Round = 2,
        Function = function() end
    })
    OnlyBehind = tracers.CreateToggle({
        Name = "only behind",
        Default = false,
        Function = function() end
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

     
do 
    --   local old = {}
  
    
       local cs = {}; cs = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
           Name = "Chest Stealer",
           Function = function(callback) 
               if callback then 
                   print("true")
                   
    
    
           
            coroutine.wrap(function() 
                   repeat
        task.wait(0.1)
        if lplr then
            for i,v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
                if (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude < 18 and v:FindFirstChild("ChestFolderValue") then
                    local chest = v:FindFirstChild("ChestFolderValue")
                    chest = chest and chest.Value or nil
                    local chestitems = chest and chest:GetChildren() or {}
                    if chestitems  then
                        Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
                        for i3, v3 in pairs(chestitems) do
                            if v3:IsA("Accessory") then
                                spawn(function()
                                    pcall(function()
                                        Client:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
                                    end)
                                end)
                            end
                        end
                        Client:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
                    end
                end
            end
        end
    until  not cs.Enabled
            end)()
   
               
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
    local hasTeleported = false 
    function findNearestBed()
           local nearestBed = nil
           local minDistance = math.huge
           
           for _,v in pairs(game.Workspace:GetDescendants()) do
               if v.Name:lower() == "bed" and v:FindFirstChild("Covers") and v:FindFirstChild("Covers").BrickColor ~= lplr.Team.TeamColor then
                   local distance = (v.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                   if distance < minDistance then
                       nearestBed = v
                       minDistance = distance
                   end
               end
           end
           
           return nearestBed
       end
       function tweenToNearestBed()
           local nearestBed = findNearestBed()
           
           if nearestBed and not hasTeleported then
               hasTeleported = true
   
               local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
               
               local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.97), {CFrame = nearestBed.CFrame + Vector3.new(0, 2, 0)})
               tween:Play()
           end
       end
    
       local bd = {}; bd = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
           Name = "Tp_nearest beds",
           Function = function(callback) 
               if callback then 
                   print("Tping...syn")
                   lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                lplr.CharacterAdded:Connect(function()
                    wait(0.3) 
                    tweenToNearestBed()
               end)
               
    
    
               
               end
           end
       })
   end






     
do 
    local Animrange = 22
    local Anims = {
        ["Slow"] = {
            {CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(90)),Time = 0.25},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
        },
       ["Zyla"] = {
             {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
                {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
                {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1}
        },
        ["Self"] = {
            {CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(90)),Time = 0.25},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
        },
        ["Butcher"] = {
            {CFrame = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)),Time = 0.3},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3}
        },
        ["VerticalSpin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.3},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.3},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.3},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3}
		},
    }
		local endanim = {
        {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
    }
    local endanim = {
        {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
    }
    local DidAttack = false
    local AttackAnim = {["Enabled"] = true}
    local CurrentAnim = {["Value"] = "Zyla"}

    local an = {}; an = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "Killaura Animation",
        Function = function(callback) 
            if callback then 
             
                coroutine.wrap(function() 
                 
repeat
    task.wait()
    local playertohit
    for i,v in pairs(game.Players:GetChildren()) do
    if v.TeamColor ~= game.Players.LocalPlayer.TeamColor and v.Name ~= game.Players.LocalPlayer.Name and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character:FindFirstChild("HumanoidRootPart").Position - game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < Animrange then
        DidAttack = true
            if AttackAnim["Enabled"] then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://4947108314"
                local loader = lplr.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
                loader:LoadAnimation(anim):Play()
                for i,v in pairs(Anims[CurrentAnim["Value"]]) do
                    game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist,TweenInfo.new(v.Time),{C0 = origC0 * v.CFrame}):Play()
                    task.wait(v.Time-0.01)
                end
            end
        
        else
            DidAttack = false
                    end
                    if not DidAttack then
                        for i,v2 in pairs(endanim) do
                            game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist,TweenInfo.new(v2.Time),{C0 = origC0 * v2.CFrame}):Play()
                        end
                    end
                    end
    until not an.Enabled
                end)()
               
            else
print("no")
            end
        end
    })

end



local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
   bedwars = {
    ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController
}

  
do 
    


	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}

    local oldc1
	local oldfunc
    local bob = {}; bob = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "No Bobing",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
repeat wait()

			lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth["Value"] / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal["Value"] / 10))
					pcall(function()
						for i,v in pairs(cam.Viewmodel.Humanoid.Animator:GetPlayingAnimationTracks()) do 
							v:Stop()
						end
					end)
					bedwars["ViewmodelController"]:playAnimation(11)
					oldc1 = cam.Viewmodel.RightHand.RightWrist.C1
					cam.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx["Value"]), math.rad(rotationy["Value"]), math.rad(rotationz["Value"]))
                    until not bob.Enabled
                end)()

            end
        end
    })
  
    nobobdepth = bob.CreateSlider({
        Name = "nobobdepth",
        Min = 0,
        Max = 100,
        Default = 14,
        Round = 1,
        Function = function(value) 
            if bob.Enabled then 
                lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(value / 10))
            
            end
        end
    })
end



   
   


do 

    local heightval = 1
    local safeornot = 1

 
    local inf = {}; inf = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "Infinite Fly",
        Function = function(callback) 
            if callback then 
                safeornot = math.random(1, 7)
                local origy = lplr.Character.HumanoidRootPart.Position.y
                part = Instance.new("Part", workspace)
                part.Size = Vector3.new(1,1,1)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                cam.CameraSubject = part
                RunLoops:BindToHeartbeat("FunnyFlyPart", 1, function()
                    local pos = lplr.Character.HumanoidRootPart.Position
                    part.Position = Vector3.new(pos.x, origy, pos.z)
                end)
                local cf = lplr.Character.HumanoidRootPart.CFrame
                lplr.Character.HumanoidRootPart.CFrame = CFrame.new(cf.x, 300000, cf.z)
                if lplr.Character.HumanoidRootPart.Position.X < 50000 then 
                    lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 100000, 0)
                end
               
            else
  heightval = 0
                task.wait(0.1)
                RunLoops:UnbindFromHeartbeat("FunnyFlyPart")
                local pos = lplr.Character.HumanoidRootPart.Position
                local rcparams = RaycastParams.new()
                rcparams.FilterType = Enum.RaycastFilterType.Whitelist
                rcparams.FilterDescendantsInstances = {workspace.Map}
                rc = workspace:Raycast(Vector3.new(pos.x, 300, pos.z), Vector3.new(0,-1000,0), rcparams)
                if rc and rc.Position then
                    lplr.Character.HumanoidRootPart.CFrame = CFrame.new(rc.Position) * CFrame.new(0,3,0)
                end
                cam.CameraSubject = lplr.Character
                part:Destroy()
                RunLoops:BindToHeartbeat("FunnyFlyVeloEnd", 1, function()
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(rc.Position) * CFrame.new(0,3,0)
                end)
                RunLoops:UnbindFromHeartbeat("FunnyFlyVeloEnd")
            end
        end
    })

end




do 
    	local ReachValue = {Value = 14}
    local bedwars = {
        ["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
    }
    local ra = {}; ra = GuiLibrary.Objects.combatWindow.API.CreateOptionsButton({
        Name = "Range",
        Function = function(callback) 
            if callback then 
                	bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2

            else
                bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
              
            end
        end,
    })

    ReachValue = ra.CreateSlider({
        Name = "value",
        Min = 1,
        Max = 20,
        Round = 0,
        Default = 18,
        Function = function(value) 
            if ra.Enabled then
              bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = value + 2
            end
        end
    })
end






do 

	
local Fraps = Instance.new("ScreenGui")
local Fps = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local Ping = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")
local UIGradient_2 = Instance.new("UIGradient")


Fraps.Name = "Fraps"
Fraps.Parent = game.CoreGui
Fraps.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Fraps.Enabled = false
Fps.Name = "Fps"
Fps.Parent = Fraps
Fps.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Fps.BackgroundTransparency = 0.300
Fps.BorderColor3 = Color3.fromRGB(0, 0, 0)
Fps.BorderSizePixel = 0
Fps.Position = UDim2.new(0.00219940231, 0, 0.8359375, 0)
Fps.Size = UDim2.new(0, 96, 0, 36)
Fps.Font = Enum.Font.Arial
Fps.Text = " Fps: 123"
Fps.TextColor3 = Color3.fromRGB(255, 255, 255)
Fps.TextSize = 22.000
Fps.AutomaticSize = Enum.AutomaticSize.X
Fps.TextWrapped = true
Fps.TextXAlignment = Enum.TextXAlignment.Left

UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Fps

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(21, 255, 228)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 212, 205))}
UIGradient.Parent = Fps

Ping.Name = "Ping"
Ping.Parent = Fraps
Ping.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Ping.BackgroundTransparency = 0.300
Ping.BorderColor3 = Color3.fromRGB(0, 0, 0)
Ping.BorderSizePixel = 0
Ping.Position = UDim2.new(0.0014662724, 0, 0.91796875, 0)
Ping.Size = UDim2.new(0, 60, 0, 36)
Ping.Font = Enum.Font.Arial
Ping.Text = " Ping: 1/2"
Ping.TextColor3 = Color3.fromRGB(255, 255, 255)
Ping.TextSize = 22.000
Ping.TextWrapped = true
Ping.AutomaticSize = Enum.AutomaticSize.X
Ping.TextXAlignment = Enum.TextXAlignment.Left

UICorner_2.CornerRadius = UDim.new(0, 7)
UICorner_2.Parent = Ping

UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(21, 255, 228)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 212, 205))}
UIGradient_2.Parent = Ping


local script = Instance.new('LocalScript', Fps)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(frame) -- This will fire every time a frame is rendered


script.Parent.Text = (" FPS: "..math.round(1/frame)).." "

end)


local Pinge = math.random(10.5,100.45)

local rs = game:GetService("RunService")

rs.RenderStepped:Connect(function()
	Pinge = Pinge + 1
end)



    local stats ={}; stats = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "Status",
        Function = function(callback) 
            if callback then 
				Fraps.Enabled = true

				coroutine.wrap(function() 
                    repeat
						task.wait(0.4)
						Ping.Text = " SPV: " .. Pinge.." "
	Pinge = math.random(0.5,200.45)
                       
                    until not stats.Enabled
                end)()
            else
              Fraps.Enabled = false
            end
        end
    })
end
