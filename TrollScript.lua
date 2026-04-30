-- ================================================================
--   ULTRA TROLL SCRIPT v69.420
--   NUR FUER DEN EIGENEN GEBRAUCH / FOR OWN GAME TESTING ONLY
--   Als LocalScript in StarterPlayerScripts einfuegen
-- ================================================================

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting        = game:GetService("Lighting")
local VirtualUser     = game:GetService("VirtualUser")

local LP   = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================================
-- STATE
-- ============================================================
local flying       = false
local noclip       = false
local infJump      = false
local godMode      = false
local spinning     = false
local antiAFK      = false
local fullbright   = false
local rainbowBody  = false

local flyConn, noclipConn, spinConn, godConn, rainbowConn

-- ============================================================
-- GUI AUFBAU
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "UltraTrollGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = LP.PlayerGui

-- Haupt-Frame (agressiv haesslich)
local Main = Instance.new("Frame")
Main.Size            = UDim2.new(0, 360, 0, 520)
Main.Position        = UDim2.new(0, 12, 0, 12)
Main.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
Main.BorderSizePixel  = 6
Main.BorderColor3     = Color3.fromRGB(255, 0, 255)
Main.Active           = true
Main.Parent           = ScreenGui

-- Titelleiste
local TitleBar = Instance.new("Frame")
TitleBar.Size            = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Main

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size      = UDim2.new(1, -40, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
TitleLbl.Text      = " ULTRA TROLL SCRIPT v69.420 !!"
TitleLbl.TextSize  = 17
TitleLbl.Font      = Enum.Font.ComicSans
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent    = TitleBar

-- Minimier-Knopf
local MinBtn = Instance.new("TextButton")
MinBtn.Size            = UDim2.new(0, 34, 0, 34)
MinBtn.Position        = UDim2.new(1, -38, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
MinBtn.TextColor3      = Color3.fromRGB(0, 0, 0)
MinBtn.Text            = "_"
MinBtn.TextSize        = 20
MinBtn.Font            = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 3
MinBtn.BorderColor3    = Color3.fromRGB(0, 0, 255)
MinBtn.Parent          = TitleBar

-- Draggable
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = inp.Position
        startPos  = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Scroll-Frame fuer Buttons
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size                = UDim2.new(1, 0, 1, -42)
Scroll.Position            = UDim2.new(0, 0, 0, 42)
Scroll.BackgroundColor3    = Color3.fromRGB(90, 0, 180)
Scroll.BorderSizePixel     = 0
Scroll.ScrollBarThickness  = 10
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 0)
Scroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
Scroll.Parent              = Main

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding   = UDim.new(0, 4)
Layout.Parent    = Scroll

local Pad = Instance.new("UIPadding")
Pad.PaddingLeft   = UDim.new(0, 5)
Pad.PaddingRight  = UDim.new(0, 5)
Pad.PaddingTop    = UDim.new(0, 5)
Pad.Parent        = Scroll

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
end)

-- Minimieren
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Scroll.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 360, 0, 42) or UDim2.new(0, 360, 0, 520)
    MinBtn.Text = minimized and "+" or "_"
end)

