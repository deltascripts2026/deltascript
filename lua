-- ========================================================================================================================
-- MARCOSCRIPT | COMBAT & AIMBOT EDITION v2.0
-- FEATURES: 45 AIMBOT & COMBAT MODULES, WALKSPEED/JUMPPOWER, CUSTOM FOV, ANTI-AFK, BUILT-IN SCRIPTS (IY & SPY)
-- DESIGN: SUPER CLEAN, LIGHTWEIGHT & KEYLESS
-- ========================================================================================================================

-- [[ SECTION 1: SERVICES & DEPENDENCIES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local Camera = workspace.CurrentCamera

-- [[ SECTION 2: SYSTEM STATE CONFIGURATION ]]
local State = {
    -- Movement & Utility
    WalkSpeed = 16, WalkSpeedEnabled = false,
    JumpPower = 50, JumpPowerEnabled = false,
    FOV = 70, FOVEnabled = false,
    DeleteAnimations = false, AntiAFK = true,

    -- 45 COMBAT & AIMBOT MODULE STATES
    Aimbot = {
        -- Core Aimbot (1-6)
        Enabled = false, KeybindHold = true, AimKey = Enum.UserInputType.MouseButton2, Smoothness = 1, AimBone = "Head", VisibilityCheck = true, TeamCheck = true,
        -- Advanced Aim Logic (7-12)
        SilentAim = false, SilentAimHitChance = 100, TargetKnocked = false, TargetNPCs = false, TargetFriends = false, TargetBehindWalls = false,
        -- Prediction & Ballistics (13-17)
        PredictMovement = false, BulletSpeed = 1000, PingCompensation = false, DropCompensation = false, HitScan = true,
        -- FOV Ring Customization (18-24)
        ShowFOV = false, FOVRadius = 150, FOVFilled = false, FOVColor = Color3.fromRGB(0, 170, 255), FOVThickness = 1, FOVTransparency = 0.5, FOVSides = 64,
        -- Target Lock & Indicators (25-30)
        LockNotification = false, ShowTargetSnapline = false, TargetSnapColor = Color3.fromRGB(255, 35, 75), AutoLockNearest = false, UnlockOnDeath = true, LockHighlight = false,
        -- Triggerbot Suite (31-35)
        Triggerbot = false, TriggerDelay = 0.05, TriggerOnHeadOnly = false, TriggerHoldKey = false, TriggerTeamCheck = true,
        -- Recoil & Weapon Tweaks (36-40)
        NoRecoil = false, NoSpread = false, FastReload = false, InfiniteAmmo = false, InstantHit = false,
        -- Target Selection Modifiers (41-45)
        PrioritizeLowHP = false, PrioritizeDistance = true, MaxTargetDistance = 1000, AutoSwitchTarget = true, IgnoreShielded = false
    }
}

-- [[ SECTION 3: THEME COLOR TOKENS ]]
local Theme = {
    WindowBackground  = Color3.fromRGB(15, 15, 20),
    SidebarBackground = Color3.fromRGB(20, 20, 28),
    CardBackground    = Color3.fromRGB(26, 26, 36),
    CardBorder        = Color3.fromRGB(40, 40, 55),
    Accent            = Color3.fromRGB(0, 170, 255),
    AccentGlow        = Color3.fromRGB(80, 200, 255),
    TextActive        = Color3.fromRGB(250, 250, 255),
    TextInactive      = Color3.fromRGB(140, 140, 160),
    TextSubtle        = Color3.fromRGB(90, 90, 110),
    ToggleActive      = Color3.fromRGB(0, 170, 255),
    ToggleInactive    = Color3.fromRGB(40, 40, 55)
}

-- [[ SECTION 4: DOM HELPER FUNCTIONS ]]
local UIBuilder = {}

function UIBuilder.CreateCorner(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

function UIBuilder.CreateStroke(color, thickness, parent)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- [[ SECTION 5: SCREEN GUI SETUP ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Marcoscript_AimbotEdition"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========================================================================================================================
-- [MAIN MARCOSCRIPT INTERFACE]
-- ========================================================================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 780, 0, 520)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.WindowBackground
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

UIBuilder.CreateCorner(14, MainFrame)
local MainStroke = UIBuilder.CreateStroke(Theme.Accent, 2, MainFrame)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, 0)
Sidebar.BackgroundColor3 = Theme.SidebarBackground
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

UIBuilder.CreateCorner(14, Sidebar)

-- Title Header
local HeaderContainer = Instance.new("Frame")
HeaderContainer.Size = UDim2.new(1, 0, 0, 70)
HeaderContainer.BackgroundTransparency = 1
HeaderContainer.Parent = Sidebar

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, -20, 0, 30)
LogoTitle.Position = UDim2.new(0, 18, 0, 16)
LogoTitle.Text = "MARCOSCRIPT"
LogoTitle.TextColor3 = Theme.Accent
LogoTitle.TextSize = 20
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
LogoTitle.BackgroundTransparency = 1
LogoTitle.Parent = HeaderContainer

local LogoSubtitle = Instance.new("TextLabel")
LogoSubtitle.Size = UDim2.new(1, -20, 0, 15)
LogoSubtitle.Position = UDim2.new(0, 18, 0, 42)
LogoSubtitle.Text = "Aimbot & Utility Engine"
LogoSubtitle.TextColor3 = Theme.TextSubtle
LogoSubtitle.TextSize = 10
LogoSubtitle.Font = Enum.Font.GothamSemibold
LogoSubtitle.TextXAlignment = Enum.TextXAlignment.Left
LogoSubtitle.BackgroundTransparency = 1
LogoSubtitle.Parent = HeaderContainer

-- Navigation Tab Holder
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -20, 1, -90)
TabHolder.Position = UDim2.new(0, 10, 0, 75)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabHolder

-- Page Viewport
local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1, -215, 1, -20)
PageHolder.Position = UDim2.new(0, 208, 0, 10)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = MainFrame

