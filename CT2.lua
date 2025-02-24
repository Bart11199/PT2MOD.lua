```lua
-- Services y variables iniciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local RADAR_RANGE = 300
local RADAR_SIZE = 200

-- ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SapienMenuGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

------------------------------------------------
-- Ícono Toggle (siempre visible)
------------------------------------------------
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0, 10, 1, -60)
ToggleIcon.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
ToggleIcon.Text = "Menu"
ToggleIcon.TextScaled = true
ToggleIcon.Parent = ScreenGui

local menuVisible = false

------------------------------------------------
-- Menú Principal Arrastrable
------------------------------------------------
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 320, 0, 500)
MenuFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MenuFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
MenuFrame.BorderSizePixel = 2
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

-- Título y Subtítulo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.05, 0)
Subtitle.Position = UDim2.new(0, 0, 0.1, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "made by BART00"
Subtitle.TextColor3 = Color3.new(1, 1, 1)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MenuFrame

--------------------------------------
-- SECCIÓN: Speed Control
--------------------------------------
local speedEnabled = true
local defaultSpeed = 16
local currentSpeed = defaultSpeed

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0.05, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0.17, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. defaultSpeed
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MenuFrame

local SpeedSliderTrack = Instance.new("Frame")
SpeedSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
SpeedSliderTrack.Position = UDim2.new(0.1, 0, 0.23, 0)
SpeedSliderTrack.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
SpeedSliderTrack.Parent = MenuFrame

local SpeedSliderKnob = Instance.new("TextButton")
SpeedSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local speedDefaultPercent = (defaultSpeed - 1) / (50 - 1)
SpeedSliderKnob.Position = UDim2.new(speedDefaultPercent, -10, 0, 0)
SpeedSliderKnob.BackgroundColor3 = Color3.new(1, 0, 0)
SpeedSliderKnob.Text = ""
SpeedSliderKnob.Parent = SpeedSliderTrack

local draggingSpeed = false
SpeedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = SpeedSliderTrack.AbsolutePosition.X
        local sliderWidth = SpeedSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newSpeed = math.floor(percent * (50 - 1) + 1)
        SpeedSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        SpeedLabel.Text = "Speed: " .. newSpeed
        currentSpeed = newSpeed
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = newSpeed
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingSpeed = false
    end
end)

local SpeedToggleButton = Instance.new("TextButton")
SpeedToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
SpeedToggleButton.Position = UDim2.new(0.25, 0, 0.29, 0)
SpeedToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
SpeedToggleButton.Text = "Speed: ON"
SpeedToggleButton.TextScaled = true
SpeedToggleButton.Font = Enum.Font.GothamBold
SpeedToggleButton.TextColor3 = Color3.new(1,1,1)
SpeedToggleButton.Parent = MenuFrame
SpeedToggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggleButton.Text = "Speed: ON"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
        end
    else
        SpeedToggleButton.Text = "Speed: OFF"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

--------------------------------------
-- SECCIÓN: Jump Control
--------------------------------------
local jumpEnabled = true
local defaultJump = 50  -- Valor por defecto de JumpPower en Roblox
local currentJump = defaultJump

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, 0, 0.05, 0)
JumpLabel.Position = UDim2.new(0, 0, 0.35, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump: " .. defaultJump
JumpLabel.TextColor3 = Color3.new(1,1,1)
JumpLabel.TextScaled = true
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.Parent = MenuFrame

local JumpSliderTrack = Instance.new("Frame")
JumpSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
JumpSliderTrack.Position = UDim2.new(0.1, 0, 0.41, 0)
JumpSliderTrack.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
JumpSliderTrack.Parent = MenuFrame

local JumpSliderKnob = Instance.new("TextButton")
JumpSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local jumpDefaultPercent = (defaultJump - 1) / (115 - 1)
JumpSliderKnob.Position = UDim2.new(jumpDefaultPercent, -10, 0, 0)
JumpSliderKnob.BackgroundColor3 = Color3.new(1, 0, 0)
JumpSliderKnob.Text = ""
JumpSliderKnob.Parent = JumpSliderTrack

local draggingJump = false
JumpSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJump = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingJump and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = JumpSliderTrack.AbsolutePosition.X
        local sliderWidth = JumpSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newJump = math.floor(percent * (115 - 1) + 1)
        JumpSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        JumpLabel.Text = "Jump: " .. newJump
        currentJump = newJump
        if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = newJump
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingJump = false
    end
end)

local JumpToggleButton = Instance.new("TextButton")
JumpToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
JumpToggleButton.Position = UDim2.new(0.25, 0, 0.47, 0)
JumpToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
JumpToggleButton.Text = "Jump: ON"
JumpToggleButton.TextScaled = true
JumpToggleButton.Font = Enum.Font.GothamBold
JumpToggleButton.TextColor3 = Color3.new(1,1,1)
JumpToggleButton.Parent = MenuFrame
JumpToggleButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        JumpToggleButton.Text = "Jump: ON"
        JumpToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = currentJump
        end
    else
        JumpToggleButton.Text = "Jump: OFF"
        JumpToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = defaultJump
        end
    end
end)

--------------------------------------
-- SECCIÓN: PerfectShot (Auto Aim)
--------------------------------------
local perfectShotEnabled = false
local perfectShotPotency = 1  -- Slider de 1 a 30 (cuanto mayor, más rápido el lock-on)
local defaultPotency = 1

local PerfectShotLabel = Instance.new("TextLabel")
PerfectShotLabel.Size = UDim2.new(1, 0, 0.05, 0)
PerfectShotLabel.Position = UDim2.new(0, 0, 0.55, 0)
PerfectShotLabel.BackgroundTransparency = 1
PerfectShotLabel.Text = "PerfectShot Potency: " .. perfectShotPotency
PerfectShotLabel.TextColor3 = Color3.new(1,1,1)
PerfectShotLabel.TextScaled = true
PerfectShotLabel.Font = Enum.Font.Gotham
PerfectShotLabel.Parent = MenuFrame

local PerfectShotSliderTrack = Instance.new("Frame")
PerfectShotSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
PerfectShotSliderTrack.Position = UDim2.new(0.1, 0, 0.61, 0)
PerfectShotSliderTrack.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
PerfectShotSliderTrack.Parent = MenuFrame

local PerfectShotSliderKnob = Instance.new("TextButton")
PerfectShotSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local psDefaultPercent = (perfectShotPotency - 1) / (30 - 1)
PerfectShotSliderKnob.Position = UDim2.new(psDefaultPercent, -10, 0, 0)
PerfectShotSliderKnob.BackgroundColor3 = Color3.new(1, 0, 0)
PerfectShotSliderKnob.Text = ""
PerfectShotSliderKnob.Parent = PerfectShotSliderTrack

local draggingPS = false
PerfectShotSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPS = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingPS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local sliderPos = PerfectShotSliderTrack.AbsolutePosition.X
        local sliderWidth = PerfectShotSliderTrack.AbsoluteSize.X
        local inputX = input.Position.X
        local relativePos = math.clamp(inputX - sliderPos, 0, sliderWidth)
        local percent = relativePos / sliderWidth
        local newPotency = math.floor(percent * (30 - 1) + 1)
        PerfectShotSliderKnob.Position = UDim2.new(percent, -10, 0, 0)
        PerfectShotLabel.Text = "PerfectShot Potency: " .. newPotency
        perfectShotPotency = newPotency
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        draggingPS = false
    end
end)

local function isWithinCircle(targetPosition)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local radius = 50
    local screenPoint = Camera:WorldToViewportPoint(targetPosition)
    local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
    
    return distanceFromCenter <= radius
end

local function getNearestEnemyInRange()
    local nearest, nearestDistance = nil, math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            if isWithinCircle(head.Position) then
                local distance = (head.Position - hrp.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = head
                end
            end
        end
    end
    return nearest
end

local function onAttack()
    if perfectShotEnabled then
        local target = getNearestEnemyInRange()
        if target then
            local tweenInfo = TweenInfo.new(0.2 / perfectShotPotency, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local goal = {}
            goal.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            local tween = TweenService:Create(Camera, tweenInfo, goal)
            tween:Play()
        end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
        onAttack()
    end
end)

local PerfectShotToggleButton = Instance.new("TextButton")
PerfectShotToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
PerfectShotToggleButton.Position = UDim2.new(0.25, 0, 0.67, 0)
PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
PerfectShotToggleButton.Text = "PerfectShot: OFF"
PerfectShotToggleButton.TextScaled = true
PerfectShotToggleButton.Font = Enum.Font.GothamBold
PerfectShotToggleButton.TextColor3 = Color3.new(1,1,1)
PerfectShotToggleButton.Parent = MenuFrame
PerfectShotToggleButton.MouseButton1Click:Connect(function()
    perfectShotEnabled = not perfectShotEnabled
    if perfectShotEnabled then
        PerfectShotToggleButton.Text = "PerfectShot: ON"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
    else
        PerfectShotToggleButton.Text = "PerfectShot: OFF"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    end
end)

--------------------------------------
-- SECCIÓN: Unlimited Stamina
--------------------------------------
local unlimitedStaminaEnabled = false
local StaminaToggleButton = Instance.new("TextButton")
StaminaToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
StaminaToggleButton.Position = UDim2.new(0.25, 0, 0.79, 0)
StaminaToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
StaminaToggleButton.Text = "Unlimited Stamina: OFF"
StaminaToggleButton.TextScaled = true
StaminaToggleButton.Font = Enum.Font.GothamBold
StaminaToggleButton.TextColor3 = Color3.new(1,1,1)
StaminaToggleButton.Parent = MenuFrame
StaminaToggleButton.MouseButton1Click:Connect(function()
    unlimitedStaminaEnabled = not unlimitedStaminaEnabled
    if unlimitedStaminaEnabled then
        StaminaToggleButton.Text = "Unlimited Stamina: ON"
        StaminaToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
    else
        StaminaToggleButton.Text = "Unlimited Stamina: OFF"
        StaminaToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    end
end)

spawn(function()
    while wait(0.1) do
        if unlimitedStaminaEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local stamina = char:FindFirstChild("Stamina") or char:FindFirstChildWhichIsA("NumberValue")
            if stamina then
                stamina.Value = 100
            end
        end
    end
end)

--------------------------------------
-- SECCIÓN: Radar / Mini Mapa
--------------------------------------
local RadarFrame = Instance.new("Frame")
RadarFrame.Name = "RadarFrame"
RadarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
RadarFrame.Position = UDim2.new(1, -RADAR_SIZE - 10, 0, 10)
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
RadarFrame.BorderSizePixel = 2
RadarFrame.Visible = false
RadarFrame.Parent = ScreenGui

local RadarCenter = Instance.new("Frame")
RadarCenter.Size = UDim2.new(0, 6, 0, 6)
RadarCenter.AnchorPoint = Vector2.new(0.5, 0.5)
RadarCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
RadarCenter.BackgroundColor3 = Color3.new(1,1,1)
RadarCenter.BorderSizePixel = 0
RadarCenter.Parent = RadarFrame

local radarMarkers = {}
local function updateRadar()
    if not RadarFrame.Visible then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = player.Character.HumanoidRootPart
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local diff = enemyHRP.Position - localHRP.Position
                local dist = diff.Magnitude
                if dist <= RADAR_RANGE then
                    local relativePos = Vector2.new(diff.X, diff.Z) / RADAR_RANGE
                    local markerPos = Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2) + relativePos * (RADAR_SIZE/2)
                    if not radarMarkers[player] then
                        local marker = Instance.new("TextLabel")
                        marker.Size = UDim2.new(0, 20, 0, 20)
                        marker.BackgroundTransparency = 1
                        marker.Text = "●"
                        marker.TextColor3 = Color3.new(1, 0, 0)
                        marker.TextScaled = true
                        marker.Parent = RadarFrame
                        radarMarkers[player] = marker
                    end
                    local marker = radarMarkers[player]
                    local clampedX = math.clamp(markerPos.X, 0, RADAR_SIZE)
                    local clampedY = math.clamp(markerPos.Y, 0, RADAR_SIZE)
                    marker.Position = UDim2.new(0, clampedX - 10, 0, clampedY - 10)
                    if markerPos.X ~= clampedX or markerPos.Y ~= clampedY then
                        marker.Text = "►"
                    else
                        marker.Text = "●"
                    end
                else
                    if radarMarkers[player] then
                        radarMarkers[player]:Destroy()
                        radarMarkers[player] = nil
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    updateRadar()
end)

local RadarToggleButton = Instance.new("TextButton")
RadarToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
RadarToggleButton.Position = UDim2.new(0.25, 0, 0.85, 0)
RadarToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
RadarToggleButton.Text = "Radar: OFF"
RadarToggleButton.TextScaled = true
RadarToggleButton.Font = Enum.Font.GothamBold
RadarToggleButton.TextColor3 = Color3.new(1,1,1)
RadarToggleButton.Parent = MenuFrame
RadarToggleButton.MouseButton1Click:Connect(function()
    if RadarFrame.Visible then
        RadarFrame.Visible = false
        RadarToggleButton.Text = "Radar: OFF"
        RadarToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    else
        RadarFrame.Visible = true
        RadarToggleButton.Text = "Radar: ON"
        RadarToggleButton.BackgroundColor3 = Color3.new(0, 0.8, 0)
    end
end)

--------------------------------------
-- Hacer el menú arrastrable
--------------------------------------
local dragging = false
local dragStart, startPos
MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MenuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MenuFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleIcon.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MenuFrame.Visible = menuVisible
end)

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
    LocalPlayer.Character.Humanoid.JumpPower = defaultJump
end
```
