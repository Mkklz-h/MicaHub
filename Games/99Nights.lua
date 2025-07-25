local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()
local Window = Library:CreateWindow("MicaHub")
local folder = Window:AddFolder("Other Works")

local WalkSpeedEnabled = false
local InstantChestEnabled = false
local FpsBoosterEnabled = false
local EvolveBonfireEnabled = false
local CollectWoodEnabled = false

local CoalConnections = {}

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
		if not WalkSpeedEnabled then
			WalkSpeedEnabled = true
			
			local function setWalkSpeed()
				local player = game.Players.LocalPlayer
				if player and player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid.WalkSpeed = 30
				end
			end
			
			setWalkSpeed()
			
			game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				setWalkSpeed()
				
				character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if character.Humanoid.WalkSpeed ~= 30 then
						character.Humanoid.WalkSpeed = 30
					end
				end)
			end)
			
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if game.Players.LocalPlayer.Character.Humanoid.WalkSpeed ~= 30 then
						game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 30
					end
				end)
			end
		end
	end
})

Window:AddButton({
	text = "Instant Chests [MORE]",
	flag = "button",
	callback = function()
		if not InstantChestEnabled then
			InstantChestEnabled = true
			
			local function setInstantPrompt(prompt)
				if prompt:IsA("ProximityPrompt") then
					prompt.HoldDuration = 0
					
					prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
						if prompt.HoldDuration ~= 0 then
							prompt.HoldDuration = 0
						end
					end)
				end
			end
			
			local function processAllPrompts(obj)
				for _, child in pairs(obj:GetDescendants()) do
					setInstantPrompt(child)
				end
			end
			
			processAllPrompts(workspace)
			
			workspace.DescendantAdded:Connect(function(descendant)
				setInstantPrompt(descendant)
			end)
		end
	end
})

Window:AddButton({
	text = "Fps Booster [BETA]",
	flag = "button",
	callback = function()
		if not FpsBoosterEnabled then
			FpsBoosterEnabled = true
			
			local function changeMaterialAndRemoveTextures(obj)
				if obj:IsA("BasePart") then
					obj.Material = Enum.Material.Plastic
				end
				
				if obj:IsA("Texture") or obj:IsA("Decal") then
					obj:Destroy()
				end
				
				if obj.Name == "Foliage" or obj.Name == "Bunny Burrow" or obj.Name == "Boundaries" then
					obj:Destroy()
					return
				end
				
				for _, child in pairs(obj:GetChildren()) do
					changeMaterialAndRemoveTextures(child)
				end
			end
			
			local function optimizeLighting()
				local lighting = game:GetService("Lighting")
				
				lighting.Brightness = 5
				lighting.GlobalShadows = false
				lighting.Ambient = Color3.new(1, 1, 1)
				lighting.FogEnd = math.huge
				lighting.FogStart = 0
				
				for _, child in pairs(lighting:GetChildren()) do
					child:Destroy()
				end
			end
			
			changeMaterialAndRemoveTextures(workspace)
			optimizeLighting()
			
			local lighting = game:GetService("Lighting")
			
			lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
				if lighting.Brightness ~= 5 then
					lighting.Brightness = 5
				end
			end)
			
			lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
				if lighting.GlobalShadows ~= false then
					lighting.GlobalShadows = false
				end
			end)
			
			lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
				if lighting.Ambient ~= Color3.new(1, 1, 1) then
					lighting.Ambient = Color3.new(1, 1, 1)
				end
			end)
			
			lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
				if lighting.FogEnd ~= math.huge then
					lighting.FogEnd = math.huge
				end
			end)
			
			lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
				if lighting.FogStart ~= 0 then
					lighting.FogStart = 0
				end
			end)
			
			lighting.ChildAdded:Connect(function(child)
				child:Destroy()
			end)
			
			workspace.ChildAdded:Connect(function(child)
				if child.Name == "Foliage" or child.Name == "Bunny Burrow" or child.Name == "Boundaries" then
					child:Destroy()
				else
					changeMaterialAndRemoveTextures(child)
				end
			end)
			
			workspace.DescendantAdded:Connect(function(descendant)
				if descendant.Name == "Foliage" or descendant.Name == "Bunny Burrow" or descendant.Name == "Boundaries" then
					descendant:Destroy()
				elseif descendant:IsA("BasePart") then
					descendant.Material = Enum.Material.Plastic
				elseif descendant:IsA("Texture") or descendant:IsA("Decal") then
					descendant:Destroy()
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") then
					descendant:Destroy()
				end
			end)
		end
	end
})

folder:AddToggle({
	text = "Evolve Bonfire",
	flag = "toggle",
	callback = function(v)
		if v and not EvolveBonfireEnabled then
			EvolveBonfireEnabled = true
			
			local function processCoalModel(model)
				if model.Name == "Coal" and model:IsA("Model") then
					if model.PrimaryPart then
						local currentPos = model.PrimaryPart.Position
						model:SetPrimaryPartCFrame(CFrame.new(currentPos.X, currentPos.Y + 10, currentPos.Z))
					end
				end
			end
			
			local function processItemsFolder(itemsFolder)
				for _, model in pairs(itemsFolder:GetChildren()) do
					processCoalModel(model)
				end
				
				CoalConnections[#CoalConnections + 1] = itemsFolder.ChildAdded:Connect(function(child)
					processCoalModel(child)
				end)
			end
			
			local itemsFolder = workspace:FindFirstChild("Items")
			if itemsFolder then
				processItemsFolder(itemsFolder)
			end
			
			CoalConnections[#CoalConnections + 1] = workspace.ChildAdded:Connect(function(child)
				if child.Name == "Items" then
					processItemsFolder(child)
				end
			end)
			
		elseif not v and EvolveBonfireEnabled then
			EvolveBonfireEnabled = false
			
			for _, connection in pairs(CoalConnections) do
				connection:Disconnect()
			end
			CoalConnections = {}
		end
	end
})

folder:AddToggle({
	text = "Collect Wood",
	flag = "toggle",
	callback = function(v)
		if v and not CollectWoodEnabled then
			CollectWoodEnabled = true
			
		elseif not v and CollectWoodEnabled then
			CollectWoodEnabled = false
			
		end
	end
})

Window:AddLabel({
	text = "GitHub: Mkklz-h",
	type = "label"
})

Library:Init()