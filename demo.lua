local GetGender = loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/roblox-get-user-gender/refs/heads/main/main.lua"))()

local Players = game:GetService("Players")

local GenderColors = {
    Male = Color3.fromRGB(100, 180, 255),
    Female = Color3.fromRGB(255, 150, 200),
    Unknown = Color3.fromRGB(180, 180, 180)
}

local GenderIcons = {
    Male = "♂",
    Female = "♀",
    Unknown = "?"
}

local function CreateOverhead(Player, Result)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Head = Character:WaitForChild("Head")

    local Existing = Head:FindFirstChild("GenderGui")
    if Existing then Existing:Destroy() end

    local Gender = Result and Result.Gender or "Unknown"
    local Color = GenderColors[Gender]
    local Icon = GenderIcons[Gender]

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "GenderGui"
	Billboard.Size = UDim2.new(4, 0, 1.2, 0)
	Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	Billboard.AlwaysOnTop = false
	Billboard.ResetOnSpawn = false
	Billboard.Parent = Head

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.4
    Frame.BorderSizePixel = 0
    Frame.Parent = Billboard

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Icon .. " " .. Gender
    Label.TextColor3 = Color
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Frame
end

local function HandlePlayer(Player)
	task.spawn(function()
		local R = GetGender(Player)
	    CreateOverhead(Player, R)
	
	    Player.CharacterAdded:Connect(function()
	        CreateOverhead(Player, R)
	    end)
	end)
end

for _, Player in Players:GetPlayers() do
    HandlePlayer(Player)
end

Players.PlayerAdded:Connect(HandlePlayer)
