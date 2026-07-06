local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Folder Assignments
local oresFolder = workspace:WaitForChild("Ores")
local enemiesFolder = workspace:WaitForChild("SwordEnemies")

---//
local lockedSuiteName = string.char(86,114,111,32,67,97,118,101,32,68,105,118,105,110,103,32,69,120,112,101,114,105,101,110,99,101,32,83,117,105,116,101)
---\\

-- Combined Targets Setup
local targets = {
    {name = "Coal", type = "Ore"},
    {name = "Copper", type = "Ore"},
    {name = "Iron", type = "Ore"}, 
    {name = "Gold", type = "Ore"},
    {name = "Titanium", type = "Ore"},
    {name = "Diamond", type = "Ore"},
    {name = "Emerald", type = "Ore"},
    {name = "Obsidian", type = "Ore"},
    {name = "Ruby", type = "Ore"},
    {name = "Mythril", type = "Ore"},
    {name = "Goblin", type = "Enemy"},
    {name = "GoblinChampion", type = "Enemy"},
    {name = "Spider", type = "Enemy"}
}
local selectedTarget = targets[1]
local currentHighlights = {}
local isMinimized = false
local isDropdownOpen = false

-- Track Respawns Safely
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- Create Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VroUtilityGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Toast Notification Engine
local function showNotification(text)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 340, 0, 45)
    notif.Position = UDim2.new(0.5, -170, 0.05, -60)
    notif.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    notif.TextColor3 = Color3.fromRGB(245, 245, 245)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 11
    notif.Text = "[" .. lockedSuiteName:upper() .. "]\n" .. text:upper()
    notif.TextWrapped = true
    notif.Parent = screenGui
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", notif)
    s.Color = Color3.fromRGB(220, 0, 0)
    s.Thickness = 1.5

    notif:TweenPosition(UDim2.new(0.5, -170, 0.05, 0), "Out", "Back", 0.3, true)
    
    task.delay(3, function()
        pcall(function()
            TweenService:Create(notif, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
            TweenService:Create(s, TweenInfo.new(0.4), {Transparency = 1}):Play()
            task.wait(0.4)
            notif:Destroy()
        end)
    end)
end

-- Main Frame (Vro Matte Black Layout)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 160)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(220, 0, 0)
stroke.Thickness = 1.5

-- Dragging Functionality Engine
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Header Label text (Pulls directly from protected bytecode)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -50, 0, 35)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Text = lockedSuiteName:upper()
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = mainFrame

-- Content Canvas Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

-- Dropdown Header Selector Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 32)
dropdown.Position = UDim2.new(0, 10, 0, 5)
dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dropdown.Text = selectedTarget.name .. " [" .. selectedTarget.type .. "]"
dropdown.TextColor3 = Color3.fromRGB(220, 220, 220)
dropdown.Font = Enum.Font.GothamSemibold
dropdown.TextSize = 12
dropdown.Parent = contentFrame

Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
local dropStroke = Instance.new("UIStroke", dropdown)
dropStroke.Color = Color3.fromRGB(45, 45, 45)

-- Dropdown Selection Scrolling Menu Box
local menuMaxHeight = math.min(#targets * 30, 150)
local menu = Instance.new("ScrollingFrame")
menu.Size = UDim2.new(1, -20, 0, menuMaxHeight)
menu.Position = UDim2.new(0, 10, 0, 42)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.Visible = false
menu.BorderSizePixel = 0
menu.CanvasSize = UDim2.new(0, 0, 0, #targets * 30)
menu.ScrollBarThickness = 4
menu.ScrollBarImageColor3 = Color3.fromRGB(220, 0, 0)
menu.Parent = contentFrame

Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = Color3.fromRGB(45, 45, 45)

-- Live Status Counter Label Tracker
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -20, 0, 20)
counterLabel.Position = UDim2.new(0, 10, 1, -70)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Targets Found: 0"
counterLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
counterLabel.Font = Enum.Font.GothamSemibold
counterLabel.TextSize = 11
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Parent = contentFrame

-- Primary Execution Action Button
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, -20, 0, 35)
actionBtn.Position = UDim2.new(0, 10, 1, -45)
actionBtn.BackgroundColor3 = Color3.fromRGB(190, 0, 0)
actionBtn.Text = "EXECUTE TELEPORT"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.GothamBold
actionBtn.TextSize = 12
actionBtn.Parent = contentFrame

Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- Target Life Value Verification Engine
local function isValidTarget(model)
    if not model:IsA("Model") then return false end
    
    local healthObj = model:FindFirstChild("Health")
    if healthObj and (healthObj:IsA("IntValue") or healthObj:IsA("NumberValue")) then
        return healthObj.Value > 0
    end
    
    local healthAttr = model:GetAttribute("Health")
    if healthAttr then return healthAttr > 0 end
    
    return (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) ~= nil