-- ============================================================
-- HELPER: Farben-Liste fuer haessliche Buttons
-- ============================================================
local UGLY_COLORS = {
    Color3.fromRGB(255, 100, 0),
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(255, 0, 128),
    Color3.fromRGB(200, 255, 0),
    Color3.fromRGB(128, 0, 255),
    Color3.fromRGB(0, 255, 128),
    Color3.fromRGB(255, 200, 0),
    Color3.fromRGB(0, 100, 255),
}
local colorIdx = 0
local function nextColor()
    colorIdx = (colorIdx % #UGLY_COLORS) + 1
    return UGLY_COLORS[colorIdx]
end

-- Trennlabel
local function sectionLabel(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Size            = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    lbl.TextColor3      = Color3.fromRGB(255, 255, 0)
    lbl.Text            = ">> " .. txt .. " <<"
    lbl.TextSize        = 13
    lbl.Font            = Enum.Font.ComicSans
    lbl.BorderSizePixel  = 2
    lbl.BorderColor3    = Color3.fromRGB(0, 0, 0)
    lbl.Parent          = Scroll
    return lbl
end

-- Normaler Klick-Button
local function makeButton(txt, callback)
    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = nextColor()
    btn.TextColor3      = Color3.fromRGB(0, 0, 0)
    btn.Text            = txt
    btn.TextSize        = 14
    btn.Font            = Enum.Font.ComicSans
    btn.BorderSizePixel  = 3
    btn.BorderColor3    = Color3.fromRGB(0, 0, 200)
    btn.Parent          = Scroll
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Toggle-Button
local function makeToggle(txt, onFn, offFn)
    local active = false
    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.Text            = "[OFF] " .. txt
    btn.TextSize        = 14
    btn.Font            = Enum.Font.ComicSans
    btn.BorderSizePixel  = 3
    btn.BorderColor3    = Color3.fromRGB(0, 0, 200)
    btn.Parent          = Scroll
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            btn.Text = "[ON]  " .. txt
            onFn()
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            btn.Text = "[OFF] " .. txt
            offFn()
        end
    end)
    return btn
end

-- TextBox + Button Kombination
local function makeInputButton(placeholder, btnTxt, callback)
    local box = Instance.new("TextBox")
    box.Size            = UDim2.new(1, 0, 0, 28)
    box.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    box.TextColor3      = Color3.fromRGB(0, 0, 0)
    box.PlaceholderText = placeholder
    box.Text            = ""
    box.TextSize        = 13
    box.Font            = Enum.Font.ComicSans
    box.ClearTextOnFocus = false
    box.Parent          = Scroll

    local btn = makeButton(btnTxt, function()
        callback(box.Text)
    end)
    return box, btn
end

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local function getChar()
    return LP.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

-- ============================================================
-- SEKTION 1: BEWEGUNG
-- ============================================================
sectionLabel("BEWEGUNG")

-- Speed
local speedBox, _ = makeInputButton("Speed (Standard 16)", "SPEED SETZEN", function(txt)
    local v = tonumber(txt)
    if v then
        local h = getHum()
        if h then h.WalkSpeed = v end
    end
end)

-- Jump Power
local jumpBox, _ = makeInputButton("JumpPower (Standard 50)", "JUMP POWER SETZEN", function(txt)
    local v = tonumber(txt)
    if v then
        local h = getHum()
        if h then h.JumpPower = v end
    end
end)

-- Reset Speed
makeButton("SPEED + JUMP ZURUECKSETZEN", function()
    local h = getHum()
    if h then h.WalkSpeed = 16; h.JumpPower = 50 end
end)

-- Infinite Jump
makeToggle("INFINITE JUMP", function()
    infJump = true
end, function()
    infJump = false
end)

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Fly
makeToggle("FLIEGEN", function()
    flying = true
    local c = getChar()
    local hrp = getHRP()
    if not (c and hrp) then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name      = "_FlyVel"
    bv.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity  = Vector3.zero
    bv.Parent    = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name      = "_FlyGyro"
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P         = 1e6
    bg.Parent    = hrp

    flyConn = RunService.Heartbeat:Connect(function()
        if not flying then return end
        local cam  = workspace.CurrentCamera
        local dir  = Vector3.zero
        local keys = UserInputService
        if keys:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if keys:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if keys:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if keys:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if keys:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if keys:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
        local spd = keys:IsKeyDown(Enum.KeyCode.LeftShift) and 120 or 60
        bv.Velocity = dir * spd
        bg.CFrame   = cam.CFrame
    end)
end, function()
    flying = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local hrp = getHRP()
    if hrp then
        local v = hrp:FindFirstChild("_FlyVel")
        local g = hrp:FindFirstChild("_FlyGyro")
        if v then v:Destroy() end
        if g then g:Destroy() end
    end
end)

-- Noclip
makeToggle("NOCLIP", function()
    noclip = true
    noclipConn = RunService.Stepped:Connect(function()
        if not noclip then return end
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end, function()
    noclip = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- Spin
makeToggle("DREHEN (SPIN)", function()
    spinning = true
    spinConn = RunService.Heartbeat:Connect(function()
        if not spinning then return end
        local hrp = getHRP()
        if hrp then
            hrp.CFrame *= CFrame.Angles(0, math.rad(12), 0)
        end
    end)
end, function()
    spinning = false
    if spinConn then spinConn:Disconnect(); spinConn = nil end
end)

-- ============================================================
-- SEKTION 2: SPIELER-MANIPULATION
-- ============================================================
sectionLabel("SPIELER-MANIPULATION")

-- God Mode (lokal)
makeToggle("GOD MODE (LOKAL)", function()
    godMode = true
    local h = getHum()
    if h then
        h.MaxHealth = math.huge
        h.Health    = math.huge
    end
    godConn = RunService.Heartbeat:Connect(function()
        if not godMode then return end
        local hum = getHum()
        if hum then hum.Health = math.huge end
    end)
end, function()
    godMode = false
    if godConn then godConn:Disconnect(); godConn = nil end
    local h = getHum()
    if h then h.MaxHealth = 100; h.Health = 100 end
end)

-- Unsichtbar (lokal - nur fuer sich selbst)
makeToggle("UNSICHTBAR (LOKAL)", function()
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.LocalTransparencyModifier = 1
        end
    end
end, function()
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.LocalTransparencyModifier = 0
        end
    end
end)

-- Rainbow Body
makeToggle("REGENBOGEN KOERPER", function()
    rainbowBody = true
    local hue = 0
    rainbowConn = RunService.Heartbeat:Connect(function()
        if not rainbowBody then return end
        hue = (hue + 1) % 360
        local col = Color3.fromHSV(hue / 360, 1, 1)
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Color = col end
        end
    end)
end, function()
    rainbowBody = false
    if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
end)

-- Groesse
local sizeBox, _ = makeInputButton("Groesse (1 = normal)", "GROESSE AENDERN", function(txt)
    local v = tonumber(txt)
    if not v then return end
    local h = getHum()
    if not h then return end
    h.BodyDepthScale.Value = v
    h.BodyHeightScale.Value = v
    h.BodyWidthScale.Value  = v
    h.HeadScale.Value       = v
end)

-- Zurueck auf normale Groesse
makeButton("GROESSE ZURUECKSETZEN", function()
    local h = getHum()
    if not h then return end
    h.BodyDepthScale.Value  = 1
    h.BodyHeightScale.Value = 1
    h.BodyWidthScale.Value  = 1
    h.HeadScale.Value       = 1
end)

-- Selbst loeschen (Respawn)
makeButton("SELBST RESPAWNEN", function()
    local h = getHum()
    if h then h.Health = 0 end
end)

-- ============================================================
-- SEKTION 3: TELEPORT
-- ============================================================
sectionLabel("TELEPORT")

-- Zu Spieler teleportieren
local tpBox, _ = makeInputButton("Spielername eingeben...", "ZU SPIELER TELEPORTIEREN", function(txt)
    local target = Players:FindFirstChild(txt)
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = getHRP()
        if hrp and myHrp then
            myHrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)
        end
    end
end)

-- Alle zu mir holen
makeButton("ALLE SPIELER ZU MIR HOLEN", function()
    local myHrp = getHRP()
    if not myHrp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = myHrp.CFrame
                    + Vector3.new(math.random(-6, 6), 3, math.random(-6, 6))
            end
        end
    end
end)

-- Zu Position teleportieren
local posBox, _ = makeInputButton("X,Y,Z  (z.B. 0,50,0)", "ZU POSITION TELEPORTIEREN", function(txt)
    local x, y, z = txt:match("([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)")
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    if x and y and z then
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(x, y, z) end
    end
end)

-- Spawn teleportieren
makeButton("ZUM SPAWN TELEPORTIEREN", function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(0, 5, 0) end
end)

-- ============================================================
-- SEKTION 4: WELT-MANIPULATION
-- ============================================================
sectionLabel("WELT-MANIPULATION")

-- Schwerkraft
local gravBox, _ = makeInputButton("Schwerkraft (normal: 196.2)", "SCHWERKRAFT SETZEN", function(txt)
    local v = tonumber(txt)
    if v then workspace.Gravity = v end
end)

makeButton("SCHWERKRAFT ZURUECKSETZEN", function()
    workspace.Gravity = 196.2
end)

-- Fullbright
makeToggle("VOLLHELL (FULLBRIGHT)", function()
    fullbright = true
    Lighting.Brightness      = 10
    Lighting.ClockTime       = 14
    Lighting.FogEnd          = 1e6
    Lighting.GlobalShadows   = false
    Lighting.Ambient         = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient  = Color3.fromRGB(255, 255, 255)
end, function()
    fullbright = false
    Lighting.Brightness     = 1
    Lighting.ClockTime      = 14
    Lighting.GlobalShadows  = true
    Lighting.Ambient        = Color3.fromRGB(70, 70, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

-- Tageszeit
local timeBox, _ = makeInputButton("Tageszeit (0-24)", "UHRZEIT SETZEN", function(txt)
    local v = tonumber(txt)
    if v then Lighting.ClockTime = v % 24 end
end)

-- FOV
local fovBox, _ = makeInputButton("FOV (normal: 70)", "FOV SETZEN", function(txt)
    local v = tonumber(txt)
    if v then workspace.CurrentCamera.FieldOfView = v end
end)

makeButton("FOV ZURUECKSETZEN", function()
    workspace.CurrentCamera.FieldOfView = 70
end)

-- ============================================================
-- SEKTION 5: SONSTIGES
-- ============================================================
sectionLabel("SONSTIGES")

-- Anti-AFK
makeToggle("ANTI-AFK", function()
    antiAFK = true
    LP.Idled:Connect(function()
        if antiAFK then
            VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
        end
    end)
end, function()
    antiAFK = false
end)

-- Spieler-Liste anzeigen
makeButton("SPIELER AUFLISTEN (OUTPUT)", function()
    print("=== SPIELER IM SERVER ===")
    for _, p in ipairs(Players:GetPlayers()) do
        print(string.format(" - %s  (Ping: ~%dms)", p.Name, p.GetNetworkPing and math.floor(p:GetNetworkPing() * 1000) or 0))
    end
    print("=========================")
end)

-- Chat Spam (eigener Chat)
local chatBox, _ = makeInputButton("Nachricht fuer Chat-Spam...", "CHAT SPAM (5x)", function(txt)
    if txt == "" then return end
    for i = 1, 5 do
        task.delay(i * 0.6, function()
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                    :FindFirstChild("SayMessageRequest")
                    and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
                        :FireServer(txt, "All")
        end)
    end
end)

-- Kamera Shake
makeButton("KAMERA ZITTERN (5 Sek)", function()
    local cam   = workspace.CurrentCamera
    local conn
    local timer = 0
    conn = RunService.Heartbeat:Connect(function(dt)
        timer += dt
        if timer > 5 then conn:Disconnect(); return end
        cam.CFrame *= CFrame.Angles(
            math.rad(math.random(-3, 3)),
            math.rad(math.random(-3, 3)),
            math.rad(math.random(-3, 3))
        )
    end)
end)

-- Alle Baelle abfeuern (versucht alle BaseParts mit Velocity zu schleudern)
makeButton("ALLES WEGSCHLEUDERN (FUN)", function()
    local myHrp = getHRP()
    if not myHrp then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored
            and not (LP.Character and LP.Character:IsAncestorOf(obj)) then
            local dir = (obj.Position - myHrp.Position).Unit
            obj:ApplyImpulse(dir * obj.AssemblyMass * 200)
        end
    end
end)

-- Reset Charakter
makeButton("CHARAKTER ZURUECKSETZEN", function()
    LP:LoadCharacter()
end)

-- ============================================================
print("==============================================")
print("  ULTRA TROLL SCRIPT v69.420 GELADEN!  :D")
print("  Nur fuer den eigenen Gebrauch benutzen!")
print("==============================================")
