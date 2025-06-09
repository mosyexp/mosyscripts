-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local hitboxSize = 5
local hitboxTransparency = 0.5
local hitboxOn = false
local reloadOn = false
local antiAimOn = false
local glitchRadius = 12
local glitchInterval = 0.05

local glitchTimer = 0
local originalCFrame = nil
local cameraHeightOffset = Vector3.new(0, 3, 0)

-- Load Luna UI
local Luna = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua',
        true
    )
)()

local Window = Luna:CreateWindow({
    Name = 'Mosy Hub',
    Subtitle = 'Murder vs Sheriff',
    LogoID = '111108278176277',
    LoadingEnabled = true,
    LoadingTitle = 'Loading Mosy Hub...',
    LoadingSubtitle = 'Murder vs Sheriff',
    ConfigSettings = {
        RootFolder = 'Mosy',
        ConfigFolder = 'Configs',
        AutoLoadConfig = true,
    },
})

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = 'Main',
    Icon = 'settings',
    ImageSource = 'Material',
    ShowTitle = true,
})

-- Hitbox Expander Functions
local function updateHitboxes()
    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            head.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            head.Transparency = hitboxTransparency
            head.CanCollide = false
            head.Massless = true
            local face = head:FindFirstChild("face")
            if face then face:Destroy() end
        end
    end
end

local function resetHitboxes()
    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            head.Size = Vector3.new(2, 1, 1)
            head.Transparency = 0
        end
    end
end

-- Hitbox Expander Section
MainTab:CreateSection("Hitbox Expander")

MainTab:CreateToggle({
    Name = 'Toggle Head Hitbox',
    CurrentValue = false,
    Callback = function(Value)
        hitboxOn = Value
        if hitboxOn then 
            updateHitboxes() 
        else 
            resetHitboxes() 
        end
    end,
})

MainTab:CreateSlider({
    Name = 'Hitbox Size',
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 5,
    Callback = function(Value)
        hitboxSize = Value
        if hitboxOn then updateHitboxes() end
    end,
})

MainTab:CreateSlider({
    Name = 'Hitbox Transparency',
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(Value)
        hitboxTransparency = Value
        if hitboxOn then updateHitboxes() end
    end,
})

-- Instant Reload Section
MainTab:CreateSection("Instant Reload")

MainTab:CreateToggle({
    Name = 'Toggle Instant Reload',
    CurrentValue = false,
    Callback = function(Value)
        reloadOn = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if not reloadOn then return end
    for _, plr in Players:GetPlayers() do
        local function clearCooldown(tool)
            if tool:IsA("Tool") and tool:GetAttribute("Cooldown") then
                tool:SetAttribute("Cooldown", 0)
            end
        end
        for _, tool in ipairs(plr.Backpack:GetChildren()) do clearCooldown(tool) end
        if plr.Character then
            for _, tool in ipairs(plr.Character:GetChildren()) do clearCooldown(tool) end
        end
    end
end)

-- Anti-Aim Section
MainTab:CreateSection("Anti-Aim")

MainTab:CreateToggle({
    Name = 'Enable Anti-Aim',
    CurrentValue = false,
    Callback = function(Value)
        antiAimOn = Value
        if antiAimOn then
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                originalCFrame = hrp.CFrame
            else
                antiAimOn = false
            end
        else
            originalCFrame = nil
        end
    end,
})

MainTab:CreateSlider({
    Name = 'Glitch Radius',
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 12,
    Callback = function(Value)
        glitchRadius = Value
    end,
})

MainTab:CreateSlider({
    Name = 'Glitch Frequency',
    Range = {0.01, 0.2},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(Value)
        glitchInterval = Value
    end,
})

RunService.RenderStepped:Connect(function(dt)
    if not antiAimOn then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not originalCFrame then originalCFrame = hrp.CFrame end
    camera.CFrame = originalCFrame + cameraHeightOffset
    hrp.CFrame = originalCFrame
    glitchTimer += dt
    if glitchTimer >= glitchInterval then
        glitchTimer = 0
        local offset = Vector3.new((math.random() - 0.5) * glitchRadius * 2, 0, (math.random() - 0.5) * glitchRadius * 2)
        hrp.CFrame = originalCFrame * CFrame.new(offset)
    end
end)

-- Config Tab
local ConfigTab = Window:CreateTab({
    Name = 'Config',
    Icon = 'settings',
    ImageSource = 'Material',
    ShowTitle = true,
})

ConfigTab:BuildConfigSection()
Window:CreateHomeTab({
    SupportedExecutors = { 'Synapse', 'ScriptWare', 'Krnl', 'Fluxus' },
    DiscordInvite = 'DR2RdatRjc',
    Icon = 1,
})

Luna:LoadAutoloadConfig()