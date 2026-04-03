--[[
  ======================================================================
  |             A C Y R   v 2   -   P R O F E S S I O N A L            |
  |                Made by Acy - Full UI + Modules                     |
  |           Full UI Library + Advanced Modules                       |
  |           github.com/TheJackael/Acyr                               |
  ======================================================================

  FEATURES:
  - Professional full-screen UI with smooth staggered animations
  - Advanced modules: Fly, Noclip, Speed, XRay, Blink, ESP, Aimbot
  - Settings tab with notifications, version info, and more
  - Fun tab with harmless cosmetic features
  - Click sounds on all interactions
  - Customizable sliders, toggles
  - Persistent settings
  - Modern design with gradients and effects
  - ArrayList sidebar showing active modules
  
  KEYBINDS:
  - J: Toggle UI (full-screen with animations)
  - F: Fly
  - N: Noclip
  - Delete: Panic/Close
]]

-- ====================================================================
--  SECTION 1: CORE SERVICES & INITIALIZATION
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ====================================================================
--  SECTION 2: CONSTANTS & CONFIGURATION
-- ====================================================================

local CONFIG = {
    SAVE_FILE = "AcyrV2_settings.json",
    UI_PADDING = 8,
    ANIMATION_SPEED = 0.35,
    STAGGER_DELAY = 0.06,
    BORDER_RADIUS = 8,
    HEADER_HEIGHT = 40,
    SECTION_WIDTH = 190,
    SECTION_HEIGHT = 520,
    ARRAYLIST_WIDTH = 160,
    VERSION = "2.1.0",
}

local COLORS = {
    background = Color3.fromRGB(15, 15, 20),
    darkBG = Color3.fromRGB(10, 10, 15),
    panel = Color3.fromRGB(28, 28, 38),
    panelHover = Color3.fromRGB(38, 38, 52),
    border = Color3.fromRGB(50, 50, 70),
    
    combat = Color3.fromRGB(220, 90, 140),
    movement = Color3.fromRGB(100, 200, 220),
    render = Color3.fromRGB(160, 120, 220),
    player = Color3.fromRGB(220, 160, 80),
    settings = Color3.fromRGB(120, 180, 120),
    fun = Color3.fromRGB(255, 160, 60),
    
    active = Color3.fromRGB(255, 130, 180),
    activeGlow = Color3.fromRGB(255, 100, 160),
    
    text = Color3.fromRGB(200, 200, 210),
    textDark = Color3.fromRGB(100, 100, 110),
    white = Color3.fromRGB(255, 255, 255),
    
    success = Color3.fromRGB(100, 200, 100),
    warning = Color3.fromRGB(220, 160, 80),
    error = Color3.fromRGB(220, 100, 100),
}

-- Sound IDs for click effects
local SOUNDS = {
    CLICK_ON = "rbxassetid://6895079853",
    CLICK_OFF = "rbxassetid://6895079853",
    HOVER = "rbxassetid://10066936758",
    OPEN = "rbxassetid://6895079853",
    CLOSE = "rbxassetid://6895079853",
}

-- ====================================================================
--  SECTION 3: STATE MANAGEMENT
-- ====================================================================

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
    aimbot = Settings.aimbot or false,
    aimbot_fov = Settings.aimbot_fov or 100,
    
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
    fullbright = Settings.fullbright or false,
    stretched = Settings.stretched or false,
    stretched_fov = Settings.stretched_fov or 120,
    
    -- Player
    third_person = Settings.third_person or false,
    anti_kb = Settings.anti_kb or false,
    godmode = Settings.godmode or false,
    invisible = Settings.invisible or false,
    air_jump = Settings.air_jump or false,
    staff_detector = Settings.staff_detector or false,
    
    -- Settings
    notifications = (Settings.notifications ~= nil) and Settings.notifications or true,
    arraylist = (Settings.arraylist ~= nil) and Settings.arraylist or true,
    target_hud = Settings.target_hud or false,
    click_sounds = (Settings.click_sounds ~= nil) and Settings.click_sounds or true,
    
    -- Fun
    big_head = Settings.big_head or false,
    tiny = Settings.tiny or false,
    giant = Settings.giant or false,
    rainbow = Settings.rainbow or false,
    spin = Settings.spin or false,
    upside_down = Settings.upside_down or false,
    headless = Settings.headless or false,
    disco = Settings.disco or false,
    noodle_arms = Settings.noodle_arms or false,
}