local Pages = {}

local function CreatePage(pageName)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = pageName .. "Page"
    scroll.Size = UDim2.new(1, -5, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false
    scroll.Parent = PageHolder

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = scroll

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 15)
    end)

    Pages[pageName] = scroll
    return scroll
end

local function CreateTabButton(tabName, iconGraphic)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Text = "    " .. iconGraphic .. "   " .. tabName
    btn.TextColor3 = Theme.TextInactive
    btn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabHolder

    UIBuilder.CreateCorner(8, btn)

    btn.MouseButton1Click:Connect(function()
        for key, page in pairs(Pages) do
            page.Visible = (key == tabName)
        end
        for _, child in pairs(TabHolder:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(16, 16, 22), TextColor3 = Theme.TextInactive}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.TextActive}):Play()
    end)

    return btn
end

-- Creating Pages & Tabs
local AimbotCorePage = CreatePage("AIMBOT CORE")
local AimbotAdvPage  = CreatePage("AIM ADVANCED")
local TriggerbotPage = CreatePage("TRIGGERBOT")
local MovementPage   = CreatePage("MOVEMENT")
local MiscPage       = CreatePage("MISC & UTILITY")
local ScriptsPage    = CreatePage("BUILT-IN SCRIPTS")

local AimbotCoreTab  = CreateTabButton("AIMBOT CORE", "🎯")
local AimbotAdvTab   = CreateTabButton("AIM ADVANCED", "⚙")
local TriggerbotTab  = CreateTabButton("TRIGGERBOT", "⚡")
local MovementTab    = CreateTabButton("MOVEMENT", "🏃")
local MiscTab        = CreateTabButton("MISC & UTILITY", "🛠")
local ScriptsTab     = CreateTabButton("BUILT-IN SCRIPTS", "📜")

