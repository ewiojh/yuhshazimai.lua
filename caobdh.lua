if not game:IsLoaded() then game.Loaded:Wait() end

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end

local Camera = Workspace.CurrentCamera
local HAS_DRAWING = (Drawing ~= nil)

if _G.ZakaUnload then pcall(_G.ZakaUnload) end

--=====================================================================
-- 配置
--=====================================================================
local CFG = {
    ESP = {
        Enabled    = true,
        Box        = true,
        Health     = true,
        Name       = true,
        Distance   = true,
        Tracer     = false,
        Skeleton   = true,
        HeadDot    = true,
        TeamCheck  = true,
        MaxDist    = 1200,
        Color      = Color3.fromRGB(120, 205, 255),
        TeamColor  = Color3.fromRGB(120, 255, 160),
        Rainbow    = false,
        ProjMode   = "自研",
        OffsetY    = 0,
    },
    GAME = {
        Preset     = "自动",
    },
    AIM = {
        Enabled    = false,
        Hold       = false,
        FOV        = 220,
        Smooth     = 7,
        Part       = "头部",
        MaxDist    = 800,
        TeamCheck  = true,
        WallCheck  = true,
        Prediction = 0.14,
        Sticky     = true,
        ShowFOV    = true,
        Deadzone   = 1,
        MaxDegPerSec = 900,
        BulletSpeed  = 0,
        SwitchDelay  = 0.12,
        FOVColor   = Color3.fromRGB(150, 210, 255),
    },
}

local function D(kind)
    if not HAS_DRAWING then return nil end
    local ok, obj = pcall(Drawing.new, kind)
    if ok then return obj end
    return nil
end

local gethuiFn = gethui or function() return game:GetService("CoreGui") end
local parentGui
pcall(function() parentGui = gethuiFn() end)
if not parentGui then parentGui = LP:WaitForChild("PlayerGui", 10) end

local gui = Instance.new("ScreenGui")
gui.Name = "ZakaOverlay_" .. tostring(math.random(100000, 999999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = parentGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = inst
    return c
end

local function stroke(inst, col, th, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(255, 255, 255)
    s.Thickness = th or 1
    s.Transparency = trans or 0.75
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function pad(inst, a)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, a)
    p.PaddingRight  = UDim.new(0, a)
    p.PaddingTop    = UDim.new(0, a)
    p.PaddingBottom = UDim.new(0, a)
    p.Parent = inst
    return p
end

local MAIN_W, MAIN_H = 300, 430
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(MAIN_W, MAIN_H)
main.Position = UDim2.new(0, 24, 0.5, -MAIN_H / 2)
main.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
main.BackgroundTransparency = 0.12
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.Parent = gui
corner(main, 16)
local mainStroke = stroke(main, Color3.fromRGB(140, 200, 255), 1.2, 0.55)

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 0, 0, 90)
glow.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
glow.BackgroundTransparency = 0.9
glow.BorderSizePixel = 0
glow.Parent = main
corner(glow, 16)
local glowGrad = Instance.new("UIGradient")
glowGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(1, 1),
})
glowGrad.Rotation = 90
glowGrad.Parent = glow

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 46)
bar.BackgroundTransparency = 1
bar.Parent = main

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(9, 9)
dot.Position = UDim2.new(0, 16, 0, 19)
dot.BackgroundColor3 = Color3.fromRGB(110, 235, 175)
dot.BorderSizePixel = 0
dot.Parent = bar
corner(dot, 5)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 46)
title.Position = UDim2.new(0, 32, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ZAKA  //  ROBLOX"
title.TextColor3 = Color3.fromRGB(235, 245, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = bar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -36, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 100)
closeBtn.BackgroundTransparency = 0.72
closeBtn.Text = "×"
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 205)
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = bar
corner(closeBtn, 8)

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -32, 0, 1)
line.Position = UDim2.new(0, 16, 0, 46)
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BackgroundTransparency = 0.85
line.BorderSizePixel = 0
line.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -112)
scroll.Position = UDim2.new(0, 12, 0, 56)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 190, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local foot = Instance.new("Frame")
foot.Size = UDim2.new(1, -24, 0, 30)
foot.Position = UDim2.new(0, 12, 1, -42)
foot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
foot.BackgroundTransparency = 0.94
foot.BorderSizePixel = 0
foot.Parent = main
corner(foot, 8)

