local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()

local MicaHub = {}
MicaHub.__index = MicaHub

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

MicaHub.ItemConnection = nil
MicaHub.WalkSpeedEnabled = false
MicaHub.FpsBoosterEnabled = false
MicaHub.InstantChestEnabled = false
MicaHub.SearchItemsEnabled = false
MicaHub.ProcessingItem = false

MicaHub.ItemTypes = {"Coal", "Fuel Canister"}

MicaHub.new = function()
    local self = setmetatable({}, MicaHub)
    self.Window = Library:CreateWindow("MicaHub")
    self:InitializeAntiKick()
    self:SetupButtons()
    return self
end

MicaHub.InitializeAntiKick = function(self)
    local Registro = getreg()
    local Blocklist = {"kick", "ban"}
    
    for _, func in pairs(Registro) do
        if type(func) == "function" then
            local data = getinfo(func)
            if data and data.name then
                for _, target in pairs(Blocklist) do
                    if string.lower(data.name) == string.lower(target) then
                        hookfunction(data.func, function() 
                            return nil 
                        end)
                        break
                    end
                end
            end
        end
    end
end

MicaHub.ApplyWalkSpeed = function(self, character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 30
    
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= 30 then
            humanoid.WalkSpeed = 30
        end
    end)
end

MicaHub.EnableWalkSpeed = function(self)
    if self.WalkSpeedEnabled then return end
    self.WalkSpeedEnabled = true
    
    local player = game.Players.LocalPlayer
    
    if player.Character then
        self:ApplyWalkSpeed(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        self:ApplyWalkSpeed(character)
    end)
end

MicaHub.ConfigurePrompt = function(self, prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    
    prompt.HoldDuration = 0
    prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
        if prompt.HoldDuration ~= 0 then
            prompt.HoldDuration = 0
        end
    end)
end

MicaHub.EnableInstantChests = function(self)
    if self.InstantChestEnabled then return end
    self.InstantChestEnabled = true
    
    for _, descendant in pairs(workspace:GetDescendants()) do
        self:ConfigurePrompt(descendant)
    end
    
    workspace.DescendantAdded:Connect(function(descendant)
        self:ConfigurePrompt(descendant)
    end)
end

MicaHub.SetPartMaterial = function(self, obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
    end
end

MicaHub.EnableFpsBooster = function(self)
    if self.FpsBoosterEnabled then return end
    self.FpsBoosterEnabled = true
    
    for _, obj in pairs(workspace:GetDescendants()) do
        self:SetPartMaterial(obj)
    end
    
    workspace.DescendantAdded:Connect(function(obj)
        self:SetPartMaterial(obj)
    end)
end

MicaHub.GetRandomAvailableItem = function(self)
    local items = workspace:FindFirstChild("Items")
    if not items then return nil end
    
    local availableItems = {}
    
    for _, item in pairs(items:GetChildren()) do
        for _, itemType in pairs(self.ItemTypes) do
            if item.Name == itemType then
                table.insert(availableItems, item)
            end
        end
    end
    
    if #availableItems == 0 then return nil end
    
    local randomIndex = math.random(1, #availableItems)
    return availableItems[randomIndex]
end

MicaHub.InteractWithItem = function(self, item)
    local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
    
    local startArgs = {item}
    remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(unpack(startArgs))
    wait(0.1)

    local stopArgs = {item}
    remoteEvents:WaitForChild("StopDraggingItem"):FireServer(unpack(stopArgs))
    wait(0.1)
end

MicaHub.TeleportItemToFire = function(self, item, callback)
    local itemPart = item:FindFirstChild("Main") or item:FindFirstChild("Coal")
    if not itemPart then
        if callback then callback() end
        return
    end
    
    local mainFire = workspace.Map and workspace.Map.Campground and workspace.Map.Campground.MainFire
    if not mainFire or not mainFire:FindFirstChild("Center") then
        if callback then callback() end
        return
    end
    
    local centerPart = mainFire.Center
    itemPart.CFrame = centerPart.CFrame + Vector3.new(0, 15, 0)
    wait(0.1)

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(itemPart, tweenInfo, {CFrame = centerPart.CFrame})
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
end

MicaHub.ProcessItem = function(self, item)
    if not item or not item.Parent or not self.SearchItemsEnabled or self.ProcessingItem then 
        return 
    end
    
    self.ProcessingItem = true
    
    spawn(function()
        self:InteractWithItem(item)
        
        local itemDestroyedConnection
        itemDestroyedConnection = item.AncestryChanged:Connect(function()
            if not item.Parent then
                itemDestroyedConnection:Disconnect()
                self.ProcessingItem = false
                if self.SearchItemsEnabled then
                    wait(0.5)
                    self:SearchAndProcessNextItem()
                end
            end
        end)
        
        self:TeleportItemToFire(item, function()
            wait(0.5)
        end)
    end)
end

MicaHub.SearchAndProcessNextItem = function(self)
    if not self.SearchItemsEnabled or self.ProcessingItem then return end
    
    local item = self:GetRandomAvailableItem()
    
    if item then
        self:ProcessItem(item)
    else
        wait(1)
        if self.SearchItemsEnabled then
            self:SearchAndProcessNextItem()
        end
    end
end

MicaHub.HandleNewItem = function(self, item)
    if not item:IsA("Model") or not self.SearchItemsEnabled or self.ProcessingItem then 
        return 
    end
    
    local isValidItem = false
    for _, itemType in pairs(self.ItemTypes) do
        if item.Name == itemType then
            isValidItem = true
            break
        end
    end
    
    if not isValidItem then return end
    
    self:ProcessItem(item)
end

MicaHub.ToggleSearchItems = function(self, state)
    if self.ItemConnection then
        self.ItemConnection:Disconnect()
        self.ItemConnection = nil
    end

    if not state then 
        self.SearchItemsEnabled = false
        self.ProcessingItem = false
        return 
    end

    if self.SearchItemsEnabled then return end

    local mainFire = workspace.Map and workspace.Map.Campground and workspace.Map.Campground.MainFire
    if not mainFire or not mainFire:FindFirstChild("Center") then
        return
    end

    self.SearchItemsEnabled = true
    self.ProcessingItem = false

    local items = workspace:FindFirstChild("Items")
    if items then
        self.ItemConnection = items.ChildAdded:Connect(function(item)
            self:HandleNewItem(item)
        end)
    end
    
    self:SearchAndProcessNextItem()
end

MicaHub.SetupButtons = function(self)
    self.Window:AddButton({
        text = "Walk Speed",
        flag = "button",
        callback = function()
            self:EnableWalkSpeed()
        end
    })

    self.Window:AddButton({
        text = "Instant Chests",
        flag = "button",
        callback = function()
            self:EnableInstantChests()
        end
    })

    self.Window:AddButton({
        text = "Fps Booster [BETA]",
        flag = "button",
        callback = function()
            self:EnableFpsBooster()
        end
    })

    self.Window:AddToggle({
        text = "Search Items",
        flag = "toggle",
        callback = function(state)
            self:ToggleSearchItems(state)
        end
    })

    self.Window:AddLabel({
        text = "GitHub: Mkklz-h",
        type = "label"
    })
end

local hub = MicaHub.new()
Library:Init()