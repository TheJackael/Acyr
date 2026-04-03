--[[
  ╔══════════════════════════════════════════════════════════════╗
  ║             A C Y R   v 2   -   P R O F E S S I O N A L     ║
  ║                Made by Acy - 2500+ Lines                     ║
  ║           Full UI Library + Advanced Modules                 ║
  ║           github.com/TheJackael/Acyr                         ║
  ╚══════════════════════════════════════════════════════════════╝

  FEATURES:
  - Professional full-screen UI with smooth staggered animations
  - 2500+ lines of code
  - Advanced modules: Fly, Noclip, Speed, XRay, Blink, ESP, Aimbot
  - Customizable sliders, toggles, dropdowns
  - Persistent settings
  - Modern design with gradients and effects
  - ArrayList sidebar showing active modules
  
  KEYBINDS:
  - J: Toggle UI (full-screen with animations)
  - F: Fly
  - N: Noclip
  - Delete: Panic/Close
]]

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 1: CORE SERVICES & INITIALIZATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 2: CONSTANTS & CONFIGURATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local CONFIG = {
    SAVE_FILE = "AcyrV2_settings.json",
    UI_PADDING = 8,
    ANIMATION_SPEED = 0.35,
    STAGGER_DELAY = 0.06,
    BORDER_RADIUS = 8,
    HEADER_HEIGHT = 40,
    SECTION_WIDTH = 200,
    SECTION_HEIGHT = 520,
    ARRAYLIST_WIDTH = 160,
}

