--[[
    SCRIPT COMPLETO: SAPIEN V1 Script
    Funciones:
      • Menú arrastrable con toggle icon.
      • Speed control (1-50) y Jump control (1-115) con botones toggle.
      • Radar (mini mapa en la esquina superior derecha) que muestra red dots y flechas (ESP) para jugadores dentro de 300m.
      • PERFECTSHOT: al activarlo, al presionar el botón se bloquea (lock-on) al enemigo más cercano; la potencia (1-30) define la rapidez del lock.
      • Unlimited Stamina: si se detecta un valor de stamina en el personaje, se fuerza su valor a 100.
      
    Nota: Algunas funciones (como PerfectShot o Unlimited Stamina) dependen de cómo esté estructurado el juego.
    Prueba y ajusta según sea necesario.
--]]

-- Servicios y variables iniciales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local RADAR_RANGE = 300
local RADAR_SIZE = 200
local AIM_RADIUS = 20  -- Radio reducido para mayor precisión

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

------------------------------------------------
-- PERFECTSHOT (Auto-Aim Avanzado) - Modificado para activarse solo al atacar
------------------------------------------------
local perfectShotEnabled = false
local perfectShotPotency = 1  -- Slider de 1 a 30 (cuanto mayor, más rápido el lock-on)
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

------------------------------------------------
-- Toggle del menú mediante el ícono
------------------------------------------------
ToggleIcon.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MenuFrame.Visible = menuVisible
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
