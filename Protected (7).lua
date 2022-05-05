if getgenv().executed then return end
if not game.PlaceId == 9300407930 then return end

local Plr = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character = Plr.Character
local HTTPService = game:GetService("HttpService")
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = 'Secret Hub (Bot Clash)', HidePremium = true, SaveConfig = SaveSettings, ConfigFolder = CFolderName})

local LocalPlayerTab = Window:MakeTab({
	Name = "Client Modifier",
	Icon = "rbxassetid://6513421738",
	PremiumOnly = false
})

local BypassSpeed = false
local BypassJumpPower = false
local PlrsToTP = {}
local OldIndex

-- OldIndex = hookmetamethod(game,"__index",newcclosure(function(Self, ...)
--     local args = {...}
--     local Key = args[1]    
--     -- if not checkcaller() and Self== game.Players.LocalPlayer.Character.Humanoid and Key == "Walkspeed" and BypassSpeed then
--     --     return
--     -- end
--     return OldIndex(...)
-- end))


LocalPlayerTab:AddToggle({
	Name = "Speed Bypass",
	Default = false,
	Callback = function(Value)
		BypassSpeed = Value
	end    
})

LocalPlayerTab:AddSlider({
	Name = "Speed Slider",
	Min = 0,
	Max = 120,
	Default = 5,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "WalkSpeed",
	Callback = function(Value)
		Plr.Character.Humanoid.WalkSpeed = Value
	end    
})

local LocalPlayerTab = LocalPlayerTab:AddDropdown({
	Name = "Teleport To Player",
	Default = "Choose a Player",
	Options = {unpack(PlrsToTP)},
	Callback = function(Value)
		local Players = game.Players:GetChildren()

        for i,v in pairs(Players)do
            if v.Name == Value then
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    Plr.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                end
            end
        end
	end    
})