local statusTxt = Instance.new("TextLabel")
statusTxt.Size = UDim2.new(1, -16, 1, 0)
statusTxt.Position = UDim2.new(0, 8, 0, 0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "就绪 · 目标 0"
statusTxt.TextColor3 = Color3.fromRGB(170, 200, 230)
statusTxt.TextSize = 11
statusTxt.Font = Enum.Font.Gotham
statusTxt.TextXAlignment = Enum.TextXAlignment.Left
statusTxt.Parent = foot

--=====================================================================
-- 组件
--=====================================================================
local function addSection(text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 22)
    holder.BackgroundTransparency = 1
    holder.Parent = scroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(120, 175, 235)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder
    return holder
end

local function addToggle(text, default, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.955
    row.BorderSizePixel = 0
    row.Parent = scroll
    corner(row, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 235, 245)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(38, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = Color3.fromRGB(60, 68, 84)
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15, 15)
    knob.Position = UDim2.new(0, 2.5, 0.5, -7.5)
    knob.BackgroundColor3 = Color3.fromRGB(200, 210, 225)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    local state = default and true or false
    local function render()
        TweenService:Create(track, TweenInfo.new(0.16), {
            BackgroundColor3 = state and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(60, 68, 84)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.16), {
            Position = state and UDim2.new(1, -17.5, 0.5, -7.5) or UDim2.new(0, 2.5, 0.5, -7.5),
            BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 210, 225)
        }):Play()
    end
    render()

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        setter(state)
    end)

    return row
end

local function addSlider(text, min, max, default, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.955
    row.BorderSizePixel = 0
    row.Parent = scroll
    corner(row, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 235, 245)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 46, 0, 18)
    valLbl.Position = UDim2.new(1, -58, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(120, 190, 255)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 5)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(60, 68, 84)
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)

    local grab = Instance.new("TextButton")
    grab.Size = UDim2.new(1, 12, 0, 30)
    grab.Position = UDim2.new(0, -6, 0, 17)
    grab.BackgroundTransparency = 1
    grab.Text = ""
    grab.Parent = row

    local dragging = false
    local function applyFromX(px)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local t = math.clamp((px - abs) / w, 0, 1)
        local v = math.floor(min + (max - min) * t + 0.5)
        fill.Size = UDim2.new(t, 0, 1, 0)
        valLbl.Text = tostring(v)
        setter(v)
    end

    grab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            applyFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            applyFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

