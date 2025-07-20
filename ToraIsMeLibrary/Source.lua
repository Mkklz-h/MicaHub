local library = {flags = {}, windows = {}, open = true}

--Services
local runService = game:GetService"RunService"
local tweenService = game:GetService"TweenService"
local textService = game:GetService"TextService"
local inputService = game:GetService"UserInputService"
local ui = Enum.UserInputType.MouseButton1
--Locals
local dragging, dragInput, dragStart, startPos, dragObject

--Functions
local function round(num, bracket)
        bracket = bracket or 1
        local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
        if a < 0 then
                a = a + bracket
        end
        return a
end

local function keyCheck(x,x1)
        for _,v in next, x1 do
                if v == x then
                        return true
                end
        end
end

local function update(input)
        local delta = input.Position - dragStart
        local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
        dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
end

--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
local rainbowTime = 5
spawn(function()
        while wait() do
                chromaColor = Color3.fromHSV(tick() % rainbowTime / rainbowTime, 1, 1)
        end
end)

function library:Create(class, properties)
        properties = typeof(properties) == "table" and properties or {}
        local inst = Instance.new(class)
        for property, value in next, properties do
                inst[property] = value
        end
        return inst
end

local function createOptionHolder(holderTitle, parent, parentTable, subHolder)
        local size = subHolder and 34 or 40
        parentTable.main = library:Create("ImageButton", {
                LayoutOrder = subHolder and parentTable.position or 0,
                Position = UDim2.new(0, 20 + (250 * (parentTable.position or 0)), 0, 20),
                Size = UDim2.new(0, 230, 0, size),
                BackgroundTransparency = 1,
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(20, 20, 20),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04,
                ClipsDescendants = true,
                Parent = parent
        })

        local round
        if not subHolder then
                round = library:Create("ImageLabel", {
                        Size = UDim2.new(1, 0, 0, size),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://3570695787",
                        ImageColor3 = parentTable.open and (subHolder and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)) or (subHolder and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)),
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(100, 100, 100, 100),
                        SliceScale = 0.04,
                        Parent = parentTable.main
                })
        end

        local title = library:Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, size),
                BackgroundTransparency = subHolder and 0 or 1,
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel = 0,
                Text = holderTitle,
                TextSize = subHolder and 16 or 17,
                Font = Enum.Font.LuckiestGuy,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = parentTable.main
        })

        local closeHolder = library:Create("Frame", {
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(-1, 0, 1, 0),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 1,
                Parent = title
        })

        local close = library:Create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -size - 10, 1, -size - 10),
                Rotation = parentTable.open and 90 or 180,
                BackgroundTransparency = 1,
                Image = "rbxassetid://4918373417",
                ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30),
                ScaleType = Enum.ScaleType.Fit,
                Parent = closeHolder
        })

        parentTable.content = library:Create("Frame", {
                Position = UDim2.new(0, 0, 0, size),
                Size = UDim2.new(1, 0, 1, -size),
                BackgroundTransparency = 1,
                Parent = parentTable.main
        })

        local layout = library:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = parentTable.content
        })

        layout.Changed:connect(function()
                parentTable.content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
                parentTable.main.Size = #parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size)
        end)

        if not subHolder then
                library:Create("UIPadding", {
                        Parent = parentTable.content
                })

                title.InputBegan:connect(function(input)
                        if input.UserInputType == ui then
                                dragObject = parentTable.main
                                dragging = true
                                dragStart = input.Position
                                startPos = dragObject.Position
                        elseif input.UserInputType == Enum.UserInputType.Touch then
                                dragObject = parentTable.main
                                dragging = true
                                dragStart = input.Position
                                startPos = dragObject.Position
                        end
                end)
                title.InputChanged:connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                dragInput = input
                        elseif dragging and input.UserInputType == Enum.UserInputType.Touch then
                                dragInput = input
                        end
                end)
                        title.InputEnded:connect(function(input)
                        if input.UserInputType == ui then
                                dragging = false
                        elseif input.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                        end
                end)
        end

        closeHolder.InputBegan:connect(function(input)
                if input.UserInputType == ui then
                        parentTable.open = not parentTable.open
                        tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
                        if subHolder then
                                tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
                        else
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
                        end
                        parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
                elseif input.UserInputType == Enum.UserInputType.Touch then
                        parentTable.open = not parentTable.open
                        tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
                        if subHolder then
                                tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
                        else
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
                        end
                        parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
                end
        end)

        function parentTable:SetTitle(newTitle)
                title.Text = tostring(newTitle)
        end

        return parentTable
