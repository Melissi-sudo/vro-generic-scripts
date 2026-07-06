local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Folder Assignments
local oresFolder = workspace:WaitForChild("Ores")
local enemiesFolder = workspace:WaitForChild("SwordEnemies")

-- Combined Targets Configuration
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

-- Refresh character tracking upon respawning
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- Create Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VroTeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (Black Theme)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12))
}
gradient.Parent = mainFrame

-- Red Accent Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(230, 0, 0)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 30)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "SELECT TARGET"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = mainFrame

-- Selection Dropdown Button
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 45)
dropdown.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
dropdown.Text = selectedTarget.name .. " [" .. selectedTarget.type .. "]"
dropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
dropdown.Font = Enum.Font.GothamSemibold
dropdown.TextSize = 13
dropdown.Parent = mainFrame

Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
local dropStroke = Instance.new("UIStroke")
dropStroke.Color = Color3.fromRGB(45, 45, 45)
dropStroke.Parent = dropdown

-- Dropdown Scrolling Menu (Prevents layout overflow)
local menu = Instance.new("ScrollingFrame")
local menuMaxHeight = math.min(#targets * 30, 150)
menu.Size = UDim2.new(1, -20, 0, menuMaxHeight)
menu.Position = UDim2.new(0, 10, 0, 80)
menu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
menu.Visible = false
menu.BorderSizePixel = 0
menu.CanvasSize = UDim2.new(0, 0, 0, #targets * 30)
menu.ScrollBarThickness = 4
menu.ScrollBarImageColor3 = Color3.fromRGB(230, 0, 0)
menu.Parent = mainFrame

Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(45, 45, 45)
menuStroke.Parent = menu

-- Dynamic Dropdown Button Generation
for i, target in ipairs(targets) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, (i - 1) * 30)
    btn.BackgroundTransparency = 1
    btn.Text = target.name .. " (" .. target.type .. ")"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = menu

    btn.MouseButton1Click:Connect(function()
        selectedTarget = target
        dropdown.Text = target.name .. " [" .. target.type .. "]"
        menu.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 150), "Out", "Quad", 0.2, true)
        actionBtn.Position = UDim2.new(0, 10, 1, -45)
    end)
end

-- Teleport Action Button (Red Accent)
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, -20, 0, 35)
actionBtn.Position = UDim2.new(0, 10, 1, -45)
actionBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
actionBtn.Text = "Teleport to Target"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.GothamBold
actionBtn.TextSize = 14
actionBtn.Parent = mainFrame

Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- Open/Close Dropdown Menu Window Tweens
dropdown.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
    if menu.Visible then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 150 + menuMaxHeight), "Out", "Quad", 0.2, true)
        actionBtn.Position = UDim2.new(0, 10, 0, 80 + menuMaxHeight + 10)
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 150), "Out", "Quad", 0.2, true)
        actionBtn.Position = UDim2.new(0, 10, 1, -45)
    end
end)

-- Dynamic Teleport Engine Logic
local function teleportToTarget()
    if not hrp or not hrp.Parent then
        hrp = character:FindFirstChild("HumanoidRootPart")
    end
    if not hrp then return end

    -- Determine which folder directory to scrape
    local targetFolder = selectedTarget.type == "Ore" and oresFolder or enemiesFolder
    local closestTarget = nil
    local closestDist = math.huge

    if not targetFolder then
        warn("Directory system error: Target folder location missing.")
        return
    end

    for _, model in ipairs(targetFolder:GetChildren()) do
        if model:IsA("Model") and model.Name == selectedTarget.name then
            -- Check target life value metric
            local health = model:FindFirstChild("Health")
            if health and health:IsA("IntValue") and health.Value > 0 then
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
        -- Safely offsets player 2 studs vertically above destination root point
        hrp.CFrame = closestTarget.CFrame + Vector3.new(0, 2, 0)
    else
        warn("No alive targets matching '" .. selectedTarget.name .. "' found nearby.")
    end
end

actionBtn.MouseButton1Click:Connect(teleportToTarget)
