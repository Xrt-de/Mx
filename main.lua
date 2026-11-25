-- MX HUB v1.0
-- Unified GUI Foundation
-- Lua / Luau

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Remove previous MX Hub
pcall(function()
    CoreGui:FindFirstChild("MXHub"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MXHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 440, 0, 320)
main.Position = UDim2.new(0.5, -220, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(19, 19, 27)
main.BorderSizePixel = 0
main.Parent = gui

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
end

corner(main, 12)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(29, 29, 41)
header.BorderSizePixel = 0
header.Parent = main

corner(header, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MX HUB"
title.TextColor3 = Color3.fromRGB(110, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 30)
close.Position = UDim2.new(1, -42, 0, 9)
close.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = header
corner(close, 7)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 10, 0, 60)
sidebar.Size = UDim2.new(0, 115, 1, -70)
sidebar.BackgroundTransparency = 1
sidebar.Parent = main

-- Content
local content = Instance.new("Frame")
content.Position = UDim2.new(0, 135, 0, 60)
content.Size = UDim2.new(1, -145, 1, -70)
content.BackgroundTransparency = 1
content.Parent = main

local function makeButton(parent, text, position, size)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 240)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = parent
    corner(button, 7)
    return button
end

local function clearContent()
    for _, item in ipairs(content:GetChildren()) do
        item:Destroy()
    end
end

local function makeHeading(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 32)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

local settings = {}

local function makeToggle(text, y)
    local enabled = false

    local button = makeButton(
        content,
        text .. "  [OFF]",
        UDim2.new(0, 0, 0, y),
        UDim2.new(1, 0, 0, 36)
    )

    button.MouseButton1Click:Connect(function()
        enabled = not enabled

        button.Text = text .. (enabled and "  [ON]" or "  [OFF]")

        button.BackgroundColor3 = enabled
            and Color3.fromRGB(55, 90, 160)
            or Color3.fromRGB(38, 38, 52)

        settings[text] = enabled
    end)

    settings[text] = false
end

local function showESP()
    clearContent()
    makeHeading("ESP SETTINGS")

    makeToggle("Player Highlight", 40)
    makeToggle("Name Tags", 82)
    makeToggle("Distance", 124)
    makeToggle("Team Check", 166)
end

local function showAim()
    clearContent()
    makeHeading("AIM SETTINGS")

    makeToggle("Camera Aim", 40)
    makeToggle("FOV Circle", 82)
    makeToggle("Team Check", 124)
end

local espTab = makeButton(
    sidebar,
    "ESP",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(1, 0, 0, 40)
)

local aimTab = makeButton(
    sidebar,
    "AIM",
    UDim2.new(0, 0, 0, 48),
    UDim2.new(1, 0, 0, 40)
)

espTab.MouseButton1Click:Connect(showESP)
aimTab.MouseButton1Click:Connect(showAim)

-- Dragging
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

showESP()

gui.Parent = CoreGui