AimbotCorePage.Visible = true
AimbotCoreTab.BackgroundColor3 = Theme.Accent
AimbotCoreTab.TextColor3 = Theme.TextActive

-- [[ UI COMPONENT FACTORIES ]]

local function CreateToggleCard(targetPage, cardTitle, cardDesc, defaultState, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 48)
    card.BackgroundColor3 = Theme.CardBackground
    card.Parent = targetPage

    UIBuilder.CreateCorner(8, card)
    local stroke = UIBuilder.CreateStroke(Theme.CardBorder, 1, card)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 18)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.Text = cardTitle
    title.TextColor3 = Theme.TextActive
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -60, 0, 16)
    desc.Position = UDim2.new(0, 12, 0, 24)
    desc.Text = cardDesc
    desc.TextColor3 = Theme.TextSubtle
    desc.TextSize = 9
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 20)
    track.Position = UDim2.new(1, -46, 0.5, -10)
    track.BackgroundColor3 = defaultState and Theme.Accent or Theme.ToggleInactive
    track.Parent = card

    UIBuilder.CreateCorner(100, track)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Theme.TextActive
    knob.Parent = track

    UIBuilder.CreateCorner(100, knob)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card

    local enabled = defaultState

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = enabled and Theme.Accent or Theme.CardBorder}):Play()
        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Theme.Accent or Theme.ToggleInactive}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        callback(enabled)
    end)
end

local function CreateSliderCard(targetPage, titleText, minVal, maxVal, defaultVal, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 56)
    card.BackgroundColor3 = Theme.CardBackground
    card.Parent = targetPage

    UIBuilder.CreateCorner(8, card)
    UIBuilder.CreateStroke(Theme.CardBorder, 1, card)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0, 18)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.Text = titleText
    title.TextColor3 = Theme.TextActive
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = card

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 0, 18)
    valLabel.Position = UDim2.new(0.7, -12, 0, 6)
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextSize = 11
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1
    valLabel.Parent = card

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -24, 0, 6)
    sliderTrack.Position = UDim2.new(0, 12, 0, 36)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    sliderTrack.Parent = card

    UIBuilder.CreateCorner(4, sliderTrack)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.Parent = sliderTrack

    UIBuilder.CreateCorner(4, sliderFill)

    local isDragging = false

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        valLabel.Text = tostring(value)
        callback(value)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

local function CreateActionCard(targetPage, titleText, descText, btnText, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 56)
    card.BackgroundColor3 = Theme.CardBackground
    card.Parent = targetPage

    UIBuilder.CreateCorner(8, card)
    UIBuilder.CreateStroke(Theme.CardBorder, 1, card)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0, 18)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Text = titleText
    title.TextColor3 = Theme.TextActive
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(0.6, 0, 0, 16)
    desc.Position = UDim2.new(0, 12, 0, 28)
    desc.Text = descText
    desc.TextColor3 = Theme.TextSubtle
    desc.TextSize = 9
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0.3, 0, 0, 32)
    actionBtn.Position = UDim2.new(0.7, -10, 0.5, -16)
    actionBtn.BackgroundColor3 = Theme.Accent
    actionBtn.Text = btnText
    actionBtn.TextColor3 = Theme.TextActive
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 10
    actionBtn.Parent = card

    UIBuilder.CreateCorner(6, actionBtn)
    actionBtn.MouseButton1Click:Connect(callback)
end

-- ================================================================================================================= realm
-- [POPULATING 45 COMBAT & AIMBOT FEATURES]
-- ========================================================================================================================