end

-- Refresh Highlights maps
local function updateUtilityState()
    for _, hl in ipairs(currentHighlights) do
        if hl then hl:Destroy() end
    end
    table.clear(currentHighlights)

    local folder = selectedTarget.type == "Ore" and oresFolder or enemiesFolder
    local count = 0

    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model.Name == selectedTarget.name and isValidTarget(model) then
                count = count + 1
                
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(220, 0, 0)
                hl.FillTransparency = 0.7
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.15
                hl.Adornee = model
                hl.Parent = model
                table.insert(currentHighlights, hl)
            end
        end
    end
    
    counterLabel.Text = "Targets Found: " .. tostring(count)
    return count
end

-- Populate Dropdown Menu Options Items
for i, target in ipairs(targets) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, (i - 1) * 30)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. target.name .. " (" .. target.type .. ")"
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = menu

    btn.MouseButton1Click:Connect(function()
        selectedTarget = target
        dropdown.Text = target.name .. " [" .. target.type .. "]"
        menu.Visible = false
        isDropdownOpen = false
        mainFrame:TweenSize(UDim2.new(0, 270, 0, 160), "Out", "Quad", 0.2, true)
        
        local total = updateUtilityState()
        showNotification(target.name .. " marked: (" .. total .. " active)")
    end)
end

-- Dropdown Drop Expand Management Engine
dropdown.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isDropdownOpen = not isDropdownOpen
    menu.Visible = isDropdownOpen
    if isDropdownOpen then
        mainFrame:TweenSize(UDim2.new(0, 270, 0, 160 + menuMaxHeight), "Out", "Quad", 0.2, true)
        updateUtilityState()
    else
        mainFrame:TweenSize(UDim2.new(0, 270, 0, 160), "Out", "Quad", 0.2, true)
    end
end)

-- Minimize Button Controller Engine
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 25)
minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(220, 0, 0)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = mainFrame

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", minimizeBtn).Color = Color3.fromRGB(50, 50, 50)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        menu.Visible = false
        isDropdownOpen = false
        contentFrame.Visible = false
        minimizeBtn.Text = "+"
        mainFrame:TweenSize(UDim2.new(0, 270, 0, 35), "Out", "Quad", 0.15, true)
    else
        minimizeBtn.Text = "-"
        mainFrame:TweenSize(UDim2.new(0, 270, 0, 160), "Out", "Quad", 0.15, true)
        task.delay(0.1, function() contentFrame.Visible = true end)
    end
end)

-- Core Processing Teleport Target Sequence
local function executeTeleport()
    if not hrp or not hrp.Parent then
        hrp = character:FindFirstChild("HumanoidRootPart")
    end
    if not hrp then return end

    local folder = selectedTarget.type == "Ore" and oresFolder or enemiesFolder
    local closestTarget = nil
    local closestDist = math.huge

    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model.Name == selectedTarget.name and isValidTarget(model) then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (hrp.Position - part.Position).Magnitude
                    if distance < closestDist then
                        closestDist = distance
                        closestTarget = part
                    end
                end
            end
        end
    end

    if closestTarget then
        hrp.CFrame = closestTarget.CFrame + Vector3.new(0, 5, 0)
        showNotification("Warped to " .. selectedTarget.name)
    else
        showNotification("No targets for " .. selectedTarget.name .. " found!")
    end
    updateUtilityState()
end

actionBtn.MouseButton1Click:Connect(executeTeleport)

-- Active Verification Map Loop Thread
task.spawn(function()
    while true do
        updateUtilityState()
        task.wait(2)
    end
end)

updateUtilityState()
