<head><meta charset="UTF-8"></head><pre style="caret-color: rgb(255, 255, 255); color: rgb(255, 255, 255); font-style: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; widows: auto; word-spacing: 0px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.3); -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; text-decoration: none; overflow-wrap: break-word; white-space: pre-wrap;">--[[
    SAPIEN V1 Ultimate Script (Modificado sin AntiBan)
    
    Funciones:
      • Menú móvil y arrastrable, optimizado para iPhone (menú y radar reducidos).
      • Speed (1-50) y Jump (1-115) con slider y botón toggle.
      • PERFECTSHOT: Auto-aim activado por un solo botón.
          – Se muestra un pequeño círculo en el centro de la pantalla.
          – Mientras esté activo, si algún enemigo (cualquier jugador menos tú)
            tiene su "Head" dentro del área del círculo (umbral configurable), la cámara se ajusta automáticamente (lock-on).
          – La "potency" del auto-aim (slider 1-30) define la rapidez del lock.
      • Unlimited Ammo: Si el juego tiene un objeto "Ammo" en el Tool/character, se forzará a un valor muy alto.
      • Heal Player: Un botón que restaura la salud completa.
      • Damage Multipliers: Botones para multiplicar el daño (DAMAGEx2, x3, x4, x5). Se busca (en forma básica) algún NumberValue llamado "Damage" en el character o tools y se multiplica.
      • Radar: Mini mapa para detectar jugadores.
      
    NOTA: Estas funciones pueden no funcionar en todos los juegos o requerir adaptaciones.
--]]

-- Servicios y variables iniciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Insertar el ScreenGui en el PlayerGui para mejor visibilidad
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SapienMenuGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Configuración para el Radar y el AimCircle
local RADAR_RANGE = 300
local RADAR_SIZE = 150  -- reducido para mobile
local AIM_RADIUS = 50   -- radio en píxeles del círculo de auto-aim

-- Variables globales de multipliers
_G.damageMultiplier = 1

------------------------------------------------
-- Ícono Toggle (siempre visible)
------------------------------------------------
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
ToggleIcon.Position = UDim2.new(0, 10, 1, -55)
ToggleIcon.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
ToggleIcon.Text = "Menu"
ToggleIcon.TextScaled = true
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.ZIndex = 10
ToggleIcon.Parent = ScreenGui

local menuVisible = false

------------------------------------------------
-- Menú Principal Arrastrable (280×450)
------------------------------------------------
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 280, 0, 450)
MenuFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MenuFrame.BorderSizePixel = 2
MenuFrame.Visible = false
MenuFrame.ZIndex = 10
MenuFrame.Parent = ScreenGui

-- Título y Subtítulo
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SAPIEN V1 Script"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 10
Title.Parent = MenuFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0.04, 0)
Subtitle.Position = UDim2.new(0, 0, 0.08, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "made by BART00"
Subtitle.TextColor3 = Color3.new(1,1,1)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.ZIndex = 10
Subtitle.Parent = MenuFrame

------------------------------------------------
-- SECCIÓN: Speed Control (1–50)
------------------------------------------------
local speedEnabled = true
local defaultSpeed = 16
local currentSpeed = defaultSpeed

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0.05, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0.15, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. defaultSpeed
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.ZIndex = 10
SpeedLabel.Parent = MenuFrame

local SpeedSliderTrack = Instance.new("Frame")
SpeedSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
SpeedSliderTrack.Position = UDim2.new(0.1, 0, 0.21, 0)
SpeedSliderTrack.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
SpeedSliderTrack.ZIndex = 10
SpeedSliderTrack.Parent = MenuFrame

local SpeedSliderKnob = Instance.new("TextButton")
SpeedSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local speedDefaultPercent = (defaultSpeed - 1) / (50 - 1)
SpeedSliderKnob.Position = UDim2.new(speedDefaultPercent, -10, 0, 0)
SpeedSliderKnob.BackgroundColor3 = Color3.new(1,0,0)
SpeedSliderKnob.Text = ""
SpeedSliderKnob.ZIndex = 10
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
SpeedToggleButton.Position = UDim2.new(0.25, 0, 0.27, 0)
SpeedToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
SpeedToggleButton.Text = "Speed: ON"
SpeedToggleButton.TextScaled = true
SpeedToggleButton.Font = Enum.Font.GothamBold
SpeedToggleButton.TextColor3 = Color3.new(1,1,1)
SpeedToggleButton.ZIndex = 10
SpeedToggleButton.Parent = MenuFrame
SpeedToggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggleButton.Text = "Speed: ON"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
        end
    else
        SpeedToggleButton.Text = "Speed: OFF"
        SpeedToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Jump Control (1–115)
------------------------------------------------
local jumpEnabled = true
local defaultJump = 50
local currentJump = defaultJump

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, 0, 0.05, 0)
JumpLabel.Position = UDim2.new(0, 0, 0.33, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump: " .. defaultJump
JumpLabel.TextColor3 = Color3.new(1,1,1)
JumpLabel.TextScaled = true
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.ZIndex = 10
JumpLabel.Parent = MenuFrame

local JumpSliderTrack = Instance.new("Frame")
JumpSliderTrack.Size = UDim2.new(0.8, 0, 0.05, 0)
JumpSliderTrack.Position = UDim2.new(0.1, 0, 0.39, 0)
JumpSliderTrack.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
JumpSliderTrack.ZIndex = 10
JumpSliderTrack.Parent = MenuFrame

local JumpSliderKnob = Instance.new("TextButton")
JumpSliderKnob.Size = UDim2.new(0, 20, 1, 0)
local jumpDefaultPercent = (defaultJump - 1) / (115 - 1)
JumpSliderKnob.Position = UDim2.new(jumpDefaultPercent, -10, 0, 0)
JumpSliderKnob.BackgroundColor3 = Color3.new(1,0,0)
JumpSliderKnob.Text = ""
JumpSliderKnob.ZIndex = 10
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
JumpToggleButton.Position = UDim2.new(0.25, 0, 0.45, 0)
JumpToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
JumpToggleButton.Text = "Jump: ON"
JumpToggleButton.TextScaled = true
JumpToggleButton.Font = Enum.Font.GothamBold
JumpToggleButton.TextColor3 = Color3.new(1,1,1)
JumpToggleButton.ZIndex = 10
JumpToggleButton.Parent = MenuFrame
JumpToggleButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        JumpToggleButton.Text = "Jump: ON"
        JumpToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = currentJump
        end
    else
        JumpToggleButton.Text = "Jump: OFF"
        JumpToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = defaultJump
        end
    end
end)

