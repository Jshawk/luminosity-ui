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

--// ServicesS
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
local SilentAimData = nil
local IsSilentAimKeyHeld = false
local SilentAimActiveIndicator = false -- UI/Debug indicator for active silent aim
local SilentAimLastDebug = "" -- Last debug message for silent aim
local SilentAimPrevActive = false
local SilentAimLastNotify = nil

-- Throttle spammy lock prints
local SilentAimLastLockKey = nil
local SilentAimLastLockTime = 0
local SilentAimLockThrottle = 0.75 -- seconds (only print identical lock attempts after this interval)
local Connections = {}
local RGBHue = 0
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local OriginalClockTime = Lighting.ClockTime
local OriginalFogEnd = Lighting.FogEnd
local OriginalGlobalShadows = Lighting.GlobalShadows
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
    size = UDim2.new(0, 600, 0, 675),
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
    Aimbot = tabs.Aimbot:AddSection("Camera Aimbot", 1),
    Silent = tabs.Aimbot:AddSection("Silent Aim", 2),
    FOV = tabs.Aimbot:AddSection("FOV Circle", 2),
}

--// Camera Aimbot Section
AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Enable Aimbot",
    flag = "Aimbot_Enabled",
    tooltip = "Master toggle for camera aimbot",
    risky = true,
})

AimbotSections.Aimbot:AddBind({
    text = "Aim Key",
    flag = "Aimbot_Key",
    nomouse = false,
    mode = "hold",
    bind = Enum.UserInputType.MouseButton2,
    tooltip = "Hold to lock onto target",
})

AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Third Person Mode",
    flag = "Aimbot_Third_Person",
    tooltip = "FOV follows mouse cursor (for third person)",
})

AimbotSections.Aimbot:AddSeparator({text = "Targeting Settings"})

AimbotSections.Aimbot:AddList({
    text = "Target Part",
    flag = "Aimbot_Part",
    tooltip = "Body part to aim at",
    values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random", "Closest"},
    value = "Head",
})

AimbotSections.Aimbot:AddList({
    text = "Target Mode",
    flag = "Aimbot_Priority",
    tooltip = "How to select targets",
    values = {"Nearest to Cursor", "Nearest to Player", "Lowest Health"},
    value = "Nearest to Cursor",
})

AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Stick to Target",
    flag = "Aimbot_Stick",
    tooltip = "Stay locked on same target while aimbot active",
})

AimbotSections.Aimbot:AddSlider({
    text = "Max Distance",
    flag = "Aimbot_Max_Distance",
    suffix = " studs",
    value = 1000,
    min = 100,
    max = 5000,
    increment = 100,
    tooltip = "Maximum targeting distance",
})

AimbotSections.Aimbot:AddSeparator({text = "Filters"})

AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Team Check",
    flag = "Aimbot_Team_Check",
    tooltip = "Don't aim at teammates",
})

AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Visible Check",
    flag = "Aimbot_Wall_Check",
    tooltip = "Only aim at visible targets (wall check)",
})

AimbotSections.Aimbot:AddSeparator({text = "Smoothing & Prediction"})

AimbotSections.Aimbot:AddSlider({
    text = "Smoothing",
    flag = "Aimbot_Smoothness",
    suffix = "",
    value = 0.5,
    min = 0.01,
    max = 1,
    increment = 0.01,
    tooltip = "Lower = smoother aim, Higher = snappier aim",
})

AimbotSections.Aimbot:AddToggle({
    enabled = true,
    text = "Prediction",
    flag = "Aimbot_Prediction",
    tooltip = "Predict target movement (experimental)",
})

AimbotSections.Aimbot:AddSlider({
    text = "Prediction Velocity",
    flag = "Aimbot_Prediction_Velocity",
    suffix = "x",
    value = 0.165,
    min = 0.01,
    max = 0.5,
    increment = 0.005,
    tooltip = "Velocity multiplier for prediction",
})

--// FOV Circle Section
AimbotSections.FOV:AddToggle({
    enabled = true,
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
    min = 10,
    max = 500,
    increment = 10,
    tooltip = "Size of FOV circle",
    callback = function(value)
        FOVCircle.Radius = value
    end
})

AimbotSections.FOV:AddSeparator({text = "Appearance"})

AimbotSections.FOV:AddToggle({
    enabled = true,
    text = "Rainbow FOV",
    flag = "FOV_RGB",
    tooltip = "Cycle rainbow colors on FOV circle",
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
    enabled = true,
    text = "Filled Circle",
    flag = "FOV_Filled",
    tooltip = "Fill the FOV circle",
    callback = function(state)
        FOVCircle.Filled = state
    end
})

AimbotSections.FOV:AddSlider({
    text = "Fill Opacity",
    flag = "FOV_Fill_Opacity",
    suffix = "%",
    value = 30,
    min = 5,
    max = 100,
    increment = 5,
    tooltip = "Opacity of filled circle",
    callback = function(value)
        FOVCircle.Transparency = value / 100
    end
})

-- Debug/Status indicator for Silent Aim (AddLabel unsupported; use keyIndicator instead)
library.silentDebugIndicator = library.keyIndicator:AddValue({ key = 'Silent Aim :', value = 'Inactive', enabled = true })
-- Keep a flag present so existing logic that checks the flag still runs
library.flags["Silent_Debug_Label"] = library.flags["Silent_Debug_Label"] or true

-- Expose a debug toggle to force silent aim active for testing
AimbotSections.Silent:AddToggle({
    enabled = true,
    text = "Force Silent Aim (Testing)",
    flag = "Silent_Force_Active",
    tooltip = "Force silent aim to stay active regardless of keys (for testing)",
})

-- Option: Use Remote Fallback (attempt to intercept remote events/raycast calls)
AimbotSections.Silent:AddToggle({
    enabled = true,
    text = "Remote Fallback",
    flag = "Silent_Remote_Fallback",
    tooltip = "Try to override common remote/raycast targets if Mouse.Hit is not used",
})

--// Silent Aim Section
AimbotSections.Silent:AddToggle({
    enabled = true,
    text = "Enable Silent Aim",
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

AimbotSections.Silent:AddToggle({
    enabled = true,
    text = "Use Aimbot Target",
    flag = "Silent_Use_Aimbot_Target",
    tooltip = "When enabled, Silent Aim uses the Aimbot's selected target and FOV settings",
})

AimbotSections.Silent:AddToggle({
    enabled = true,
    text = "Aggressive Remote Injection",
    flag = "Silent_Aggressive_Remote",
    tooltip = "Try more aggressive heuristics to inject target into remote calls (may affect other remotes)",
})

AimbotSections.Silent:AddSeparator({text = "Accuracy Settings"})

AimbotSections.Silent:AddSlider({
    text = "Activation Chance",
    flag = "Silent_Aim_Chance",
    suffix = "%",
    value = 100,
    min = 1,
    max = 100,
    increment = 5,
    tooltip = "Chance for silent aim to activate",
})

AimbotSections.Silent:AddSlider({
    text = "Hit Chance",
    flag = "Silent_Hit_Chance",
    suffix = "%",
    value = 100,
    min = 1,
    max = 100,
    increment = 5,
    tooltip = "Chance to hit target with silent aim",
})

AimbotSections.Silent:AddButton({
    text = "Log Silent Aim Data",
    tooltip = "Print current SilentAimData to console",
    callback = function()
        if SilentAimData and SilentAimData.player then
            print(string.format("[SilentAim] Target=%s Part=%s Pos=%.2f,%.2f,%.2f", SilentAimData.player.Name, SilentAimData.part and SilentAimData.part.Name or "nil", SilentAimData.position.X or 0, SilentAimData.position.Y or 0, SilentAimData.position.Z or 0))
            library:SendNotification("SilentAim locked: " .. SilentAimData.player.Name, 3, Color3.fromRGB(0,255,0))
        else
            print("[SilentAim] No target currently")
            library:SendNotification("SilentAim: no target", 3, Color3.fromRGB(255,100,100))
        end
    end
})

-- Debug: Force replace next shots via UI
AimbotSections.Silent:AddButton({
    text = "Force Replace Next Shots (Debug)",
    tooltip = "Temporarily force replacements on next remote/namecall args (debug)",
    callback = function()
        ForceReplaceNextShots(12)
    end
})

-- Debug: Dump namecalls to discover what the game actually calls
AimbotSections.Silent:AddButton({
    text = "Dump Namecalls (Debug)",
    tooltip = "Log the next 200 namecalls (method + arg types) to help identify shot APIs",
    callback = function()
        FullNamecallDump = 200
        pcall(function() if library and library.SendNotification then library:SendNotification('Namecall dump enabled for next 200 calls', 3, Color3.fromRGB(255,200,0)) end end)
        print('[SilentAim] Namecall dump enabled for next 200 calls')
    end
})

-- Debug: Print a stack trace on next click and boost capture counters
AimbotSections.Silent:AddButton({
    text = "Click Stack (Debug)",
    tooltip = "Enable stack trace and stronger dumps on next Mouse.Button1Down",
    callback = function()
        FullNamecallDump = math.max(FullNamecallDump, 200)
        VerboseNamecallCapture = math.max(VerboseNamecallCapture, 200)
        ForceReplaceCount = math.max(ForceReplaceCount, 12)
        pcall(function() print('[SilentAim] Click Stack enabled: next Mouse.Button1Down will print stack and dump namecalls') end)
    end
})

-- Debug: Scan all remotes in the game (aggressive, may be heavy)
AimbotSections.Silent:AddButton({
    text = "Scan All Remotes (Debug)",
    tooltip = "Scan entire game for RemoteEvent/RemoteFunction and wrap them for silent aim testing",
    callback = function()
        local found = 0
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                pcall(WrapRemote, obj)
                found = found + 1
            end
        end
        pcall(function() if library and library.SendNotification then library:SendNotification('Scanned game for remotes, found: '..tostring(found), 3, Color3.fromRGB(255,200,0)) end end)
        print('[SilentAim] ScanAllRemotes found: '..tostring(found))
    end
})

-- Debug: Dump FireServer/InvokeServer namecalls (detailed captures)
AimbotSections.Silent:AddButton({
    text = "Dump FireServer (Debug)",
    tooltip = "Log detailed FireServer/InvokeServer calls for the next 200 calls",
    callback = function()
        VerboseNamecallCapture = 200
        pcall(function() if library and library.SendNotification then library:SendNotification('Detailed FireServer/InvokeServer dump enabled for next 200 calls', 3, Color3.fromRGB(255,200,0)) end end)
        print('[SilentAim] FireServer dump enabled for next 200 calls')
    end
})


--[[ ═══════════════════════════════════════════════════════════════
                        ESP/VISUALS TAB
═══════════════════════════════════════════════════════════════ ]]

--// Create Sections
local VisualsSections = {
    ESP = tabs.Visuals:AddSection("Player ESP", 1),
    World = tabs.Visuals:AddSection("World", 2),
    Crosshair = tabs.Visuals:AddSection("Crosshair", 2),
}

--// Player ESP Section
VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Enable ESP",
    flag = "ESP_Enabled",
    tooltip = "Master ESP toggle",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Team Check",
    flag = "ESP_Team_Check",
    tooltip = "Hide ESP on teammates",
})