task.spawn(function()
    while task.wait(5)do
        LocalPlayerTab:Refresh(PlrsToTP,true)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local function GivePlayersArray()
        local PlrsArray = {}

        for i,v in pairs(game.Players:GetChildren())do
            table.insert(PlrsArray,#PlrsArray+1,v.Name)
        end

        PlrsToTP = PlrsArray
    end

    GivePlayersArray()
end)

local FarmingTab = Window:MakeTab({
	Name = "Farming",
	Icon = "rbxassetid://6513421738",
	PremiumOnly = false
})

 
local CoinsFolder = game:GetService("Workspace").PICK


local function PickupAllMethod1()
    for i,v in pairs(CoinsFolder:GetChildren())do
        v.Root.CFrame = Character.HumanoidRootPart.CFrame
    end
end

local function PickupAllMethod2()
    for i,v in pairs(CoinsFolder:GetChildren())do
        task.wait()
       ReplicatedStorage.Remotes.PickRE:FireServer(v.Name)
    end
end


getgenv().AutoCollectCoinsMethod1 = false

FarmingTab:AddToggle({
	Name = "Auto Collect Coins (Method 1) (Recommended)",
	Default = false,
	Callback = function(Value)
		if Value and not AutoCollectCoinsMethod1 then
            AutoCollectCoinsMethod1 = true
            while AutoCollectCoinsMethod1 do 
                task.wait()
                PickupAllMethod1()
            end
        end

        if not Value then
            AutoCollectCoinsMethod1 = false
        end
	end    

})
getgenv().AutoCollectCoinsMethod2 = false

FarmingTab:AddToggle({
	Name = "Auto Collect Coins (Method 2)",
	Default = false,
	Callback = function(Value)
		if Value and not AutoCollectCoinsMethod2 then
            AutoCollectCoinsMethod2 = true
            while AutoCollectCoinsMethod2 do 
                task.wait()
                PickupAllMethod2()
            end
        end

        if not Value then
            AutoCollectCoinsMethod2 = false
        end
	end    
})

local CurrentFarmingArea
local CurrentObjectsFarming = {}
local CurrentlyFarming = false

local AreasTable = {
    ["Area 1"] = "W01",
    ["Area 2"] = "W02",
    ["Area 3"] = "W03"
}

local SortType = {
    ["Turrets Tier 1"] = "_T_1",
    ["Turrets Tier 2"] = "_T_2",
    ["Barrels"] = "_B",
    ["Elite Turrets"] = "_E"
}



local SortTypeUnpack = {}

for i,_ in pairs(SortType)do
    table.insert(SortTypeUnpack,i)
end

local NPCFolder = game:GetService("Workspace").NPC

FarmingTab:AddDropdown({
	Name = "Choose a Farming Area",
	Default = "Area 1",
	Options = {"ALL","Area 1","Area 2","Area 3"},
	Callback = function(Value)

        if Value == "ALL" then CurrentFarmingArea = "ALL" return end

		if AreasTable[Value] then
            CurrentFarmingArea = AreasTable[Value]
        end
	end    
})

local FarmingObjects = FarmingTab:AddParagraph("Objects Farming:","...")

game:GetService("RunService").Heartbeat:Connect(function()
    FarmingObjects:Set(table.concat(CurrentObjectsFarming,", "))
end)

FarmingTab:AddDropdown({
	Name = "Select Objects To Farm (Don't choose if ALL)",
	Default = "Select One",
	Options = {unpack(SortTypeUnpack)},
	Callback = function(Value)
		if table.find(CurrentObjectsFarming,SortType[Value]) then
            table.remove(CurrentObjectsFarming,table.find(CurrentObjectsFarming,SortType[Value]))
            warn('found and removed')
        else
            table.insert(CurrentObjectsFarming,#CurrentObjectsFarming+1,SortType[Value])
        end

        print(table.concat(CurrentObjectsFarming,","))
	end    
})



getgenv().Autofarm = false

local function AutofarmTarget()
    local npcs = game:GetService("Workspace").NPC
    local Target

    local function GetArea(FullTargetName)
        local Area = string.sub(FullTargetName, 1, 3)

        if CurrentFarmingArea == "ALL" then return true end

        if CurrentFarmingArea == Area or Area == CurrentFarmingArea then
            return true
        else
            return false
        end
    end

    local function GetSortType(FullTargetName)
        if #CurrentObjectsFarming == 0 then return true end
        local TargetSortType
        for i,v in pairs(CurrentObjectsFarming)do
            if FullTargetName:match(v) then
                warn("Matched", FullTargetName:match(v))
                TargetSortType = true
                break
            end
        end

        return TargetSortType
    end

    for i,v in pairs(npcs:GetChildren())do
        if GetArea(v.Name) and GetSortType(v.Name) and v:FindFirstChild("ModelObj") and v:FindFirstChild("ModelObj"):FindFirstChild("Click") then
            Target = v
            break
        end
    end

    if Target then
        local CheckingOnTarget = false
        task.wait(0.1)
        if Target:FindFirstChild("SetTargetRE") then
            Target.SetTargetRE:FireServer()
            warn("Fired Server ",Target)
            warn(Plr.TeamTarget.Value)
            repeat
                task.wait()
                if not Target.Parent or not Target:FindFirstChild("ModelObj") or not Autofarm then return end

                if Plr.TeamTarget.Value ~= Target and not CheckingOnTarget then
                    CheckingOnTarget = true
                    task.delay(0.5,function()
                        if Plr.TeamTarget.Value ~= Target then
                            Target.SetTargetRE:FireServer()
                        end
                        CheckingOnTarget = false
                    end)
                end
            until
            Target.Parent == nil or not Target:FindFirstChild("ModelObj")
        end
    end
    
end

FarmingTab:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(Value)
		if Value and not Autofarm then
            Autofarm = true
            while Autofarm do
                task.wait()
                AutofarmTarget()
            end
        end

        if not Value then
            Autofarm = false
        end
	end    
})


local SummonTab = Window:MakeTab({
	Name = "Auto Summon",
	Icon = "rbxassetid://6513421738",
	PremiumOnly = false
})

local OpenScript = game:GetService("Players").LocalPlayer.PlayerScripts.LocalGameUIMgr



-- local WorldSummons = {
--     W1 = game:GetService("Workspace").Area["W_01"].Base.Store,
--     World1Summons = {
--         ["Tier 1 Summon"] = W1:FindFirstChild("robo_lottery004"),
--         ["Tier 2 Summon"] = W1:FindFirstChild("robo_lottery003"),
--         ["Tier 3 Summon"] = W1:FindFirstChild("robo_lottery002")
--     }
-- }





OldIndex = hookmetamethod(game,"__index",function(...)
    local args = {...}

    local Self = args[1]
    local Key = args[2]

    if Self == OpenScript and Key == "Disabled" then
        return false
    end

    return OldIndex(...)
end)

local function SkipOpeningScreen(Value)
    OpenScript.Disabled = Value 
end

SummonTab:AddToggle({
	Name = "Skip Summon Animation",
	Default = false,
	Callback = function(Value)
        SkipOpeningScreen(Value)
	end    
})




OrionLib:Init()