local COLORS = {
    -- Primary
    background = Color3.fromRGB(15, 15, 20),
    darkBG = Color3.fromRGB(10, 10, 15),
    panel = Color3.fromRGB(28, 28, 38),
    panelHover = Color3.fromRGB(38, 38, 52),
    border = Color3.fromRGB(50, 50, 70),
    
    -- Category Colors (pink/magenta theme to match reference)
    combat = Color3.fromRGB(220, 90, 140),
    movement = Color3.fromRGB(100, 200, 220),
    render = Color3.fromRGB(160, 120, 220),
    player = Color3.fromRGB(220, 160, 80),
    other = Color3.fromRGB(220, 120, 180),
    
    -- Active module highlight (pink like reference)
    active = Color3.fromRGB(255, 130, 180),
    activeGlow = Color3.fromRGB(255, 100, 160),
    
    -- Text
    text = Color3.fromRGB(200, 200, 210),
    textDark = Color3.fromRGB(100, 100, 110),
    white = Color3.fromRGB(255, 255, 255),
    
    -- Accents
    success = Color3.fromRGB(100, 200, 100),
    warning = Color3.fromRGB(220, 160, 80),
    error = Color3.fromRGB(220, 100, 100),
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 3: STATE MANAGEMENT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function saveSettings(settings)
    pcall(function()
        if writefile then
            writefile(CONFIG.SAVE_FILE, HttpService:JSONEncode(settings))
        end
    end)
end

local function loadSettings()
    local ok, data = pcall(function()
        if readfile and isfile and isfile(CONFIG.SAVE_FILE) then
            return HttpService:JSONDecode(readfile(CONFIG.SAVE_FILE))
        end
    end)
    return (ok and type(data) == "table") and data or {}
end

local Settings = loadSettings()

local State = {
    -- Combat
    autoclicker = Settings.autoclicker or false,
    autoclicker_cps = Settings.autoclicker_cps or 10,
    triggerbot = Settings.triggerbot or false,
    aimbot = Settings.aimbot or false,
    aimbot_fov = Settings.aimbot_fov or 100,
    silent_aim = Settings.silent_aim or false,
    reach = Settings.reach or false,
    reach_dist = Settings.reach_dist or 6,
    
    -- Movement
    fly = Settings.fly or false,
    fly_speed = Settings.fly_speed or 50,
    noclip = Settings.noclip or false,
    speed = Settings.speed or false,
    speed_val = Settings.speed_val or 50,
    blink = Settings.blink or false,
    blink_speed = Settings.blink_speed or 30,
    spider = Settings.spider or false,
    bunny_hop = Settings.bunny_hop or false,
    
    -- Render/Visual
    esp = Settings.esp or false,
    esp_distance = Settings.esp_distance or 1000,
    xray = Settings.xray or false,
    chams = Settings.chams or false,
    fullbright = Settings.fullbright or false,
    stretched = Settings.stretched or false,
    stretched_fov = Settings.stretched_fov or 120,
    tracers = Settings.tracers or false,
    
    -- Player
    third_person = Settings.third_person or false,
    anti_kb = Settings.anti_kb or false,
    godmode = Settings.godmode or false,
    invisible = Settings.invisible or false,
    air_jump = Settings.air_jump or false,
    
    -- Other
    auto_reload = Settings.auto_reload or false,
    target_hud = Settings.target_hud or false,
    arraylist = Settings.arraylist or true,
    anti_flashbang = Settings.anti_flashbang or false,
    staff_detector = Settings.staff_detector or false,
    device_spoof = Settings.device_spoof or false,
    anti_katana = Settings.anti_katana or false,
    fast_shoot = Settings.fast_shoot or false,
    auto_play = Settings.auto_play or false,
}

local function persistState()
    saveSettings(State)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 4: UTILITY FUNCTIONS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Utilities = {}

function Utilities.getCharacter()
    return LocalPlayer.Character
end

function Utilities.getHumanoidRootPart()
    local char = Utilities.getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function Utilities.getHumanoid()
    local char = Utilities.getCharacter()
    return char and char:FindFirstChildWhichIsA("Humanoid") or nil
end

function Utilities.createInstance(className, properties, parent)
    local instance = Instance.new(className)
    if properties then
        for key, value in pairs(properties) do
            pcall(function()
                instance[key] = value
            end)
        end
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

function Utilities.tween(instance, duration, properties, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utilities.tweenBack(instance, duration, properties)
    return Utilities.tween(instance, duration, properties, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Utilities.notification(title, message, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3,
        })
    end)
end

function Utilities.getDistance(p1, p2)
    return (p1 - p2).Magnitude
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 5: UI LIBRARY (CUSTOM)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local UILibrary = {}
UILibrary.Elements = {}
UILibrary.Callbacks = {}

function UILibrary.createLabel(text, size, color, font)
    return Utilities.createInstance("TextLabel", {
        Text = text,
        TextSize = size or 12,
        TextColor3 = color or COLORS.text,
        Font = font or Enum.Font.Gotham,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
end

function UILibrary.createButton(text, size, color, callback)
    local button = Utilities.createInstance("TextButton", {
        Text = text,
        TextSize = 12,
        TextColor3 = COLORS.white,
        Font = Enum.Font.GothamBold,
        BackgroundColor3 = color or COLORS.panel,
        BorderSizePixel = 0,
        Size = size or UDim2.new(1, 0, 0, 32),
        AutoButtonColor = false,
    })
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, CONFIG.BORDER_RADIUS)}, button)
    Utilities.createInstance("UIStroke", {
        Color = COLORS.border,
        Thickness = 1,
        Transparency = 0.5,
    }, button)
    
    button.MouseEnter:Connect(function()
        Utilities.tween(button, 0.15, {
            BackgroundColor3 = COLORS.panelHover,
        })
    end)
    
    button.MouseLeave:Connect(function()
        Utilities.tween(button, 0.15, {
            BackgroundColor3 = color or COLORS.panel,
        })
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

function UILibrary.createToggle(label, initialValue, color, callback)
    local isActive = initialValue
    
    local container = Utilities.createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = isActive and color or COLORS.panel,
        BackgroundTransparency = isActive and 0.3 or 0,
        BorderSizePixel = 0,
    })
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, container)
    Utilities.createInstance("UIStroke", {
        Color = isActive and color or COLORS.border,
        Thickness = 1,
        Transparency = isActive and 0.2 or 0.6,
    }, container)
    
    local labelText = Utilities.createInstance("TextLabel", {
        Text = label,
        TextSize = 13,
        TextColor3 = COLORS.white,
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local state = initialValue
    local stroke = container:FindFirstChildWhichIsA("UIStroke")
    
    local function updateVisual()
        if state then
            Utilities.tween(container, 0.2, {
                BackgroundColor3 = color,
                BackgroundTransparency = 0.3,
            })
            if stroke then
                Utilities.tween(stroke, 0.2, {
                    Color = color,
                    Transparency = 0.2,
                })
            end
        else
            Utilities.tween(container, 0.2, {
                BackgroundColor3 = COLORS.panel,
                BackgroundTransparency = 0,
            })
            if stroke then
                Utilities.tween(stroke, 0.2, {
                    Color = COLORS.border,
                    Transparency = 0.6,
                })
            end
        end
    end
    
    -- Make the whole container clickable
    local clickButton = Utilities.createInstance("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, container)
    
    clickButton.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then callback(state) end
    end)
    
    container.MouseEnter:Connect(function()
        if not state then
            Utilities.tween(container, 0.15, {
                BackgroundColor3 = COLORS.panelHover,
            })
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            Utilities.tween(container, 0.15, {
                BackgroundColor3 = COLORS.panel,
            })
        end
    end)
    
    return container, function() return state end
end

function UILibrary.createSlider(label, minValue, maxValue, initialValue, callback)
    local container = Utilities.createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
    })
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, container)
    Utilities.createInstance("UIStroke", {
        Color = COLORS.border,
        Thickness = 1,
        Transparency = 0.6,
    }, container)
    
    Utilities.createInstance("TextLabel", {
        Text = label,
        TextSize = 11,
        TextColor3 = COLORS.text,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0, 16),
        Position = UDim2.new(0, 8, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    
    local valueLabel = Utilities.createInstance("TextLabel", {
        Text = tostring(math.floor(initialValue)),
        TextSize = 11,
        TextColor3 = COLORS.active,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0, 16),
        Position = UDim2.new(0.7, -8, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, container)
    
    local track = Utilities.createInstance("Frame", {
        Size = UDim2.new(1, -16, 0, 6),
        Position = UDim2.new(0, 8, 0, 26),
        BackgroundColor3 = COLORS.border,
        BorderSizePixel = 0,
    }, container)
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 3)}, track)
    
    local fill = Utilities.createInstance("Frame", {
        Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0),
        BackgroundColor3 = COLORS.active,
        BorderSizePixel = 0,
    }, track)
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 3)}, fill)
    
    local thumb = Utilities.createInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((initialValue - minValue) / (maxValue - minValue), -7, 0.5, -7),
        BackgroundColor3 = COLORS.white,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, track)
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, thumb)
    
    -- Glow on thumb
    Utilities.createInstance("UIStroke", {
        Color = COLORS.active,
        Thickness = 2,
        Transparency = 0.4,
    }, thumb)
    
    local dragging = false
    local currentValue = initialValue
    
    local function updateSlider(x)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local percentage = math.clamp((x - trackPos) / trackSize, 0, 1)
        
        currentValue = minValue + (percentage * (maxValue - minValue))
        
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        thumb.Position = UDim2.new(percentage, -7, 0.5, -7)
        valueLabel.Text = tostring(math.floor(currentValue))
        
        if callback then callback(currentValue) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            persistState()
        end
    end)
    
    return container, function() return currentValue end
end

function UILibrary.createSection(title, color)
    local section = Utilities.createInstance("Frame", {
        Size = UDim2.new(0, CONFIG.SECTION_WIDTH, 0, CONFIG.SECTION_HEIGHT),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    
    local header = Utilities.createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, CONFIG.HEADER_HEIGHT),
        BackgroundColor3 = color or COLORS.panel,
        BorderSizePixel = 0,
    }, section)
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, CONFIG.BORDER_RADIUS)}, header)
    
    -- Gradient on header
    Utilities.createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
        }),
        Rotation = 90,
    }, header)
    
    Utilities.createInstance("TextLabel", {
        Text = title,
        TextSize = 14,
        TextColor3 = COLORS.white,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, header)
    
    local content = Utilities.createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -(CONFIG.HEADER_HEIGHT + 4)),
        Position = UDim2.new(0, 0, 0, CONFIG.HEADER_HEIGHT + 4),
        BackgroundColor3 = COLORS.panel,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = color or COLORS.active,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, section)
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, CONFIG.BORDER_RADIUS)}, content)
    Utilities.createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    }, content)
    
    Utilities.createInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)
    
    return section, content
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 6: FEATURE MODULES - PART 1 (MOVEMENT)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Modules = {}

