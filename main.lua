--[[
    MX DESYNC HUB — single-file GitHub build
    ------------------------------------------------------------
    HOW TO USE (one file, two paste spots):
      1. Copy everything between  ===SERVER START===  and  ===SERVER END===
         into a Script in ServerScriptService named "MXDesyncServer".
      2. Copy everything between  ===CLIENT START===  and  ===CLIENT END===
         into a LocalScript in StarterPlayer > StarterPlayerScripts
         named "MXDesyncClient".
      3. Press Play. A dark "MX DESYNC HUB" window appears.
         Click DESYNC tab → GHOST HITBOX [OFF] → [ON].
         Red neon ghost appears at the SERVER's authoritative position.
         "Server offset: X.XX studs" turns red when desync > 1 stud.
    ------------------------------------------------------------
    Why two spots? Roblox blocks a Script from creating client GUIs and
    blocks a LocalScript from creating server Parts. This is the minimum
    split. Everything is still ONE file in your GitHub repo.
]]

-- ============================================================
-- ===SERVER START===
-- ============================================================
-- Paste into: ServerScriptService > Script named "MXDesyncServer"

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("MXDesyncDebug")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "MXDesyncDebug"
    folder.Parent = ReplicatedStorage
end

local toggleRemote = folder:FindFirstChild("ToggleGhost")
if not toggleRemote then
    toggleRemote = Instance.new("RemoteEvent")
    toggleRemote.Name = "ToggleGhost"
    toggleRemote.Parent = folder
end

local active = {}

