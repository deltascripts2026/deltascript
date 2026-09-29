-- ==========================================================
--  ATEZ HUB - COMPACT SPAWNER + BOTTOM SERVER PLAYER PANEL
-- ==========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Chat = game:GetService("Chat")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local activeNPC = nil
local moveConnection = nil
local activeAnimations = {}
local currentAnimState = "None"

local clickCount = 0
local clickConnection = nil
local targetPosition = nil

-- CLIPBOARD (KOPYALAMA) FONKSİYONU
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    elseif toclipboard then
        toclipboard(text)
        return true
    elseif set_clipboard then
        set_clipboard(text)
        return true
    end
    return false
end

-- RGB COLOR MOTORU
local currentRgbColor = Color3.fromRGB(0, 255, 170)
task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        currentRgbColor = Color3.fromHSV(hue, 1, 1)
    end
end)

-- FALLBACK CHAT
local function fallbackChat(targetCharacter, message)
    if targetCharacter and targetCharacter:FindFirstChild("Head") then
        pcall(function()
            Chat:Chat(targetCharacter.Head, message, Enum.ChatColor.White)
        end)
    end
end

-- ESKİ GUI TEMİZLİĞİ
if playerGui:FindFirstChild("AtezCompactSpawner") then
    playerGui.AtezCompactSpawner:Destroy()
end

-- ==========================================================
-- 1. KOMPAKT GUI & ALT OYUNCU LİSTESİ PANELİ
-- ==========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AtezCompactSpawner"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 340)
mainFrame.Position = UDim2.new(0.04, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2
mainStroke.Parent = mainFrame

-- ALT PANEL (MENÜNÜN ALTINA YERLEŞTİRİLDİ)
local bottomPanel = Instance.new("Frame")
bottomPanel.Name = "BottomPlayerPanel"
bottomPanel.Size = UDim2.new(1, 0, 0, 130)
bottomPanel.Position = UDim2.new(0, 0, 1, 8) -- Ana menünün 8px altında durur
bottomPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
bottomPanel.BackgroundTransparency = 0.1
bottomPanel.BorderSizePixel = 0
bottomPanel.Parent = mainFrame

local bottomCorner = Instance.new("UICorner")
bottomCorner.CornerRadius = UDim.new(0, 10)
bottomCorner.Parent = bottomPanel

local bottomStroke = Instance.new("UIStroke")
bottomStroke.Thickness = 1.5
bottomStroke.Transparency = 0.2
bottomStroke.Parent = bottomPanel

local bottomTitle = Instance.new("TextLabel")
bottomTitle.Size = UDim2.new(1, 0, 0, 24)
bottomTitle.Text = "SUNUCU PROFIL LİNKLERİ (TIKLA & KOPYALA)"
bottomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
bottomTitle.TextSize = 9
bottomTitle.Font = Enum.Font.GothamBold
bottomTitle.BackgroundTransparency = 1
bottomTitle.Parent = bottomPanel

local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Size = UDim2.new(0.92, 0, 1, -28)
playerListScroll.Position = UDim2.new(0.04, 0, 0, 24)
playerListScroll.BackgroundTransparency = 1
playerListScroll.BorderSizePixel = 0
playerListScroll.ScrollBarThickness = 3
playerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListScroll.Parent = bottomPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Parent = playerListScroll

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
end)

-- BAŞLIK BAR
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -10, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.Text = "ATEZ HUB // RGB CHAT"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 10
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

-- PROFIL RESMI
local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 40, 0, 40)
avatarFrame.Position = UDim2.new(0.5, -20, 0.11, 0)
avatarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
avatarFrame.Parent = mainFrame

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarFrame

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(1, 0, 1, 0)
avatarImage.BackgroundTransparency = 1
avatarImage.Image = "rbxassetid://0"
avatarImage.Parent = avatarFrame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(1, 0)
imgCorner.Parent = avatarImage

-- INPUT KUTULARI
local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0.88, 0, 0, 26)
nameInput.Position = UDim2.new(0.06, 0, 0.25, 0)
nameInput.PlaceholderText = "Oyuncu Adı..."
nameInput.Text = ""
nameInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
nameInput.Font = Enum.Font.GothamMedium
nameInput.TextSize = 10
nameInput.Parent = mainFrame

local inC1 = Instance.new("UICorner")
inC1.CornerRadius = UDim.new(0, 6)
inC1.Parent = nameInput

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0.42, 0, 0, 26)
spawnBtn.Position = UDim2.new(0.06, 0, 0.34, 0)
spawnBtn.Text = "SPAWN ET"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 10
spawnBtn.Parent = mainFrame

local btnC1 = Instance.new("UICorner")
btnC1.CornerRadius = UDim.new(0, 6)
btnC1.Parent = spawnBtn

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0.42, 0, 0, 26)
removeBtn.Position = UDim2.new(0.52, 0, 0.34, 0)
removeBtn.Text = "SİL"
removeBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeBtn.Font = Enum.Font.GothamBold
removeBtn.TextSize = 10
removeBtn.Parent = mainFrame