VisualsSections.ESP:AddSlider({
    text = "Max Distance",
    flag = "ESP_Max_Distance",
    suffix = " studs",
    value = 1000,
    min = 100,
    max = 5000,
    increment = 100,
    tooltip = "Maximum render distance",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Box ESP",
    flag = "ESP_Box",
    tooltip = "Draw boxes around players",
})

VisualsSections.ESP:AddList({
    text = "Box Type",
    flag = "ESP_Box_Type",
    tooltip = "Style of ESP boxes",
    values = {"2D", "Corner", "3D"},
    value = "2D",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Box Outline",
    flag = "ESP_Box_Outline",
    tooltip = "Add black outline to boxes",
})

VisualsSections.ESP:AddColor({
    text = "Box Color",
    flag = "ESP_Box_Color",
    tooltip = "Color of ESP boxes",
    color = Color3.fromRGB(255, 50, 50),
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Name ESP",
    flag = "ESP_Name",
    tooltip = "Show player names",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Distance ESP",
    flag = "ESP_Distance",
    tooltip = "Show distance to players",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Tool/Weapon ESP",
    flag = "ESP_Tool",
    tooltip = "Show equipped tools",
})

VisualsSections.ESP:AddColor({
    text = "Text Color",
    flag = "ESP_Name_Color",
    tooltip = "Color of text elements",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Health Bar",
    flag = "ESP_Health",
    tooltip = "Show health bars",
})

VisualsSections.ESP:AddList({
    text = "Health Position",
    flag = "ESP_Health_Position",
    tooltip = "Where to show health bar",
    values = {"Left", "Right", "Top", "Bottom"},
    value = "Left",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Tracers",
    flag = "ESP_Tracers",
    tooltip = "Draw lines to players",
})

VisualsSections.ESP:AddList({
    text = "Tracer Origin",
    flag = "ESP_Tracer_Origin",
    tooltip = "Where tracers start from",
    values = {"Bottom", "Center", "Top", "Mouse"},
    value = "Bottom",
})

VisualsSections.ESP:AddColor({
    text = "Tracer Color",
    flag = "ESP_Tracer_Color",
    tooltip = "Color of tracers",
    color = Color3.fromRGB(255, 50, 50),
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Skeleton ESP",
    flag = "ESP_Skeleton",
    tooltip = "Draw skeleton on players",
})

VisualsSections.ESP:AddColor({
    text = "Skeleton Color",
    flag = "ESP_Skeleton_Color",
    tooltip = "Color of skeleton lines",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Chams/Highlight",
    flag = "ESP_Chams",
    tooltip = "Highlight players through walls",
    risky = true,
})

VisualsSections.ESP:AddList({
    text = "Chams Style",
    flag = "ESP_Chams_Style",
    tooltip = "Visual style of chams",
    values = {"Fill", "Outline", "Both", "Glow", "Pulse", "Rainbow"},
    value = "Fill",
})

VisualsSections.ESP:AddSlider({
    text = "Chams Opacity",
    flag = "ESP_Chams_Transparency",
    suffix = "%",
    value = 80,
    min = 10,
    max = 100,
    increment = 10,
    tooltip = "Opacity of chams fill",
})

VisualsSections.ESP:AddColor({
    text = "Chams Color",
    flag = "ESP_Chams_Color",
    tooltip = "Color of chams/highlights",
    color = Color3.fromRGB(255, 100, 100),
})

VisualsSections.ESP:AddSeparator({text = "Rainbow"})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Rainbow Box",
    flag = "ESP_Box_RGB",
    tooltip = "Rainbow color cycling on boxes",
})

VisualsSections.ESP:AddToggle({
    enabled = true,
    text = "Rainbow Tracers",
    flag = "ESP_Tracer_RGB",
    tooltip = "Rainbow color cycling on tracers",
})