local function makeGhost(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local part = Instance.new("Part")
    part.Name = "MXServerGhost_" .. player.Name
    part.Size = hrp.Size
    part.CFrame = hrp.CFrame
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 0.5
    part.Color = Color3.fromRGB(255, 60, 60)
    part.Material = Enum.Material.Neon
    part.Parent = workspace

    local box = Instance.new("SelectionBox")
    box.Adornee = part
    box.LineThickness = 0.05
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Parent = part

    local conn = RunService.Heartbeat:Connect(function()
        local c = player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            part.CFrame = h.CFrame
            part.Size = h.Size
        end
    end)

    active[player] = { part = part, conn = conn }
end

local function removeGhost(player)
    local data = active[player]
    if not data then return end
    if data.conn then data.conn:Disconnect() end
    if data.part then data.part:Destroy() end
    active[player] = nil
end

toggleRemote.OnServerEvent:Connect(function(player, on)
    if on then
        removeGhost(player)
        makeGhost(player)
    else
        removeGhost(player)
    end
end)

Players.PlayerRemoving:Connect(removeGhost)

-- ============================================================
-- ===SERVER END===
-- ============================================================


-- ============================================================
-- ===CLIENT START===
-- ============================================================
-- Paste into: StarterPlayer > StarterPlayerScripts > LocalScript "MXDesyncClient"

-- NOTE: everything below this line goes in the CLIENT LocalScript.
-- (If you're pasting the whole file in one go, delete the SERVER block
--  above from your LocalScript — it won't run on the client anyway,
--  but keep it clean.)

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local toggleRemote = ReplicatedStorage:WaitForChild("MXDesyncDebug"):WaitForChild("ToggleGhost")

local GhostEnabled = false

local oldGui = PlayerGui:FindFirstChild("MXDesyncHub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MXDesyncHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 440, 0, 320)
main.Position = UDim2.new(0.5, -220, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(19, 19, 27)
main.BorderSizePixel = 0
main.Parent = gui

local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end
addCorner(main, 12)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(29, 29, 41)
header.BorderSizePixel = 0
header.Parent = main
addCorner(header, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MX DESYNC HUB"
title.TextColor3 = Color3.fromRGB(110, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 34, 0, 30)
closeButton.Position = UDim2.new(1, -42, 0, 9)
closeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = header
addCorner(closeButton, 7)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 10, 0, 60)
sidebar.Size = UDim2.new(0, 115, 1, -70)
sidebar.BackgroundTransparency = 1
sidebar.Parent = main

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 135, 0, 60)
content.Size = UDim2.new(1, -145, 1, -70)
content.BackgroundTransparency = 1
content.Parent = main

local function makeButton(parent, text, position, size)
    local b = Instance.new("TextButton")
    b.Position = position
    b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 240)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Parent = parent
    addCorner(b, 7)
    return b
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
    return label
end

local ghostButton
local deltaLabel

local function updateGhostButton()
    if not ghostButton then return end
    if GhostEnabled then
        ghostButton.Text = "GHOST HITBOX  [ON]"
        ghostButton.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
    else
        ghostButton.Text = "GHOST HITBOX  [OFF]"
        ghostButton.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
    end
end

local function showDesyncPage()
    clearContent()
    makeHeading("DESYNC DEBUG")

    ghostButton = makeButton(
        content,
        "GHOST HITBOX  [OFF]",
        UDim2.new(0, 0, 0, 40),
        UDim2.new(1, 0, 0, 38)
    )

    ghostButton.MouseButton1Click:Connect(function()
        GhostEnabled = not GhostEnabled
        updateGhostButton()
        toggleRemote:FireServer(GhostEnabled)
    end)

    updateGhostButton()

    deltaLabel = Instance.new("TextLabel")
    deltaLabel.Position = UDim2.new(0, 0, 0, 88)
    deltaLabel.Size = UDim2.new(1, 0, 0, 26)
    deltaLabel.BackgroundTransparency = 1
    deltaLabel.Text = "Server offset: --"
    deltaLabel.TextColor3 = Color3.fromRGB(175, 175, 190)
    deltaLabel.Font = Enum.Font.GothamMedium
    deltaLabel.TextSize = 13
    deltaLabel.TextXAlignment = Enum.TextXAlignment.Left
    deltaLabel.Parent = content

    local info = Instance.new("TextLabel")
    info.Position = UDim2.new(0, 0, 0, 122)
    info.Size = UDim2.new(1, 0, 0, 90)
    info.BackgroundTransparency = 1
    info.Text = "Toggles a red neon ghost on the SERVER at your\n"
        .. "authoritative HumanoidRootPart position.\n"
        .. "Gap between ghost and your character = desync.\n"
        .. "Offset turns red when server drift > 1 stud."
    info.TextColor3 = Color3.fromRGB(175, 175, 190)
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextWrapped = true
    info.Parent = content
end

local desyncTab = makeButton(
    sidebar, "DESYNC",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(1, 0, 0, 40)
)
desyncTab.MouseButton1Click:Connect(showDesyncPage)

local dragging, dragStart, startPosition = false, nil, nil
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
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local restoreButton = Instance.new("TextButton")
restoreButton.Name = "MXDesyncRestore"
restoreButton.Size = UDim2.new(0, 54, 0, 38)
restoreButton.Position = UDim2.new(0, 16, 0.5, -19)
restoreButton.BackgroundColor3 = Color3.fromRGB(29, 29, 41)
restoreButton.Text = "MX"
restoreButton.TextColor3 = Color3.fromRGB(110, 150, 255)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 16
restoreButton.BorderSizePixel = 0
restoreButton.Visible = false
restoreButton.Parent = gui
addCorner(restoreButton, 9)

closeButton.MouseButton1Click:Connect(function()
    main.Visible = false
    restoreButton.Visible = true
end)
restoreButton.MouseButton1Click:Connect(function()
    restoreButton.Visible = false
    main.Visible = true
end)

task.spawn(function()
    while gui.Parent do
        task.wait(0.25)
        if GhostEnabled and deltaLabel then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local ghost = workspace:FindFirstChild("MXServerGhost_" .. LocalPlayer.Name)
            if hrp and ghost then
                local d = (ghost.Position - hrp.Position).Magnitude
                deltaLabel.Text = string.format("Server offset: %.2f studs", d)
                deltaLabel.TextColor3 = d > 1
                    and Color3.fromRGB(255, 90, 90)
                    or  Color3.fromRGB(175, 175, 190)
            else
                deltaLabel.Text = "Server offset: waiting for ghost..."
                deltaLabel.TextColor3 = Color3.fromRGB(175, 175, 190)
            end
        elseif deltaLabel then
            deltaLabel.Text = "Server offset: --"
            deltaLabel.TextColor3 = Color3.fromRGB(175, 175, 190)
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if GhostEnabled then
        toggleRemote:FireServer(false)
        GhostEnabled = false
        updateGhostButton()
    end
end)

showDesyncPage()

-- ============================================================
-- ===CLIENT END===
-- ============================================================

print("MX Desync Hub loaded")
