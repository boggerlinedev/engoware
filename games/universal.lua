
local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary, funcs = engoware.entity, engoware.GuiLibrary, engoware.funcs
local mouse = lplr:GetMouse()

do 
    local AddSpeed = 0
    local LinearVelocity, BodyVelocity
    local SpeedValue, SpeedOptions, SpeedMode = {}, {}, {}
    local Speed = {}; Speed = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "speed",
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

do 
    local Connections = {}
    local HighJumpMode = {}
    local HighJumpValue = {}
    local HighJump = {}; HighJump = GuiLibrary.Objects.movementWindow.API.CreateOptionsButton({
        Name = "highjump",
        Function = function(callback) 
            if callback then 
                if HighJumpMode.Value == 'toggle' then 
                    if entity.isAlive then 
                        local Velocity = entity.character.HumanoidRootPart.Velocity
                        entity.character.HumanoidRootPart .Velocity = Vector3.new(Velocity.X, Velocity.Y + HighJumpValue.Value, Velocity.Z)
                        HighJump.Toggle()
                    end
                elseif HighJumpMode.Value == 'normal' then
                    local function highjumpfunc(_, new) 
                        if new == Enum.HumanoidStateType.Jumping then 
                            local Velocity = entity.character.HumanoidRootPart.Velocity
                            entity.character.HumanoidRootPart.Velocity = Vector3.new(Velocity.X, Velocity.Y + HighJumpValue.Value, Velocity.Z)
                        end
                    end

                    if entity.isAlive then 
                        Connections[#Connections + 1] = entity.character.Humanoid.StateChanged:Connect(highjumpfunc)
                    end

                    Connections[#Connections + 1] = lplr.CharacterAdded:Connect(function(char) 
                        if not entity.isAlive then 
                            repeat task.wait() until entity.isAlive
                        end

                        char.Humanoid.StateChanged:Connect(highjumpfunc)
                    end)
                end
            else
                for _, Connection in pairs(Connections) do 
                    Connection:Disconnect()
                end
                Connections = {}
            end
        end
    })
    HighJumpMode = HighJump.CreateDropdown({
        Name = "mode",
        List = {"toggle", "normal"},
        Default = "toggle",
        Function = function(value) 
            if HighJump.Enabled then 
                HighJump.Toggle()
            end
        end
    })
    HighJumpValue = HighJump.CreateSlider({
        Name = "value",
        Min = 0,
        Max = 100,
        Default = 20,
        Round = 1,
        Function = function(value) 
            if HighJump.Enabled then 
                HighJump.Toggle()
                HighJump.Toggle()
            end
        end
    })
end

do 
    local ESPColorMode = {}
    local esp = {}
    local drawings = {}
    local done = {}
    esp = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "esp",
        Function = function(callback) 
            if callback then 
                funcs:bindToRenderStepped("ESP", function()
                    for _, v in next, drawings do 
                        if v.Outline then
                            v.Outline.Visible = false
                        end
                        if v.Inner then
                            v.Inner.Visible = false
                        end
                    end
                    for _, v in next, entity.entityList do

                        if not funcs:isAlive(v.Player, true) then continue end

                        local Name = v.Player.Name
                        local ESPOutline, ESPInner
                        if done[Name] then
                            ESPOutline = drawings[Name].Outline
                            ESPInner = drawings[Name].Inner
                        else
                            done[Name] = true
                            drawings[Name] = drawings[Name] or {}
                            ESPOutline = Drawing.new("Square")
                            ESPInner = Drawing.new("Square")
                            drawings[Name].Outline = ESPOutline
                            drawings[Name].Inner = ESPInner
                        end
                        
                        if not ESPOutline or not ESPInner then 
                            return 
                        end

                        ESPOutline.Color = Color3.new(0, 0, 0)
                        ESPOutline.Thickness = 2.7
                        ESPOutline.Visible = false
                        ESPOutline.Transparency = 1
                        ESPOutline.Filled = false
                        ESPInner.Color = funcs:getColorFromEntity(v, ESPColorMode.Value == 'team', ESPColorMode.Value == 'color theme')
                        ESPInner.Thickness = 1
                        ESPInner.Visible = false
                        ESPInner.Transparency = 1
                        ESPInner.Filled = false


                        local topPos, topVis = workspace.CurrentCamera:WorldToViewportPoint((CFrame.new(v.RootPart.Position, v.RootPart.Position + workspace.CurrentCamera.CFrame.LookVector) * CFrame.new(2, 3, 0)).p)
                        local bottomPos, bottomVis = workspace.CurrentCamera:WorldToViewportPoint((CFrame.new(v.RootPart.Position, v.RootPart.Position + workspace.CurrentCamera.CFrame.LookVector) * CFrame.new(-2, -3.5, 0)).p)
                        local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(v.RootPart.Position)
                        if Visible or topVis or bottomVis then 
                            local sizex, sizey = topPos.X - bottomPos.X, topPos.Y - bottomPos.Y
                            ESPInner.Size = Vector2.new(sizex, sizey)
                            ESPOutline.Size = Vector2.new(sizex, sizey)

                            ESPInner.Position = Vector2.new(Position.X - ESPOutline.Size.X / 2, Position.Y - ESPOutline.Size.Y / 2)
                            ESPOutline.Position = Vector2.new(Position.X - ESPOutline.Size.X / 2, Position.Y - ESPOutline.Size.Y / 2)

                            ESPInner.Visible = true
                            ESPOutline.Visible = true
                        else
                            ESPInner.Visible = false
                            ESPOutline.Visible = false
                        end
                    end 
                end)
            else    
                funcs:unbindFromRenderStepped("ESP")
                for i,v in next, drawings do
                    v.Outline:Remove()
                    v.Inner:Remove()
                    drawings[i] = nil
                end
                done = {}
            end
        end
    }) 
    ESPColorMode = esp.CreateDropdown({
        Name = "color mode",
        Default = 'team',
        List = {"none", "team", "color theme"},
        Function = function() end
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

do
    local function formatNametag(ent) 
        if not entity.isAlive then 
            return ("[0] " .. ent.Player.Name .. "| %sHP"):format(math.round(ent.Humanoid.Health))
        end
        return string.format("[%s] %s | %sHP", 
        entity.character.HumanoidRootPart and tostring(math.round((ent.RootPart.Position - entity.character.HumanoidRootPart.Position).Magnitude)) or "N/A",
        ent.Player.Name, 
        tostring(math.round(ent.Humanoid.Health)))
    end
    
    local NametagsColorMode, NametagsScale, NametagsRemoveHumanoidTag = {}, {}, {}
    local Nametags = {}
    local drawings = {}
    local done = {}
    Nametags = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "nametags",
        Function = function(callback) 
            if callback then 
                funcs:bindToRenderStepped("Nametags", function(dt) 
                    for _, v in next, drawings do 
                        if v.Text then 
                            v.Text.Visible = false
                        end
                        if v.BG then 
                            v.BG.Visible = false
                        end
                    end

                    for _, v in next, entity.entityList do 

                        if not funcs:isAlive(v.Player, true) then 
                            continue 
                        end

                        local Name = v.Player.Name
                        local NametagBG, NametagText
                        if done[Name] then
                            NametagText = drawings[Name].Text
                            NametagBG = drawings[Name].BG
                        else
                            done[Name] = true
                            drawings[Name] = drawings[Name] or {}
                            NametagText = Drawing.new("Text")
                            NametagBG = Drawing.new("Square")
                            drawings[Name].Text = NametagText
                            drawings[Name].BG = NametagBG
                        end

                        if not NametagBG or not NametagText then 
                            continue 
                        end

                        local Position, Visible = workspace.CurrentCamera:WorldToViewportPoint(v.Head.Position + Vector3.new(0, 1.75, 0))
                        if Visible then 
                            local XOffset, YOffset = 10, 2

                            NametagText.Text = formatNametag(v)
                            NametagText.Font = 3
                            NametagText.Size = 16 * NametagsScale.Value
                            NametagText.ZIndex = 2
                            NametagText.Visible = true
                            NametagText.Position = Vector2.new(
                                Position.X - (NametagText.TextBounds.X * 0.5),
                                Position.Y - NametagText.TextBounds.Y
                            )
                            NametagText.Color = funcs:getColorFromEntity(v, NametagsColorMode.Value == 'team', NametagsColorMode.Value == 'color theme')
                            NametagBG.Filled = true
                            NametagBG.Color = Color3.new(0, 0, 0)
                            NametagBG.ZIndex = 1
                            NametagBG.Transparency = 0.5
                            NametagBG.Visible = true
                            NametagBG.Position = Vector2.new(
                                ((Position.X - (NametagText.TextBounds.X + XOffset) * 0.5)),
                                (Position.Y - NametagText.TextBounds.Y)
                            )
                            NametagBG.Size = NametagText.TextBounds + Vector2.new(XOffset, YOffset)
                        end

                        if NametagsRemoveHumanoidTag.Enabled then 
                            --pcall(function() 
                                v.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                            --end)
                        end
                    end
                end)
            else
                funcs:unbindFromRenderStepped("Nametags")
                for i,v in next, drawings do 
                    if v.Text then 
                        v.Text:Remove()
                    end
                    if v.BG then 
                        v.BG:Remove()
                    end
                    drawings[i] = nil
                end
                done = {}
            end
        end,
    })
    NametagsColorMode = Nametags.CreateDropdown({
        Name = "color mode",
        Default = 'team',
        List = {"none", "team", "color theme"},
        Function = function() end
    })
    NametagsScale = Nametags.CreateSlider({
        Name = "scale",
        Min = 1,
        Max = 10,
        Default = 1,
        Round = 1,
        Function = function() end
    })
    NametagsRemoveHumanoidTag = Nametags.CreateToggle({
        Name = "anti humanoid tag",
        Function = function() end
    })