local btnC2 = Instance.new("UICorner")
btnC2.CornerRadius = UDim.new(0, 6)
btnC2.Parent = removeBtn

-- CHAT ALANI
local chatInput = Instance.new("TextBox")
chatInput.Size = UDim2.new(0.88, 0, 0, 26)
chatInput.Position = UDim2.new(0.06, 0, 0.43, 0)
chatInput.PlaceholderText = "Chat Mesajı..."
chatInput.Text = ""
chatInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
chatInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
chatInput.Font = Enum.Font.GothamMedium
chatInput.TextSize = 10
chatInput.Parent = mainFrame

local inC2 = Instance.new("UICorner")
inC2.CornerRadius = UDim.new(0, 6)
inC2.Parent = chatInput

local talkBtn = Instance.new("TextButton")
talkBtn.Size = UDim2.new(0.88, 0, 0, 26)
talkBtn.Position = UDim2.new(0.06, 0, 0.52, 0)
talkBtn.Text = "💬 KONUŞTUR"
talkBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
talkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
talkBtn.Font = Enum.Font.GothamBold
talkBtn.TextSize = 10
talkBtn.Parent = mainFrame

local talkC = Instance.new("UICorner")
talkC.CornerRadius = UDim.new(0, 6)
talkC.Parent = talkBtn

-- KUMANDA FRAME
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0.88, 0, 0, 120)
controlFrame.Position = UDim2.new(0.06, 0, 0.61, 0)
controlFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
controlFrame.Parent = mainFrame

local ctrlC = Instance.new("UICorner")
ctrlC.CornerRadius = UDim.new(0, 8)
ctrlC.Parent = controlFrame