local function persistState()
    saveSettings(State)
end

-- ====================================================================
--  SECTION 4: UTILITY FUNCTIONS
-- ====================================================================

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
    if not State.notifications then return end
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

function Utilities.playSound(soundId, volume, pitch)
    if not State.click_sounds then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume or 0.5
        sound.PlaybackSpeed = pitch or 1.2
        sound.Parent = SoundService
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- ====================================================================
--  SECTION 5: UI LIBRARY (CUSTOM)
-- ====================================================================

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
        Utilities.playSound(SOUNDS.HOVER, 0.15, 1.5)
    end)
    
    button.MouseLeave:Connect(function()
        Utilities.tween(button, 0.15, {
            BackgroundColor3 = color or COLORS.panel,
        })
    end)
    
    button.MouseButton1Click:Connect(function()
        Utilities.playSound(SOUNDS.CLICK_ON, 0.4, 1.0)
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
    
    Utilities.createInstance("TextLabel", {
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
        if state then
            Utilities.playSound(SOUNDS.CLICK_ON, 0.5, 1.3)
        else
            Utilities.playSound(SOUNDS.CLICK_OFF, 0.4, 0.9)
        end
        if callback then callback(state) end
    end)
    
    container.MouseEnter:Connect(function()
        if not state then
            Utilities.tween(container, 0.15, {
                BackgroundColor3 = COLORS.panelHover,
            })
        end
        Utilities.playSound(SOUNDS.HOVER, 0.1, 1.5)
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
            Utilities.playSound(SOUNDS.CLICK_ON, 0.3, 1.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
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

function UILibrary.createInfoLabel(text, color)
    local label = Utilities.createInstance("TextLabel", {
        Text = text,
        TextSize = 12,
        TextColor3 = color or COLORS.textDark,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = COLORS.panel,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    
    Utilities.createInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, label)
    
    return label
end

-- ====================================================================
--  SECTION 6: FEATURE MODULES - MOVEMENT
-- ====================================================================

local Modules = {}

-- FLY MODULE
local flyConnection, flyBodyVelocity, flyBodyGyro
function Modules.fly(enabled)
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

-- NOCLIP MODULE
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

-- SPEED MODULE
local speedConnection
function Modules.speed(enabled)
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    
    if enabled then
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

-- SPIDER MODULE
local spiderConnection
function Modules.spider(enabled)
    if spiderConnection then spiderConnection:Disconnect() spiderConnection = nil end
    
    if enabled then
        spiderConnection = RunService.Stepped:Connect(function()
            local hrp = Utilities.getHumanoidRootPart()
            if not hrp then return end
            
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

-- BLINK MODULE
local blinkData = {
    serverPosition = nil,
    serverCFrame = nil,
    isActive = false,
}
local blinkRenderConnection
local blinkSteppedConnection

function Modules.blink(enabled)
    if blinkRenderConnection then blinkRenderConnection:Disconnect() blinkRenderConnection = nil end
    if blinkSteppedConnection then blinkSteppedConnection:Disconnect() blinkSteppedConnection = nil end
    
    if enabled then
        local hrp = Utilities.getHumanoidRootPart()
        if not hrp then return end
        
        blinkData.serverPosition = hrp.Position
        blinkData.serverCFrame = hrp.CFrame
        blinkData.isActive = true
        
        blinkSteppedConnection = RunService.Stepped:Connect(function()
            local hrpCheck = Utilities.getHumanoidRootPart()
            if not hrpCheck or not blinkData.isActive then return end
            hrpCheck.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrpCheck.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        
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
                hrp2.CFrame = hrp2.CFrame + (moveDirection * speed * dt)
            end
        end)
        
        Utilities.notification("Acyr v2", "Blink enabled - Server stays put, you move freely", 3)
    else
        blinkData.isActive = false
        if blinkData.serverCFrame then
            local hrp = Utilities.getHumanoidRootPart()
            if hrp then hrp.CFrame = blinkData.serverCFrame end
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

-- ====================================================================
--  SECTION 7: FEATURE MODULES - COMBAT & RENDER
-- ====================================================================

-- AUTOCLICKER MODULE
local autoclickerConnection
function Modules.autoClicker(enabled)
    if autoclickerConnection then autoclickerConnection:Disconnect() autoclickerConnection = nil end
    
    if enabled then
        local elapsed = 0
        
        autoclickerConnection = RunService.Heartbeat:Connect(function(deltaTime)
            local cps = State.autoclicker_cps or 10
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
        Utilities.notification("Acyr v2", "AutoClicker enabled (" .. math.floor(State.autoclicker_cps or 10) .. " CPS)", 2)
    else
        Utilities.notification("Acyr v2", "AutoClicker disabled", 2)
    end
end

-- ESP MODULE
local espFolder
local espPlayerAddedConnection
local espCharacterConnections = {}
function Modules.esp(enabled)
    if espFolder then espFolder:Destroy() espFolder = nil end
    if espPlayerAddedConnection then espPlayerAddedConnection:Disconnect() espPlayerAddedConnection = nil end
    for _, conn in pairs(espCharacterConnections) do
        if conn then conn:Disconnect() end
    end
    espCharacterConnections = {}
    
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
        
        espPlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
            local charConn = player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if State.esp then createESPBox(player) end
            end)
            table.insert(espCharacterConnections, charConn)
        end)
        Utilities.notification("Acyr v2", "ESP enabled", 2)
    else
        Utilities.notification("Acyr v2", "ESP disabled", 2)
    end
end

-- XRAY MODULE
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

-- STRETCHED RESOLUTION MODULE
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

-- STAFF DETECTOR MODULE
local staffDetectorConnection
function Modules.staffDetector(enabled)
    if staffDetectorConnection then staffDetectorConnection:Disconnect() staffDetectorConnection = nil end
    
    if enabled then
        local function checkPlayer(player)
            pcall(function()
                if player:GetRankInGroup(game.CreatorId) > 0 then
                    Utilities.notification("STAFF ALERT", player.Name .. " is a staff member!", 5)
                end
            end)
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

-- ====================================================================
--  SECTION 8: FUN MODULES (Harmless cosmetic features)
-- ====================================================================

-- BIG HEAD MODULE
function Modules.bigHead(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    local head = character:FindFirstChild("Head")
    if head then
        if enabled then
            head.Size = Vector3.new(4, 4, 4)
        else
            head.Size = Vector3.new(2, 1, 1)
        end
    end
    Utilities.notification("Acyr v2", enabled and "Big Head ON" or "Big Head OFF", 2)
end

-- TINY MODULE
function Modules.tiny(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local bodyScale = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
        for _, scaleName in ipairs(bodyScale) do
            local scale = humanoid:FindFirstChild(scaleName)
            if scale then scale.Value = enabled and 0.3 or 1 end
        end
    end
    Utilities.notification("Acyr v2", enabled and "Tiny mode ON" or "Tiny mode OFF", 2)
end

-- GIANT MODULE
function Modules.giant(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local bodyScale = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
        for _, scaleName in ipairs(bodyScale) do
            local scale = humanoid:FindFirstChild(scaleName)
            if scale then scale.Value = enabled and 3 or 1 end
        end
    end
    Utilities.notification("Acyr v2", enabled and "Giant mode ON" or "Giant mode OFF", 2)
end

-- RAINBOW MODULE
local rainbowConnection
function Modules.rainbow(enabled)
    if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
    
    if enabled then
        local hue = 0
        rainbowConnection = RunService.Heartbeat:Connect(function(dt)
            hue = (hue + dt * 0.5) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            local character = Utilities.getCharacter()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        pcall(function() part.Color = color end)
                    end
                end
            end
        end)
        Utilities.notification("Acyr v2", "Rainbow enabled", 2)
    else
        Utilities.notification("Acyr v2", "Rainbow disabled", 2)
    end
end

-- SPIN MODULE
local spinConnection
function Modules.spin(enabled)
    if spinConnection then spinConnection:Disconnect() spinConnection = nil end
    
    if enabled then
        spinConnection = RunService.Heartbeat:Connect(function(dt)
            local hrp = Utilities.getHumanoidRootPart()
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360 * dt * 2), 0)
            end
        end)
        Utilities.notification("Acyr v2", "Spin enabled - WHEEE!", 2)
    else
        Utilities.notification("Acyr v2", "Spin disabled", 2)
    end
end

-- UPSIDE DOWN MODULE
function Modules.upsideDown(enabled)
    local hrp = Utilities.getHumanoidRootPart()
    if hrp then
        if enabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(180), 0, 0)
        else
            local pos = hrp.Position
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, 0)
        end
    end
    Utilities.notification("Acyr v2", enabled and "Upside Down ON" or "Upside Down OFF", 2)
end

-- HEADLESS MODULE
local headlessOriginalTransparency
function Modules.headless(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    local head = character:FindFirstChild("Head")
    if head then
        if enabled then
            headlessOriginalTransparency = head.Transparency
            head.Transparency = 1
            local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
            if face then face.Transparency = 1 end
        else
            head.Transparency = headlessOriginalTransparency or 0
            local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
            if face then face.Transparency = 0 end
        end
    end
    Utilities.notification("Acyr v2", enabled and "Headless ON" or "Headless OFF", 2)
end

-- DISCO MODULE
local discoConnection
function Modules.disco(enabled)
    if discoConnection then discoConnection:Disconnect() discoConnection = nil end
    
    if enabled then
        local hue = 0
        discoConnection = RunService.Heartbeat:Connect(function(dt)
            hue = (hue + dt * 2) % 1
            local color = Color3.fromHSV(hue, 0.8, 1)
            Lighting.Ambient = color
            Lighting.OutdoorAmbient = color
            Lighting.FogColor = color
        end)
        Utilities.notification("Acyr v2", "Disco mode ON!", 2)
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.FogColor = Color3.fromRGB(192, 192, 192)
        Utilities.notification("Acyr v2", "Disco mode OFF", 2)
    end
end

-- NOODLE ARMS MODULE
function Modules.noodleArms(enabled)
    local character = Utilities.getCharacter()
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local armWidthScale = humanoid:FindFirstChild("BodyWidthScale")
        local armDepthScale = humanoid:FindFirstChild("BodyDepthScale")
        if armWidthScale then armWidthScale.Value = enabled and 0.2 or 1 end
        if armDepthScale then armDepthScale.Value = enabled and 0.2 or 1 end
    end
    Utilities.notification("Acyr v2", enabled and "Noodle Arms ON" or "Noodle Arms OFF", 2)
end

-- ====================================================================
--  SECTION 9: MAIN UI CONSTRUCTION (FULL-SCREEN)
-- ====================================================================

-- Cleanup existing UI
for _, element in pairs(CoreGui:GetChildren()) do
    if element.Name == "AcyrV2MainUI" then
        element:Destroy()
    end
end

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

-- Main container - columns at TOP of screen
local mainContainer = Utilities.createInstance("Frame", {
    Name = "MainContainer",
    Size = UDim2.new(1, -80, 1, -80),
    Position = UDim2.new(0, 40, 0, 40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, background)

Utilities.createInstance("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
}, mainContainer)

-- ====================================================================
--  SECTION 10: BUILD UI SECTIONS (6 columns)
-- ====================================================================

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
    
    local aimbotToggle = UILibrary.createToggle("Aim Assist", State.aimbot, COLORS.combat, function(v)
        State.aimbot = v
        Modules.aimbot(v)
        persistState()
    end)
    aimbotToggle.LayoutOrder = 3
    aimbotToggle.Parent = content
    
    local aimbotFovSlider = UILibrary.createSlider("Aim FOV", 20, 300, State.aimbot_fov, function(v)
        State.aimbot_fov = v
    end)
    aimbotFovSlider.LayoutOrder = 4
    aimbotFovSlider.Parent = content
    
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
    
    local fullbrightToggle = UILibrary.createToggle("Fullbright", State.fullbright, COLORS.render, function(v)
        State.fullbright = v
        Modules.fullbright(v)
        persistState()
    end)
    fullbrightToggle.LayoutOrder = 3
    fullbrightToggle.Parent = content
    
    local stretchedToggle = UILibrary.createToggle("Stretched Res", State.stretched, COLORS.render, function(v)
        State.stretched = v
        Modules.stretched(v)
        persistState()
    end)
    stretchedToggle.LayoutOrder = 4
    stretchedToggle.Parent = content
    
    local stretchedFOVSlider = UILibrary.createSlider("Stretched FOV", 70, 140, State.stretched_fov, function(v)
        State.stretched_fov = v
        if State.stretched then Camera.FieldOfView = v end
    end)
    stretchedFOVSlider.LayoutOrder = 5
    stretchedFOVSlider.Parent = content
    
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
    
    local staffDetectorToggle = UILibrary.createToggle("Staff Detector", State.staff_detector, COLORS.player, function(v)
        State.staff_detector = v
        Modules.staffDetector(v)
        persistState()
    end)
    staffDetectorToggle.LayoutOrder = 1
    staffDetectorToggle.Parent = content
    
    local thirdPersonToggle = UILibrary.createToggle("Third Person", State.third_person, COLORS.player, function(v)
        State.third_person = v
        Modules.thirdPerson(v)
        persistState()
    end)
    thirdPersonToggle.LayoutOrder = 2
    thirdPersonToggle.Parent = content
    
    local airJumpToggle = UILibrary.createToggle("Air Jump", State.air_jump, COLORS.player, function(v)
        State.air_jump = v
        Modules.airJump(v)
        persistState()
    end)
    airJumpToggle.LayoutOrder = 3
    airJumpToggle.Parent = content
    
    local antiKBToggle = UILibrary.createToggle("Anti Knockback", State.anti_kb, COLORS.player, function(v)
        State.anti_kb = v
        Modules.antiKB(v)
        persistState()
    end)
    antiKBToggle.LayoutOrder = 4
    antiKBToggle.Parent = content
    
    local godmodeToggle = UILibrary.createToggle("Godmode", State.godmode, COLORS.player, function(v)
        State.godmode = v
        Modules.godmode(v)
        persistState()
    end)
    godmodeToggle.LayoutOrder = 5
    godmodeToggle.Parent = content
    
    local invisibleToggle = UILibrary.createToggle("Invisible", State.invisible, COLORS.player, function(v)
        State.invisible = v
        Modules.invisible(v)
        persistState()
    end)
    invisibleToggle.LayoutOrder = 6
    invisibleToggle.Parent = content
    
    sections.player = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- SETTINGS SECTION
do
    local section, content = UILibrary.createSection("Settings", COLORS.settings)
    section.LayoutOrder = 5
    section.Parent = mainContainer
    
    local notifToggle = UILibrary.createToggle("Notifications", State.notifications, COLORS.settings, function(v)
        State.notifications = v
        persistState()
    end)
    notifToggle.LayoutOrder = 1
    notifToggle.Parent = content
    
    local clickSoundToggle = UILibrary.createToggle("Click Sounds", State.click_sounds, COLORS.settings, function(v)
        State.click_sounds = v
        persistState()
    end)
    clickSoundToggle.LayoutOrder = 2
    clickSoundToggle.Parent = content
    
    local arraylistToggle = UILibrary.createToggle("ArrayList", State.arraylist, COLORS.settings, function(v)
        State.arraylist = v
        persistState()
    end)
    arraylistToggle.LayoutOrder = 3
    arraylistToggle.Parent = content
    
    local targetHudToggle = UILibrary.createToggle("Target HUD", State.target_hud, COLORS.settings, function(v)
        State.target_hud = v
        persistState()
    end)
    targetHudToggle.LayoutOrder = 4
    targetHudToggle.Parent = content
    
    local versionLabel = UILibrary.createInfoLabel("Acyr v" .. CONFIG.VERSION, COLORS.text)
    versionLabel.LayoutOrder = 10
    versionLabel.Parent = content
    
    local creditsLabel = UILibrary.createInfoLabel("Made by Acy", COLORS.textDark)
    creditsLabel.LayoutOrder = 11
    creditsLabel.Parent = content
    
    local keybindsLabel = UILibrary.createInfoLabel("J: Menu | F: Fly | N: Noclip", COLORS.textDark)
    keybindsLabel.LayoutOrder = 12
    keybindsLabel.Parent = content
    
    local panicLabel = UILibrary.createInfoLabel("Delete: Panic (disable all)", COLORS.error)
    panicLabel.LayoutOrder = 13
    panicLabel.Parent = content
    
    local resetBtn = UILibrary.createButton("Reset All Settings", UDim2.new(1, 0, 0, 32), COLORS.error, function()
        for key, value in pairs(State) do
            if type(value) == "boolean" then
                State[key] = false
            end
        end
        State.notifications = true
        State.click_sounds = true
        State.arraylist = true
        State.fly_speed = 50
        State.speed_val = 50
        State.blink_speed = 30
        State.stretched_fov = 120
        State.autoclicker_cps = 10
        State.aimbot_fov = 100
        
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
        Modules.staffDetector(false)
        Modules.godmode(false)
        Modules.invisible(false)
        Modules.autoClicker(false)
        Modules.bigHead(false)
        Modules.tiny(false)
        Modules.giant(false)
        Modules.rainbow(false)
        Modules.spin(false)
        Modules.disco(false)
        Modules.headless(false)
        Modules.noodleArms(false)
        
        persistState()
        Utilities.notification("Acyr v2", "All settings reset!", 3)
    end)
    resetBtn.LayoutOrder = 20
    resetBtn.Parent = content
    
    sections.settings = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- FUN SECTION
do
    local section, content = UILibrary.createSection("Fun", COLORS.fun)
    section.LayoutOrder = 6
    section.Parent = mainContainer
    
    local bigHeadToggle = UILibrary.createToggle("Big Head", State.big_head, COLORS.fun, function(v)
        State.big_head = v
        Modules.bigHead(v)
        persistState()
    end)
    bigHeadToggle.LayoutOrder = 1
    bigHeadToggle.Parent = content
    
    local tinyToggle = UILibrary.createToggle("Tiny", State.tiny, COLORS.fun, function(v)
        State.tiny = v
        if v then State.giant = false end
        Modules.tiny(v)
        persistState()
    end)
    tinyToggle.LayoutOrder = 2
    tinyToggle.Parent = content
    
    local giantToggle = UILibrary.createToggle("Giant", State.giant, COLORS.fun, function(v)
        State.giant = v
        if v then State.tiny = false end
        Modules.giant(v)
        persistState()
    end)
    giantToggle.LayoutOrder = 3
    giantToggle.Parent = content
    
    local rainbowToggle = UILibrary.createToggle("Rainbow", State.rainbow, COLORS.fun, function(v)
        State.rainbow = v
        Modules.rainbow(v)
        persistState()
    end)
    rainbowToggle.LayoutOrder = 4
    rainbowToggle.Parent = content
    
    local spinToggle = UILibrary.createToggle("Spin", State.spin, COLORS.fun, function(v)
        State.spin = v
        Modules.spin(v)
        persistState()
    end)
    spinToggle.LayoutOrder = 5
    spinToggle.Parent = content
    
    local upsideDownToggle = UILibrary.createToggle("Upside Down", State.upside_down, COLORS.fun, function(v)
        State.upside_down = v
        Modules.upsideDown(v)
        persistState()
    end)
    upsideDownToggle.LayoutOrder = 6
    upsideDownToggle.Parent = content
    
    local headlessToggle = UILibrary.createToggle("Headless", State.headless, COLORS.fun, function(v)
        State.headless = v
        Modules.headless(v)
        persistState()
    end)
    headlessToggle.LayoutOrder = 7
    headlessToggle.Parent = content
    
    local discoToggle = UILibrary.createToggle("Disco", State.disco, COLORS.fun, function(v)
        State.disco = v
        Modules.disco(v)
        persistState()
    end)
    discoToggle.LayoutOrder = 8
    discoToggle.Parent = content
    
    local noodleToggle = UILibrary.createToggle("Noodle Arms", State.noodle_arms, COLORS.fun, function(v)
        State.noodle_arms = v
        Modules.noodleArms(v)
        persistState()
    end)
    noodleToggle.LayoutOrder = 9
    noodleToggle.Parent = content
    
    sections.fun = {section = section, content = content}
    table.insert(sectionOrder, section)
end

-- ====================================================================
--  SECTION 11: ARRAYLIST (RIGHT SIDE)
-- ====================================================================

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
    for _, label in pairs(arrayListLabels) do
        if label and label.Parent then label:Destroy() end
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
        {key = "autoclicker", name = "AutoClicker"},
        {key = "aimbot", name = "AimAssist"},
        {key = "godmode", name = "Godmode"},
        {key = "invisible", name = "Invisible"},
        {key = "anti_kb", name = "AntiKB"},
        {key = "third_person", name = "ThirdPerson"},
        {key = "air_jump", name = "AirJump"},
        {key = "staff_detector", name = "StaffDetect"},
        {key = "target_hud", name = "TargetHUD"},
        {key = "big_head", name = "BigHead"},
        {key = "tiny", name = "Tiny"},
        {key = "giant", name = "Giant"},
        {key = "rainbow", name = "Rainbow"},
        {key = "spin", name = "Spin"},
        {key = "upside_down", name = "UpsideDown"},
        {key = "headless", name = "Headless"},
        {key = "disco", name = "Disco"},
        {key = "noodle_arms", name = "NoodleArms"},
    }
    
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
        Utilities.createInstance("UIPadding", {PaddingRight = UDim.new(0, 6)}, label)
        
        table.insert(arrayListLabels, label)
    end
end

task.spawn(function()
    while true do
        updateArrayList()
        task.wait(0.5)
    end
end)

-- ====================================================================
--  SECTION 12: UI ANIMATION & STATE MANAGEMENT
--  Columns fly UP from below into position at the top
-- ====================================================================

local UIState = {
    isOpen = false,
    isAnimating = false,
}

local function animateUIIn()
    if UIState.isOpen or UIState.isAnimating then return end
    UIState.isOpen = true
    UIState.isAnimating = true
    
    MainScreenGui.Enabled = true
    Utilities.playSound(SOUNDS.OPEN, 0.6, 1.0)
    
    background.BackgroundTransparency = 1
    Utilities.tween(background, CONFIG.ANIMATION_SPEED, {
        BackgroundTransparency = 0.35,
    })
    
    for i, section in ipairs(sectionOrder) do
        section.Position = UDim2.new(0, 0, 0, 120)
        section.Size = UDim2.new(0, CONFIG.SECTION_WIDTH, 0, CONFIG.SECTION_HEIGHT)
        
        for _, child in pairs(section:GetDescendants()) do
            if child:IsA("GuiObject") then child.Visible = true end
        end
        
        task.delay((i - 1) * CONFIG.STAGGER_DELAY, function()
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
    
    Utilities.playSound(SOUNDS.CLOSE, 0.4, 0.8)
    
    for i = #sectionOrder, 1, -1 do
        local section = sectionOrder[i]
        local reverseIndex = #sectionOrder - i
        
        task.delay(reverseIndex * CONFIG.STAGGER_DELAY, function()
            Utilities.tween(section, CONFIG.ANIMATION_SPEED * 0.8, {
                Position = UDim2.new(0, 0, 0, 120),
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        end)
    end
    
    Utilities.tween(background, CONFIG.ANIMATION_SPEED, {
        BackgroundTransparency = 1,
    })
    
    task.delay(#sectionOrder * CONFIG.STAGGER_DELAY + CONFIG.ANIMATION_SPEED, function()
        MainScreenGui.Enabled = false
        UIState.isAnimating = false
    end)
end

-- ====================================================================
--  SECTION 13: KEYBINDS & INPUT HANDLING
-- ====================================================================

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
        for key, value in pairs(State) do
            if type(value) == "boolean" then State[key] = false end
        end
        State.notifications = true
        State.click_sounds = true
        State.arraylist = true
        
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
        Modules.staffDetector(false)
        Modules.godmode(false)
        Modules.invisible(false)
        Modules.autoClicker(false)
        Modules.bigHead(false)
        Modules.tiny(false)
        Modules.giant(false)
        Modules.rainbow(false)
        Modules.spin(false)
        Modules.disco(false)
        Modules.headless(false)
        Modules.noodleArms(false)
        
        animateUIOut()
        Utilities.notification("Acyr v2", "PANIC - All features disabled", 3)
        persistState()
    end
end)

-- ====================================================================
--  SECTION 14: AUTO-LOAD & INITIALIZATION
-- ====================================================================

task.spawn(function()
    task.wait(0.5)
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
    if State.staff_detector then Modules.staffDetector(true) end
    if State.big_head then Modules.bigHead(true) end
    if State.tiny then Modules.tiny(true) end
    if State.giant then Modules.giant(true) end
    if State.rainbow then Modules.rainbow(true) end
    if State.spin then Modules.spin(true) end
    if State.disco then Modules.disco(true) end
    if State.headless then Modules.headless(true) end
    if State.noodle_arms then Modules.noodleArms(true) end
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.fly then Modules.fly(true) end
    if State.noclip then Modules.noclip(true) end
    if State.speed then Modules.speed(true) end
    if State.godmode then Modules.godmode(true) end
    if State.blink then Modules.blink(true) end
    if State.air_jump then Modules.airJump(true) end
    if State.anti_kb then Modules.antiKB(true) end
    if State.big_head then Modules.bigHead(true) end
    if State.rainbow then Modules.rainbow(true) end
    if State.spin then Modules.spin(true) end
end)

-- ====================================================================
--  SECTION 15: INITIALIZATION & STARTUP MESSAGE
-- ====================================================================

MainScreenGui.Enabled = false

Utilities.notification("Acyr v2", "Loaded successfully!", 3)
Utilities.notification("Acyr v2", "Press J to toggle UI | F to fly | N to noclip | Delete to panic", 5)

print("[Acyr v2] Script loaded successfully!")
print("[Acyr v2] Version " .. CONFIG.VERSION)
print("[Acyr v2] Full-screen UI with smooth staggered animations")
print("[Acyr v2] All modules active and ready")
print("[Acyr v2] Press J to open the menu")

-- ====================================================================
--  END OF SCRIPT
-- ====================================================================