local function addChoice(text, options, defaultIdx, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.955
    row.BorderSizePixel = 0
    row.Parent = scroll
    corner(row, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 235, 245)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local idx = defaultIdx
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 92, 0, 24)
    btn.Position = UDim2.new(1, -102, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    btn.BackgroundTransparency = 0.55
    btn.Text = options[idx]
    btn.TextColor3 = Color3.fromRGB(235, 245, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = row
    corner(btn, 7)

    btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        btn.Text = options[idx]
        setter(options[idx], idx)
    end)

    return row
end

local PRESETS = {
    ["通用"]       = {FOV = 220, Smooth = 7,  Prediction = 0.14, ESPDist = 1200, AIMDist = 800},
    ["BloxStrike"] = {FOV = 165, Smooth = 5,  Prediction = 0.10, ESPDist = 1500, AIMDist = 950},
    ["防御模式"]   = {FOV = 285, Smooth = 10, Prediction = 0.22, ESPDist = 950,  AIMDist = 750},
}

local function detectedGameName()
    local n = "?"
    pcall(function() n = tostring(game.Name) end)
    return n
end

local function resolvePreset(name)
    if name ~= "自动" then return name end
    local n = string.lower(detectedGameName())
    if string.find(n, "strike", 1, true) or string.find(n, "blox", 1, true) then
        return "BloxStrike"
    elseif string.find(n, "defen", 1, true) or string.find(n, "防御", 1, true) then
        return "防御模式"
    end
    return "通用"
end

local function applyPreset(name)
    local key = resolvePreset(name)
    local pset = PRESETS[key]
    if not pset then return end
    CFG.AIM.FOV        = pset.FOV
    CFG.AIM.Smooth     = pset.Smooth
    CFG.AIM.Prediction = pset.Prediction
    CFG.ESP.MaxDist    = pset.ESPDist
    CFG.AIM.MaxDist    = pset.AIMDist
    if statusTxt then statusTxt.Text = "预设: " .. key end
    return key
end

addSection("透视  /  ESP")
addToggle("启用透视", CFG.ESP.Enabled, function(v) CFG.ESP.Enabled = v end)
addToggle("方框",     CFG.ESP.Box,     function(v) CFG.ESP.Box = v end)
addToggle("血条",     CFG.ESP.Health,  function(v) CFG.ESP.Health = v end)
addToggle("名字",     CFG.ESP.Name,    function(v) CFG.ESP.Name = v end)
addToggle("距离",     CFG.ESP.Distance,function(v) CFG.ESP.Distance = v end)
addToggle("骨骼线",   CFG.ESP.Skeleton,function(v) CFG.ESP.Skeleton = v end)
addToggle("锁定点",   CFG.ESP.HeadDot, function(v) CFG.ESP.HeadDot = v end)
addToggle("射线",     CFG.ESP.Tracer,  function(v) CFG.ESP.Tracer = v end)
addToggle("忽略队友", CFG.ESP.TeamCheck,function(v) CFG.ESP.TeamCheck = v end)
addToggle("流光配色", CFG.ESP.Rainbow, function(v) CFG.ESP.Rainbow = v end)
addSlider("透视距离", 100, 3000, CFG.ESP.MaxDist, function(v) CFG.ESP.MaxDist = v end)
addChoice("投影方式", {"自研", "原生"}, 1, function(v) CFG.ESP.ProjMode = v end)
addSlider("垂直校准", -80, 80, CFG.ESP.OffsetY, function(v) CFG.ESP.OffsetY = v end)

addSection("自瞄  /  AIM")
local functionPartIdx = 1
addToggle("启用自瞄", CFG.AIM.Enabled, function(v) CFG.AIM.Enabled = v end)
addToggle("按住才瞄", CFG.AIM.Hold,    function(v) CFG.AIM.Hold = v end)
addToggle("锁定目标", CFG.AIM.Sticky,  function(v) CFG.AIM.Sticky = v end)
addToggle("显示 FOV", CFG.AIM.ShowFOV, function(v) CFG.AIM.ShowFOV = v end)
addToggle("忽略队友", CFG.AIM.TeamCheck,function(v) CFG.AIM.TeamCheck = v end)
addToggle("隔墙不瞄", CFG.AIM.WallCheck,function(v) CFG.AIM.WallCheck = v end)
addChoice("瞄准部位", {"头部", "躯干", "智能"}, 1, function(v, i)
    functionPartIdx = i
    CFG.AIM.Part = v
end)
addSlider("FOV 半径", 40, 600, CFG.AIM.FOV, function(v) CFG.AIM.FOV = v end)
addSlider("平滑度", 1, 30, CFG.AIM.Smooth, function(v) CFG.AIM.Smooth = v end)
addSlider("预判量", 0, 60, math.floor(CFG.AIM.Prediction * 100), function(v) CFG.AIM.Prediction = v / 100 end)
addSlider("瞄准距离", 100, 2000, CFG.AIM.MaxDist, function(v) CFG.AIM.MaxDist = v end)
addSlider("死区(度)", 0, 6, CFG.AIM.Deadzone, function(v) CFG.AIM.Deadzone = v end)
addSlider("最大转速", 180, 1800, CFG.AIM.MaxDegPerSec, function(v) CFG.AIM.MaxDegPerSec = v end)
addSlider("弹速 0=关", 0, 4000, CFG.AIM.BulletSpeed, function(v) CFG.AIM.BulletSpeed = v end)
addSlider("换人延迟ms", 0, 600, 120, function(v) CFG.AIM.SwitchDelay = v / 1000 end)

addSection("适配  /  GAME")
addChoice("游戏预设", {"自动", "通用", "BloxStrike", "防御模式"}, 1, function(v) applyPreset(v) end)

-- [插入点 A] 下面这段是新增的缩小按钮+悬浮球，接在你原代码后面
local BALL = 54
local ball = Instance.new("TextButton")
ball.Size = UDim2.fromOffset(BALL, BALL)
ball.Position = UDim2.new(0, 22, 0.5, 130)
ball.BackgroundColor3 = Color3.fromRGB(15, 19, 29)
ball.BackgroundTransparency = 0.18
ball.BorderSizePixel = 0
ball.AutoButtonColor = false
ball.Text = ""
ball.Visible = false
ball.ZIndex = 50
ball.Parent = gui
corner(ball, math.floor(BALL / 2))
local ballStroke = stroke(ball, Color3.fromRGB(130, 200, 255), 1.6, 0.4)

local ballTxt = Instance.new("TextLabel")
ballTxt.Size = UDim2.new(1, 0, 1, 0)
ballTxt.BackgroundTransparency = 1
ballTxt.Text = "Z"
ballTxt.TextColor3 = Color3.fromRGB(200, 230, 255)
ballTxt.TextSize = 21
ballTxt.Font = Enum.Font.GothamBold
ballTxt.Active = false
ballTxt.ZIndex = 51
ballTxt.Parent = ball

local shrinkBtn = Instance.new("TextButton")
shrinkBtn.Size = UDim2.fromOffset(26, 26)
shrinkBtn.Position = UDim2.new(1, -70, 0, 10)
shrinkBtn.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
shrinkBtn.BackgroundTransparency = 0.78
shrinkBtn.Text = "—"
shrinkBtn.TextSize = 17
shrinkBtn.Font = Enum.Font.GothamBold
shrinkBtn.TextColor3 = Color3.fromRGB(220, 240, 255)
shrinkBtn.BorderSizePixel = 0
shrinkBtn.AutoButtonColor = false
shrinkBtn.Parent = bar
corner(shrinkBtn, 8)

shrinkBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    ball.Visible = true
end)