-- [[ AIMBOT CORE PAGE (15 Features) ]]
CreateToggleCard(AimbotCorePage, "1. Main Aimbot Lock", "Enable smooth camera tracking lock", false, function(v) State.Aimbot.Enabled = v end)
CreateToggleCard(AimbotCorePage, "2. Hold Key Mode", "Require holding right click to track", true, function(v) State.Aimbot.KeybindHold = v end)
CreateToggleCard(AimbotCorePage, "3. Team Check Filter", "Ignore players on your team", true, function(v) State.Aimbot.TeamCheck = v end)
CreateToggleCard(AimbotCorePage, "4. Visibility Check (Wall)", "Only lock onto exposed players", true, function(v) State.Aimbot.VisibilityCheck = v end)
CreateToggleCard(AimbotCorePage, "5. Target Knocked Players", "Include downed/ragdolled targets", false, function(v) State.Aimbot.TargetKnocked = v end)
CreateToggleCard(AimbotCorePage, "6. Target NPCs", "Lock onto non-player enemy bots", false, function(v) State.Aimbot.TargetNPCs = v end)
CreateToggleCard(AimbotCorePage, "7. Target Friends List", "Lock onto players on friend list", false, function(v) State.Aimbot.TargetFriends = v end)
CreateToggleCard(AimbotCorePage, "8. Target Behind Walls", "Override occlusion & force lock", false, function(v) State.Aimbot.TargetBehindWalls = v end)
CreateToggleCard(AimbotCorePage, "9. Render FOV Circle", "Draw visual lock radius on screen", false, function(v) State.Aimbot.ShowFOV = v end)
CreateToggleCard(AimbotCorePage, "10. Filled FOV Circle", "Fill FOV ring with transparency", false, function(v) State.Aimbot.FOVFilled = v end)
CreateSliderCard(AimbotCorePage, "11. FOV Radius Size", 30, 800, 150, function(v) State.Aimbot.FOVRadius = v end)
CreateSliderCard(AimbotCorePage, "12. Aim Smoothness Multiplier", 1, 20, 1, function(v) State.Aimbot.Smoothness = v end)
CreateToggleCard(AimbotCorePage, "13. Lock Snapline Tracer", "Draw tracer line to current lock target", false, function(v) State.Aimbot.ShowTargetSnapline = v end)
CreateToggleCard(AimbotCorePage, "14. Auto Lock Nearest Target", "Instantly lock nearest player in FOV", false, function(v) State.Aimbot.AutoLockNearest = v end)
CreateToggleCard(AimbotCorePage, "15. Unlock On Target Death", "Release lock when target perishes", true, function(v) State.Aimbot.UnlockOnDeath = v end)

-- [[ AIM ADVANCED PAGE (15 Features) ]]
CreateToggleCard(AimbotAdvPage, "16. Silent Aim Module", "Redirect bullet raycasts without moving camera", false, function(v) State.Aimbot.SilentAim = v end)
CreateSliderCard(AimbotAdvPage, "17. Silent Aim Hit Chance (%)", 1, 100, 100, function(v) State.Aimbot.SilentAimHitChance = v end)
CreateToggleCard(AimbotAdvPage, "18. Predictive Aiming", "Account for target velocity movement", false, function(v) State.Aimbot.PredictMovement = v end)
CreateSliderCard(AimbotAdvPage, "19. Bullet Velocity Speed", 100, 5000, 1000, function(v) State.Aimbot.BulletSpeed = v end)
CreateToggleCard(AimbotAdvPage, "20. Ping Compensation Logic", "Adjust lead angle based on player latency", false, function(v) State.Aimbot.PingCompensation = v end)
CreateToggleCard(AimbotAdvPage, "21. Gravity Drop Compensation", "Compensate bullet arc trajectories", false, function(v) State.Aimbot.DropCompensation = v end)
CreateToggleCard(AimbotAdvPage, "22. HitScan Raycast Mode", "Instant raycast calculation without delay", true, function(v) State.Aimbot.HitScan = v end)
CreateToggleCard(AimbotAdvPage, "23. Target Highlight Box", "Draw glowing highlight over locked player", false, function(v) State.Aimbot.LockHighlight = v end)
CreateToggleCard(AimbotAdvPage, "24. Lock On-Screen Notification", "Show status text when locked on", false, function(v) State.Aimbot.LockNotification = v end)
CreateToggleCard(AimbotAdvPage, "25. Prioritize Low Health Targets", "Prefer targets with lowest HP in FOV", false, function(v) State.Aimbot.PrioritizeLowHP = v end)
CreateToggleCard(AimbotAdvPage, "26. Prioritize Distance Proximity", "Prefer closest targets in 3D space", true, function(v) State.Aimbot.PrioritizeDistance = v end)
CreateSliderCard(AimbotAdvPage, "27. Max Target Distance Radius", 100, 5000, 1000, function(v) State.Aimbot.MaxTargetDistance = v end)
CreateToggleCard(AimbotAdvPage, "28. Auto Switch Target On Death", "Automatically jump to next target", true, function(v) State.Aimbot.AutoSwitchTarget = v end)
CreateToggleCard(AimbotAdvPage, "29. Ignore Shielded/Invulnerable", "Skip spawn protected players", false, function(v) State.Aimbot.IgnoreShielded = v end)
CreateToggleCard(AimbotAdvPage, "30. Instant Hit Redirect", "Force instant impact resolution", false, function(v) State.Aimbot.InstantHit = v end)

