local GetInfo = loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/roblox-get-avatar-info/refs/heads/main/library.lua"))()

local Players = game:GetService("Players")

local GenderColors = {
    Male    = Color3.fromRGB(100, 180, 255),
    Female  = Color3.fromRGB(255, 150, 200),
    Unknown = Color3.fromRGB(180, 180, 180)
}

local GenderIcons = {
    Male    = "♂",
    Female  = "♀",
    Unknown = "?"
}

local RaceColors = {
    White   = Color3.fromRGB(255, 235, 210),
    Black   = Color3.fromRGB(180, 130, 90),
    Mixed   = Color3.fromRGB(210, 175, 130),
    Unknown = Color3.fromRGB(180, 180, 180)
}

local function CreateOverhead(Player, GenderResult, RaceResult)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Head = Character:WaitForChild("Head")

    local Existing = Head:FindFirstChild("InfoGui")
    if Existing then Existing:Destroy() end

    local Gender = GenderResult and GenderResult.Gender or "Unknown"
    local GenderColor = GenderColors[Gender]
    local Icon = GenderIcons[Gender]

    local GenderMethodText = "No Match"
    if GenderResult and GenderResult.Method then
        local M = GenderResult.Method
        GenderMethodText = M.Name .. ": " .. (M.Value or "?")
    end

    local Race = RaceResult and RaceResult.Race or "Unknown"
    local RaceColor = RaceColors[Race]

    local RaceMethodText = "No Match"
    if RaceResult and RaceResult.Method then
        local M = RaceResult.Method
        RaceMethodText = M.Name .. ": " .. (M.BrickColor or "?")
    end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "InfoGui"
    Billboard.Size = UDim2.new(5, 0, 2.6, 0)
    Billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    Billboard.AlwaysOnTop = false
    Billboard.ResetOnSpawn = false
    Billboard.Parent = Head

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.Parent = Billboard

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.08, 0)
    Corner.Parent = Frame

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0.06, 0)
    Padding.PaddingRight = UDim.new(0.06, 0)
    Padding.PaddingTop = UDim.new(0.06, 0)
    Padding.PaddingBottom = UDim.new(0.06, 0)
    Padding.Parent = Frame

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0.03, 0)
    Layout.Parent = Frame

    local function AddDivider()
        local Divider = Instance.new("Frame")
        Divider.Size = UDim2.new(0.85, 0, 0, 1)
        Divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        Divider.BorderSizePixel = 0
        Divider.Parent = Frame
    end

    local GenderLabel = Instance.new("TextLabel")
    GenderLabel.Size = UDim2.new(1, 0, 0.28, 0)
    GenderLabel.BackgroundTransparency = 1
    GenderLabel.Text = Icon .. "  " .. Gender
    GenderLabel.TextColor3 = GenderColor
    GenderLabel.TextScaled = true
    GenderLabel.Font = Enum.Font.GothamBold
    GenderLabel.Parent = Frame

    local GenderMethodLabel = Instance.new("TextLabel")
    GenderMethodLabel.Size = UDim2.new(1, 0, 0.14, 0)
    GenderMethodLabel.BackgroundTransparency = 1
    GenderMethodLabel.Text = GenderMethodText
    GenderMethodLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    GenderMethodLabel.TextScaled = true
    GenderMethodLabel.TextTruncate = Enum.TextTruncate.AtEnd
    GenderMethodLabel.Font = Enum.Font.Gotham
    GenderMethodLabel.Parent = Frame

    AddDivider()

    local RaceLabel = Instance.new("TextLabel")
    RaceLabel.Size = UDim2.new(1, 0, 0.28, 0)
    RaceLabel.BackgroundTransparency = 1
    RaceLabel.Text = Race
    RaceLabel.TextColor3 = RaceColor
    RaceLabel.TextScaled = true
    RaceLabel.Font = Enum.Font.GothamBold
    RaceLabel.Parent = Frame

    local RaceMethodLabel = Instance.new("TextLabel")
    RaceMethodLabel.Size = UDim2.new(1, 0, 0.14, 0)
    RaceMethodLabel.BackgroundTransparency = 1
    RaceMethodLabel.Text = RaceMethodText
    RaceMethodLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    RaceMethodLabel.TextScaled = true
    RaceMethodLabel.TextTruncate = Enum.TextTruncate.AtEnd
    RaceMethodLabel.Font = Enum.Font.Gotham
    RaceMethodLabel.Parent = Frame
end

local function HandlePlayer(Player)
    task.spawn(function()
        local GenderResult = GetInfo:GetGender(Player)
        local RaceResult   = GetInfo:GetRace(Player)
        CreateOverhead(Player, GenderResult, RaceResult)

        Player.CharacterAdded:Connect(function()
            CreateOverhead(Player, GenderResult, RaceResult)
        end)
    end)
end

for _, Player in Players:GetPlayers() do
    HandlePlayer(Player)
end

Players.PlayerAdded:Connect(HandlePlayer)
