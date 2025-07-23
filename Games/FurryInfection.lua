local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mkklz-h/MicaHub/Home/ToraIsMeLibrary/Source.lua",true))()
local Window = Library:CreateWindow("MicaHub")

local Registro = getreg()
local Blocklist = {"kick", "ban"}

for _, func in pairs(Registro) do
    if type(func) == "function" then
        local data = getinfo(func)
        if data and data.name then
            for _, target in pairs(Blocklist) do
                if string.lower(data.name) == string.lower(target) then
                    hookfunction(data.func, function() 
                        warn("Função " .. target .. " foi bloqueada!")
                        return nil 
                    end)
                    break
                end
            end
        end
    end
end

Window:AddButton({
	text = "Tester Button",
	flag = "button",
	callback = function()
	end
})

Window:AddToggle({
	text = "Grab Players",
	flag = "toggle",
	callback = function(v)
		if v then
			local Players = game:GetService('Players')
			local TweenService = game:GetService('TweenService')
			local UserInputService = game:GetService('UserInputService')
			local RunService = game:GetService('RunService')
			local Teams = game:GetService('Teams')

			local LocalPlayer = Players.LocalPlayer

			local BackstabSystem = {}
			BackstabSystem.__index = BackstabSystem

			function BackstabSystem:new()
				local self = setmetatable({}, BackstabSystem)
				self.isAttaching = false
				self.currentTarget = nil
				self.attachConnection = nil
				self.targetConnection = nil
				self.targetTeamName = "Humans"
				self.inputConnection = nil
				self.jumpConnection = nil
				self.characterConnection = nil
				self.currentHighlight = nil
				self.highlightUpdateConnection = nil
				return self
			end

			function BackstabSystem:getCharacter()
				return LocalPlayer.Character
			end

			function BackstabSystem:getCharacterRootPart()
				local character = self:getCharacter()
				if not character then return nil end
				return character:FindFirstChild('HumanoidRootPart')
			end

			function BackstabSystem:isValidTarget(player)
				if player == LocalPlayer then return false end
				if not player.Character then return false end
				if not player.Character:FindFirstChild('HumanoidRootPart') then return false end
				
				local playerTeam = player.Team
				local myTeam = LocalPlayer.Team
				
				if not playerTeam then return false end
				if playerTeam.Name ~= self.targetTeamName then return false end
				if myTeam and playerTeam == myTeam then return false end
				
				return true
			end

			function BackstabSystem:createHighlight(player)
				if self.currentHighlight then
					self.currentHighlight:Destroy()
					self.currentHighlight = nil
				end
				
				if not player or not player.Character then return end
				
				local highlight = Instance.new("Highlight")
				highlight.Parent = player.Character
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				
				self.currentHighlight = highlight
			end

			function BackstabSystem:removeHighlight()
				if self.currentHighlight then
					self.currentHighlight:Destroy()
					self.currentHighlight = nil
				end
			end

			function BackstabSystem:updateHighlight()
				local nearestTarget = self:findNearestTarget()
				
				if nearestTarget then
					if not self.currentHighlight or self.currentHighlight.Parent ~= nearestTarget.Character then
						self:createHighlight(nearestTarget)
					end
				else
					self:removeHighlight()
				end
			end
				local myRoot = self:getCharacterRootPart()
				if not myRoot then return nil end
				
				local myPosition = myRoot.Position
				local nearestPlayer = nil
				local shortestDistance = 5
				
				for _, player in pairs(Players:GetPlayers()) do
					if not self:isValidTarget(player) then continue end
					
					local distance = (player.Character.HumanoidRootPart.Position - myPosition).Magnitude
					if distance <= shortestDistance then
						nearestPlayer = player
						shortestDistance = distance
					end
				end
				
				return nearestPlayer
			end

			function BackstabSystem:cleanup()
				if self.attachConnection then
					self.attachConnection:Disconnect()
					self.attachConnection = nil
				end
				
				if self.targetConnection then
					self.targetConnection:Disconnect()
					self.targetConnection = nil
				end
				
				self:removeHighlight()
				self.currentTarget = nil
				self.isAttaching = false
			end

			function BackstabSystem:destroy()
				self:cleanup()
				
				if self.inputConnection then
					self.inputConnection:Disconnect()
					self.inputConnection = nil
				end
				
				if self.jumpConnection then
					self.jumpConnection:Disconnect()
					self.jumpConnection = nil
				end
				
				if self.characterConnection then
					self.characterConnection:Disconnect()
					self.characterConnection = nil
				end
				
				if self.highlightUpdateConnection then
					self.highlightUpdateConnection:Disconnect()
					self.highlightUpdateConnection = nil
				end
				
				self:removeHighlight()
			end

			function BackstabSystem:validateAttachment()
				if not self.currentTarget then
					self:cleanup()
					return false
				end
				
				if not self.currentTarget.Character then
					self:cleanup()
					return false
				end
				
				if not self.currentTarget.Character:FindFirstChild('HumanoidRootPart') then
					self:cleanup()
					return false
				end
				
				if not self:getCharacterRootPart() then
					self:cleanup()
					return false
				end
				
				if not self:isValidTarget(self.currentTarget) then
					self:cleanup()
					return false
				end
				
				return true
			end

			function BackstabSystem:isCloseToTarget()
				if not self.currentTarget then return false end
				
				local myRoot = self:getCharacterRootPart()
				local targetRoot = self.currentTarget.Character and self.currentTarget.Character:FindFirstChild('HumanoidRootPart')
				
				if not myRoot or not targetRoot then return false end
				
				local distance = (myRoot.Position - targetRoot.Position).Magnitude
				return distance <= 5
			end

			function BackstabSystem:executeAttachment()
				if not self:validateAttachment() then return end
				
				local myRoot = self:getCharacterRootPart()
				local targetRoot = self.currentTarget.Character.HumanoidRootPart
				local lastTargetCFrame = targetRoot.CFrame
				
				self.attachConnection = RunService.Heartbeat:Connect(function()
					if not self:validateAttachment() then return end
					if not self:isCloseToTarget() then
						self:cleanup()
						return
					end
					
					local currentTargetCFrame = targetRoot.CFrame
					local backPosition = currentTargetCFrame * CFrame.new(0, 0, 0.5)
					
					if (currentTargetCFrame.Position - lastTargetCFrame.Position).Magnitude > 0.1 or 
					   math.abs(currentTargetCFrame.LookVector:Dot(lastTargetCFrame.LookVector)) < 0.99 then
						
						local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						local tween = TweenService:Create(myRoot, tweenInfo, {CFrame = backPosition})
						tween:Play()
						
						lastTargetCFrame = currentTargetCFrame
					else
						myRoot.CFrame = backPosition
					end
				end)
				
				self.targetConnection = self.currentTarget.CharacterRemoving:Connect(function()
					self:cleanup()
				end)
				
				local targetPlayerConnection
				targetPlayerConnection = Players.PlayerRemoving:Connect(function(player)
					if player == self.currentTarget then
						self:cleanup()
						targetPlayerConnection:Disconnect()
					end
				end)
			end

			function BackstabSystem:attachToTarget(targetPlayer)
				if not self:isValidTarget(targetPlayer) then return end
				
				local myRoot = self:getCharacterRootPart()
				local targetRoot = targetPlayer.Character.HumanoidRootPart
				
				if not myRoot or not targetRoot then return end
				
				if self.isAttaching then
					self:cleanup()
					return
				end
				
				self.isAttaching = true
				self.currentTarget = targetPlayer
				
				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local backPosition = targetRoot.CFrame * CFrame.new(0, 0, 0.5)
				
				local tween = TweenService:Create(myRoot, tweenInfo, {CFrame = backPosition})
				tween:Play()
				
				tween.Completed:Connect(function()
					self:executeAttachment()
				end)
			end

			function BackstabSystem:onJumpRequest()
				if self.isAttaching then return end
				
				local target = self:findNearestTarget()
				if not target then return end
				
				self:removeHighlight()
				self:attachToTarget(target)
			end

			function BackstabSystem:initialize()
				self.inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					if input.KeyCode ~= Enum.KeyCode.Space then return end
					
					self:onJumpRequest()
				end)
				
				self.jumpConnection = UserInputService.JumpRequest:Connect(function()
					self:onJumpRequest()
				end)
				
				self.characterConnection = LocalPlayer.CharacterRemoving:Connect(function()
					self:cleanup()
				end)
				
				self.highlightUpdateConnection = RunService.Heartbeat:Connect(function()
					if not self.isAttaching then
						self:updateHighlight()
					end
				end)
			end

			_G.backstabSystem = BackstabSystem:new()
			_G.backstabSystem:initialize()
		else
			if _G.backstabSystem then
				_G.backstabSystem:destroy()
				_G.backstabSystem = nil
			end
		end
	end
})

Window:AddLabel({
	text = "GitHub: Mkklz-h",
	type = "label"
})

Library:Init()