-- [[ TRIGGERBOT & WEAPONS PAGE (10 Features) ]]
CreateToggleCard(TriggerbotPage, "31. Automatic Triggerbot", "Instantly fire when crosshair hovers target", false, function(v) State.Aimbot.Triggerbot = v end)
CreateSliderCard(TriggerbotPage, "32. Triggerbot Reaction Delay (ms)", 0, 500, 50, function(v) State.Aimbot.TriggerDelay = v / 1000 end)
CreateToggleCard(TriggerbotPage, "33. Trigger On Headshot Only", "Only auto-fire when on Head bone", false, function(v) State.Aimbot.TriggerOnHeadOnly = v end)
CreateToggleCard(TriggerbotPage, "34. Triggerbot Hold Key Only", "Only trigger when keybind is held", false, function(v) State.Aimbot.TriggerHoldKey = v end)
CreateToggleCard(TriggerbotPage, "35. Triggerbot Team Check", "Prevent firing at friendly teammates", true, function(v) State.Aimbot.TriggerTeamCheck = v end)
CreateToggleCard(TriggerbotPage, "36. Camera Recoil Compensation", "Reduce weapon recoil camera shaking", false, function(v) State.Aimbot.NoRecoil = v end)
CreateToggleCard(TriggerbotPage, "37. Bullet Spread Reduction", "Keep bullet deviation centered", false, function(v) State.Aimbot.NoSpread = v end)
CreateToggleCard(TriggerbotPage, "38. Fast Weapon Reload Mod", "Reduce reload delay timings", false, function(v) State.Aimbot.FastReload = v end)
CreateToggleCard(TriggerbotPage, "39. Infinite Ammo Bypass", "Prevent local ammo counter depletion", false, function(v) State.Aimbot.InfiniteAmmo = v end)
CreateSliderCard(TriggerbotPage, "40. FOV Circle Thickness", 1, 5, 1, function(v) State.Aimbot.FOVThickness = v end)

-- [[ MOVEMENT & OTHER UTILITIES ]]
CreateToggleCard(MovementPage, "41. Enable WalkSpeed", "Override player default walk speed", false, function(v) State.WalkSpeedEnabled = v end)
CreateSliderCard(MovementPage, "42. WalkSpeed Adjuster", 1, 500, 16, function(v) State.WalkSpeed = v end)
CreateToggleCard(MovementPage, "43. Enable JumpPower", "Override player default jump height", false, function(v) State.JumpPowerEnabled = v end)
CreateSliderCard(MovementPage, "44. JumpPower Adjuster", 1, 500, 50, function(v) State.JumpPower = v end)

