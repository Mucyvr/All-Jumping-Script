Print("test")

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local checkpoints = {}
local cameraToggle = false
local character, humanoid, hrp

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid", 5)
    hrp = character:WaitForChild("HumanoidRootPart", 5)
end

updateCharacter()
player.CharacterAdded:Connect(updateCharacter)

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "AJMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0, 50)
frame.Position = UDim2.new(0.25, 0, 0, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Parent = gui

local function createButton(name, position, func)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.25, 0, 1, 0)
    button.Position = UDim2.new(position, 0, 0, 0)
    button.Text = name
    button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = frame
    button.MouseButton1Click:Connect(func)
    return button
end

local cameraButton
pcall(function()
    cameraButton = createButton("Camera: Off", 0.75, function()
        cameraToggle = not cameraToggle
        if cameraButton then
            cameraButton.Text = "Camera: " .. (cameraToggle and "On" or "Off")
        end
    end)
end)

createButton("Save", 0, function() setCheckpoint() end)
createButton("Load", 0.25, function() loadCheckpoint() end)
createButton("Remove", 0.5, function() removeCheckpoint() end)

local function cloneCharacterForVisual()
    if not character or not character.Parent then
        updateCharacter()
    end
    local startTime = tick()
    while not character.Parent and tick() - startTime < 2 do
        wait(0.1)
    end
    local success, clone = pcall(function()
        local c = Instance.new("Part")  -- Fallback to simple part if clone fails
        c.Shape = Enum.PartType.Ball
        c.Size = Vector3.new(2, 2, 2)
        c.Color = Color3.new(1, 0, 0)  -- Red sphere
        c.Transparency = 0.5
        c.Anchored = true
        c.CanCollide = false
        c.Position = hrp.Position
        c.Parent = workspace
        return c
    end)
    if not success then
        local c = Instance.new("Part")  -- Silent fallback
        c.Shape = Enum.PartType.Ball
        c.Size = Vector3.new(2, 2, 2)
        c.Color = Color3.new(1, 0, 0)
        c.Transparency = 0.5
        c.Anchored = true
        c.CanCollide = false
        c.Position = hrp.Position
        c.Parent = workspace
        return c
    end
    return clone
end

function setCheckpoint()
    if not hrp then return end
    local cp = {
        CFrame = hrp.CFrame,
        CamCFrame = cameraToggle and workspace.CurrentCamera.CFrame or nil,
        Visual = cloneCharacterForVisual()
    }
    table.insert(checkpoints, cp)
end

function loadCheckpoint()
    if #checkpoints > 0 and hrp then
        local latest = checkpoints[#checkpoints]
        pcall(function()
            hrp.CFrame = latest.CFrame
            if cameraToggle and latest.CamCFrame then
                workspace.CurrentCamera.CFrame = latest.CamCFrame
            end
        end)
    end
end

function removeCheckpoint()
    if #checkpoints > 0 then
        local latest = table.remove(checkpoints)
        if latest.Visual then
            pcall(function() latest.Visual:Destroy() end)
        end
    end
end

uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        setCheckpoint()
    elseif input.KeyCode == Enum.KeyCode.F then
        loadCheckpoint()
    elseif input.KeyCode == Enum.KeyCode.H then
        removeCheckpoint()
    end
end)
