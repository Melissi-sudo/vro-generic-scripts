local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

-- Folder Assignments
local oresFolder = workspace:WaitForChild("Ores")
local enemiesFolder = workspace:WaitForChild("SwordEnemies")

-- Combined Targets Setup
local targets = {
    {name = "Coal", type = "Ore"},
    {name = "Copper", type = "Ore"},
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
    notif.Size = UDim2.new(0, 220, 0, 35)
    notif.Position = UDim2.new(0.5, -110, 0.05, -50)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    notif.TextColor3 = Color3.fromRGB(255, 25, 25)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 13
    notif.Text = "[VRO] " .. text:upper()
    notif.Parent = screenGui
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", notif)
    s.Color = Color3.fromRGB(255, 0, 0)
    s.Thickness = 1.5

    notif:TweenPosition(UDim2.new(0.5, -110, 0.05, 0), "Out", "Back", 0.3, true)
    
    task.delay(2.5, function()
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
mainFrame.Size = UDim2.new(0, 250, 0, 160)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 1.5

-- Header Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 30)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "VRO UTILITY SYSTEM"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = mainFrame

-- Dropdown Main Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 32)
dropdown.Position = UDim2.new(0, 10, 0, 42)
dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dropdown.Text = selectedTarget.name .. " [" .. selectedTarget.type .. "]"
dropdown.TextColor3 = Color3.fromRGB(220, 220, 220)
dropdown.Font = Enum.Font.GothamSemibold
dropdown.TextSize = 13
dropdown.Parent = mainFrame

Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
local dropStroke = Instance.new("UIStroke", dropdown)
dropStroke.Color = Color3.fromRGB(40, 40, 40)

-- Dropdown Menu (Scrolling Frame Layout)
local menuMaxHeight = math.min(#targets * 30, 150)
local menu = Instance.new("ScrollingFrame")
menu.Size = UDim2.new(1, -20, 0, menuMaxHeight)
menu.Position = UDim2.new(0, 10, 0, 80)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.Visible = false
menu.BorderSizePixel = 0
menu.CanvasSize = UDim2.new(0, 0, 0, #targets * 30)
menu.ScrollBarThickness = 4
menu.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
menu.Parent = mainFrame

Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = Color3.fromRGB(40, 40, 40)

-- Bottom Status Count Tracker
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -20, 0, 20)
counterLabel.Position = UDim2.new(0, 10, 1, -70)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Targets Found: 0"
counterLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
counterLabel.Font = Enum.Font.GothamSemibold
counterLabel.TextSize = 12
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Parent = mainFrame

-- Action Activation Button (Stays safely hard-anchored to the bottom)
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, -20, 0, 35)
actionBtn.Position = UDim2.new(0, 10, 1, -45)
actionBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
actionBtn.Text = "EXECUTE TELEPORT"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.GothamBold
actionBtn.TextSize = 13
actionBtn.Parent = mainFrame

Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- Streamlined Health Value Object Engine (Applies to both Ores & Enemies seamlessly)
local function isValidTarget(model)
    if not model:IsA("Model") then return false end
    
    -- Checks specifically for the Int/Number Health Value instance configuration
    local healthObj = model:FindFirstChild("Health")
    if healthObj and (healthObj:IsA("IntValue") or healthObj:IsA("NumberValue")) then
        return healthObj.Value > 0
    end
    
    -- Backup check: In case the health setup uses attributes instead of an object
    local healthAttr = model:GetAttribute("Health")
    if healthAttr then return healthAttr > 0 end
    
    -- Universal Fallback: If no numerical health indicator exists, check if it has parts to teleport to
    return (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) ~= nil
end

-- Refresh Highlights and Counts Elements
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
                
                -- Construct Vro-style Highlight Outlines
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.7
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.1
                hl.Adornee = model
                hl.Parent = model
                table.insert(currentHighlights, hl)
            end
        end
    end
    
    counterLabel.Text = "Targets Found: " .. tostring(count)
    return count
end

-- Populate Dropdown Menu Buttons Dynamically
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
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 160), "Out", "Quad", 0.2, true)
        
        local total = updateUtilityState()
        showNotification(target.name .. " Selected: " .. total .. " available")
    end)
end

-- Dropdown Expand Toggle Logic
dropdown.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
    if menu.Visible then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 160 + menuMaxHeight), "Out", "Quad", 0.2, true)
        updateUtilityState()
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 160), "Out", "Quad", 0.2, true)
    end
end)

-- Main Teleport Logic Execution Block
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
        showNotification("Teleported to " .. selectedTarget.name)
    else
        showNotification("No valid " .. selectedTarget.name .. " found!")
    end
    updateUtilityState()
end

actionBtn.MouseButton1Click:Connect(executeTeleport)

-- Background Thread Loop: Refreshes data sync maps every 2 seconds
task.spawn(function()
    while true do
        updateUtilityState()
        task.wait(2)
    end
end)

-- Initial Status Initialization Setup Run
updateUtilityState()
