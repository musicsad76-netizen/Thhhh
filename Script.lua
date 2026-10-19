--[[
    THAIIIFMYT HUB
    Steal a Brainrot Style
    For your own Roblox Studio game
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remove old GUI
local OldGUI = PlayerGui:FindFirstChild("THAIIIFMYTHub")
if OldGUI then
    OldGUI:Destroy()
end

-- State
local Flying = false
local InfiniteJump = false
local AntiLag = false
local SavedWaypoint = nil
local DefaultSpeed = 16
local FlyConnection = nil
local FlyVelocity = nil
local FlyGyro = nil
local OriginalEffects = {}

-- Character
local Character
local Humanoid
local RootPart

local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    DefaultSpeed = Humanoid.WalkSpeed
end

if Player.Character then
    SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "THAIIIFMYTHub"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 310, 0, 440)
Main.Position = UDim2.new(0.5, -155, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(19, 19, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = GUI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(160, 80, 255)
Stroke.Thickness = 2
Stroke.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(45, 25, 75)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "THAIIIFMYT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 30)
Minimize.Position = UDim2.new(1, -75, 0, 7)
Minimize.Text = "-"
Minimize.TextSize = 22
Minimize.Font = Enum.Font.GothamBold
Minimize.BackgroundColor3 = Color3.fromRGB(80, 55, 110)
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.Text = "X"
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.BackgroundColor3 = Color3.fromRGB(180, 45, 65)
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Parent = Header

local Body = Instance.new("ScrollingFrame")
Body.Name = "Body"
Body.Position = UDim2.new(0, 8, 0, 52)
Body.Size = UDim2.new(1, -16, 1, -60)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ScrollBarThickness = 4
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Body

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 8)
Padding.PaddingLeft = UDim.new(0, 3)
Padding.PaddingRight = UDim.new(0, 3)
Padding.Parent = Body

-- Helpers
local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -4, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(42, 42, 58)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = Body

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    Button.Activated:Connect(function()
        callback(Button)
    end)

    return Button
end

local function CreateInput(placeholder, defaultText)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -4, 0, 36)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Box.BorderSizePixel = 0
    Box.PlaceholderText = placeholder
    Box.Text = defaultText or ""
    Box.TextColor3 = Color3.new(1, 1, 1)
    Box.PlaceholderColor3 = Color3.fromRGB(160, 160, 170)
    Box.TextSize = 14
    Box.Font = Enum.Font.Gotham
    Box.ClearTextOnFocus = false
    Box.Parent = Body

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Box

    return Box
end

local function SetButtonState(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(65, 125, 85)
        or Color3.fromRGB(42, 42, 58)
end

local function GetCharacter()
    Character = Player.Character
    if not Character then
        return nil, nil, nil
    end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")

    return Character, Humanoid, RootPart
end

-- 1. SPEED
local SpeedInput = CreateInput("Speed: 16 - 100", "50")

CreateButton("APPLY SPEED", function(button)
    local _, hum = GetCharacter()
    local value = tonumber(SpeedInput.Text)

    if hum and value then
        hum.WalkSpeed = math.clamp(value, 16, 100)
        button.Text = "SPEED APPLIED: " .. hum.WalkSpeed
    else
        button.Text = "INVALID SPEED"
    end
end)

-- 2. FLY
local FlyButton

local function StopFly()
    Flying = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    local _, hum, root = GetCharacter()

    if root then
        local velocity = root:FindFirstChild("THAIIIFMYTFlyVelocity")
        local gyro = root:FindFirstChild("THAIIIFMYTFlyGyro")

        if velocity then velocity:Destroy() end
        if gyro then gyro:Destroy() end
    end

    if hum then
        hum.PlatformStand = false
    end

    if FlyButton then
        SetButtonState(FlyButton, "FLY", false)
    end
end

local function StartFly()
    local _, hum, root = GetCharacter()

    if not hum or not root then
        return false
    end

    Flying = true

    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "THAIIIFMYTFlyVelocity"
    velocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    local gyro = Instance.new("BodyGyro")
    gyro.Name = "THAIIIFMYTFlyGyro"
    gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    gyro.P = 10000
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Flying or not root.Parent then
            StopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local direction = hum.MoveDirection
        local vertical = 0

        -- Keyboard vertical movement
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        elseif UserInputService.TouchEnabled then
            -- Mobile: use jump button to rise
            if hum.Jump then
                vertical = 1
            end
        end

        local horizontal = Vector3.zero

        if direction.Magnitude > 0 then
            horizontal = direction.Unit * 45
        end

        velocity.Velocity = horizontal + Vector3.new(0, vertical * 35, 0)

        if camera then
            local look = camera.CFrame.LookVector
            gyro.CFrame = CFrame.lookAt(
                root.Position,
                root.Position + Vector3.new(look.X, 0, look.Z)
            )
        end
    end)

    return true
end

FlyButton = CreateButton("FLY: OFF", function(button)
    if Flying then
        StopFly()
    else
        if StartFly() then
            SetButtonState(button, "FLY", true)
        end
    end
end)

-- 3. INFINITE JUMP
local JumpButton

JumpButton = CreateButton("INFINITE JUMP: OFF", function(button)
    InfiniteJump = not InfiniteJump
    SetButtonState(button, "INFINITE JUMP", InfiniteJump)
end)

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJump then
        return
    end

    local _, hum = GetCharacter()

    if hum and hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 4. ANTI-LAG
local AntiLagButton

local function ApplyAntiLag(enabled)
    if enabled then
        table.clear(OriginalEffects)

        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("ParticleEmitter")
                or object:IsA("Trail")
                or object:IsA("Beam") then

                OriginalEffects[object] = object.Enabled
                object.Enabled = false
            end
        end
    else
        for object, originalEnabled in pairs(OriginalEffects) do
            if object and object.Parent then
                object.Enabled = originalEnabled
            end
        end

        table.clear(OriginalEffects)
    end
end

AntiLagButton = CreateButton("ANTI-LAG: OFF", function(button)
    AntiLag = not AntiLag
    ApplyAntiLag(AntiLag)
    SetButtonState(button, "ANTI-LAG", AntiLag)
end)

-- 5. WAYPOINT COORDINATES
local XInput = CreateInput("X coordinate", "0")
local YInput = CreateInput("Y coordinate", "10")
local ZInput = CreateInput("Z coordinate", "0")

CreateButton("GO TO WAYPOINT", function(button)
    local _, hum, root = GetCharacter()

    local x = tonumber(XInput.Text)
    local y = tonumber(YInput.Text)
    local z = tonumber(ZInput.Text)

    if not root or not hum or not x or not y or not z then
        button.Text = "INVALID COORDINATES"
        return
    end

    -- Local character movement for your own test game.
    local success = pcall(function()
        Character:PivotTo(CFrame.new(x, y, z))
    end)

    button.Text = success and "WAYPOINT REACHED" or "TELEPORT FAILED"
end)

CreateButton("SAVE CURRENT WAYPOINT", function(button)
    local _, _, root = GetCharacter()

    if root then
        SavedWaypoint = root.Position

        XInput.Text = tostring(math.round(SavedWaypoint.X))
        YInput.Text = tostring(math.round(SavedWaypoint.Y))
        ZInput.Text = tostring(math.round(SavedWaypoint.Z))

        button.Text = "WAYPOINT SAVED"
    end
end)

CreateButton("GO TO SAVED WAYPOINT", function(button)
    local _, _, root = GetCharacter()

    if root and SavedWaypoint then
        local success = pcall(function()
            Character:PivotTo(CFrame.new(SavedWaypoint))
        end)

        button.Text = success and "SAVED WAYPOINT REACHED"
            or "TELEPORT FAILED"
    else
        button.Text = "NO SAVED WAYPOINT"
    end
end)

-- 6. RESET CHARACTER
CreateButton("RESET CHARACTER", function()
    local _, hum = GetCharacter()

    if hum then
        hum.Health = 0
    end
end)

-- 7. MINIMIZE GUI
local minimized = false
local originalSize = Main.Size

Minimize.Activated:Connect(function()
    minimized = not minimized

    Body.Visible = not minimized
    Main.Size = minimized
        and UDim2.new(0, 310, 0, 45)
        or originalSize

    Minimize.Text = minimized and "+" or "-"
end)

-- 8. CLOSE GUI
Close.Activated:Connect(function()
    StopFly()
    InfiniteJump = false
    ApplyAntiLag(false)
    GUI:Destroy()
end)

-- Make the window draggable on mouse and touch
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("THAIIIFMYT HUB loaded successfully!")