------------------------------------------------
-- SECCIÓN: PERFECTSHOT (Auto-Aim con AimCircle)
------------------------------------------------

local isShooting = false
local aimingStatus = false

local PerfectShotLabel = Instance.new("TextLabel")
PerfectShotLabel.Size = UDim2.new(1, 0, 0.05, 0)
PerfectShotLabel.Position = UDim2.new(0, 0, 0.53, 0)
PerfectShotLabel.BackgroundTransparency = 1
PerfectShotLabel.Text = "Aim Potency: " .. perfectShotPotency
PerfectShotLabel.TextColor3 = Color3.new(1, 1, 1)
PerfectShotLabel.TextScaled = true
PerfectShotLabel.Font = Enum.Font.Gotham
PerfectShotLabel.ZIndex = 10
PerfectShotLabel.Parent = MenuFrame

local PerfectShotToggleButton = Instance.new("TextButton")
PerfectShotToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
PerfectShotToggleButton.Position = UDim2.new(0.25, 0, 0.65, 0)
PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
PerfectShotToggleButton.Text = "PerfectShot: OFF"
PerfectShotToggleButton.TextScaled = true
PerfectShotToggleButton.Font = Enum.Font.GothamBold
PerfectShotToggleButton.TextColor3 = Color3.new(1, 1, 1)
PerfectShotToggleButton.ZIndex = 10
PerfectShotToggleButton.Parent = MenuFrame

PerfectShotToggleButton.MouseButton1Click:Connect(function()
    perfectShotEnabled = not perfectShotEnabled
    PerfectShotToggleButton.Text = perfectShotEnabled and "PerfectShot: ON" or "PerfectShot: OFF"
    PerfectShotToggleButton.BackgroundColor3 = perfectShotEnabled and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
end)

-- AimCircle para visualizar el área de auto-aim (centrado en la pantalla)
local AimCircle = Instance.new("Frame")
AimCircle.Name = "AimCircle"
AimCircle.Size = UDim2.new(0, AIM_RADIUS * 2, 0, AIM_RADIUS * 2)
AimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AimCircle.BackgroundTransparency = 1
AimCircle.BorderSizePixel = 0
AimCircle.ZIndex = 10
AimCircle.Parent = ScreenGui

local AimCircleOutline = Instance.new("Frame")
AimCircleOutline.Size = UDim2.new(1, 0, 1, 0)
AimCircleOutline.Position = UDim2.new(0, 0, 0, 0)
AimCircleOutline.BackgroundTransparency = 1
AimCircleOutline.BorderSizePixel = 3
AimCircleOutline.BorderColor3 = Color3.new(1, 1, 1)
AimCircleOutline.ZIndex = 10
AimCircleOutline.Parent = AimCircle

-- Función de comprobación de disparo/ataque
local function checkShooting()
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:IsDescendantOf(LocalPlayer.Backpack) then
                tool.Activated:Connect(function() isShooting = true end)
                tool.Deactivated:Connect(function() isShooting = false end)
            end
        end
    end
end