local function createPadButton(text, pos, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 30, 0, 30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = controlFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    return btn
end

local btnUp = createPadButton("▲", UDim2.new(0.5, -15, 0.08, 0))
local btnDown = createPadButton("▼", UDim2.new(0.5, -15, 0.62, 0))
local btnLeft = createPadButton("◄", UDim2.new(0.5, -50, 0.62, 0))
local btnRight = createPadButton("►", UDim2.new(0.5, 20, 0.62, 0))
local btnJump = createPadButton("ZIPLA", UDim2.new(0.5, -35, 0.35, 0), UDim2.new(0, 70, 0, 28))

-- RGB RENDER DÖNGÜSÜ
RunService.RenderStepped:Connect(function()
    mainStroke.Color = currentRgbColor
    bottomStroke.Color = currentRgbColor
    talkBtn.BackgroundColor3 = currentRgbColor
end)

-- ==========================================================
-- 2. DRAG, AVATAR UPDATE & ALT OYUNCU LİSTESİ MOTORU
-- ==========================================================
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

nameInput:GetPropertyChangedSignal("Text"):Connect(function()
    local text = nameInput.Text
    if #text >= 3 then
        task.spawn(function()
            local success, userId = pcall(function() return Players:GetUserIdFromNameAsync(text) end)
            if success and userId then
                avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
            end
        end)
    end
end)

-- ALT PANELE OYUNCULARI LİSTELEME
local function updatePlayerList()
    for _, child in ipairs(playerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(1, -6, 0, 22)
        pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        pBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pBtn.Font = Enum.Font.GothamMedium
        pBtn.TextSize = 9
        pBtn.TextTruncate = Enum.TextTruncate.AtEnd
        pBtn.Parent = playerListScroll

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 4)
        pCorner.Parent = pBtn

        pBtn.MouseButton1Click:Connect(function()
            nameInput.Text = p.Name
            local profileUrl = "https://www.roblox.com/users/" .. p.UserId .. "/profile"
            
            if copyToClipboard(profileUrl) then
                pBtn.Text = "✔ Kopyalandı!"
                task.wait(1.2)
                pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            else
                pBtn.Text = "✖ Desteklenmiyor"
                task.wait(1.2)
                pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            end
        end)
    end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- ==========================================================
-- 3. ANIMASYON MOTORU
-- ==========================================================
local function applyPerfectAnimations(npc)
    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    activeAnimations = {}

    local idleAnim = Instance.new("Animation")
    local walkAnim = Instance.new("Animation")

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        idleAnim.AnimationId = "rbxassetid://507766388"
        walkAnim.AnimationId = "rbxassetid://913402848"
    else
        idleAnim.AnimationId = "rbxassetid://180435571"
        walkAnim.AnimationId = "rbxassetid://180436334"
    end

    local trackIdle = animator:LoadAnimation(idleAnim)
    local trackWalk = animator:LoadAnimation(walkAnim)

    trackIdle.Priority = Enum.AnimationPriority.Core
    trackWalk.Priority = Enum.AnimationPriority.Movement

    activeAnimations.idle = trackIdle
    activeAnimations.walk = trackWalk

    trackIdle:Play(0.2)
    currentAnimState = "Idle"
end

local function setAnimState(state)
    if currentAnimState == state then return end

    if state == "Walk" then
        if activeAnimations.idle then activeAnimations.idle:Stop(0.2) end
        if activeAnimations.walk then activeAnimations.walk:Play(0.2) end
    elseif state == "Idle" then
        if activeAnimations.walk then activeAnimations.walk:Stop(0.2) end
        if activeAnimations.idle then activeAnimations.idle:Play(0.2) end
    end

    currentAnimState = state
end

-- ==========================================================
-- 4. DOKUNMATİK KUMANDA MOTORU
-- ==========================================================
local padHeld = {Up = false, Down = false, Left = false, Right = false}

btnUp.MouseButton1Down:Connect(function() padHeld.Up = true end)
btnUp.MouseButton1Up:Connect(function() padHeld.Up = false end)

btnDown.MouseButton1Down:Connect(function() padHeld.Down = true end)
btnDown.MouseButton1Up:Connect(function() padHeld.Down = false end)

btnLeft.MouseButton1Down:Connect(function() padHeld.Left = true end)
btnLeft.MouseButton1Up:Connect(function() padHeld.Left = false end)

btnRight.MouseButton1Down:Connect(function() padHeld.Right = true end)
btnRight.MouseButton1Up:Connect(function() padHeld.Right = false end)

btnJump.MouseButton1Click:Connect(function()
    if activeNPC then
        local humanoid = activeNPC:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Jump = true end
    end
end)

local function startControl(npc)
    if moveConnection then moveConnection:Disconnect() end

    local humanoid = npc:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    applyPerfectAnimations(npc)

    moveConnection = RunService.RenderStepped:Connect(function()
        if not npc or not npc.Parent then
            if moveConnection then moveConnection:Disconnect() end
            return
        end

        local moveVector = Vector3.zero
        local cameraCFrame = Workspace.CurrentCamera.CFrame

        if padHeld.Up then moveVector = moveVector + cameraCFrame.LookVector end
        if padHeld.Down then moveVector = moveVector - cameraCFrame.LookVector end
        if padHeld.Left then moveVector = moveVector - cameraCFrame.RightVector end
        if padHeld.Right then moveVector = moveVector + cameraCFrame.RightVector end

        moveVector = Vector3.new(moveVector.X, 0, moveVector.Z)

        if moveVector.Magnitude > 0 then
            humanoid:Move(moveVector.Unit, false)
            setAnimState("Walk")
        else
            humanoid:Move(Vector3.zero, false)
            setAnimState("Idle")
        end
    end)
end

-- ==========================================================
-- 5. CHAT İLE KONUŞTURMA
-- ==========================================================
talkBtn.MouseButton1Click:Connect(function()
    local msg = chatInput.Text
    if msg == "" then return end

    if activeNPC then
        fallbackChat(activeNPC, msg)
    else
        local target = Players:FindFirstChild(nameInput.Text)
        if target and target.Character then
            fallbackChat(target.Character, msg)
        end
    end

    chatInput.Text = ""
end)

-- ==========================================================
-- 6. SPAWN LOGIC (3 TIKLAMA)
-- ==========================================================
spawnBtn.MouseButton1Click:Connect(function()
    local targetName = nameInput.Text
    if targetName == "" then return end

    clickCount = 0
    spawnBtn.Text = "3 TIKLA (0/3)"

    if clickConnection then clickConnection:Disconnect() end

    clickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            clickCount = clickCount + 1
            spawnBtn.Text = "3 TIKLA (" .. clickCount .. "/3)"

            if clickCount >= 3 then
                clickConnection:Disconnect()
                clickConnection = nil
                
                targetPosition = mouse.Hit.Position
                spawnBtn.Text = "YÜKLENİYOR..."

                task.spawn(function()
                    local success, userId = pcall(function()
                        return Players:GetUserIdFromNameAsync(targetName)
                    end)

                    if success and userId then
                        local charModel
                        local getSuccess = pcall(function()
                            charModel = Players:CreateHumanoidModelFromUserId(userId)
                        end)

                        if getSuccess and charModel then
                            if activeNPC then activeNPC:Destroy() end
                            activeNPC = charModel
                            activeNPC.Name = targetName

                            for _, part in ipairs(activeNPC:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            
                            local hrp = activeNPC:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CanCollide = true end

                            activeNPC:PivotTo(CFrame.new(targetPosition + Vector3.new(0, 3, 0)))

                            activeNPC.Parent = Workspace
                            
                            task.wait(0.1)
                            startControl(activeNPC)

                            spawnBtn.Text = "SPAWN ET"
                        else
                            spawnBtn.Text = "HATA!"
                            task.wait(1.5)
                            spawnBtn.Text = "SPAWN ET"
                        end
                    else
                        spawnBtn.Text = "BULUNAMADI!"
                        task.wait(1.5)
                        spawnBtn.Text = "SPAWN ET"
                    end
                end)
            end
        end
    end)
end)

removeBtn.MouseButton1Click:Connect(function()
    if activeNPC then
        activeNPC:Destroy()
        activeNPC = nil
    end
    if moveConnection then
        moveConnection:Disconnect()
    end
    if clickConnection then
        clickConnection:Disconnect()
    end
    spawnBtn.Text = "SPAWN ET"
end)
