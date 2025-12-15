--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                     LUMINOSITY HUB                            ║
    ║              Universal Aimbot & ESP Script                    ║
    ║                                                               ║
    ║  Credits: @xz, @goof (Original Devs)                          ║
    ║  UI Library: Luminosity UI                                    ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

--// Configuration
getgenv().Config = {
    Invite = "Luminosityhub.com",
    Version = "1.0",
}

getgenv().luaguardvars = {
    DiscordName = "jshawk",
}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

--// Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--[[ ═══════════════════════════════════════════════════════════════
                      LOADING ANIMATION
═══════════════════════════════════════════════════════════════ ]]

--// Pre-fetch the library source (doesn't execute yet)
local librarySource = game:HttpGet("https://raw.githubusercontent.com/Jshawk/luminosity-ui/refs/heads/main/Luminosity%20UI%20Source.lua")

local function PlayLoadingAnimation()
    local screenSize = Camera.ViewportSize
    local centerX, centerY = screenSize.X / 2, screenSize.Y / 2
    
    -- Background overlay
    local bg = Drawing.new("Square")
    bg.Size = screenSize
    bg.Position = Vector2.new(0, 0)
    bg.Color = Color3.fromRGB(15, 15, 20)
    bg.Filled = true
    bg.Transparency = 1
    bg.Visible = true
    
    -- Logo text
    local logo = Drawing.new("Text")
    logo.Text = "LUMINOSITY"
    logo.Size = 42
    logo.Center = true
    logo.Position = Vector2.new(centerX, centerY - 60)
    logo.Color = Color3.fromRGB(255, 60, 60)
    logo.Outline = true
    logo.OutlineColor = Color3.fromRGB(0, 0, 0)
    logo.Transparency = 0
    logo.Visible = true
    
    -- Subtitle
    local subtitle = Drawing.new("Text")
    subtitle.Text = "HUB v1.0"
    subtitle.Size = 18
    subtitle.Center = true
    subtitle.Position = Vector2.new(centerX, centerY - 20)
    subtitle.Color = Color3.fromRGB(180, 180, 180)
    subtitle.Outline = true
    subtitle.Transparency = 0
    subtitle.Visible = true
    
    -- Progress bar background
    local barBg = Drawing.new("Square")
    barBg.Size = Vector2.new(300, 8)
    barBg.Position = Vector2.new(centerX - 150, centerY + 30)
    barBg.Color = Color3.fromRGB(40, 40, 50)
    barBg.Filled = true
    barBg.Transparency = 0
    barBg.Visible = true
    
    -- Progress bar fill
    local barFill = Drawing.new("Square")
    barFill.Size = Vector2.new(0, 6)
    barFill.Position = Vector2.new(centerX - 149, centerY + 31)
    barFill.Color = Color3.fromRGB(255, 60, 60)
    barFill.Filled = true
    barFill.Transparency = 0
    barFill.Visible = true
    
    -- Status text
    local status = Drawing.new("Text")
    status.Text = "Initializing..."
    status.Size = 14
    status.Center = true
    status.Position = Vector2.new(centerX, centerY + 55)
    status.Color = Color3.fromRGB(150, 150, 150)
    status.Outline = true
    status.Transparency = 0
    status.Visible = true
    
    -- Spinning dots
    local dots = {}
    for i = 1, 8 do
        local dot = Drawing.new("Circle")
        dot.Radius = 4
        dot.Filled = true
        dot.Transparency = 0
        dot.Visible = true
        dots[i] = dot
    end
    
    -- Animation variables
    local progress = 0
    local hue = 0
    local spinAngle = 0
    local statusMessages = {
        {0, "Initializing..."},
        {15, "Loading UI Library..."},
        {35, "Setting up modules..."},
        {55, "Configuring ESP..."},
        {75, "Preparing aimbot..."},
        {90, "Almost ready..."},
        {100, "Welcome!"}
    }
    
    -- Fade in
    for i = 0, 1, 0.05 do
        logo.Transparency = i
        subtitle.Transparency = i
        barBg.Transparency = i
        status.Transparency = i
        for _, dot in pairs(dots) do
            dot.Transparency = i
        end
        task.wait(0.02)
    end
    
    -- Main loading animation
    local startTime = tick()
    local duration = 2.5
    
    while progress < 100 do
        local elapsed = tick() - startTime
        progress = math.min((elapsed / duration) * 100, 100)
        
        -- Update progress bar
        barFill.Size = Vector2.new(298 * (progress / 100), 6)
        
        -- Rainbow progress bar
        hue = (hue + 0.01) % 1
        barFill.Color = Color3.fromHSV(hue, 0.8, 1)
        
        -- Update status text
        for _, msg in ipairs(statusMessages) do
            if progress >= msg[1] then
                status.Text = msg[2]
            end
        end
        
        -- Spinning dots animation
        spinAngle = spinAngle + 0.15
        for i, dot in ipairs(dots) do
            local angle = spinAngle + (i - 1) * (math.pi * 2 / 8)
            local radius = 80
            local x = centerX + math.cos(angle) * radius
            local y = centerY + 120 + math.sin(angle) * 25
            dot.Position = Vector2.new(x, y)
            
            -- Fade based on position
            local alpha = (math.sin(angle - spinAngle) + 1) / 2
            dot.Transparency = 0.3 + alpha * 0.7
            dot.Color = Color3.fromHSV((hue + i * 0.1) % 1, 0.7, 1)
            dot.Radius = 3 + alpha * 3
        end
        
        -- Pulse logo
        local pulse = math.sin(elapsed * 4) * 0.1 + 0.9
        logo.Transparency = pulse
        
        RunService.RenderStepped:Wait()
    end
    
    -- Hold at 100% briefly
    status.Text = "Welcome!"
    status.Color = Color3.fromRGB(100, 255, 100)
    task.wait(0.5)
    
    -- Fade out
    for i = 1, 0, -0.05 do
        bg.Transparency = i
        logo.Transparency = i
        subtitle.Transparency = i
        barBg.Transparency = i
        barFill.Transparency = i
        status.Transparency = i
        for _, dot in pairs(dots) do
            dot.Transparency = i
        end
        task.wait(0.02)
    end
    
    -- Cleanup
    bg:Remove()
    logo:Remove()
    subtitle:Remove()
    barBg:Remove()
    barFill:Remove()
    status:Remove()
    for _, dot in pairs(dots) do
        dot:Remove()
    end
