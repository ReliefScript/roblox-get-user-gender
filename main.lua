local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

if not isfolder("GetGender") then
    makefolder("GetGender")
end

local function Get(File)
    local Path = "GetGender/" .. File
    local Result = isfile(Path) and readfile(Path)
    if not Result then
        local Url = "https://raw.githubusercontent.com/ReliefScript/roblox-get-user-gender/refs/heads/main/" .. File
        Result = game:HttpGet(Url)
        writefile(Path, Result)
    end
    return HttpService:JSONDecode(Result)
end

local Names = Get("gender_names.json")
local Items = Get("avatar_items.json")

local function CheckItems(AppearanceInfo)
    local Score = { Male = 0, Female = 0 }
    local Hits = { Male = {}, Female = {} }

    for _, Asset in AppearanceInfo.assets do
        local Words = Asset.name:lower():split(" ")
        for _, Word in Words do
            for _, Gender in { "Male", "Female" } do
                for _, Keyword in Items[Gender] do
                    if Word == Keyword then
                        Score[Gender] += 1
                        table.insert(Hits[Gender], { Keyword = Keyword, Item = Asset.name })
                    end
                end
            end
        end
    end

    if Score.Male == 0 and Score.Female == 0 then return nil end

    local Winner = Score.Male > Score.Female and "Male" or "Female"
    local TopHit = Hits[Winner][1]
    return {
        Method = {
            Name = "Avatar Item Check",
            Value = TopHit.Keyword,
            Item = TopHit.Item,
            Score = Score
        },
        Gender = Winner
    }
end

local function GetGender(Target)
    local Success, AppearanceInfo = pcall(function()
        return Players:GetCharacterAppearanceInfoAsync(Target.UserId)
    end)

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

    local R = Handle("Male") if R then return R end
    local R = Handle("Female") if R then return R end

    if Success and AppearanceInfo then
        return CheckItems(AppearanceInfo)
    end
end

return GetGender
