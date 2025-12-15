--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                     LUMINOSITY HUB                            ║
    ║          Universal Script - Full Feature Edition              ║
    ║                                                               ║
    ║  Credits: @jshawk (Original Dev)                              ║
    ║  UI Library: Luminosity UI v2.0                               ║
    ║  Version: 2.0 - Enhanced Edition                              ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

--[[ ═══════════════════════════════════════════════════════════════
                        CONFIGURATION
═══════════════════════════════════════════════════════════════ ]]

getgenv().Config = {
    Invite = "Luminosityhub.com",
    Version = "2.0",
    ScriptName = "Luminosity Hub",
}

getgenv().luaguardvars = {
    DiscordName = "jshawk",
}

--[[ ═══════════════════════════════════════════════════════════════
                        SERVICES & VARIABLES
═══════════════════════════════════════════════════════════════ ]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

--// Local Player References
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// State Variables
local ESPObjects = {}
local CrosshairObjects = {}
local AimbotTarget = nil
local IsAimKeyHeld = false
local IsSilentAimKeyHeld = false
local Connections = {}
local RGBHue = 0
local OriginalAmbient = Lighting.Ambient
local SavedPosition = nil
local AntiAFKEnabled = false
local SpinBotAngle = 0
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local TeleportPlayers = {}

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

--// Load and initialize the library
local library = loadstring(librarySource)()
library:init()

--[[ ═══════════════════════════════════════════════════════════════
                        DRAWING OBJECTS
═══════════════════════════════════════════════════════════════ ]]

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false
FOVCircle.Radius = 100

--// Target Info Indicator
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

--// Crosshair Elements
CrosshairObjects.Horizontal = Drawing.new("Line")
CrosshairObjects.Horizontal.Thickness = 2
CrosshairObjects.Horizontal.Color = Color3.fromRGB(255, 255, 255)
CrosshairObjects.Horizontal.Visible = false

CrosshairObjects.Vertical = Drawing.new("Line")
CrosshairObjects.Vertical.Thickness = 2
CrosshairObjects.Vertical.Color = Color3.fromRGB(255, 255, 255)
CrosshairObjects.Vertical.Visible = false

CrosshairObjects.Circle = Drawing.new("Circle")
CrosshairObjects.Circle.Thickness = 2
CrosshairObjects.Circle.NumSides = 32
CrosshairObjects.Circle.Filled = false
CrosshairObjects.Circle.Color = Color3.fromRGB(255, 255, 255)
CrosshairObjects.Circle.Visible = false

CrosshairObjects.Dot = Drawing.new("Circle")
CrosshairObjects.Dot.Radius = 2
CrosshairObjects.Dot.Filled = true
CrosshairObjects.Dot.Color = Color3.fromRGB(255, 255, 255)
CrosshairObjects.Dot.Visible = false

CrosshairObjects.OutlineH = Drawing.new("Line")
CrosshairObjects.OutlineH.Thickness = 4
CrosshairObjects.OutlineH.Color = Color3.fromRGB(0, 0, 0)
CrosshairObjects.OutlineH.Visible = false

CrosshairObjects.OutlineV = Drawing.new("Line")
CrosshairObjects.OutlineV.Thickness = 4
CrosshairObjects.OutlineV.Color = Color3.fromRGB(0, 0, 0)
CrosshairObjects.OutlineV.Visible = false

--[[ ═══════════════════════════════════════════════════════════════
                        UI WINDOW SETUP
═══════════════════════════════════════════════════════════════ ]]

--// Create Window
local Window = library.NewWindow({
    title = "Luminosity Hub v2.0 - Enhanced",
    size = UDim2.new(0, 600, 0, 650)
})

--// Create Tabs
local tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    Visuals = Window:AddTab("ESP/Visuals"),
    Player = Window:AddTab("Player"),
    Misc = Window:AddTab("Misc"),
    Settings = library:CreateSettingsTab(Window),
}

print("Created enhanced Luminosity Hub v2.0!")
print("Total lines generated: TBD")

--[[ ═══════════════════════════════════════════════════════════════
                          AIMBOT TAB
═══════════════════════════════════════════════════════════════ ]]

--// Create Sections
local AimbotSections = {
    Main = tabs.Aimbot:AddSection("Main Settings", 1),
    Targeting = tabs.Aimbot:AddSection("Targeting", 2),
    FOV = tabs.Aimbot:AddSection("FOV Circle", 1),
    Silent = tabs.Aimbot:AddSection("Silent Aim", 2),
}

--// Main Settings Section
AimbotSections.Main:AddToggle({
    text = "Enable Aimbot",
    flag = "Aimbot_Enabled",
    tooltip = "Master toggle for camera aimbot",
    risky = true,
})

AimbotSections.Main:AddBind({
    text = "Aim Key",
    flag = "Aimbot_Key",
    nomouse = false,
    mode = "hold",
    bind = Enum.UserInputType.MouseButton2,
    tooltip = "Hold to lock onto target",
})

AimbotSections.Main:AddToggle({
    text = "Team Check",
    flag = "Aimbot_Team_Check",
    tooltip = "Don't aim at teammates",
})

AimbotSections.Main:AddToggle({
    text = "Visible Check",
    flag = "Aimbot_Wall_Check",
    tooltip = "Only aim at visible targets (wall check)",
})

AimbotSections.Main:AddSlider({
    text = "Smoothing",
    flag = "Aimbot_Smoothness",
    suffix = "",
    value = 0.5,
    min = 0.01,
    max = 1,
    increment = 0.01,
    tooltip = "Lower = smoother aim, Higher = snappier aim",
})

AimbotSections.Main:AddToggle({
    text = "Prediction",
    flag = "Aimbot_Prediction",
    tooltip = "Predict target movement (experimental)",
})

AimbotSections.Main:AddSlider({
    text = "Prediction Velocity",
    flag = "Aimbot_Prediction_Velocity",
    suffix = "x",
    value = 0.165,
    min = 0.01,
    max = 0.5,
    increment = 0.005,
    tooltip = "Velocity multiplier for prediction",
})

