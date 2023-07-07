local cloneref = cloneref or function(ref) 
    return ref
end

local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui

if gethui and identifyexecutor and identifyexecutor() == "ScriptWare" then
    CoreGui = cloneref(gethui())
elseif gethiddengui then
    CoreGui = cloneref(gethiddengui())
else
    CoreGui = cloneref(game:GetService("CoreGui"))
end

local Debris = cloneref(game:GetService("Debris"))



return function(Arguments)
    coroutine.resume(coroutine.create(function()
 local Text = Arguments.Text or "lorem ipsum"
        local Duration = Arguments.Duration or 5

        -- Instances:

        local ScreenGui
        if CoreGui:FindFirstChild("Error") then
            ScreenGui = CoreGui:FindFirstChild("Error")
        elseif syn and syn.protect_gui then
            ScreenGui = Instance.new("ScreenGui")
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
        else
            ScreenGui = Instance.new("ScreenGui",CoreGui)
        end
        
local Frame = Instance.new("Frame")
local SideT = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local cProductSans = Instance.new("TextLabel")
local Togg = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")
local Circol = Instance.new("Frame")
local UICorner_3 = Instance.new("UICorner")




local Children = ScreenGui:GetChildren()
        for i,v in pairs(Children) do
            local Tween = TweenService:Create(v,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = UDim2.new(Frame.Position.X.Scale, 0, .1, (i*v.AbsoluteSize.Y*1.2))})
            Tween:Play()
        end

        ScreenGui.Parent = CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "Notify"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.190
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(-1, 0, 0.100000001, 0)
Frame.Size = UDim2.new(0, 278, 0, 61)

SideT.Name = "SideT"
SideT.Parent = Frame
SideT.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
SideT.BorderColor3 = Color3.fromRGB(0, 0, 0)
SideT.BorderSizePixel = 0
SideT.Position = UDim2.new(0.980000019, 2, -0.00100000005, 0)
SideT.Size = UDim2.new(0, 4, 0, 61)

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = SideT

cProductSans.Name = "cProductSans"
cProductSans.Parent = Frame
cProductSans.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
cProductSans.BackgroundTransparency = 9.000
cProductSans.BorderColor3 = Color3.fromRGB(0, 0, 0)
cProductSans.BorderSizePixel = 0
cProductSans.Position = UDim2.new(0.197841838, 0, 0.426229507, 0)
cProductSans.Size = UDim2.new(0, 220, 0, 34)
cProductSans.Font = Enum.Font.Arial
cProductSans.Text = "Speed"
cProductSans.TextColor3 = Color3.fromRGB(255, 255, 255)
cProductSans.TextSize = 17.000
cProductSans.TextWrapped = true
cProductSans.TextXAlignment = Enum.TextXAlignment.Left

Togg.Name = "Togg"
Togg.Parent = Frame
Togg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Togg.BackgroundTransparency = 9.000
Togg.BorderColor3 = Color3.fromRGB(0, 0, 0)
Togg.BorderSizePixel = 0
Togg.Position = UDim2.new(0.197841853, 0, 2.98023224e-08, 0)
Togg.Size = UDim2.new(0, 206, 0, 26)
Togg.Font = Enum.Font.ArialBold
Togg.Text = "Toggle"
Togg.TextColor3 = Color3.fromRGB(255, 0, 4)
Togg.TextSize = 18.000
Togg.TextWrapped = true
Togg.TextXAlignment = Enum.TextXAlignment.Left

UICorner_2.CornerRadius = UDim.new(0, 9)
UICorner_2.Parent = Frame

Circol.Name = "Circol"
Circol.Parent = Frame
Circol.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Circol.BorderColor3 = Color3.fromRGB(0, 0, 0)
Circol.BorderSizePixel = 0
Circol.Position = UDim2.new(0.0223741066, 0, 0.14654091, 0)
Circol.Size = UDim2.new(0, 41, 0, 42)

UICorner_3.CornerRadius = UDim.new(0, 9)
UICorner_3.Parent = Circol

Debris:AddItem(Frame, Duration)
local Tween = TweenService:Create(Frame,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = UDim2.new(0, 0, 0, Frame.AbsolutePosition.Y)})
Tween:Play()

wait(Duration)
Tween = TweenService:Create(Frame,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position = UDim2.new(-1, 0, 0, Frame.AbsolutePosition.Y)})
Tween:Play()



        end))
end