end

local function createLabel(option, parent)
        local main = library:Create("TextLabel", {
                LayoutOrder = option.position,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Text = " " .. option.text,
                TextSize = 17,
                Font = Enum.Font.GothamBlack,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent.content
        })

        setmetatable(option, {__newindex = function(t, i, v)
                if i == "Text" then
                        main.Text = " " .. tostring(v)
                end
        end})
end

function createToggle(option, parent)
        local main = library:Create("TextLabel", {
                LayoutOrder = option.position,
                Size = UDim2.new(1, 0, 0, 31),
                BackgroundTransparency = 1,
                Text = " " .. option.text,
                TextSize = 17,
                Font = Enum.Font.GothamBlack,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent.content
        })

        local tickboxOutline = library:Create("ImageLabel", {
                Position = UDim2.new(1, -6, 0, 4),
                Size = UDim2.new(-1, 10, 1, -10),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 1,
                Image = "rbxassetid://3570695787",
                ImageColor3 = option.state and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(100, 100, 100),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.02,
                Parent = main
        })

        local tickboxInner = library:Create("ImageLabel", {
                Position = UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(1, -4, 1, -4),
                BackgroundTransparency = 1,
                Image = "rbxassetid://3570695787",
                ImageColor3 = option.state and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(20, 20, 20),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.02,
                Parent = tickboxOutline
        })

        local checkmarkHolder = library:Create("Frame", {
                Position = UDim2.new(0, 4, 0, 4),
                Size = option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Parent = tickboxOutline
        })

        local checkmark = library:Create("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 1,
                Image = "rbxassetid://4919148038",
                ImageColor3 = Color3.fromRGB(20, 20, 20),
                Parent = checkmarkHolder
        })

        local inContact
        main.InputBegan:connect(function(input)
                if input.UserInputType == ui then
                        option:SetState(not option.state)
                elseif input.UserInputType == Enum.UserInputType.Touch then
                        option:SetState(not option.state)
                end
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = true
                        if not option.state then
                                tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
                        end
                end
        end)

        main.InputEnded:connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = true
                        if not option.state then
                                tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                        end
                end
        end)

        function option:SetState(state)
                library.flags[self.flag] = state
                self.state = state
                checkmarkHolder:TweenSize(option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
                tweenService:Create(tickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = state and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(20, 20, 20)}):Play()
                if state then
                        tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
                else
                        if inContact then
                                tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
                        else
                                tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                        end
                end
                self.callback(state)
        end

        if option.state then
                delay(1, function() option.callback(true) end)
        end

        setmetatable(option, {__newindex = function(t, i, v)
                if i == "Text" then
                        main.Text = " " .. tostring(v)
                end
        end})
end

