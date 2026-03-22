local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local AppearanceCache = {}

local function Get(File)
	return HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/roblox-get-avatar-info/refs/heads/main/data/" .. File))
end

local Names = Get("gender_names.json")
local Items = Get("avatar_items.json")

local function GetAppearance(UserId)
	if AppearanceCache[UserId] then
		return true, AppearanceCache[UserId]
	end

	local Success, Info = pcall(function()
		return Players:GetCharacterAppearanceInfoAsync(UserId)
	end)

	if Success and Info then
		AppearanceCache[UserId] = Info
	end

	return Success, Info
end

local function CheckItems(AppearanceInfo)
	local Score = { Male = 0, Female = 0 }
	local Hits  = { Male = {}, Female = {} }

	local function MatchesKeyword(Words, Keyword)
		local KeyWords = Keyword:split(" ")
		local KeyLen   = #KeyWords
		for i = 1, #Words - KeyLen + 1 do
			local Match = true
			for j = 1, KeyLen do
				if Words[i + j - 1] ~= KeyWords[j] then
					Match = false
					break
				end
			end
			if Match then return true end
		end
		return false
	end

	for _, Asset in AppearanceInfo.assets do
		local Words = Asset.name:lower():split(" ")
		for _, Gender in { "Male", "Female" } do
			for _, Keyword in Items[Gender] do
				if MatchesKeyword(Words, Keyword) then
					Score[Gender] += 1
					table.insert(Hits[Gender], { Keyword = Keyword, Item = Asset.name })
				end
			end
		end
	end

	if Score.Male == 0 and Score.Female == 0 then return nil end

	local Winner = Score.Male > Score.Female and "Male" or "Female"
	local TopHit = Hits[Winner][1]
	return {
		Method = {
			Name  = "Avatar Item Check",
			Value = TopHit.Keyword,
			Item  = TopHit.Item,
			Score = Score
		},
		Gender = Winner
	}
end

local GetInfo = {}

function GetInfo:GetGender(Target)
	local function Handle(Gender)
		local N, D = Target.Name:lower(), Target.DisplayName:lower()
		for _, Name in Names[Gender] do
			if N:find(Name) then
				return { Method = { Name = "Name Check", Value = Name }, Gender = Gender }
			end
			if D:find(Name) then
				return { Method = { Name = "Display Name Check", Value = Name }, Gender = Gender }
			end
		end
	end

	local R = Handle("Male")   if R then return R end
	local R = Handle("Female") if R then return R end

	local Success, AppearanceInfo = GetAppearance(Target.UserId)
	if Success and AppearanceInfo then
		return CheckItems(AppearanceInfo)
	end
end

function GetInfo:GetRace(Target)
	local Success, AppearanceInfo = GetAppearance(Target.UserId)
	if not Success or not AppearanceInfo then return nil end

	local BC = AppearanceInfo.bodyColors
	local ColorIds = {
		BC.headColorId,
		BC.torsoColorId,
		BC.leftArmColorId,
		BC.rightArmColorId,
		BC.leftLegColorId,
		BC.rightLegColorId,
	}

	local First = ColorIds[1]
	for i = 2, #ColorIds do
		if ColorIds[i] ~= First then return nil end
	end

	local Color      = BrickColor.new(First).Color
	local Brightness = (Color.R + Color.G + Color.B) / 3

	if not (Color.R - Color.G >= 0.04 and Color.R > Color.B) then
		return nil
	end

	local Race
	if Brightness >= 0.55 then
		Race = "White"
	elseif Brightness <= 0.38 then
		Race = "Black"
	else
		Race = "Mixed"
	end

	return {
		Method = {
			Name         = "Skin Color Check",
			BrickColorId = First,
			BrickColor   = BrickColor.new(First).Name,
			Brightness   = math.floor(Brightness * 100) / 100
		},
		Race = Race
	}
end

function GetInfo:GetAvatarValue(Target)
	local Success, AppearanceInfo = GetAppearance(Target.UserId)
	if not Success or not AppearanceInfo then return nil end

	local Total = 0
	local Assets = {}

	for _, Asset in AppearanceInfo.assets do
		local Ok, Info
		repeat
			Ok, Info = pcall(function()
				return MarketplaceService:GetProductInfo(Asset.id)
			end)
			if not Ok then task.wait(0.5) end
		until Ok and Info

		local Price = (Info.IsForSale and Info.PriceInRobux) or 0
		Total += Price
		table.insert(Assets, {
			Id    = Asset.id,
			Name  = Asset.name,
			Price = Price,
		})
	end

	return {
		Total  = Total,
		Assets = Assets,
	}
end

return GetInfo