end

-- Play the loading animation
PlayLoadingAnimation()

--[[ ═══════════════════════════════════════════════════════════════
                       UI LIBRARY SETUP
═══════════════════════════════════════════════════════════════ ]]

--// Now load and initialize the library (after animation)
local library = loadstring(librarySource)()
library:init()

--[[ ═══════════════════════════════════════════════════════════════
                       DRAWING OBJECTS
═══════════════════════════════════════════════════════════════ ]]

--// Drawing Objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false
FOVCircle.Radius = 100

local TargetInfo = {
    Line = Drawing.new("Line"),
    Dot = Drawing.new("Circle"),
}
TargetInfo.Line.Thickness = 1
TargetInfo.Line.Color = Color3.fromRGB(255, 255, 0)
TargetInfo.Line.Visible = false
TargetInfo.Dot.Radius = 5
TargetInfo.Dot.Filled = true
TargetInfo.Dot.Color = Color3.fromRGB(255, 255, 0)
TargetInfo.Dot.Visible = false

--[[ ═══════════════════════════════════════════════════════════════
                       UI WINDOW SETUP
═══════════════════════════════════════════════════════════════ ]]

--// Create Window
local Window = library.NewWindow({
    title = "Luminosity Hub v1.0",
    size = UDim2.new(0, 550, 0, 650)
})

--// Create Tabs
local tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    ESP = Window:AddTab("ESP"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
    Settings = library:CreateSettingsTab(Window),
}

--// Create Sections
local sections = {
    -- Aimbot Tab
    AimbotMain = tabs.Aimbot:AddSection("Aimbot", 1),
    AimbotSettings = tabs.Aimbot:AddSection("Aimbot Settings", 2),
    FOV = tabs.Aimbot:AddSection("FOV Circle", 1),
    FOVVisuals = tabs.Aimbot:AddSection("FOV Visuals", 2),
    
    -- ESP Tab
    ESPMain = tabs.ESP:AddSection("ESP Settings", 1),
    ESPElements = tabs.ESP:AddSection("ESP Elements", 2),
    ESPColors = tabs.ESP:AddSection("ESP Colors", 1),
    ESPStyle = tabs.ESP:AddSection("ESP Style", 2),
    
    -- Visuals Tab
    World = tabs.Visuals:AddSection("World", 1),
    Effects = tabs.Visuals:AddSection("Effects", 2),
    
    -- Misc Tab
    Player = tabs.Misc:AddSection("Player", 1),
    Utility = tabs.Misc:AddSection("Utility", 2),
}

--[[ ═══════════════════════════════════════════════════════════════
                         AIMBOT TAB
═══════════════════════════════════════════════════════════════ ]]

-- Main Aimbot Controls
sections.AimbotMain:AddToggle({
    enabled = true,
    text = "Enable Aimbot",
    flag = "Aimbot_Enabled",
    tooltip = "Master toggle for camera aimbot",
})

sections.AimbotMain:AddBind({
    text = "Aim Key",
    flag = "Aimbot_Key",
    nomouse = false,
    mode = "hold",
    bind = Enum.UserInputType.MouseButton2,
    tooltip = "Hold to lock onto target",
})

sections.AimbotMain:AddList({
    text = "Target Part",
    flag = "Aimbot_Part",
    tooltip = "Body part to aim at",
    values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    value = "Head",
})

