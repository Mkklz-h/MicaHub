local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()
local Window = Library:CreateWindow("MicaHub")

local TweenService = game:GetService("TweenService")
local ItemConnections = {}

local WalkSpeedEnabled = false
local FpsBoosterEnabled = false
local InstantChestEnabled = false
local SearchItemsEnabled = false

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

Window:AddButton({
    text = "Walk Speed",
    flag = "button",
    callback = function()
        if WalkSpeedEnabled then return end
        WalkSpeedEnabled = true
        
        local player = game.Players.LocalPlayer
        
        local function applyWalkSpeed(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.WalkSpeed = 30
            
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if humanoid.WalkSpeed ~= 30 then
                    humanoid.WalkSpeed = 30
                end
            end)
        end
        
        if player.Character then
            applyWalkSpeed(player.Character)
        end
        
        player.CharacterAdded:Connect(applyWalkSpeed)
    end
})

Window:AddButton({
    text = "Instant Chests",
    flag = "button",
    callback = function()
        if InstantChestEnabled then return end
        InstantChestEnabled = true
        
        local function configurePrompt(prompt)
            if not prompt:IsA("ProximityPrompt") then return end
            
            prompt.HoldDuration = 0
            prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if prompt.HoldDuration ~= 0 then
                    prompt.HoldDuration = 0
                end
            end)
        end
        
        for _, descendant in pairs(workspace:GetDescendants()) do
            configurePrompt(descendant)
        end
        
        workspace.DescendantAdded:Connect(configurePrompt)
    end
})

Window:AddButton({
    text = "Fps Booster [BETA]",
    flag = "button",
    callback = function()
        if FpsBoosterEnabled then return end
        FpsBoosterEnabled = true
        
        local lighting = game:GetService("Lighting")
        local destructiveNames = {"Foliage", "Bunny Burrow", "Boundaries"}
        
        local function optimizeObject(obj)
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ParticleEmitter") or 
                   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj:Destroy()
                return
            end
            
            for _, name in pairs(destructiveNames) do
                if obj.Name == name then
                    obj:Destroy()
                    return
                end
            end
        end
        
        local function setupLighting()
            lighting.Brightness = 5
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.FogEnd = math.huge
            lighting.FogStart = 0
            
            for _, child in pairs(lighting:GetChildren()) do
                child:Destroy()
            end
            
            local properties = {"Brightness", "GlobalShadows", "Ambient", "FogEnd", "FogStart"}
            local values = {5, false, Color3.new(1, 1, 1), math.huge, 0}
            
            for i, property in pairs(properties) do
                lighting:GetPropertyChangedSignal(property):Connect(function()
                    if lighting[property] ~= values[i] then
                        lighting[property] = values[i]
                    end
                end)
            end
            
            lighting.ChildAdded:Connect(function(child)
                child:Destroy()
            end)
        end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            optimizeObject(obj)
        end
        
        setupLighting()
        workspace.DescendantAdded:Connect(optimizeObject)
    end
})

Window:AddToggle({
    text = "Search Items",
    flag = "toggle",
    callback = function(state)
        SearchItemsEnabled = state
        
        for _, connection in pairs(ItemConnections) do
            if connection then connection:Disconnect() end
        end
        ItemConnections = {}
        
        if not SearchItemsEnabled then return end
        
        local itemTargets = {
            ["Coal"] = function()
                local path = workspace.Map and workspace.Map.Campground and workspace.Map.Campground.MainFire
                return path and path.Center
            end,
            ["Log"] = function()
                local path = workspace.Map and workspace.Map.Campground and workspace.Map.Campground.Scrapper
                return path and path.ScrapperParticles
            end,
            ["Fuel Canister"] = function()
                local path = workspace.Map and workspace.Map.Campground and workspace.Map.Campground.MainFire
                return path and path.Center
            end
        }
        
        local function teleportItem(itemPart, targetPart)
            if not itemPart.Parent or not SearchItemsEnabled then return end
            
            local aboveTarget = targetPart.CFrame + Vector3.new(0, 10, 0)
            itemPart.CFrame = aboveTarget
            
            local tween = TweenService:Create(itemPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), 
                {CFrame = targetPart.CFrame})
            tween:Play()
            
            local connection
            connection = tween.Completed:Connect(function()
                connection:Disconnect()
                if itemPart.Parent and SearchItemsEnabled then
                    wait(0.1)
                    teleportItem(itemPart, targetPart)
                end
            end)
            
            table.insert(ItemConnections, connection)
        end
        
        local function processNewItem(item)
            if not item:IsA("Model") or not SearchItemsEnabled then return end
            
            local getTarget = itemTargets[item.Name]
            if not getTarget then return end
            
            local targetPart = getTarget()
            if not targetPart then return end
            
            local itemPart = item:FindFirstChild("Main") or item:FindFirstChild("Coal")
            if not itemPart then return end
            
            teleportItem(itemPart, targetPart)
            
            local ancestryConnection
            ancestryConnection = item.AncestryChanged:Connect(function()
                if not item.Parent then
                    ancestryConnection:Disconnect()
                end
            end)
            
            table.insert(ItemConnections, ancestryConnection)
        end
        
        local items = workspace:FindFirstChild("Items")
        if items then
            for _, item in pairs(items:GetChildren()) do
                processNewItem(item)
            end
            
            local childAddedConnection = items.ChildAdded:Connect(processNewItem)
            table.insert(ItemConnections, childAddedConnection)
        end
    end
})

Window:AddLabel({
    text = "GitHub: Mkklz-h",
    type = "label"
})

Library:Init()