--// Targeting Section
AimbotSections.Targeting:AddList({
    text = "Target Part",
    flag = "Aimbot_Part",
    tooltip = "Body part to aim at",
    values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random", "Closest"},
    value = "Head",
})

AimbotSections.Targeting:AddList({
    text = "Target Mode",
    flag = "Aimbot_Priority",
    tooltip = "How to select targets",
    values = {"Nearest to Cursor", "Nearest to Player", "Lowest Health"},
    value = "Nearest to Cursor",
})

AimbotSections.Targeting:AddToggle({
    text = "Stick to Target",
    flag = "Aimbot_Stick",
    tooltip = "Stay locked on same target while aimbot active",
})

AimbotSections.Targeting:AddSlider({
    text = "Max Distance",
    flag = "Aimbot_Max_Distance",
    suffix = " studs",
    value = 1000,
    min = 100,
    max = 5000,
    increment = 50,
    tooltip = "Maximum targeting distance",
})

--// FOV Circle Section
AimbotSections.FOV:AddToggle({
    text = "Show FOV Circle",
    flag = "Show_FOV",
    tooltip = "Display the FOV circle on screen",
    callback = function(state)
        FOVCircle.Visible = state
    end
})

AimbotSections.FOV:AddSlider({
    text = "FOV Radius",
    flag = "FOV_Radius",
    suffix = "px",
    value = 100,
    min = 1,
    max = 500,
    increment = 5,
    tooltip = "Size of FOV circle",
    callback = function(value)
        FOVCircle.Radius = value
    end
})

AimbotSections.FOV:AddToggle({
    text = "Third Person Mode",
    flag = "Aimbot_Third_Person",
    tooltip = "FOV follows mouse cursor (for third person)",
})

AimbotSections.FOV:AddColor({
    text = "FOV Color",
    flag = "FOV_Color",
    tooltip = "Color of FOV circle",
    color = Color3.fromRGB(255, 0, 0),
    callback = function(color)
        FOVCircle.Color = color
    end
})

AimbotSections.FOV:AddToggle({
    text = "Rainbow FOV",
    flag = "FOV_RGB",
    tooltip = "Cycle rainbow colors on FOV circle",
})

AimbotSections.FOV:AddSlider({
    text = "Filled Transparency",
    flag = "FOV_Fill_Transparency",
    suffix = "%",
    value = 0,
    min = 0,
    max = 100,
    increment = 5,
    tooltip = "Fill transparency (0 = no fill)",
    callback = function(value)
        FOVCircle.Filled = value > 0
        FOVCircle.Transparency = value / 100
    end
})

--// Silent Aim Section
AimbotSections.Silent:AddToggle({
    text = "Silent Aim",
    flag = "Silent_Aim_Enabled",
    tooltip = "Silent aim (no camera movement)",
    risky = true,
})

AimbotSections.Silent:AddBind({
    text = "Silent Aim Key",
    flag = "Silent_Aim_Key",
    nomouse = false,
    mode = "hold",
    bind = Enum.KeyCode.C,
    tooltip = "Hold for silent aim",
})

AimbotSections.Silent:AddSlider({
    text = "Silent Aim Chance",
    flag = "Silent_Aim_Chance",
    suffix = "%",
    value = 100,
    min = 1,
    max = 100,
    increment = 1,
    tooltip = "Chance for silent aim to activate",
})

AimbotSections.Silent:AddSlider({
    text = "Hit Chance",
    flag = "Silent_Hit_Chance",
    suffix = "%",
    value = 100,
    min = 1,
    max = 100,
    increment = 1,
    tooltip = "Chance to hit target with silent aim",
})


--[[ ═══════════════════════════════════════════════════════════════
                        ESP/VISUALS TAB
═══════════════════════════════════════════════════════════════ ]]

--// Create Sections
local VisualsSections = {
    PlayerESP = tabs.Visuals:AddSection("Player ESP", 1),
    ESPColors = tabs.Visuals:AddSection("ESP Colors", 2),
    Crosshair = tabs.Visuals:AddSection("Crosshair", 1),
    World = tabs.Visuals:AddSection("World", 2),
}

--// Player ESP Section
VisualsSections.PlayerESP:AddToggle({
    text = "Enable ESP",
    flag = "ESP_Enabled",
    tooltip = "Master ESP toggle",
})

VisualsSections.PlayerESP:AddBind({
    text = "ESP Keybind",
    flag = "ESP_Key",
    nomouse = true,
    mode = "toggle",
    bind = Enum.KeyCode.Insert,
    tooltip = "Toggle ESP on/off",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Team Check",
    flag = "ESP_Team_Check",
    tooltip = "Hide ESP on teammates",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Box ESP",
    flag = "ESP_Box",
    tooltip = "Draw boxes around players",
})

VisualsSections.PlayerESP:AddList({
    text = "Box Type",
    flag = "ESP_Box_Type",
    tooltip = "Style of ESP boxes",
    values = {"2D", "Corner", "3D"},
    value = "2D",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Name ESP",
    flag = "ESP_Name",
    tooltip = "Show player names",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Health Bar",
    flag = "ESP_Health",
    tooltip = "Show health bars",
})

VisualsSections.PlayerESP:AddList({
    text = "Health Position",
    flag = "ESP_Health_Position",
    tooltip = "Where to show health bar",
    values = {"Left", "Right", "Top", "Bottom"},
    value = "Left",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Distance ESP",
    flag = "ESP_Distance",
    tooltip = "Show distance to players",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Tracers",
    flag = "ESP_Tracers",
    tooltip = "Draw lines to players",
})

VisualsSections.PlayerESP:AddList({
    text = "Tracer Position",
    flag = "ESP_Tracer_Origin",
    tooltip = "Where tracers start from",
    values = {"Bottom", "Center", "Top", "Mouse"},
    value = "Bottom",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Skeleton ESP",
    flag = "ESP_Skeleton",
    tooltip = "Draw skeleton on players",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Chams/Highlight",
    flag = "ESP_Chams",
    tooltip = "Highlight players through walls",
    risky = true,
})