-- Auto-Aim: Cada frame verifica si el PERFECTSHOT está activo y el jugador está disparando.
RunService.Heartbeat:Connect(function()
    if perfectShotEnabled and isShooting and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local bestTarget, bestDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local pos2d = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos2d - center).Magnitude
                    if dist <= AIM_RADIUS and dist < bestDist then
                        bestDist = dist
                        bestTarget = head
                    end
                end
            end
        end
        if bestTarget then
            local tweenInfo = TweenInfo.new(1 / perfectShotPotency, Enum.EasingStyle.Linear)
            local goal = {CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)}
            local tween = TweenService:Create(Camera, tweenInfo, goal)
            tween:Play()
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Unlimited Ammo
------------------------------------------------
local unlimitedAmmoEnabled = false
local AmmoToggleButton = Instance.new("TextButton")
AmmoToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
AmmoToggleButton.Position = UDim2.new(0.25, 0, 0.71, 0)
AmmoToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
AmmoToggleButton.Text = "Unlimited Ammo: OFF"
AmmoToggleButton.TextScaled = true
AmmoToggleButton.Font = Enum.Font.GothamBold
AmmoToggleButton.TextColor3 = Color3.new(1,1,1)
AmmoToggleButton.ZIndex = 10
AmmoToggleButton.Parent = MenuFrame
AmmoToggleButton.MouseButton1Click:Connect(function()
    unlimitedAmmoEnabled = not unlimitedAmmoEnabled
    if unlimitedAmmoEnabled then
        AmmoToggleButton.Text = "Unlimited Ammo: ON"
        AmmoToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        AmmoToggleButton.Text = "Unlimited Ammo: OFF"
        AmmoToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)
spawn(function()
    while wait(0.1) do
        if unlimitedAmmoEnabled and LocalPlayer.Character then
            for _,tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Ammo") and tool.Ammo:IsA("NumberValue") then
                    tool.Ammo.Value = 9999
                end
            end
        end
    end
end)

------------------------------------------------
-- SECCIÓN: Heal Player
------------------------------------------------
local HealButton = Instance.new("TextButton")
HealButton.Size = UDim2.new(0.5, 0, 0.05, 0)
HealButton.Position = UDim2.new(0.25, 0, 0.77, 0)
HealButton.BackgroundColor3 = Color3.new(0,0.8,0)
HealButton.Text = "Heal Player"
HealButton.TextScaled = true
HealButton.Font = Enum.Font.GothamBold
HealButton.TextColor3 = Color3.new(1,1,1)
HealButton.ZIndex = 10
HealButton.Parent = MenuFrame
HealButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

------------------------------------------------
-- SECCIÓN: Damage Multipliers
------------------------------------------------
local function setDamageMultiplier(mult)
    _G.damageMultiplier = mult
end

spawn(function()
    while wait(0.5) do
        if LocalPlayer.Character then
            for _,obj in pairs(LocalPlayer.Character:GetDescendants()) do
                if obj:IsA("NumberValue") and obj.Name:lower():find("damage") then
                    obj.Value = obj.Value * _G.damageMultiplier
                end
            end
            if LocalPlayer.Backpack then
                for _,tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    for _,obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("NumberValue") and obj.Name:lower():find("damage") then
                            obj.Value = obj.Value * _G.damageMultiplier
                        end
                    end
                end
            end
        end
    end
end)

local Damage2Button = Instance.new("TextButton")
Damage2Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage2Button.Position = UDim2.new(0.05, 0, 0.83, 0)
Damage2Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage2Button.Text = "DAMAGEx2"
Damage2Button.TextScaled = true
Damage2Button.Font = Enum.Font.GothamBold
Damage2Button.TextColor3 = Color3.new(1,1,1)
Damage2Button.ZIndex = 10
Damage2Button.Parent = MenuFrame
Damage2Button.MouseButton1Click:Connect(function() setDamageMultiplier(2) end)

local Damage3Button = Instance.new("TextButton")
Damage3Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage3Button.Position = UDim2.new(0.4, 0, 0.83, 0)
Damage3Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage3Button.Text = "DAMAGEx3"
Damage3Button.TextScaled = true
Damage3Button.Font = Enum.Font.GothamBold
Damage3Button.TextColor3 = Color3.new(1,1,1)
Damage3Button.ZIndex = 10
Damage3Button.Parent = MenuFrame
Damage3Button.MouseButton1Click:Connect(function() setDamageMultiplier(3) end)

local Damage4Button = Instance.new("TextButton")
Damage4Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage4Button.Position = UDim2.new(0.05, 0, 0.89, 0)
Damage4Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage4Button.Text = "DAMAGEx4"
Damage4Button.TextScaled = true
Damage4Button.Font = Enum.Font.GothamBold
Damage4Button.TextColor3 = Color3.new(1,1,1)
Damage4Button.ZIndex = 10
Damage4Button.Parent = MenuFrame
Damage4Button.MouseButton1Click:Connect(function() setDamageMultiplier(4) end)