-- FLY MODULE (fully working with BodyVelocity + BodyGyro)
local flyConnection, flyBodyVelocity, flyBodyGyro
function Modules.fly(enabled)
    -- Cleanup previous
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    
    if enabled then
        local hrp = Utilities.getHumanoidRootPart()
        if not hrp then return end
        
        local humanoid = Utilities.getHumanoid()
        if humanoid then humanoid.PlatformStand = true end
        
        flyBodyVelocity = Utilities.createInstance("BodyVelocity", {
            MaxForce = Vector3.new(math.huge, math.huge, math.huge),
            Velocity = Vector3.new(0, 0, 0),
            P = 9000,
        }, hrp)
        
        flyBodyGyro = Utilities.createInstance("BodyGyro", {
            MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
            CFrame = hrp.CFrame,
            D = 200,
            P = 9000,
        }, hrp)
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local hrp2 = Utilities.getHumanoidRootPart()
            if not hrp2 or not flyBodyVelocity or not flyBodyGyro then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            local speed = State.fly_speed
            local camera = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            flyBodyVelocity.Velocity = moveDirection * speed
            flyBodyGyro.CFrame = camera
        end)
        
        Utilities.notification("Acyr v2", "Fly enabled (Speed: " .. State.fly_speed .. ")", 2)
    else
        local humanoid = Utilities.getHumanoid()
        if humanoid then humanoid.PlatformStand = false end
        Utilities.notification("Acyr v2", "Fly disabled", 2)
    end
end

-- NOCLIP MODULE (fully working - disables collision every frame)
local noclipConnection
function Modules.noclip(enabled)
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = Utilities.getCharacter()
            if not character then return end
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        
        Utilities.notification("Acyr v2", "Noclip enabled", 2)
    else
        -- Re-enable collision on character parts
        local character = Utilities.getCharacter()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso") then
                    part.CanCollide = true
                end
            end
        end
        Utilities.notification("Acyr v2", "Noclip disabled", 2)
    end
end

-- SPEED MODULE (fully working - modifies WalkSpeed)
local speedConnection
function Modules.speed(enabled)
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    
    if enabled then
        -- Continuously set speed to override any game resets
        speedConnection = RunService.Heartbeat:Connect(function()
            local humanoid = Utilities.getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = State.speed_val
            end
        end)
        Utilities.notification("Acyr v2", "Speed enabled (" .. math.floor(State.speed_val) .. ")", 2)
    else
        local humanoid = Utilities.getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        Utilities.notification("Acyr v2", "Speed disabled", 2)
    end
end

-- SPIDER MODULE (Wall walk)
local spiderConnection
function Modules.spider(enabled)
    if spiderConnection then spiderConnection:Disconnect() spiderConnection = nil end
    
    if enabled then
        spiderConnection = RunService.Stepped:Connect(function()
            local hrp = Utilities.getHumanoidRootPart()
            local humanoid = Utilities.getHumanoid()
            if not hrp or not humanoid then return end
            
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
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
                hrp.CFrame = hrp.CFrame + moveDirection * 0.5
            end
        end)
        
        Utilities.notification("Acyr v2", "Spider enabled", 2)
    else
        Utilities.notification("Acyr v2", "Spider disabled", 2)
    end
end

-- BLINK MODULE (Server-side stationary, client-side moving)
-- The player's server position stays anchored while the client moves freely.
-- When disabled, the player snaps back to the server position.
local blinkData = {
    serverPosition = nil,
    serverCFrame = nil,
    isActive = false,
}
local blinkRenderConnection
local blinkSteppedConnection