VisualsSections.PlayerESP:AddSlider({
    text = "Chams Transparency",
    flag = "ESP_Chams_Transparency",
    suffix = "%",
    value = 50,
    min = 0,
    max = 100,
    increment = 5,
    tooltip = "Transparency of chams",
})

VisualsSections.PlayerESP:AddToggle({
    text = "Tool/Weapon ESP",
    flag = "ESP_Tool",
    tooltip = "Show equipped tools",
})

VisualsSections.PlayerESP:AddSlider({
    text = "Max Distance",
    flag = "ESP_Max_Distance",
    suffix = " studs",
    value = 1000,
    min = 100,
    max = 5000,
    increment = 50,
    tooltip = "Maximum render distance",
})

--// ESP Colors Section
VisualsSections.ESPColors:AddColor({
    text = "Box Color",
    flag = "ESP_Box_Color",
    tooltip = "Color of ESP boxes",
    color = Color3.fromRGB(255, 50, 50),
})

VisualsSections.ESPColors:AddToggle({
    text = "Rainbow Box",
    flag = "ESP_Box_RGB",
    tooltip = "Rainbow color cycling on boxes",
})

VisualsSections.ESPColors:AddColor({
    text = "Name Color",
    flag = "ESP_Name_Color",
    tooltip = "Color of player names",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.ESPColors:AddColor({
    text = "Tracer Color",
    flag = "ESP_Tracer_Color",
    tooltip = "Color of tracers",
    color = Color3.fromRGB(255, 50, 50),
})

VisualsSections.ESPColors:AddToggle({
    text = "Rainbow Tracers",
    flag = "ESP_Tracer_RGB",
    tooltip = "Rainbow color cycling on tracers",
})

VisualsSections.ESPColors:AddColor({
    text = "Skeleton Color",
    flag = "ESP_Skeleton_Color",
    tooltip = "Color of skeleton lines",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.ESPColors:AddColor({
    text = "Chams Color",
    flag = "ESP_Chams_Color",
    tooltip = "Color of chams/highlights",
    color = Color3.fromRGB(255, 100, 100),
})

VisualsSections.ESPColors:AddSlider({
    text = "Rainbow Speed",
    flag = "RGB_Speed",
    suffix = "x",
    value = 1,
    min = 0.1,
    max = 5,
    increment = 0.1,
    tooltip = "Speed of rainbow effects",
})

--// Crosshair Section
VisualsSections.Crosshair:AddToggle({
    text = "Enable Crosshair",
    flag = "Crosshair_Enabled",
    tooltip = "Show custom crosshair",
})

VisualsSections.Crosshair:AddList({
    text = "Style",
    flag = "Crosshair_Style",
    tooltip = "Crosshair style",
    values = {"Cross", "Circle", "Dot", "T-Shape", "Plus"},
    value = "Cross",
})

VisualsSections.Crosshair:AddSlider({
    text = "Size",
    flag = "Crosshair_Size",
    suffix = "px",
    value = 10,
    min = 5,
    max = 50,
    increment = 1,
    tooltip = "Crosshair size",
})

VisualsSections.Crosshair:AddSlider({
    text = "Thickness",
    flag = "Crosshair_Thickness",
    suffix = "px",
    value = 2,
    min = 1,
    max = 10,
    increment = 1,
    tooltip = "Line thickness",
})

VisualsSections.Crosshair:AddSlider({
    text = "Gap",
    flag = "Crosshair_Gap",
    suffix = "px",
    value = 5,
    min = 0,
    max = 20,
    increment = 1,
    tooltip = "Gap from center",
})

VisualsSections.Crosshair:AddColor({
    text = "Color",
    flag = "Crosshair_Color",
    tooltip = "Crosshair color",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.Crosshair:AddToggle({
    text = "Outline",
    flag = "Crosshair_Outline",
    tooltip = "Add black outline",
})

VisualsSections.Crosshair:AddToggle({
    text = "Rotation",
    flag = "Crosshair_Rotation",
    tooltip = "Rotate crosshair",
})

VisualsSections.Crosshair:AddSlider({
    text = "Rotation Speed",
    flag = "Crosshair_Rotation_Speed",
    suffix = "°/s",
    value = 45,
    min = 1,
    max = 360,
    increment = 5,
    tooltip = "Rotation speed in degrees per second",
})

--// World Section
VisualsSections.World:AddToggle({
    text = "Dropped Items",
    flag = "World_Items",
    tooltip = "Show dropped items (game-specific)",
})

VisualsSections.World:AddToggle({
    text = "Vehicles",
    flag = "World_Vehicles",
    tooltip = "Show vehicles (game-specific)",
})

VisualsSections.World:AddToggle({
    text = "NPCs",
    flag = "World_NPCs",
    tooltip = "Show NPCs/enemies (game-specific)",
})

VisualsSections.World:AddSeparator({text = "Environment"})

VisualsSections.World:AddToggle({
    text = "Fullbright",
    flag = "Fullbright",
    tooltip = "Remove darkness/shadows",
    callback = function(state)
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = OriginalAmbient
        end
    end
})

VisualsSections.World:AddToggle({
    text = "No Fog",
    flag = "No_Fog",
    tooltip = "Remove fog",
    callback = function(state)
        Lighting.FogEnd = state and 100000 or 1000
    end
})

VisualsSections.World:AddSlider({
    text = "Field of View",
    flag = "Camera_FOV",
    suffix = "°",
    value = 70,
    min = 30,
    max = 120,
    increment = 1,
    tooltip = "Camera FOV",
    callback = function(value)
        Camera.FieldOfView = value
    end
})

VisualsSections.World:AddToggle({
    text = "Rainbow Ambient",
    flag = "Rainbow_Ambient",
    tooltip = "Cycle ambient lighting colors",
})


--[[ ═══════════════════════════════════════════════════════════════
                          PLAYER TAB
═══════════════════════════════════════════════════════════════ ]]

--// Create Sections
local PlayerSections = {
    Movement = tabs.Player:AddSection("Movement", 1),
    Character = tabs.Player:AddSection("Character", 2),
}

--// Movement Section
PlayerSections.Movement:AddToggle({
    text = "Speed Modifier",
    flag = "Speed_Enabled",
    tooltip = "Modify walk speed",
})

PlayerSections.Movement:AddSlider({
    text = "Speed Multiplier",
    flag = "WalkSpeed",
    suffix = "x",
    value = 1,
    min = 1,
    max = 5,
    increment = 0.1,
    tooltip = "WalkSpeed multiplier",
})

PlayerSections.Movement:AddToggle({
    text = "Jump Power Modifier",
    flag = "Jump_Enabled",
    tooltip = "Modify jump power",
})

PlayerSections.Movement:AddSlider({
    text = "Jump Multiplier",
    flag = "JumpPower",
    suffix = "x",
    value = 1,
    min = 1,
    max = 5,
    increment = 0.1,
    tooltip = "JumpPower multiplier",
})

PlayerSections.Movement:AddToggle({
    text = "Infinite Jump",
    flag = "Infinite_Jump",
    tooltip = "Jump infinite times",
    risky = true,
})

PlayerSections.Movement:AddToggle({
    text = "Fly",
    flag = "Fly_Enabled",
    tooltip = "Fly mode",
    risky = true,
})

PlayerSections.Movement:AddBind({
    text = "Fly Keybind",
    flag = "Fly_Key",
    nomouse = true,
    mode = "toggle",
    bind = Enum.KeyCode.F,
    tooltip = "Toggle fly on/off",
})

PlayerSections.Movement:AddSlider({
    text = "Fly Speed",
    flag = "Fly_Speed",
    suffix = "",
    value = 50,
    min = 10,
    max = 500,
    increment = 10,
    tooltip = "Flight speed",
})

PlayerSections.Movement:AddToggle({
    text = "Noclip",
    flag = "Noclip_Enabled",
    tooltip = "Walk through walls",
    risky = true,
})

PlayerSections.Movement:AddBind({
    text = "Noclip Keybind",
    flag = "Noclip_Key",
    nomouse = true,
    mode = "toggle",
    bind = Enum.KeyCode.N,
    tooltip = "Toggle noclip on/off",
})

--// Character Section
PlayerSections.Character:AddToggle({
    text = "God Mode",
    flag = "God_Mode",
    tooltip = "Attempt to enable god mode (may not work)",
    risky = true,
})

PlayerSections.Character:AddToggle({
    text = "No Fall Damage",
    flag = "No_Fall_Damage",
    tooltip = "Remove fall damage",
})

PlayerSections.Character:AddToggle({
    text = "Anti-Void",
    flag = "Anti_Void",
    tooltip = "Teleport back if you fall into void",
})

PlayerSections.Character:AddSlider({
    text = "Anti-Void Height",
    flag = "Anti_Void_Height",
    suffix = " studs",
    value = -100,
    min = -500,
    max = 0,
    increment = 10,
    tooltip = "Height threshold for anti-void",
})


--[[ ═══════════════════════════════════════════════════════════════
                        MISCELLANEOUS TAB
═══════════════════════════════════════════════════════════════ ]]

--// Create Sections
local MiscSections = {
    Utility = tabs.Misc:AddSection("Utility", 1),
    Teleport = tabs.Misc:AddSection("Teleport", 2),
    Fun = tabs.Misc:AddSection("Fun", 1),
    Server = tabs.Misc:AddSection("Server", 2),
}

--// Utility Section
MiscSections.Utility:AddToggle({
    text = "Anti-AFK",
    flag = "Anti_AFK",
    tooltip = "Prevent AFK kick",
})

MiscSections.Utility:AddToggle({
    text = "FPS Unlocker",
    flag = "FPS_Unlocker",
    tooltip = "Unlock frame rate",
})

MiscSections.Utility:AddSlider({
    text = "FPS Cap",
    flag = "FPS_Cap",
    suffix = " fps",
    value = 240,
    min = 60,
    max = 500,
    increment = 10,
    tooltip = "Maximum FPS limit",
})

MiscSections.Utility:AddToggle({
    text = "Streamer Mode",
    flag = "Streamer_Mode",
    tooltip = "Hide sensitive information",
})

MiscSections.Utility:AddToggle({
    text = "Auto-Rejoin",
    flag = "Auto_Rejoin",
    tooltip = "Automatically rejoin when kicked",
})

--// Teleport Section
MiscSections.Teleport:AddList({
    text = "Select Player",
    flag = "Teleport_Player",
    tooltip = "Choose player to teleport to",
    values = {},
})

MiscSections.Teleport:AddButton({
    text = "Teleport to Player",
    tooltip = "Teleport to selected player",
    risky = true,
    callback = function()
        local targetName = library.flags.Teleport_Player
        if targetName and targetName ~= "" then
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    library:SendNotification("Teleported to " .. targetName, 3, Color3.fromRGB(0, 255, 0))
                end
            else
                library:SendNotification("Player not found or invalid!", 3, Color3.fromRGB(255, 0, 0))
            end
        end
    end
})

MiscSections.Teleport:AddSeparator({text = "Position Manager"})

MiscSections.Teleport:AddButton({
    text = "Save Position",
    tooltip = "Save current position",
    callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            library:SendNotification("Position saved!", 3, Color3.fromRGB(0, 255, 0))
        end
    end
})

MiscSections.Teleport:AddButton({
    text = "Load Position",
    tooltip = "Teleport to saved position",
    risky = true,
    callback = function()
        if SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
            library:SendNotification("Teleported to saved position!", 3, Color3.fromRGB(0, 255, 0))
        else
            library:SendNotification("No position saved!", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

MiscSections.Teleport:AddBind({
    text = "Quick Teleport",
    flag = "Quick_Teleport_Key",
    nomouse = true,
    mode = "hold",
    bind = Enum.KeyCode.T,
    tooltip = "Hold to teleport to saved position",
})

--// Fun Section
MiscSections.Fun:AddToggle({
    text = "Spin Bot",
    flag = "Spin_Bot",
    tooltip = "Spin your character",
    risky = true,
})

MiscSections.Fun:AddSlider({
    text = "Spin Speed",
    flag = "Spin_Speed",
    suffix = "°/s",
    value = 360,
    min = 10,
    max = 1000,
    increment = 10,
    tooltip = "Rotation speed",
})

MiscSections.Fun:AddList({
    text = "Animation",
    flag = "Animation_Changer",
    tooltip = "Change animation style (game-specific)",
    values = {"None", "Zombie", "Knight", "Levitate", "Astronaut", "Ninja", "Werewolf", "Elder"},
    value = "None",
})

--// Server Section
MiscSections.Server:AddButton({
    text = "Rejoin Server",
    tooltip = "Rejoin current server",
    confirm = true,
    callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

MiscSections.Server:AddButton({
    text = "Server Hop",
    tooltip = "Join a different server",
    callback = function()
        local servers = {}
        local req = request or http_request or syn.request
        local serverList = game:GetService("HttpService"):JSONDecode(req({
            Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId)
        }).Body)
        
        for _, server in pairs(serverList.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id)
        else
            library:SendNotification("No available servers!", 3, Color3.fromRGB(255, 0, 0))
        end
    end
})

MiscSections.Server:AddButton({
    text = "Copy Join Script",
    tooltip = "Copy script to clipboard",
    callback = function()
        setclipboard(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', game.PlaceId, game.JobId))
        library:SendNotification("Copied to clipboard!", 3, Color3.fromRGB(0, 255, 0))
    end
})


--[[ ═══════════════════════════════════════════════════════════════
                        UTILITY FUNCTIONS
═══════════════════════════════════════════════════════════════ ]]

--// RGB Color Helper
local function GetRGBColor(hue)
    return Color3.fromHSV(hue or RGBHue, 1, 1)
end

--// Get Random Part Helper
local function GetRandomPart(character)
    local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    return character:FindFirstChild(parts[math.random(1, #parts)])
end

--// Get Closest Part to Camera Helper
local function GetClosestPart(character)
    local closestPart = nil
    local closestDistance = math.huge
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local distance = (Camera.CFrame.Position - part.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPart = part
            end
        end
    end
    
    return closestPart
end

--// Get Aimbot Target Function
local function GetAimbotTarget()
    local camera = Camera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()
    local thirdPerson = library.flags["Aimbot_Third_Person"]
    local aimOrigin = thirdPerson and mousePos or screenCenter
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    local targetPartName = library.flags["Aimbot_Part"] or "Head"
    local useFOV = library.flags["Show_FOV"]
    local fovRadius = library.flags["FOV_Radius"] or 100
    local wallCheck = library.flags["Aimbot_Wall_Check"]
    local teamCheck = library.flags["Aimbot_Team_Check"]
    local maxDistance = library.flags["Aimbot_Max_Distance"] or 1000
    local priority = library.flags["Aimbot_Priority"] or "Nearest to Cursor"
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if character and humanoid and humanoid.Health > 0 then
                -- Team check
                if teamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Get target part
                local targetPart
                if targetPartName == "Random" then
                    targetPart = GetRandomPart(character)
                elseif targetPartName == "Closest" then
                    targetPart = GetClosestPart(character)
                else
                    targetPart = character:FindFirstChild(targetPartName)
                end
                
                if not targetPart then continue end
                
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - aimOrigin).Magnitude
                    local worldDistance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                        (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude) or math.huge
                    
                    -- FOV check
                    if useFOV and screenDistance > fovRadius then
                        continue
                    end
                    
                    -- Distance check
                    if worldDistance > maxDistance then
                        continue
                    end
                    
                    -- Wall check
                    if wallCheck then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local ray = Ray.new(myRoot.Position, (targetPart.Position - myRoot.Position).Unit * worldDistance)
                            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, camera})
                            if hit and not hit:IsDescendantOf(character) then
                                continue
                            end
                        end
                    end
                    
                    -- Priority selection
                    local compareDistance
                    if priority == "Nearest to Cursor" then
                        compareDistance = screenDistance
                    elseif priority == "Nearest to Player" then
                        compareDistance = worldDistance
                    elseif priority == "Lowest Health" then
                        compareDistance = humanoid.Health
                    end
                    
                    if compareDistance < closestDistance then
                        closestDistance = compareDistance
                        closestPlayer = {player = player, part = targetPart}
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

--// Update Player List for Teleport
local function UpdateTeleportList()
    if library.options.Teleport_Player then
        library.options.Teleport_Player:ClearValues()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                library.options.Teleport_Player:AddValue(player.Name)
            end
        end
    end
end


--// Create ESP for Players
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Corners = {},
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tool = Drawing.new("Text"),
        HealthBG = Drawing.new("Line"),
        Health = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
        Highlight = nil,
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
    local skeletonConnections = {
        "Head_Neck", "Neck_LeftArm", "Neck_RightArm", 
        "LeftArm_LeftHand", "RightArm_RightHand", 
        "Neck_Torso", "Torso_LeftLeg", "Torso_RightLeg", 
        "LeftLeg_LeftFoot", "RightLeg_RightFoot"
    }
    for _, name in pairs(skeletonConnections) do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        esp.Skeleton[name] = line
    end
    
    -- Text Elements
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Visible = false
    
    esp.Tool.Size = 13
    esp.Tool.Center = true
    esp.Tool.Outline = true
    esp.Tool.Color = Color3.fromRGB(150, 150, 255)
    esp.Tool.Visible = false
    
    -- Health Bar
    esp.HealthBG.Thickness = 4
    esp.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBG.Transparency = 1
    esp.HealthBG.Visible = false
    
    esp.Health.Thickness = 2
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Transparency = 1
    esp.Health.Visible = false
    
    -- Tracer
    esp.Tracer.Transparency = 1
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 2
end

--// Remove ESP
local function RemoveESP(player)
    if ESPObjects[player] then
        for key, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, subObj in pairs(obj) do
                    if subObj.Remove then subObj:Remove() end
                end
            elseif obj and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

--// Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    task.wait(0.5)
    UpdateTeleportList()
end)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    UpdateTeleportList()
end)

--// Update Teleport List Initially
UpdateTeleportList()


--[[ ═══════════════════════════════════════════════════════════════
                        INPUT HANDLERS
═══════════════════════════════════════════════════════════════ ]]

--// Track Aimbot Keys
Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Aimbot Key
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = true
    end
    
    -- Silent Aim Key
    if input.KeyCode == Enum.KeyCode.C then
        IsSilentAimKeyHeld = true
    end
    
    -- Infinite Jump
    if library.flags.Infinite_Jump and input.KeyCode == Enum.KeyCode.Space then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- Quick Teleport
    if input.KeyCode == Enum.KeyCode.T and library.flags.Quick_Teleport_Key then
        if SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedPosition
        end
    end
end)

Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = false
    end
    if input.KeyCode == Enum.KeyCode.C then
        IsSilentAimKeyHeld = false
    end
end)

--[[ ═══════════════════════════════════════════════════════════════
                        MAIN UPDATE LOOP
═══════════════════════════════════════════════════════════════ ]]

local CrosshairRotation = 0

Connections.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
    local camera = Camera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()
    
    --[[ RGB HUE UPDATE ]]--
    local rgbSpeed = library.flags["RGB_Speed"] or 1
    RGBHue = (RGBHue + deltaTime * rgbSpeed * 0.5) % 1
    local rgbColor = GetRGBColor(RGBHue)
    
    --[[ FOV CIRCLE UPDATE ]]--
    local thirdPerson = library.flags["Aimbot_Third_Person"]
    FOVCircle.Position = thirdPerson and mousePos or screenCenter
    FOVCircle.Color = library.flags["FOV_RGB"] and rgbColor or library.flags["FOV_Color"]
    
    --[[ RAINBOW AMBIENT ]]--
    if library.flags["Rainbow_Ambient"] then
        Lighting.Ambient = rgbColor
    end
    
    --[[ CROSSHAIR UPDATE ]]--
    local crosshairEnabled = library.flags.Crosshair_Enabled
    local style = library.flags.Crosshair_Style or "Cross"
    local size = library.flags.Crosshair_Size or 10
    local thickness = library.flags.Crosshair_Thickness or 2
    local gap = library.flags.Crosshair_Gap or 5
    local color = library.flags.Crosshair_Color or Color3.fromRGB(255, 255, 255)
    local outline = library.flags.Crosshair_Outline
    local rotate = library.flags.Crosshair_Rotation
    local rotSpeed = library.flags.Crosshair_Rotation_Speed or 45
    
    if rotate then
        CrosshairRotation = (CrosshairRotation + rotSpeed * deltaTime) % 360
    end
    
    -- Hide all crosshair elements first
    for _, obj in pairs(CrosshairObjects) do
        if obj.Visible ~= nil then
            obj.Visible = false
        end
    end
    
    if crosshairEnabled then
        if style == "Cross" or style == "Plus" then
            local angleRad = math.rad(CrosshairRotation)
            local cos, sin = math.cos(angleRad), math.sin(angleRad)
            
            -- Horizontal line
            local hFrom = Vector2.new(
                screenCenter.X - (size + gap) * cos,
                screenCenter.Y - (size + gap) * sin
            )
            local hTo = Vector2.new(
                screenCenter.X + (size + gap) * cos,
                screenCenter.Y + (size + gap) * sin
            )
            
            -- Vertical line  
            local vFrom = Vector2.new(
                screenCenter.X - (size + gap) * sin,
                screenCenter.Y + (size + gap) * cos
            )
            local vTo = Vector2.new(
                screenCenter.X + (size + gap) * sin,
                screenCenter.Y - (size + gap) * cos
            )
            
            if outline then
                CrosshairObjects.OutlineH.From = hFrom
                CrosshairObjects.OutlineH.To = hTo
                CrosshairObjects.OutlineH.Visible = true
                CrosshairObjects.OutlineV.From = vFrom
                CrosshairObjects.OutlineV.To = vTo
                CrosshairObjects.OutlineV.Visible = true
            end
            
            CrosshairObjects.Horizontal.From = hFrom
            CrosshairObjects.Horizontal.To = hTo
            CrosshairObjects.Horizontal.Color = color
            CrosshairObjects.Horizontal.Thickness = thickness
            CrosshairObjects.Horizontal.Visible = true
            
            CrosshairObjects.Vertical.From = vFrom
            CrosshairObjects.Vertical.To = vTo
            CrosshairObjects.Vertical.Color = color
            CrosshairObjects.Vertical.Thickness = thickness
            CrosshairObjects.Vertical.Visible = true
            
        elseif style == "Circle" then
            CrosshairObjects.Circle.Position = screenCenter
            CrosshairObjects.Circle.Radius = size
            CrosshairObjects.Circle.Color = color
            CrosshairObjects.Circle.Thickness = thickness
            CrosshairObjects.Circle.Visible = true
            
        elseif style == "Dot" then
            CrosshairObjects.Dot.Position = screenCenter
            CrosshairObjects.Dot.Color = color
            CrosshairObjects.Dot.Visible = true
        end
    end
    
    --[[ AIMBOT LOGIC ]]--
    AimbotTarget = nil
    TargetInfo.Line.Visible = false
    TargetInfo.Dot.Visible = false
    
    if library.flags["Aimbot_Enabled"] and IsAimKeyHeld then
        local target = GetAimbotTarget()
        if target then
            AimbotTarget = target.player
            local targetPart = target.part
            
            if targetPart then
                local smoothness = library.flags["Aimbot_Smoothness"] or 0.5
                local lerpAlpha = 1.1 - smoothness
                
                -- Prediction
                local targetPosition = targetPart.Position
                if library.flags.Aimbot_Prediction and targetPart.Parent and targetPart.Parent:FindFirstChild("Humanoid") then
                    local humanoidRootPart = targetPart.Parent:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local velocity = humanoidRootPart.AssemblyLinearVelocity
                        local predictionMultiplier = library.flags.Aimbot_Prediction_Velocity or 0.165
                        targetPosition = targetPosition + (velocity * predictionMultiplier)
                    end
                end
                
                if thirdPerson then
                    -- Third Person: Move mouse
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPosition)
                    if onScreen then
                        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local delta = (targetScreenPos - mousePos) * lerpAlpha
                        if delta.Magnitude > 1 and mousemoverel then
                            mousemoverel(delta.X, delta.Y)
                        end
                    end
                else
                    -- First Person: Rotate camera
                    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpAlpha)
                end
                
                -- Target Line & Dot
                local screenPos = camera:WorldToViewportPoint(targetPosition)
                local lineOrigin = thirdPerson and mousePos or screenCenter
                TargetInfo.Line.From = lineOrigin
                TargetInfo.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetInfo.Line.Color = rgbColor
                TargetInfo.Line.Visible = true
                
                TargetInfo.Dot.Position = Vector2.new(screenPos.X, screenPos.Y)
                TargetInfo.Dot.Color = rgbColor
                TargetInfo.Dot.Visible = true
                
                -- Update Target Indicator
                library.targetIndicator:SetEnabled(true)
                library.targetName:SetValue(AimbotTarget.Name)
                library.targetDisplay:SetValue(AimbotTarget.DisplayName)
                if AimbotTarget.Character and AimbotTarget.Character:FindFirstChild("Humanoid") then
                    library.targetHealth:SetValue(math.floor(AimbotTarget.Character.Humanoid.Health))
                end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                   AimbotTarget.Character and AimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - AimbotTarget.Character.HumanoidRootPart.Position).Magnitude
                    library.targetDistance:SetValue(math.floor(dist).."m")
                end
                local tool = AimbotTarget.Character and AimbotTarget.Character:FindFirstChildOfClass("Tool")
                library.targetTool:SetValue(tool and tool.Name or "None")
            end
        else
            library.targetIndicator:SetEnabled(false)
        end
    else
        library.targetIndicator:SetEnabled(false)
    end
    
    --[[ ESP UPDATE ]]--
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
            
            if onScreen and espEnabled and not isTeammate and distance <= maxDist then
                local head = character:FindFirstChild("Head")
                local headTop = head and (head.Position + Vector3.new(0, head.Size.Y / 2 + 0.5, 0)) or (rootPart.Position + Vector3.new(0, 2.5, 0))
                local feetBottom = rootPart.Position - Vector3.new(0, 3, 0)
                
                local headScreenPos = camera:WorldToViewportPoint(headTop)
                local feetScreenPos = camera:WorldToViewportPoint(feetBottom)
                
                local boxHeight = math.abs(feetScreenPos.Y - headScreenPos.Y)
                boxHeight = math.clamp(boxHeight, 30, 1000)
                local boxWidth = boxHeight * 0.55
                local boxX = rootPos.X - boxWidth / 2
                local boxY = headScreenPos.Y
                
                local boxType = library.flags["ESP_Box_Type"] or "2D"
                local showBox = library.flags["ESP_Box"] and boxType ~= "None"
                local boxColor = library.flags["ESP_Box_RGB"] and rgbColor or library.flags["ESP_Box_Color"]
                
                -- Hide all box elements first
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                for i = 1, 8 do esp.Corners[i].Visible = false end
                
                if showBox then
                    if boxType == "2D" then
                        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.BoxOutline.Visible = true
                        
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Color = boxColor
                        esp.Box.Visible = true
                    elseif boxType == "Corner" then
                        local cornerLength = math.min(boxWidth, boxHeight) * 0.25
                        
                        -- Draw 4 corners (2 lines each)
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
                            esp.Corners[i].Visible = true
                        end
                    end
                end
                
                -- Name ESP
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, boxY - 15)
                esp.Name.Color = library.flags["ESP_Name_Color"] or Color3.fromRGB(255, 255, 255)
                esp.Name.Visible = library.flags["ESP_Name"] or false
                
                -- Distance ESP
                esp.Distance.Text = "["..math.floor(distance).."m]"
                esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 2)
                esp.Distance.Visible = library.flags["ESP_Distance"] or false
                
                -- Tool ESP
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    esp.Tool.Text = tool.Name
                    esp.Tool.Position = Vector2.new(rootPos.X, boxY + boxHeight + 17)
                    esp.Tool.Visible = library.flags["ESP_Tool"] or false
                else
                    esp.Tool.Visible = false
                end
                
                -- Health Bar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthPos = library.flags["ESP_Health_Position"] or "Left"
                local healthX, healthY1, healthY2
                
                if healthPos == "Left" then
                    healthX = boxX - 6
                    healthY1, healthY2 = boxY, boxY + boxHeight
                elseif healthPos == "Right" then
                    healthX = boxX + boxWidth + 6
                    healthY1, healthY2 = boxY, boxY + boxHeight
                elseif healthPos == "Top" then
                    healthX = boxY - 6
                    healthY1, healthY2 = boxX, boxX + boxWidth
                else -- Bottom
                    healthX = boxY + boxHeight + 6
                    healthY1, healthY2 = boxX, boxX + boxWidth
                end
                
                esp.HealthBG.From = Vector2.new(healthX, healthY1)
                esp.HealthBG.To = Vector2.new(healthX, healthY2)
                esp.HealthBG.Visible = library.flags["ESP_Health"] or false
                
                local healthHeight = (healthY2 - healthY1) * healthPercent
                esp.Health.From = Vector2.new(healthX, healthY2)
                esp.Health.To = Vector2.new(healthX, healthY2 - healthHeight)
                esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                esp.Health.Visible = library.flags["ESP_Health"] or false
                
                -- Tracers
                local tracerOrigin = library.flags["ESP_Tracer_Origin"] or "Bottom"
                local startPos
                if tracerOrigin == "Top" then
                    startPos = Vector2.new(camera.ViewportSize.X / 2, 0)
                elseif tracerOrigin == "Center" then
                    startPos = screenCenter
                elseif tracerOrigin == "Mouse" then
                    startPos = mousePos
                else -- Bottom
                    startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                end
                
                esp.Tracer.From = startPos
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Color = library.flags["ESP_Tracer_RGB"] and rgbColor or library.flags["ESP_Tracer_Color"]
                esp.Tracer.Visible = library.flags["ESP_Tracers"] or false
                
                -- Skeleton ESP
                for _, line in pairs(esp.Skeleton) do
                    line.Visible = false
                end
                
                if library.flags["ESP_Skeleton"] then
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
                            esp.Skeleton[lineName].Color = library.flags["ESP_Skeleton_Color"] or Color3.fromRGB(255, 255, 255)
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
                
            else
                -- Hide all ESP elements
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                for i = 1, 8 do esp.Corners[i].Visible = false end
                for _, line in pairs(esp.Skeleton) do line.Visible = false end
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Tool.Visible = false
                esp.Health.Visible = false
                esp.HealthBG.Visible = false
                esp.Tracer.Visible = false
            end
        else
            -- Hide all ESP elements if character invalid
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
            for i = 1, 8 do esp.Corners[i].Visible = false end
            for _, line in pairs(esp.Skeleton) do line.Visible = false end
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tool.Visible = false
            esp.Health.Visible = false
            esp.HealthBG.Visible = false
            esp.Tracer.Visible = false
        end
    end
end)


--[[ ═══════════════════════════════════════════════════════════════
                    CHARACTER MODIFICATIONS
═══════════════════════════════════════════════════════════════ ]]

--// Apply Character Modifications
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- WalkSpeed Modifier
    if library.flags.Speed_Enabled then
        local multiplier = library.flags.WalkSpeed or 1
        humanoid.WalkSpeed = OriginalWalkSpeed * multiplier
    end
    
    -- JumpPower Modifier
    if library.flags.Jump_Enabled then
        local multiplier = library.flags.JumpPower or 1
        humanoid.JumpPower = OriginalJumpPower * multiplier
    end
    
    -- Noclip
    if library.flags.Noclip_Enabled then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Fly
    if library.flags.Fly_Enabled and not FlyEnabled then
        FlyEnabled = true
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.P = 10000
        bodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
        
        humanoid.PlatformStand = true
        
        RunService.RenderStepped:Connect(function()
            if not library.flags.Fly_Enabled then
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                humanoid.PlatformStand = false
                FlyEnabled = false
                return
            end
            
            local speed = library.flags.Fly_Speed or 50
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = moveDirection.Unit * speed
            bodyGyro.CFrame = Camera.CFrame
        end)
    end
    
    -- Anti-Void
    if library.flags.Anti_Void then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local voidHeight = library.flags.Anti_Void_Height or -100
            if rootPart.Position.Y < voidHeight then
                if SavedPosition then
                    rootPart.CFrame = SavedPosition
                else
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 100, 0)
                end
                library:SendNotification("Anti-Void activated!", 2, Color3.fromRGB(255, 255, 0))
            end
        end
    end
    
    -- Spin Bot
    if library.flags.Spin_Bot then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local spinSpeed = library.flags.Spin_Speed or 360
            SpinBotAngle = (SpinBotAngle + spinSpeed / 60) % 360
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed / 60), 0)
        end
    end