end

do 
    local AutoRejoinDelay = {Value = 0}
    local AutoRejoin = {}; AutoRejoin = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "autorejoin",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat task.wait() until not AutoRejoin.Enabled or #game:GetService("CoreGui").RobloxPromptGui.promptOverlay:GetChildren() ~= 0
                    if AutoRejoin.Enabled then 
                        task.wait(AutoRejoinDelay.Value)
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
                    end
                end)()
            end
        end,
    })
    AutoRejoinDelay = AutoRejoin.CreateSlider({
        Name = "delay",
        Function = function(value) end,
        Min = 0,
        Max = 30,
        Round = 0,
    })
end


do 
    local BAV
    local Connections = {}
    local spinbotaxis = {}
    local spinbotvalue = {}
    local spinbot = {}; spinbot = GuiLibrary.Objects.miscWindow.API.CreateOptionsButton({
        Name = "spinbot",
        Function = function(callback) 
            if callback then 
                BAV = Instance.new("BodyAngularVelocity")
                BAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BAV.AngularVelocity = Vector3.new(
                    spinbotaxis.Values.x.Enabled and spinbotvalue.Value or 0,
                    spinbotaxis.Values.y.Enabled and spinbotvalue.Value or 0,
                    spinbotaxis.Values.z.Enabled and spinbotvalue.Value or 0
                )
                BAV.P = spinbotvalue.Value
                if entity.isAlive then 
                    BAV.Parent = entity.character.HumanoidRootPart
                end
                Connections[#Connections+1] = lplr.CharacterAdded:Connect(function(character) 
                    if not entity.isAlive then 
                        repeat task.wait() until entity.isAlive
                    end
                    if BAV then
                        BAV.Parent = character.HumanoidRootPart
                    end
                end)
            else
                if BAV then 
                    BAV:Destroy()
                    BAV = nil
                end
            end 
        end
    })
    spinbotaxis = spinbot.CreateMultiDropdown({
        Name = "axis",
        List = {"x", "y", "z"},
        Default = {"y"},
        Function = function()
            if spinbot.Enabled then 
                spinbot.Toggle()
                spinbot.Toggle()
            end
        end
    })
    spinbotvalue = spinbot.CreateSlider({
        Name = "value",
        Function = function(value) 
            if BAV then 
                BAV.AngularVelocity = Vector3.new(
                    spinbotaxis.Values.x.Enabled and value or 0,
                    spinbotaxis.Values.y.Enabled and value or 0,
                    spinbotaxis.Values.z.Enabled and value or 0
                )
            end
        end,
        Min = -75,
        Max = 75,
        Round = 0,
        Default = 20
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
    local BlinkModes = {}
    local Blink = {}; Blink = GuiLibrary.Objects.exploitsWindow.API.CreateOptionsButton({
        Name = "blink",
        Function = function(callback) 
            if callback then 
                if BlinkModes.Values["incoming"].Enabled then 
                    settings().Network.IncomingReplicationLag = 999e999
                end
                if BlinkModes.Values["outgoing"].Enabled then 
                    funcs:bindToHeartbeat("blink-outgoing", function() 
                        if not entity.isAlive then return end
                        sethiddenproperty(entity.character.HumanoidRootPart, "NetworkIsSleeping", true)
                    end)
                end
            else
                funcs:unbindFromHeartbeat("blink-outgoing")
                settings().Network.IncomingReplicationLag = 0
            end
        end
    })
    BlinkModes = Blink.CreateMultiDropdown({
        Name = "mode",
        List = {"incoming", "outgoing"},
        Default = {"incoming", "outgoing"},
        Function = function() 
            if Blink.Enabled then 
                Blink.Toggle()
                Blink.Toggle()
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
    local old = {}
    local Phase = {}; Phase = GuiLibrary.Objects.exploitsWindow.API.CreateOptionsButton({
        Name = "phase",
        Function = function(callback) 
            if callback then 
                funcs:bindToStepped("phase", function() 
                    if not entity.isAlive then return end
                    for i,v in next, lplr.Character:GetChildren() do 
                        local found = table.find(old, v)
                        if v:IsA("BasePart") and (v.CanCollide or found) then 
                            if not found then
                                old[#old+1] = v
                            end
                            v.CanCollide = false
                        end
                    end
                end)
            else
                funcs:unbindFromStepped("phase")
                for i,v in next, old do 
                    if v:IsA("BasePart") then 
                        v.CanCollide = true
                    end
                end
                old = {}
            end
        end
    })
end






do 
 --   local old = {}
 _G.Module = false
    local Phase = {}; Phase = GuiLibrary.Objects.exploitsWindow.API.CreateOptionsButton({
        Name = "ChestStealer",
        Function = function(callback) 
            if callback then 
                print("true")
        
local lplr = game.Players.LocalPlayer
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client



    _G.Module = true
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
    until  _G.Module == false
            else
                _G.Module = false
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


 

















   local KnockbackTable = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)

   
do 
   
   
    local vel = {}
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
   
   
    
function getblockfrommap(name)
    for i, v in pairs(game.Workspace:GetChildren()) do
        if v:FindFirstChild(name) then
            return v
        end
    end
end





function getbedsxd()
    local beds = {}
    local blocks = game:GetService("Workspace")
    for _,Block in pairs(blocks:GetChildren()) do
        if Block.Name == "bed" and Block.Covers.BrickColor ~= game.Players.LocalPlayer.Team.TeamColor then
            table.insert(beds,Block)
        end
    end
    return beds
end

function getbedsblocks()
    local blockstb = {}
    local blocks = game:GetService("Workspace")
    for i,v in pairs(blocks:GetChildren()) do
        if v:IsA("MeshPart") then
            table.insert(blockstb,v)
        end
    end
    return blockstb
end

function blocks(bed)
    local aboveblocks = 0
    local Blocks = getbedsblocks()
    for _,Block in pairs(Blocks) do
        if Block.Position.X == bed.X and Block.Position.Z == bed.Z and Block.Name ~= "bed" and (Block.Position.Y - bed.Y) <= 9 and Block.Position.Y > bed.Y then
            aboveblocks = aboveblocks + 1
        end
    end
    return aboveblocks
end







function nuker()
    local beds = getbedsxd()
    for _,bed in pairs(beds) do
        local bedmagnitude = (bed.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude
        if bedmagnitude < 27 then
            local upnum = blocks(bed.Position)
            local x = math.round(bed.Position.X/3)
            local y = math.round(bed.Position.Y/3) + upnum
            local z = math.round(bed.Position.Z/3)
 game:GetService("ReplicatedStorage").rbxts_include.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged.DamageBlock:InvokeServer({
                ["blockRef"] = {
                    ["blockPosition"] = Vector3.new(x,y,z)
                },
                ["hitPosition"] = Vector3.new(x,y,z),
                ["hitNormal"] = Vector3.new(x,y,z),
            })
        end
    end
end
_G.t = false
    local bn = {}; bn = GuiLibrary.Objects.exploitsWindow.API.CreateOptionsButton({
        Name = "Bed Banger",
        Function = function(callback) 
            if callback then 
                _G.t = true
                while _G.t == true do
                    nuker()
                    wait()
                    end
            else
                _G.t = false
            end
        end
    })
  
  
end


   
do 
   
   
   
    
    local killaurarange = {}
    _G.tt = false
        local ka = {}; ka = GuiLibrary.Objects.exploitsWindow.API.CreateOptionsButton({
            Name = "KilAura",
            Function = function(callback) 
                if callback then 
                    _G.tt = true
               
                    local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
                    local itemtablefunc = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta
                    local itemstuff = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1)
                    local itemtable = debug.getupvalue(itemtablefunc, 1)
                    local itemmeta = require(game:GetService("ReplicatedStorage").TS.item["item-meta"])
                    local lplr = game.Players.LocalPlayer
                    
                    
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
                    
                    
                    repeat
                    task.wait(0.1)
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
                    until    _G.tt == false


                else
                    _G.tt = false
                end
            end
        })
      
        killaurarange = ka.CreateSlider({
            Name = "value",
            Min = 0,
            Max = 100,
            Default = 20,
            Round = 1,
            Function = function(value) 
                if ka.Enabled then 
                    ka.Toggle()
                    ka.Toggle()
                end
            end
        })
      
    end
    
    