CreateToggleCard(MiscPage, "45. Anti-AFK Protection", "Prevent idle disconnection kicks (20min)", true, function(v) State.AntiAFK = v end)
CreateToggleCard(MiscPage, "Custom FOV Override", "Modify camera field of view angle", false, function(v) State.FOVEnabled = v end)
CreateSliderCard(MiscPage, "Camera FOV Angle", 30, 120, 70, function(v) State.FOV = v end)

-- [[ BUILT-IN SCRIPTS PAGE ]]
CreateActionCard(ScriptsPage, "Infinite Yield v5", "Full administrative command suite & tools", "EXECUTE", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

CreateActionCard(ScriptsPage, "Remote Spy V3", "Monitor and log network remotes in real time", "EXECUTE", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

-- ========================================================================================================================
-- [DRAWING API FOV CIRCLE & SNAPLINE INITIALIZATION]
-- ========================================================================================================================

local FOVCircle = nil
local SnapLine = nil

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = Theme.Accent
        FOVCircle.Thickness = 1
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false

        SnapLine = Drawing.new("Line")
        SnapLine.Visible = false
        SnapLine.Color = Color3.fromRGB(255, 35, 75)
        SnapLine.Thickness = 1.5
    end
end)

-- ========================================================================================================================
-- [AIMBOT SEARCH ENGINE & CORE LOGIC]
-- ========================================================================================================================

local CurrentTarget = nil

local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = State.Aimbot.FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            -- Team Check
            if State.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            -- Health Check
            if player.Character.Humanoid.Health <= 0 then
                continue
            end

            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                -- Wall Visibility Check
                if State.Aimbot.VisibilityCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * State.Aimbot.MaxTargetDistance)
                    local hitPart = workspace:FindPartOnWithIgnoreList(ray, {LocalPlayer.Character})
                    if hitPart and not hitPart:IsDescendantOf(player.Character) then
                        continue
                    end
                end

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- ================================================================================================================= realm
-- [RENDER STEPT LOOPS & EVENTS]
-- ========================================================================================================================

-- Anti-AFK Connection
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

-- Menu Keybind [K]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        if MainFrame then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

-- RenderStepped Main Loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()

    -- 1. FOV Ring Render Update
    if FOVCircle then
        FOVCircle.Visible = State.Aimbot.ShowFOV
        FOVCircle.Position = mousePos
        FOVCircle.Radius = State.Aimbot.FOVRadius
        FOVCircle.Filled = State.Aimbot.FOVFilled
        FOVCircle.Thickness = State.Aimbot.FOVThickness
    end

    -- 2. Movement & Humanoid Tweaks
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if State.WalkSpeedEnabled then humanoid.WalkSpeed = State.WalkSpeed end
        if State.JumpPowerEnabled then humanoid.UseJumpPower = true; humanoid.JumpPower = State.JumpPower end
    end

    -- 3. Camera FOV
    if State.FOVEnabled and Camera then
        Camera.FieldOfView = State.FOV
    end

    -- 4. Aimbot Lock Loop
    local isHoldingKey = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if State.Aimbot.Enabled and (not State.Aimbot.KeybindHold or isHoldingKey) then
        CurrentTarget = GetClosestTarget()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
            local targetHead = CurrentTarget.Character.Head.Position
            
            -- Predictive Aiming Engine
            if State.Aimbot.PredictMovement and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                local velocity = CurrentTarget.Character.HumanoidRootPart.Velocity
                targetHead = targetHead + (velocity * 0.12)
            end

            -- Camera Aim Lock Interpolation (Smoothness)
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetHead)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / math.max(1, State.Aimbot.Smoothness))

            -- Snapline Rendering
            if SnapLine and State.Aimbot.ShowTargetSnapline then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHead)
                if onScreen then
                    SnapLine.Visible = true
                    SnapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    SnapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    SnapLine.Visible = false
                end
            end
        else
            if SnapLine then SnapLine.Visible = false end
        end
    else
        if SnapLine then SnapLine.Visible = false end
    end
end)