sections.AimbotMain:AddList({
    text = "Priority",
    flag = "Aimbot_Priority",
    tooltip = "How to select target",
    values = {"Closest to Crosshair", "Closest Distance", "Lowest Health"},
    value = "Closest to Crosshair",
})

sections.AimbotMain:AddSeparator({ text = "Smoothing" })

sections.AimbotMain:AddSlider({
    text = "Smoothness",
    flag = "Aimbot_Smoothness",
    suffix = "",
    value = 0.5,
    min = 0.1,
    max = 1,
    increment = 0.05,
    tooltip = "Higher = more snappy, Lower = smoother",
})

-- Aimbot Settings
sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Use FOV",
    flag = "Aimbot_Use_FOV",
    tooltip = "Only target players inside FOV circle",
})

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Third Person Mode",
    flag = "Aimbot_Third_Person",
    tooltip = "FOV follows mouse cursor (for third person games)",
})

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Visibility Check",
    flag = "Aimbot_Wall_Check",
    tooltip = "Only aim at visible targets",
})

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Team Check",
    flag = "Aimbot_Team_Check",
    tooltip = "Don't aim at teammates",
})

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Alive Check",
    flag = "Aimbot_Alive_Check",
    tooltip = "Only target alive players",
})

sections.AimbotSettings:AddSeparator({ text = "Target Line" })

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Show Target Line",
    flag = "Aimbot_Target_Line",
    tooltip = "Draw line to current target",
})

sections.AimbotSettings:AddToggle({
    enabled = true,
    text = "Show Target Dot",
    flag = "Aimbot_Target_Dot",
    tooltip = "Draw dot on target position",
})

-- FOV Circle Controls
sections.FOV:AddToggle({
    enabled = true,
    text = "Show FOV Circle",
    flag = "Show_FOV",
    tooltip = "Display the FOV circle on screen",
    callback = function(state)
        FOVCircle.Visible = state
    end
})

sections.FOV:AddSlider({
    text = "FOV Radius",
    flag = "FOV_Radius",
    suffix = "px",
    value = 100,
    min = 10,
    max = 500,
    increment = 5,
    tooltip = "Size of FOV circle",
    callback = function(value)
        FOVCircle.Radius = value
    end
})

sections.FOV:AddToggle({
    enabled = true,
    text = "Filled Circle",
    flag = "FOV_Filled",
    tooltip = "Fill the circle",
    callback = function(state)
        FOVCircle.Filled = state
    end
})

sections.FOV:AddSlider({
    text = "Fill Opacity",
    flag = "FOV_Opacity",
    suffix = "%",
    value = 30,
    min = 0,
    max = 100,
    increment = 5,
    tooltip = "Opacity of filled circle",
    callback = function(value)
        FOVCircle.Transparency = value / 100
    end
})

-- FOV Visuals
sections.FOVVisuals:AddSlider({
    text = "Thickness",
    flag = "FOV_Thickness",
    suffix = "px",
    value = 2,
    min = 1,
    max = 5,
    increment = 1,
    tooltip = "Circle outline thickness",
    callback = function(value)
        FOVCircle.Thickness = value
    end
})

sections.FOVVisuals:AddColor({
    text = "Circle Color",
    flag = "FOV_Color",
    tooltip = "Color of FOV circle",
    color = Color3.fromRGB(255, 0, 0),
    callback = function(color)
        FOVCircle.Color = color
    end
})

sections.FOVVisuals:AddSeparator({ text = "Rainbow" })

sections.FOVVisuals:AddToggle({
    enabled = true,
    text = "Rainbow FOV",
    flag = "FOV_RGB",
    tooltip = "Cycle rainbow colors (uses global RGB Speed)",
})

--[[ ═══════════════════════════════════════════════════════════════
                           ESP TAB
═══════════════════════════════════════════════════════════════ ]]

-- ESP Main Settings
sections.ESPMain:AddToggle({
    enabled = true,
    text = "Enable ESP",
    flag = "ESP_Enabled",
    tooltip = "Master ESP toggle",
})

sections.ESPMain:AddToggle({
    enabled = true,
    text = "Team Check",
    flag = "ESP_Team_Check",
    tooltip = "Hide ESP on teammates",
})

sections.ESPMain:AddSlider({
    text = "Max Distance",
    flag = "ESP_Max_Distance",
    suffix = " studs",
    value = 1000,
    min = 100,
    max = 5000,
    increment = 50,
    tooltip = "Maximum render distance",
})

sections.ESPMain:AddSeparator({ text = "Display Mode" })

sections.ESPMain:AddList({
    text = "Box Type",
    flag = "ESP_Box_Type",
    tooltip = "Style of ESP boxes",
    values = {"Full", "Corner", "None"},
    value = "Full",
})

