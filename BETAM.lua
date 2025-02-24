-- Servicios y variables iniciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Insertar el ScreenGui en el PlayerGui
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SapienMenuGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Configuración para el Radar y el AimCircle
local RADAR_RANGE = 300
local RADAR_SIZE = 150
local AIM_RADIUS = 20  -- Radio reducido para mayor precisión

-- Variable de control para PERFECTSHOT
local perfectShotEnabled = false
local perfectShotPotency = 1  -- Potencia del aim lock (1-30)
local isAttacking = false  -- Se activará cuando toques fuera del menú (simula disparo/ataque)

-- Detectar cuando el jugador está atacando
ScreenGui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local menu = ScreenGui:FindFirstChild("MenuFrame")
        if not (menu and input.Target and input.Target:IsDescendantOf(menu)) then
            isAttacking = true
        end
    end
end)
ScreenGui.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isAttacking = false
    end
end)

-- Crear el menú de Sapien
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 280, 0, 450)
MenuFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MenuFrame.BorderSizePixel = 2
MenuFrame.Visible = false
MenuFrame.ZIndex = 10
MenuFrame.Parent = ScreenGui

-- Botón para activar/desactivar PERFECTSHOT
local PerfectShotToggleButton = Instance.new("TextButton")
PerfectShotToggleButton.Size = UDim2.new(0.5, 0, 0.05, 0)
PerfectShotToggleButton.Position = UDim2.new(0.25, 0, 0.65, 0)
PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
PerfectShotToggleButton.Text = "PerfectShot: OFF"
PerfectShotToggleButton.TextScaled = true
PerfectShotToggleButton.Font = Enum.Font.GothamBold
PerfectShotToggleButton.TextColor3 = Color3.new(1,1,1)
PerfectShotToggleButton.ZIndex = 10
PerfectShotToggleButton.Parent = MenuFrame
PerfectShotToggleButton.MouseButton1Click:Connect(function()
    perfectShotEnabled = not perfectShotEnabled
    if perfectShotEnabled then
        PerfectShotToggleButton.Text = "PerfectShot: ON"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0,0.8,0)
    else
        PerfectShotToggleButton.Text = "PerfectShot: OFF"
        PerfectShotToggleButton.BackgroundColor3 = Color3.new(0.8,0,0)
    end
end)

-- AimCircle: área de auto-aim. Se muestra como un círculo transparente con bordes púrpuras.
local AimCircle = Instance.new("Frame")
AimCircle.Name = "AimCircle"
AimCircle.Size = UDim2.new(0, AIM_RADIUS*2, 0, AIM_RADIUS*2)
AimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AimCircle.BackgroundTransparency = 1
AimCircle.BorderSizePixel = 0
AimCircle.ZIndex = 10
AimCircle.Parent = ScreenGui

local AimCircleCorner = Instance.new("UICorner")
AimCircleCorner.CornerRadius = UDim.new(1, 0)
AimCircleCorner.Parent = AimCircle

local AimCircleOutline = Instance.new("Frame")
AimCircleOutline.Size = UDim2.new(1, 0, 1, 0)
AimCircleOutline.Position = UDim2.new(0, 0, 0, 0)
AimCircleOutline.BackgroundTransparency = 1
AimCircleOutline.BorderSizePixel = 3
AimCircleOutline.BorderColor3 = Color3.fromRGB(128, 0, 128)  -- borde púrpura
AimCircleOutline.ZIndex = 10
AimCircleOutline.Parent = AimCircle

-- PERFECTSHOT: Auto-Aim avanzado (mejorado)
RunService.Heartbeat:Connect(function()
    if perfectShotEnabled and isAttacking and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local bestTarget, bestDist = nil, math.huge
        for _, player in pairs(Players:GetPlayers()) do
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

-- Toggle del menú mediante el ícono
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
ToggleIcon.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

-- Hacer el menú arrastrable
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
