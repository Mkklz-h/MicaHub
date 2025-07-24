local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()
local Window = Library:CreateWindow("MicaHub")

local WalkSpeedEnabled = false
local FpsBoosterEnabled = false
local InstantChestEnabled = false

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
					player.Character.Humanoid.WalkSpeed = 25
				end
			end
			
			setWalkSpeed()
			
			game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				setWalkSpeed()
				
				character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if character.Humanoid.WalkSpeed ~= 25 then
						character.Humanoid.WalkSpeed = 25
					end
				end)
			end)
			
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if game.Players.LocalPlayer.Character.Humanoid.WalkSpeed ~= 25 then
						game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 25
					end
				end)
			end
		end
	end
})

Window:AddButton({
	text = "Instant Chests",
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

Window:AddToggle({
	text = "Super Jump",
	flag = "toggle",
	callback = function(v)
		local player = game.Players.LocalPlayer
		
		local function setSuperJump(enabled)
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				if enabled then
					player.Character.Humanoid.JumpPower = 230
				else
					player.Character.Humanoid.JumpPower = 50
				end
			end
		end
		
		setSuperJump(v)
		
		if v then
			player.CharacterAdded:Connect(function(character)
				character:WaitForChild("Humanoid")
				character.Humanoid.JumpPower = 230
			end)
		end
	end
})

Window:AddLabel({
	text = "GitHub: Mkklz-h",
	type = "label"
})

Library:Init()