sections.ESPMain:AddList({
    text = "Tracer Origin",
    flag = "ESP_Tracer_Origin",
    tooltip = "Where tracers start from",
    values = {"Bottom", "Center", "Top", "Mouse"},
    value = "Bottom",
})

-- ESP Elements
sections.ESPElements:AddToggle({
    enabled = true,
    text = "Box ESP",
    flag = "ESP_Box",
    tooltip = "Draw boxes around players",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Name ESP",
    flag = "ESP_Name",
    tooltip = "Show player names",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Health Bar",
    flag = "ESP_Health",
    tooltip = "Show health bars",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Distance",
    flag = "ESP_Distance",
    tooltip = "Show distance to player",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Skeleton ESP",
    flag = "ESP_Skeleton",
    tooltip = "Draw skeleton lines on players",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Tracers",
    flag = "ESP_Tracers",
    tooltip = "Draw lines to players",
})

sections.ESPElements:AddToggle({
    enabled = true,
    text = "Box Outline",
    flag = "ESP_Box_Outline",
    tooltip = "Add black outline to boxes",
})

-- ESP Colors
sections.ESPColors:AddColor({
    text = "Box Color",
    flag = "ESP_Box_Color",
    tooltip = "Color of ESP boxes",
    color = Color3.fromRGB(255, 50, 50),
})

sections.ESPColors:AddColor({
    text = "Name Color",
    flag = "ESP_Name_Color",
    tooltip = "Color of player names",
    color = Color3.fromRGB(255, 255, 255),
})

sections.ESPColors:AddColor({
    text = "Tracer Color",
    flag = "ESP_Tracer_Color",
    tooltip = "Color of tracers",
    color = Color3.fromRGB(255, 50, 50),
})

sections.ESPColors:AddColor({
    text = "Skeleton Color",
    flag = "ESP_Skeleton_Color",
    tooltip = "Color of skeleton lines",
    color = Color3.fromRGB(255, 255, 255),
})

sections.ESPColors:AddSeparator({ text = "Rainbow" })

sections.ESPColors:AddToggle({
    enabled = true,
    text = "Rainbow Box",
    flag = "ESP_Box_RGB",
    tooltip = "Rainbow colors on boxes",
})

sections.ESPColors:AddToggle({
    enabled = true,
    text = "Rainbow Tracers",
    flag = "ESP_Tracer_RGB",
    tooltip = "Rainbow colors on tracers",
})

-- ESP Style
sections.ESPStyle:AddSlider({
    text = "Box Thickness",
    flag = "ESP_Box_Thickness",
    suffix = "px",
    value = 1,
    min = 1,
    max = 5,
    increment = 1,
    tooltip = "Thickness of ESP boxes",
})

sections.ESPStyle:AddSlider({
    text = "Tracer Thickness",
    flag = "ESP_Tracer_Thickness",
    suffix = "px",
    value = 2,
    min = 1,
    max = 5,
    increment = 1,
    tooltip = "Thickness of tracers",
})

sections.ESPStyle:AddSlider({
    text = "Text Size",
    flag = "ESP_Text_Size",
    suffix = "px",
    value = 13,
    min = 10,
    max = 20,
    increment = 1,
    tooltip = "Size of ESP text",
})

sections.ESPStyle:AddSeparator({ text = "Global" })

sections.ESPStyle:AddSlider({
    text = "Rainbow Speed",
    flag = "RGB_Speed",
    suffix = "x",
    value = 1,
    min = 0.1,
    max = 5,
    increment = 0.1,
    tooltip = "Speed of all rainbow effects (FOV, ESP, Ambient)",
})

--[[ ═══════════════════════════════════════════════════════════════
                        VISUALS TAB
═══════════════════════════════════════════════════════════════ ]]

-- World Section
sections.World:AddToggle({
    enabled = true,
    text = "Fullbright",
    flag = "Fullbright",
    tooltip = "Remove darkness/shadows",
    callback = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            lighting.Brightness = 1
            lighting.GlobalShadows = true
            lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end
})

sections.World:AddToggle({
    enabled = true,
    text = "No Fog",
    flag = "No_Fog",
    tooltip = "Remove fog from the game",
    callback = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.FogEnd = 100000
        else
            lighting.FogEnd = 1000
        end
    end
})

