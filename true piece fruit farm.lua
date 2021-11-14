--Credits to SenseiJoshy just fixed his script
--wait until game has loaded
if (not game:IsLoaded()) then
    game.Loaded:Wait();
end;

print("started")

--teleport function
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end


--Main Script
if ServerHop then
    while wait(20) do
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.StartUp:InvokeServer()
        end)
        wait(5)
        for i, v in pairs(game.Workspace.Map.Trees:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Leaf") and v:FindFirstChild("MeshPart1") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Leaf.CFrame
                wait(.5)
                fireproximityprompt(v.Leaf.ProximityPromptDF)
                wait(0.1)
            end
        end
        wait(5)
        for i, v in pairs(game.Workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Leaf") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Leaf.CFrame
                wait(.5)
                fireproximityprompt(v.Leaf.ProximityPromptDF)
                wait(0.1)
            end
        end
        syn.queue_on_teleport([[
        getgenv().ServerHop = true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WalterCums/Scripts/main/true%20piece%20fruit%20farm.lua"))()
        ]])
        repeat wait()
            Teleport()
        until not ServerHop
    end
end
