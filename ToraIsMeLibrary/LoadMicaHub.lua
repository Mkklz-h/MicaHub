local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(library)
    return setmetatable({
        library = library,
        player = Players.LocalPlayer,
        playerGui = Players.LocalPlayer:WaitForChild("PlayerGui"),
        tweens = {},
        connections = {},
        customSteps = {}
    }, LoadingScreen)
end

function LoadingScreen:CreateElement(class, properties)
    return self.library:Create(class, properties)
end

function LoadingScreen:CreateGui()
    self.screenGui = self:CreateElement("ScreenGui", {
        Name = "LoadingScreen",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = self.playerGui
    })
    
    self.loadingContainer = self:CreateElement("Frame", {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundTransparency = 1,
        Parent = self.screenGui
    })
    
    self.loadingFrame = self:CreateElement("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(20, 20, 20),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.04,
        Parent = self.loadingContainer
    })
    
    return self
end

function LoadingScreen:CreateText()
    self.title = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "CARREGANDO",
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })
    
    self.percentageText = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 125),
        BackgroundTransparency = 1,
        Text = "0%",
        TextSize = 18,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })
    
    self.statusText = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 155),
        BackgroundTransparency = 1,
        Text = "Iniciando...",
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })
    
    return self
end

function LoadingScreen:CreateProgress()
    self.progressContainer = self:CreateElement("Frame", {
        Size = UDim2.new(0.8, 0, 0, 20),
        Position = UDim2.new(0.1, 0, 0, 90),
        BackgroundTransparency = 1,
        Parent = self.loadingFrame
    })
    
    self.progressBackground = self:CreateElement("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(40, 40, 40),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Parent = self.progressContainer
    })
    
    self.progressBar = self:CreateElement("ImageLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(255, 65, 65),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        ClipsDescendants = true,
        Parent = self.progressBackground
    })
    
    return self
end

function LoadingScreen:StartRainbow()
    table.insert(self.connections, RunService.Heartbeat:Connect(function()
        if not self.progressBar or not self.progressBar.Parent then return end
        local hue = (tick() % 3) / 3
        self.progressBar.ImageColor3 = Color3.fromHSV(hue, 0.8, 1)
    end))
    
    return self
end

function LoadingScreen:UpdateProgress(progress, status)
    progress = math.clamp(progress, 0, 100)
    
    local tween = TweenService:Create(self.progressBar, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(progress / 100, 0, 1, 0)}
    )
    
    table.insert(self.tweens, tween)
    tween:Play()
    
    self.percentageText.Text = math.floor(progress) .. "%"
    if status then self.statusText.Text = status end
    
    return self
end

function LoadingScreen:SetSteps(steps)
    self.customSteps = steps or {
        {10, "MICAHUB/TORAISME"},
        {25, "MICAHUB/TORAISME"},
        {40, "MICAHUB/TORAISME"},
        {60, "MICAHUB/TORAISME"},
        {80, "MICAHUB/TORAISME"},
        {95, "MICAHUB/TORAISME"},
        {100, "MICAHUB/TORAISME"}
    }
    
    return self
end

function LoadingScreen:StartSequence()
    if #self.customSteps == 0 then self:SetSteps() end
    
    spawn(function()
        wait(1)
        for i, step in ipairs(self.customSteps) do
            self:UpdateProgress(step[1], step[2])
            wait(i == #self.customSteps and 0.8 or math.random(0.5, 1.2))
        end
        wait(0.5)
        self:Destroy()
    end)
    
    return self
end

function LoadingScreen:Init()
    return self:CreateGui():CreateText():CreateProgress():StartRainbow():StartSequence()
end

function LoadingScreen:Destroy()
    for _, conn in ipairs(self.connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    
    for _, tween in ipairs(self.tweens) do
        if tween then tween:Cancel() end
    end
    
    if self.screenGui and self.screenGui.Parent then
        self.screenGui:Destroy()
    end
    
    for k, _ in pairs(self) do
        self[k] = nil
    end
    
    setmetatable(self, nil)
    return nil
end

_G.LoadingScreen = LoadingScreen
return LoadingScreen