sections.World:AddSlider({
    text = "Field of View",
    flag = "Camera_FOV",
    suffix = "°",
    value = 70,
    min = 30,
    max = 120,
    increment = 1,
    tooltip = "Camera field of view",
    callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

-- Effects Section
sections.Effects:AddToggle({
    enabled = true,
    text = "No Effects",
    flag = "No_Effects",
    tooltip = "Remove blur, bloom, etc",
    callback = function(state)
        local lighting = game:GetService("Lighting")
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = not state
            end
        end
    end
})

sections.Effects:AddToggle({
    enabled = true,
    text = "Rainbow Ambient",
    flag = "Rainbow_Ambient",
    tooltip = "Cycle ambient colors",
})

--[[ ═══════════════════════════════════════════════════════════════
                          MISC TAB
═══════════════════════════════════════════════════════════════ ]]

-- Player Section
sections.Player:AddSlider({
    text = "WalkSpeed",
    flag = "WalkSpeed",
    suffix = "",
    value = 16,
    min = 16,
    max = 100,
    increment = 1,
    tooltip = "Character walk speed",
    callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

sections.Player:AddSlider({
    text = "JumpPower",
    flag = "JumpPower",
    suffix = "",
    value = 50,
    min = 50,
    max = 200,
    increment = 5,
    tooltip = "Character jump power",
    callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

-- Utility Section
sections.Utility:AddButton({
    text = "Rejoin Server",
    tooltip = "Rejoin the current server",
    callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

sections.Utility:AddButton({
    text = "Copy Join Script",
    tooltip = "Copy script to join this server",
    callback = function()
        setclipboard(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', game.PlaceId, game.JobId))
        library:SendNotification("Copied to clipboard!", 3, Color3.fromRGB(0, 255, 0))
    end
})

sections.Utility:AddButton({
    text = "Reset Character",
    tooltip = "Reset your character",
    callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end
})

--[[ ═══════════════════════════════════════════════════════════════
                       BACKEND CODE
═══════════════════════════════════════════════════════════════ ]]

--// State Variables
local ESPObjects = {}
local IsAimKeyHeld = false
local Connections = {}
local RGBHue = 0
local CurrentTarget = nil
local OriginalAmbient = game:GetService("Lighting").Ambient
local StoredFOVColor = Color3.fromRGB(255, 0, 0)
local StoredBoxColor = Color3.fromRGB(255, 50, 50)
local StoredTracerColor = Color3.fromRGB(255, 50, 50)

--// Utility Functions
local function GetRGBColor(hue)
    return Color3.fromHSV(hue or RGBHue, 1, 1)
end

--// Cleanup Function
local function Cleanup()
    -- Remove FOV Circle
    if FOVCircle then
        pcall(function() FOVCircle:Remove() end)
    end
    
    -- Remove Target Info drawings
    if TargetInfo then
        pcall(function() TargetInfo.Line:Remove() end)
        pcall(function() TargetInfo.Dot:Remove() end)
    end
    
    -- Remove all ESP drawings
    for player, esp in pairs(ESPObjects) do
        if esp.Box then pcall(function() esp.Box:Remove() end) end
        if esp.BoxOutline then pcall(function() esp.BoxOutline:Remove() end) end
        if esp.Name then pcall(function() esp.Name:Remove() end) end
        if esp.Distance then pcall(function() esp.Distance:Remove() end) end
        if esp.HealthBG then pcall(function() esp.HealthBG:Remove() end) end
        if esp.Health then pcall(function() esp.Health:Remove() end) end
        if esp.Tracer then pcall(function() esp.Tracer:Remove() end) end
        
        -- Remove corner lines
        if esp.Corners then
            for i = 1, 8 do
                if esp.Corners[i] then
                    pcall(function() esp.Corners[i]:Remove() end)
                end
            end
        end
        
        -- Remove skeleton lines
        if esp.Skeleton then
            for name, line in pairs(esp.Skeleton) do
                pcall(function() line:Remove() end)
            end
        end
    end
    table.clear(ESPObjects)
    
    -- Disconnect all connections
    for _, connection in pairs(Connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
    
    -- Reset lighting changes
    local lighting = game:GetService("Lighting")
    lighting.Ambient = OriginalAmbient
    lighting.Brightness = 1
    lighting.GlobalShadows = true
    lighting.FogEnd = 1000
    
    -- Re-enable effects
    for _, effect in pairs(lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = true
        end
    end
    
    -- Reset camera FOV
    workspace.CurrentCamera.FieldOfView = 70
    
    -- Reset character stats
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    
    -- Notification
    library:SendNotification("Script Unloaded!", 3, Color3.fromRGB(255, 100, 100))
end

-- Connect to library unload signal
library.unloaded:Connect(Cleanup)

-- Track aimbot key manually
Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = true
    end
end)

Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = false
    end
end)

-- Get closest target for aimbot
local function GetAimbotTarget()
    local camera = workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()
    local thirdPerson = library.flags["Aimbot_Third_Person"]
    local aimOrigin = thirdPerson and mousePos or screenCenter
    local closestPlayer = nil
    local closestDistance = math.huge
    
    local targetPart = library.flags["Aimbot_Part"] or "Head"
    local useFOV = library.flags["Aimbot_Use_FOV"]
    local fovRadius = library.flags["FOV_Radius"] or 100
    local wallCheck = library.flags["Aimbot_Wall_Check"]
    local teamCheck = library.flags["Aimbot_Team_Check"]
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local part = character and character:FindFirstChild(targetPart)
            
            if character and humanoid and part and humanoid.Health > 0 then
                -- Team check
                if teamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - aimOrigin).Magnitude
                    
                    -- FOV check
                    if useFOV and screenDistance > fovRadius then
                        continue
                    end
                    
                    -- Wall check
                    if wallCheck then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local ray = Ray.new(myRoot.Position, (part.Position - myRoot.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, camera})
                            if hit and not hit:IsDescendantOf(character) then
                                continue
                            end
                        end
                    end
                    
                    if screenDistance < closestDistance then
                        closestDistance = screenDistance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Create ESP drawings for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Corners = {},
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBG = Drawing.new("Line"),
        Health = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
    }
    
    local esp = ESPObjects[player]
    
    -- Box
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    -- Box Outline
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.BoxOutline.Visible = false
    
    -- Corner Lines (8 lines for 4 corners)
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        esp.Corners[i] = line
    end
    
    -- Skeleton Lines
    local skeletonParts = {"Head_Neck", "Neck_LeftArm", "Neck_RightArm", "LeftArm_LeftHand", "RightArm_RightHand", "Neck_Torso", "Torso_LeftLeg", "Torso_RightLeg", "LeftLeg_LeftFoot", "RightLeg_RightFoot"}
    for _, name in pairs(skeletonParts) do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        esp.Skeleton[name] = line
    end
    
    -- Name Text
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    -- Distance Text
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Visible = false
    
    -- Health Bar Background
    esp.HealthBG.Thickness = 4
    esp.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBG.Transparency = 1
    esp.HealthBG.Visible = false
    
    -- Health Bar Fill
    esp.Health.Thickness = 2
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Transparency = 1
    esp.Health.Visible = false
    
    -- Tracer Line
    esp.Tracer.Transparency = 1
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 2
end

-- Remove ESP drawings for a player
local function RemoveESP(player)
    if ESPObjects[player] then
        for key, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, subObj in pairs(obj) do
                    subObj:Remove()
                end
            else
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Connections.PlayerAdded = Players.PlayerAdded:Connect(CreateESP)
Connections.PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)

-- Main Update Loop
Connections.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
    local camera = workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()
    
    --// Update RGB Hue (synced for all effects)
    local rgbSpeed = library.flags["RGB_Speed"] or 1
    RGBHue = (RGBHue + deltaTime * rgbSpeed * 0.5) % 1
    local rgbColor = GetRGBColor(RGBHue)
    
    --// Update FOV Circle
    local thirdPerson = library.flags["Aimbot_Third_Person"]
    FOVCircle.Position = thirdPerson and mousePos or screenCenter
    if library.flags["FOV_RGB"] then
        FOVCircle.Color = rgbColor
    else
        FOVCircle.Color = library.flags["FOV_Color"] or StoredFOVColor
    end
    
    --// Rainbow Ambient
    if library.flags["Rainbow_Ambient"] then
        game:GetService("Lighting").Ambient = rgbColor
    else
        -- Only reset if it was previously rainbow (check if it's a saturated color)
        local currentAmbient = game:GetService("Lighting").Ambient
        local h, s, v = currentAmbient:ToHSV()
        if s > 0.9 and v > 0.9 then
            game:GetService("Lighting").Ambient = OriginalAmbient
        end
    end
    
    --// Aimbot Logic
    CurrentTarget = nil
    TargetInfo.Line.Visible = false
    TargetInfo.Dot.Visible = false
    
    if library.flags["Aimbot_Enabled"] and IsAimKeyHeld then
        local target = GetAimbotTarget()
        if target then
            CurrentTarget = target
            local character = target.Character
            local targetPart = library.flags["Aimbot_Part"] or "Head"
            local part = character and character:FindFirstChild(targetPart)
            
            if part then
                local smoothness = library.flags["Aimbot_Smoothness"] or 0.5
                local lerpAlpha = 1.1 - smoothness
                
                if thirdPerson then
                    -- Third Person Mode: Move mouse to target position
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local currentMousePos = mousePos
                        local delta = (targetScreenPos - currentMousePos) * lerpAlpha
                        
                        -- Use mousemoverel to move the mouse towards the target
                        if delta.Magnitude > 1 then
                            mousemoverel(delta.X, delta.Y)
                        end
                    end
                else
                    -- First Person Mode: Rotate camera to target
                    local targetCFrame = CFrame.new(camera.CFrame.Position, part.Position)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpAlpha)
                end
                
                -- Target Line
                if library.flags["Aimbot_Target_Line"] then
                    local screenPos = camera:WorldToViewportPoint(part.Position)
                    local lineOrigin = thirdPerson and mousePos or screenCenter
                    TargetInfo.Line.From = lineOrigin
                    TargetInfo.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                    TargetInfo.Line.Color = rgbColor
                    TargetInfo.Line.Visible = true
                end
                
                -- Target Dot
                if library.flags["Aimbot_Target_Dot"] then
                    local screenPos = camera:WorldToViewportPoint(part.Position)
                    TargetInfo.Dot.Position = Vector2.new(screenPos.X, screenPos.Y)
                    TargetInfo.Dot.Color = rgbColor
                    TargetInfo.Dot.Visible = true
                end
            end
        end
    end
    
    --// Update ESP for each player
    for player, esp in pairs(ESPObjects) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if character and humanoid and rootPart and humanoid.Health > 0 then
            local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = myRoot and (myRoot.Position - rootPart.Position).Magnitude or 0
            
            local isTeammate = library.flags["ESP_Team_Check"] and player.Team == LocalPlayer.Team
            local maxDist = library.flags["ESP_Max_Distance"] or 1000
            local espEnabled = library.flags["ESP_Enabled"]
            local textSize = library.flags["ESP_Text_Size"] or 13
            
            if onScreen and espEnabled and not isTeammate and distance <= maxDist then
                -- Get character bounds from head and humanoidrootpart
                local head = character:FindFirstChild("Head")
                
                -- Calculate box dimensions from actual character
                local headTop = head and (head.Position + Vector3.new(0, head.Size.Y / 2 + 0.5, 0)) or (rootPart.Position + Vector3.new(0, 2.5, 0))
                local feetBottom = rootPart.Position - Vector3.new(0, 3, 0)
                
                local headScreenPos = camera:WorldToViewportPoint(headTop)
                local feetScreenPos = camera:WorldToViewportPoint(feetBottom)
                
                local boxHeight = math.abs(feetScreenPos.Y - headScreenPos.Y)
                boxHeight = math.clamp(boxHeight, 30, 1000)
                local boxWidth = boxHeight * 0.55
                local boxX = rootPos.X - boxWidth / 2
                local boxY = headScreenPos.Y
                
                local boxType = library.flags["ESP_Box_Type"] or "Full"
                local showBox = library.flags["ESP_Box"] and boxType ~= "None"
                local boxColor = library.flags["ESP_Box_RGB"] and rgbColor or (library.flags["ESP_Box_Color"] or StoredBoxColor)
                local boxThickness = library.flags["ESP_Box_Thickness"] or 1
                
                --// Hide full box elements when using corners
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                for i = 1, 8 do
                    esp.Corners[i].Visible = false
                end
                
                if showBox then
                    if boxType == "Full" then
                        --// Box Outline (draw first so it's behind)
                        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.BoxOutline.Visible = library.flags["ESP_Box_Outline"] or false
                        
                        --// Full Box
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Color = boxColor
                        esp.Box.Thickness = boxThickness
                        esp.Box.Visible = true
                    elseif boxType == "Corner" then
                        --// Corner Box
                        local cornerLength = math.min(boxWidth, boxHeight) * 0.25
                        
                        -- Top Left
                        esp.Corners[1].From = Vector2.new(boxX, boxY)
                        esp.Corners[1].To = Vector2.new(boxX + cornerLength, boxY)
                        esp.Corners[2].From = Vector2.new(boxX, boxY)
                        esp.Corners[2].To = Vector2.new(boxX, boxY + cornerLength)
                        
                        -- Top Right
                        esp.Corners[3].From = Vector2.new(boxX + boxWidth, boxY)
                        esp.Corners[3].To = Vector2.new(boxX + boxWidth - cornerLength, boxY)
                        esp.Corners[4].From = Vector2.new(boxX + boxWidth, boxY)
                        esp.Corners[4].To = Vector2.new(boxX + boxWidth, boxY + cornerLength)
                        
                        -- Bottom Left
                        esp.Corners[5].From = Vector2.new(boxX, boxY + boxHeight)
                        esp.Corners[5].To = Vector2.new(boxX + cornerLength, boxY + boxHeight)
                        esp.Corners[6].From = Vector2.new(boxX, boxY + boxHeight)
                        esp.Corners[6].To = Vector2.new(boxX, boxY + boxHeight - cornerLength)
                        
                        -- Bottom Right
                        esp.Corners[7].From = Vector2.new(boxX + boxWidth, boxY + boxHeight)
                        esp.Corners[7].To = Vector2.new(boxX + boxWidth - cornerLength, boxY + boxHeight)
                        esp.Corners[8].From = Vector2.new(boxX + boxWidth, boxY + boxHeight)
                        esp.Corners[8].To = Vector2.new(boxX + boxWidth, boxY + boxHeight - cornerLength)
                        
                        for i = 1, 8 do
                            esp.Corners[i].Color = boxColor
                            esp.Corners[i].Thickness = boxThickness
                            esp.Corners[i].Visible = true
                        end
                    end
                end
                
                --// Skeleton ESP
                local showSkeleton = library.flags["ESP_Skeleton"] or false
                local skeletonColor = library.flags["ESP_Box_RGB"] and rgbColor or (library.flags["ESP_Skeleton_Color"] or Color3.new(1, 1, 1))
                for _, line in pairs(esp.Skeleton) do
                    line.Visible = false
                end
                
                if showSkeleton then
                    local function GetBonePos(boneName)
                        local part = character:FindFirstChild(boneName)
                        if part then
                            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                return Vector2.new(pos.X, pos.Y), true
                            end
                        end
                        return nil, false
                    end
                    
                    local function DrawBone(lineName, part1, part2)
                        local pos1, vis1 = GetBonePos(part1)
                        local pos2, vis2 = GetBonePos(part2)
                        if pos1 and pos2 and vis1 and vis2 then
                            esp.Skeleton[lineName].From = pos1
                            esp.Skeleton[lineName].To = pos2
                            esp.Skeleton[lineName].Color = skeletonColor
                            esp.Skeleton[lineName].Visible = true
                        end
                    end
                    
                    -- R15 Skeleton
                    DrawBone("Head_Neck", "Head", "UpperTorso")
                    DrawBone("Neck_LeftArm", "UpperTorso", "LeftUpperArm")
                    DrawBone("Neck_RightArm", "UpperTorso", "RightUpperArm")
                    DrawBone("LeftArm_LeftHand", "LeftUpperArm", "LeftHand")
                    DrawBone("RightArm_RightHand", "RightUpperArm", "RightHand")
                    DrawBone("Neck_Torso", "UpperTorso", "LowerTorso")
                    DrawBone("Torso_LeftLeg", "LowerTorso", "LeftUpperLeg")
                    DrawBone("Torso_RightLeg", "LowerTorso", "RightUpperLeg")
                    DrawBone("LeftLeg_LeftFoot", "LeftUpperLeg", "LeftFoot")
                    DrawBone("RightLeg_RightFoot", "RightUpperLeg", "RightFoot")
                end
                
                --// Name
                esp.Name.Text = player.Name
                esp.Name.Size = textSize
                esp.Name.Position = Vector2.new(rootPos.X, boxY - textSize - 2)
                esp.Name.Color = library.flags["ESP_Name_Color"] or Color3.new(1, 1, 1)
                esp.Name.Visible = library.flags["ESP_Name"] or false
                
                --// Distance (separate text below box)
                esp.Distance.Text = "[" .. math.floor(distance) .. "m]"
                esp.Distance.Size = textSize - 2
                esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 2)
                esp.Distance.Visible = library.flags["ESP_Distance"] or false
                
                --// Health Bar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthX = boxX - 6
                
                esp.HealthBG.From = Vector2.new(healthX, boxY)
                esp.HealthBG.To = Vector2.new(healthX, boxY + boxHeight)
                esp.HealthBG.Visible = library.flags["ESP_Health"] or false
                
                local healthHeight = boxHeight * healthPercent
                esp.Health.From = Vector2.new(healthX, boxY + boxHeight)
                esp.Health.To = Vector2.new(healthX, boxY + boxHeight - healthHeight)
                esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                esp.Health.Visible = library.flags["ESP_Health"] or false
                
                --// Tracer
                local tracerOrigin = library.flags["ESP_Tracer_Origin"] or "Bottom"
                local startX = camera.ViewportSize.X / 2
                local startY = camera.ViewportSize.Y
                
                if tracerOrigin == "Top" then
                    startY = 0
                elseif tracerOrigin == "Center" then
                    startY = camera.ViewportSize.Y / 2
                elseif tracerOrigin == "Mouse" then
                    startX = mousePos.X
                    startY = mousePos.Y
                end
                
                esp.Tracer.From = Vector2.new(startX, startY)
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight / 2)
                if library.flags["ESP_Tracer_RGB"] then
                    esp.Tracer.Color = rgbColor
                else
                    esp.Tracer.Color = library.flags["ESP_Tracer_Color"] or StoredTracerColor
                end
                esp.Tracer.Thickness = library.flags["ESP_Tracer_Thickness"] or 1
                esp.Tracer.Visible = library.flags["ESP_Tracers"] or false
            else
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                for i = 1, 8 do esp.Corners[i].Visible = false end
                for _, line in pairs(esp.Skeleton) do line.Visible = false end
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Health.Visible = false
                esp.HealthBG.Visible = false
                esp.Tracer.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
            for i = 1, 8 do esp.Corners[i].Visible = false end
            for _, line in pairs(esp.Skeleton) do line.Visible = false end
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Health.Visible = false
            esp.HealthBG.Visible = false
            esp.Tracer.Visible = false
        end
    end
end)

--// Startup Notification
library:SendNotification("Luminosity Hub Loaded!", 5, Color3.fromRGB(255, 0, 0))

--// Fix initial layout by switching tabs
task.spawn(function()
    task.wait(0.1)
    tabs.ESP:Select()
    task.wait(0.05)
    tabs.Aimbot:Select()
end)