function createButton(option, parent)
        local main = library:Create("TextLabel", {
                ZIndex = 2,
                LayoutOrder = option.position,
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Text = " " .. option.text,
                TextSize = 17,
                Font = Enum.Font.GothamBlack,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = parent.content
        })

        local round = library:Create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -12, 1, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(40, 40, 40),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.02,
                Parent = main
        })

        local inContact
        local clicking
        main.InputBegan:connect(function(input)
                if input.UserInputType == ui then
                        library.flags[option.flag] = true
                        clicking = true
                        tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
                        option.callback()
                elseif input.UserInputType == Enum.UserInputType.Touch then
                        library.flags[option.flag] = true
                        clicking = true
                        tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
                        option.callback()
                end
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = true
                        tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                end
        end)

        main.InputEnded:connect(function(input)
                if input.UserInputType == ui then
                        clicking = false
                        if inContact then
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                        else
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end
                elseif input.UserInputType == Enum.UserInputType.Touch then
                        clicking = false
                        if inContact then
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                        else
                                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end
                end
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = false
                        if not clicking then
                                tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end
                end
        end)
end

local function createBind(option, parent)
        local binding
        local holding
        local loop
        local text = string.match(option.key, "Mouse") and string.sub(option.key, 1, 5) .. string.sub(option.key, 12, 13) or option.key

        local main = library:Create("TextLabel", {
                LayoutOrder = option.position,
                Size = UDim2.new(1, 0, 0, 33),
                BackgroundTransparency = 1,
                Text = " " .. option.text,
                TextSize = 17,
                Font = Enum.Font.GothamBlack,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent.content
        })

        local round = library:Create("ImageLabel", {
                Position = UDim2.new(1, -6, 0, 4),
                Size = UDim2.new(0, -textService:GetTextSize(text, 16, Enum.Font.GothamBlack, Vector2.new(9e9, 9e9)).X - 16, 1, -10),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 1,
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(40, 40, 40),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.02,
                Parent = main
        })

        local bindinput = library:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextSize = 16,
                Font = Enum.Font.GothamBlack,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = round
        })

        local inContact
        main.InputBegan:connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = true
                        if not binding then
                                tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                        end
                end
        end)

        main.InputEnded:connect(function(input)
                if input.UserInputType == ui then
                        binding = true
                        bindinput.Text = "..."
                        tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
                elseif input.UserInputType == Enum.UserInputType.Touch then
                        binding = true
                        bindinput.Text = "..."
                        tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
                end
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                        inContact = false
                        if not binding then
                                tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end
                end
        end)

        inputService.InputBegan:connect(function(input)
                if inputService:GetFocusedTextBox() then return end
                if (input.KeyCode.Name == option.key or input.UserInputType.Name == option.key) and not binding then
                        if option.hold then
                                loop = runService.Heartbeat:connect(function()
                                        if binding then
                                                option.callback(true)
                                                loop:Disconnect()
                                                loop = nil
                                        else
                                                option.callback()
                                        end
                                end)
                        else
                                option.callback()
                        end
                elseif binding then
                        local key
                        pcall(function()
                                if not keyCheck(input.KeyCode, blacklistedKeys) then
                                        key = input.KeyCode
                                end
                        end)
                        pcall(function()
                                if keyCheck(input.UserInputType, whitelistedMouseinputs) and not key then
                                        key = input.UserInputType
                                end
                        end)
                        key = key or option.key
                        option:SetKey(key)
                end
        end)

        inputService.InputEnded:connect(function(input)
                if input.KeyCode.Name == option.key or input.UserInputType.Name == option.key or input.UserInputType.Name == "MouseMovement" then
                        if loop then
                                loop:Disconnect()
                                loop = nil
                                option.callback(true)
                        end
                end
        end)

        function option:SetKey(key)
                binding = false
                if loop then
                        loop:Disconnect()
                        loop = nil
                end
                self.key = key or self.key
                self.key = self.key.Name or self.key
                library.flags[self.flag] = self.key
                if string.match(self.key, "Mouse") then
                        bindinput.Text = string.sub(self.key, 1, 5) .. string.sub(self.key, 12, 13)
                else
                        bindinput.Text = self.key
                end
                tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
                round.Size = UDim2.new(0, -textService:GetTextSize(bindinput.Text, 15, Enum.Font.GothamBlack, Vector2.new(9e9, 9e9)).X - 16, 1, -10)        
        end
end