end)

--// Anti-AFK
Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
    if library.flags.Anti_AFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--[[ ═══════════════════════════════════════════════════════════════
                        CLEANUP FUNCTION
═══════════════════════════════════════════════════════════════ ]]

local function Cleanup()
    -- Remove FOV Circle
    if FOVCircle then
        pcall(function() FOVCircle:Remove() end)
    end
    
    -- Remove Target Info
    if TargetInfo then
        pcall(function() TargetInfo.Line:Remove() end)
        pcall(function() TargetInfo.Dot:Remove() end)
    end
    
    -- Remove Crosshair
    for _, obj in pairs(CrosshairObjects) do
        if obj and obj.Remove then
            pcall(function() obj:Remove() end)
        end
    end
    
    -- Remove all ESP
    for player, esp in pairs(ESPObjects) do
        RemoveESP(player)
    end
    table.clear(ESPObjects)
    
    -- Disconnect all connections
    for _, connection in pairs(Connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
    
    -- Reset lighting
    Lighting.Ambient = OriginalAmbient
    Lighting.Brightness = 1
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 1000
    
    -- Reset camera
    Camera.FieldOfView = 70
    
    -- Reset character
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = OriginalWalkSpeed
            humanoid.JumpPower = OriginalJumpPower
        end
    end
    
    library:SendNotification("Luminosity Hub Unloaded!", 3, Color3.fromRGB(255, 100, 100))
end

-- Connect cleanup to library unload
library.unloaded:Connect(Cleanup)

--[[ ═══════════════════════════════════════════════════════════════
                        STARTUP & FINALIZATION
═══════════════════════════════════════════════════════════════ ]]

--// Startup Notification
library:SendNotification("Luminosity Hub v2.0 Loaded!", 5, Color3.fromRGB(255, 60, 60))
library:SendNotification("Press RightShift to toggle menu", 3, Color3.fromRGB(100, 255, 100))

--// Fix initial layout
task.spawn(function()
    task.wait(0.1)
    tabs.Visuals:Select()
    task.wait(0.01)
    tabs.Aimbot:Select()
end)

--// Enable watermark and keybind indicator by default
if library.watermark then
    library.watermark:Update()
end

--// Print success message
print("═══════════════════════════════════════════════════════════════")
print("           LUMINOSITY HUB V2.0 - ENHANCED EDITION")
print("═══════════════════════════════════════════════════════════════")
print("✓ Comprehensive Aimbot System")
print("✓ Advanced ESP & Visuals")
print("✓ Player Movement Modifications")
print("✓ Miscellaneous Utilities")
print("✓ Full Configuration System")
print("═══════════════════════════════════════════════════════════════")
print("Script loaded successfully! Enjoy responsibly.")
print("═══════════════════════════════════════════════════════════════")