local Damage5Button = Instance.new("TextButton")
Damage5Button.Size = UDim2.new(0.22, 0, 0.05, 0)
Damage5Button.Position = UDim2.new(0.4, 0, 0.89, 0)
Damage5Button.BackgroundColor3 = Color3.new(0,0.8,0)
Damage5Button.Text = "DAMAGEx5"
Damage5Button.TextScaled = true
Damage5Button.Font = Enum.Font.GothamBold
Damage5Button.TextColor3 = Color3.new(1,1,1)
Damage5Button.ZIndex = 10
Damage5Button.Parent = MenuFrame
Damage5Button.MouseButton1Click:Connect(function() setDamageMultiplier(5) end)

------------------------------------------------
-- SECCIÓN: AntiDetect (Dummy)
------------------------------------------------
local antiDetectEnabled = false
local AntiDetectButton = Instance.new("TextButton")
AntiDetectButton.Size = UDim2.new(0.5, 0, 0.05, 0)
AntiDetectButton.Position = UDim2.new(0.25, 0, 0.95, 0)
AntiDetectButton.BackgroundColor3 = Color3.new(0.8,0,0)
AntiDetectButton.Text = "AntiDetect: OFF"
AntiDetectButton.TextScaled = true
AntiDetectButton.Font = Enum.Font.GothamBold
AntiDetectButton.TextColor3 = Color3.new(1,1,1)
AntiDetectButton.ZIndex = 10
AntiDetectButton.Parent = MenuFrame
AntiDetectButton.MouseButton1Click:Connect(function()
    antiDetectEnabled = not antiDetectEnabled
    if antiDetectEnabled then
        AntiDetectButton.Text = "AntiDetect: ON"
        AntiDetectButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        AntiDetectButton.Text = "AntiDetect: OFF"
        AntiDetectButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)

------------------------------------------------
-- SECCIÓN: Radar / Mini Mapa (más chico)
------------------------------------------------
local RadarFrame = Instance.new("Frame")
RadarFrame.Name = "RadarFrame"
RadarFrame.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
RadarFrame.Position = UDim2.new(1, -RADAR_SIZE - 10, 0, 10)
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.BackgroundColor3 = Color3.new(0,0,0)
RadarFrame.BorderSizePixel = 2
RadarFrame.Visible = false
RadarFrame.ZIndex = 10
RadarFrame.Parent = ScreenGui

local RadarCenter = Instance.new("Frame")
RadarCenter.Size = UDim2.new(0, 6, 0, 6)
RadarCenter.AnchorPoint = Vector2.new(0.5,0.5)
RadarCenter.Position = UDim2.new(0.5,0,0.5,0)
RadarCenter.BackgroundColor3 = Color3.new(1,1,1)
RadarCenter.BorderSizePixel = 0
RadarCenter.ZIndex = 10
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
                if dist &lt;= RADAR_RANGE then
                    local relativePos = Vector2.new(diff.X, diff.Z) / RADAR_RANGE
                    local markerPos = Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2) + relativePos * (RADAR_SIZE/2)
                    if not radarMarkers[player] then
                        local marker = Instance.new("TextLabel")
                        marker.Size = UDim2.new(0, 20, 0, 20)
                        marker.BackgroundTransparency = 1
                        marker.Text = "●"
                        marker.TextColor3 = Color3.new(1,0,0)
                        marker.TextScaled = true
                        marker.ZIndex = 10
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
RunService.Heartbeat:Connect(function() updateRadar() end)
local RadarToggleButton = Instance.new("TextButton")
RadarToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
RadarToggleButton.Position = UDim2.new(0.25, 0, 0.53, 0)
RadarToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
RadarToggleButton.Text = "Radar: OFF"
RadarToggleButton.TextScaled = true
RadarToggleButton.Font = Enum.Font.GothamBold
RadarToggleButton.TextColor3 = Color3.new(1,1,1)
RadarToggleButton.ZIndex = 10
RadarToggleButton.Parent = MenuFrame
RadarToggleButton.MouseButton1Click:Connect(function()
    if RadarFrame.Visible then
        RadarFrame.Visible = false
        RadarToggleButton.Text = "Radar: OFF"
        RadarToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    else
        RadarFrame.Visible = true
        RadarToggleButton.Text = "Radar: ON"
        RadarToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    end
end)

------------------------------------------------
-- Hacer el menú arrastrable
------------------------------------------------
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

-- Toggle del menú mediante el ícono
ToggleIcon.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MenuFrame.Visible = menuVisible
end)

-- Establecer valores iniciales si el personaje existe
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
    LocalPlayer.Character.Humanoid.JumpPower = defaultJump
end</pre>