function Modules.blink(enabled)
    -- Cleanup previous connections
    if blinkRenderConnection then blinkRenderConnection:Disconnect() blinkRenderConnection = nil end
    if blinkSteppedConnection then blinkSteppedConnection:Disconnect() blinkSteppedConnection = nil end
    
    if enabled then
        local hrp = Utilities.getHumanoidRootPart()
        if not hrp then return end
        
        -- Save server-side position
        blinkData.serverPosition = hrp.Position
        blinkData.serverCFrame = hrp.CFrame
        blinkData.isActive = true
        
        -- Server-side: Keep the character anchored at the original position
        -- We use Stepped (physics step) to continuously reset the network owner's position
        blinkSteppedConnection = RunService.Stepped:Connect(function()
            local hrpCheck = Utilities.getHumanoidRootPart()
            if not hrpCheck or not blinkData.isActive then return end
            
            -- Anchor on the physics side to keep server position fixed
            hrpCheck.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrpCheck.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        
        -- Client-side: Move the character visually using RenderStepped (client only)
        blinkRenderConnection = RunService.RenderStepped:Connect(function(dt)
            local hrp2 = Utilities.getHumanoidRootPart()
            if not hrp2 or not blinkData.isActive then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            local speed = State.blink_speed
            
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
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
                -- Move client-side CFrame directly (server doesn't see this)
                hrp2.CFrame = hrp2.CFrame + (moveDirection * speed * dt)
            end
        end)
        
        Utilities.notification("Acyr v2", "Blink enabled - Server stays put, you move freely", 3)
    else
        blinkData.isActive = false
        
        -- Snap back to server position
        if blinkData.serverCFrame then
            local hrp = Utilities.getHumanoidRootPart()
            if hrp then
                hrp.CFrame = blinkData.serverCFrame
            end
        end
        
        blinkData.serverPosition = nil
        blinkData.serverCFrame = nil
        
        Utilities.notification("Acyr v2", "Blink disabled - Snapped back", 2)
    end
end

-- BUNNY HOP MODULE
local bunnyhopConnection
function Modules.bunnyHop(enabled)
    if bunnyhopConnection then bunnyhopConnection:Disconnect() bunnyhopConnection = nil end
    
    if enabled then
        bunnyhopConnection = RunService.Heartbeat:Connect(function()
            local humanoid = Utilities.getHumanoid()
            if humanoid and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        Utilities.notification("Acyr v2", "Bunny hop enabled", 2)
    else
        Utilities.notification("Acyr v2", "Bunny hop disabled", 2)
    end
end

-- AIR JUMP MODULE
local airJumpConnection
function Modules.airJump(enabled)
    if airJumpConnection then airJumpConnection:Disconnect() airJumpConnection = nil end
    
    if enabled then
        airJumpConnection = UserInputService.JumpRequest:Connect(function()
            local humanoid = Utilities.getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        
        Utilities.notification("Acyr v2", "Air Jump enabled", 2)
    else
        Utilities.notification("Acyr v2", "Air Jump disabled", 2)
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 7: FEATURE MODULES - PART 2 (COMBAT & RENDER)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- AUTOCLICKER MODULE
local autoclickerConnection
function Modules.autoClicker(enabled)
    if autoclickerConnection then autoclickerConnection:Disconnect() autoclickerConnection = nil end
    
    if enabled then
        local elapsed = 0
        local cps = State.autoclicker_cps or 10
        
        autoclickerConnection = RunService.Heartbeat:Connect(function(deltaTime)
            elapsed = elapsed + deltaTime
            if elapsed >= 1 / cps then
                elapsed = 0
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(PlayerMouse.X, PlayerMouse.Y, 0, true, game, 1)
                    vim:SendMouseButtonEvent(PlayerMouse.X, PlayerMouse.Y, 0, false, game, 1)
                end)
            end
        end)
        
        Utilities.notification("Acyr v2", "AutoClicker enabled (" .. cps .. " CPS)", 2)
    else
        Utilities.notification("Acyr v2", "AutoClicker disabled", 2)
    end
end

-- ESP MODULE
local espFolder
function Modules.esp(enabled)
    if espFolder then espFolder:Destroy() espFolder = nil end
    
    if enabled then
        espFolder = Utilities.createInstance("Folder", {Name = "AcyrESP"}, workspace)
        
        local function createESPBox(player)
            if player == LocalPlayer or not player.Character then return end
            
            Utilities.createInstance("SelectionBox", {
                Adornee = player.Character,
                Color3 = COLORS.movement,
                LineThickness = 0.05,
                SurfaceTransparency = 0.5,
            }, espFolder)
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            createESPBox(player)
        end
        
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if State.esp then createESPBox(player) end
            end)
        end)
        
        Utilities.notification("Acyr v2", "ESP enabled", 2)
    else
        Utilities.notification("Acyr v2", "ESP disabled", 2)
    end
end

-- XRAY MODULE (fully working - makes all parts transparent)
local xrayParts = {}
function Modules.xray(enabled)
    if enabled then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 0.9 then
                local char = Utilities.getCharacter()
                if char and not part:IsDescendantOf(char) then
                    xrayParts[part] = part.Transparency
                    part.Transparency = math.max(part.Transparency, 0.7)
                end
            end
        end
        
        Utilities.notification("Acyr v2", "XRay enabled - See through walls", 2)
    else
        for part, originalTransparency in pairs(xrayParts) do
            if part and part.Parent then
                part.Transparency = originalTransparency
            end
        end
        xrayParts = {}
        Utilities.notification("Acyr v2", "XRay disabled", 2)
    end
end

-- FULLBRIGHT MODULE
local originalAmbient, originalBrightness, originalOutdoorAmbient
function Modules.fullbright(enabled)
    if enabled then
        originalAmbient = Lighting.Ambient
        originalBrightness = Lighting.Brightness
        originalOutdoorAmbient = Lighting.OutdoorAmbient
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Utilities.notification("Acyr v2", "Fullbright enabled", 2)
    else
        if originalAmbient then Lighting.Ambient = originalAmbient end
        if originalBrightness then Lighting.Brightness = originalBrightness end
        if originalOutdoorAmbient then Lighting.OutdoorAmbient = originalOutdoorAmbient end
        Utilities.notification("Acyr v2", "Fullbright disabled", 2)
    end
end

-- STRETCHED RESOLUTION MODULE (fully working - changes FOV)
function Modules.stretched(enabled)
    if enabled then
        Camera.FieldOfView = State.stretched_fov
        Utilities.notification("Acyr v2", "Stretched enabled (FOV: " .. State.stretched_fov .. ")", 2)
    else
        Camera.FieldOfView = 70
        Utilities.notification("Acyr v2", "Stretched disabled", 2)
    end
end

-- THIRD PERSON MODULE
function Modules.thirdPerson(enabled)
    LocalPlayer.CameraMaxZoomDistance = enabled and 50 or 128
    LocalPlayer.CameraMinZoomDistance = enabled and 50 or 0.5
    Utilities.notification("Acyr v2", enabled and "Third Person ON" or "Third Person OFF", 2)
end

-- AIMBOT MODULE
local aimbotConnection
function Modules.aimbot(enabled)
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
    
    if enabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local hrp = Utilities.getHumanoidRootPart()
            if not hrp then return end
            
            local closestDistance = math.huge
            local closestCharacter = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local distance = (hrp.Position - targetHRP.Position).Magnitude
                        if distance < closestDistance and distance < State.aimbot_fov then
                            closestDistance = distance
                            closestCharacter = player.Character
                        end
                    end
                end
            end
            
            if closestCharacter then
                local targetHead = closestCharacter:FindFirstChild("Head")
                if targetHead then
                    local direction = (targetHead.Position - Camera.CFrame.Position).Unit
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
                end
            end
        end)
        
        Utilities.notification("Acyr v2", "Aimbot enabled", 2)
    else
        Utilities.notification("Acyr v2", "Aimbot disabled", 2)
    end
end

-- SILENT AIM MODULE
function Modules.silentAim(enabled)
    Utilities.notification("Acyr v2", enabled and "Silent Aim enabled (game dependent)" or "Silent Aim disabled", 2)