VisualsSections.ESP:AddSlider({
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
    enabled = true,
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

VisualsSections.Crosshair:AddColor({
    text = "Color",
    flag = "Crosshair_Color",
    tooltip = "Crosshair color",
    color = Color3.fromRGB(255, 255, 255),
})

VisualsSections.Crosshair:AddToggle({
    enabled = true,
    text = "Outline",
    flag = "Crosshair_Outline",
    tooltip = "Add black outline",
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

VisualsSections.Crosshair:AddToggle({
    enabled = true,
    text = "Rotation",
    flag = "Crosshair_Rotation",
    tooltip = "Rotate crosshair",
})

VisualsSections.Crosshair:AddSlider({
    text = "Rotation Speed",
    flag = "Crosshair_Rotation_Speed",
    suffix = "°/s",
    value = 45,
    min = 10,
    max = 180,
    increment = 10,
    tooltip = "Rotation speed in degrees per second",
})

--// World Section
VisualsSections.World:AddToggle({
    enabled = true,
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
    enabled = true,
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
    enabled = true,
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
    enabled = true,
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
    enabled = true,
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
    enabled = true,
    text = "Infinite Jump",
    flag = "Infinite_Jump",
    tooltip = "Jump infinite times",
    risky = true,
})

PlayerSections.Movement:AddSeparator({text = "Advanced Movement"})

PlayerSections.Movement:AddToggle({
    enabled = true,
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
    enabled = true,
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
    enabled = true,
    text = "God Mode",
    flag = "God_Mode",
    tooltip = "Attempt to enable god mode (may not work)",
    risky = true,
})

PlayerSections.Character:AddToggle({
    enabled = true,
    text = "No Fall Damage",
    flag = "No_Fall_Damage",
    tooltip = "Remove fall damage",
})

PlayerSections.Character:AddToggle({
    enabled = true,
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
    Fun = tabs.Misc:AddSection("Fun & Server", 1),
    Teleport = tabs.Misc:AddSection("Teleport", 2),
}

--// Utility Section
MiscSections.Utility:AddToggle({
    enabled = true,
    text = "Anti-AFK",
    flag = "Anti_AFK",
    tooltip = "Prevent AFK kick",
})

MiscSections.Utility:AddToggle({
    enabled = true,
    text = "Auto-Rejoin",
    flag = "Auto_Rejoin",
    tooltip = "Automatically rejoin when kicked",
})

MiscSections.Utility:AddToggle({
    enabled = true,
    text = "Streamer Mode",
    flag = "Streamer_Mode",
    tooltip = "Hide sensitive information",
})

MiscSections.Utility:AddSeparator({text = "Performance"})

MiscSections.Utility:AddToggle({
    enabled = true,
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
    increment = 20,
    tooltip = "Maximum FPS limit",
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

--// Fun & Server Section
MiscSections.Fun:AddToggle({
    enabled = true,
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
    min = 50,
    max = 1000,
    increment = 50,
    tooltip = "Rotation speed",
})

MiscSections.Fun:AddList({
    text = "Animation",
    flag = "Animation_Changer",
    tooltip = "Change animation style (game-specific)",
    values = {"None", "Zombie", "Knight", "Levitate", "Astronaut", "Ninja", "Werewolf", "Elder"},
    value = "None",
})

MiscSections.Fun:AddSeparator({text = "Server Controls"})

MiscSections.Fun:AddButton({
    text = "Rejoin Server",
    tooltip = "Rejoin current server",
    confirm = true,
    callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

MiscSections.Fun:AddButton({
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

MiscSections.Fun:AddButton({
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
                            local hit = nil
                            local ok, res = pcall(function() return Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, camera}) end)
                            if ok then hit = res end
                            if not hit then
                                local ok2, res2 = pcall(function() return Workspace:FindPartOnRay(ray) end)
                                if ok2 then hit = res2 end
                            end
                            if not hit then
                                local ok3, res3 = pcall(function() return Workspace:Raycast(ray.Origin, ray.Direction) end)
                                if ok3 and res3 and res3.Instance then hit = res3.Instance end
                            end
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

--// Update Silent Aim Target Selection
local function UpdateSilentAimTarget()
    -- Basic checks
    if not library.flags["Silent_Aim_Enabled"] then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "Silent Aim disabled"
        return
    end

    if not IsSilentAimKeyHeld then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "Silent key not held"
        return
    end

    -- Optionally use the Aimbot's selected target (uses same FOV/priorities)
    local target = nil
    if library.flags["Silent_Use_Aimbot_Target"] then
        if AimbotTarget and AimbotTarget.Character then
            local partName = library.flags["Aimbot_Part"] or "Head"
            local char = AimbotTarget.Character
            if partName == "Random" then
                target = { player = AimbotTarget, part = GetRandomPart(char) }
            elseif partName == "Closest" then
                target = { player = AimbotTarget, part = GetClosestPart(char) }
            else
                target = { player = AimbotTarget, part = char:FindFirstChild(partName) }
            end
            if not (target and target.part) then
                SilentAimData = nil
                SilentAimActiveIndicator = false
                SilentAimLastDebug = "Aimbot target missing part"
                return
            end
        else
            SilentAimData = nil
            SilentAimActiveIndicator = false
            SilentAimLastDebug = "Aimbot target unavailable"
            return
        end
    else
        -- Default behaviour (self-contained selection)
        target = GetAimbotTarget()
    end

    -- Activation chance
    if math.random(1, 100) > (library.flags["Silent_Aim_Chance"] or 100) then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "Activation chance failed"
        return
    end

    local target = GetAimbotTarget()
    if not target then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "No valid target"
        return
    end

    -- Hit chance
    if math.random(1, 100) > (library.flags["Silent_Hit_Chance"] or 100) then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "Hit chance failed"
        return
    end

    -- Debug print for target lock (throttled)
    pcall(function()
        local key = tostring(target.player and target.player.Name or 'nil') .. ':' .. tostring(target.part and target.part.Name or 'nil')
        local now = tick()
        if key ~= SilentAimLastLockKey or (now - (SilentAimLastLockTime or 0)) > SilentAimLockThrottle then
            SilentAimLastLockKey = key
            SilentAimLastLockTime = now
            print(string.format('[SilentAim] Lock Attempt: %s part: %s', tostring(target.player and target.player.Name or 'nil'), tostring(target.part and target.part.Name or 'nil')))
        end
    end)

    local targetPart = target.part
    if not targetPart then
        SilentAimData = nil
        SilentAimActiveIndicator = false
        SilentAimLastDebug = "Target part missing"
        return
    end

    local predictedPosition = targetPart.Position
    local parent = targetPart.Parent

    -- Prefer HumanoidRootPart velocity for prediction when available
    if library.flags.Aimbot_Prediction then
        local hrp = parent and parent:FindFirstChild("HumanoidRootPart")
        if hrp then
            local velocity = hrp.AssemblyLinearVelocity or Vector3.new()
            local predictionMultiplier = library.flags.Aimbot_Prediction_Velocity or 0.165
            predictedPosition = predictedPosition + (velocity * predictionMultiplier)
        end
    end

    SilentAimData = {
        player = target.player,
        part = targetPart,
        position = predictedPosition,
        timestamp = tick(),
    }

    SilentAimActiveIndicator = true
    SilentAimLastDebug = string.format("Locked on %s at (%.2f, %.2f, %.2f)", target.player.Name, predictedPosition.X, predictedPosition.Y, predictedPosition.Z)
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

--// Silent Aim Mouse Hook (safe/resilient)
local success, rawMeta = pcall(getrawmetatable, game)
if success and rawMeta then
    local oldIndex = rawMeta.__index
    setreadonly(rawMeta, false)
    rawMeta.__index = function(self, key)
        -- Ensure we only override mouse properties when not called by our script
        if self == Mouse and (key == "Hit" or key == "Target") and not checkcaller() then
            if SilentAimData and SilentAimData.part and SilentAimData.position then
                SilentAimLastDebug = SilentAimLastDebug or "Overriding mouse property"
                -- Print minimally to console for debugging (pcall to avoid errors)
                pcall(function()
                    -- Small, infrequent print to avoid spam; only when timestamp is recent
                    if SilentAimData.timestamp and tick() - SilentAimData.timestamp < 0.2 then
                        print("[SilentAim] Overriding Mouse." .. key .. " -> " .. tostring(SilentAimData.part.Name))
                    end
                end)

                if key == "Hit" then
                    return CFrame.new(SilentAimData.position)
                elseif key == "Target" then
                    return SilentAimData.part
                end
            end
        end

        if type(oldIndex) == "function" then
            return oldIndex(self, key)
        end

        return oldIndex[key]
    end
    setreadonly(rawMeta, true)
else
    warn("Silent Aim: getrawmetatable unavailable or failed")
end

--// Remote fallback for games that don't use Mouse.Hit/Target
local RemoteFallbackEnabled = false
local RemoteFallbackWrapped = {}
local RemoteFallbackOriginals = {}
local RemoteFallbackLogs = {}
local remoteScanConn = nil

-- Debug: Force replace next N remote/namecall args (one-shot)
local ForceReplaceCount = 0
local function ForceReplaceNextShots(count)
    ForceReplaceCount = tonumber(count) or 12
    pcall(function()
        if library and library.SendNotification then
            library:SendNotification('Force replace enabled for next '..tostring(ForceReplaceCount)..' shots', 2, Color3.fromRGB(255,200,0))
        end
    end)
    print('[SilentAim] ForceReplace enabled for next ' .. tostring(ForceReplaceCount) .. ' shots')
end

local function WrapRemote(remote)
    if not remote or RemoteFallbackWrapped[remote] then return end
    RemoteFallbackWrapped[remote] = true
    RemoteFallbackOriginals[remote] = {
        FireServer = remote.FireServer,
        InvokeServer = remote.InvokeServer,
    }

    if type(remote.FireServer) == "function" then
        remote.FireServer = function(self, ...)
            local args = { ... }

            -- Prepare a small summary and a more detailed summary of original arguments for debugging
            local function vec3str(v) return string.format('%.2f,%.2f,%.2f', v.X, v.Y, v.Z) end
            local function cfrstr(cf) local p = cf.Position; return string.format('%.2f,%.2f,%.2f', p.X, p.Y, p.Z) end
            local function dumpTable(t, limit)
                local parts = {}
                for k, val in pairs(t) do
                    if #parts >= (limit or 8) then break end
                    local tv = typeof(val)
                    local repr = tv
                    if tv == 'Vector3' then repr = repr .. ':' .. vec3str(val)
                    elseif tv == 'CFrame' then repr = repr .. ':' .. cfrstr(val)
                    else repr = repr .. ':' .. tostring(val)
                    end
                    table.insert(parts, tostring(k) .. '=' .. repr)
                end
                return '{' .. table.concat(parts, ',') .. '}'
            end

            local origSummary = {}
            local detailedSummary = {}
            for i, v in ipairs(args) do
                local tv = typeof(v)
                table.insert(origSummary, tv)
                if tv == 'Vector3' then
                    table.insert(detailedSummary, string.format('[%d]=Vector3(%s)', i, vec3str(v)))
                elseif tv == 'CFrame' then
                    table.insert(detailedSummary, string.format('[%d]=CFrame(%s)', i, cfrstr(v)))
                elseif tv == 'table' then
                    table.insert(detailedSummary, string.format('[%d]=table%s', i, dumpTable(v, 12)))
                else
                    table.insert(detailedSummary, string.format('[%d]=%s(%s)', i, tv, tostring(v)))
                end
            end

            -- Throttle logs per-remote to avoid spamming
            RemoteFallbackLogs[remote] = RemoteFallbackLogs[remote] or { count = 0, last = 0 }
            local rl = RemoteFallbackLogs[remote]

            local replaced = false
            if SilentAimData and SilentAimData.position and SilentAimData.part then
                local i = 1
                while i <= #args do
                    local v = args[i]
                    local t = typeof(v)

                    -- Handle tables with Origin/Position/Direction fields
                    if t == 'table' then
                        local changed = false
                        -- normalize key lookup (case-insensitive common keys)
                        local function hasKey(tbl, ...)
                            for _, key in ipairs({...}) do
                                if tbl[key] ~= nil then return key end
                            end
                            return nil
                        end

                        local originKey = hasKey(v, 'Origin', 'origin', 'Position', 'position')
                        local dirKey = hasKey(v, 'Direction', 'direction')

                        if originKey then
                            v[originKey] = SilentAimData.position
                            changed = true
                        end

                        if dirKey then
                            local oldDir = v[dirKey]
                            if typeof(oldDir) == 'Vector3' then
                                local origin = v[originKey] or SilentAimData.position
                                local newDir = (SilentAimData.position - origin)
                                if newDir.Magnitude > 0 then
                                    -- preserve magnitude of oldDir if available
                                    local mag = oldDir.Magnitude or 1
                                    v[dirKey] = newDir.Unit * mag
                                else
                                    v[dirKey] = Vector3.new(0,0,0)
                                end
                                changed = true
                            end

                            -- if direction is Vector2-based, convert similarly
                            if typeof(oldDir) == 'Vector2' then
                                local origin = v[originKey] or SilentAimData.position
                                local screenPos = Camera:WorldToViewportPoint(SilentAimData.position)
                                v[dirKey] = Vector2.new(screenPos.X, screenPos.Y)
                                changed = true
                            end
                        end

                        if changed then replaced = true end

                    elseif t == 'Vector3' then
                        local nextv = args[i+1]
                        if nextv and typeof(nextv) == 'Vector3' then
                            -- origin + direction pair
                            local originalOrigin = args[i]
                            local originalDir = args[i+1]
                            local newDir = (SilentAimData.position - originalOrigin)
                            if newDir.Magnitude > 0 then
                                local mag = (typeof(originalDir) == 'Vector3' and originalDir.Magnitude) or newDir.Magnitude
                                args[i+1] = newDir.Unit * mag
                            else
                                args[i+1] = Vector3.new(0,0,0)
                            end
                            replaced = true
                            i = i + 2
                        else
                            -- single Vector3 -> replace with target position
                            args[i] = SilentAimData.position
                            replaced = true
                            i = i + 1
                        end

                    elseif t == 'CFrame' then
                        args[i] = CFrame.new(SilentAimData.position)
                        replaced = true
                    elseif t == 'Ray' then
                        local dir = v.Direction or Vector3.new(0,0,0)
                        args[i] = Ray.new(SilentAimData.position, dir)
                        replaced = true
                    elseif t == 'Vector2' then
                        -- remote passing screen position; convert target world pos to screen coords
                        local screenPos = Camera:WorldToViewportPoint(SilentAimData.position)
                        args[i] = Vector2.new(screenPos.X, screenPos.Y)
                        replaced = true
                        i = i + 1
                    elseif t == 'number' then
                        local nextn = args[i+1]
                        if type(nextn) == 'number' then
                            -- Treat as possible screen (x,y) pair if values are within viewport range
                            local vx = math.abs(args[i]) <= (Camera.ViewportSize.X + 1) and math.abs(nextn) <= (Camera.ViewportSize.Y + 1)
                            if vx then
                                local screenPos = Camera:WorldToViewportPoint(SilentAimData.position)
                                args[i] = screenPos.X
                                args[i+1] = screenPos.Y
                                replaced = true
                                i = i + 2
                            else
                                i = i + 1
                            end
                        else
                            i = i + 1
                        end
                    elseif t == 'Instance' and v:IsA('BasePart') then
                        args[i] = SilentAimData.part
                        replaced = true
                    end

                end

                -- Aggressive fallback heuristics (if enabled)
                if (not replaced) and library.flags["Silent_Aggressive_Remote"] then
                    for j = 1, #args do
                        -- origin(Vector3), distance(number) -> replace distance into a direction vector
                        if typeof(args[j]) == 'Vector3' and typeof(args[j+1]) == 'number' then
                            local origin = args[j]
                            local distance = args[j+1]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j+1] = newDir.Unit * (distance or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end

                        -- [origin, dir, speed] style tables
                        if type(args[j]) == 'table' and #args[j] >= 2 and typeof(args[j][1]) == 'Vector3' and typeof(args[j][2]) == 'Vector3' then
                            local origin = args[j][1]
                            local dir = args[j][2]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j][2] = newDir.Unit * (dir.Magnitude or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end
                    end
                end

                -- Send a short in-game notification when a replacement occurs (throttled)
                if replaced and (tick() - (rl.lastNotification or 0)) > 0.75 then
                    rl.lastNotification = tick()
                    pcall(function()
                        if library and library.SendNotification then
                            library:SendNotification('SilentAim injected into '..tostring(remote.Name or remote.ClassName), 1, Color3.fromRGB(0,255,0))
                        end
                    end)
                end

                if (tick() - rl.last) > 1 and rl.count < 20 then
                    rl.count = rl.count + 1; rl.last = tick()
                    pcall(function()
                        print(string.format('[SilentAim][RemoteDebug] %s FireServer called. Silent target=%s. Orig=%s Replaced=%s\nStack: %s', tostring(remote.Name or remote.ClassName), tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(detailedSummary, ', '), tostring(replaced), debug.traceback('',2)))
                    end)
                end
            end

                -- Force-replace heuristic for quick debugging (one-shot)
                if ForceReplaceCount and ForceReplaceCount > 0 and SilentAimData and SilentAimData.position then
                    local f_replaced = false
                    for idx = 1, #args do
                        local vt = typeof(args[idx])
                        if vt == 'Vector3' then
                            args[idx] = SilentAimData.position; f_replaced = true
                        elseif vt == 'CFrame' then
                            args[idx] = CFrame.new(SilentAimData.position); f_replaced = true
                        elseif vt == 'Vector2' then
                            local sp = Camera:WorldToViewportPoint(SilentAimData.position)
                            args[idx] = Vector2.new(sp.X, sp.Y); f_replaced = true
                        elseif vt == 'number' and type(args[idx+1]) == 'number' then
                            local sp = Camera:WorldToViewportPoint(SilentAimData.position)
                            args[idx] = sp.X; args[idx+1] = sp.Y; f_replaced = true
                        elseif vt == 'string' and SilentAimData.player and type(args[idx])=='string' and args[idx]:lower() == (SilentAimData.player.Name or ''):lower() then
                            args[idx] = SilentAimData.player; f_replaced = true
                        elseif vt == 'Instance' and args[idx]:IsA('BasePart') then
                            args[idx] = SilentAimData.part; f_replaced = true
                        end
                    end
                    if f_replaced then
                        replaced = true
                        ForceReplaceCount = math.max(ForceReplaceCount - 1, 0)
                        print(string.format('[SilentAim][ForceReplace] %s FireServer forced replacement. Remaining=%d', tostring(remote.Name or remote.ClassName), ForceReplaceCount))
                    end
                end

                RemoteFallbackLogs[remote] = rl

                if replaced and VerboseNamecallCapture and VerboseNamecallCapture > 0 then
                    pcall(function()
                        print(string.format('[SilentAim][ReplaceVerbose] %s FireServer replaced args before sending. Silent target=%s. Orig=%s', tostring(remote.Name or remote.ClassName), tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(detailedSummary, ', ')))
                    end)
                end

                return RemoteFallbackOriginals[remote].FireServer(self, table.unpack(args))
        end
    end

    if type(remote.InvokeServer) == "function" then
        remote.InvokeServer = function(self, ...)
            local args = { ... }

            -- Prepare a small summary and a more detailed summary of original arguments for debugging
            local function vec3str(v) return string.format('%.2f,%.2f,%.2f', v.X, v.Y, v.Z) end
            local function cfrstr(cf) local p = cf.Position; return string.format('%.2f,%.2f,%.2f', p.X, p.Y, p.Z) end
            local function dumpTable(t, limit)
                local parts = {}
                for k, val in pairs(t) do
                    if #parts >= (limit or 8) then break end
                    local tv = typeof(val)
                    local repr = tv
                    if tv == 'Vector3' then repr = repr .. ':' .. vec3str(val)
                    elseif tv == 'CFrame' then repr = repr .. ':' .. cfrstr(val)
                    else repr = repr .. ':' .. tostring(val)
                    end
                    table.insert(parts, tostring(k) .. '=' .. repr)
                end
                return '{' .. table.concat(parts, ',') .. '}'
            end

            local origSummary = {}
            local detailedSummary = {}
            for i, v in ipairs(args) do
                local tv = typeof(v)
                table.insert(origSummary, tv)
                if tv == 'Vector3' then
                    table.insert(detailedSummary, string.format('[%d]=Vector3(%s)', i, vec3str(v)))
                elseif tv == 'CFrame' then
                    table.insert(detailedSummary, string.format('[%d]=CFrame(%s)', i, cfrstr(v)))
                elseif tv == 'table' then
                    table.insert(detailedSummary, string.format('[%d]=table%s', i, dumpTable(v, 12)))
                else
                    table.insert(detailedSummary, string.format('[%d]=%s(%s)', i, tv, tostring(v)))
                end
            end

            -- Throttle logs per-remote to avoid spamming
            RemoteFallbackLogs[remote] = RemoteFallbackLogs[remote] or { count = 0, last = 0 }
            local rl = RemoteFallbackLogs[remote]

            local replaced = false
            if SilentAimData and SilentAimData.position and SilentAimData.part then
                local i = 1
                while i <= #args do
                    local v = args[i]
                    local t = typeof(v)

                    -- Handle tables with Origin/Position/Direction fields
                    if t == 'table' then
                        local changed = false
                        -- normalize key lookup (case-insensitive common keys)
                        local function hasKey(tbl, ...)
                            for _, key in ipairs({...}) do
                                if tbl[key] ~= nil then return key end
                            end
                            return nil
                        end

                        local originKey = hasKey(v, 'Origin', 'origin', 'Position', 'position')
                        local dirKey = hasKey(v, 'Direction', 'direction')

                        if originKey then
                            v[originKey] = SilentAimData.position
                            changed = true
                        end

                        if dirKey then
                            local oldDir = v[dirKey]
                            if typeof(oldDir) == 'Vector3' then
                                local origin = v[originKey] or SilentAimData.position
                                local newDir = (SilentAimData.position - origin)
                                if newDir.Magnitude > 0 then
                                    local mag = oldDir.Magnitude or 1
                                    v[dirKey] = newDir.Unit * mag
                                else
                                    v[dirKey] = Vector3.new(0,0,0)
                                end
                                changed = true
                            end
                        end

                        if changed then replaced = true end

                    elseif t == 'Vector3' then
                        -- If a Vector3 is followed by another Vector3, treat as origin + direction pair
                        local nextv = args[i+1]
                        if nextv and typeof(nextv) == 'Vector3' then
                            local originalOrigin = args[i]
                            local originalDir = args[i+1]
                            local newDir = (SilentAimData.position - originalOrigin)
                            if newDir.Magnitude > 0 then
                                local mag = (typeof(originalDir) == 'Vector3' and originalDir.Magnitude) or newDir.Magnitude
                                args[i+1] = newDir.Unit * mag
                            else
                                args[i+1] = Vector3.new(0,0,0)
                            end
                            replaced = true
                            i = i + 2
                        else
                            args[i] = SilentAimData.position
                            replaced = true
                        end

                    elseif t == 'CFrame' then
                        args[i] = CFrame.new(SilentAimData.position)
                        replaced = true
                    elseif t == 'Ray' then
                        local dir = v.Direction or Vector3.new(0,0,0)
                        args[i] = Ray.new(SilentAimData.position, dir)
                        replaced = true
                    elseif t == 'Instance' and v:IsA('BasePart') then
                        args[i] = SilentAimData.part
                        replaced = true
                    end

                end

                -- Aggressive fallback heuristics (if enabled)
                if (not replaced) and library.flags["Silent_Aggressive_Remote"] then
                    for j = 1, #args do
                        if typeof(args[j]) == 'Vector3' and typeof(args[j+1]) == 'number' then
                            local origin = args[j]
                            local distance = args[j+1]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j+1] = newDir.Unit * (distance or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end

                        if type(args[j]) == 'table' and #args[j] >= 2 and typeof(args[j][1]) == 'Vector3' and typeof(args[j][2]) == 'Vector3' then
                            local origin = args[j][1]
                            local dir = args[j][2]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j][2] = newDir.Unit * (dir.Magnitude or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end
                    end
                end

                if replaced and (tick() - (rl.lastNotification or 0)) > 0.75 then
                    rl.lastNotification = tick()
                    pcall(function()
                        if library and library.SendNotification then
                            library:SendNotification('SilentAim injected into '..tostring(remote.Name or remote.ClassName), 1, Color3.fromRGB(0,255,0))
                        end
                    end)
                end

                if (tick() - rl.last) > 1 and rl.count < 20 then
                    rl.count = rl.count + 1; rl.last = tick()
                    pcall(function()
                        print(string.format('[SilentAim][RemoteDebug] %s InvokeServer called. Silent target=%s. Orig=%s Replaced=%s\nStack: %s', tostring(remote.Name or remote.ClassName), tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(detailedSummary, ', '), tostring(replaced), debug.traceback('',2)))
                    end)
                end
            end

            RemoteFallbackLogs[remote] = rl
            return RemoteFallbackOriginals[remote].InvokeServer(self, table.unpack(args))
        end
    end
end

-- Install a namecall hook to catch remote calls we couldn't wrap directly
local namecallHookInstalled = false
local oldNamecall
local VerboseNamecallCapture = 0 -- counts how many namecalls to print verbosely
local FullNamecallDump = 0 -- dump all namecalls (method + arg types) for next N calls (debug)
local function InstallNamecallHook()
    if namecallHookInstalled then return end
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return end
    oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local argsAll = { ... }

        -- Full namecall dump (debug): print any namecall signatures to discover game behavior
        if FullNamecallDump and FullNamecallDump > 0 and not checkcaller() then
            FullNamecallDump = math.max(FullNamecallDump - 1, 0)
            pcall(function()
                local parts = {}
                for i, v in ipairs(argsAll) do
                    local tv = typeof(v)
                    if tv == 'string' or tv == 'number' or tv == 'boolean' then
                        table.insert(parts, string.format('%s(%s)', tv, tostring(v)))
                    else
                        table.insert(parts, tv)
                    end
                end
                print(string.format('[SilentAim][NamecallDump] %s.%s Args=%s', tostring(self and (self.Name or self.ClassName) or 'unknown'), method, table.concat(parts, ', ')))
            end)
        end

        -- Ray redirection: try Workspace methods first, then generic detection
        if not checkcaller() and Toggles and Toggles.aim_Enabled and Toggles.aim_Enabled.Value and SilentAimData and SilentAimData.position then
            local didRedirect = false

            -- Existing workspace-targeted logic (keeps compatibility)
            if self == Workspace and (method == 'FindPartOnRayWithIgnoreList' or method == 'FindPartOnRay' or method == 'Raycast' or method:lower() == 'findpartonray') then
                local args = { table.unpack(argsAll) }
                local argsFull = {self, table.unpack(args)}
                if method == 'FindPartOnRayWithIgnoreList' and ValidateArguments(argsFull, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                    local ray = args[1]
                    local ok, origin = pcall(function() return ray.Origin end)
                    if ok then
                        local newDir = getDirection(origin, SilentAimData.position)
                        if newDir.Magnitude > 0 then
                            args[1] = Ray.new(origin, newDir)
                            didRedirect = true
                            pcall(function() print(string.format('[SilentAim][RayNamecall] Redirected %s to %s', method, tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'))) end)
                        end
                    end
                elseif method == 'FindPartOnRay' and ValidateArguments(argsFull, ExpectedArguments.FindPartOnRay) then
                    local ray = args[1]
                    local ok, origin = pcall(function() return ray.Origin end)
                    if ok then
                        local newDir = getDirection(origin, SilentAimData.position)
                        if newDir.Magnitude > 0 then
                            args[1] = Ray.new(origin, newDir)
                            didRedirect = true
                            pcall(function() print(string.format('[SilentAim][RayNamecall] Redirected %s to %s', method, tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'))) end)
                        end
                    end
                elseif method == 'Raycast' and ValidateArguments(argsFull, ExpectedArguments.Raycast) then
                    local origin = args[1]
                    if typeof(origin) == 'Vector3' then
                        args[2] = getDirection(origin, SilentAimData.position)
                        didRedirect = true
                        pcall(function() print(string.format('[SilentAim][RayNamecall] Redirected %s to %s', method, tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'))) end)
                    end
                end

                if didRedirect then return oldNamecall(self, table.unpack(args)) end
            end

            -- Generic fallback: catch calls that pass a Ray or (Vector3, Vector3) as args even if self != Workspace
            if not didRedirect then
                -- If first arg is a Ray
                if #argsAll >= 1 and typeof(argsAll[1]) == 'Ray' then
                    local ok, origin = pcall(function() return argsAll[1].Origin end)
                    if ok then
                        local newDir = getDirection(origin, SilentAimData.position)
                        if newDir.Magnitude > 0 then
                            argsAll[1] = Ray.new(origin, newDir)
                            didRedirect = true
                            pcall(function() print(string.format('[SilentAim][RayNamecall] Generic redirected Ray arg in %s', method)) end)
                        end
                    end
                -- If args are (Vector3 origin, Vector3 direction)
                elseif #argsAll >= 2 and typeof(argsAll[1]) == 'Vector3' and typeof(argsAll[2]) == 'Vector3' then
                    argsAll[2] = getDirection(argsAll[1], SilentAimData.position)
                    didRedirect = true
                    pcall(function() print(string.format('[SilentAim][RayNamecall] Generic redirected Vector3 origin/direction in %s', method)) end)
                end

                if didRedirect then
                    return oldNamecall(self, table.unpack(argsAll))
                end
            end
        end

        if (method == 'FireServer' or method == 'InvokeServer') and not checkcaller() and (RemoteFallbackEnabled or (VerboseNamecallCapture and VerboseNamecallCapture > 0)) then
            local args = { ... }

            -- simple helper for formatting/diagnostics
            local function fmtArg(v)
                local tv = typeof(v)
                if tv == 'Vector3' then return string.format('V3(%.2f,%.2f,%.2f)', v.X, v.Y, v.Z)
                elseif tv == 'CFrame' then local p = v.Position; return string.format('CFrame(%.2f,%.2f,%.2f)', p.X, p.Y, p.Z)
                elseif tv == 'table' then return 'table' end
                return tv
            end

            local origSummary = {}
            for i, v in ipairs(args) do table.insert(origSummary, fmtArg(v)) end

            -- Throttle per-remote
            RemoteFallbackLogs[self] = RemoteFallbackLogs[self] or { count = 0, last = 0 }
            local rl = RemoteFallbackLogs[self]

            -- If user requested a verbose capture (after shooting), print detailed per-arg info regardless of replacements
            if VerboseNamecallCapture and VerboseNamecallCapture > 0 then
                VerboseNamecallCapture = VerboseNamecallCapture - 1
                pcall(function()
                    print(string.format('[SilentAim][NamecallCapture] %s.%s called. Silent target=%s. Args=%s\nStack: %s', tostring(self and (self.Name or self.ClassName) or 'unknown'), method, tostring(SilentAimData and SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(origSummary, ', '), debug.traceback('', 2)))
                end)
            end

            -- Apply heuristic replacements (same logic as WrapRemote)
            local replaced = false
            if SilentAimData and SilentAimData.position and SilentAimData.part then
                local i = 1
                while i <= #args do
                    local v = args[i]
                    local t = typeof(v)

                    if t == 'table' then
                        local changed = false
                        if #v >= 2 and typeof(v[1]) == 'Vector3' and typeof(v[2]) == 'Vector3' then
                            local origin, dir = v[1], v[2]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then v[2] = newDir.Unit * (dir.Magnitude or newDir.Magnitude) end
                            replaced = true
                            changed = true
                        else
                            local function findKey(tbl, ...)
                                for _, k in ipairs({...}) do if tbl[k] ~= nil then return k end end
                                return nil
                            end
                            local originKey = findKey(v, 'Origin','origin','Position','position','From','from')
                            local toKey = findKey(v, 'To','to','Target','target','Position')
                            local dirKey = findKey(v, 'Direction','direction','Dir','dir','Velocity','velocity')
                            if originKey and toKey then v[toKey] = SilentAimData.position; replaced = true; changed = true end
                            if originKey and dirKey and typeof(v[dirKey]) == 'Vector3' then local origin = v[originKey] or SilentAimData.position; local newDir = (SilentAimData.position - origin); if newDir.Magnitude>0 then v[dirKey] = newDir.Unit * (v[dirKey].Magnitude or newDir.Magnitude) end; replaced=true; changed=true end
                            if originKey and dirKey and typeof(v[dirKey]) == 'Vector2' then local screenPos = Camera:WorldToViewportPoint(SilentAimData.position); v[dirKey] = Vector2.new(screenPos.X, screenPos.Y); replaced=true; changed=true end
                        end
                        i = i + 1

                    elseif t == 'Vector3' then
                        local nextv = args[i+1]
                        if nextv and typeof(nextv) == 'Vector3' then
                            local origin, dir = args[i], args[i+1]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then args[i+1] = newDir.Unit * (dir.Magnitude or newDir.Magnitude) end
                            replaced = true
                            i = i + 2
                        else
                            args[i] = SilentAimData.position
                            replaced = true
                            i = i + 1
                        end

                    elseif t == 'CFrame' then
                        args[i] = CFrame.new(SilentAimData.position)
                        replaced = true
                        i = i + 1

                    elseif t == 'Ray' then
                        local dir = v.Direction or Vector3.new(0,0,0)
                        args[i] = Ray.new(SilentAimData.position, dir)
                        replaced = true
                        i = i + 1

                    elseif t == 'Vector2' then
                        -- remote passing screen position; convert target world pos to screen coords
                        local screenPos = Camera:WorldToViewportPoint(SilentAimData.position)
                        args[i] = Vector2.new(screenPos.X, screenPos.Y)
                        replaced = true
                        i = i + 1

                    elseif t == 'number' then
                        local nextn = args[i+1]
                        if type(nextn) == 'number' then
                            local vx = math.abs(args[i]) <= (Camera.ViewportSize.X + 1) and math.abs(nextn) <= (Camera.ViewportSize.Y + 1)
                            if vx then
                                local screenPos = Camera:WorldToViewportPoint(SilentAimData.position)
                                args[i] = screenPos.X
                                args[i+1] = screenPos.Y
                                replaced = true
                                i = i + 2
                            else
                                i = i + 1
                            end
                        else
                            i = i + 1
                        end

                    elseif t == 'userdata' then
                        local ok1, origin = pcall(function() return v.Origin end)
                        local ok2, direction = pcall(function() return v.Direction end)
                        if ok1 and ok2 and typeof(origin) == 'Vector3' and typeof(direction) == 'Vector3' then
                            args[i] = Ray.new(SilentAimData.position, direction)
                            replaced = true
                        end
                        i = i + 1

                    elseif t == 'Instance' and v:IsA('BasePart') then
                        args[i] = SilentAimData.part
                        replaced = true
                        i = i + 1

                    else
                        i = i + 1
                    end
                end

                -- Aggressive fallback (if enabled)
                if (not replaced) and library.flags["Silent_Aggressive_Remote"] then
                    for j = 1, #args do
                        if typeof(args[j]) == 'Vector3' and typeof(args[j+1]) == 'number' then
                            local origin = args[j]
                            local distance = args[j+1]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j+1] = newDir.Unit * (distance or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end

                        if type(args[j]) == 'table' and #args[j] >= 2 and typeof(args[j][1]) == 'Vector3' and typeof(args[j][2]) == 'Vector3' then
                            local origin = args[j][1]
                            local dir = args[j][2]
                            local newDir = (SilentAimData.position - origin)
                            if newDir.Magnitude > 0 then
                                args[j][2] = newDir.Unit * (dir.Magnitude or newDir.Magnitude)
                                replaced = true
                                break
                            end
                        end
                    end
                end

                if replaced and (tick() - (rl.lastNotification or 0)) > 0.75 then
                    rl.lastNotification = tick()
                    pcall(function()
                        if library and library.SendNotification then
                            library:SendNotification('SilentAim injected via namecall on '..tostring(self and (self.Name or self.ClassName) or 'unknown'), 1, Color3.fromRGB(0,255,0))
                        end
                    end)
                end

                if (tick() - rl.last) > 1 and rl.count < 50 then
                    rl.count = rl.count + 1; rl.last = tick()
                    pcall(function()
                        print(string.format('[SilentAim][RemoteDebugNamecall] %s.%s called. Silent target=%s. Orig=%s Replaced=%s', tostring(self and (self.Name or self.ClassName) or 'unknown'), method, tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(origSummary, ', '), tostring(replaced)))
                    end)
                end
            end

            -- Force-replace heuristic for quick debugging (one-shot)
            if ForceReplaceCount and ForceReplaceCount > 0 and SilentAimData and SilentAimData.position then
                local f_replaced = false
                for idx = 1, #args do
                    local vt = typeof(args[idx])
                    if vt == 'Vector3' then
                        args[idx] = SilentAimData.position; f_replaced = true
                    elseif vt == 'CFrame' then
                        args[idx] = CFrame.new(SilentAimData.position); f_replaced = true
                    elseif vt == 'Vector2' then
                        local sp = Camera:WorldToViewportPoint(SilentAimData.position)
                        args[idx] = Vector2.new(sp.X, sp.Y); f_replaced = true
                    elseif vt == 'number' and type(args[idx+1]) == 'number' then
                        local sp = Camera:WorldToViewportPoint(SilentAimData.position)
                        args[idx] = sp.X; args[idx+1] = sp.Y; f_replaced = true
                    elseif vt == 'string' and SilentAimData.player and type(args[idx])=='string' and args[idx]:lower() == (SilentAimData.player.Name or ''):lower() then
                        args[idx] = SilentAimData.player; f_replaced = true
                    elseif vt == 'Instance' and args[idx]:IsA('BasePart') then
                        args[idx] = SilentAimData.part; f_replaced = true
                    end
                end
                if f_replaced then
                    replaced = true
                    ForceReplaceCount = math.max(ForceReplaceCount - 1, 0)
                    pcall(function()
                        print(string.format('[SilentAim][ForceReplace] namecall %s.%s forced replacement. Remaining=%d', tostring(self and (self.Name or self.ClassName) or 'unknown'), method, ForceReplaceCount))
                    end)
                end
            end

            RemoteFallbackLogs[self] = rl

            if replaced and VerboseNamecallCapture and VerboseNamecallCapture > 0 then
                pcall(function()
                    print(string.format('[SilentAim][ReplaceVerbose] %s.%s namecall replaced args before call. Silent target=%s. Orig=%s', tostring(self and (self.Name or self.ClassName) or 'unknown'), method, tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), table.concat(origSummary, ', ')))
                end)
            end

            return oldNamecall(self, table.unpack(args))
        end

        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    namecallHookInstalled = true
    pcall(function() print('[SilentAim][NamecallHook] Installed namecall hook') end)
end

InstallNamecallHook()

-- Install workspace raycast hooks to intercept local raycasts for silent aim

-- Expected argument shapes for ray methods (used for conservative validation)
local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 2,
        Args = {"Instance", "Ray", "table", "boolean", "boolean"}
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 2,
        Args = {"Instance", "Ray", "table", "boolean"}
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {"Instance", "Ray", "Instance", "boolean", "boolean"}
    },
    Raycast = {
        ArgCountRequired = 2,
        Args = {"Instance", "Vector3", "Vector3", "RaycastParams"}
    }
}

local function ValidateArguments(Args, RayMethod)
    if not RayMethod then return false end
    local Matches = 0
    if #Args < (RayMethod.ArgCountRequired or 0) then return false end
    for Pos, Argument in next, Args do
        local Expected = RayMethod.Args[Pos]
        if Expected and typeof(Argument) == Expected then
            Matches = Matches + 1
        end
    end
    return Matches >= (RayMethod.ArgCountRequired or 0)
end

local function getDirection(Origin, Position)
    -- return a long unit vector towards the position
    local dir = (Position - Origin)
    if dir.Magnitude == 0 then return Vector3.new(0,0,0) end
    return dir.Unit * 1000
end

local RayHookInstalled = false
local function InstallRaycastHooks()
    if RayHookInstalled then return end
    RayHookInstalled = true
    local ok_fpwril, orig_FindPartOnRayWithIgnoreList = pcall(function() return Workspace.FindPartOnRayWithIgnoreList end)
    if not ok_fpwril then orig_FindPartOnRayWithIgnoreList = nil end
    local ok_fpor, orig_FindPartOnRay = pcall(function() return Workspace.FindPartOnRay end)
    if not ok_fpor then orig_FindPartOnRay = nil end
    local ok_rr, orig_Raycast = pcall(function() return Workspace.Raycast end)
    if not ok_rr then orig_Raycast = nil end

    if type(orig_FindPartOnRayWithIgnoreList) == 'function' then
        local ok_assign, assign_err = pcall(function()
            Workspace.FindPartOnRayWithIgnoreList = function(self, ray, ignoreList, ...)
                local args = {self, ray, ignoreList, ...}
                if not ValidateArguments(args, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                    return orig_FindPartOnRayWithIgnoreList(self, ray, ignoreList, ...)
                end
                local ok, origin = pcall(function() return ray.Origin end)
                local ok2, dir = pcall(function() return ray.Direction end)
                if SilentAimData and SilentAimData.position and ok and ok2 and typeof(origin)=='Vector3' then
                    local newDir = getDirection(origin, SilentAimData.position)
                    if newDir.Magnitude > 0 then
                        local newRay = Ray.new(origin, newDir)
                        pcall(function() print(string.format('[SilentAim][RayHook] Redirected FindPartOnRayWithIgnoreList to %s from %s', tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), tostring(origin))) end)
                        return orig_FindPartOnRayWithIgnoreList(self, newRay, ignoreList, ...)
                    end
                end
                return orig_FindPartOnRayWithIgnoreList(self, ray, ignoreList, ...)
            end
        end)
        if ok_assign then
            pcall(function() print('[SilentAim][RayHook] Hooked FindPartOnRayWithIgnoreList') end)
        else
            pcall(function() print('[SilentAim][RayHook] Failed to hook FindPartOnRayWithIgnoreList: '..tostring(assign_err)) end)
        end
    else
        pcall(function() print('[SilentAim][RayHook] FindPartOnRayWithIgnoreList not available; skipping hook') end)
    end

    if type(orig_FindPartOnRay) == 'function' then
        local ok_assign, assign_err = pcall(function()
            Workspace.FindPartOnRay = function(self, ray, ...)
                local args = {self, ray, ...}
                if not ValidateArguments(args, ExpectedArguments.FindPartOnRay) then
                    return orig_FindPartOnRay(self, ray, ...)
                end
                local ok, origin = pcall(function() return ray.Origin end)
                local ok2, dir = pcall(function() return ray.Direction end)
                if SilentAimData and SilentAimData.position and ok and ok2 and typeof(origin)=='Vector3' then
                    local newDir = getDirection(origin, SilentAimData.position)
                    if newDir.Magnitude > 0 then
                        local newRay = Ray.new(origin, newDir)
                        pcall(function() print(string.format('[SilentAim][RayHook] Redirected FindPartOnRay to %s from %s', tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), tostring(origin))) end)
                        return orig_FindPartOnRay(self, newRay, ...)
                    end
                end
                return orig_FindPartOnRay(self, ray, ...)
            end
        end)
        if ok_assign then
            pcall(function() print('[SilentAim][RayHook] Hooked FindPartOnRay') end)
        else
            pcall(function() print('[SilentAim][RayHook] Failed to hook FindPartOnRay: '..tostring(assign_err)) end)
        end
    else
        pcall(function() print('[SilentAim][RayHook] FindPartOnRay not available; skipping hook') end)
    end

    if type(orig_Raycast) == 'function' then
        local ok_assign, assign_err = pcall(function()
            Workspace.Raycast = function(self, origin, direction, ...)
                local args = {self, origin, direction, ...}
                if not ValidateArguments(args, ExpectedArguments.Raycast) then
                    return orig_Raycast(self, origin, direction, ...)
                end
                if SilentAimData and SilentAimData.position and typeof(origin)=='Vector3' then
                    local newDir = getDirection(origin, SilentAimData.position)
                    if newDir.Magnitude > 0 then
                        pcall(function() print(string.format('[SilentAim][RayHook] Redirected Raycast to %s from %s', tostring(SilentAimData.player and SilentAimData.player.Name or 'nil'), tostring(origin))) end)
                        return orig_Raycast(self, origin, newDir, ...)
                    end
                end
                return orig_Raycast(self, origin, direction, ...)
            end
        end)
        if ok_assign then
            pcall(function() print('[SilentAim][RayHook] Hooked Raycast') end)
        else
            pcall(function() print('[SilentAim][RayHook] Failed to hook Raycast: '..tostring(assign_err)) end)
        end
    else
        pcall(function() print('[SilentAim][RayHook] Raycast not available; skipping hook') end)
    end

    pcall(function() print('[SilentAim][RayHook] Installed raycast hooks') end)
end

local RayHookUseAssignment = false
if RayHookUseAssignment then
    local ok_install_rays, install_err = pcall(InstallRaycastHooks)
    if not ok_install_rays then pcall(function() print('[SilentAim][RayHook] InstallRaycastHooks failed: '..tostring(install_err)) end) end
else
    pcall(function() print('[SilentAim][RayHook] Assignment-based Workspace hooks are disabled; using namecall interception only') end)
end

local function ScanAndWrapRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(WrapRemote, obj)
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(WrapRemote, obj)
        end
    end
end

local function EnableRemoteFallback()
    if RemoteFallbackEnabled then return end
    RemoteFallbackEnabled = true
    ScanAndWrapRemotes()
    remoteScanConn = ReplicatedStorage.DescendantAdded:Connect(function(desc)
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            pcall(WrapRemote, desc)
        end
    end)
    print("[SilentAim] Remote fallback enabled")
end

local function DisableRemoteFallback()
    if not RemoteFallbackEnabled then return end
    RemoteFallbackEnabled = false
    if remoteScanConn and remoteScanConn.Connected then remoteScanConn:Disconnect() end

    -- Restore originals
    for remote, orig in pairs(RemoteFallbackOriginals) do
        pcall(function()
            if orig.FireServer then remote.FireServer = orig.FireServer end
            if orig.InvokeServer then remote.InvokeServer = orig.InvokeServer end
        end)
    end

    table.clear(RemoteFallbackOriginals)
    table.clear(RemoteFallbackWrapped)
    print("[SilentAim] Remote fallback disabled")
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
    
    -- Corner Lines (12 lines for 3D boxes, 8 for 2D corner boxes)
    for i = 1, 12 do
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
            if key == "Highlight" and obj then
                obj:Destroy()
            elseif type(obj) == "table" then
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
    
    -- Update hold-mode bind indicators on key press
    for _, opt in pairs(library.options) do
        if opt and opt.class == 'bind' and opt.mode == 'hold' and opt.bind ~= 'none' then
            if input.KeyCode == opt.bind or input.UserInputType == opt.bind then
                if opt.indicatorValue and not opt.noindicator then
                    opt.indicatorValue:SetValue('true')
                    opt.indicatorValue:SetEnabled(true)
                end
            end
        end
    end
    
    -- Aimbot Key
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = true
    end

    -- Mouse Left Click => capture namecall args for debugging when silent aim active
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if SilentAimData and RemoteFallbackEnabled then
            VerboseNamecallCapture = 8
            print('[SilentAim] Verbose capture enabled for next remote calls (8) - shoot once or twice')
        end
    end

    -- Also watch the legacy Mouse.Button1Down (some games process InputBegan as gameProcessed)
    if Mouse then
        pcall(function()
            if not Connections.MouseButton1Down then
                Connections.MouseButton1Down = Mouse.Button1Down:Connect(function()
                    if SilentAimData and (RemoteFallbackEnabled or (VerboseNamecallCapture and VerboseNamecallCapture > 0)) then
                        VerboseNamecallCapture = 12
                        FullNamecallDump = math.max(FullNamecallDump, 50)
                        ForceReplaceCount = math.max(ForceReplaceCount, 6)
                        pcall(function()
                            print('[SilentAim] Verbose capture enabled via Mouse.Button1Down (12) - shoot once or twice')
                            print('[SilentAim] Also enabled FullNamecallDump=50 and ForceReplaceCount=6 for deeper tracing')
                            print('[SilentAim] Mouse.Button1Down stack: '..debug.traceback('', 2))
                        end)
                    end
                end)
            end
        end)
    end
    
    -- Silent Aim Key
    local silentBind = library.flags["Silent_Aim_Key"]
    if (silentBind and input.KeyCode == silentBind) or (input.KeyCode == Enum.KeyCode.C and not silentBind) then
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
    -- Update hold-mode bind indicators on key release
    for _, opt in pairs(library.options) do
        if opt and opt.class == 'bind' and opt.mode == 'hold' and opt.bind ~= 'none' then
            if input.KeyCode == opt.bind or input.UserInputType == opt.bind then
                if opt.indicatorValue and not opt.noindicator then
                    opt.indicatorValue:SetValue('false')
                    opt.indicatorValue:SetEnabled(true)
                end
            end
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAimKeyHeld = false
    end
    local silentBind = library.flags["Silent_Aim_Key"]
    if (silentBind and input.KeyCode == silentBind) or (input.KeyCode == Enum.KeyCode.C and not silentBind) then
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
    
    -- Optionally force silent aim for testing
    if library.flags["Silent_Force_Active"] then
        IsSilentAimKeyHeld = true
    end

    UpdateSilentAimTarget()

    -- Remote fallback toggle
    if library.flags["Silent_Remote_Fallback"] then
        EnableRemoteFallback()
    else
        DisableRemoteFallback()
    end

    -- Update debug label if present
    if library.flags["Silent_Debug_Label"] ~= nil then
        -- Throttled notifications to avoid spamming
        if SilentAimActiveIndicator then
            if not SilentAimLastNotify or (tick() - SilentAimLastNotify) > 1 then
                library:SendNotification("Silent Aim active: " .. (SilentAimLastDebug or "locked"), 1, Color3.fromRGB(0,255,0))
                SilentAimLastNotify = tick()
            end
        else
            -- Notify once on deactivation
            if SilentAimPrevActive then
                library:SendNotification("Silent Aim inactive", 1, Color3.fromRGB(255,100,100))
                SilentAimPrevActive = false
                SilentAimLastNotify = nil
            end
        end

        -- Update the visible indicator we created in place of AddLabel
        if library.silentDebugIndicator then
            library.silentDebugIndicator:SetValue(SilentAimActiveIndicator and 'Active' or 'Inactive')
            library.silentDebugIndicator:SetEnabled(true)
        end
    end

    -- store prev state
    SilentAimPrevActive = SilentAimActiveIndicator or SilentAimPrevActive

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
            
        elseif style == "T-Shape" then
            -- Horizontal line (top bar of T)
            local hFrom = Vector2.new(screenCenter.X - size, screenCenter.Y - gap)
            local hTo = Vector2.new(screenCenter.X + size, screenCenter.Y - gap)
            
            -- Vertical line (stem of T, going down)
            local vFrom = Vector2.new(screenCenter.X, screenCenter.Y - gap)
            local vTo = Vector2.new(screenCenter.X, screenCenter.Y + size + gap)
            
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
                for i = 1, 12 do esp.Corners[i].Visible = false end
                
                if showBox then
                    if boxType == "2D" then
                        local showOutline = library.flags["ESP_Box_Outline"] or false
                        
                        if showOutline then
                            esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                            esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                            esp.BoxOutline.Visible = true
                        end
                        
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
                    elseif boxType == "3D" then
                        -- 3D Box rendering using actual character dimensions
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local size = hrp.Size
                            local cf = hrp.CFrame
                            
                            -- Calculate 8 corners of the 3D box
                            local corners3D = {
                                cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
                                cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
                                cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
                                cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
                                cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                                cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
                                cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                                cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)
                            }
                            
                            -- Project 3D corners to 2D screen space
                            local corners2D = {}
                            for i, corner in ipairs(corners3D) do
                                local screenPos, visible = camera:WorldToViewportPoint(corner.Position)
                                corners2D[i] = Vector2.new(screenPos.X, screenPos.Y)
                            end
                            
                            -- Draw lines connecting the corners to form a 3D box
                            local connections = {{1,2},{2,4},{4,3},{3,1},{5,6},{6,8},{8,7},{7,5},{1,5},{2,6},{3,7},{4,8}}
                            
                            for i = 1, math.min(#connections, 8) do
                                local conn = connections[i]
                                if corners2D[conn[1]] and corners2D[conn[2]] then
                                    esp.Corners[i].From = corners2D[conn[1]]
                                    esp.Corners[i].To = corners2D[conn[2]]
                                    esp.Corners[i].Color = boxColor
                                    esp.Corners[i].Visible = true
                                end
                            end
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
                
                -- Chams/Highlight
                if library.flags["ESP_Chams"] then
                    if not esp.Highlight then
                        esp.Highlight = Instance.new("Highlight")
                        esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    esp.Highlight.Adornee = character
                    local chamsColor = library.flags["ESP_Chams_Color"] or Color3.fromRGB(255, 100, 100)
                    local chamsOpacity = (library.flags["ESP_Chams_Transparency"] or 80) / 100
                    local chamsStyle = library.flags["ESP_Chams_Style"] or "Fill"
                    
                    esp.Highlight.FillColor = chamsColor
                    esp.Highlight.OutlineColor = chamsColor
                    
                    if chamsStyle == "Fill" then
                        esp.Highlight.FillTransparency = 1 - chamsOpacity
                        esp.Highlight.OutlineTransparency = 1
                    elseif chamsStyle == "Outline" then
                        esp.Highlight.FillTransparency = 1
                        esp.Highlight.OutlineTransparency = 1 - chamsOpacity
                    elseif chamsStyle == "Both" then
                        esp.Highlight.FillTransparency = 1 - chamsOpacity
                        esp.Highlight.OutlineTransparency = 0
                    elseif chamsStyle == "Glow" then
                        esp.Highlight.FillTransparency = 1 - (chamsOpacity * 0.3)
                        esp.Highlight.OutlineTransparency = 0
                    elseif chamsStyle == "Pulse" then
                        local pulse = (math.sin(tick() * 3) + 1) / 2
                        esp.Highlight.FillTransparency = 1 - (chamsOpacity * pulse)
                        esp.Highlight.OutlineTransparency = 1 - pulse
                    elseif chamsStyle == "Rainbow" then
                        local hue = (tick() * 0.5) % 1
                        local rainbowColor = Color3.fromHSV(hue, 1, 1)
                        esp.Highlight.FillColor = rainbowColor
                        esp.Highlight.OutlineColor = Color3.fromHSV((hue + 0.1) % 1, 1, 1)
                        esp.Highlight.FillTransparency = 1 - chamsOpacity
                        esp.Highlight.OutlineTransparency = 0
                    end
                    
                    esp.Highlight.Enabled = true
                    esp.Highlight.Parent = character
                else
                    if esp.Highlight then
                        esp.Highlight.Enabled = false
                    end
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
                if esp.Highlight then esp.Highlight.Enabled = false end
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
            if esp.Highlight then esp.Highlight.Enabled = false end
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
            
            if moveDirection.Magnitude > 0 then
                bodyVelocity.Velocity = moveDirection.Unit * speed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
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
    Lighting.Brightness = OriginalBrightness or 1
    Lighting.GlobalShadows = OriginalGlobalShadows or true
    Lighting.FogEnd = OriginalFogEnd or 1000
    Lighting.ClockTime = OriginalClockTime or 14
    
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