do
    local dragging, dragStart, origin, moved = false, nil, nil, false
    ball.MouseButton1Down:Connect(function()
        dragging = true; moved = false
        dragStart = UIS:GetMouseLocation()
        origin = ball.Position
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = UIS:GetMouseLocation() - dragStart
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
            ball.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    ball.MouseButton1Click:Connect(function()
        if not moved then
            main.Visible = true
            ball.Visible = false
        end
    end)
end
-- [插入点 A 结束]

--=====================================================================
-- 拖动（你原代码这段保留不动）
--=====================================================================
do
    local dragging, dragStart, startPos = false, nil, nil
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end--=====================================================================
-- ESP 实体
--=====================================================================
local visuals = {}          -- [player] = {...}

local BONES_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local view = { inv = nil, vp = nil, tanX = 1, tanY = 1, cf = nil, native = false }

local function cameraCFrame()
    local cf = Camera.CFrame
    local ok, rcf = pcall(function() return Camera:GetRenderCFrame() end)
    if ok and rcf then cf = rcf end
    return cf
end

local function refreshView()
    local vp = Camera.ViewportSize
    if not vp or vp.X < 1 or vp.Y < 1 then return false end
    local cf = cameraCFrame()
    if not cf then return false end
    local aspect = vp.X / vp.Y
    local fov = math.rad(Camera.FieldOfView)
    local mode = "Vertical"
    pcall(function()
        mode = string.gsub(tostring(Camera.FieldOfViewMode), "Enum.FieldOfViewMode.", "")
    end)
    local tanY
    if mode == "Horizontal" then
        tanY = math.tan(fov * 0.5) / aspect
    elseif mode == "Diagonal" then
        tanY = math.tan(fov * 0.5) / math.sqrt(aspect * aspect + 1)
    elseif mode == "MaxAxis" then
        tanY = math.tan(fov * 0.5) / math.max(aspect, 1)
    else
        tanY = math.tan(fov * 0.5)
    end
    view.cf = cf
    view.inv = cf:Inverse()
    view.vp = vp
    view.tanY = tanY
    view.tanX = tanY * aspect
    view.native = (CFG.ESP.ProjMode == "原生")
    return true
end

local function project(pos)
    if not view.inv then return nil end
    if view.native then
        local sp = Camera:WorldToViewportPoint(pos)
        if not sp or sp.Z <= 0.08 then return nil end
        return Vector2.new(sp.X, sp.Y + CFG.ESP.OffsetY), sp.Z
    end
    local rel = view.inv * pos
    local depth = -rel.Z
    if depth <= 0.08 then return nil end
    local nx = rel.X / (depth * view.tanX)
    local ny = rel.Y / (depth * view.tanY)
    if math.abs(nx) > 90 or math.abs(ny) > 90 then return nil end
    local vp = view.vp
    return Vector2.new((0.5 + nx * 0.5) * vp.X, (0.5 - ny * 0.5) * vp.Y + CFG.ESP.OffsetY), depth
end

local HEAD_NAMES = {"Head", "head", "HeadPart", "HumanoidHead", "HEAD"}
local FOOT_NAMES = {"LeftFoot", "RightFoot", "Left Leg", "Right Leg",
                    "LeftLowerLeg", "RightLowerLeg", "Foot", "Feet", "LeftFootPart"}
local HAND_NAMES = {"LeftHand", "RightHand", "Left Arm", "Right Arm",
                    "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm"}

local function findPart(char, names)
    for i = 1, #names do
        local p = char:FindFirstChild(names[i], true)
        if p and p:IsA("BasePart") then return p end
    end
    return nil
end

local MAX_BONES = 22

local function buildRig(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")

    local head = findPart(char, HEAD_NAMES)
    if not head then head = root end

    local footPart = findPart(char, FOOT_NAMES)

    local hip = 2
    if hum then
        local ok, h = pcall(function() return hum.HipHeight end)
        if ok and h and h > 0 then hip = h end
    end

    local hands = {}
    for i = 1, #HAND_NAMES do
        local p = char:FindFirstChild(HAND_NAMES[i], true)
        if p and p:IsA("BasePart") then table.insert(hands, p) end
    end

    local bones = {}
    local okB = pcall(function()
        for _, j in ipairs(char:GetDescendants()) do
            if j:IsA("Motor6D") and j.Part0 and j.Part1 then
                local n0, n1 = j.Part0.Name, j.Part1.Name
                if n0 ~= "HumanoidRootPart" and n1 ~= "HumanoidRootPart" then
                    table.insert(bones, {j.Part0, j.Part1})
                end
                if #bones >= MAX_BONES then break end
            end
        end
    end)
    if not okB or #bones == 0 then
        local r15 = char:FindFirstChild("UpperTorso") ~= nil
        local tbl = r15 and BONES_R15 or BONES_R6
        for i = 1, #tbl do
            local a = char:FindFirstChild(tbl[i][1], true)
            local b = char:FindFirstChild(tbl[i][2], true)
            if a and b then table.insert(bones, {a, b}) end
        end
    end

    return { head = head, footPart = footPart, hands = hands,
             bones = bones, root = root, hip = hip, hum = hum }
end

local function rigPoints(rig)
    local headTop, feet
    if rig.head then
        headTop = rig.head.Position + Vector3.new(0, rig.head.Size.Y * 0.5 + 0.05, 0)
    end
    if rig.footPart then
        feet = rig.footPart.Position - Vector3.new(0, rig.footPart.Size.Y * 0.5, 0)
    elseif rig.root then
        feet = rig.root.Position - Vector3.new(0, rig.hip + rig.root.Size.Y * 0.5, 0)
    end
    return headTop, feet
end

local function teamKey(plr)
    if plr.Team then
        local okN, nm = pcall(function() return plr.Team.Name end)
        if okN and nm ~= nil and nm ~= "" then return "T|" .. tostring(nm) end
    end
    local ok1, attr = pcall(function() return plr:GetAttribute("Team") end)
    if ok1 and attr then return "A|" .. tostring(attr) end
    local ok2, attr2 = pcall(function() return plr:GetAttribute("TeamId") end)
    if ok2 and attr2 then return "A2|" .. tostring(attr2) end
    local char = plr.Character
    if char then
        local ok3, tag = pcall(function()
            local inst = char:FindFirstChild("Team", true)
                or char:FindFirstChild("TeamName", true)
                or char:FindFirstChild("TEAM", true)
            if inst and inst.Value ~= nil then return tostring(inst.Value) end
            return nil
        end)
        if ok3 and tag then return "C|" .. tag end
    end
    if plr.TeamColor and LP.TeamColor then
        local okC, cl = pcall(function() return tostring(plr.TeamColor) end)
        if okC and cl and cl ~= "" then return "TC|" .. cl end
    end
    return nil
end

local function sameTeam(plr)
    if plr == LP then return true end
    local a = teamKey(plr)
    local b = teamKey(LP)
    if a ~= nil and b ~= nil then return a == b end
    return false
end

local function healthOf(char, hum)
    if hum and hum.MaxHealth and hum.MaxHealth > 0 then
        return math.clamp(hum.Health / hum.MaxHealth, 0, 1), hum.Health
    end
    local names = {"Health", "HP", "Hp", "health"}
    for i = 1, #names do
        local inst = char:FindFirstChild(names[i], true)
        if inst and inst.Value ~= nil and type(inst.Value) == "number" then
            return 1, inst.Value
        end
    end
    return 1, 0
end

local function deadFlag(char)
    local names = {"Dead", "IsDead", "dead", "IsSpectating"}
    for i = 1, #names do
        local inst = char:FindFirstChild(names[i], true)
        if inst and inst.Value == true then return true end
    end
    return false
end

local function newVisual()
    local v = {}
    if not HAS_DRAWING then return v end
    v.box      = D("Square")
    v.boxOut   = D("Square")
    v.hpBg     = D("Square")
    v.hpFill   = D("Square")
    v.name     = D("Text")
    v.dist     = D("Text")
    v.dot      = D("Circle")
    v.tracer   = D("Line")
    v.bones    = {}
    for i = 1, MAX_BONES do
        local l = D("Line")
        if l then table.insert(v.bones, l) end
    end

    if v.box then
        v.box.Filled = false
        v.box.Thickness = 1.4
    end
    if v.boxOut then
        v.boxOut.Filled = false
        v.boxOut.Thickness = 1
        v.boxOut.Color = Color3.fromRGB(0, 0, 0)
        v.boxOut.Transparency = 0.55
    end
    if v.hpBg then
        v.hpBg.Filled = true
        v.hpBg.Color = Color3.fromRGB(0, 0, 0)
        v.hpBg.Transparency = 0.45
    end
    if v.hpFill then
        v.hpFill.Filled = true
    end
    if v.name then
        v.name.Center = true
        v.name.Outline = true
        v.name.OutlineColor = Color3.fromRGB(0, 0, 0)
        v.name.Size = 13
        v.name.Font = 2
    end
    if v.dist then
        v.dist.Center = true
        v.dist.Outline = true
        v.dist.OutlineColor = Color3.fromRGB(0, 0, 0)
        v.dist.Size = 12
        v.dist.Font = 2
    end
    if v.dot then
        v.dot.Filled = true
        v.dot.Radius = 3
    end
    if v.tracer then
        v.tracer.Thickness = 1
    end
    for _, l in ipairs(v.bones) do
        l.Thickness = 1
    end
    return v
end

local function destroyVisual(v)
    for k, obj in pairs(v) do
        if k == "bones" then
            for _, l in ipairs(obj) do pcall(function() l:Remove() end) end
        else
            pcall(function() obj:Remove() end)
        end
    end
end

local function setVis(v, on)
    for k, obj in pairs(v) do
        if k == "bones" then
            for _, l in ipairs(obj) do pcall(function() l.Visible = on end) end
        else
            pcall(function() obj.Visible = on end)
        end
    end
end

local function getVisual(plr)
    if not visuals[plr] then
        visuals[plr] = newVisual()
    end
    return visuals[plr]
end

local function charOf(plr)
    local c = plr.Character
    if not c or not c.Parent then return nil end
    return c
end

local function alive(plr)
    local c = charOf(plr)
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    return c, h
end

local fovCircle = D("Circle")
if fovCircle then
    fovCircle.Thickness = 1.4
    fovCircle.Filled = false
    fovCircle.Transparency = 0.35
    fovCircle.NumSides = 64
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function clearView(targetPos)
    local filter = { Camera }
    if LP.Character then table.insert(filter, LP.Character) end
    rayParams.FilterDescendantsInstances = filter
    local dir = targetPos - Camera.CFrame.Position
    local hit = Workspace:Raycast(Camera.CFrame.Position, dir, rayParams)
    if not hit then return true end
    return (hit.Position - Camera.CFrame.Position).Magnitude >= dir.Magnitude - 1.5
end

local hue = 0
local function espColor(isTeam)
    if CFG.ESP.Rainbow then
        hue = (hue + 0.006) % 1
        return Color3.fromHSV(hue, 0.55, 1)
    end
    if isTeam then return CFG.ESP.TeamColor end
    return CFG.ESP.Color
end

local function getAimPart(char, mode)
    if mode == "头部" then
        return char:FindFirstChild("Head")
    elseif mode == "躯干" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    else
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if not head then return torso end
        local d = (head.Position - Camera.CFrame.Position).Magnitude
        if d > 350 then return torso or head end
        return head
    end
end

local frameCount = 0
local espErrShown = false

local function updateESP()
    if not HAS_DRAWING then return end
    if not CFG.ESP.Enabled then
        for _, v in pairs(visuals) do setVis(v, false) end
        return
    end
    if not refreshView() then return end

    local vpSize = view.vp
    local screenCenter = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    local camPos = view.cf.Position

    local alive_targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local c, h = alive(plr)
            if c and not deadFlag(c) then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                    or c:FindFirstChild("UpperTorso")
                    or c:FindFirstChild("Torso")
                if hrp then
                    local worldDist = (hrp.Position - camPos).Magnitude
                    if worldDist <= CFG.ESP.MaxDist then
                        table.insert(alive_targets, {plr = plr, char = c, hum = h, hrp = hrp, dist = worldDist})
                    end
                end
            end
        end
    end

    table.sort(alive_targets, function(a, b) return a.dist < b.dist end)

    local shown = {}
    for i, t in ipairs(alive_targets) do
        shown[t.plr] = true
        local v = getVisual(t.plr)
        local isTeam = sameTeam(t.plr)

        if CFG.ESP.TeamCheck and isTeam then
            setVis(v, false)
        else
            if v.rigChar ~= t.char then
                v.rigChar = t.char
                local okRig, rig = pcall(buildRig, t.char)
                if okRig and rig then v.rig = rig else v.rig = nil end
            end
            local rig = v.rig

            local pTop, pBot
            if rig then
                local headTop, feetPos = rigPoints(rig)
                if headTop then pTop = project(headTop) end
                if feetPos then pBot = project(feetPos) end
            end

            if pTop and pBot then
                setVis(v, true)
                local col = espColor(isTeam)

                local minX = math.min(pTop.X, pBot.X)
                local maxX = math.max(pTop.X, pBot.X)
                local minY = math.min(pTop.Y, pBot.Y)
                local maxY = math.max(pTop.Y, pBot.Y)

                for hi = 1, #rig.hands do
                    local hp = project(rig.hands[hi].Position)
                    if hp then
                        if hp.X < minX then minX = hp.X end
                        if hp.X > maxX then maxX = hp.X end
                        if hp.Y < minY then minY = hp.Y end
                        if hp.Y > maxY then maxY = hp.Y end
                    end
                end

                local hgt = maxY - minY
                local wdt = maxX - minX
                if hgt < 5 then hgt = 5 end
                if wdt < hgt * 0.28 then wdt = hgt * 0.28 end
                if wdt > hgt * 1.15 then wdt = hgt * 1.15 end

                local cx = (minX + maxX) * 0.5
                local x = cx - wdt * 0.5
                local y = minY
                local boxPos = Vector2.new(x, y)
                local boxSize = Vector2.new(wdt, hgt)

                if v.box then
                    v.box.Visible = CFG.ESP.Box
                    v.box.Position = boxPos
                    v.box.Size = boxSize
                    v.box.Color = col
                end
                if v.boxOut then
                    v.boxOut.Visible = CFG.ESP.Box
                    v.boxOut.Position = boxPos - Vector2.new(1, 1)
                    v.boxOut.Size = boxSize + Vector2.new(2, 2)
                end

                local hpRatio, hpVal = healthOf(t.char, t.hum)
                if v.hpBg and v.hpFill then
                    v.hpBg.Visible = CFG.ESP.Health
                    v.hpFill.Visible = CFG.ESP.Health
                    local barX = x - 6
                    v.hpBg.Position = Vector2.new(barX, y)
                    v.hpBg.Size = Vector2.new(3, hgt)
                    v.hpFill.Position = Vector2.new(barX, y + hgt * (1 - hpRatio))
                    v.hpFill.Size = Vector2.new(3, math.max(hgt * hpRatio, 0.5))
                    v.hpFill.Color = Color3.fromRGB(
                        math.clamp(math.floor(255 * (1 - hpRatio) + 90), 0, 255),
                        math.clamp(math.floor(255 * hpRatio + 40), 0, 255),
                        90
                    )
                end

                if v.name then
                    v.name.Visible = CFG.ESP.Name
                    v.name.Text = t.plr.Name
                    v.name.Position = Vector2.new(x + wdt / 2, y - 17)
                    v.name.Color = col
                end
                if v.dist then
                    v.dist.Visible = CFG.ESP.Distance
                    v.dist.Text = string.format("%dm", math.floor(t.dist))
                    v.dist.Position = Vector2.new(x + wdt / 2, y + hgt + 2)
                    v.dist.Color = col
                end

                if v.dot and rig.head then
                    local hs = project(rig.head.Position)
                    if hs then
                        v.dot.Visible = CFG.ESP.HeadDot
                        v.dot.Position = hs
                        v.dot.Color = col
                    else
                        v.dot.Visible = false
                    end
                end

                if v.tracer then
                    v.tracer.Visible = CFG.ESP.Tracer
                    v.tracer.From = Vector2.new(screenCenter.X, vpSize.Y)
                    v.tracer.To = Vector2.new(x + wdt / 2, y + hgt)
                    v.tracer.Color = col
                end

                local drawBones = CFG.ESP.Skeleton and i <= 16
                for bi = 1, #v.bones do
                    local l = v.bones[bi]
                    local pair = drawBones and rig.bones and rig.bones[bi]
                    if pair then
                        local sa = project(pair[1].Position)
                        local sb = project(pair[2].Position)
                        if sa and sb then
                            l.Visible = true
                            l.From = sa
                            l.To = sb
                            l.Color = col
                        else
                            l.Visible = false
                        end
                    else
                        l.Visible = false
                    end
                end
            else
                setVis(v, false)
            end
        end
    end

    for plr, v in pairs(visuals) do
        if not shown[plr] then setVis(v, false) end
    end
end

local aimTarget = nil
local lockedPlr = nil
local lostSince = nil
local pendingPlr, pendingSince = nil, 0
local visCache = {}

local function holdActive()
    if not CFG.AIM.Hold then return true end

    local function onPanel(p)
        if not main or not main.Visible then return false end
        local ap = main.AbsolutePosition
        local as = main.AbsoluteSize
        return p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y
    end

    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mp = UIS:GetMouseLocation()
        if not onPanel(mp) then return true end
    end
    local touches = UIS:GetTouches()
    for _, t in ipairs(touches) do
        if t.Position.X > Camera.ViewportSize.X * 0.5 and not onPanel(t.Position) then
            return true
        end
    end
    return false
end

local function visibleTo(part)
    local key = tostring(part)
    local now = tick()
    local c = visCache[key]
    if c and (now - c.t) < 0.12 then return c.v end
    local v = true
    local ok = pcall(function() v = clearView(part.Position) end)
    if not ok then v = true end
    visCache[key] = {v = v, t = now}
    return v
end

local function validateTarget(plr, center, camPos)
    if plr == nil or plr == LP then return nil end
    if CFG.AIM.TeamCheck and sameTeam(plr) then return nil end

    local c, h = alive(plr)
    if not c or deadFlag(c) then return nil end

    local part = getAimPart(c, CFG.AIM.Part)
    if not part then return nil end

    local worldDist = (part.Position - camPos).Magnitude
    if worldDist > CFG.AIM.MaxDist then return nil end

    local sp = project(part.Position)
    if not sp then return nil end

    local screenDist = (sp - center).Magnitude
    if screenDist > CFG.AIM.FOV then return nil end

    if CFG.AIM.WallCheck then
        if not visibleTo(part) then return nil end
    end

    local hpRatio = 1
    if h and h.MaxHealth and h.MaxHealth > 0 then
        hpRatio = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
    end

    local score = screenDist + hpRatio * 90 + (worldDist / CFG.AIM.MaxDist) * 120
    return { part = part, plr = plr, hum = h, score = score, dist = worldDist, screen = sp }
end

local function updateAim(dt)
    if not CFG.AIM.Enabled then
        aimTarget = nil
        lockedPlr = nil
        lostSince = nil
        pendingPlr = nil
        return
    end
    if not refreshView() then return end

    local vp = view.vp
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local camPos = view.cf.Position
    local now = tick()

    local best = nil
    if CFG.AIM.Sticky and lockedPlr then
        best = validateTarget(lockedPlr, center, camPos)
        if best then
            lostSince = nil
        else
            if not lostSince then lostSince = now end
            if (now - lostSince) > 0.25 then
                lockedPlr = nil
                lostSince = nil
            end
        end
    end

    if CFG.AIM.Sticky and lockedPlr and not best and lostSince then
        aimTarget = nil
        statusTxt.Text = string.format("目标丢失 · 搜索中")
        return
    end

    if not best then
        local cand, bestScore = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            local t = validateTarget(plr, center, camPos)
            if t and t.score < bestScore then
                bestScore = t.score
                cand = t
            end
        end

        if cand then
            if CFG.AIM.Sticky and lockedPlr ~= nil and cand.plr ~= lockedPlr then
                if pendingPlr ~= cand.plr then
                    pendingPlr = cand.plr
                    pendingSince = now
                end
                if (now - pendingSince) >= CFG.AIM.SwitchDelay then
                    lockedPlr = cand.plr
                    best = cand
                end
            else
                lockedPlr = cand.plr
                pendingPlr = cand.plr
                pendingSince = now
                best = cand
            end
        else
            lockedPlr = nil
            pendingPlr = nil
        end
    end

    aimTarget = best
    if not best then
        statusTxt.Text = string.format("搜索中 · %d 人在线", #Players:GetPlayers())
        return
    end
    statusTxt.Text = string.format("锁定 %s · %.0fm", best.plr.Name, best.dist)

    if not holdActive() then return end

    local predTime = CFG.AIM.Prediction
    if CFG.AIM.BulletSpeed and CFG.AIM.BulletSpeed > 1 then
        predTime = predTime + (best.dist / CFG.AIM.BulletSpeed) * 0.85
    end
    local aimPos = best.part.Position
    if predTime > 0 then
        local okV, vel = pcall(function() return best.part.AssemblyLinearVelocity end)
        if okV and vel then aimPos = aimPos + vel * predTime end
    end

    local curCF = Camera.CFrame
    local targetCF = CFrame.lookAt(curCF.Position, aimPos)
    local dot = math.clamp(curCF.LookVector:Dot(targetCF.LookVector), -1, 1)
    local ang = math.deg(math.acos(dot))

    if ang < CFG.AIM.Deadzone then return end

    local k = 55 / math.max(CFG.AIM.Smooth, 1)
    local alpha = 1 - math.exp(-k * dt)
    if ang > 0.02 then
        local maxStep = (CFG.AIM.MaxDegPerSec * dt) / ang
        if alpha > maxStep then alpha = maxStep end
    end
    alpha = math.clamp(alpha, 0, 1)
    Camera.CFrame = curCF:Lerp(targetCF, alpha)
endlocal conn
conn = RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1

    local pulse = (math.sin(tick() * 1.7) + 1) * 0.5
    mainStroke.Transparency = 0.38 + pulse * 0.42
    mainStroke.Color = Color3.fromRGB(120 + math.floor(40 * pulse), 190, 255)
    dot.BackgroundTransparency = 0.05 + pulse * 0.45

    -- [新增] 球呼吸灯
    if ball.Visible and ballStroke then
        ballStroke.Transparency = 0.26 + pulse * 0.42
        ballTxt.TextColor3 = Color3.fromRGB(180 + math.floor(50 * pulse), 215, 255)
    end

    if fovCircle then
        local vp = Camera.ViewportSize
        fovCircle.Visible = CFG.AIM.Enabled and CFG.AIM.ShowFOV
        fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        fovCircle.Radius = CFG.AIM.FOV
        fovCircle.Color = aimTarget and Color3.fromRGB(255, 120, 120) or CFG.AIM.FOVColor
    end

    updateAim(dt)

    if frameCount % 2 == 0 then
        local ok, err = pcall(updateESP)
        if not ok and not espErrShown then
            espErrShown = true
            warn("[Zaka] ESP 异常: " .. tostring(err))
        end
    end
end)

local function unload()
    pcall(function() conn:Disconnect() end)
    for _, v in pairs(visuals) do destroyVisual(v) end
    visuals = {}
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    pcall(function() gui:Destroy() end)
    _G.ZakaUnload = nil
end

_G.ZakaUnload = unload

closeBtn.MouseButton1Click:Connect(unload)

Players.PlayerRemoving:Connect(function(plr)
    if visuals[plr] then
        destroyVisual(visuals[plr])
        visuals[plr] = nil
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Workspace.CurrentCamera then Camera = Workspace.CurrentCamera end
end)

if not HAS_DRAWING then
    statusTxt.Text = "当前执行器不支持绘制，透视不可用"
end

do
    local ok, key = pcall(applyPreset, CFG.GAME.Preset)
    if ok then CFG.GAME.Resolved = key end
end

pcall(function()
    local vp = Camera.ViewportSize
    print(string.format("[Zaka] 游戏=%s PlaceId=%s FOV=%.1f(%s) 视口=%dx%d 预设=%s",
        tostring(game.Name), tostring(game.PlaceId),
        Camera.FieldOfView, tostring(Camera.FieldOfViewMode),
        math.floor(vp.X), math.floor(vp.Y), tostring(CFG.GAME.Resolved)))
end)

_G.ZakaDebug = {
    project   = project,
    view      = view,
    buildRig  = buildRig,
    updateESP = updateESP,
    updateAim = updateAim,
    CFG       = CFG,
    ui        = { gui = gui, main = main, ball = ball },
}

print("[Zaka] 已加载 v2 · 自研投影 + 手机自瞄 · 面板可缩成球")