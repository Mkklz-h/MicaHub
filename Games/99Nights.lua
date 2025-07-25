local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()

local MicaHub = {}
MicaHub.__index = MicaHub

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

MicaHub.MainFireList = {"Coal", "Fuel Canister"}
MicaHub.ScrapperList = {"Sheet Metal", "Log", "UFO Scrap"}

MicaHub.ItemConnection = nil
MicaHub.WalkSpeedEnabled = false
MicaHub.FpsBoosterEnabled = false
MicaHub.InstantChestEnabled = false
MicaHub.SearchItemsEnabled = false
MicaHub.ProcessingItem = false

MicaHub.new = function()
    local self = setmetatable({}, MicaHub)
    self.Window = Library:CreateWindow("MicaHub")
    self:InitializeAntiKick()
    self:SetupButtons()
    return self
end

MicaHub.SafeExecute = function(self, operation, ...)
    local success, result = pcall(operation, ...)
    return success, result
end

MicaHub.ValidateObject = function(self, object)
    return object and object.Parent and not object.Parent:IsA("TempStorage")
end

MicaHub.WaitForService = function(self, serviceName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    while tick() - startTime < timeout do
        local success, service = self:SafeExecute(function()
            return game:GetService(serviceName)
        end)
        
        if success and service then
            return service
        end
        
        wait(0.1)
    end
    
    return nil
end

MicaHub.InitializeAntiKick = function(self)
    local success, result = self:SafeExecute(function()
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
    end)
    
    return success
end

MicaHub.GetWorkspaceMap = function(self)
    local success, map = self:SafeExecute(function()
        return workspace.Map
    end)
    
    return success and map or nil
end

MicaHub.GetCampgroundObject = function(self, objectName)
    local map = self:GetWorkspaceMap()
    if not map then return nil end
    
    local success, object = self:SafeExecute(function()
        return map.Campground[objectName]
    end)
    
    return success and object or nil
end

MicaHub.GetMainFireCenter = function(self)
    local mainFire = self:GetCampgroundObject("MainFire")
    if not mainFire then return nil end
    
    local success, center = self:SafeExecute(function()
        return mainFire.Center
    end)
    
    return success and center or nil
end

MicaHub.GetScrapperPart = function(self)
    local scrapper = self:GetCampgroundObject("Scrapper")
    if not scrapper then return nil end
    
    local success, primaryPart = self:SafeExecute(function()
        return scrapper.PrimaryPart
    end)
    
    return success and primaryPart or nil
end

MicaHub.GetItemsContainer = function(self)
    local success, items = self:SafeExecute(function()
        return workspace.Items
    end)
    
    return success and items or nil
end

MicaHub.GetRemoteEvents = function(self)
    local success, remoteEvents = self:SafeExecute(function()
        return ReplicatedStorage:WaitForChild("RemoteEvents", 5)
    end)
    
    return success and remoteEvents or nil
end

MicaHub.IsValidItemType = function(self, itemName)
    for _, item in pairs(self.MainFireList) do
        if item == itemName then return true end
    end
    
    for _, item in pairs(self.ScrapperList) do
        if item == itemName then return true end
    end
    
    return false
end

MicaHub.GetItemDestination = function(self, itemName)
    for _, item in pairs(self.ScrapperList) do
        if item == itemName then
            return self:GetScrapperPart()
        end
    end
    
    for _, item in pairs(self.MainFireList) do
        if item == itemName then
            return self:GetMainFireCenter()
        end
    end
    
    return nil
end

MicaHub.FindAvailableItems = function(self)
    local items = self:GetItemsContainer()
    if not items then return {} end
    
    local availableItems = {}
    
    local success, result = self:SafeExecute(function()
        for _, item in pairs(items:GetChildren()) do
            if self:ValidateObject(item) and self:IsValidItemType(item.Name) then
                table.insert(availableItems, item)
            end
        end
    end)
    
    return success and availableItems or {}
end

MicaHub.SelectRandomItem = function(self)
    local availableItems = self:FindAvailableItems()
    
    if #availableItems == 0 then
        return nil
    end
    
    local randomIndex = math.random(1, #availableItems)
    return availableItems[randomIndex]
end

MicaHub.GetItemMainPart = function(self, item)
    if not self:ValidateObject(item) then return nil end
    
    local success, part = self:SafeExecute(function()
        return item:FindFirstChild("Main") or item:FindFirstChild("Coal")
    end)
    
    return success and part or nil
end

MicaHub.SendRemoteEvent = function(self, eventName, args)
    local remoteEvents = self:GetRemoteEvents()
    if not remoteEvents then return false end
    
    local success, result = self:SafeExecute(function()
        local event = remoteEvents:WaitForChild(eventName, 3)
        if event then
            event:FireServer(unpack(args))
            return true
        end
        return false
    end)
    
    return success and result
end

MicaHub.InteractWithItem = function(self, item)
    if not self:ValidateObject(item) then return false end
    
    local startSuccess = self:SendRemoteEvent("RequestStartDraggingItem", {item})
    if not startSuccess then return false end
    
    wait(0.1)
    
    local stopSuccess = self:SendRemoteEvent("StopDraggingItem", {item})
    if not stopSuccess then return false end
    
    wait(0.1)
    return true
end

MicaHub.TeleportItemPart = function(self, itemPart, destination)
    if not self:ValidateObject(itemPart) or not destination then return false end
    
    local success, result = self:SafeExecute(function()
        itemPart.CFrame = destination.CFrame + Vector3.new(0, 15, 0)
        return true
    end)
    
    return success and result
end

MicaHub.CreateItemTween = function(self, itemPart, destination, callback)
    if not self:ValidateObject(itemPart) or not destination then
        if callback then callback() end
        return false
    end
    
    local success, result = self:SafeExecute(function()
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(itemPart, tweenInfo, {CFrame = destination.CFrame})
        tween:Play()
        
        if callback then
            tween.Completed:Connect(callback)
        end
        
        return true
    end)
    
    return success and result
end

MicaHub.MoveItemToDestination = function(self, item, callback)
    if not self:ValidateObject(item) then
        if callback then callback() end
        return false
    end
    
    local itemPart = self:GetItemMainPart(item)
    if not itemPart then
        if callback then callback() end
        return false
    end
    
    local destination = self:GetItemDestination(item.Name)
    if not destination then
        if callback then callback() end
        return false
    end
    
    local teleportSuccess = self:TeleportItemPart(itemPart, destination)
    if not teleportSuccess then
        if callback then callback() end
        return false
    end
    
    wait(0.1)
    
    local tweenSuccess = self:CreateItemTween(itemPart, destination, callback)
    return tweenSuccess
end

MicaHub.MonitorItemDestruction = function(self, item, callback)
    if not self:ValidateObject(item) then
        if callback then callback() end
        return
    end
    
    local success, connection = self:SafeExecute(function()
        return item.AncestryChanged:Connect(function()
            if not item.Parent then
                if callback then callback() end
            end
        end)
    end)
    
    return success and connection or nil
end

MicaHub.ProcessSingleItem = function(self, item)
    if not self:ValidateObject(item) or not self.SearchItemsEnabled or self.ProcessingItem then
        return false
    end
    
    self.ProcessingItem = true
    
    spawn(function()
        local interactionSuccess = self:InteractWithItem(item)
        
        if not interactionSuccess or not self:ValidateObject(item) then
            self:ResetProcessingState()
            return
        end
        
        local destructionConnection = self:MonitorItemDestruction(item, function()
            self:ResetProcessingState()
        end)
        
        local moveSuccess = self:MoveItemToDestination(item, function()
            wait(0.5)
        end)
        
        if not moveSuccess then
            if destructionConnection then
                destructionConnection:Disconnect()
            end
            self:ResetProcessingState()
        end
    end)
    
    return true
end

MicaHub.ResetProcessingState = function(self)
    self.ProcessingItem = false
    if self.SearchItemsEnabled then
        wait(0.5)
        self:StartItemSearch()
    end
end

MicaHub.StartItemSearch = function(self)
    if not self.SearchItemsEnabled or self.ProcessingItem then return end
    
    local item = self:SelectRandomItem()
    
    if item then
        local processSuccess = self:ProcessSingleItem(item)
        if not processSuccess then
            wait(1)
            self:StartItemSearch()
        end
    else
        wait(1)
        if self.SearchItemsEnabled then
            self:StartItemSearch()
        end
    end
end

MicaHub.HandleNewItemSpawn = function(self, item)
    if not item:IsA("Model") or not self.SearchItemsEnabled or self.ProcessingItem then
        return
    end
    
    if not self:IsValidItemType(item.Name) then return end
    
    self:ProcessSingleItem(item)
end

MicaHub.SetupItemSpawnListener = function(self)
    local items = self:GetItemsContainer()
    if not items then return false end
    
    local success, connection = self:SafeExecute(function()
        return items.ChildAdded:Connect(function(item)
            self:HandleNewItemSpawn(item)
        end)
    end)
    
    if success and connection then
        self.ItemConnection = connection
        return true
    end
    
    return false
end

MicaHub.ValidateRequiredObjects = function(self)
    local mainFire = self:GetMainFireCenter()
    local scrapper = self:GetScrapperPart()
    
    return mainFire ~= nil and scrapper ~= nil
end

MicaHub.CleanupConnections = function(self)
    if self.ItemConnection then
        local success = self:SafeExecute(function()
            self.ItemConnection:Disconnect()
        end)
        self.ItemConnection = nil
    end
end

MicaHub.EnableItemSearch = function(self)
    if self.SearchItemsEnabled then return true end
    
    if not self:ValidateRequiredObjects() then
        return false
    end
    
    self.SearchItemsEnabled = true
    self.ProcessingItem = false
    
    local listenerSuccess = self:SetupItemSpawnListener()
    if not listenerSuccess then
        self.SearchItemsEnabled = false
        return false
    end
    
    self:StartItemSearch()
    return true
end

MicaHub.DisableItemSearch = function(self)
    self.SearchItemsEnabled = false
    self.ProcessingItem = false
    self:CleanupConnections()
end

MicaHub.ToggleSearchItems = function(self, state)
    if state then
        return self:EnableItemSearch()
    else
        self:DisableItemSearch()
        return true
    end
end

MicaHub.GetPlayerCharacter = function(self)
    local player = Players.LocalPlayer
    if not player then return nil end
    
    local success, character = self:SafeExecute(function()
        return player.Character
    end)
    
    return success and character or nil
end

MicaHub.GetCharacterHumanoid = function(self, character)
    if not character then return nil end
    
    local success, humanoid = self:SafeExecute(function()
        return character:WaitForChild("Humanoid", 5)
    end)
    
    return success and humanoid or nil
end

MicaHub.SetHumanoidWalkSpeed = function(self, humanoid, speed)
    if not humanoid then return false end
    
    local success = self:SafeExecute(function()
        humanoid.WalkSpeed = speed
    end)
    
    return success
end

MicaHub.MonitorWalkSpeedChanges = function(self, humanoid, targetSpeed)
    if not humanoid then return end
    
    self:SafeExecute(function()
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= targetSpeed then
                self:SetHumanoidWalkSpeed(humanoid, targetSpeed)
            end
        end)
    end)
end

MicaHub.ApplyWalkSpeedToCharacter = function(self, character)
    local humanoid = self:GetCharacterHumanoid(character)
    if not humanoid then return false end
    
    local setSuccess = self:SetHumanoidWalkSpeed(humanoid, 30)
    if not setSuccess then return false end
    
    self:MonitorWalkSpeedChanges(humanoid, 30)
    return true
end

MicaHub.EnableWalkSpeed = function(self)
    if self.WalkSpeedEnabled then return end
    
    self.WalkSpeedEnabled = true
    
    local player = Players.LocalPlayer
    if not player then return end
    
    local currentCharacter = self:GetPlayerCharacter()
    if currentCharacter then
        self:ApplyWalkSpeedToCharacter(currentCharacter)
    end
    
    self:SafeExecute(function()
        player.CharacterAdded:Connect(function(character)
            self:ApplyWalkSpeedToCharacter(character)
        end)
    end)
end

MicaHub.ConfigureProximityPrompt = function(self, prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    
    local success = self:SafeExecute(function()
        prompt.HoldDuration = 0
        
        prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
            if prompt.HoldDuration ~= 0 then
                prompt.HoldDuration = 0
            end
        end)
    end)
    
    return success
end

MicaHub.ProcessWorkspaceDescendants = function(self, processor)
    local success = self:SafeExecute(function()
        for _, descendant in pairs(workspace:GetDescendants()) do
            processor(descendant)
        end
    end)
    
    return success
end

MicaHub.MonitorWorkspaceChanges = function(self, processor)
    self:SafeExecute(function()
        workspace.DescendantAdded:Connect(function(descendant)
            processor(descendant)
        end)
    end)
end

MicaHub.EnableInstantChests = function(self)
    if self.InstantChestEnabled then return end
    
    self.InstantChestEnabled = true
    
    self:ProcessWorkspaceDescendants(function(descendant)
        self:ConfigureProximityPrompt(descendant)
    end)
    
    self:MonitorWorkspaceChanges(function(descendant)
        self:ConfigureProximityPrompt(descendant)
    end)
end

MicaHub.SetPartMaterial = function(self, obj)
    if not obj:IsA("BasePart") then return false end
    
    local success = self:SafeExecute(function()
        obj.Material = Enum.Material.Plastic
    end)
    
    return success
end

MicaHub.EnableFpsBooster = function(self)
    if self.FpsBoosterEnabled then return end
    
    self.FpsBoosterEnabled = true
    
    self:ProcessWorkspaceDescendants(function(obj)
        self:SetPartMaterial(obj)
    end)
    
    self:MonitorWorkspaceChanges(function(obj)
        self:SetPartMaterial(obj)
    end)
end

MicaHub.CreateButton = function(self, text, callback)
    local success = self:SafeExecute(function()
        self.Window:AddButton({
            text = text,
            flag = "button",
            callback = callback
        })
    end)
    
    return success
end

MicaHub.CreateToggle = function(self, text, callback)
    local success = self:SafeExecute(function()
        self.Window:AddToggle({
            text = text,
            flag = "toggle",
            callback = callback
        })
    end)
    
    return success
end

MicaHub.CreateLabel = function(self, text)
    local success = self:SafeExecute(function()
        self.Window:AddLabel({
            text = text,
            type = "label"
        })
    end)
    
    return success
end

MicaHub.SetupButtons = function(self)
    self:CreateButton("Walk Speed", function()
        self:EnableWalkSpeed()
    end)

    self:CreateButton("Instant Interact", function()
        self:EnableInstantChests()
    end)

    self:CreateButton("Fps Booster [BETA]", function()
        self:EnableFpsBooster()
    end)

    self:CreateToggle("Search Items", function(state)
        self:ToggleSearchItems(state)
    end)

    self:CreateLabel("GitHub: Mkklz-h")
end

local hub = MicaHub.new()
Library:Init()