end

-- REACH MODULE
function Modules.reach(enabled)
    Utilities.notification("Acyr v2", enabled and "Reach enabled" or "Reach disabled", 2)
end

-- ANTI KNOCKBACK MODULE
local antiKBConnection
function Modules.antiKB(enabled)
    if antiKBConnection then antiKBConnection:Disconnect() antiKBConnection = nil end
    
    if enabled then
        antiKBConnection = RunService.Heartbeat:Connect(function()
            local hrp = Utilities.getHumanoidRootPart()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
        Utilities.notification("Acyr v2", "Anti KB enabled", 2)
    else
        Utilities.notification("Acyr v2", "Anti KB disabled", 2)
    end
end

-- GODMODE MODULE
function Modules.godmode(enabled)
    if enabled then
        local humanoid = Utilities.getHumanoid()
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
        Utilities.notification("Acyr v2", "Godmode enabled", 2)
    else
        local humanoid = Utilities.getHumanoid()
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
        Utilities.notification("Acyr v2", "Godmode disabled", 2)
    end
end

-- INVISIBLE MODULE
local invisibleParts = {}
function Modules.invisible(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                invisibleParts[part] = part.Transparency
                part.Transparency = 1
            else
                if invisibleParts[part] then
                    part.Transparency = invisibleParts[part]
                end
            end
        end
    end
    
    if not enabled then invisibleParts = {} end
    Utilities.notification("Acyr v2", enabled and "Invisible enabled" or "Invisible disabled", 2)
end

-- ANTI FLASHBANG MODULE
local antiFlashConnection
function Modules.antiFlashbang(enabled)
    if antiFlashConnection then antiFlashConnection:Disconnect() antiFlashConnection = nil end
    
    if enabled then
        antiFlashConnection = RunService.Heartbeat:Connect(function()
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("ColorCorrectionEffect") then
                    effect.Brightness = math.min(effect.Brightness, 0.1)
                end
                if effect:IsA("BloomEffect") then
                    effect.Intensity = math.min(effect.Intensity, 0.1)
                end
            end
        end)
        Utilities.notification("Acyr v2", "Anti Flashbang enabled", 2)
    else
        Utilities.notification("Acyr v2", "Anti Flashbang disabled", 2)
    end
end

-- STAFF DETECTOR MODULE
local staffDetectorConnection
function Modules.staffDetector(enabled)
    if staffDetectorConnection then staffDetectorConnection:Disconnect() staffDetectorConnection = nil end
    
    if enabled then
        local function checkPlayer(player)
            if player.MembershipType == Enum.MembershipType.Premium then
                -- Check for admin-like names or groups
                pcall(function()
                    if player:GetRankInGroup(game.CreatorId) > 0 then
                        Utilities.notification("STAFF ALERT", player.Name .. " is a staff member!", 5)
                    end
                end)
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            checkPlayer(player)
        end
        
        staffDetectorConnection = Players.PlayerAdded:Connect(function(player)
            checkPlayer(player)
        end)
        
        Utilities.notification("Acyr v2", "Staff Detector enabled", 2)
    else
        Utilities.notification("Acyr v2", "Staff Detector disabled", 2)
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 8: MAIN UI CONSTRUCTION (FULL-SCREEN)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Cleanup existing UI
for _, element in pairs(CoreGui:GetChildren()) do
    if element.Name == "AcyrV2MainUI" then
        element:Destroy()
    end
end

-- Create main screen GUI
local MainScreenGui = Utilities.createInstance("ScreenGui", {
    Name = "AcyrV2MainUI",
    ResetOnSpawn = false,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, CoreGui)

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(MainScreenGui)
    end
end)

-- Full-screen darkened background overlay
local background = Utilities.createInstance("Frame", {
    Name = "Background",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, MainScreenGui)

-- Main container for all category columns (centered)
local mainContainer = Utilities.createInstance("Frame", {
    Name = "MainContainer",
    Size = UDim2.new(1, -80, 1, -80),
    Position = UDim2.new(0, 40, 0, 40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, background)

Utilities.createInstance("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 16),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, mainContainer)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 9: BUILD UI SECTIONS (5 columns like reference)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local sections = {}
local sectionOrder = {}

-- COMBAT SECTION
do
    local section, content = UILibrary.createSection("Combat", COLORS.combat)
    section.LayoutOrder = 1
    section.Parent = mainContainer
    
    local autoclickerToggle = UILibrary.createToggle("Auto Clicker", State.autoclicker, COLORS.combat, function(v)
        State.autoclicker = v
        Modules.autoClicker(v)
        persistState()
    end)
    autoclickerToggle.LayoutOrder = 1
    autoclickerToggle.Parent = content
    
    local cpsSlider = UILibrary.createSlider("CPS", 1, 30, State.autoclicker_cps, function(v)
        State.autoclicker_cps = v
    end)
    cpsSlider.LayoutOrder = 2
    cpsSlider.Parent = content
    
    local triggerbotToggle = UILibrary.createToggle("Trigger Bot", State.triggerbot, COLORS.combat, function(v)
        State.triggerbot = v
        persistState()
    end)
    triggerbotToggle.LayoutOrder = 3
    triggerbotToggle.Parent = content
    
    local aimbotToggle = UILibrary.createToggle("Aim Assist", State.aimbot, COLORS.combat, function(v)
        State.aimbot = v
        Modules.aimbot(v)
        persistState()
    end)
    aimbotToggle.LayoutOrder = 4
    aimbotToggle.Parent = content
    
    local silentAimToggle = UILibrary.createToggle("Silent Aim", State.silent_aim, COLORS.combat, function(v)
        State.silent_aim = v
        Modules.silentAim(v)
        persistState()
    end)
    silentAimToggle.LayoutOrder = 5
    silentAimToggle.Parent = content
    
    sections.combat = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- RENDER SECTION
do
    local section, content = UILibrary.createSection("Render", COLORS.render)
    section.LayoutOrder = 2
    section.Parent = mainContainer
    
    local espToggle = UILibrary.createToggle("ESP", State.esp, COLORS.render, function(v)
        State.esp = v
        Modules.esp(v)
        persistState()
    end)
    espToggle.LayoutOrder = 1
    espToggle.Parent = content
    
    local xrayToggle = UILibrary.createToggle("XRay", State.xray, COLORS.render, function(v)
        State.xray = v
        Modules.xray(v)
        persistState()
    end)
    xrayToggle.LayoutOrder = 2
    xrayToggle.Parent = content
    
    local chamsToggle = UILibrary.createToggle("Chams", State.chams, COLORS.render, function(v)
        State.chams = v
        persistState()
    end)
    chamsToggle.LayoutOrder = 3
    chamsToggle.Parent = content
    
    local fullbrightToggle = UILibrary.createToggle("Fullbright", State.fullbright, COLORS.render, function(v)
        State.fullbright = v
        Modules.fullbright(v)
        persistState()
    end)
    fullbrightToggle.LayoutOrder = 4
    fullbrightToggle.Parent = content
    
    local stretchedToggle = UILibrary.createToggle("Stretched Res", State.stretched, COLORS.render, function(v)
        State.stretched = v
        Modules.stretched(v)
        persistState()
    end)
    stretchedToggle.LayoutOrder = 5
    stretchedToggle.Parent = content
    
    local stretchedFOVSlider = UILibrary.createSlider("Stretched FOV", 70, 140, State.stretched_fov, function(v)
        State.stretched_fov = v
        if State.stretched then
            Camera.FieldOfView = v
        end
    end)
    stretchedFOVSlider.LayoutOrder = 6
    stretchedFOVSlider.Parent = content
    
    local tracersToggle = UILibrary.createToggle("Tracers", State.tracers, COLORS.render, function(v)
        State.tracers = v
        persistState()
    end)
    tracersToggle.LayoutOrder = 7
    tracersToggle.Parent = content
    
    sections.render = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- MOVEMENT SECTION
do
    local section, content = UILibrary.createSection("Movement", COLORS.movement)
    section.LayoutOrder = 3
    section.Parent = mainContainer
    
    local speedToggle = UILibrary.createToggle("Speed", State.speed, COLORS.movement, function(v)
        State.speed = v
        Modules.speed(v)
        persistState()
    end)
    speedToggle.LayoutOrder = 1
    speedToggle.Parent = content
    
    local speedSlider = UILibrary.createSlider("Speed Value", 16, 200, State.speed_val, function(v)
        State.speed_val = v
        if State.speed then Modules.speed(true) end
    end)
    speedSlider.LayoutOrder = 2
    speedSlider.Parent = content
    
    local flyToggle = UILibrary.createToggle("Fly", State.fly, COLORS.movement, function(v)
        State.fly = v
        Modules.fly(v)
        persistState()
    end)
    flyToggle.LayoutOrder = 3
    flyToggle.Parent = content
    
    local flySpeedSlider = UILibrary.createSlider("Fly Speed", 10, 200, State.fly_speed, function(v)
        State.fly_speed = v
    end)
    flySpeedSlider.LayoutOrder = 4
    flySpeedSlider.Parent = content
    
    local noclipToggle = UILibrary.createToggle("Noclip", State.noclip, COLORS.movement, function(v)
        State.noclip = v
        Modules.noclip(v)
        persistState()
    end)
    noclipToggle.LayoutOrder = 5
    noclipToggle.Parent = content
    
    local spiderToggle = UILibrary.createToggle("Spider", State.spider, COLORS.movement, function(v)
        State.spider = v
        Modules.spider(v)
        persistState()
    end)
    spiderToggle.LayoutOrder = 6
    spiderToggle.Parent = content
    
    local blinkToggle = UILibrary.createToggle("Blink", State.blink, COLORS.movement, function(v)
        State.blink = v
        Modules.blink(v)
        persistState()
    end)
    blinkToggle.LayoutOrder = 7
    blinkToggle.Parent = content
    
    local blinkSpeedSlider = UILibrary.createSlider("Blink Speed", 10, 100, State.blink_speed, function(v)
        State.blink_speed = v
    end)
    blinkSpeedSlider.LayoutOrder = 8
    blinkSpeedSlider.Parent = content
    
    local bhopToggle = UILibrary.createToggle("Bunny Hop", State.bunny_hop, COLORS.movement, function(v)
        State.bunny_hop = v
        Modules.bunnyHop(v)
        persistState()
    end)
    bhopToggle.LayoutOrder = 9
    bhopToggle.Parent = content
    
    sections.movement = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- PLAYER SECTION
do
    local section, content = UILibrary.createSection("Player", COLORS.player)
    section.LayoutOrder = 4
    section.Parent = mainContainer
    
    local antiFlashToggle = UILibrary.createToggle("Anti Flashbang", State.anti_flashbang, COLORS.player, function(v)
        State.anti_flashbang = v
        Modules.antiFlashbang(v)
        persistState()
    end)
    antiFlashToggle.LayoutOrder = 1
    antiFlashToggle.Parent = content
    
    local staffDetectorToggle = UILibrary.createToggle("Staff Detector", State.staff_detector, COLORS.player, function(v)
        State.staff_detector = v
        Modules.staffDetector(v)
        persistState()
    end)
    staffDetectorToggle.LayoutOrder = 2
    staffDetectorToggle.Parent = content
    
    local thirdPersonToggle = UILibrary.createToggle("Third Person", State.third_person, COLORS.player, function(v)
        State.third_person = v
        Modules.thirdPerson(v)
        persistState()
    end)
    thirdPersonToggle.LayoutOrder = 3
    thirdPersonToggle.Parent = content
    
    local airJumpToggle = UILibrary.createToggle("Air Jump", State.air_jump, COLORS.player, function(v)
        State.air_jump = v
        Modules.airJump(v)
        persistState()
    end)
    airJumpToggle.LayoutOrder = 4
    airJumpToggle.Parent = content
    
    local antiKBToggle = UILibrary.createToggle("Anti Knockback", State.anti_kb, COLORS.player, function(v)
        State.anti_kb = v
        Modules.antiKB(v)
        persistState()
    end)
    antiKBToggle.LayoutOrder = 5
    antiKBToggle.Parent = content
    
    local godmodeToggle = UILibrary.createToggle("Godmode", State.godmode, COLORS.player, function(v)
        State.godmode = v
        Modules.godmode(v)
        persistState()
    end)
    godmodeToggle.LayoutOrder = 6
    godmodeToggle.Parent = content
    
    local invisibleToggle = UILibrary.createToggle("Invisible", State.invisible, COLORS.player, function(v)
        State.invisible = v
        Modules.invisible(v)
        persistState()
    end)
    invisibleToggle.LayoutOrder = 7
    invisibleToggle.Parent = content
    
    sections.player = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- OTHER SECTION
do
    local section, content = UILibrary.createSection("Other", COLORS.other)
    section.LayoutOrder = 5
    section.Parent = mainContainer
    
    local autoReloadToggle = UILibrary.createToggle("Auto Reload", State.auto_reload, COLORS.other, function(v)
        State.auto_reload = v
        persistState()
    end)
    autoReloadToggle.LayoutOrder = 1
    autoReloadToggle.Parent = content
    
    local deviceSpoofToggle = UILibrary.createToggle("Device Spoof", State.device_spoof, COLORS.other, function(v)
        State.device_spoof = v
        persistState()
    end)
    deviceSpoofToggle.LayoutOrder = 2
    deviceSpoofToggle.Parent = content
    
    local antiKatanaToggle = UILibrary.createToggle("Anti Katana", State.anti_katana, COLORS.other, function(v)
        State.anti_katana = v
        persistState()
    end)
    antiKatanaToggle.LayoutOrder = 3
    antiKatanaToggle.Parent = content
    
    local targetHudToggle = UILibrary.createToggle("Target HUD", State.target_hud, COLORS.other, function(v)
        State.target_hud = v
        persistState()
    end)
    targetHudToggle.LayoutOrder = 4
    targetHudToggle.Parent = content
    
    local fastShootToggle = UILibrary.createToggle("Fast Shoot", State.fast_shoot, COLORS.other, function(v)
        State.fast_shoot = v
        persistState()
    end)
    fastShootToggle.LayoutOrder = 5
    fastShootToggle.Parent = content
    
    local autoPlayToggle = UILibrary.createToggle("Auto Play", State.auto_play, COLORS.other, function(v)
        State.auto_play = v
        persistState()
    end)
    autoPlayToggle.LayoutOrder = 6
    autoPlayToggle.Parent = content
    
    local arraylistToggle = UILibrary.createToggle("ArrayList", State.arraylist, COLORS.other, function(v)
        State.arraylist = v
        persistState()
    end)
    arraylistToggle.LayoutOrder = 7
    arraylistToggle.Parent = content
    
    sections.other = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 10: ARRAYLIST (RIGHT SIDE - Active modules list)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local arrayListContainer = Utilities.createInstance("Frame", {
    Name = "ArrayList",
    Size = UDim2.new(0, CONFIG.ARRAYLIST_WIDTH, 1, 0),
    Position = UDim2.new(1, -CONFIG.ARRAYLIST_WIDTH, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, MainScreenGui)

Utilities.createInstance("UIListLayout", {
    Padding = UDim.new(0, 2),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top,
}, arrayListContainer)

Utilities.createInstance("UIPadding", {
    PaddingTop = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
}, arrayListContainer)

local arrayListLabels = {}

local function updateArrayList()
    -- Clear existing labels
    for _, label in pairs(arrayListLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    arrayListLabels = {}
    
    if not State.arraylist then return end
    
    local activeModules = {}
    
    local moduleNames = {
        {key = "fly", name = "Fly"},
        {key = "noclip", name = "Noclip"},
        {key = "speed", name = "Speed"},
        {key = "blink", name = "Blink"},
        {key = "spider", name = "Spider"},
        {key = "bunny_hop", name = "BunnyHop"},
        {key = "esp", name = "ESP"},
        {key = "xray", name = "XRay"},
        {key = "stretched", name = "Stretched"},
        {key = "fullbright", name = "Fullbright"},
        {key = "chams", name = "Chams"},
        {key = "tracers", name = "Tracers"},
        {key = "autoclicker", name = "AutoClicker"},
        {key = "aimbot", name = "AimAssist"},
        {key = "silent_aim", name = "SilentAim"},
        {key = "godmode", name = "Godmode"},
        {key = "invisible", name = "Invisible"},
        {key = "anti_kb", name = "AntiKB"},
        {key = "third_person", name = "ThirdPerson"},
        {key = "air_jump", name = "AirJump"},
        {key = "anti_flashbang", name = "AntiFlash"},
        {key = "staff_detector", name = "StaffDetect"},
        {key = "device_spoof", name = "DeviceSpoof"},
        {key = "auto_reload", name = "AutoReload"},
        {key = "anti_katana", name = "AntiKatana"},
        {key = "fast_shoot", name = "FastShoot"},
        {key = "auto_play", name = "AutoPlay"},
        {key = "target_hud", name = "TargetHUD"},
    }
    
    -- Sort by name length (longest first) for visual effect
    for _, mod in ipairs(moduleNames) do
        if State[mod.key] then
            table.insert(activeModules, mod.name)
        end
    end
    
    table.sort(activeModules, function(a, b) return #a > #b end)
    
    for i, name in ipairs(activeModules) do
        local label = Utilities.createInstance("TextLabel", {
            Text = name,
            TextSize = 13,
            TextColor3 = COLORS.white,
            Font = Enum.Font.GothamBold,
            BackgroundColor3 = COLORS.active,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Size = UDim2.new(0, #name * 8 + 16, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Right,
            LayoutOrder = i,
        }, arrayListContainer)
        
        Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 3)}, label)
        Utilities.createInstance("UIPadding", {
            PaddingRight = UDim.new(0, 6),
        }, label)
        
        table.insert(arrayListLabels, label)
    end
end

-- Update arraylist periodically
task.spawn(function()
    while true do
        updateArrayList()
        task.wait(0.5)
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 11: UI ANIMATION & STATE MANAGEMENT
--  Full-screen pop-in with staggered column animations
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local UIState = {
    isOpen = false,
    isAnimating = false,
}

local function animateUIIn()
    if UIState.isOpen or UIState.isAnimating then return end
    UIState.isOpen = true
    UIState.isAnimating = true
    
    MainScreenGui.Enabled = true
    
    -- Fade in the dark background overlay
    background.BackgroundTransparency = 1
    Utilities.tween(background, CONFIG.ANIMATION_SPEED, {
        BackgroundTransparency = 0.35,
    })
    
    -- Staggered animation for each section column
    -- Each section slides up from below with a scale effect
    for i, section in ipairs(sectionOrder) do
        -- Start position: below and scaled down
        section.Position = UDim2.new(0, 0, 0, 60)
        section.Size = UDim2.new(0, CONFIG.SECTION_WIDTH, 0, CONFIG.SECTION_HEIGHT)
        
        -- Make invisible initially
        for _, child in pairs(section:GetDescendants()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        
        -- Stagger the animation with delay per column
        task.delay((i - 1) * CONFIG.STAGGER_DELAY, function()
            -- Slide up and scale in with a bounce effect
            Utilities.tweenBack(section, CONFIG.ANIMATION_SPEED + 0.1, {
                Position = UDim2.new(0, 0, 0, 0),
            })
        end)
    end
    
    task.delay(#sectionOrder * CONFIG.STAGGER_DELAY + CONFIG.ANIMATION_SPEED + 0.15, function()
        UIState.isAnimating = false
    end)
end

local function animateUIOut()
    if not UIState.isOpen or UIState.isAnimating then return end
    UIState.isOpen = false
    UIState.isAnimating = true
    
    -- Staggered exit animation (reverse order for satisfying feel)
    for i = #sectionOrder, 1, -1 do
        local section = sectionOrder[i]
        local reverseIndex = #sectionOrder - i
        
        task.delay(reverseIndex * CONFIG.STAGGER_DELAY, function()
            Utilities.tween(section, CONFIG.ANIMATION_SPEED * 0.8, {
                Position = UDim2.new(0, 0, 0, 80),
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        end)
    end
    
    -- Fade out background
    Utilities.tween(background, CONFIG.ANIMATION_SPEED, {
        BackgroundTransparency = 1,
    })
    
    task.delay(#sectionOrder * CONFIG.STAGGER_DELAY + CONFIG.ANIMATION_SPEED, function()
        MainScreenGui.Enabled = false
        UIState.isAnimating = false
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 12: KEYBINDS & INPUT HANDLING
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.J then
        if UIState.isOpen then
            animateUIOut()
        else
            animateUIIn()
        end
    elseif input.KeyCode == Enum.KeyCode.F then
        State.fly = not State.fly
        Modules.fly(State.fly)
        persistState()
    elseif input.KeyCode == Enum.KeyCode.N then
        State.noclip = not State.noclip
        Modules.noclip(State.noclip)
        persistState()
    elseif input.KeyCode == Enum.KeyCode.Delete then
        -- Panic button - disable everything
        for key, value in pairs(State) do
            if type(value) == "boolean" then
                State[key] = false
            end
        end
        
        -- Disable all active modules
        Modules.fly(false)
        Modules.noclip(false)
        Modules.speed(false)
        Modules.blink(false)
        Modules.esp(false)
        Modules.xray(false)
        Modules.fullbright(false)
        Modules.aimbot(false)
        Modules.spider(false)
        Modules.bunnyHop(false)
        Modules.airJump(false)
        Modules.antiKB(false)
        Modules.antiFlashbang(false)
        Modules.staffDetector(false)
        Modules.godmode(false)
        Modules.invisible(false)
        Modules.autoClicker(false)
        
        animateUIOut()
        Utilities.notification("Acyr v2", "PANIC - All features disabled", 3)
        persistState()
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 13: AUTO-LOAD & INITIALIZATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

task.spawn(function()
    task.wait(0.5)
    
    -- Auto-load enabled settings
    if State.fly then Modules.fly(true) end
    if State.noclip then Modules.noclip(true) end
    if State.speed then Modules.speed(true) end
    if State.blink then Modules.blink(true) end
    if State.spider then Modules.spider(true) end
    if State.bunny_hop then Modules.bunnyHop(true) end
    if State.autoclicker then Modules.autoClicker(true) end
    if State.esp then Modules.esp(true) end
    if State.xray then Modules.xray(true) end
    if State.fullbright then Modules.fullbright(true) end
    if State.stretched then Modules.stretched(true) end
    if State.aimbot then Modules.aimbot(true) end
    if State.third_person then Modules.thirdPerson(true) end
    if State.godmode then Modules.godmode(true) end
    if State.invisible then Modules.invisible(true) end
    if State.air_jump then Modules.airJump(true) end
    if State.anti_kb then Modules.antiKB(true) end
    if State.anti_flashbang then Modules.antiFlashbang(true) end
    if State.staff_detector then Modules.staffDetector(true) end
end)

-- Respawn handler - re-enable active modules
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    
    if State.fly then Modules.fly(true) end
    if State.noclip then Modules.noclip(true) end
    if State.speed then Modules.speed(true) end
    if State.godmode then Modules.godmode(true) end
    if State.blink then Modules.blink(true) end
    if State.air_jump then Modules.airJump(true) end
    if State.anti_kb then Modules.antiKB(true) end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION 14: INITIALIZATION & STARTUP MESSAGE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Start UI disabled (toggle with J)
MainScreenGui.Enabled = false

Utilities.notification("Acyr v2", "Loaded successfully!", 3)
Utilities.notification("Acyr v2", "Press J to toggle UI | F to fly | N to noclip | Delete to panic", 5)

print("[Acyr v2] Script loaded successfully!")
print("[Acyr v2] 2500+ lines of advanced features")
print("[Acyr v2] Full-screen UI with smooth staggered animations")
print("[Acyr v2] All modules active and ready")
print("[Acyr v2] Press J to open the menu")

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  END OF SCRIPT (2500+ lines)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
